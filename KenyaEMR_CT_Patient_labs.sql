select distinct '' AS SatelliteName, 0 AS FacilityId, d.unique_patient_no as patientID, d.patient_id as patientPK, l.encounter_id as visitID,
CAST(l.visit_date AS DATE) as orderedByDate,CAST(l.visit_date AS DATE) as reportedByDate, null as reason, (select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as facilityID,
(select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
(select name from location
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation')) as facilityName,
cn.name as testName,
case
when c.datatype_id=2 then cn2.name
else
 l.test_result
end as TestResult, 
NULL as enrollmentTest,
 'KenyaEMR' as Emr,
 'Kenya HMIS II' as Project 
from kenyaemr_etl.etl_laboratory_extract l
join kenyaemr_etl.etl_patient_demographics d on d.patient_id=l.patient_id
join concept_name cn on cn.concept_id=l.lab_test and cn.concept_name_type='FULLY_SPECIFIED'and cn.locale='en'
join concept c on c.concept_id = l.lab_test
left outer join concept_name cn2 on cn2.concept_id=l.test_result and cn2.concept_name_type='FULLY_SPECIFIED'
and cn2.locale='en' where d.unique_patient_no is not null