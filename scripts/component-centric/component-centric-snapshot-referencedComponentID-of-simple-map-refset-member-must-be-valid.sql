
/******************************************************************************** 
component-centric-snapshot-referencedComponentID-of-simple-map-refset-member-must-be-valid.sql

	Assertion:
	"All active simple map Refset records must be valid."

********************************************************************************/



    insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Reference component id:',a.referencedcomponentid,' for refset id: ', a.refsetid, ' in simple map refset must be valid.'),
        a.id,
        'curr_simplemaprefset_s'
    from curr_simplemaprefset_s a left join curr_concept_s b on a.referencedcomponentid = b.id
    where a.active = '1' and b.id is null;

