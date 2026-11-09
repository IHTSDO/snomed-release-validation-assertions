#!/usr/bin/env python3
"""Do the checks in assertion_lint.py find what they should, and only that?

Each case is a small SQL fragment and the number of findings it must produce.
The false-positive cases matter as much as the true ones: a linter that reports
valid SQL gets switched off.

Run: python3 .github/scripts/assertion_lint_selftest.py
"""
import pathlib
import sys

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

    # Comparisons to NULL.
    ("select a.id from curr_concept_s a where a.moduleid = null", 1),
    ("select a.id from curr_concept_s a where a.moduleid = (NULL)", 1),
    ("select a.id from curr_concept_s a where a.active = 1 and a.moduleid <> null", 1),
    ("select 1 from t where not exists (select 1 from u where u.x = null))", 1),
    ("select 1 from t where t.id in (select id from u where u.x = null))", 1),
    ("update t set a.col = null where a.x = null", 1),
    ("if x = null then set y = 1; end if;", 1),
    ("if y = 1 then set z = 1; elseif x = null then set z = 2; end if;", 1),
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


def main():
    failed = 0
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
    total = len(FINDINGS) + len(CASE)
    print(f"{total - failed}/{total} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
