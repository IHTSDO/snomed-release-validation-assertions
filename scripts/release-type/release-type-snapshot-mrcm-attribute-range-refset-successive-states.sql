
/******************************************************************************** 
	release-type-snapshot-mrcm-attribute-range-refset-successive-states

	Assertion:	
	New inactive states follow active states in the MRCM ATTRIBUTE RANGE REFSET snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Mrcm Attribute Range Refset: id=',a.id, '  should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_mrcmattributerangerefset_s'
	from curr_mrcmattributerangerefset_s a , prev_mrcmattributerangerefset_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.active = b.active;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('Mrcm Attribute Range Refset: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_mrcmattributerangerefset_s'
	from (select a.id, a.referencedcomponentid from curr_mrcmattributerangerefset_s a  left join prev_mrcmattributerangerefset_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null) d 
	left join dependency_mrcmattributerangerefset_s e on d.id = e.id
	where e.id is null;
	