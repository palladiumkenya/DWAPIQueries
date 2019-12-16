SELECT

 a.PatientPK, a.PatientID, c.FacilityID, c.SiteCode, 
 a.FacilityName, a.DOB, a.AgeEnrollment, a.AgeARTStart, 
 a.AgeLastVisit, a.RegistrationDate, a.PatientSource, a.Gender, a.StartARTDate, a.PreviousARTStartDate,
  REPLACE(REPLACE(REPLACE (a.PreviousARTRegimen,'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') AS PreviousARTRegimen,
  a.StartARTAtThisFacility, 
 REPLACE(REPLACE(REPLACE (a.StartRegimen,'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') AS StartRegimen,
  a.StartRegimenLine, a.LastARTDate, 
  REPLACE(REPLACE(REPLACE (a.LastRegimen,'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') AS LastRegimen,
   a.LastRegimenLine, a.Duration, a.ExpectedReturn, a.Provider, a.LastVisit, a.ExitReason,

 a.ExitDate, CAST(GETDATE() AS DATE) AS DateExtracted
 , 'IQCare' AS EMR, 'Kenya HMIS II' AS Project

FROM
 tmp_ARTPatients AS a 
 INNER JOIN
 tmp_PatientMaster AS c ON a.PatientPK = c.PatientPK where c.RegistrationAtCCC is not null