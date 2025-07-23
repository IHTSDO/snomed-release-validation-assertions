
/******************************************************************************** 
	component-centric-snapshot-definition-language-inactive-members

	Assertion:
	LangRefset members are active for inactive text definitions in the language refset snapshot file.

********************************************************************************/
	
	/* 
	
	*/
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('MEMBER: id=',b.id, ': Language refset member is active for an inactive text definition.'),
		b.id,
       'curr_langrefset_s'
	from curr_textdefinition_s a
	inner join curr_langrefset_s b 
		on a.id = b.referencedcomponentid
	where b.active = '1'
	and a.active ='0';

	