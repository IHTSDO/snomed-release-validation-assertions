
/*  
	The current attribute-value refset delta file is an accurate derivative of the current full file
*/

/* in the delta; not in the full */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('ATTRIBUTE VALUE REFSET: id=',a.id, ' is in DELTA file, but not in FULL file.'),
		a.id,
		'curr_attributevaluerefset_d'
	from curr_attributevaluerefset_d a
	left join curr_attributevaluerefset_f b
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
	