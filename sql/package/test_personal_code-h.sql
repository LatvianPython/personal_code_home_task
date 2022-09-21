CREATE OR REPLACE PACKAGE test_personal_code AS

  --%suite(Personal code validation, parsing)

  --%test(Check if Latvian personal code is valid/invalid)
  PROCEDURE personal_code_validity_latvia;

  --%test(Check if Estonian personal code is valid/invalid)
  PROCEDURE personal_code_validity_estonia;

  --%test(Check if Lithuanian personal code is valid/invalid)
  PROCEDURE personal_code_validity_lithuania;

END;
/
