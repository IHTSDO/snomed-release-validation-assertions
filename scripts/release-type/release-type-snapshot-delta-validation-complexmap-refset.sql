/*  
*	Content in the the current complex map delta file must be in the current full file
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedComponentId,
		concat('ComplexMap: id=',a.id, ' is in DELTA file, but not in SNAPSHOT file.'),
		a.id,
		'curr_complexmaprefset_d'
	from curr_complexmaprefset_d a
	left join curr_complexmaprefset_s b
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.refsetid = b.refsetid
	and a.referencedcomponentid = b.referencedcomponentid
	and a.mapGroup = b.mapGroup
	and a.mapPriority = b.mapPriority
	and a.mapRule = b.mapRule
	and a.mapAdvice = b.mapAdvice
	and a.mapTarget = b.mapTarget
	and a.correlationId = b.correlationId
	where (b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.refsetid is null
	or b.referencedcomponentid is null
	or b.mapGroup is null
	or b.mapPriority is null
	or b.mapRule is null
	or b.mapTarget is null
	or b.correlationId is null)
	and cast(a.effectivetime as datetime) =  (select max(cast(z.effectivetime as datetime)) from curr_complexmaprefset_d z where z.id = a.id);
	