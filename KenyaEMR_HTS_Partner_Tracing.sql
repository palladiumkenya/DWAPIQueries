select distinct
t.patient_id as PatientPK,
id.identifier as HtsNumber,
client_id as PartnerPersonId,
contact_type as TraceType,
encounter_date as TraceDate,
SN.name as FacilityName,
'KenyaEMR' as Emr,
'Kenya HMIS II' AS Project,
SC.value_reference AS SiteCode,
status as TraceOutcome,
tc.appointment_date as BookingDate
from 
	kenyaemr_hiv_testing_patient_contact pc
inner join 
	kenyaemr_etl.etl_hts_test t on pc.patient_related_to=t.patient_id
inner join 
	kenyaemr_hiv_testing_client_trace tc on pc.id=tc.client_id
LEFT JOIN 
	openmrs.patient_identifier id ON id.patient_id = t.patient_id AND id.identifier_type = (select patient_identifier_type_id 
	from openmrs.patient_identifier_type where name='OpenMRS ID')
LEFT JOIN 
	 openmrs.location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id=1
LEFT JOIN 
	openmrs.location SN ON SN.location_id =t.encounter_location;