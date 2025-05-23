
/******************************************************************************** 
	release-type-snapshot-simple-map-successive-states

	Assertion:	
	New inactive states follow active states in the SIMPLE MAP REFSET snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('SimpleMap Refset: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_simplemaprefset_s'
	from curr_simplemaprefset_s a , prev_simplemaprefset_s b
	where a.active = 0
	and a.id = b.id
	and a.active = b.active
	and a.effectivetime != b.effectivetime
	and not exists (select 1 from curr_simplemaprefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and c.active = 1);

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('SimpleMap Refset: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_simplemaprefset_s'
	from (select a.id, a.referencedcomponentid from curr_simplemaprefset_s a left join prev_simplemaprefset_s b
	on a.id=b.id
	where a.active = '0'
	and b.id is null 
	and not exists (select 1 from curr_simplemaprefset_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d 
	left join dependency_simplemaprefset_s e on d.id = e.id
	where e.id is null;