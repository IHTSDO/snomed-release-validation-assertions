/*
 * Assert Description Type Refset id is unique in the snapshot file
 */
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
select
 	<RUNID>,
 	'<ASSERTIONUUID>',
 	a.referencedComponentId,
    concat('Description Type Refset: id=',a.id, ' is duplicate in Snapshot file'),
    a.id,
    'curr_descriptiontyperefset_s'
	 from curr_descriptiontyperefset_s a
	group by a.id
	having count(*) > 1;