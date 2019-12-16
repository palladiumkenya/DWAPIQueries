SELECT DISTINCT
-- -----Demographics
X.Ptn_Pk,
X.PatientPK,
siteCode,
FacilityName,
-- a.patient_clinic_number AS Serial
-- X.Ptn_Pk AS Serial
X.Serial
,FirstName
, MiddleName
,LastName
, FirstName_Normalized
, MiddleName_Normalized
,LastName_Normalized
,sxFirstName
,sxLastName
,sxMiddleName
,dmFirstName
, dmLastName
, dmMiddleName
, PatientPhoneNumber
, PatientAlternatePhoneNumber
,Gender
,DOB
,MaritalStatus
-- -----Patient Address
, PatientSource
, PatientCounty
, PatientSubCounty
, PatientVillage
-- -----Patient-Identifiers
,PatientID
,National_ID
,NHIF_Number
,Birth_Certificate
,CCC_Number
,TB_Number
-- -----Next Of Kin
,ContactName
,ContactRelation
, ContactPhoneNumber
,ContactAddress
, NokNationalId
-- -----Additional Variables
, DateConfirmedHIVPositive
,StartARTDate
,StartARTRegimenCode
, StartARTRegimenDesc,
CONCAT(LEFT(Gender ,1), sxFirstName ,sxLastName ,LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y')))) AS sxPKValue,
CONCAT( CAST(LEFT(Gender ,1) AS CHAR CHARACTER SET utf8),
CAST(CASE
WHEN locate(';',dmFirstName )>0 THEN
SUBSTRING(dmFirstName , locate(';',dmFirstName )+1,LENGTH(dmFirstName ))
ELSE
dmFirstName
END AS CHAR CHARACTER SET utf8),
CAST(CASE
WHEN locate(';',dmLastName )>0 THEN
SUBSTRING(dmLastName , locate(';',dmLastName )+1,LENGTH(dmLastName ))
ELSE
dmLastName
END AS CHAR CHARACTER SET utf8),
CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y')))AS CHAR CHARACTER SET utf8)

) AS dmPKValue ,

CASE WHEN locate(';',dmLastName )>0
THEN
CONCAT(
CAST(LEFT(Gender ,1) AS CHAR CHARACTER SET utf8)
, CAST(sxFirstName AS CHAR CHARACTER SET utf8)
, CAST(SUBSTRING(dmLastName , locate(';',dmLastName )+1,LENGTH(dmLastName )) AS CHAR CHARACTER SET utf8)
, CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y')))AS CHAR CHARACTER SET utf8)
)
ELSE
CONCAT(
CAST(LEFT(Gender ,1)AS CHAR CHARACTER SET utf8)
, CAST(sxFirstName AS CHAR CHARACTER SET utf8)
, CAST(dmLastName AS CHAR CHARACTER SET utf8)
, CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y'))) AS CHAR CHARACTER SET utf8)
)
END AS sxdmPKValue ,
CONCAT(
CAST(LEFT(Gender ,1) AS CHAR CHARACTER SET utf8)
,CAST(sxFirstName AS CHAR CHARACTER SET utf8)
,CAST(sxLastName AS CHAR CHARACTER SET utf8)
,CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y%m%d')))AS CHAR CHARACTER SET utf8)
) AS sxPKValueDoB ,

CONCAT(

CAST(LEFT(Gender ,1) AS CHAR CHARACTER SET utf8),
CASE
WHEN locate(';',dmFirstName )>0 THEN
CAST(SUBSTRING(dmFirstName , locate(';',dmFirstName )+1,LENGTH(dmFirstName )) AS CHAR CHARACTER SET utf8)
ELSE
CAST(dmFirstName AS CHAR CHARACTER SET utf8)
END ,
CASE
WHEN locate(';',dmLastName )>0 THEN
CAST( SUBSTRING(dmLastName , locate(';',dmLastName )+1,LENGTH(dmLastName )) AS CHAR CHARACTER SET utf8)
ELSE
CAST( dmLastName AS CHAR CHARACTER SET utf8)
END ,

CAST( LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y%m%d'))) AS CHAR CHARACTER SET utf8)
) AS dmPKValueDoB ,

CASE WHEN locate(';',dmLastName )>0 THEN
CONCAT(
CAST( LEFT(Gender ,1) AS CHAR CHARACTER SET utf8)
,CAST( sxFirstName AS CHAR CHARACTER SET utf8)
, CAST( SUBSTRING(dmLastName ,locate(';',dmLastName )+1,LENGTH(dmLastName )) AS CHAR CHARACTER SET utf8)
,CAST( LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y%m%d'))) AS CHAR CHARACTER SET utf8)
)
ELSE
CONCAT(
CAST( LEFT(Gender ,1)AS CHAR CHARACTER SET utf8)
, CAST( sxFirstName AS CHAR CHARACTER SET utf8),
CAST( dmLastName AS CHAR CHARACTER SET utf8),
CAST( LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y%m%d'))) AS CHAR CHARACTER SET utf8)
)
END AS sxdmPKValueDoB
FROM
(
SELECT
-- -----Demographics
a.patient_id as Ptn_Pk,
a.patient_id as PatientPK,
(select value_reference from openmrs.location_attribute
where location_id in (select property_value
from openmrs.global_property
where property='kenyaemr.defaultLocation') and attribute_type_id=1) as siteCode,

(select name from openmrs.location
where location_id in (select property_value
from openmrs.global_property
where property='kenyaemr.defaultLocation')) as FacilityName,
id.identifier AS Serial
-- a.patient_clinic_number AS Serial

,UPPER(a.given_name ) as FirstName
,UPPER(a.middle_name ) as MiddleName
,UPPER(family_name) as LastName
,UPPER(REPLACE(given_name ,'0','O')) AS FirstName_Normalized
,UPPER(REPLACE(middle_name ,'0','O')) AS MiddleName_Normalized
,UPPER(REPLACE(family_name ,'0','O')) AS LastName_Normalized
,SOUNDEX(UPPER(REPLACE(given_name ,'0','O'))) AS sxFirstName
,SOUNDEX(UPPER(REPLACE(family_name ,'0','O'))) AS sxLastName
,SOUNDEX(UPPER(REPLACE(middle_name ,'0','O'))) AS sxMiddleName
, openmrs.fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(given_name ,'0','O'))) AS dmFirstName
, openmrs.fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(family_name ,'0','O'))) AS dmLastName
, openmrs.fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(middle_name ,'0','O'))) AS dmMiddleName
,a.phone_number AS PatientPhoneNumber
,en.treatment_supporter_telephone AS PatientAlternatePhoneNumber
,a.Gender
,a.DOB
,a.marital_status AS MaritalStatus
-- -----Patient Address
, en.entry_point AS PatientSource 
,NULL PatientCounty
,NULL PatientSubCounty
,NULL PatientVillage
-- -----Patient-Identifiers
,patient_clinic_number AS PatientID
,national_id_no AS National_ID
,NULL as NHIF_Number
,NULL as Birth_Certificate
,a.patient_clinic_number AS CCC_Number
,ltrim(rtrim(a.district_reg_no))TB_Number
-- -----Next Of Kin
,LTRIM(RTRIM(next_of_kin)) AS ContactName
,next_of_kin_relationship AS ContactRelation
,treatment_supporter_telephone as ContactPhoneNumber
,treatment_supporter_address as ContactAddress
,NULL AS NokNationalId
-- -----Additional Variables
,date_confirmed_hiv_positive AS DateConfirmedHIVPositive
,X.date_started AS StartARTDate
,X.regimen_name AS StartARTRegimenCode
,X.regimen_line StartARTRegimenDesc

