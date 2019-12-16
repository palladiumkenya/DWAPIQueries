SELECT distinct r.ptn_pk as PatientPK,SiteCode,
p.FacilityName,
'IQCare' as Emr,
'Kenya HMIS II' as Project,
p.HTSID as HtsNumber,
ref.referraldate as DatePrefferedToBeEnrolled,
case when ref.tofacility=99999 then 'Other Facility'else (
select name from FacilityList where MFLCode=ref.tofacility ) end as FacilityReferredTo,
HandedOverTo,
HandedOverToCadre,
r.FacilityEnrolled as EnrolledFacilityName,
ref.createdate as ReferralDate,
dateEnrolled as DateEnrolled,
r.CCCNumber as ReportedCCCNumber,
r.ArtStartDate as ReportedStartARTDate
  FROM tmp_Referral_Linkage_Register r 
  inner join tmp_PatientMaster p on r.ptn_pk=p.PatientPK
  inner join tmp_HTS_LAB_register plab on r.ptn_pk=plab.PatientPK
  inner join patient pat on pat.ptn_pk=r.ptn_pk
  left join Referral ref on pat.personid=ref.personid