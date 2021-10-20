
/******************************************************************************** 
	file-centric-snapshot-language-unique-pt

	Assertion:
	Every active concept has one and only one active preferred term.

********************************************************************************/
/* 	testing for multiple perferred terms */
/* 	temp table: active sysonyms of active concepts edited in the current release cycle */ 	
	drop table if exists description_edited_tmp;
	create table if not exists description_edited_tmp 
	as select c.id, c.conceptid, c.active
	from res_concepts_edited a
	join curr_concept_s b 
		on a.conceptid = b.id
	join curr_description_s c
		on b.id = c.conceptid
		and b.active = c.active
	where b.active = 1;		
	
	alter table description_edited_tmp add index idx_desc_tmp_id(id);
	alter table description_edited_tmp add index idx_desc_tmp_cid(conceptid);
	alter table description_edited_tmp add index idx_desc_tmp_active(active);
	

	/*  detect duplicate language refset entries - ignoring the id and active flag - where both appear in the delta. */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select  	
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Concept: id=',a.conceptid, ' has duplicate language refsets for description id=',a.id, ' in Language refset delta'),
		a.conceptid,
		'curr_concept_s'
	from description_edited_tmp a
	join curr_langrefset_d b on a.id = b.referencedcomponentid	
	group by a.conceptid, b.refsetid, b.referencedcomponentid
	having count(b.referencedcomponentid) >1;

	drop table if exists description_edited_tmp;