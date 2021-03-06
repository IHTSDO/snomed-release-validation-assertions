
/******************************************************************************** 
	component-centric-snapshot-ctv3-unique

	Assertion:
	CTV3 simple map refset members are unique.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MEMBER: id=',a.id, ': CTV3 member key (referencedcomponentid, maptarget) is not unique.'),
        a.id,
        'curr_simplemaprefset_s'
	from curr_simplemaprefset_s a
	where a.refsetid = '900000000000497000'
	group by a.referencedcomponentid, a.maptarget
	having count(*) > 1;	
