
/******************************************************************************** 
	file-centric-snapshot-definition-trim

	Assertion:
	No active definitions contain leading or trailing spaces.

********************************************************************************/	
/* 	inserting exceptions in the result table */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('TEXTDEF: id=',a.id, ':Active Terms with leading or trailing spaces.'),
		a.id,
		'curr_textdefinition_s'
	from curr_textdefinition_s a 
	where a.active = 1
	and ( a.term not like LTRIM(term) or a.term not like RTRIM(term));
	commit;
	