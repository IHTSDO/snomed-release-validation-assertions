 /******************************************************************************** 
component-centric-snapshot-expression-association-valid-expression-syntax.sql

	Assertion:
	The expression syntax is valid in expression association refset snapshot.

********************************************************************************/
insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
 select
 	<RUNID>,
	'<ASSERTIONUUID>',
 	a.referencedcomponentid,
 	concat('MapTarget:',a.mapTarget,' contains invalid expression in the expression association refset snapshot.'),
 	a.id,
    'curr_expressionassociationrefset_s'
 from curr_expressionassociationrefset_s a
 	where a.expression not like "363787002:704346009=%";
 commit;
