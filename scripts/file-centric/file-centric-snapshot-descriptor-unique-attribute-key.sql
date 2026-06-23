
/******************************************************************************** 
	file-centric-snapshot-descriptor-unique-attribute-key

	Assertion:
	There must not be more than one active refset descriptor entry with the same
	referencedComponentId, attributeDescription, attributeOrder and attributeType.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		b.referencedcomponentid,
		concat('Refset descriptor: duplicate active entries for referencedComponentId=', b.referencedcomponentid, ', attributeDescription=', b.attributedescription, ', attributeOrder=', b.attributeorder, ', attributeType=', b.attributetype, ' (member ids=', b.duplicate_ids, ')'),
		b.id,
		'curr_refsetdescriptor_s'
	from (
		select referencedcomponentid, attributedescription, attributeorder, attributetype,
			group_concat(id order by id separator ', ') as duplicate_ids,
			min(id) as id
		from curr_refsetdescriptor_s
		where active = 1
		group by referencedcomponentid, attributedescription, attributeorder, attributetype
		having count(*) > 1
	) b;
