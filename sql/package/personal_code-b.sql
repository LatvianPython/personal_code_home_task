CREATE OR REPLACE PACKAGE BODY personal_code AS

  e_incorrect_day EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_incorrect_day, -1847);

  e_incorrect_month EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_incorrect_month, -1843);

  FUNCTION parse_lv_code(p_personal_code IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
    v_birth_date DATE;
    v_personal_code VARCHAR2(11);
    v_checksum INTEGER := 0;
    v_century INTEGER;
  BEGIN
    IF regexp_like(p_personal_code, '^3[2-9]\d{4}-?\d{5}$') THEN
      vr_result.is_valid := TRUE; -- new personal code format
    ELSIF regexp_like(p_personal_code, '^[0-9]{6}-?[0-9]{5}$') THEN
      v_personal_code := regexp_replace(p_personal_code, '\D');

      v_century := TO_NUMBER(SUBSTR(v_personal_code, 7, 1));

      IF v_century IN (0, 1, 2) THEN
        BEGIN
          v_birth_date := TO_DATE(SUBSTR(v_personal_code, 1, 2) ||
                                  SUBSTR(v_personal_code, 3, 2)  ||
                                  (TO_NUMBER(SUBSTR(v_personal_code, 5, 2)) + 1800 + 100 * v_century),
                                  'ddmmyyyy');
        EXCEPTION
          WHEN e_incorrect_day OR e_incorrect_month THEN
            vr_result.is_valid := FALSE;
            RETURN vr_result;
        END;
      ELSE
        NULL;--not a valid date in first part, check only with checksum for validity
      END IF;

      FOR v_i IN 1 .. 10 LOOP
        v_checksum := v_checksum + ((TO_NUMBER(SUBSTR('9473105268', v_i, 1)) + 1) * TO_NUMBER(SUBSTR(v_personal_code, v_i, 1)));
      END LOOP;
      v_checksum := MOD(MOD(v_checksum + 1, 11), 10);

      vr_result.is_valid := v_checksum = SUBSTR(v_personal_code, -1, 1);
    ELSE
      vr_result.is_valid := FALSE;
    END IF;

    RETURN vr_result;
  END parse_lv_code;

  FUNCTION parse_personal_code(p_personal_code IN VARCHAR2,
                               p_country       IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
  BEGIN
    CASE p_country
    WHEN 'LV' THEN
      vr_result := parse_lv_code(p_personal_code);
    ELSE
      vr_result.is_valid := FALSE;
    END CASE;

    RETURN vr_result;
  END;

END;
/
