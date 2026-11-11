
/******************************************************************************** 
	file-centric-snapshot-simple-refset-valid-key

	Assertion:
	There is a 1:1 relationship between the id and the key values in the SIMPLE REFSET snapshot.

	A key with several members is reported when more than one of them is
	active, or when one of them changed in this release (<VERSION>). A
	historical re-add - a member inactivated in an earlier release and the
	component later added back under a new member id - leaves two rows that
	can no longer be removed from the snapshot, so it is not reported again
	in every later release.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Refset id:',a.refsetid, ' and referencedcomponent Id:', a.referencedcomponentid, ' are duplicated in the simple refset snapshot file.'),
		a.id,
		'curr_simplerefset_s'
	from curr_simplerefset_s a 
	group by a.refsetid , a.referencedcomponentid
	having count(a.id) > 1
		and (sum(a.active = 1) > 1 or max(a.effectivetime) = '<VERSION>');