FROM kenyaemr_datatools.patient_demographics a
INNER JOIN openmrs.patient_identifier id ON a.patient_id = id.patient_id AND id.identifier_type = 6 
inner join (
SELECT  c.patient_id,
c.encounter_id, treatment_supporter_telephone, entry_point , treatment_supporter_address, date_confirmed_hiv_positive 
from kenyaemr_datatools.hiv_enrollment  c
INNER JOIN
    (
        SELECT patient_id, MAX(encounter_id) max_encounter_id
        FROM kenyaemr_datatools.hiv_enrollment
        GROUP BY patient_id
    ) b ON c.patient_id = b.patient_id AND
            c.encounter_id = b.max_encounter_id

  order by patient_id,date_created asc 


 ) en
on a.Patient_Id=en.patient_id
LEFT JOIN
(
SELECT patient_id, MIN(date_started) AS date_started ,MIN(regimen_name) AS regimen_name, MIN(regimen_line) AS regimen_line
FROM kenyaemr_datatools.drug_event GROUP BY patient_id
) X ON X.patient_id = a.Patient_id
) X
INNER JOIN
(
SELECT
a.patient_id as Ptn_Pk,
id.identifier AS Serial
FROM kenyaemr_datatools.patient_demographics a
INNER JOIN openmrs.patient_identifier id ON a.patient_id = id.patient_id AND id.identifier_type = 6 

)Y
ON
Y.Ptn_Pk = X.Ptn_Pk AND Y.Serial= X.Serial