
/******************************************************************************** 
	file-centric-snapshot-definition-immutable

	Assertion:
	There is a 1:1 relationship between the ID and the immutable values in DEFINITION snapshot.

********************************************************************************/

/* 	inserting exceptions in the result table */
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.conceptid,
		concat('Definition: id=',a.id, ' references a term which is duplicated.'),
		a.id,
		'curr_textdefinition_s'
	from curr_textdefinition_s a inner join (
											select id, typeid, conceptid, languagecode, term, active, effectivetime
											from curr_textdefinition_s 
											group by typeid, conceptid, languagecode, binary term
											having count(*) >= 2
											) b
										on a.typeid = b.typeid 
											and a.conceptid = b.conceptid 
											and a.languagecode = b.languagecode 
											and a.term = b.term
											and a.id != b.id
											and (((a.active != b.active or (a.active = '1' and b.active = '1')) and a.effectivetime = b.effectivetime and cast(a.effectivetime as datetime) = (select max(cast(effectivetime as datetime)) from curr_textdefinition_s) ) /* Detect all new active records or active + inactive records in current cycle */
												or (a.active = '1' and b.active = '1' and 
													((cast(a.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_textdefinition_s ) and cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_textdefinition_s) ) /* Detect all old records in the past which are acitve */
													or (a.effectivetime <> b.effectivetime and (cast(a.effectivetime as datetime) =  (select max(cast(effectivetime as datetime)) from curr_textdefinition_s) or cast(b.effectivetime as datetime) <  (select max(cast(effectivetime as datetime)) from curr_textdefinition_s) ))))) /* Detect old and new records which are acitve */;
	commit;