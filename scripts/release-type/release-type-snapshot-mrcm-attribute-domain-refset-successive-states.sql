
/******************************************************************************** 
	release-type-snapshot-mrcm-attribute-domain-refset-successive-states

	Assertion:	
	New inactive states follow active states in the MRCM ATTRIBUTE DOMAIN REFSET snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Mrcm Attribute Domain Refset: id=',a.id, '  should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_mrcmattributedomainrefset_s'
	from curr_mrcmattributedomainrefset_s a , prev_mrcmattributedomainrefset_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.active = b.active;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('Mrcm Attribute Domain Refset: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_mrcmattributedomainrefset_s'
	from (select a.id, a.referencedcomponentid from curr_mrcmattributedomainrefset_s a  left join prev_mrcmattributedomainrefset_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null) d
	left join dependency_mrcmattributedomainrefset_s e on d.id = e.id
	where e.id is null;
	