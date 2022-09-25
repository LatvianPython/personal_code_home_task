CREATE OR REPLACE PACKAGE BODY personal_code AS

  e_incorrect_day EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_incorrect_day, -1847);

  e_incorrect_month EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_incorrect_month, -1843);

  e_invalid_birth_date EXCEPTION;

  TYPE tt_checksum_magic IS TABLE OF INTEGER;

  FUNCTION calculate_checksum(p_personal_code IN VARCHAR2,
                              p_checksum_magic IN tt_checksum_magic)
  RETURN INTEGER IS
    v_checksum INTEGER := 0;
  BEGIN
    FOR v_i IN 1 .. p_checksum_magic.COUNT LOOP
      v_checksum := v_checksum + (p_checksum_magic(v_i) * TO_NUMBER(SUBSTR(p_personal_code, v_i, 1)));
    END LOOP;
    RETURN v_checksum;
  END calculate_checksum;

  FUNCTION parse_birth_date(p_personal_code IN VARCHAR2,
                            p_day_offset IN INTEGER,
                            p_month_offset IN INTEGER,
                            p_year_offset IN INTEGER,
                            p_century_offset IN INTEGER,
                            p_with_gender IN BOOLEAN DEFAULT TRUE,
                            p_ignore_century_error IN BOOLEAN DEFAULT FALSE)
  RETURN DATE IS
    v_result DATE;
    v_century INTEGER;
  BEGIN
    v_century := TO_NUMBER(SUBSTR(p_personal_code, p_century_offset, 1));
    v_century := CASE WHEN p_with_gender THEN v_century / 2 ELSE v_century END;
    IF p_ignore_century_error AND v_century NOT IN (1, 2, 3) THEN
      NULL;
    ELSE
      v_result := TO_DATE(SUBSTR(p_personal_code, p_day_offset, 2) ||
                          SUBSTR(p_personal_code, p_month_offset, 2)  ||
                          (TO_NUMBER(SUBSTR(p_personal_code, p_year_offset, 2)) +
                           1800 + 100 * v_century),
                          'ddmmyyyy');
    END IF;
    RETURN v_result;
  EXCEPTION
    WHEN e_incorrect_day OR e_incorrect_month THEN
      RAISE e_invalid_birth_date;
  END parse_birth_date;

  FUNCTION parse_lv_code(p_personal_code IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
    v_birth_date DATE;
    v_personal_code VARCHAR2(11);
    v_checksum INTEGER;
  BEGIN
    IF regexp_like(p_personal_code, '^3[2-9]\d{4}-?\d{5}$') THEN
      vr_result.is_valid := TRUE; -- new personal code format
    ELSIF regexp_like(p_personal_code, '^[0-9]{6}-?[0-9]{5}$') THEN
      v_personal_code := regexp_replace(p_personal_code, '\D');

      v_birth_date := parse_birth_date(
        p_personal_code => v_personal_code,
        p_day_offset => 1,
        p_month_offset => 3,
        p_year_offset => 5,
        p_century_offset => 7,
        p_with_gender => FALSE,
        p_ignore_century_error => TRUE
      );

      v_checksum := MOD(MOD(calculate_checksum(v_personal_code, tt_checksum_magic(10, 5, 8, 4, 2, 1, 6, 3, 7, 9)) + 1, 11), 10);

      vr_result.is_valid := v_checksum = SUBSTR(v_personal_code, -1, 1);
    ELSE
      vr_result.is_valid := FALSE;
    END IF;

    RETURN vr_result;
  END parse_lv_code;

  FUNCTION parse_ee_code(p_personal_code IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
    v_birth_date DATE;
    v_checksum INTEGER;
  BEGIN
    IF regexp_like(p_personal_code, '^[1-6]\d{10}$') THEN
      v_birth_date := parse_birth_date(
        p_personal_code => p_personal_code,
        p_day_offset => 4,
        p_month_offset => 6,
        p_year_offset => 2,
        p_century_offset => 1
      );

      v_checksum := MOD(MOD(calculate_checksum(p_personal_code, tt_checksum_magic(1, 2, 3, 4, 5, 6, 7, 8, 9 ,1)), 11), 10);

      vr_result.is_valid := v_checksum = SUBSTR(p_personal_code, -1, 1);
    ELSE
      vr_result.is_valid := FALSE;
    END IF;

    RETURN vr_result;
  END parse_ee_code;

  FUNCTION parse_lt_code(p_personal_code IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
    v_birth_date DATE;
    v_checksum INTEGER;
  BEGIN
    IF regexp_like(p_personal_code, '^[1-6]\d{10}$') THEN
      v_birth_date := parse_birth_date(
        p_personal_code => p_personal_code,
        p_day_offset => 4,
        p_month_offset => 6,
        p_year_offset => 2,
        p_century_offset => 1
      );

      v_checksum := MOD(calculate_checksum(p_personal_code, tt_checksum_magic(1, 2, 3, 4, 5, 6, 7, 8, 9 ,1)), 11);

      IF v_checksum != 10 THEN
        vr_result.is_valid := v_checksum = SUBSTR(p_personal_code, -1, 1);
      ELSE
        v_checksum := MOD(calculate_checksum(p_personal_code, tt_checksum_magic(3, 4, 5, 6, 7, 8, 9, 1, 2, 3)), 11);
        vr_result.is_valid := v_checksum = SUBSTR(p_personal_code, -1, 1);
      END IF;
    ELSE
      vr_result.is_valid := FALSE;
    END IF;

    RETURN vr_result;
  END parse_lt_code;

  FUNCTION parse_personal_code(p_personal_code IN VARCHAR2,
                               p_country       IN VARCHAR2)
  RETURN tr_personal_code IS
    vr_result tr_personal_code;
  BEGIN
    CASE p_country
    WHEN 'LV' THEN
      vr_result := parse_lv_code(p_personal_code);
    WHEN 'EE' THEN
      vr_result := parse_ee_code(p_personal_code);
    WHEN 'LT' THEN
      vr_result := parse_lt_code(p_personal_code);
    ELSE
      vr_result.is_valid := FALSE;
    END CASE;

    RETURN vr_result;
  EXCEPTION
    WHEN e_invalid_birth_date THEN
      vr_result.is_valid := FALSE;
      RETURN vr_result;
  END parse_personal_code;

END;
/
