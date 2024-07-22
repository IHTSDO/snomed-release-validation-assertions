
/******************************************************************************** 
	file-centric-snapshot-attribute-value-unique-pair

	Assertion:
	Reference componentId and valueId pair is unique in the ATTRIBUTE VALUE snapshot.
	Note:Only to check contents in current release and add module id for the us edtion

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Reference component id:',a.referencedcomponentid, ' valueid=', a.valueid, ' pair is not unique in the Attribute Value snapshot'),
		a.id,
		'curr_attributevaluerefset_s'
	from curr_attributevaluerefset_s a
	where cast(a.effectivetime as datetime) = (select max(cast(z.effectivetime as datetime)) from curr_attributevaluerefset_d z where z.id = a.id)
	group by a.referencedcomponentid,a.valueid,a.moduleid
	having  count(a.id) > 1;