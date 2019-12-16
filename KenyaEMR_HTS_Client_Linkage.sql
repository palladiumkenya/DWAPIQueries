SELECT  distinct htsrl.patient_id as PatientPK,
	SC.value_reference AS SiteCode,
	SN.name as FacilityName,
	'KenyaEMR' as Emr,
	'Kenya HMIS II' AS Project,
	id.identifier AS HtsNumber,
	ref.date_to_enrol as DatePrefferedToBeEnrolled,
	ref.facility_referred_to as FacilityReferredTo,
	htsrl.provider_handed_to as HandedOverTo,
	NULL HandedOverToCadre,
	htsrl.facility_linked_to as EnrolledFacilityName,
	ref.visit_date as ReferralDate,
	htsrl.enrollment_date as DateEnrolled,
	htsrl.ccc_number as ReportedCCCNumber,
	htsrl.art_start_date as ReportedStartARTDate
FROM 
	kenyaemr_etl.etl_hts_referral_and_linkage htsrl 
INNER JOIN 
	kenyaemr_etl.etl_hts_test t ON htsrl.patient_id=t.patient_id
LEFT JOIN 
	kenyaemr_etl.etl_hts_referral ref ON htsrl.patient_id=ref.patient_id
LEFT JOIN 
	 openmrs.location_attribute SC ON SC.location_id = htsrl.encounter_location AND SC.attribute_type_id=1
LEFT JOIN 
  openmrs.location SN ON SN.location_id =htsrl.encounter_location
LEFT JOIN 
 openmrs.patient_identifier id ON id.patient_id = htsrl.patient_id AND id.identifier_type = (select patient_identifier_type_id 
from openmrs.patient_identifier_type
where name='OpenMRS ID')  
LEFT JOIN 
	kenyaemr_etl.etl_hiv_enrollment EN ON EN.patient_id =htsrl.patient_id