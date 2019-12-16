SELECT
 pm.PatientID, pm.FacilityID, pm.SiteCode, 
 ph.PatientPK, ph.VisitID, 
  CASE WHEN ph.TreatmentType='ART'
 THEN  REPLACE(REPLACE(REPLACE ( ph.Drug,'/', '+'),'LPV+r','LPV/r'), 'ATV+r','ATV/r') 
 ELSE ph.Drug END as drug, ph.Provider,
 ph.DispenseDate, ph.Duration, ph.ExpectedReturn, ph.TreatmentType, ph.RegimenLine, ph.PeriodTaken,
  ph.ProphylaxisType, CAST(GETDATE() AS DATE) AS DateExtracted
 , 'IQCare' AS EMR, 'Kenya HMIS II' AS Project
FROM
 tmp_Pharmacy Ph 
 INNER JOIN
    tmp_PatientMaster pm ON ph.PatientPK = pm.PatientPK where pm.RegistrationAtCCC is not null