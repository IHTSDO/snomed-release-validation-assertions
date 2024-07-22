/*  
 * There must be actual changes made to previously published extended map refset components in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ExtendedMap: id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
		a.id,
		'curr_extendedmaprefset_d'
	from curr_extendedmaprefset_d a
	left join prev_extendedmaprefset_s b
	on a.id = b.id
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
	and a.mapCategoryId = b.mapCategoryId
	where b.id is not null
	and not exists (select 1 from curr_extendedmaprefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and (a.active != c.active 
																		or a.moduleid != c.moduleid 
																		or a.refsetid != c.refsetid 
																		or a.referencedcomponentid != c.referencedcomponentid
																		or a.mapGroup != c.mapGroup
																		or a.mapPriority != c.mapPriority
																		or a.mapRule != c.mapRule
																		or a.mapAdvice != c.mapAdvice
																		or a.mapTarget != c.mapTarget
																		or a.correlationId != c.correlationId
																		or a.mapCategoryId != c.mapCategoryId));