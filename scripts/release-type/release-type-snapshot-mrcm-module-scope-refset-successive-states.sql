
/******************************************************************************** 
	release-type-snapshot-mrcm-module-scope-refset-successive-states
	Assertion:

	New inactive states follow active states in the MRCM MODULE SCOPE REFSET snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Mrcm Module Scope Refset: id=',a.id, '  should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_mrcmmodulescoperefset_s'
	from curr_mrcmmodulescoperefset_s a , prev_mrcmmodulescoperefset_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.active = b.active;
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.referencedcomponentid,
		concat('Mrcm Module Scope Refset: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_mrcmmodulescoperefset_s'
	from (select a.id, a.referencedcomponentid from curr_mrcmmodulescoperefset_s a  left join prev_mrcmmodulescoperefset_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null) d 
	left join dependency_mrcmmodulescoperefset_s e on d.id = e.id
	where e.id is null;
	