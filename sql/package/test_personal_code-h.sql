CREATE OR REPLACE PACKAGE test_personal_code AS

  --%suite(Personal code validation, parsing)

  --%test(Check if personal code is valid)
  PROCEDURE is_personal_code_valid;

END;
/
