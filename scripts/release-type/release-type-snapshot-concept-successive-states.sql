
/******************************************************************************** 
	release-type-snapshot-concept-successive-states

	Assertion:	
	New inactive states follow active states in the CONCEPT snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('CONCEPT: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_concept_s'
	from curr_concept_s a inner join  prev_concept_s b
	on a.id = b.id
	where a.active = 0
	and a.active = b.active
	and a.effectivetime != b.effectivetime
	and not exists (select 1 from curr_concept_d c where a.id = c.id 
														and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
														and c.active = 1);

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('CONCEPT: id=',a.id, ': is inactive but no active state found in the previous release.'),
		a.id,
		'curr_concept_s'
	from curr_concept_s a left join prev_concept_s b
	on a.id = b.id
	where a.active=0 and b.id is null
	and not exists (select 1 from curr_concept_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime));	
	commit;