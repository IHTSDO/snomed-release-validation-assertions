/********************************************************************************
component-centric-snapshot-annotation-refset-ids-must-be-valid-and-active.sql

	Assertion:
	Active Component Annotation refset members use a valid referencedComponentId
	and typeId.

	referencedComponentId must be an existing concept, active or inactive.
	typeId must be an active descendant of 1295447006 |Annotation attribute|.

	Membership of moduleId in the module dependency list, and of refsetId in the
	refset descriptor, is already asserted by the file-centric module and refset
	id procedures once these tables are loaded. refsetId being an active concept
	is asserted with the other refset files.

********************************************************************************/

	drop table if exists tmp_annotation_attribute_type;
	create table tmp_annotation_attribute_type (
		id bigint(20) not null,
		primary key (id)
	) engine=myisam default charset=utf8;

	insert ignore into tmp_annotation_attribute_type (id)
	with recursive annotation_type (id) as (
		select cast(1295447006 as signed)
		union all
		select r.sourceid
		from curr_relationship_s r
		inner join annotation_type t on r.destinationid = t.id
		where r.active = '1'
		and r.typeid = 116680003
	)
	select id from annotation_type;

	delete from tmp_annotation_attribute_type where id = 1295447006;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Referenced component id:', a.referencedcomponentid, ' for refset id:', a.refsetid, ' in component annotation refset member must be an existing concept.'),
		a.id,
		'curr_componentannotationstringvaluerefset_s'
	from curr_componentannotationstringvaluerefset_s a
	left join curr_concept_s c on a.referencedcomponentid = c.id
	where a.active = '1'
	and c.id is null;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.typeid,
		concat('Annotation type id:', a.typeid, ' for refset id:', a.refsetid, ' in component annotation refset member must be an existing and active concept.'),
		a.id,
		'curr_componentannotationstringvaluerefset_s'
	from curr_componentannotationstringvaluerefset_s a
	left join curr_concept_s c on a.typeid = c.id
	where a.active = '1'
	and (c.id is null or c.active = '0');

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.typeid,
		concat('Annotation type id:', a.typeid, ' for refset id:', a.refsetid, ' in component annotation refset member must be an active descendant of 1295447006 |Annotation attribute|.'),
		a.id,
		'curr_componentannotationstringvaluerefset_s'
	from curr_componentannotationstringvaluerefset_s a
	inner join curr_concept_s c on a.typeid = c.id and c.active = '1'
	left join tmp_annotation_attribute_type t on a.typeid = t.id
	where a.active = '1'
	and t.id is null;

	drop table if exists tmp_annotation_attribute_type;
