/*  
 * There must be actual changes made to previously published mapcorrelationOriginRefset components in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('mapcorrelationOriginRefset: id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
	a.id,
	'curr_mapcorrelationoriginrefset_d'
	from curr_mapcorrelationoriginrefset_d a
	left join prev_mapcorrelationoriginrefset_s b
		on a.id = b.id
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.refsetid = b.refsetid
		and a.referencedcomponentid = b.referencedcomponentid
		and a.mapTarget = b.mapTarget
		and a.attributeId = b.attributeId
		and a.correlationId = b.correlationId
		and a.contentOriginId = b.contentOriginId
	where b.id is not null
	and not exists (select 1 from curr_mapcorrelationoriginrefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and (a.active != c.active 
																		or a.moduleid != c.moduleid 
																		or a.refsetid != c.refsetid 
																		or a.referencedcomponentid != c.referencedcomponentid
																		or a.mapTarget != c.mapTarget
																		or a.attributeId != c.attributeId
																		or a.correlationId != c.correlationId
																		or a.contentOriginId != c.contentOriginId));
