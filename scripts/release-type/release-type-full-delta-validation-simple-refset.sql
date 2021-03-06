
/*  
	The current full simple refset file consists of the previously published full file and the changes for the current release
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('SimpleRefsetId=',a.id, ' is in current full file, but not in prior full or current delta file.'),
	a.id,
	'curr_simplerefset_f'
	from curr_simplerefset_f a
	left join curr_simplerefset_d b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
    	and a.moduleid = b.moduleid
    	and a.refsetid = b.refsetid
   		 and a.referencedcomponentid = b.referencedcomponentid
   	left join prev_simplerefset_f c
		on a.id = c.id
		and a.effectivetime = c.effectivetime
		and a.active = c.active
    	and a.moduleid = c.moduleid
    	and a.refsetid = c.refsetid
   		and a.referencedcomponentid = c.referencedcomponentid
	where ( b.id is null
		or b.effectivetime is null
		or b.active is null
		or b.moduleid is null
 		or b.refsetid is null
  		or b.referencedcomponentid is null)
  	and ( c.id is null
		or c.effectivetime is null
		or c.active is null
		or c.moduleid is null
 		or c.refsetid is null
  		or c.referencedcomponentid is null);
commit;