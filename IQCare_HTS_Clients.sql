select distinct h.PatientPk,
SiteCode,
FacilityName,
'IQCare' as Emr,
'Kenya HMIS II' as Project,
HTSID as HtsNumber  ,
h.DOB as Dob,
h.Gender,
h.MaritalStatus,
case when ltrim(h.KeyPop) in ('SW','PWID','MSM','Other','MSW','FSW') then 'Key Population' else 'General Population' end as PopulationType,
ltrim(h.KeyPop)  as KeyPopulationType,
Disability as PatientDisabled,
County,
SubCounty,
Ward from  tmp_HTS_LAB_register h inner join tmp_PatientMaster p
on h.PatientPK=p.PatientPK
order by KeyPopulationType