
/********************************************************************************
	file-centric-snapshot-correct-module-id.sql

	Assertion:
	The module id of all data must be correct

********************************************************************************/
drop table if exists module_id;
create table module_id(
moduleid bigint(20) not null
) engine=myisam default charset=utf8;

insert into module_id(moduleid) values(900000000000012004); /* SNOMED CT model component module */

insert into module_id
select distinct moduleid from curr_moduledependencyrefset_s
where active = 1;

call validate_module_id('<PROSPECTIVE>',<RUNID>,'<ASSERTIONUUID>');
