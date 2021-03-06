
/******************************************************************************** 
	release-type-snapshot-relationship-concrete-values-successive-states

	Assertion:
	All relationship concrete values inactivated in current release must have been active in the previous release

********************************************************************************/
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Relationship Concrete Values: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_relationship_concrete_values_s'
	from curr_relationship_concrete_values_s a
	inner join prev_relationship_concrete_values_s b on a.id = b.id
	where a.active = '0' 
	and b.active = '0' 
	and a.effectivetime != b.effectivetime
	and a.moduleid = b.moduleid
	and a.sourceid = b.sourceid
	and a.relationshipgroup = b.relationshipgroup
	and a.value = b.value
	and a.typeid = b.typeid
	and a.characteristictypeid = b.characteristictypeid
	and a.modifierid = b.modifierid;
	
	
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Relationship Concrete Values: id=',a.id, ' is inactive in the current release but no active state found in the previous snapshot.'),
		a.id,
		'curr_relationship_concrete_values_s'
	from curr_relationship_concrete_values_s  a left join prev_relationship_concrete_values_s b
	on a.id=b.id
	and a.sourceid=b.sourceid
	and a.value=b.value
	and a.typeid=b.typeid
	where a.active=0 
	and b.id is null
	AND NOT EXISTS (
        SELECT 1 FROM curr_relationship_concrete_values_f c
        WHERE a.id = c.id
		AND a.moduleid = c.moduleid
        AND c.active = 1);
