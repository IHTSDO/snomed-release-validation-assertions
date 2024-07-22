
/******************************************************************************** 
	release-type-snapshot-language-successive-states

	Assertion:
	Members inactivated in current release were active in the previous release.

********************************************************************************/
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Language Refset: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_langrefset_s'
	from curr_langrefset_s a
	join prev_langrefset_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.acceptabilityid=b.acceptabilityid
	and a.active = b.active
	and not exists (select 1 from curr_langrefset_d c where a.id = c.id 
														and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
														and c.active = 1);
	commit;
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Language Refset: id=',a.id, '  is inactive but no active state found in previous release.'),
		a.id,
		'curr_langrefset_s'
	from curr_langrefset_s a
	left join prev_langrefset_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null
	and not exists (select 1 from curr_langrefset_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime));
	commit;

