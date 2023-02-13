
/********************************************************************************
	component-centric-snapshot-language-unique-textdefinition

	Assertion:
	Language refset members have the wrong module id in	the snapshot file.
	
********************************************************************************/


	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Language refset member: id=',a.id, ': Member has the wrong module.'),
		a.id,
        'curr_langrefset_s'
	from curr_langrefset_s a 
	left join curr_description_s b on a.referencedcomponentid = b.id
	left join dependency_langrefset_s c on a.id = c.id
	where a.active = '1'
		and b.active = '1'
		and c.id is null
		and a.moduleid not in (<MODULEIDS>);

    commit;
