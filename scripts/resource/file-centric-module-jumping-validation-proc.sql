/********************************************************************************
 file-centric-module-jumping-validation-proc.sql
 
 Assertion:
 Validate that module has been jumped according to module in dependency package.
 
 ********************************************************************************/
drop procedure if exists validate_module_jumping;

create procedure validate_module_jumping(prospective_dbname char(255), previous_dbname char(255), dependent_dbname char(255), runid BIGINT, assertionid char(36)) 
begin 
declare no_more_rows integer default 0;
declare tb_name char(255);
declare table_cursor cursor for
select table_name from information_schema.tables where table_schema = substring_index(prospective_dbname, '.', 1) and table_name like '%\_s';
declare continue handler for not found set no_more_rows = 1;
open table_cursor;
myloop: loop fetch table_cursor into tb_name;
if no_more_rows = 1 then 
close table_cursor;
leave myloop;
end if;

set @details1 = CONCAT('CONCAT(\'The module of the component id= \', a.id,\' has been jumped from International module: \', a.other_moduleid,\' to \', a.moduleid)');
set @sql1 = CONCAT('insert into qa_result(run_id, assertion_id, concept_id, details, component_id, table_name) select ', runid, ',', assertionid, ',NULL,', @details1 ,',a.id,\'', tb_name, '\' from (select t1.id, t1.moduleid, t2.moduleid as other_moduleid from ', prospective_dbname, '.', tb_name, ' t1, ', dependent_dbname, '.', tb_name, ' t2 where t1.moduleid <> t2.moduleid and t1.id = t2.id and t1.active = t2.active) a;');
prepare stmt from @sql1;
execute stmt;
deallocate prepare stmt;

set @details2 = CONCAT('CONCAT(\'The module of the component id= \', a.id,\' has been jumped from: \', a.other_moduleid,\' to \', a.moduleid)');
set @sql2 = CONCAT('insert into qa_result(run_id, assertion_id, concept_id, details, component_id, table_name) select ', runid, ',', assertionid, ',NULL,', @details2 ,',a.id,\'', tb_name, '\' from (select t1.id, t1.moduleid, t2.moduleid as other_moduleid from ', prospective_dbname, '.', tb_name, ' t1, ', previous_dbname, '.', tb_name, ' t2 where t1.moduleid <> t2.moduleid and t1.id = t2.id) a;');
prepare stmt2 from @sql2;
execute stmt2;
deallocate prepare stmt2;

end loop myloop;
end;