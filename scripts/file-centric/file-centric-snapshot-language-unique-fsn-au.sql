
/******************************************************************************** 
	file-centric-snapshot-language-unique-fsn-au

	Assertion:
	Every active concept defined in the Australian extension has a preferred FSN in the en-US language refset.
	

********************************************************************************/
	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('Concept: id=',a.id, ' does not have an FSN preferred in the US language refset.'),
		a.id,
		'curr_concept_s'
	from curr_concept_s a
	where a.active = '1'
	and a.moduleid = '32506021000036107'
	and not exists (select b.id
		from curr_description_s b, curr_langrefset_s c
		where b.id=c.referencedcomponentid
		and b.active = '1'
		and c.active = '1'
		and b.typeid = '900000000000003001'
		and c.refsetid='900000000000509007' 
		and c.acceptabilityid='900000000000548007'
		and b.conceptid= a.id);

