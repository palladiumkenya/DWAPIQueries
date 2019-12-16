SELECT
 pm.PatientID, ls.PatientPK, pm.SiteCode, 
 pm.FacilityName, pm.FacilityID as FacilityId, 
 '' AS ExitDescription, 
 MAX(ls.ExitDate) AS ExitDate, 
 (SELECT TOP 1 ExitReason from tmp_LastStatus S 
	WHERE S.PatientPK=ls.PatientPK AND ExitDate= MAX(ls.ExitDate)) AS ExitReason,
 CAST(GETDATE() AS DATE) AS DateExtracted, 'IQCare' AS EMR, 'Kenya HMIS II' AS Project
FROM
 tmp_LastStatus ls
 INNER JOIN
 tmp_PatientMaster pm ON ls.PatientPK = pm.PatientPK 
 where pm.RegistrationAtCCC is not null
 GROUP BY  pm.PatientID, ls.PatientPK, pm.SiteCode, pm.FacilityName, pm.FacilityID 
 order by PatientPK