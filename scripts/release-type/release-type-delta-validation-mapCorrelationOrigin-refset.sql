/*  
*	Changes from the current mapcorrelationoriginrefset delta file must be in the current full file
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ExpressionAssociation: id=',a.id, ' is in DELTA file, but not in FULL file.'),
		a.id,
		'curr_mapcorrelationoriginrefset_d'
	from curr_mapcorrelationoriginrefset_d a
	left join curr_mapcorrelationoriginrefset_f b
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.refsetid = b.refsetid
	and a.referencedcomponentid = b.referencedcomponentid
	and a.mapTarget = b.mapTarget
	and a.attributeId = b.attributeId
	and a.correlationId = b.correlationId
	and a.contentOriginId = b.contentOriginId
	where b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.refsetid is null
	or b.referencedcomponentid is null
	or b.mapTarget is null
	or b.attributeId is null
	or b.correlationId is null
	or b.contentOriginId is null;
	commit;