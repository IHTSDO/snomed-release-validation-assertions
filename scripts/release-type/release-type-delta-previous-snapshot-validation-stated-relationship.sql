/*  
 * There must be actual changes made to previously published stated relatioships in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Stated relationship: id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
		a.id,
		'curr_stated_relationship_d'
	from curr_stated_relationship_d a
	left join prev_stated_relationship_s b
		on a.id = b.id
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.sourceid = b.sourceid
		and a.destinationid = b.destinationid
		and a.relationshipgroup = b.relationshipgroup
		and a.typeid = b.typeid
		and a.characteristictypeid = b.characteristictypeid
		and a.modifierid = b.modifierid	
	where b.id is not null
	and not exists (select 1 from curr_stated_relationship_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and (a.active != c.active 
																		or a.moduleid != c.moduleid 
																		or a.sourceid != c.sourceid
																		or a.destinationid != c.destinationid
																		or a.relationshipgroup != c.relationshipgroup
																		or a.typeid != c.typeid
																		or a.characteristictypeid != c.characteristictypeid
																		or a.modifierid != c.modifierid));
