/******************************************************************************** 
	release-type-SNAPSHOT-delta-validation-Description

	Assertion:
	The current data in the Definition snapshot file are the same as the data in 
	the current delta file. 
********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('DESCRIPTION: id=',a.id, ' is in delta file but not in snapshot file.'),
		a.id,
		'curr_description_d'
	from curr_description_d a
	left join curr_description_s b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.conceptid = b.conceptid
		and a.languagecode = b.languagecode
		and a.typeid = b.typeid
		and a.term = b.term
		and a.casesignificanceid = b.casesignificanceid
	where (b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.conceptid is null
	or b.languagecode is null
	or b.typeid is null
	or b.term is null
	or b.casesignificanceid is null)
	and not exists (select 1 from curr_description_d c where a.id = c.id and cast(c.effectivetime as datetime) > cast(a.effectivetime as datetime));
	
	 
	 
	 