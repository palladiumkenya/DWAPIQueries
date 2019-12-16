select distinct '' AS SatelliteName, 0 AS FacilityId, d.unique_patient_no as PatientID,
d.patient_id as PatientPK,
(select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as facilityId,
(select value_reference from location_attribute
where location_id in (select property_value
from global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
 mid(max(if(l.visit_date<=p_dates.enrollment_date,concat(l.visit_date,test_result),null)),11) as eCd4,
 CAST(left(max(if(l.visit_date<=p_dates.enrollment_date,concat(l.visit_date,test_result),null)),10) AS DATE) as eCd4Date,
 if(fup.visit_date<=p_dates.enrollment_date,
 case who_stage
 when 1220 then 'WHO I'
 when 1221 then 'WHO II'
 when 1222 then 'WHO III'
 when 1223 then 'WHO IV'
 when 1204 then 'WHO I'
 when 1205 then 'WHO II'
 when 1206 then 'WHO III'
 when 1207 then 'WHO IV'
 end,null) as ewho,
 CAST(if(fup.visit_date<=p_dates.enrollment_date and who_stage is not null and fup.visit_date>'1900-01-01',
fup.visit_date,null) AS DATE) as ewhodate,
'' as bCD4,
NULL as bCD4Date,
'' as bWHO,
NULL as bWHODate,
 mid(max(concat(fup.visit_date,case who_stage
 when 1220 then 'WHO I'
 when 1221 then 'WHO II'
 when 1222 then 'WHO III'
 when 1223 then 'WHO IV'
 when 1204 then 'WHO I'
 when 1205 then 'WHO II'
 when 1206 then 'WHO III'
 when 1207 then 'WHO IV'
 end)),11) as lastwho,
 CAST(left(max(concat(fup.visit_date,case who_stage
 when 1220 then 'WHO I'
 when 1221 then 'WHO II'
 when 1222 then 'WHO III'
 when 1223 then 'WHO IV'
 when 1204 then 'WHO I'
 when 1205 then 'WHO II'
 when 1206 then 'WHO III'
 when 1207 then 'WHO IV'
 end)),10) AS DATE) as lastwhodate,
  mid(max(concat(l.visit_date,l.test_result)),11) as lastcd4,
 CAST(left(max(concat(l.visit_date,l.test_result)),10) AS DATE) as lastcd4date,
 mid(max(if(l.visit_date>p_dates.six_month_date and l.visit_date<p_dates.twelve_month_date ,concat(l.visit_date,test_result),null)),11) as m6Cd4,
 CAST(left(max(if(l.visit_date>=p_dates.six_month_date and l.visit_date<p_dates.twelve_month_date ,concat(l.visit_date,test_result),null)),10) AS DATE) as m6Cd4Date,
 mid(max(if(l.visit_date>=p_dates.twelve_month_date,concat(l.visit_date,test_result),null)),11) as m6Cd4,
 CAST(left(max(if(l.visit_date>p_dates.twelve_month_date,concat(l.visit_date,test_result),null)),10) AS DATE) as m6Cd4Date,
 '' as eWAB, NULL as eWABDate,'' as bWAB, NULL as bWABDAte,
 'KenyaEMR' as Emr,
 'Kenya HMIS II' as Project,
 '' AS LastWaB,NULL AS LastWABDate,
 '' as m12CD4,
NULL as m12CD4Date,
'' AS m6CD4,
NULL m6CD4Date
from kenyaemr_etl.etl_patient_hiv_followup fup
join kenyaemr_etl.etl_patient_demographics d on d.patient_id=fup.patient_id
join (select e.patient_id,date_add(date_add(min(e.visit_date),interval 3 month), interval 1 day) as enrollment_date,
date_add(date_add(min(e.visit_date), interval 6 month),interval 1 day) as six_month_date,
date_add(date_add(min(e.visit_date), interval 12 month),interval 1 day) as twelve_month_date
from kenyaemr_etl.etl_hiv_enrollment e
group by e.patient_id) p_dates on p_dates.patient_id=fup.patient_id
left outer join kenyaemr_etl.etl_laboratory_extract l on l.patient_id=fup.patient_id and l.lab_test in (5497,730) where d.unique_patient_no is not null
group by fup.patient_id
order by m6cd4date desc