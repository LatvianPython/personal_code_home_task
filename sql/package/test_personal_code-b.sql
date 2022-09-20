CREATE OR REPLACE PACKAGE BODY test_personal_code AS

  PROCEDURE is_personal_code_valid IS
  BEGIN
    ut.expect(personal_code.parse_personal_code('181192-14950', 'LV').is_valid).to_equal(TRUE);
    ut.expect(personal_code.parse_personal_code('181192-14951', 'LV').is_valid).to_equal(FALSE);
  END is_personal_code_valid;

END;
/
