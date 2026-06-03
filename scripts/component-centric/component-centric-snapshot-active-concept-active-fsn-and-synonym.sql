
/******************************************************************************** 
	component-centric-snapshot-active-concept-active-fsn-and-synonym

	Assertion:
	Every active concept has an active FSN and an active synonym.

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		c.id,
		concat('CONCEPT: id=', c.id, ': Active concept does not have an active ',
			if(r.typeid = '900000000000003001', 'FSN', 'synonym'), '.'),
		c.id,
		'curr_concept_s'
	from curr_concept_s c
	inner join (
		select '900000000000003001' as typeid
		union all
		select '900000000000013009'
	) r on not exists (
		select 1 from curr_description_s d
		where d.conceptid = c.id
		and d.active = '1'
		and d.typeid = r.typeid
	)
	where c.active = '1';
