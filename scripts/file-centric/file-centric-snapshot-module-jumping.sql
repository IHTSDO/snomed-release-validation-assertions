/********************************************************************************
 file-centric-snapshot-module-jumping.sql
 
 Assertion:
 Validate that module has been jumped according to module in previous/dependency package.
 
 ********************************************************************************/
call validate_module_jumping(
	'<PROSPECTIVE>',
	'<PREVIOUS>',
	'<DEPENDENCY>',	
	<RUNID>,
	'<ASSERTIONUUID>'
);