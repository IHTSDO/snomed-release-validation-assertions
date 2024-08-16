
/******************************************************************************** 
	file-centric-snapshot-association-valid-targetcomponentid_AU_EDITION

	Assertion:
	TargetComponentId refers to valid components in the ASSOCIATION REFSET snapshot file.

********************************************************************************/

	create table if not exists v_concept_and_description_and_relationship_ids as
	select id from curr_concept_s  
	union all
	select id from curr_description_s
	union all
	select id from curr_relationship_s;

	alter table v_concept_and_description_and_relationship_ids add index idx_concept_and_description_and_relationship_id(id);

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: Targetcomponentid=',a.targetcomponentid, ':Invalid TargetComponentId. RefsetId=', a.refsetid, '.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a
	left join v_concept_and_description_and_relationship_ids b
	on a.targetcomponentid = b.id
	where b.id is null;
	commit;

	drop table if exists v_concept_and_description_and_relationship_ids;
	