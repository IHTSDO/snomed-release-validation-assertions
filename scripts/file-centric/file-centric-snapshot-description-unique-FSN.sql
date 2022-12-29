
/******************************************************************************** 
	file-centric-snapshot-description-unique-FSN

	Assertion:
	Active Fully Specified Name associated with active concepts is unique in DESCRIPTION snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		e.conceptid,
		concat('DESC: Active FSN =',e.term, ': is not unique in DESCRIPTION snapshot.This term already exists against active concept ', e.duplicate_conceptid,' |', e.term,'| in ', e.duplicate_moduleid,' |',f.term,'|'),
		e.id,
		'curr_description_s'
	from (select duplicate.id, duplicate.term, duplicate.conceptid, c.id as duplicate_id, c.moduleid as duplicate_moduleid, c.conceptid as duplicate_conceptid 
		from (select a.id as id, a.term as term, a.conceptid as conceptid 
				from curr_description_s a , curr_concept_s b 
				where a.conceptid = b.id 
				and b.active = 1 
				and a.active = 1 
				and a.typeid = '900000000000003001' 
				group by BINARY a.term having count(a.term) > 1) duplicate, curr_description_s c, curr_concept_s d 
		where duplicate.term = c.term 
		and duplicate.id <> c.id 
		and c.active = 1 
		and c.typeid = '900000000000003001' 
		and c.conceptid = d.id 
		and d.active = 1) e left join curr_description_s f on e.duplicate_moduleid = f.conceptid 
	where f.active = 1 
	and f.typeid = '900000000000003001' 
	and f.languagecode = 'en';
