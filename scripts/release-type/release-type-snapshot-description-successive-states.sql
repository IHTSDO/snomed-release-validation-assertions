
/******************************************************************************** 
	release-type-snapshot-description-successive-states

	Assertion:	
	New inactive states must follow active states in the DESCRIPTION snapshot.
	Note: Unless there are changes in other fields since last release due to data correction in current release 

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('DESCRIPTION: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_description_s'
	from curr_description_s a , prev_description_s b	
	where a.effectivetime != b.effectivetime
	and a.active = '0'
	and b.active = '0'
	and a.id = b.id
	and a.conceptid = b.conceptid
	and a.moduleid = b.moduleid
	and a.term = b.term
	and a.typeid = b.typeid
	and a.languagecode = b.languagecode
	and a.casesignificanceid = b.casesignificanceid
	and not exists (select 1 from curr_description_d c where a.id = c.id 
															and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
															and c.active = 1);
	
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.conceptid,
		concat('DESCRIPTION: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_description_s'
	from (select a.id, a.conceptid from curr_description_s a left join prev_description_s b
	on a.id=b.id
	where a.active=0 and b.id is null
	and not exists (select 1 from curr_description_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d 
	left join dependency_description_s e on d.id = e.id
	where e.id is null;
	
	
	