/*  
 * There must be actual changes made to previously published expression association refset components in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ExpressionAssociation: id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
		a.id,
		'curr_expressionassociationrefset_d'
	from curr_expressionassociationrefset_d a
	left join prev_expressionassociationrefset_s b
	on a.id = b.id
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.refsetid = b.refsetid
	and a.referencedcomponentid = b.referencedcomponentid
	and a.mapTarget = b.mapTarget
	and a.expression = b.expression
	and a.definitionStatusId = b.definitionStatusId
	and a.correlationId = b.correlationId
	and a.contentOriginId = b.contentOriginId
	where b.id is not null
	and not exists (select 1 from curr_expressionassociationrefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and (a.active != c.active 
																		or a.moduleid != c.moduleid 
																		or a.refsetid != c.refsetid 
																		or a.referencedcomponentid != c.referencedcomponentid
																		or a.mapTarget != c.mapTarget
																		or a.expression != c.expression
																		or a.definitionStatusId != c.definitionStatusId
																		or a.correlationId != c.correlationId
																		or a.contentOriginId != c.contentOriginId));
	