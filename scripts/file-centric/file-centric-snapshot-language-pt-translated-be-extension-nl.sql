
/******************************************************************************** 
	file-centric-snapshot-language-unique-pt-translated-no-extension

	Assertion:
	Every active concept from international release is recommended to have one active preferred term in the Belgian Dutch language refset.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select  	
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('Concept: id=',a.id, ': has no active preferred term in the Belgian Dutch language refset'),
		a.id,
		'curr_concept_s'
	from curr_concept_s a
	where
	 a.active=1
	 and a.moduleid in ('900000000000207008','900000000000012004')
	 and not exists ( select b.id from curr_description_s b, curr_langrefset_s c
			where b.id = c.referencedcomponentid
			and b.typeid = '900000000000013009'
			and b.active=1
			and c.active=1
			and c.acceptabilityid = '900000000000548007'
			and c.refsetid = '31000172101'
			and b.conceptid=a.id);
