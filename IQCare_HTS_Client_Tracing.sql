select distinct a.PatientPK, a.SiteCode, a. TracingType, a.TracingDate, 
a.FacilityName,a.Emr,a.Project, a.HTSNumber AS HtsNumber, a.TracingOutcome from (select h.PatientPK,
tp.SiteCode, 
TracingType = (Select TOP 1 ItemName From LookupItemView WHERE ItemId = tr.Mode),
DateTracingDone as TracingDate,
FacilityName,
'IQCare' as Emr,
'Kenya HMIS II' as Project,
tp.HTSID as HTSNumber,
Tpe = (Select TOP 1 ItemName From LookupItemView WHERE ItemId = tr.TracingType),
TracingOutcome = (Select Top 1 ItemName From LookupItemView WHERE ItemId = tr.Outcome)
from tmp_HTS_LAB_register h
inner join tmp_PatientMaster tp on tp.PatientPK =h.Patientpk 
inner join patient pt on pt.ptn_pk=h.Patientpk
inner join Tracing tr on tr.personid=pt.id) a
where a.Tpe='Enrolment'