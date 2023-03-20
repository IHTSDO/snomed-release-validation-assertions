
/******************************************************************************** 
	release-type-snapshot-owl-expression-refset-successive-states

	Assertion:	
	New inactive states follow active states in the Owl Expression snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Owl Expression: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_owlexpressionrefset_s'
	from curr_owlexpressionrefset_s a inner join  prev_owlexpressionrefset_s b
	on a.id = b.id
	where a.active = 0
	and a.active = b.active
	and a.effectivetime != b.effectivetime;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Owl Expression: id=',a.id, ': is inactive but no active state found in the previous release.'),
		a.id,
		'curr_owlexpressionrefset_s'
	from curr_owlexpressionrefset_s a left join prev_owlexpressionrefset_s b
	on a.id = b.id
	where a.active=0 and b.id is null
	AND NOT EXISTS (
	SELECT 1 FROM curr_owlexpressionrefset_f c
	WHERE a.id = c.id
	AND a.moduleid = c.moduleid
	AND c.active = 1);
	commit;