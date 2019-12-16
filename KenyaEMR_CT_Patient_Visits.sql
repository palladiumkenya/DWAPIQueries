select distinct
'' AS SatelliteName, 0 AS FacilityId, d.unique_patient_no as PatientID,
d.patient_id as PatientPK,
(select name from location
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation')) as FacilityName,
(select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
fup.visit_id as VisitID,
case when fup.visit_date < '1990-01-01' then null else CAST(fup.visit_date AS DATE) end  AS VisitDate,
'Out Patient' as Service,
fup.visit_scheduled as VisitType,
case fup.who_stage
when 1220 then 'WHO I'
when 1221 then 'WHO II'
when 1222 then 'WHO III'
when 1223 then 'WHO IV'
when 1204 then 'WHO I'
when 1205 then 'WHO II'
when 1206 then 'WHO III'
when 1207 then 'WHO IV'
  else ''
end as WHOStage,
'' as WABStage,
case fup.pregnancy_status
when 1065 then 'Yes'
when 1066 then 'No'
end as Pregnant,
CAST(fup.last_menstrual_period AS DATE) as LMP,
CAST(fup.expected_delivery_date AS DATE) as EDD,
fup.height as Height,
fup.weight as Weight,
concat(fup.systolic_pressure,'/',fup.diastolic_pressure) as BP,
'ART|CTX' as AdherenceCategory,
concat(
IF(fup.arv_adherence=159405, 'Good', IF(fup.arv_adherence=159406, 'Fair', IF(fup.arv_adherence=159407, 'Poor', ''))), IF(fup.arv_adherence in (159405,159406,159407), '|','') ,
IF(fup.ctx_adherence=159405, 'Good', IF(fup.ctx_adherence=159406, 'Fair', IF(fup.ctx_adherence=159407, 'Poor', '')))
) AS Adherence,
'' as OI,
NULL as OIDate,
case fup.family_planning_status
when 695 then 'Currently using FP'
when 160652 then 'Not using FP'
when 1360 then 'Wants FP'
else ''
end as FamilyPlanningMethod,
concat(
case fup.condom_provided
when 1065 then 'Condoms,'
else ''
end,
case fup.pwp_disclosure
when 1065 then 'Disclosure|'
else ''
end,
case fup.pwp_partner_tested
when 1065 then 'Partner Testing|'
else ''
end,
case fup.screened_for_sti
when 1065 then 'Screened for STI'
else ''
end )as PWP,
if(fup.last_menstrual_period is not null, timestampdiff(week,fup.last_menstrual_period,fup.visit_date),'') as GestationAge,
case when fup.next_appointment_date < '1990-01-01' then null else CAST(fup.next_appointment_date AS DATE) end  AS NextAppointmentDate,
'KenyaEMR' as Emr,
'Kenya HMIS II' as Project,

CAST(fup.substitution_first_line_regimen_date AS DATE)  AS SubstitutionFirstlineRegimenDate,
fup.substitution_first_line_regimen_reason AS SubstitutionFirstlineRegimenReason,
CAST(fup.substitution_second_line_regimen_date AS DATE) AS SubstitutionSecondlineRegimenDate,
fup.substitution_second_line_regimen_reason AS SubstitutionSecondlineRegimenReason,
CAST(fup.second_line_regimen_change_date AS DATE) AS SecondlineRegimenChangeDate,
fup.second_line_regimen_change_reason AS SecondlineRegimenChangeReason,

 
 CASE fup.stability 
 WHEN 1 THEN 'Stable' 
 WHEN 2 THEN 'Not Stable' END as StabilityAssessment,  
 
dc.name as DifferentiatedCare, 
CASE 
               WHEN fup.key_population_type  IS NOT NULL AND fup.key_population_type  !=1175
               THEN 'Key population'
    ELSE pt.name  END as PopulationType,
    
case fup.key_population_type 
WHEN 105 THEN 'PWID'
WHEN 160578 THEN 'MSM'
WHEN 160579  THEN 'FSW' 
WHEN 1175 THEN 'N/A'
ELSE fup.key_population_type  END as KeyPopulationType 

from kenyaemr_etl.etl_patient_demographics d
join kenyaemr_etl.etl_patient_hiv_followup fup on fup.patient_id=d.patient_id
left join openmrs.concept_name dc on dc.concept_id =  fup.differentiated_care and dc.concept_name_type='FULLY_SPECIFIED'
left join openmrs.concept_name pt on fup.population_type = pt.concept_id AND pt.concept_name_type='FULLY_SPECIFIED'
where d.unique_patient_no is not null and fup.visit_date > '1990-01-01'  