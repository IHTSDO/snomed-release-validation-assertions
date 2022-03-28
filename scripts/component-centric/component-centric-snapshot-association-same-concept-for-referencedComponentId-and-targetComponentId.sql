
/******************************************************************************** 
	component-centric-snapshot-association-same-concept-for-referencedComponentId-and-targetComponentId

	Assertion:
	Association reference record is referencing the same concept for both referencedComponentId and targetComponentId

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MEMBER: id=',a.id, ': Association reference record is referencing the same concept ', a.referencedcomponentid,' for both referencedComponentId and targetComponentId.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a	
	where a.active = '1' and a.referencedcomponentid = a.targetcomponentid;
	