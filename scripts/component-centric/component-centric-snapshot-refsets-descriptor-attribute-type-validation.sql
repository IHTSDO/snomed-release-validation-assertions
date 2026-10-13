/*
 *Any refset with a refsetDescriptor record, that is a subset of another refset with a refsetDescriptor record, must have an Attribute Type in each column that is either the same as, or a specialisation of, the Attribute Type in the same column of the parent's refsetDescriptor
 */

/* create table if not exists of all concepts containing an active inferred is_a relationship */
drop table if exists v_rd_type_act_parent_concepts;
create table if not exists v_rd_type_act_parent_concepts as
select distinct a.referencedcomponentid as concept_id, b.destinationId as parent_id
	from curr_refsetdescriptor_s a left join curr_relationship_s b on a.referencedcomponentid = b.sourceid
	where a.active = 1
	and a.refsetid = '900000000000456007' -- Reference set descriptor
	and b.active = 1
	and b.typeid = 116680003;

/* create table if not exists of all Attribute Type concepts */
drop table if exists tmp_rd_type_attribute_concept_ids;
create table if not exists tmp_rd_type_attribute_concept_ids as
select distinct attributetype as concept_id
	from curr_refsetdescriptor_s
	where active = '1'
	and refsetid = '900000000000456007';

/* call store procedure to get all ancestors for the given concepts in table tmp_rd_type_attribute_concept_ids, and insert into table tmp_rd_type_ancestors */
/* tables passed by name to findAncestors use the tmp prefix because RVF renames temp tables in the script but not inside the procedure */
call findAncestors('tmp_rd_type_attribute_concept_ids', 'tmp_rd_type_ancestors');

/* create table if not exists of all valid records */
drop table if exists v_rd_type_valid_ids;
create table if not exists v_rd_type_valid_ids as
select a.id FROM curr_refsetdescriptor_s a
	left join v_rd_type_act_parent_concepts b on a.referencedcomponentid = b.concept_id
	left join curr_refsetdescriptor_s c on c.referencedcomponentid = b.parent_id
	left join tmp_rd_type_ancestors e on a.attributetype = e.concept_id
  where b.parent_id is null
  or c.referencedcomponentid is null
  or (a.active = 1
    and a.refsetid = '900000000000456007'
    and c.active = 1
    and c.refsetid = '900000000000456007'
    and a.attributeorder = c.attributeorder
    and (a.attributetype = c.attributetype or (e.concept_id is not null and concat(e.parents, ',') like concat('%,', c.attributetype, ',%'))));

/* insert into qa table */
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
select <RUNID>, '<ASSERTIONUUID>', d.referencedcomponentid,
case when p.id is null
	then concat('The refsetDescriptor id=', d.referencedcomponentid, ' has the Attribute Type id=', d.attributetype, ' at column index (attributeOrder) ', d.attributeorder, ', but the parent refsetDescriptor id=', d.parent_id, ' has no Attribute Type at column index ', d.attributeorder)
	else concat('The refsetDescriptor id=', d.referencedcomponentid, ' has the Attribute Type id=', d.attributetype, ' at column index (attributeOrder) ', d.attributeorder, ' which is not descendant or self of the Attribute Type id=', p.attributetype, ' at column index ', d.attributeorder, ' in the parent refsetDescriptor id=', d.parent_id)
end,
d.id,
'curr_refsetdescriptor_s'
from (select a.id, a.referencedcomponentid, a.attributetype, a.attributeorder, c.parent_id from curr_refsetdescriptor_s a
	left join v_rd_type_valid_ids b on a.id = b.id
	left join v_rd_type_act_parent_concepts c on a.referencedcomponentid = c.concept_id
	where a.active = 1
	and a.refsetid = '900000000000456007'
	and b.id is null) d
left join dependency_refsetdescriptor_s e on d.id = e.id
left join curr_refsetdescriptor_s p on p.referencedcomponentid = d.parent_id
	and p.attributeorder = d.attributeorder
	and p.active = 1
	and p.refsetid = '900000000000456007'
where e.id is null;

drop table if exists tmp_rd_type_ancestors;
drop table if exists tmp_rd_type_attribute_concept_ids;
drop table if exists v_rd_type_valid_ids;
drop table if exists v_rd_type_act_parent_concepts;
