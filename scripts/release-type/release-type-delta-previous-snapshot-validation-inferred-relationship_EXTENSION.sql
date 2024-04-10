/*  
 * There must be actual changes made to previously published inferred relationships in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.sourceid,
		concat('Inferred relationship: id=',a.id, ' is in the detla file, but no actual changes made since the previous release.'),
		a.id,
		'curr_relationship_d'
	from curr_relationship_d a
	left join prev_relationship_s b
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
	    AND NOT EXISTS (
        SELECT 1 FROM curr_relationship_f c
        WHERE a.id = c.id
		AND a.moduleid = c.moduleid
        AND c.active != a.active AND cast(a.effectivetime as datetime) > cast(c.effectivetime as datetime) 
        AND cast(c.effectivetime as datetime) > cast(b.effectivetime as datetime))
		AND NOT EXISTS (
        SELECT 1 FROM dependency_relationship_f d
        WHERE a.id = d.id
        AND d.active != a.active AND cast(a.effectivetime as datetime) > cast(d.effectivetime as datetime) 
        AND cast(d.effectivetime as datetime) > cast(b.effectivetime as datetime));

