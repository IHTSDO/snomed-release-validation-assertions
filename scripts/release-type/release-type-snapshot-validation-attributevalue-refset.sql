
/*  
	The current attribute-value refset snapshot file is an accurate derivative of the current full file
*/

/* view of current snapshot, derived from current full */
	drop table if exists temp_attributevaluerefset;
  	create table if not exists temp_attributevaluerefset like curr_attributevaluerefset_f;
  	insert into temp_attributevaluerefset
	select a.*
	from curr_attributevaluerefset_f a
	where cast(a.effectivetime as datetime) = 
		(select max(cast(z.effectivetime as datetime))
		 from curr_attributevaluerefset_f z
		 where z.id = a.id);

/* in the snapshot; not in the full */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('ATTRIBUTE VALUE REFSET: id=',a.id, ' is in SNAPSHOT file, but not in FULL file.'),
	a.id,
	'curr_attributevaluerefset_s'
	from curr_attributevaluerefset_s a
	left join temp_attributevaluerefset b
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.valueid = b.valueid
	where b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
  	or b.refsetid is null
  	or b.referencedcomponentid is null
  	or b.valueid is null;

/* in the full; not in the snapshot */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('ATTRIBUTE VALUE REFSET: id=',a.id, ' is in FULL file, but not in SNAPSHOT file.') ,
	a.id,
	'curr_attributevaluerefset_f'
	from temp_attributevaluerefset a
	left join curr_attributevaluerefset_s b 
	on a.id = b.id
	and a.effectivetime = b.effectivetime
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.valueid = b.valueid
	where b.id is null
	or b.effectivetime is null
	or b.active is null
	or b.moduleid is null
  	or b.refsetid is null
  	or b.referencedcomponentid is null
  	or b.valueid is null;
	
	commit;
	drop table if exists temp_attributevaluerefset;






