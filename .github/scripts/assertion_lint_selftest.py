#!/usr/bin/env python3
"""Do the checks in assertion_lint.py find what they should, and only that?

Each case is a small SQL fragment and the number of findings it must produce.
The false-positive cases matter as much as the true ones: a linter that reports
valid SQL gets switched off.

Run: python3 .github/scripts/assertion_lint_selftest.py
"""
import contextlib
import io
import pathlib
import sys
import tempfile

sys.dont_write_bytecode = True  # leave no __pycache__ in the checkout
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import assertion_lint as lint  # noqa: E402

FINDINGS = [
    # NOT EXISTS over something that always exists.
    ("select 1 where not exists (select 1)", 1),
    ("select 1 where not exists (select count(1) from curr_concept_s)", 1),
    ("select 1 where not exists (select 1 where 1 = 0)", 0),
    ("select 1 where not exists (select count(1) from curr_concept_s group by id)", 0),
    ("select 1 where exists (select 1)", 0),
    ("select 1 where not exists (select (select 1 from curr_concept_s))", 1),
    ("select 1 where not exists (select (select count(*) from u where u.id = t.id) from t where t.x = 1)", 0),
    ("select 1 where not exists (select count(*) over () from t)", 0),
    ("select 1 where not exists (select count(*) from t where id in (select id from u group by id))", 1),
    ("select 1 where not exists (select coalesce(max(id), 0) from curr_concept_s)", 1),
    ("select 1 where not exists (select ifnull(count(*), 0) from curr_concept_s)", 1),
    ("select 1 where not exists (select (count(*)) from curr_concept_s)", 1),

    # The same call required and forbidden as adjacent conjuncts.
    ("select a.id from curr_concept_s a where not f(a.id, 1) and f(a.id, 1)", 1),
    ("select a.id from curr_concept_s a where f(a.id, 1) and not f(a.id, 1)", 1),
    ("select a.id from curr_concept_s a where f(a.id) and not f(a.id) and f(a.id)", 2),
    ("select a.id from curr_concept_s a where not f(a.id, 1) and f(a.id, 2)", 0),
    ("select a.id from curr_concept_s a where not f(a.id) or f(a.id)", 0),
    ("select a.id from curr_concept_s a where f(a.id) and f(a.id)", 0),
    ("select a.id from curr_concept_s a where a.id not in (1) and a.id in (1)", 0),
    ("select a.id from curr_concept_s a where not exists (select 1) and exists (select 1)", 1),
    ("select a.id from curr_concept_s a where a.x between f(1) and f(1)", 0),
    ("select a.id from curr_concept_s a where a.x between f(a.y) and g(a.y) and not g(a.y)", 0),
    ("select a.id from curr_concept_s a where a.x between 1 and 2 and not g(a.y) and g(a.y)", 1),
    ("select a.id from curr_concept_s a where (not f(a.id) and f(a.id))", 1),
    ("select a.id from curr_concept_s a where a.y < abs(a.v) and not abs(a.v)", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and not f(a.id)", 0),
    ("select a.id from curr_concept_s a where f(a.x) or not g(a.x) and g(a.x)", 0),
    ("select a.id from curr_concept_s a where not g(a.x) and g(a.x) or f(a.x)", 0),
    ("select a.id from curr_concept_s a where (f(a.x) or h(a.x)) and not g(a.x) and g(a.x)", 1),
    ("select a.id from curr_concept_s a where a.z or (not g(a.x) and g(a.x))", 0),
    ("select a.id from curr_concept_s a where a.z or exists (select 1 from u where not g(u.x) and g(u.x))", 1),
    ("select a.id from curr_concept_s a where not g(a.x) and g(a.x) and case when a.b = 1 then 1 end = 1 or a.c = 1", 0),
    ("select a.id from curr_concept_s a where a.c = 1 || not g(a.x) and g(a.x)", 0),
    ("select a.id from curr_concept_s a where not abs(a.id) and abs(a.id) = 0", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) is null", 1),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) is true", 1),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) is not false", 1),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) is not null", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) is false", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) + 1 > 2", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) group by a.id", 1),
    ("select a.id from curr_concept_s a where case when not g(a.x) and g(a.x) then 1 when a.y = 1 then 1 end = 1", 1),
    ("select a.id from curr_concept_s a where case when not f(a.x) and f(a.x) then 1 else 0 end = 1", 1),
    ("select a.id from curr_concept_s a where case when a.y = 1 then not g(a.x) and g(a.x) else false end", 1),
    ("select a.id from t a join u b on not f(b.id) and f(b.id) where a.x = 1", 1),
    ("select a.id from t a join u b on not f(b.id) and f(b.id) left join v c on c.id = a.id", 1),
    ("select a.id from curr_concept_s a where if(not f(a.x) and f(a.x), 1, 0)", 1),
    ("while not f(x) and f(x) do set y = 1; end while;", 1),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) xor a.z", 0),
    ("select a.id from curr_concept_s a where not f(a.id) and f(a.id) not in (1)", 0),
    ("select a.id from curr_concept_s a where not f(\n  a.id) and f(a.id)", 1),

    # Comparisons to NULL.
    ("select a.id from curr_concept_s a where a.moduleid = null", 1),
    ("select a.id from curr_concept_s a where a.moduleid = (NULL)", 1),
    ("select a.id from curr_concept_s a where a.active = 1 and a.moduleid <> null", 1),
    ("select 1 from t where not exists (select 1 from u where u.x = null))", 1),
    ("select 1 from t where t.id in (select id from u where u.x = null))", 1),
    ("update t set a.col = null where a.x = null", 1),
    ("if x = null then set y = 1; end if;", 1),
    ("if y = 1 then set z = 1; elseif x = null then set z = 2; end if;", 1),
    ("if (x = null) then set y = 1; end if;", 1),
    ("begin if (x = null) then set y = 1; end if; end", 1),
    ("if a = 1 then if (x = null) then set y = 1; end if; end if;", 1),
    ("if (tb_name != 'moduledependencyrefset_d') then set y = 1; end if;", 0),
    ("if (select count(*) from t where x = 1) > 0 then set y = 1; end if;", 0),
    ("set y = if(x = null, 1, 0);", 0),
    ("select a.id from curr_concept_s a where case when a.b = 1 then if(a.x = null, 1, 0) end = 1", 0),
    ("(select id from t where x = 1) union (select id from t where x = null)", 1),
    ("insert into res (select id from t where x = null)", 1),
    ("insert into res(id, x) select id, x from t where x = 1", 0),
    ("select a.id from curr_concept_s a where `moduleId` = null", 1),
    ("select a.id from curr_concept_s a where a.`moduleId` = null", 1),
    ("select a.id from curr_concept_s a where coalesce(a.x, a.y) = null", 1),
    ("select a.id from curr_concept_s a where (select max(u.id) from u) = null", 1),
    ("select a.id from curr_concept_s a where (a.x) = null", 1),
    ("select a.id from curr_concept_s a where a.x = 1 or coalesce(a.x, a.y) = null", 0),
    ("select a.id, coalesce(a.x, 1) = null from curr_concept_s a", 0),
    ("select a.id from curr_concept_s a where if(a.x, a.y, a.z) = 0", 0),
    ("select a.id from curr_concept_s a where case when a.x = null then 1 when a.y = 1 then 1 end = 1", 1),
    ("select a.id from curr_concept_s a where case when a.x = null then 1 else 0 end = 1", 1),
    ("case v when 1 then if (x = null) then set y = 1; end if; end case;", 1),
    ("select a.id from curr_concept_s a where case when a.b = 1 then case when a.c = 1 then if(a.x = null, 1, 0) end end = 1", 0),
    ("select a.id from curr_concept_s a where case when a.x = null then 1 else 0 end = 0", 1),
    ("select a.id from curr_concept_s a where case when a.y = 1 then a.x = null else 1 end", 1),
    ("select a.id from curr_concept_s a where case when a.y = 1 then case when a.x = null then 1 end end = 1", 1),
    ("select a.id from curr_concept_s a where case when exists (select 1 from u where u.x = null) then 1 else 0 end = 1", 1),
    ("set a = case when c = null then 1 end", 0),
    ("select a.id from curr_concept_s a where a.moduleid >= null", 1),
    ("select a.id from curr_concept_s a where a.moduleid is null", 0),
    ("select a.id from curr_concept_s a where a.active = 1 or a.moduleid = null", 0),
    ("select a.id from curr_concept_s a where a.x = 1 and a.y = null or a.z = 1", 0),
    ("select a.id from curr_concept_s a where a.z = 1 or (a.x = 1 and a.y = null)", 0),
    ("select a.id from curr_concept_s a where a.y = null and case when a.b = 1 then 1 end = 1 or a.c = 1", 0),
    ("select a.id from curr_concept_s a where a.c = 1 or case when a.b = 1 then 1 end = 1 and a.y = null", 0),
    ("select a.id from curr_concept_s a where a.y = null and case when a.b = 1 or a.d = 1 then 1 end = 1", 1),
    ("select a.id from curr_concept_s a where a.x = 1 || a.y = null", 0),
    ("select a.id from curr_concept_s a where if(a.x = null, 1, 0) = 0", 0),
    ("select a.id from curr_concept_s a where coalesce(a.x = null, 1) = 1", 0),
    ("select a.id from curr_concept_s a where (a.x = null) and a.z = 1", 1),
    ("select a.id from curr_concept_s a where a.id in (select u.id from u where u.c = null) and f(a.id)", 1),
    ("select a.id from curr_concept_s a where (a.z = 1 or a.w = 1) and a.y = null", 1),
    ("select a.id from curr_concept_s a where a.z = 1 or exists (select 1 from u where u.y = null)", 1),
    ("select a.id, case when a.x = null then 1 else 0 end from curr_concept_s a", 0),
    ("select a.id from curr_concept_s a where case when a.x = null then 1 end = 1", 1),
    ("update t set a = (case when b = null then 1 end)", 0),
    ("select a.id, (select max(u.id) from u where u.c = null) from curr_concept_s a", 0),
    ("select a.id from curr_concept_s a where a.id in (select u.id from u where u.c = null)", 1),
    ("insert into r select a.id, a.x = null from curr_concept_s a", 0),
    ("insert into r select a.id, a.x = null and a.y from curr_concept_s a where a.z = null", 1),
    ("select a.id from curr_concept_s a where a.id in (select b.id, b.x = null from u b)", 0),
    ("update t set flag = a and b, other = null", 0),
    ("update t set flag = a or b, other = null", 0),
    ("update t set flag = not b, other = null", 0),
    ("update t set flag = a and b, other = 1 where c = null", 1),
    ("select a.id from curr_concept_s a where a.moduleid <=> null", 0),
    ("select a.id from curr_concept_s a where a.x = nullif(a.y, 0)", 0),
    ("select a.id from curr_concept_s a where a.x = null_col", 0),
    ("update t set a.col = null where x = 1", 0),
    ("update t set a = null, b = NULL", 0),
    ("set @v = NULL;", 0),
    ("SET x = NULL;", 0),
    ("insert into t values (1) on duplicate key update c = null", 0),
    ("update t set a = case when x = 1 then 2 else 3 end, b = null", 0),
    ("update t set a = if(x = 1, 1, 2), b = null", 0),
    ("update t set a = (select max(id) from u where u.y = 1), b = null", 0),
    ("update t set a = coalesce(x, 1), b = null where c = 1", 0),

    # Comments and literals are not code.
    ("select a.id from curr_concept_s a where a.details = 'x = null'", 0),
    ("select a.id from curr_concept_s a where a.details = \"y <> NULL\"", 0),
    ("select 1 -- where a = null\nfrom curr_concept_s", 0),
    ("select 1 # where a = null\nfrom curr_concept_s", 0),
    ("select 1 from t where a--1 = 0 and x = null", 1),
    ("select 1 from t where a = 1 --\nand x = null", 1),
    ("select 1 /* not exists (select 1) */ from curr_concept_s", 0),
    ("select a.id from curr_concept_s a where a.details = 'it''s -- not a comment' and a.x = null", 1),
]

