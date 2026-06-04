/********************************************************************************
 file-centric-snapshot-inactivated-component-module.sql

 Assertion:
 Components inactivated in the current release must remain in the module in which
 they were previously published.

 ********************************************************************************/
call validate_inactivated_component_module(
	'<PROSPECTIVE>',
	'<PREVIOUS>',
	<RUNID>,
	'<ASSERTIONUUID>'
);
