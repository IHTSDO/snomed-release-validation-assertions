
/******************************************************************************** 
	file-centric-snapshot-association-valid-key

	Assertion:
	There is a 1:1 relationship between the id and the key values in the ASSOCIATION REFSET snapshot file.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ReferencedComponentId:', a.referencedcomponentid, ' targetComponentId:', a.targetcomponentid, ' and refsetId:', a.refsetid, ' are duplicated in the association refset snapshot file.'),
		a.id,
		'curr_associationrefset_s'
	from curr_associationrefset_s a inner join (
											select id, referencedComponentId, targetcomponentId, refsetid, active, effectivetime
											from curr_associationrefset_s 
											group by referencedComponentId, targetcomponentId, refsetid
											having count(*) >= 2
											) b
										on a.referencedComponentId = b.referencedComponentId 
											and a.targetcomponentId = b.targetcomponentId 
											and a.refsetid = b.refsetid 
											and a.id != b.id
											and ((a.effectivetime = b.effectivetime and cast(a.effectivetime as datetime) = (select max(cast(effectivetime as datetime)) from curr_associationrefset_s) ) /* Detect all new records in current cycle */
												or (a.active = '1' and b.active = '1' and 
													((cast(a.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_associationrefset_s ) and cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_associationrefset_s) ) /* Detect all old records in the past which are acitve */
													or (a.effectivetime <> b.effectivetime and (cast(a.effectivetime as datetime) =  (select max(cast(effectivetime as datetime)) from curr_associationrefset_s) or cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_associationrefset_s) ))))) /* Detect old and new records which are acitve */;
	
	