CASE = [
    ("select * from curr_Concept_s", 1),
    ("select * from prev_Concept_s", 1),
    ("select * from curr_simpleRefset_s", 1),
    ("select * from <PROSPECTIVE>.Description_s", 1),
    ("select * from curr_stated_Relationship_f", 1),
    ("select * from CURR_concept_s", 1),
    ("select * from curr_concept_S", 1),
    ("select * from curr_concept_s join prev_simplerefset_s", 0),
    ("select * from <PROSPECTIVE>.relationship_concrete_values_d", 0),
    ("select * from curr_SomeOtherTable_s", 0),  # not an RVF table
    ("set @q = concat('select id from curr_Concept_s where id = ', x);", 1),
    ("set @q = concat('select id from ', db, '.curr_concept_s');", 0),
    ("select 1 -- from curr_Concept_s\nfrom curr_concept_s", 0),
]


BRANCH_WORDING = [
    ("select a.id from curr_concept_s a where case when a.x = null then 1 else 0 end = 1", True),
    ("select a.id from curr_concept_s a where case when a.x = null then 1 end = 1", False),
    ("select a.id from curr_concept_s a where case when not f(a.x) and f(a.x) then 1 when a.y = 1 then 1 end = 1", True),
    ("select a.id from curr_concept_s a where a.x = null", False),
]


