
/******************************************************************************** 
	file-centric-snapshot-ie-translated-concepts.sql

	Assertion:
	Newly added active International concept must have at least one active preferred term in the Irish language refset RF2 file.

********************************************************************************/


insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select  	
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('Concept: id=',a.id, ': has no active preferred term in the Irish language refset'),
		a.id,
		'curr_concept_d'
	from curr_concept_d a
	where
	 a.active=1
	and a.moduleid='11000220105'
	 and not exists ( select b.id from curr_description_s b, curr_langrefset_s c
			where b.id = c.referencedcomponentid
			and b.typeid = '900000000000013009'
			and b.active=1
			and c.active=1
			and c.acceptabilityid = '900000000000548007'
			and c.refsetid = '21000220103'
			and b.conceptid=a.id);
			
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select  	
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('Concept: id=',a.id, ': has recently been added to the International Edition release, but has no active preferred term in the Irish language refset RF2 files.  Please check termServer to confirm whether or not a preferred term exists in the source content, and has just failed to be exported into the Irish release files?'),
		a.id,
		'curr_concept_s'
	from curr_concept_s a
	where
	 a.active=1
	and cast(a.effectivetime as datetime) = 
		(select max(cast(z.effectivetime as datetime)) from curr_concept_s z where z.moduleid='900000000000207008')
	 and not exists ( select b.id from curr_description_s b, curr_langrefset_s c
			where b.id = c.referencedcomponentid
			and b.typeid = '900000000000013009'
			and b.active=1
			and c.active=1
			and c.acceptabilityid = '900000000000548007'
			and c.refsetid = '21000220103'
			and b.conceptid=a.id);
