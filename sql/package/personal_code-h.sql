CREATE OR REPLACE PACKAGE personal_code AS

  TYPE tr_personal_code IS RECORD (
    personal_code VARCHAR2(11),
    is_valid BOOLEAN,
    gender VARCHAR2(1),
    birth_date DATE
  );

  FUNCTION parse_personal_code(p_personal_code IN VARCHAR2,
                               p_country       IN VARCHAR2)
  RETURN tr_personal_code;

END;
/
