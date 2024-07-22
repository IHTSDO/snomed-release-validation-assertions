
/******************************************************************************** 
	release-type-snapshot-delta-validation-simple-refset 

	Assertion: The current data in the Simple refset snapshot file are the same 
	as the data in the current delta file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Simple refset: id=',a.id, ' is in delta file, but not in snapshot file.'),
		a.id,
		'curr_simplerefset_d'
	from curr_simplerefset_d a
	left join curr_simplerefset_s b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.referencedcomponentid = b.referencedcomponentid
	where (b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.referencedcomponentid is null)
	and not exists (select 1 from curr_simplerefset_d c where a.id = c.id and cast(c.effectivetime as datetime) > cast(a.effectivetime as datetime));
	 
	 
	 