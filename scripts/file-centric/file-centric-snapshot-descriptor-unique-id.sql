/*
 * Assert Descriptor Refset id is unique in the snapshot file
 */
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
select
 	<RUNID>,
 	'<ASSERTIONUUID>',
 	a.referencedComponentId,
    concat('Descriptor Refset: id=',a.id, ' is duplicate in Snapshot file'),
    a.id,
    'curr_refsetdescriptor_s'
	 from curr_refsetdescriptor_s a
	group by a.id
	having count(*) > 1;