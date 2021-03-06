
/******************************************************************************** 
	component-centric-snapshot-inferred-inactive-modifier
	
	Assertion:
	Inferred relationship modifier is always SOME.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		b.id,
		concat('RELATIONSHIP: id=',a.id, ': Inferred Relationship has a non -SOME- modifier.'),
		a.id,
        'curr_relationship_s'
	from curr_relationship_s a
	inner join curr_concept_s b on a.sourceid = b.id
	where a.modifierid != '900000000000451002';
	