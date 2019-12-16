SELECT 
DISTINCT 
               t.patient_id AS PatientPK,
               SC.value_reference AS SiteCode,
               SN.name as FacilityName,
               'KenyaEMR' as Emr,
               'Kenya HMIS II' AS Project,
               id.identifier AS HtsNumber,
               ohpc.patient_id AS PartnerPatientPk,
               ohpc.id AS PartnerPersonId,
    YEAR(ohpc.date_created)-YEAR(ohpc.birth_date)  AS Age,
               ohpc.sex,
               CASE ohpc.relationship_type  
                                              WHEN 970          THEN  'parent (Mother)'
                                              WHEN 971           THEN  'parent(Father)'
                                              WHEN 972          THEN  'sibling'
                                              WHEN 1528        THEN  'Child'
                                              WHEN 5617          THEN  'spouse'
            WHEN 163565  THEN  'partner'
                                              WHEN 162221  THEN  'cowife' 
               END     AS RelationsipToIndexClient,
    
    /*Screened for IPV? CASE?*/
               CASE WHEN ohpc.ipv_outcome IS NOT NUll THEN 'Yes' ELSE 'No' END AS  ScreenedForIpv,
                  
               ohpc.ipv_outcome AS IpvScreeningOutcome,
               CASE ohpc.living_with_patient   
                               WHEN 1065 THEN 'Yes'
                               WHEN 1066 THEN 'No'
               END AS CurrentlyLivingWithIndexClient, 
    /*knowledgeof HIV Status*/
    ohpc.baseline_hiv_status as KnowledgeOfHivStatus,  
    
pnsApprocah.name AS  PnsApproach,
ohpc.consented_contact_listing as  PnsConsent,
case when ctrace.status is null then 'N' else 'Y' end as LinkedToCare,
ctrace.encounter_date as  LinkDateLinkedToCare,
ctrace.unique_patient_no as CccNumber,
ctrace.facility_linked_to as FacilityLinkedTo,
ohpc.birth_date as DoB,
ohpc.date_created as DateElicited ,
marital.name as  MaritalStatus


  FROM 
               kenyaemr_etl.etl_hts_test t 
INNER JOIN 
        openmrs.kenyaemr_hiv_testing_patient_contact ohpc ON ohpc.patient_related_to=t.patient_id
LEFT JOIN 
                openmrs.location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id=1
LEFT JOIN
  openmrs.location SN ON SN.location_id =t.encounter_location
  LEFT JOIN 
               openmrs.patient_identifier id ON id.patient_id = t.patient_id AND id.identifier_type = (select patient_identifier_type_id 
from openmrs.patient_identifier_type
where name='OpenMRS ID')  
left JOIN openmrs.patient openmrs ON  openmrs.patient_id = id.patient_id
left JOIN openmrs.kenyaemr_hiv_testing_client_trace ctrace ON  ctrace.client_id = ohpc.id and ctrace.status='Contacted and Linked'
left join openmrs.concept_name marital ON marital.concept_id = ohpc.marital_status and marital.locale='en' and marital.concept_name_type = 'FULLY_SPECIFIED'
left join openmrs.concept_name pnsApprocah ON pnsApprocah.concept_id = ohpc.pns_approach and pnsApprocah.locale='en' and pnsApprocah.concept_name_type = 'FULLY_SPECIFIED'