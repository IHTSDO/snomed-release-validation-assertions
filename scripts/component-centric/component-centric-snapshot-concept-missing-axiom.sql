
/********************************************************************************
	component-centric-snapshot-concept-missing-axiom

	Assertion:
	Active concepts have at least one active axiom in the same module as the concepts themselves.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('CONCEPT: id=',a.id, ': Active concept has no active axiom in the same module as the concept.'),
		a.id,
        'curr_concept_s'
	from curr_concept_s a
	where a.active = '1'
	and a.id != 138875005
	and NOT EXISTS (select 1 from curr_owlexpressionrefset_s where referencedcomponentid = a.id and moduleid = a.moduleid and active = '1');
