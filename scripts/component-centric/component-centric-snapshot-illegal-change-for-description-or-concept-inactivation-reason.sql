
/********************************************************************************
	component-centric-snapshot-illegal-change-for-description-or-concept-inactivation-reason

	Assertion:
	Inactive members must not have any illegal change for inactivation indicator reason.

********************************************************************************/

   insert into qa_result (runid, assertionuuid, concept_id, details, component_id, table_name)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Attribute Value Refset id=',a.id, ' is an inactive ', if( a.refsetid = '900000000000490003', 'Description', 'Concept'),' inactivation indicator refset member, but there is an illegal modification of its inactivation indicator reason.'),
		a.id,
        'curr_attributevaluerefset_s'
	from curr_attributevaluerefset_s a
	left join prev_attributevaluerefset_s b on a.id = b.id
	where a.active = '0'
	and b.active = '0'
	and a.refsetid in ('900000000000490003','900000000000489007')
	and a.valueid <> b.valueid;
