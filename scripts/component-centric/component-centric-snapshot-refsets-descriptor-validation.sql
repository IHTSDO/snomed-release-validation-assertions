/*
 *Any refset with a refsetDescriptor record, that is a subset of another refset with a refsetDescriptor record, must have a refsetDescriptor that is either the same, or a specialisation of the parent's refset
 */

/* create table if not exists of all concepts containing an active stated is_a relationship */
drop table if exists v_act_parent_concepts;
create table if not exists v_act_parent_concepts as
select distinct a.referencedcomponentid as concept_id, b.destinationId as parent_id
	from curr_refsetdescriptor_s a left join curr_relationship_s b on a.referencedcomponentid = b.sourceid
	where a.active = 1
	and a.refsetid = '900000000000456007' -- Reference set descriptor
	and b.active = 1
	and b.typeid = 116680003;

/* create table if not exists of all Attribute Description and Attribute Type concepts */
drop table if exists v_attributedescription_and_attributetype_concept_ids;
create table if not exists v_attributedescription_and_attributetype_concept_ids as
select attributedescription as concept_id
	from curr_refsetdescriptor_s
	where active = '1'
	and refsetid = '900000000000456007' 	
UNION
select attributetype as concept_id
	from curr_refsetdescriptor_s
	where active = '1'
	and refsetid = '900000000000456007';

/* call store procedure to get all ancestor for the given concepts in table v_attributedescription_and_attributetype_concept_ids, and insert into table 'ancestors' */
call findAncestors();

/* create table if not exists of all valid records */
drop table if exists v_valid_ids;
create table if not exists v_valid_ids as
select a.id FROM curr_refsetdescriptor_s a
  	left join v_act_parent_concepts b on a.referencedcomponentid = b.concept_id
	  left join curr_refsetdescriptor_s c on c.referencedcomponentid = b.parent_id
    left join ancestors d on a.attributedescription = d.concept_id
    left join ancestors e on a.attributetype = e.concept_id
  where b.parent_id is null
  or c.referencedcomponentid is null  
  or (a.active = 1
    and a.refsetid = '900000000000456007'
    and c.active = 1
    and c.refsetid = '900000000000456007'
    and (a.attributedescription = c.attributedescription or (d.concept_id is not null and d.parents like CONCAT('%',c.attributedescription,'%')))
    and (a.attributetype = c.attributetype or (e.concept_id is not null and e.parents like CONCAT('%',c.attributetype,'%')))
    and a.attributeorder = c.attributeorder);

/* insert into qa table */
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
select <RUNID>, '<ASSERTIONUUID>', a.referencedcomponentid,
concat('The refsetDescriptor id=', a.referencedcomponentid ,' has the Attribute Description and Attribute Type which are not descendant or self of those in the parent refsetDescriptor id=', c.parent_id,' in the same position') ,
a.id,
'curr_refsetdescriptor_s'
from curr_refsetdescriptor_s a
left join v_valid_ids b on a.id = b.id
left join v_act_parent_concepts c on a.referencedcomponentid = c.concept_id
where a.active = 1
and a.refsetid = '900000000000456007'
and b.id is null;

drop table if exists ancestors;
drop table if exists v_attributedescription_and_attributetype_concept_ids;
drop table if exists v_valid_ids;
drop table if exists v_act_parent_concepts;