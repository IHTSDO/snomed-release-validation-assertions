#!/usr/bin/env python3
"""Finds assertions that cannot report a finding for any release.

Dependency-free on purpose: it reads `.sql` files as committed and needs no
database and no schema, so it can run on every pull request.

## What it looks for

A `SELECT` that reads no rows still RETURNS a row. Two consequences, and every
assertion built on either reports a pass for every release ever validated:

  NOT EXISTS(SELECT <expression>)                 -- no FROM and no WHERE
  NOT EXISTS(SELECT COUNT(1) FROM <table>)        -- ungrouped aggregate

The first is one row unconditionally. The second is one row even when the table
is EMPTY - which is the sharper case, because the assertions carrying it exist to
detect exactly that.

Two more shapes are equally unsatisfiable: the same function call required and
forbidden as adjacent conjuncts (`NOT f(x) AND f(x)`), and a comparison to NULL
(`col = NULL`), which is NULL rather than true. A table reference whose case
differs from the RVF schema is reported too, because MySQL on Linux treats it
as a different table.

Such an assertion is not slow, skipped or erroring - it runs, inserts nothing,
and is reported as passed with a failure count of zero, which is what a clean
release looks like.

## Usage

    assertion_lint.py <dir-or-file> [...]        # exits 1 if any are found
    assertion_lint.py --format=github <dir>      # ::error annotations for CI
    assertion_lint.py --ddl create-tables.sql <dir>   # table names from a schema
    assertion_lint_selftest.py                    # the checks, on fixtures

Exit status is 1 when something is found and 0 otherwise, so it works as a
build step with no wrapper.
"""
import argparse
import pathlib
import re
import sys

NOT_EXISTS_SELECT = re.compile(r'NOT\s+EXISTS\s*\(\s*SELECT\b', re.I)
FROM = re.compile(r'\bFROM\b', re.I)
AGGREGATE = re.compile(r'\b(COUNT|SUM|MAX|MIN|AVG)\s*\(', re.I)
GROUPED = re.compile(r'\bGROUP\s+BY\b|\bHAVING\b', re.I)
# Anything that can reduce a FROM-less SELECT to zero rows.
FILTER = re.compile(r'\bWHERE\b|\bHAVING\b', re.I)
# `x = null`, `x <> (NULL)`, `x >= null` and friends. In SQL a comparison to
# NULL is NULL, never true, so a WHERE built on one selects nothing and a
# conjunct built on one makes the whole conjunction unsatisfiable. `<=>` is
# NULL-safe and is not matched: after `<=` comes `>`, not NULL. Not covered:
# `NULL = x` (NULL on the left) and `x IN (NULL)`.
NULL_COMPARISON = re.compile(r'([\w.@]+)\s*(?:<>|!=|<=|>=|=|<|>)\s*\(?\s*NULL\b', re.I)
# A function call with no nested parentheses in its arguments.
_CALL = r'(\b([A-Za-z_]\w*)\s*\([^()]*\))'
# A lookahead, so that overlapping pairs (`f(x) AND NOT f(x) AND f(x)`) are all
# seen.
ADJACENT_CONTRADICTION = re.compile(
    r'(?=(\bNOT\s+)?' + _CALL + r'\s+AND\s+(NOT\s+)?' + _CALL + ')', re.I)
# Words that take a parenthesised list but are not function calls.
NOT_A_FUNCTION = frozenset({'in', 'exists', 'any', 'all', 'some', 'values'})
# What may come right before a conjunct: the left call of a contradiction must
# start one, not be the right-hand side of a comparison (`y < abs(v) AND NOT
# abs(v)` is satisfiable).
CONJUNCT_START = re.compile(r'(?:\(|\b(?:WHERE|AND|ON|WHEN|HAVING))\s*$', re.I)
# An AND that belongs to BETWEEN (`x BETWEEN f(a) AND g(b)`) does not start one:
# a BETWEEN with no other AND after it.
BETWEEN_AND = re.compile(r'\bBETWEEN\b(?:(?!\bAND\b)[^;])*\bAND\s*$', re.I)
# Tokens for finding an OR (or MySQL's `||`) at the same nesting level as a
# finding, and where that level's boolean expression starts and ends.
BOOL_TOKEN = re.compile(r'[();]|\|\||\b[A-Za-z_]\w*\b')
BOOL_START = frozenset({'where', 'on', 'having', 'when', 'if', 'elseif', 'while',
                        'until', 'return', 'select', 'from', 'set'})
BOOL_END = frozenset({'group', 'order', 'having', 'limit', 'union', 'where',
                      'then', 'join', 'into'})
