/*  
 * There must be actual changes made to previously published attribute value refset components in order for them to appear in the current delta.
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Attribute value refset id=',a.id, ' is in the detla file, but no actual changes made since the previous release.'),
		a.id,
		'curr_attributevaluerefset_d'
	from curr_attributevaluerefset_d a
	left join prev_attributevaluerefset_s b
	on a.id = b.id
	and a.active = b.active
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.valueid = b.valueid
	where b.id is not null;
