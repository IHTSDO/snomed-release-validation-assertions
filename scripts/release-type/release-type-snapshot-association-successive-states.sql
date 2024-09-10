
/******************************************************************************** 
	release-type-snapshot-association-successive-states

	Assertion:	
	New inactive states follow active states in the ASSOCIATION REFSET snapshot file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ASSOC RS: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a inner join prev_associationrefset_s b
	on a.id = b.id
	where a.active = 0
	and a.active = b.active
	and a.effectivetime != b.effectivetime
	and not exists (select 1 from curr_associationrefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and c.active = 1);
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('ASSOC RS: id=',d.id, ' is inactive but no active state found in the previous release.'),
		d.id,
		'curr_associationrefset_s'
	from (select a.id, a.referencedcomponentid from curr_associationrefset_s a left join prev_associationrefset_s b
	on a.id = b.id
	where a.active=0 and b.id is null
	and not exists (select 1 from curr_associationrefset_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d
	left join dependency_associationrefset_s e on d.id = e.id
	where e.id is null;
	commit;