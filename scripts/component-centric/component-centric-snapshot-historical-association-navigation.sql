
/******************************************************************************** 
	component-centric-snapshot-historical-association-navigation

	Assertion:
	targetComponentId does not refer to navigation concepts.
	Note: Only check current release changes.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MEMBER: id=',a.id, ': Active Historical refset member maps to Target Component that is an active navigation concept.'),
	    a.id,
        'curr_associationrefset_d'
	from curr_associationrefset_d a
	left join res_navigationconcept b on a.targetcomponentid = b.referencedcomponentid
	where a.active = '1'
	and b.active = '1'
	and b.refsetid = '447570008'
	group by a.referencedcomponentid, a.targetcomponentid;
		