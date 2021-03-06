
/******************************************************************************** 
	file-centric-snapshot-stated-relationship-valid-destinationid

	Assertion:
	All destination ids found in the Stated Relationship snapshot file exist in the Concept snapshot file

********************************************************************************/
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Stated Relationship: id=',a.id, ' contains a destination id that does not exist in the Concept snapshot file.'),
		a.id,
		'curr_stated_relationship_s'
	from curr_stated_relationship_s a
	left join curr_concept_s b on a.destinationid = b.id
	where b.id is null;