CREATE OR REPLACE PACKAGE test_personal_code AS

  --%suite(Personal code validation, parsing)

  --%test(Check if Latvian personal code is valid/invalid)
  PROCEDURE personal_code_validity_latvia;

  --%test(Check if Estonian personal code is valid/invalid)
  PROCEDURE personal_code_validity_estonia;

  --%test(Check if Lithuanian personal code is valid/invalid)
  PROCEDURE personal_code_validity_lithuania;

  --%test(Check if can extract gender from personal codes)
  PROCEDURE personal_code_gender_parsing;

  --%test(Check if can extract birth date from personal codes)
  PROCEDURE personal_code_date_parsing;

END;
/
