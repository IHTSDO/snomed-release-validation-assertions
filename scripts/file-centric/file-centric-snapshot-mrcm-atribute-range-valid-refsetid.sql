
/******************************************************************************** 
	file-centric-snapshot-mrcm-atribute-range-valid-refsetId

	Assertion:
	RefsetId value refers to valid concept identifier in MRCM ATTRIBUTE RANGE snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.refsetId,
		concat('MRCM ATTRIBUTE RANGE: id=',a.id,' : refsetId=',a.refsetId,' MRCM Attribute Range Refset contains a RefsetId that does not exist in the Concept snapshot.'),
		a.id,
		'curr_mrcmattributerangerefset_s'
	from curr_mrcmattributerangerefset_s a
	left join curr_concept_s b
	on a.refsetId = b.id
	where a.active = 1 and (b.active=0 or b.id is null);
