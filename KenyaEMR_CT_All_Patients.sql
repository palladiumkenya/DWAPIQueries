select 
CASE WHEN prg.program='TB' THEN prg.status  ELSE null end  AS StatusAtTBClinic, 
CASE WHEN prg.program='PMTCT' THEN prg.status  ELSE null end  AS  StatusAtPMTCT,
CASE WHEN prg.program='HIV' THEN prg.status  ELSE null end  AS   StatusATCCC,

'' AS SatelliteName, 
0 AS FacilityId,d.unique_patient_no as PatientID,
                                 d.patient_id as PatientPK,
                                 (select value_reference from location_attribute
                                  where location_id in (select property_value
                                                        from global_property
                                                        where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,
                                 (select name from location
                                  where location_id in (select property_value
                                                        from global_property
                                                        where property='kenyaemr.defaultLocation')) as FacilityName,
                                 case d.gender when 'M' then 'Male' when 'F' then 'Female' end  as Gender,
                                 d.dob as DOB,
                                 CAST(min(hiv.visit_date) as Date) as RegistrationDate,
                                 CAST(coalesce(date_first_enrolled_in_care,min(hiv.visit_date)) as Date) as RegistrationAtCCC,
                                 CAST(min(mch.visit_date)as Date) as RegistrationATPMTCT,
                                 CAST(min(tb.visit_date)as Date) as RegistrationAtTBClinic,
                                 case  max(hiv.entry_point)
                                   when 160542 then 'OPD'
                                   when 160563 then 'Other'
                                   when 160539 then 'VCT'
                                   when 160538 then 'PMTCT'
                                   when 160541 then 'TB'
                                   when 160536 then 'IPD - Adult'
                                   /*else cn.name*/
                                     end as PatientSource,
								
                                (select state_province from location
                                                           where location_id in (select property_value
                                                                                 from global_property
                                                                                 where property='kenyaemr.defaultLocation')) as Region,
                                 (select county_district from location
                                  where location_id in (select property_value
                                                        from global_property
                                                        where property='kenyaemr.defaultLocation'))as District,
                                 (select address6 from location
                                  where location_id in (select property_value
                                                        from global_property
                                                        where property='kenyaemr.defaultLocation')) as Village,
                                 UPPER(ts.name) as ContactRelation,
                                 CAST(GREATEST(coalesce(max(hiv.visit_date),date('1000-01-01')),coalesce(max(de.visit_date),date('1000-01-01')), coalesce(max(enr.visit_date),date('1000-01-01'))) as Date) as LastVisit,
                                 UPPER(d.marital_status) as MaritalStatus,
                                 UPPER(d.education_level) as EducationLevel,
								 
                                 CAST(min(hiv.date_confirmed_hiv_positive) as Date) as DateConfirmedHIVPositive,
                                 max(hiv.arv_status) as PreviousARTExposure,
                                 NULL as PreviousARTStartDate,
                                 
                                 
                                 'KenyaEMR' as Emr,
                                 'Kenya HMIS II' as Project,
                                 
                               
                                CASE hiv.patient_type 
									WHEN 160563 THEN 'Transfer in'
									WHEN 164144	THEN 'New client'
									WHEN 159833	THEN 'Re-enroll'
                                ELSE hiv.patient_type  
                                END AS PatientType,
                                
       
                                 
                                 (select CASE   
									WHEN f.key_population_type  IS NOT NULL AND f.key_population_type  !=1175
										THEN 'Key population'
									WHEN f.key_population_type  =1175 THEN 'General Population'
									ELSE pt.name  END  from  kenyaemr_etl.etl_patient_hiv_followup f
									left join openmrs.concept_name pt on f.population_type = pt.concept_id AND pt.concept_name_type='FULLY_SPECIFIED'
								WHERE f.encounter_id=min(enr.encounter_id)) AS PopulationType,
                                                                                               
                                 (select 
									case f.key_population_type 
									WHEN 105 THEN 'PWID'
									WHEN 160578 THEN 'MSM'
									WHEN 160579  THEN 'FSW' 
									WHEN 1175 THEN 'N/A'
									ELSE null END 
                                
                                from  kenyaemr_etl.etl_patient_hiv_followup f
								WHERE f.encounter_id=min(enr.encounter_id)) AS KeyPopulationType, 
                                case orp.value_coded when 1 THEN 'Yes' when 2 THEN 'No' ELSE null END as  'Orphan', 
                                case sch.value_coded when 1 THEN 'Yes' when 2 THEN 'No' ELSE null END as 'InSchool', 
								patAd.county_district AS  PatientResidentCounty,  
                                patAd.state_province AS PatientResidentSubCounty,  
                                patAd.address6 AS PatientResidentLocation,   
                                patAd.address5 AS PatientResidentSubLocation,  
                                patAd.address4 AS PatientResidentWard,   
                                patAd.city_village AS PatientResidentVillage,   
                                cast(min(hiv.transfer_in_date) as Date) as TransferInDate 
                               
from kenyaemr_etl.etl_hiv_enrollment hiv
inner join  kenyaemr_etl.etl_patient_demographics d on hiv.patient_id=d.patient_id
left outer join kenyaemr_etl.etl_mch_enrollment mch on mch.patient_id=d.patient_id
left outer join kenyaemr_etl.etl_patient_hiv_followup enr on enr.patient_id=d.patient_id
left outer join kenyaemr_etl.etl_tb_enrollment tb on tb.patient_id=d.patient_id
left outer join kenyaemr_etl.etl_drug_event de on de.patient_id = d.patient_id 
left join openmrs.concept_name ts on ts.concept_id=hiv.relationship_of_treatment_supporter and ts.concept_name_type = 'FULLY_SPECIFIED' and ts.locale='en'    
left join openmrs.person_address patAd ON patAd.person_id=d.patient_id and patAd.voided = 0 
left join (select distinct person_id, value_coded
	from openmrs.obs
    where concept_id=5629 and voided=0) sch on  sch.person_id = d.patient_id 
left join (select distinct person_id, value_coded
	from openmrs.obs
    where concept_id=11704 and voided=0) orp on  sch.person_id = d.patient_id 
left join 
(
	select Patient_Id,   program , 
	if(mid(max(concat(date_enrolled,date_completed)), 20) is null, 'Active', 'Inactive') as status  
	from kenyaemr_etl.etl_patient_program
	group by Patient_Id,program
) as prg on prg.patient_id = d.patient_id 
where unique_patient_no is not null
group by d.patient_id 
order by d.patient_id;