select distinct a.IndexPatientPK as PatientPK, a.HtsNumber, 
a.PartnerPersonId, a. TraceType,a.TraceDate, a.FacilityName,a.Emr,a.Project, a.SiteCode,a.TraceOutcome, a.BookingDate from (select pr.IndexPtn_pk as IndexPatientPK, tp.HTSID as HtsNumber, 
pr.PersonId as PartnerPersonId,
TraceType = (Select TOP 1 ItemName From LookupItemView WHERE ItemId = tr.Mode),
DateTracingDone as TraceDate,
FacilityName,'IQCare' as Emr,'Kenya HMIS II' as Project,tp.SiteCode,
TraceOutcome = (Select Top 1 ItemName From LookupItemView WHERE ItemId = tr.Outcome),
Tpe = (Select TOP 1 ItemName From LookupItemView WHERE ItemId = tr.TracingType), tr.datebookedTesting as BookingDate
from (select pr.PersonId, pat.ptn_pk, ptIndex.ptn_pk as IndexPtn_pk
from PersonRelationship pr 
left join patient ptIndex on ptIndex.id=pr.PatientId
left join patient pat on pat.PersonId=pr.PersonId
where pr.PatientId in (select PatientId 
from PatientIdentifier pid 
inner join Identifiers i on pid.IdentifierTypeId=i.id
where i.Name like '%hts%')) pr 
inner join Tracing tr on tr.personid=pr.PersonId
inner join tmp_PatientMaster tp on tp.PatientPK =pr.IndexPtn_pk ) a
where a.Tpe='Partner'