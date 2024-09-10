/********************************************************************************
	release-type-snapshot-owl-expression-successive-states

	Assertion:
	All OWL Expressions inactivated in current release must have been active in the previous release

********************************************************************************/

insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('OWL Expression Refset: id=',d.id, '  is inactive but no active state found in previous release.'),
		d.id,
		'curr_owlexpressionrefset_s'
	from (select a.id, a.referencedcomponentid from curr_owlexpressionrefset_s a
	left join prev_owlexpressionrefset_s b
	on a.id = b.id
	where
	a.active = 0
	and b.id is null
	and not exists (select 1 from curr_owlexpressionrefset_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d 
	left join dependency_owlexpressionrefset_s e on d.id = e.id
	where e.id is null;
	commit;
	