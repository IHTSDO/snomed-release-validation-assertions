
/*  
	The current data in the ExpressionAssociationRefset snapshot file are the same as the data in
	the current delta file. 
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('ExpressionAssociationRefset: id=',a.id, ' is in delta file but not in snapshot file.'),
	a.id,
	'curr_expressionassociationrefset_d'
	from curr_expressionassociationrefset_d a
	left join curr_expressionassociationrefset_s b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.refsetid = b.refsetid
		and a.referencedcomponentid = b.referencedcomponentid
		and a.mapTarget = b.mapTarget
		and a.expression = b.expression
		and a.definitionStatusId = b.definitionStatusId
		and a.correlationId = b.correlationId
		and a.contentOriginId = b.contentOriginId
	where 
	(b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
	or b.refsetid is null
	or b.referencedcomponentid is null
	or b.mapTarget is null
	or b.expression is null
	or b.definitionStatusId is null
	or b.correlationId is null
	or b.contentOriginId is null)
	and cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_expressionassociationrefset_d z where z.id = a.id)
commit;
