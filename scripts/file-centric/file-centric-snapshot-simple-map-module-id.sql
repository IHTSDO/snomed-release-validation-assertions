
/******************************************************************************** 
	file-centric-snapshot-simple-map-module-id.sql

	Assertion:
	The module id of all SimpleMap members should be the core module id

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Simple map refset: id=',a.id, ' has a wrong module id:', a.moduleid),
		a.id,
		'curr_simplemaprefset_s'
	from curr_simplemaprefset_s a 
	where 'NULL' = '<INCLUDED_MODULES>' -- Only validate the INT release
	AND a.moduleid != '900000000000207008';
	