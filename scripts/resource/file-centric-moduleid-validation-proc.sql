/********************************************************************************
	file-centric-moduleid-validation-proc.sql

	Assertion:
	Data should have correct module ID

********************************************************************************/
drop procedure if exists validate_module_id;
create procedure validate_module_id(dbname char(255),runid BIGINT, assertionid char(36))
begin
declare no_more_rows integer default 0;
declare tb_name char(255);
declare table_cursor cursor for
select t.table_name from information_schema.tables t
where t.table_schema = substring_index(dbname,'.',1)
and t.table_name like '%\_s'
-- Only tables this procedure can actually query. It selects id and moduleid
-- below, and not every RF2 table has an id column: identifier_s is keyed on
-- alternateidentifier. Without this the dynamic SQL raises
-- "Unknown column 'id' in 'field list'", which aborts the whole assertion.
and exists (
	select 1 from information_schema.columns c
	where c.table_schema = t.table_schema
	and c.table_name = t.table_name
	and c.column_name = 'id'
)
and exists (
	select 1 from information_schema.columns c
	where c.table_schema = t.table_schema
	and c.table_name = t.table_name
	and c.column_name = 'moduleid'
);
declare continue handler for not found set no_more_rows = 1;
open table_cursor;
myloop: loop fetch table_cursor into tb_name;
if no_more_rows = 1
then close table_cursor;
leave myloop;
end if;
set @component = substring_index(tb_name,'_s',1);
set @details = CONCAT('CONCAT(\'',@component,'\',\' ::id= \',a.id,\' ::module id: \',a.moduleid,\' is not in module dependency list\')');
set @sql = CONCAT('insert into qa_result(run_id, assertion_id,concept_id, details, component_id) select ', runid,',',assertionid,',0,',@details, ',a.id from (select id,moduleid from ', substring_index(dbname,'.',1),'.',tb_name, '  where moduleid not in (select moduleid from ',substring_index(dbname,'.',1),'.module_id)) a;');
prepare stmt from @sql;
execute stmt;
drop prepare stmt;
end loop myloop;
end;
