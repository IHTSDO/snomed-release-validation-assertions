/********************************************************************************




	Assertion:
	The Concept snapshot file contains the data in the current delta file.

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('CONCEPT: id=',a.id, ' is in delta but not in snapshot file.'),
		a.id,
		'curr_concept_d'
	from curr_concept_d a
	left join curr_concept_s b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.definitionstatusid = b.definitionstatusid
	where (b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.definitionstatusid is null)
	and not exists (select 1 from curr_concept_d c where a.id = c.id and cast(c.effectivetime as datetime) > cast(a.effectivetime as datetime));