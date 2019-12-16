select '' AS SatelliteName, 0 AS FacilityId, d.DOB,
       d.Gender, '' AS Provider,
       d.unique_patient_no as PatientID,
       d.patient_id as PatientPK,
       timestampdiff(year,d.DOB, hiv.visit_date) as AgeEnrollment,
       timestampdiff(year,d.DOB, reg.art_start_date) as AgeARTStart,
       timestampdiff(year,d.DOB, reg.latest_vis_date) as AgeLastVisit,
       (select value_reference from location_attribute
        where location_id in (select property_value
                              from global_property
                              where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
       (select name from location
        where location_id in (select property_value
                              from global_property
                              where property='kenyaemr.defaultLocation')) as FacilityName,
       CAST(coalesce(date_first_enrolled_in_care,min(hiv.visit_date)) as Date) as RegistrationDate,
       case  max(hiv.entry_point)
         when 160542 then 'OPD'
         when 160563 then 'Other'
         when 160539 then 'VCT'
         when 160538 then 'PMTCT'
         when 160541 then 'TB'
         when 160536 then 'IPD - Adult'
         else cn.name
           end as PatientSource,
       reg.art_start_date as StartARTDate,
       hiv.date_started_art_at_transferring_facility as PreviousARTStartDate,
       '' as PreviousARTRegimen,
       reg.art_start_date as StartARTAtThisFacility,
       reg.regimen as StartRegimen,
       reg.regimen_line as StartRegimenLine,
      -- reg.last_art_date as LastARTDate,
	   case 
		when reg.latest_vis_date is not null then reg.latest_vis_date else  reg.last_art_date end as LastARTDate,
     
       reg.last_regimen as LastRegimen,
       reg.last_regimen_line as LastRegimenLine,
       reg.latest_tca as ExpectedReturn,
       reg.latest_vis_date as LastVisit ,
       timestampdiff(month,reg.art_start_date, reg.latest_vis_date) as duration,
       disc.visit_date as ExitDate,
       case
         when disc.discontinuation_reason is not null then dis_rsn.name
         else '' end as ExitReason,
       'KenyaEMR' as Emr,
       'Kenya HMIS II' as Project,
       CAST(now() as Date) AS DateExtracted
from kenyaemr_etl.etl_hiv_enrollment hiv
       join kenyaemr_etl.etl_patient_demographics d on d.patient_id=hiv.patient_id
       left outer join  kenyaemr_etl.etl_patient_program_discontinuation disc on disc.patient_id=hiv.patient_id
       left outer join (select e.patient_id,
                               if(enr.date_started_art_at_transferring_facility is not null,enr.date_started_art_at_transferring_facility,
                                  e.date_started)as art_start_date, e.date_started, e.gender,e.dob,d.visit_date as dis_date, if(d.visit_date is not null, 1, 0) as TOut,
                               e.regimen, e.regimen_line, e.alternative_regimen, max(fup.next_appointment_date) as latest_tca,
                               last_art_date,last_regimen,last_regimen_line,
                               if(enr.transfer_in_date is not null, 1, 0) as TIn, max(fup.visit_date) as  latest_vis_date
                        from (select e.patient_id,p.dob,p.Gender,min(e.date_started) as date_started,
                                     max(e.date_started) as last_art_date,
                                     mid(min(concat(e.date_started,e.regimen_name)),11) as regimen,
                                     mid(min(concat(e.date_started,e.regimen_line)),11) as regimen_line,
                                     mid(max(concat(e.date_started,e.regimen_name)),11) as last_regimen,
                                     mid(max(concat(e.date_started,e.regimen_line)),11) as last_regimen_line,
                                     max(if(discontinued,1,0))as alternative_regimen
                              from kenyaemr_etl.etl_drug_event e
                                     join kenyaemr_etl.etl_patient_demographics p on p.patient_id=e.patient_id
                                     left join  kenyaemr_etl.etl_pharmacy_extract ph on ph.patient_id = e.patient_id and is_arv=1
                              group by e.patient_id) e
                               left outer join kenyaemr_etl.etl_patient_program_discontinuation d on d.patient_id=e.patient_id
                               left outer join kenyaemr_etl.etl_hiv_enrollment enr on enr.patient_id=e.patient_id
                               left outer join kenyaemr_etl.etl_patient_hiv_followup fup on fup.patient_id=e.patient_id
                        group by e.patient_id)reg on reg.patient_id=hiv.patient_id
       left outer join concept_name dis_rsn on dis_rsn.concept_id=disc.discontinuation_reason  and dis_rsn.concept_name_type='FULLY_SPECIFIED'
                                                 and dis_rsn.locale='en'
       left outer join concept_name cn on cn.concept_id=hiv.entry_point  and cn.concept_name_type='FULLY_SPECIFIED'
                                            and cn.locale='en'
where d.unique_patient_no is not null
group by d.patient_id
having min(hiv.visit_date) is not null and reg.art_start_date is not null;