
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
	and a.active = b.active
	and not exists (select 1 from curr_attributevaluerefset_d c where a.id = c.id 
																	and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																	and c.active = 1);

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
	and not exists (select 1 from curr_attributevaluerefset_f c where a.id = c.id and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime));
