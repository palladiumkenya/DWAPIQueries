SELECT
 tmp_PatientMaster.PatientID, tmp_Labs.PatientPK, tmp_PatientMaster.FacilityID, tmp_PatientMaster.SiteCode, tmp_PatientMaster.FacilityName, tmp_PatientMaster.SatelliteName, tmp_Labs.VisitID,
 tmp_Labs.OrderedbyDate, tmp_Labs.ReportedbyDate, tmp_Labs.TestName, tmp_Labs.EnrollmentTest, tmp_Labs.TestResult, tmp_Labs.Reasons as Reason,CAST(GETDATE() AS DATE) AS DateExtracted,
   'IQCare' AS EMR, 'Kenya HMIS II' AS Project
FROM
 tmp_Labs INNER JOIN
 tmp_PatientMaster ON tmp_Labs.PatientPK = tmp_PatientMaster.PatientPK where tmp_PatientMaster.RegistrationAtCCC is not null