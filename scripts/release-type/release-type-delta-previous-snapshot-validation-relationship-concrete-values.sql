/*  
 * There must be actual changes made to previously published relationships concrete values in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Relationship Concrete Values: id=',a.id, ' is in the detla file, but no actual changes made since the previous release.'),
		a.id,
		'curr_relationship_concrete_values_d'
	from curr_relationship_concrete_values_d a
	left join prev_relationship_concrete_values_s b
		on a.id = b.id
		and a.active = b.active
		and a.moduleid = b.moduleid
		and a.sourceid = b.sourceid
		and a.value = b.value
		and a.relationshipgroup = b.relationshipgroup
		and a.typeid = b.typeid
		and a.characteristictypeid = b.characteristictypeid
		and a.modifierid = b.modifierid	
	where b.id is not null;