# Comments (`/* */`, `#`, and `--` followed by whitespace, which is MySQL's
# rule: `a--1` is a minus a minus one) and quoted literals, in one pass so that a
# quote inside a comment and a comment marker inside a literal are each read
# correctly.
NOT_CODE = re.compile(
    r"/\*.*?\*/|--(?=\s|$)[^\n]*|#[^\n]*|'(?:[^'\\]|\\.|'')*'|\"(?:[^\"\\]|\\.|\"\")*\"", re.S)
# Tokens that decide which clause `x = NULL` is in.
CONTEXT_TOKEN = re.compile(r'[();]|\b[A-Za-z_]\w*\b(\s*\()?')
ASSIGNING = frozenset({'set', 'update'})
CLAUSE = ASSIGNING | frozenset({'select', 'from', 'join', 'where', 'on', 'having',
                                'when', 'if', 'elseif', 'while', 'until', 'return',
                                'then', 'else'})
# Words followed by `(` that are not function calls.
NOT_A_CALL = CLAUSE | NOT_A_FUNCTION | frozenset({'and', 'or', 'not', 'case', 'end',
                                                  'between', 'like', 'is', 'as', 'using',
                                                  'into', 'by', 'distinct'})
# Boolean operators continue the current clause; inside a SET list or a select
# list (`SET flag = a AND b, other = NULL`) they do not start a condition.
OPERATOR = frozenset({'and', 'or', 'not'})


def strip_comments(sql: str, literals: bool = True) -> str:
    """Comments and (unless `literals` is False) string literals, replaced by
    spaces so every offset is preserved - a finding reports a line number and
    it has to be the real one. Neither is SQL that executes, so neither can
    make an assertion unable to fire. The case check keeps literals, because a
    procedure's dynamic SQL is built from them."""
    def blank(m):
        if not literals and m.group(0)[0] in '\'"':
            return m.group(0)
        return re.sub(r'[^\n]', ' ', m.group(0))
    return NOT_CODE.sub(blank, sql)


def clauses_at(sql: str, at: int):
    """For each enclosing nesting level at offset `at`, outermost first:
    (clause keyword, lower-case or None; whether the level is a function
    call's argument list).

    At each level, the nearest clause keyword: anything inside
    parentheses (a subquery, `IF(...)`, `COALESCE(...)`) or inside
    `CASE ... END` is skipped, so in `SET a = CASE WHEN ... END, b = NULL` the
    clause at `b` is still `set`. AND/OR/NOT only count where the clause is not
    already `set`, `update` or `select`.
    """
    # One frame per nesting level: [clause keyword, is a CASE frame, is a call].
    frames = [[None, False, False]]
    for m in CONTEXT_TOKEN.finditer(sql, 0, at):
        tok = m.group(0)
        if tok == '(':
            frames.append([None, False, False])
        elif tok == ')':
            if len(frames) > 1:
                frames.pop()
        elif tok == ';':
            frames = [[None, False, False]]
        else:
            word = re.match(r'\w+', tok).group(0).lower()
            # `IF(` is the function; the IF statement is `IF cond THEN`.
            if word != 'if' or not m.group(1):
                if word == 'case':
                    frames.append([None, True, False])
                elif word == 'end':
                    if frames[-1][1]:
                        frames.pop()
                elif word in CLAUSE:
                    frames[-1][0] = word
                elif word in OPERATOR and frames[-1][0] not in ASSIGNING | {'select'}:
                    frames[-1][0] = word
            if m.group(1):
                # `(` after a word: a function's argument list, unless the word
                # is a keyword (`WHERE (`, `EXISTS (`, `IN (`).
                frames.append([None, False, word == 'if' or word not in NOT_A_CALL])
    return [(f[0], f[2]) for f in frames]


def or_at_same_level(sql: str, start: int, end: int) -> bool:
    """Whether an OR shares the boolean expression containing sql[start:end],
    at its own nesting level or that of any enclosing grouping parentheses -
    in which case a contradiction there only removes one branch, and the
    expression can still be true. A subquery or function argument list is a
    boundary: a contradiction inside one is not rescued by an OR outside it."""
    # CASE ... END nests like parentheses, so a CASE between the finding and an
    # OR does not hide the OR; it is never stepped out of, though. `||` is OR.
    nesting = {'case': '(', 'end': ')', '||': 'or'}
    raw = [(m.start(), m.end(), m.group(0).lower()) for m in BOOL_TOKEN.finditer(sql)]
    tokens = [(a, b, nesting.get(t, t)) for a, b, t in raw]
    first = next(i for i, t in enumerate(tokens) if t[0] >= start)
    last = max(i for i, t in enumerate(tokens) if t[1] <= end)
    while True:
        found = False
        # Backwards to this level's opening paren or clause keyword.
        depth, i = 0, first - 1
        while i >= 0:
            t = tokens[i][2]
            if t == ')':
                depth += 1
            elif t == '(':
                if depth == 0:
                    break
                depth -= 1
            elif t == ';' or (depth == 0 and t in BOOL_START | BOOL_END):
                break
            elif depth == 0 and t == 'or':
                found = True
            i -= 1
        opening = i if i >= 0 and raw[i][2] == '(' else None
        # Forwards to this level's closing paren or clause keyword.
        depth, k = 0, last + 1
        while k < len(tokens):
            t = tokens[k][2]
            if t == '(':
                depth += 1
            elif t == ')':
                if depth == 0:
                    break
                depth -= 1
            elif t == ';' or (depth == 0 and t in BOOL_START | BOOL_END):
                break
            elif depth == 0 and t == 'or':
                found = True
            k += 1
        if found:
            return True
        # Step out only through grouping parentheses.
        if opening is None or k >= len(tokens) or raw[k][2] != ')':
            return False
        before = tokens[opening - 1][2] if opening > 0 else None
        inner = tokens[opening + 1][2] if opening + 1 < len(tokens) else None
        if inner == 'select' or before not in {None, '(', 'and', 'or', 'not'} | BOOL_START:
            return False
        first, last = opening, k


