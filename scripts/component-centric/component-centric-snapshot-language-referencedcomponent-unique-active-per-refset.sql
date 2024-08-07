/******************************************************************************** 
	component-centric-snapshot-language-referencedcomponent-unique-per-refset-active

	Assertion: There is only one active member per description per dialect in the language refset snapshot file.
********************************************************************************/
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		c.conceptid,
		concat('Description: id=',c.id, ': has multiple active language refset members for a given dialect.'),
		c.id,
        'curr_description_s'
	from 
	(select distinct a.refsetid, a.referencedcomponentid from curr_langrefset_d a left join curr_langrefset_s b on a.refsetid=b.refsetid and a.referencedcomponentid=b.referencedcomponentid 
	where a.id != b.id 
		and a.active=1 
		and b.active=1
		and cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_langrefset_d z where z.id = a.id)) as temp, 
	curr_description_s c 
	where temp.referencedcomponentid =c.id;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		c.conceptid,
		concat('Text definition: id=',c.id, ': has multiple active language refset members for a given dialect.'),
		c.id,
        'curr_textdefinition_s'
	from 
	(select distinct a.refsetid, a.referencedcomponentid 
	from curr_langrefset_d a left join curr_langrefset_s b on a.refsetid =b.refsetid and a.referencedcomponentid=b.referencedcomponentid 
	where a.id != b.id 
		and a.active=1 
		and b.active=1
		and cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_langrefset_d z where z.id = a.id)) as temp, 
	curr_textdefinition_s c 
	where temp.referencedcomponentid =c.id;
	