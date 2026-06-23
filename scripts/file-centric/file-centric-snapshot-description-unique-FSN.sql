
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
		concat('DESC: Active FSN =', e.term, ': is not unique in DESCRIPTION snapshot.This term already exists against active concept(s) ',
			(select group_concat(
				concat(c.conceptid, ' |', c.term, '| in ', c.moduleid, ' |', f.term, '|')
				order by c.conceptid separator '; ')
				from curr_description_s c
				inner join curr_concept_s d on c.conceptid = d.id and d.active = 1
				left join curr_description_s f on c.moduleid = f.conceptid
					and f.active = 1
					and f.typeid = '900000000000003001'
					and f.languagecode = 'en'
				where BINARY c.term = e.term
					and c.id <> e.id
					and c.active = 1
					and c.typeid = '900000000000003001')),
		e.id,
		'curr_description_s'
	from curr_description_s e
	inner join curr_concept_s ec on e.conceptid = ec.id and ec.active = 1
	inner join (
		select a.term
		from curr_description_s a
		inner join curr_concept_s b on a.conceptid = b.id and b.active = 1
		where a.active = 1
			and a.typeid = '900000000000003001'
		group by BINARY a.term
		having count(*) > 1
	) dup on BINARY e.term = dup.term
	where e.active = 1
		and e.typeid = '900000000000003001';