def subquery_body(sql: str, after_select: int):
    """The text between `SELECT` and the paren closing its subquery."""
    depth = 1
    for i in range(after_select, len(sql)):
        c = sql[i]
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return sql[after_select:i]
    return None


def findings(sql: str):
    """(line, reason) for every shape that makes an assertion unable to fire.

    Only `NOT EXISTS` and only its own subquery. A bare `EXISTS(SELECT 1)` is a
    normal way to write a constant, an aggregate in the OUTER projection is how
    most assertions count things, and an aggregate WITH a `GROUP BY` returns
    no row for an empty group - so all three are left alone.
    """
    out = []
    clean = strip_comments(sql)
    for m in NOT_EXISTS_SELECT.finditer(clean):
        inner = subquery_body(clean, m.end())
        if inner is None:
            continue
        line = clean.count('\n', 0, m.start()) + 1
        if not FROM.search(inner):
            # `SELECT 1 WHERE 1=0` has no FROM and returns no row, so a NOT
            # EXISTS over it is satisfiable.
            if FILTER.search(inner):
                continue
            out.append((line, 'NOT EXISTS over a SELECT with no FROM and no WHERE:'
                              ' it returns exactly one row, so this can never be'
                              ' true. A function call here does not change that -'
                              ' EXISTS counts the rows the subquery yields, not'
                              ' what the function reads or returns, so a function'
                              ' that queries an empty table or returns NULL still'
                              ' yields one row'))
            continue
        projection = FROM.split(inner, 1)[0]
        if AGGREGATE.search(projection) and not GROUPED.search(inner):
            out.append((line, 'NOT EXISTS over an ungrouped aggregate: it returns one'
                              ' row even when the table is empty, so this can never'
                              ' be true - including for the empty table it is'
                              ' presumably checking for'))

    # The same call required and forbidden as ADJACENT conjuncts:
    # `NOT f(id, R) AND f(id, R)` selects nothing for any release.
    #
    # Only adjacent ones. The same call legitimately appears negated and plain
    # on the two sides of an OR, or in separate subqueries; requiring the two
    # calls to be separated by nothing but `AND` cannot span either. And not
    # when an OR shares the expression (`f(x) OR NOT g(x) AND g(x)`): the
    # contradiction then removes one branch, and the WHERE can still be true.
    for m in ADJACENT_CONTRADICTION.finditer(clean):
        left_not, left, left_name, right_not, right, right_name = m.groups()
        if left_name.lower() in NOT_A_FUNCTION or right_name.lower() in NOT_A_FUNCTION:
            continue
        if re.sub(r'\s+', '', left).lower() != re.sub(r'\s+', '', right).lower():
            continue
        if bool(left_not) == bool(right_not):
            continue
        # The left call must start a conjunct, and an AND that belongs to
        # BETWEEN does not start one.
        if (not CONJUNCT_START.search(clean, 0, m.start())
                or BETWEEN_AND.search(clean, 0, m.start())):
            continue
        if or_at_same_level(clean, m.start(), m.end(5)):
            continue
        line = clean.count('\n', 0, m.start()) + 1
        out.append((line, f'the same predicate is required and forbidden as adjacent'
                          f' conjuncts - {left.strip()[:56]} - so this can never be true'))

    # A comparison to NULL, which is NULL rather than true.
    for m in NULL_COMPARISON.finditer(clean):
        # Inside an assignment (`SET x = NULL`, `SET a = CASE WHEN b = NULL ...`)
        # or an output column of a select list (including a CASE or scalar
        # subquery there), the comparison computes a value; it does not decide
        # whether a row is returned.
        # The same inside a function's arguments (`IF(x = NULL, 1, 0)`,
        # `COALESCE(x = NULL, 1)`): the function decides what the value means.
        if any(c in ASSIGNING or c == 'select' or call
               for c, call in clauses_at(clean, m.start())):
            continue
        # `a = 1 OR b = NULL`: the other branch can still be true.
        if or_at_same_level(clean, m.start(), m.end()):
            continue
        line = clean.count('\n', 0, m.start()) + 1
        out.append((line, f'{m.group(1)} is compared to NULL, which is never true -'
                          f' use IS NULL, or bind the value this was meant to test'))
    return out


