SELECT 
    t.patient_id AS PatientPK,
	SC.value_reference AS SiteCode,
	SN.name as FacilityName,
	'KenyaEMR' as Emr,
	'Kenya HMIS II' AS Project,
    id.identifier AS HtsNumber,
	t.encounter_id AS EncounterId,
	t.test_1_kit_name AS TestKitName1,
	t.test_1_kit_lot_no AS TestKitLotNumber1,
	t.test_1_kit_expiry as TestKitExpiry1,
	t.test_1_result as TestResult1,
	t.test_2_kit_name as TestKitName2,
	t.test_2_kit_lot_no as TestKitLotNumber2,
	t.test_2_kit_expiry as TestKitExpiry2,
	t.test_2_result as TestResult2

FROM 
	kenyaemr_etl.etl_hts_test t
inner join 
	kenyaemr_etl.etl_patient_demographics demographics on t.patient_id=demographics.patient_id
LEFT JOIN 
	 openmrs.location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id=1
LEFT JOIN 
  openmrs.location SN ON SN.location_id =t.encounter_location
LEFT JOIN openmrs.patient_identifier id ON id.patient_id = t.patient_id AND id.identifier_type = (select patient_identifier_type_id 
from openmrs.patient_identifier_type
where name='OpenMRS ID')