
/*  
	The current simple refset snapshot file is an accurate derivative of the current full file
*/

/* view of current snapshot, derived from current full */
	drop table if exists temp_simplerefset_view;
  	create table if not exists temp_simplerefset_view like curr_simplerefset_f;
  	insert into temp_simplerefset_view
	select a.*
	from curr_simplerefset_f a
	where cast(a.effectivetime as datetime) = 
		(select max(cast(z.effectivetime as datetime))
		 from curr_simplerefset_f z
		 where z.id = a.id);

/* in the snapshot; not in the full */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('SIMPLE REFSET: id=',a.id, ' is in SNAPSHOT file, but not in FULL file.'),
	a.id,
	'curr_simplerefset_s'
	from curr_simplerefset_s a
	left join temp_simplerefset_view b
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
	where b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
  	or b.refsetid is null
  	or b.referencedcomponentid is null;

	commit;
	
/* in the full; not in the snapshot */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('SIMPLE REFSET: id=',a.id, ' is in FULL file, but not in SNAPSHOT file.'),
	a.id,
	'curr_simplerefset_f'
	from temp_simplerefset_view a
	left join curr_simplerefset_s b 
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
	where b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
  	or b.refsetid is null
  	or b.referencedcomponentid is null;
	
	commit;
	drop table if exists temp_simplerefset_view;






