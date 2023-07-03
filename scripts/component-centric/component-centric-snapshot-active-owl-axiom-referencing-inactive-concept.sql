
/*  
	Active OWL axiom refset members must not be referencing inactive concepts
*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('Active OWL axiom: id=',a.id, ' is referencing an ', if(b.id is null, 'invalid', 'inactive'), ' concept.'),
	a.id,
	'curr_owlexpressionrefset_s'
	from curr_owlexpressionrefset_s a
	left join curr_concept_s b
	on a.referencedcomponentid = b.id
	where a.active = 1
		and (b.id is null or b.active = 0);
		
	commit;


