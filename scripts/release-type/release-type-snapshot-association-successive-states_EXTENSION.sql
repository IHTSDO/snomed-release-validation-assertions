
/******************************************************************************** 
	release-type-snapshot-association-successive-states

	Assertion:	
	New inactive states follow active states in the ASSOCIATION REFSET snapshot file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a inner join prev_associationrefset_s b
	on a.id = b.id
	where a.active = 0
	and a.active = b.active
	and a.effectivetime != b.effectivetime;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: id=',a.id, ' is inactive but no active state found in the previous release.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a left join prev_associationrefset_s b
	on a.id = b.id
	where a.active=0 and b.id is null
	AND NOT EXISTS (
		SELECT 1 FROM curr_associationrefset_f c
		WHERE a.id = c.id
		AND a.moduleid = c.moduleid
		AND c.active = 1)
	AND NOT EXISTS (
		SELECT 1 FROM dependency_associationrefset_f c
		WHERE a.id = c.id
		AND c.active = 1);
	commit;