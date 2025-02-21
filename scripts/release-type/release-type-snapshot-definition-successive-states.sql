
/******************************************************************************** 
	release-type-snapshot-description-successive-states

	Assertion:	
	New inactive states follow active states in the DEFINITION snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('TextDefinition: id=',a.id, '  should not have a new inactive state as it was inactive previously.'),
		a.id,
		'curr_textdefinition_s'
	from curr_textdefinition_s a , prev_textdefinition_s b
	where a.effectivetime != b.effectivetime
	and a.active = 0
	and a.id = b.id
	and a.active = b.active
	and not exists (select 1 from curr_textdefinition_d c where a.id = c.id 
																and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime) 
																and c.active = 1);

	
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		d.conceptid,
		concat('TextDefinition: id=',d.id, ' is inactive but no active state found in the previous snapshot.'),
		d.id,
		'curr_textdefinition_s'
	from (select a.id, a.conceptid from curr_textdefinition_s a  left join prev_textdefinition_s b
	on a.id = b.id
	where a.active = 0
	and b.id is null
	and not exists (select 1 from curr_textdefinition_f c where a.id = c.id and a.moduleid = c.moduleid and c.active = 1 and cast(c.effectivetime as datetime) < cast(a.effectivetime as datetime))) d 
	left join dependency_textdefinition_s e on d.id = e.id
	where e.id is null;
	