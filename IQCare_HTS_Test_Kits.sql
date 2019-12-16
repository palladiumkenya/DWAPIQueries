select distinct p.PatientPK,
SiteCode,
p.FacilityName,
'IQCare' as Emr,
'Kenya HMIS II' as Project,
p.HTSID as HtsNumber,
HTSEncounterId as EncounterId,
TestKitName1,
TestKitLotNumber1,
TestKitExpiryDate1 as TestKitExpiry1,
TestResultsHTS1 as TestResult1,
TestKitName_2 as TestKitName2,
TestKitLotNumber_2 as TestKitLotNumber2,
TestKitExpiryDate_2 as TestKitExpiry2, 
TestResultsHTS_2 as TestResult2 
from tmp_HTS_LAB_register h inner join tmp_PatientMaster p
on h.PatientPK=p.PatientPK