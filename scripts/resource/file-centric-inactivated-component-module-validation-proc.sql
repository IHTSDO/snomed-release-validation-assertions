/********************************************************************************
 file-centric-inactivated-component-module-validation-proc.sql

 Assertion:
 Components inactivated in the current release must remain in the module in which
 they were previously published.

 ********************************************************************************/
drop procedure if exists validate_inactivated_component_module;

create procedure validate_inactivated_component_module(
	prospective_dbname char(255),
	previous_dbname char(255),
	runid BIGINT,
	assertionid char(36)
)
begin
declare no_more_rows integer default 0;
declare tb_name char(255);
declare qualified_table_name char(255);
declare component_part char(255);
declare component_label char(255);
declare table_cursor cursor for
select t.table_name from information_schema.tables t
where t.table_schema = substring_index(prospective_dbname, '.', 1)
and t.table_name like '%\_d'
-- Only tables this procedure can actually query. It selects t1.id below, and
-- not every RF2 delta table has an id column: identifier_d is keyed on
-- alternateidentifier and declares
-- (identifierschemeid, alternateidentifier, effectivetime, active, moduleid,
-- referencedcomponentid). Without this the dynamic SQL raises
-- "Unknown column 't1.id' in 'field list'", which aborts the whole assertion -
-- so a release shipping an Identifier file was validated for none of its
-- components, not merely for that one.
and exists (
	select 1 from information_schema.columns c
	where c.table_schema = t.table_schema
	and c.table_name = t.table_name
	and c.column_name = 'id'
);
declare continue handler for not found set no_more_rows = 1;

open table_cursor;
myloop: loop
fetch table_cursor into tb_name;
if no_more_rows = 1 then
	close table_cursor;
	leave myloop;
end if;


set qualified_table_name = concat(substring_index(prospective_dbname,'.',1),'.',tb_name);
set component_part = replace(replace(tb_name, 'curr_', ''), '_d', '');
-- Do not validate inferred relationships; module moves on inactivation are expected
if component_part = 'relationship' then
	iterate myloop;
end if;
set component_label = case component_part
	when 'concept' then 'Concept'
	when 'description' then 'Description'
	when 'stated_relationship' then 'Stated relationship'
	when 'relationship_concrete_values' then 'Relationship concrete values'
	when 'langrefset' then 'Language refset member'
	when 'textdefinition' then 'Text definition'
	when 'simplerefset' then 'Simple refset member'
	when 'simplemaprefset' then 'Simple map refset member'
	when 'extendedmaprefset' then 'Extended map refset member'
	when 'complexmaprefset' then 'Complex map refset member'
	when 'associationrefset' then 'Association refset member'
	when 'attributevaluerefset' then 'Attribute value refset member'
	when 'moduledependencyrefset' then 'Module dependency refset member'
	when 'refsetdescriptor' then 'Refset descriptor member'
	when 'owlexpressionrefset' then 'OWL expression refset member'
	when 'expressionassociationrefset' then 'Expression association refset member'
	when 'mrcmdomainrefset' then 'MRCM domain refset member'
	when 'mrcmattributedomainrefset' then 'MRCM attribute domain refset member'
	when 'mrcmattributerangerefset' then 'MRCM attribute range refset member'
	when 'mrcmmodulescoperefset' then 'MRCM module scope refset member'
	when 'mapcorrelationoriginrefset' then 'Map correlation origin refset member'
	when 'descriptiontype' then 'Description type refset member'
	else replace(component_part, '_', ' ')
end;

set @details = concat(
	'CONCAT(\'', component_label, ': id= \', a.id, \' was inactivated in module \', a.moduleid, ',
	'\' but was previously published in module \', a.previous_moduleid, \'.\')'
);
set @sql = concat(
	'insert into qa_result(run_id, assertion_id, concept_id, details, component_id, table_name, skip_module_check) ',
	'select ', runid, ',', assertionid, ',0,', @details, ',a.id,\'', qualified_table_name, '\', 1 ',
	'from (',
	'select t1.id, t1.moduleid, t2.moduleid as previous_moduleid ',
	'from ', prospective_dbname, '.', tb_name, ' t1 ',
	'inner join ', previous_dbname, '.', replace(tb_name, '_d', '_s'), ' t2 on t1.id = t2.id ',
	'where t1.active = 0 ',
	'and t2.active = 1 ',
	'and t1.moduleid <> t2.moduleid ',
	'and cast(t1.effectivetime as datetime) >= cast(t2.effectivetime as datetime) ',
	') a;'
);
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

end loop myloop;
end;