def exit_status_cases():
    """(name, exit status from main(), exit status it must be)."""
    out = []
    with tempfile.TemporaryDirectory() as d:
        d = pathlib.Path(d)
        (d / 'empty').mkdir()
        (d / 'clean').mkdir()
        (d / 'clean' / 'a.sql').write_text('select a.id from curr_concept_s a where a.x is null;')
        (d / 'dead').mkdir()
        (d / 'dead' / 'a.sql').write_text('select a.id from curr_concept_s a where a.x = null;')
        (d / 'no-tables.sql').write_text('-- nothing here')
        cases = [
            ('clean directory', [str(d / 'clean')], 0),
            ('a finding', [str(d / 'dead')], 1),
            ('missing directory', [str(d / 'missing')], 2),
            ('missing .sql file', [str(d / 'missing.sql')], 2),
            ('directory with no .sql files', [str(d / 'empty')], 2),
            ('missing directory beside a clean one', [str(d / 'clean'), str(d / 'missing')], 2),
            ('DDL with no tables', ['--ddl', str(d / 'no-tables.sql'), str(d / 'clean')], 2),
            ('missing DDL', ['--ddl', str(d / 'missing.sql'), str(d / 'clean')], 2),
        ]
        for name, argv, want in cases:
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                got = lint.main(argv)
            out.append((name, got, want))
    return out


