
/*  
 * There must be actual changes made to previously published descriptions in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.conceptid,
	concat('Description: id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
	a.id,
	'curr_description_d'
	from curr_description_d a
	left join prev_description_s b
	on a.id = b.id
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.conceptid = b.conceptid
	and a.languagecode = b.languagecode
	and a.typeid = b.typeid
	and a.term = b.term
	and a.casesignificanceid = b.casesignificanceid
	where b.id is not null;
