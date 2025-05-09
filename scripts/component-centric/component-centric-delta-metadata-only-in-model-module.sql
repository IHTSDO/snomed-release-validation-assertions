/*
 * Metadata concepts must only exist in model component module.
 */
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
SELECT <RUNID>, '<ASSERTIONUUID>', c.id,  
concat('Metadata concept (', c.id, '|', d.term,'|) in module other than model module'),
c.id,
'curr_concept_d'
FROM curr_description_s d, curr_concept_d c
WHERE 'NULL' = '<INCLUDED_MODULES>' -- Only validate the INT release
AND d.conceptid = c.id
AND d.typeid = 900000000000003001 -- FSN
AND d.term LIKE '%(%metadata%)'
AND c.active = 1 
AND c.moduleId <> 900000000000012004 -- Model Module
AND d.active = 1;
 commit;