# The table names declared by RVF's src/main/resources/sql/create-tables-mysql.sql
# (develop), without the _f/_s/_d suffix. Built in because this repository does
# not contain the DDL; --ddl reads them from a schema file instead.
RF2_TABLE_STEMS = frozenset({
    'associationrefset',
    'attributevaluerefset',
    'complexmaprefset',
    'concept',
    'description',
    'descriptiontyperefset',
    'expressionassociationrefset',
    'extendedmaprefset',
    'langrefset',
    'mapcorrelationoriginrefset',
    'moduledependencyrefset',
    'mrcmattributedomainrefset',
    'mrcmattributerangerefset',
    'mrcmdomainrefset',
    'mrcmmodulescoperefset',
    'owlexpressionrefset',
    'refsetdescriptor',
    'relationship',
    'relationship_concrete_values',
    'simplemaprefset',
    'simplerefset',
    'stated_relationship',
    'textdefinition',
})

# `curr_concept_s`, `prev_Concept_s`, `<PROSPECTIVE>.concept_s`: an optional
# curr_/prev_ prefix, the table name, and the release-type suffix.
TABLE_REFERENCE = re.compile(r'\b(?:(?:curr|prev)_)?([A-Za-z][A-Za-z_0-9]*?)_[fsd]\b', re.I)


def table_stems(ddl_path):
    """The table names the schema declares, minus the RF2 kind suffix."""
    ddl = pathlib.Path(ddl_path).read_text(encoding='utf-8', errors='replace')
    names = {m.group(1) for m in re.finditer(r'create\s+table\s+([A-Za-z_0-9]+)', ddl, re.I)}
    return {re.sub(r'_(f|s|d)$', '', n.lower()) for n in names}


def case_mismatches(sql, stems):
    """Table references whose CASE does not match the schema.

    MySQL compares table names case-sensitively wherever
    `lower_case_table_names = 0`, which is the default on Linux, so
    `curr_Concept_s` and `curr_concept_s` are different tables and one of them
    does not exist. The statement then fails with "Table ... doesn't exist" and
    the assertion reports an execution failure rather than a finding. MySQL on
    macOS and Windows resolves names case-insensitively, so it is easy to miss.
    """
    out = []
    for m in TABLE_REFERENCE.finditer(sql):
        ref = m.group(0)
        if m.group(1).lower() in stems and ref != ref.lower():
            line = sql.count('\n', 0, m.start()) + 1
            out.append((line, f'{ref} is spelled differently from the schema, which declares'
                              f' {ref.lower()} - MySQL compares table names case-sensitively on'
                              f' Linux, so this statement fails on a table that does not exist'))
    return out


def sql_files(targets):
    for t in targets:
        p = pathlib.Path(t)
        if p.is_dir():
            yield from sorted(p.rglob('*.sql'))
        elif p.suffix.lower() == '.sql':
            yield p


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('targets', nargs='+', help='directories or .sql files')
    ap.add_argument('--format', choices=('text', 'github'), default='text',
                    help='github emits ::error annotations')
    ap.add_argument('--ddl', help='create-tables SQL, to check table names for case')
    args = ap.parse_args()

    stems = table_stems(args.ddl) if args.ddl else RF2_TABLE_STEMS

    scanned = 0
    hits = []
    for path in sql_files(args.targets):
        scanned += 1
        try:
            sql = path.read_text(encoding='utf-8', errors='replace')
        except OSError as e:
            print(f'{path}: unreadable: {e}', file=sys.stderr)
            continue
        for line, reason in findings(sql):
            hits.append((path, line, reason))
        for line, reason in case_mismatches(strip_comments(sql, literals=False), stems):
            hits.append((path, line, reason))

    for path, line, reason in hits:
        if args.format == 'github':
            print(f'::error file={path},line={line},title=Assertion cannot fire::{reason}')
        else:
            print(f'{path}:{line}: {reason}')

    print(f'\n{scanned} assertion file(s) scanned, {len(hits)} that cannot fire',
          file=sys.stderr)
    if hits:
        print('An assertion that cannot report a finding passes for every release'
              ' it validates: it executes, finds nothing, and a clean release looks'
              ' the same.', file=sys.stderr)
    return 1 if hits else 0


if __name__ == '__main__':
    sys.exit(main())
