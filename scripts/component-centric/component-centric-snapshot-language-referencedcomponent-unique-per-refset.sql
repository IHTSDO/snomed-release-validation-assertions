/******************************************************************************** 
	component-centric-snapshot-language-referencedcomponent-unique-per-refset

	Assertion: There is only one member id per description per dialect in the language refset snapshot file.
********************************************************************************/
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name, skip_module_check)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		b.conceptid,
		concat('Description: id=',b.id, ': has multiple language refset members for a given dialect.'),
		b.id,
        'curr_description_s',
        if(b.moduleid != duplicates.moduleid, 1, 0)
	from 
	(select distinct a.refsetid, a.referencedcomponentid, a.moduleid
	from curr_langrefset_d a left join curr_langrefset_s b on a.refsetid =b.refsetid and a.referencedcomponentid=b.referencedcomponentid 
	where a.id != b.id and a.active = '1' and b.active = '1'
		and cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_langrefset_d z where z.id = a.id)) as duplicates,
	curr_description_s b 
	where duplicates.referencedcomponentid =b.id;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name, skip_module_check)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		b.conceptid,
		concat('Text definition: id=',b.id, ': has multiple language refset members for a given dialect.'),
		b.id,
        'curr_textdefinition_s',
        if(b.moduleid != duplicates.moduleid, 1, 0)
	from 
	(select distinct a.refsetid, a.referencedcomponentid, a.moduleid
	from curr_langrefset_d a left join curr_langrefset_s b on a.refsetid =b.refsetid and a.referencedcomponentid=b.referencedcomponentid 
	where a.id != b.id and a.active = '1' and b.active = '1'
		and cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_langrefset_d z where z.id = a.id)) as duplicates,
	curr_textdefinition_s b 
	where duplicates.referencedcomponentid =b.id;
	