SELECT  distinct d.patient_id as PatientPK,
	SC.value_reference AS SiteCode,
	SN.name as FacilityName,
	'KenyaEMR' as Emr,
	'Kenya HMIS II' AS Project,
	id.identifier AS HtsNumber,
	d.DOB,
	case when d.Gender='M' then 'Male' else 'Female' end as Gender,
	d.marital_status as MaritalStatus,
	t.population_type as PopulationType,
	t.key_population_type as KeyPopulationType,
	t.disability_type as PatientDisabled,
	A.county_district as County,
	A.state_province as SubCounty,
	A.address4 as Ward
FROM  
kenyaemr_etl.etl_patient_demographics  d
INNER JOIN 
kenyaemr_etl.etl_hts_test t ON d.patient_id=t.patient_id
LEFT JOIN 
 openmrs.location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id=1
LEFT JOIN 
  openmrs.location SN ON SN.location_id =t.encounter_location
LEFT JOIN openmrs.person_address A ON A.person_id=d.patient_id
LEFT JOIN openmrs.patient_identifier id ON id.patient_id = t.patient_id AND id.identifier_type = (select patient_identifier_type_id 
from openmrs.patient_identifier_type
where name='OpenMRS ID') 
group by d.patient_id