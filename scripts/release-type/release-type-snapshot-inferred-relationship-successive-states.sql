
/******************************************************************************** 
	release-type-snapshot-inferred-relationship-successive-states

	Assertion:
	All relationships inactivated in current release must have been active in the previous release

********************************************************************************/
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Relationship: id=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_relationship_s'
	from curr_relationship_s a
	inner join prev_relationship_s b on a.id = b.id 
	where a.active = '0' 
	and b.active = '0' 
	and a.effectivetime != b.effectivetime
	and a.moduleid = b.moduleid
	and a.sourceid = b.sourceid
	and a.relationshipgroup = b.relationshipgroup
	and a.destinationid = b.destinationid
	and a.typeid = b.typeid
	and a.characteristictypeid = b.characteristictypeid
	and a.modifierid = b.modifierid
	and not exists (select 1 from curr_relationship_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and c.active = 1);

	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.sourceid,
		concat('Relationship: id=',d.id, ' is inactive but no active state found in previous release.'),
		d.id,
		'curr_relationship_s'
	from (select a.id, a.sourceid from curr_relationship_s a
	left join prev_relationship_s b
	on a.id=b.id
	and a.sourceid=b.sourceid
	and a.destinationid=b.destinationid 
	and a.typeid=b.typeid
	where a.active=0
	and b.id is null
	and not exists (select 1 from curr_relationship_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d 
	left join dependency_relationship_s e on d.id = e.id
	where e.id is null;