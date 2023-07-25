
/******************************************************************************** 
	file-centric-snapshot-simple-map-refset-valid-referencedcomponentid

	Assertion:
	Referencedcomponentid refers to valid concepts in the SIMPLE MAP REFSET snapshot file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Member id=', a.id, ', Refset id=', a.refsetid, ', Referenced Component id=', a.referencedcomponentid, ' is invalid in SIMPLE MAP refset snapshot.'),
		a.id,
		'curr_simplemaprefset_s'
	from curr_simplemaprefset_s a
	left join curr_concept_s b
	on a.referencedcomponentid = b.id
	where a.active = 1 and (b.active = 0 or b.id is null);
