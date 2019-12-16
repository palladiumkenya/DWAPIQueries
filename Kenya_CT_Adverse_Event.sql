SELECT adv.PatientID,
       adv.PatientPK,
       adv.SiteCode,
	   p.FacilityID,
       'IQCare' AS EMR,
       'Kenya HMIS II' AS Project,
       adv.VisitDate,
       adv.Regimen AS AdverseEventRegimen,
       adv.AdverseEvent,
       adv.AdverseEventCause,
       adv.Severity,
       adv.ActionTaken AS AdverseEventActionTaken,
       adv.ClinicalOutcome AS AdverseEventClinicalOutcome,
	   adv.VisitDate AS AdverseEventStartDate,
       adv.AdverseEventEndDate,
       adv.Pregnancy AS AdverseEventIsPregnant
FROM IQC_AdverseEvents adv
     INNER JOIN tmp_PatientMaster p ON adv.PatientPK = p.PatientPK where p.RegistrationAtCCC is not null