
/********************************************************************************
	file-centric-snapshot-correct-module-id.sql

	Assertion:
	The module id of all data must be correct

********************************************************************************/
call validate_changes_in_expected_modules_extension('<PROSPECTIVE>',<RUNID>,'<ASSERTIONUUID>');
