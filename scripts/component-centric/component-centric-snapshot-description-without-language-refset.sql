/******************************************************************************** 
	component-centric-snapshot-description-without-language-refset.sql
	Assertion:
	Active descriptions should be acceptable at least in one dialect.
	
********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Term',a.term, ' descriptionId=',a.id, ': is not acceptable in any language refsets'),
		a.id,
        'curr_description_d'
		from curr_description_d a
		left join langrefset_s b on a.id = b.referencedcomponentid
		where a.active =1 
		and b.referencedcomponentid is null;
		