select distinct
 '' AS Provider,'' AS SatelliteName, 0 AS FacilityId, d.unique_patient_no as PatientID,
d.patient_id as PatientPK,
(select name from location
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation')) as FacilityName,
(select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
ph.visit_id as VisitID,
-- if(cn2.name is not null, cn2.name,cn.name) as Drug,
case 
	when is_arv=1 then drg.drugreg 
	else if(cn2.name is not null, cn2.name,cn.name) END  as Drug,
ph.visit_date as DispenseDate,
duration,
duration as PeriodTaken,
fup.next_appointment_date as ExpectedReturn,
 'KenyaEMR' as Emr,
 'Kenya HMIS II' as Project,
 CASE WHEN is_arv=1 THEN 'ARV'
	  WHEN is_ctx=1 OR is_dapsone= 1 THEN 'Prophylaxis' END AS TreatmentType,
 '' AS RegimenLine,
 CASE WHEN is_ctx=1 THEN 'CTX'
	  WHEN is_dapsone =1  THEN 'DAPSON' END AS ProphylaxisType,
CAST(now() as Date) AS DateExtracted
from kenyaemr_etl.etl_pharmacy_extract ph
left join 
(select  patient_id, visit_id,visit_date,encounter_id,
replace(replace(replace(group_concat(cn2.name SEPARATOR '/'),'/','+'),'LPV+R','LPV/R'),'ATV+R','ATV/R') as drugreg from kenyaemr_etl.etl_pharmacy_extract  ph
left outer join concept_name cn2 on cn2.concept_id=ph.drug  and cn2.concept_name_type='SHORT'
and cn2.locale='en' where is_arv = '1'
GROUP BY patient_id, visit_id,visit_date,encounter_id) drg ON drg.patient_id=ph.patient_id AND drg.visit_id=ph.visit_id AND drg.visit_date=ph.visit_date AND drg.encounter_id =ph.encounter_id
join kenyaemr_etl.etl_patient_demographics d on d.patient_id=ph.patient_id
left outer join concept_name cn on cn.concept_id=ph.drug  and cn.concept_name_type='FULLY_SPECIFIED'
and cn.locale='en'
left outer join concept_name cn2 on cn2.concept_id=ph.drug  and cn2.concept_name_type='SHORT'
and cn.locale='en'
left outer join kenyaemr_etl.etl_patient_hiv_followup fup on fup.encounter_id=ph.encounter_id
and fup.patient_id=ph.patient_id
where unique_patient_no is not null  and (is_arv=1 OR is_ctx=1 OR is_dapsone =1 )
group by  ph.patient_id,ph.visit_date,ph.visit_id
order by ph.patient_id,ph.visit_date;