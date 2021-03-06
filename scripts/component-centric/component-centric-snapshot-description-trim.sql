
/******************************************************************************** 
	file-centric-snapshot-description-trim

	Assertion:
	No active Terms contain leading or trailing spaces.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Description: id=',a.id, ' has active term with leading or trailing spaces.'),
		a.id,
        'curr_description_s'
	from curr_description_s a 
	where a.active = 1
	and ( a.term not like LTRIM(term) or a.term not like RTRIM(term));
	commit;
	
	