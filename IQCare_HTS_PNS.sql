SELECT distinct pns.ptn_pk as PatientPK,a.SiteCode,a.FacilityName,
'IQCare' as Emr, 'Kenya HMIS II' as Project,HTS_Number as HtsNumber, pd.PatientPK as PartnerPatientPk,pns.personid as PartnerPersonID,
pns.AgeYears as Age, pns.PNSSex as Sex, RelationsipToIndexClient, ScreenedForIPV as ScreenedForIpv, 
IPVScreeningOutcome as IpvScreeningOutcome, CurrentlyLivingWithIndexClient, KnowledgeOfHIVStatus as KnowledgeOfHivStatus, 
PNSApproach as PnsApproach , PNSConsent as PnsConsent, Linked as LinkedToCare, b.dateEnrolled as LinkDateLinkedToCare,
b.CCCNumber as CccNumber, b.FacilityEnrolled as FacilityLinkedTo, pd.dateofbirth as Dob, 
pns.Date as DateElicited, 
pns.MaritalStatus
  FROM  tmp_PNS_Register pns 
    INNER JOIN dbo.tmp_HTS_LAB_register AS c ON pns.Ptn_pk = c.PatientPK
	INNER JOIN tmp_PatientMaster AS a ON pns.Ptn_pk = a.PatientPK
	LEFT JOIN dbo.tmp_HTS_LAB_register AS pc ON pns.PersonID = pc.PersonID
    LEFT JOIN tmp_Referral_Linkage_Register b ON pc.PatientPK = b.ptn_pk

    LEFT JOIN tmp_PersonDetails pd ON pd.PersonID = pns.personid
  WHERE c.finalResultHTS = 'Positive' AND pns.personid IS NOT NULL