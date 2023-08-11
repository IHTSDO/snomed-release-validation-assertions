
/******************************************************************************** 
	file-centric-snapshot-association-valid-targetcomponentid

	Assertion:
	TargetComponentId refers to valid components in the ASSOCIATION REFSET snapshot file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: Targetcomponentid=',a.targetcomponentid, ':Invalid TargetComponentId.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a
	left join curr_concept_s b
		on a.targetcomponentid = b.id
    left join curr_description_s c
        on a.targetcomponentid = c.id
    left join curr_relationship_s d
        on a.targetcomponentid = d.id
	where b.id is null and c.id is null and d.id is null;
	commit;