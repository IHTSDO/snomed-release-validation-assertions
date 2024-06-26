
/******************************************************************************** 
	release-type-snapshot-attribute-value-successive-states

	Assertion:	
	New inactive states follow active states in the ATTRIBUTEVALUE snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('AttributeRefsetId=',a.id, ' should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_attributevaluerefset_s'
	from curr_attributevaluerefset_s a , prev_attributevaluerefset_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.active = b.active;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('AttributeRefsetId=',a.id, ' is inactive but no active state found in the previous snapshot.'),
		a.id,
		'curr_attributevaluerefset_s'
	from curr_attributevaluerefset_s a left join prev_attributevaluerefset_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null
	AND NOT EXISTS (
		SELECT 1 FROM curr_attributevaluerefset_f c
		WHERE a.id = c.id
		AND a.moduleid = c.moduleid
		AND c.active = 1)
	AND NOT EXISTS (
		SELECT 1 FROM dependency_attributevaluerefset_f c
		WHERE a.id = c.id
		AND c.active = 1);
