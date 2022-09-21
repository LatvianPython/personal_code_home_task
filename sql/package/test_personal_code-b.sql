CREATE OR REPLACE PACKAGE BODY test_personal_code AS

  PROCEDURE personal_code_validity_latvia IS
    TYPE vr_expectation IS RECORD (personal_code VARCHAR2(20), expectation BOOLEAN, message VARCHAR2(100));
    TYPE tt_expectations IS TABLE OF vr_expectation INDEX BY PLS_INTEGER;
    vt_expectations tt_expectations;
  BEGIN
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('32123456789', TRUE, 'new format');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-14950', TRUE, 'correct personal code');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('18119214950', TRUE, 'existence of hyphen should not matter all good');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('18119214-950', FALSE, 'hyphen in wrong place');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-149i50', FALSE, 'not all digits');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-1495066', FALSE, 'too many digits');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('18119261495066', FALSE, 'too many digits');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-149', FALSE, 'too few digits');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192149', FALSE, 'too few digits');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('501192-14950', FALSE, 'wrong date');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181492-14950', FALSE, 'wrong date');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-14951', FALSE, 'wrong checksum');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-64958', TRUE, '1. not a valid date, incorrect century, check only checksum');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('181192-44957', TRUE, '2. not a valid date, incorrect century, check only checksum');
    --tests from "valsts informācijas sistēmu savietotājs" (VISS) recommendations
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('123123-12345', FALSE, 'VISS.1');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('320000-00001', TRUE, 'VISS.2');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('32000000001', TRUE,  'VISS.3');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('330000-00001', TRUE, 'VISS.4');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('390000-00001', TRUE, 'VISS.5');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('420000-00001', FALSE, 'VISS.6');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('520000-00001', FALSE, 'VISS.7');
    vt_expectations(vt_expectations.COUNT + 1) := vr_expectation('350000-00001', TRUE, 'VISS.8');

    FOR v_i IN 1 .. vt_expectations.COUNT LOOP
      ut.expect(
        personal_code.parse_personal_code(vt_expectations(v_i).personal_code, 'LV').is_valid,
        v_i || ';' || vt_expectations(v_i).personal_code || ';' || vt_expectations(v_i).message
      ).to_equal(vt_expectations(v_i).expectation);
    END LOOP;

  END;

  PROCEDURE personal_code_validity_estonia IS
  BEGIN
    ut.expect(personal_code.parse_personal_code('37605030299', 'EE').is_valid).to_equal(TRUE);
  END;

  PROCEDURE personal_code_validity_lithuania IS
  BEGIN
    raise_application_error(-20001, 'write tests');--todo
  END;

END;
/
