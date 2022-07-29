
/******************************************************************************** 
	file-centric-snapshot-description-immutable

	Assertion:
	There is a 1:1 relationship between the id and the immutable values in the description snapshot.
	Note: Checking for current authoring cycle only as there are some voilations in the published releases.
	Add moduleid for edition release validation.(RVF-306)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Description: id=',a.id, ' references a term which is duplicated.'),
		a.id,
		'curr_description_s'
	from curr_description_s a inner join (
											select id, typeid, conceptid, languagecode, term, active, effectivetime
											from curr_description_s 
											group by typeid, conceptid, languagecode, binary term
											having count(*) >= 2
											) b
										on a.typeid = b.typeid 
											and a.conceptid = b.conceptid 
											and a.languagecode = b.languagecode 
											and a.term = b.term
											and a.id != b.id
											and (((a.active != b.active or (a.active = '1' and b.active = '1')) and a.effectivetime = b.effectivetime and cast(a.effectivetime as datetime) = (select max(cast(effectivetime as datetime)) from curr_description_s) ) /* Detect all new active records or active + inactive records in current cycle */
												or (a.active = '1' and b.active = '1' and 
													((cast(a.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_description_s ) and cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_description_s) ) /* Detect all old records in the past which are acitve */
													or (a.effectivetime <> b.effectivetime and (cast(a.effectivetime as datetime) =  (select max(cast(effectivetime as datetime)) from curr_description_s) or cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_description_s) ))))) /* Detect old and new records which are acitve */;
	commit;