
/******************************************************************************** 
	file-centric-snapshot-owl-expression-unique-active-axiom-for-same-concept

	Assertion:
	The current OWL Expression snapshot file does not contain any duplicate active OWL axioms for the same concept

********************************************************************************/
	
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('OWL Expression : ids =', GROUP_CONCAT(DISTINCT a.id ORDER BY a.id ASC SEPARATOR ', '), ' : Duplicated active OWL axioms for the concept ', a.referencedcomponentid,' in the OWL Expression snapshot.'),
		a.id,
		'curr_owlexpressionrefset_s'
	from curr_owlexpressionrefset_s a
	where a.active = '1'
	group by a.referencedcomponentid, a.owlexpression
	having count(*) > 1;