/*  
 * There must be actual changes made to previously published association refset components in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Association refset id=',a.id, ' is in the delta file, but no actual changes made since the previous release.'),
		a.id,
		'curr_associationrefset_d'
	from curr_associationrefset_d a
	left join prev_associationrefset_s b
	on a.id = b.id
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.targetcomponentid = b.targetcomponentid
	where b.id is not null
	and not exists (select 1 from curr_associationrefset_d c where a.id = c.id 
																and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																and (a.active != c.active 
																	or a.moduleid != c.moduleid 
																	or a.refsetid != c.refsetid 
																	or a.referencedcomponentid != c.referencedcomponentid
																	or a.targetcomponentid != c.targetcomponentid));