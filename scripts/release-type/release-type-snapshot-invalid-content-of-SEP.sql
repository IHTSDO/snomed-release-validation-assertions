/******************************************************************************** 
	component-centric-snapshot-invalid-content-of-SEP

	Assertion:  validate that the SE + SP refsets match the content in the release
********************************************************************************/

	/* Create TEMP tables */
	drop table if exists tmp_entire_all_part_concept;
	create table if not exists tmp_entire_all_part_concept as
	select a.id, b.term
	from curr_concept_s a 
		 left join curr_description_s b on a.id = b.conceptid
	where a.active = '1'
		and b.active = '1'
		and b.typeid = '900000000000003001' /* FSN*/
		and b.term like '%(body structure)'
		and (b.term like 'Entire%' or b.term like 'All%' or b.term like 'Part%');
	commit;

	alter table tmp_entire_all_part_concept add index idx_tmp_entire_all_part_concept_id(id);	

	drop table if exists tmp_sep_refset;
	create table if not exists tmp_sep_refset as
	select a.*
	from curr_associationrefset_s a
	where a.refsetid in ('734138000','734139008');
	commit;

	alter table tmp_sep_refset add index idx_tmp_sep_refset_id(id);
	alter table tmp_sep_refset add index idx_tmp_sep_refset_refsetid(refsetid);	
	alter table tmp_sep_refset add index idx_tmp_sep_refset_referencedcomponentid(referencedcomponentid);
	alter table tmp_sep_refset add index idx_tmp_sep_refset_targetcomponentid(targetcomponentid);
	/* End creating TEMP tables */

	/* 1. For active members, all referenced components and target components are active */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('The ', if(b.active = '0' or b.active is null, 'referenced component', 'target component') , ' id= ',  if(b.active = '0' or b.active is null, a.referencedcomponentid, a.targetcomponentid), ' for refset member id=', a.id, ' in SEP refset must be active.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a 
		left join curr_concept_s b on a.referencedcomponentid = b.id
		left join curr_concept_s c on a.targetcomponentid = c.id
	where a.active = '1'
	    and ((b.active = '0' or b.active is null)
			or (c.active = '0'or c.active is null));

	/* 2. For all members (active or inactive) any referencedComponentId (S) should only appear once per refset */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('The referenced component id=', a.referencedcomponentid, ' should only appear once per ', if( a.refsetid = '734138000', 'SE', 'SP'),' refset.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
	where not exists (select *
                   from tmp_sep_refset b
                   where cast(b.effectivetime as datetime) < cast('20210731' as datetime)
				   and b.active = '0')
	group by a.referencedcomponentid, a.refsetid
    having count(a.referencedcomponentid) > 1;

	/* 3. For all active members, the targetComponentId (E,P) should only appear once */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('The target component id=', a.targetcomponentid, ' for refset member id=', a.id, ' should only appear once in SEP refset.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
	where a.active = '1'
    group by a.targetcomponentid , a.refsetid
    having count(a.targetcomponentid) > 1;
    
	/* Populate our exclusion list where the usual SEP naming convention does not apply.  This creates the descendants table */
	call findDescendants('4421005,122453002,51576004,280115004,91832008,258331007,118956008,278001007,39801007,361083003,21229009,87100004,420864000,698969006,279228004,698968003,244023005,123957003');

	/* 4. The FSN for an S concept must contain the word Structure (case insensitive match) and must not start with the word Entire, All or Part */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('A S concept id=', a.referencedcomponentid , ' for refset member id=', a.id,' in SEP refset must contain the word Structure and must not start with the word Entire, All or Part.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
		left join curr_description_s b on a.referencedcomponentid = b.conceptid
		left join descendants d on a.referencedcomponentid = d.sourceid 
	where a.active = '1'
		and b.active = '1'
		and d.sourceId is null
		and b.typeid = '900000000000003001' /* FSN */
		and (lower(SUBSTRING(b.term, 1, LENGTH(b.term) - 17)) not like '%structure%' or (b.term like 'Entire%' or  b.term like 'All%' or b.term like 'Part%'));

	/* 5. The FSN for a P concept must start with the word Part (case sensitive match) or contain the word part*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('A P concept id=', a.targetcomponentid, ' for refset member id=', a.id, ' in SEP refset must contain the word part.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
		left join curr_description_s b on a.targetcomponentid = b.conceptid
	where a.refsetid = '734139008' /* SP Refset */
		and a.active = '1'
		and b.active = '1'
		and b.typeid = '900000000000003001' /* FSN */
		and (b.term not like 'Part%' and  b.term not like '%part%');

	/* 6. The FSN for an E concept must start with the word Entire or the word All (case sensitive match)*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('An E concept id=', a.targetcomponentid, ' for refset member id=', a.id, ' in SEP refset must start with the word Entire or the word All.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
		left join curr_description_s b on a.targetcomponentid = b.conceptid
		left join descendants d on a.targetcomponentid = d.sourceid 
	where a.refsetid = '734138000' /* SE Refset */ 
		and a.active = '1'
		and b.active = '1'
		and b.typeid = '900000000000003001' /* FSN */
		and (b.term not like 'Entire%' and  b.term not like 'All%')
		and d.sourceid is null;

	/* 7. All body structure concepts that start with the word 'Entire' or 'All' should appear in the SE refset with some exceptions.
		  If a S concept has both E concept and All concept, the E concept should be included for the SE refset. But All concept would not be required for the SE refset.*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('A body structure concept id=', a.id,' that starts with the word Entire should appear in the SE refset.'),
		a.id,
		'curr_concept_s'
	from tmp_entire_all_part_concept a
		left join (select DISTINCT targetcomponentid from tmp_sep_refset where refsetid = '734138000' /* SE Refset */ and active = '1') b on a.id = b.targetcomponentid
	where a.term like 'Entire%'
		and b.targetcomponentid is null;

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('A body structure concept id=', a.id,' that starts with the word All should appear in the SE refset.'),
		a.id,
		'curr_concept_s'
	from tmp_entire_all_part_concept a
		left join (select * from tmp_sep_refset where refsetid = '734138000' /* SE Refset */ and active = '1') b on a.id = b.targetcomponentid
		left join (select a1.id, b1.targetcomponentid
					from tmp_entire_all_part_concept a1 
						left join (select DISTINCT targetcomponentid from tmp_sep_refset where refsetid = '734138000' /* SE Refset */ and active = '1') b1 on a1.id = b1.targetcomponentid
					where a1.term like 'Entire%' 
					and b1.targetcomponentid is not null) c on b.referencedcomponentid = c.id
	where a.term like 'All%'
		and b.targetcomponentid is null
		and c.targetcomponentid is null;

	/* 8. All body structure concepts that start with the word 'Part' should appear in the SP refset.*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('A body structure concept id=', a.id,' that starts with the word Part should appear in the SP refset.'),
		a.id,
		'curr_concept_s'
	from tmp_entire_all_part_concept a
		left join (select DISTINCT targetcomponentid from tmp_sep_refset where refsetid = '734139008' /* SP Refset */ and active = '1') b on a.id = b.targetcomponentid
	where a.term like 'Part%'
		and b.targetcomponentid is null;

	/* 9. For both refsets, the 'S' concept should be an inferred parent the targetComponentId (E or P). There may be additional parent*/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('The target component id=', a.targetcomponentid, ' for refset member id=', a.id, ' should have an inferred parent in S concept in ', if( a.refsetid = '734138000', 'SE', 'SP'),' refset.'),
		a.id,
		'curr_associationrefset_s'
	from tmp_sep_refset a
		left join curr_relationship_s b on a.targetcomponentid = b.sourceid
		left join (select c.referencedcomponentid 
					from tmp_sep_refset c left join curr_relationship_s d on c.targetcomponentid = d.sourceid
					where c.active = '1'
					and d.active = '1'
					and d.typeid = '116680003'
					and c.referencedcomponentid = d.destinationid) f on a.referencedcomponentid = f.referencedcomponentid
	where a.active = '1'
		and b.active = '1'
		and b.typeid = '116680003'
		and a.referencedcomponentid <> b.destinationid
		and f.referencedcomponentid is null;

	drop table if exists tmp_entire_all_part_concept;
	drop table if exists tmp_sep_refset;