/********************************************************************************
	release-type-snapshot-owl-expression-successive-states

	Assertion:
	All OWL Expressions inactivated in current release must have been active in the previous release

********************************************************************************/

insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('OWL Expression Refset: id=',a.id, '  is inactive but no active state found in previous release.'),
		a.id,
		'curr_owlexpressionrefset_s'
	from curr_owlexpressionrefset_s a
	left join prev_owlexpressionrefset_s b
	on a.id = b.id
	where
	a.active = 0
	and b.id is null
	AND NOT EXISTS (
		SELECT 1 FROM curr_owlexpressionrefset_f c
		WHERE a.id = c.id
		AND a.moduleid = c.moduleid
		AND c.active = 1);
	commit;
	