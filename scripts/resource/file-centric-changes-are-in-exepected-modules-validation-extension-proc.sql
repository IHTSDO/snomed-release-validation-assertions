/********************************************************************************
	file-centric-changes-are-in-exepected-modules-validation-proc.sql

	Assertion:
	All the changes in the release are in the expected set of modules

********************************************************************************/
drop procedure if exists validate_changes_in_expected_modules_extension;
create procedure validate_changes_in_expected_modules_extension(dbname char(255),runid BIGINT, assertionid char(36))
begin
declare no_more_rows integer default 0;
declare tb_name char(255);
declare table_cursor cursor for select table_name from information_schema.tables where table_schema = substring_index(dbname,'.',1) and table_name like '%\_d';
declare continue handler for not found set no_more_rows = 1;
open table_cursor;
myloop: loop fetch table_cursor into tb_name;
	if no_more_rows = 1
	then close table_cursor;
	leave myloop;
	end if;
	if (tb_name != "moduledependencyrefset_d") then
		set @component = substring_index(tb_name,'_d',1);
		set @details = CONCAT('CONCAT(\'',@component,'\',\' ::id= \',a.id,\' ::module id: \',a.moduleid,\' was made in the release but not in the expected set of modules\')');
		set @sql = CONCAT('insert into qa_result(run_id, assertion_id,concept_id, details) select ', runid,',',assertionid,',0,',@details,' from (select id,moduleid from ', substring_index(dbname,'.',1),'.',tb_name, '  where moduleid not in (select distinct moduleid from ',substring_index(dbname,'.',1),'.moduledependencyrefset_d where active="1")) a;');
		prepare stmt from @sql;
		execute stmt;
		drop prepare stmt;
	end if;
end loop myloop;
end;