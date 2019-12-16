SELECT 
	t.patient_id as PatientPK,
	SC.value_reference AS SiteCode,
	 SN.name as FacilityName,
	'KenyaEMR' as Emr,
	'Kenya HMIS II' AS Project,
    id.identifier AS HtsNumber,
	t.encounter_id as EncounterId,
	t.visit_date as TestDate,
	t.ever_tested_for_hiv as EverTestedForHiv,
	t.months_since_last_test as MonthsSinceLastTest,
	t.client_tested_as as ClientTestedAs,
	t.hts_entry_point as EntryPoint,
	t.test_strategy as TestStrategy,
	t.test_1_result as TestResult1,
	t.test_2_result as TestResult2,
	t.final_test_result as FinalTestResult,
	t.patient_given_result as PatientGivenResult,
	t.tb_screening as TbScreening,
	t.patient_had_hiv_self_test as ClientSelfTested,
	t.couple_discordant as CoupleDiscordant,
	CASE t.test_type
		WHEN 1 THEN 'Initial'
        WHEN 2 THEN 'Repeat' 
	END AS TestType,
	t.patient_consented as Consent
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