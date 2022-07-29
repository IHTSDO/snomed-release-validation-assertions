
/******************************************************************************** 
	file-centric-snapshot-description-immutable-fields-changed

	Assertion:
	The descriptions should not change the immutable fields either type id, language code or concept id since previous release

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Description:', a.id , ' has changes in the immutable fields either type id, language code or concept id since previous release.'),
		a.id,
		'curr_description_s'
	from curr_description_s a
	join prev_description_s b
 	on a.id=b.id
	where
	a.typeid != b.typeid
	or a.languagecode != b.languagecode
	or a.conceptid != b.conceptid;
