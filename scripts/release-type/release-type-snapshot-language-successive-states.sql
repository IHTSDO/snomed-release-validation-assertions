
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
	and a.active = b.active;
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
	where
	a.active = 0
	and b.id is null;
	commit;

