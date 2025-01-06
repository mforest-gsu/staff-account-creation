SET term OFF
SET feed OFF
SET markup csv ON
SET heading OFF
SPOOL &1
PROMPT  "type","action","username","org_defined_id","first_name","last_name","password","is_active","role_name","email","relationships","pref_first_name","pref_last_name","sort_last_name","pronouns"
SELECT
  'user' AS "type",
  'UPDATE' AS "action",
  SISUSER_CAMPUS_ID AS "username",
  SISUSER_ORG_DEFINED_ID AS "org_defined_id",
  SSOUSER_FIRST_NAME AS "first_name",
  SSOUSER_LAST_NAME AS "last_name",
  NULL AS "password",
  1 AS "is_active",
  CASE
    WHEN SSOUSER_EMAIL_ADDRESS LIKE '%@student.gsu.edu' THEN 'Student'
    WHEN SSOUSER_AFFILIATIONS LIKE '%Faculty%' THEN 'Instructor'
    WHEN SSOUSER_AFFILIATIONS LIKE '%Staff%' THEN 'Staff'
  END AS "role_name",
  SSOUSER_EMAIL_ADDRESS AS "email",
  NULL AS "relationships",
  NULL AS "pref_first_name",
  NULL AS "pref_last_name",
  NULL AS "sort_last_name",
  NULL AS "pronouns"
FROM
  MFOREST.SISUSER,
  MFOREST.SSOUSER SsoUser
WHERE
  SSOUSER_CAMPUS_ID = SISUSER_CAMPUS_ID AND
  SSOUSER_EMAIL_ADDRESS LIKE '%@gsu.edu' AND
  SSOUSER_AFFILIATIONS LIKE '%Staff%' AND
  SSOUSER_AFFILIATIONS NOT LIKE '%Faculty%' AND
  NOT EXISTS (
    SELECT
      1
    FROM
      MFOREST.D2L_USER UserAccount
    WHERE
      UserAccount.UserName = SISUSER_CAMPUS_ID OR
      UserAccount.OrgDefinedId = SISUSER_ORG_DEFINED_ID OR
      UserAccount.SourcedId = SISUSER_SOURCED_ID
  )
;

SPOOL off
QUIT
