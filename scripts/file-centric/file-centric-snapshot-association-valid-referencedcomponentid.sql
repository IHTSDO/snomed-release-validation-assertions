
/******************************************************************************** 
	file-centric-snapshot-association-valid-referencedcomponentid

	Assertion:
	Referencedcomponentid refers to valid components in the ASSOCIATION REFSET snapshot file.

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Member id=', a.id, ', Refset id=', a.refsetid, ', Referenced Component id=', a.referencedcomponentid, ' is invalid in ASSOCIATION refset snapshot.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a
	left join curr_concept_s b
	on a.referencedcomponentid = b.id
	where b.id is null 
	and not exists ( select id from curr_description_s where id = a.referencedcomponentid )
	and not exists ( select id from curr_textdefinition_s where id = a.referencedcomponentid );
	commit;
	