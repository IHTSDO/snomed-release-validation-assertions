
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
		concat('ASSOC RS: Targetcomponentid=',a.targetcomponentid, ':Invalid TargetComponentId. RefsetId=', a.refsetid),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a
	left join curr_concept_s b
		on a.targetcomponentid = b.id
	where b.id is null
		and a.refsetid in 
			(900000000000523009, /* POSSIBLY EQUIVALENT TO */
			900000000000528000, /* WAS A */
			900000000000530003, /* ALTERNATIVE */
			900000000000531004) /* REFERS TO */;
	commit;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: Targetcomponentid=',a.targetcomponentid, ':Invalid TargetComponentId. RefsetId=', a.refsetid),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a
	left join curr_concept_s b
		on a.targetcomponentid = b.id
	left join curr_description_s c
        on a.targetcomponentid = c.id
	left join curr_relationship_s d
		on a.targetcomponentid = d.id
	where b.id is null and c.id is null and d.id is null
		and a.refsetid not in 
			(900000000000523009, /* POSSIBLY EQUIVALENT TO */
			900000000000528000, /* WAS A */
			900000000000530003, /* ALTERNATIVE */
			900000000000531004) /* REFERS TO */;
	commit;