ANNOTATION = [
    ('100% of\nlines', '100%25 of%0Alines'),
]


def main():
    failed = 0
    exits = exit_status_cases()
    for name, got, want in exits:
        if got != want:
            failed += 1
            print(f"FAIL exit status: want {want}, got {got}: {name}")
    for text, want in ANNOTATION:
        if lint.github_data(text) != want:
            failed += 1
            print(f"FAIL annotation: want {want!r}, got {lint.github_data(text)!r}")
    if lint.github_property('a,b:c') != 'a%2Cb%3Ac':
        failed += 1
        print(f"FAIL annotation property: got {lint.github_property('a,b:c')!r}")
    for sql, want in BRANCH_WORDING:
        got = ['CASE branch' in reason for _, reason in lint.findings(sql)]
        if got != [want]:
            failed += 1
            print(f"FAIL branch wording: want [{want}], got {got}: {sql!r}")
    for sql, want in FINDINGS:
        got = lint.findings(sql)
        if len(got) != want:
            failed += 1
            print(f"FAIL findings: want {want}, got {len(got)} {got}: {sql!r}")
    for sql, want in CASE:
        got = lint.case_mismatches(lint.strip_comments(sql, literals=False), lint.RF2_TABLE_STEMS)
        if len(got) != want:
            failed += 1
            print(f"FAIL case: want {want}, got {len(got)} {got}: {sql!r}")
    total = len(FINDINGS) + len(CASE) + len(exits) + len(ANNOTATION) + 1 + len(BRANCH_WORDING)
    print(f"{total - failed}/{total} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
