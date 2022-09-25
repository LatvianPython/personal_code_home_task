# personal_code_home_task
technical take-home assignment

# installation

1. get yourself an Oracle Database, one I used was from [Oracle Developer VMs](https://www.oracle.com/downloads/developer-vm/community-downloads.html)
1. install utPLSQL, follow instructions here: [utPLSQL install guide](http://www.utplsql.org/utPLSQL/latest/userguide/install.html)
1. install project to database
   1. create new schema as system user with [sql/database_setup.sql](sql/database_setup.sql)  
   1. connect to new schema and run [sql/install.sql](sql/install.sql) 
1. if you did install utPLSQL, verify code with `BEGIN ut.run() END;`

# tests

All tests used during development are available in [sql/package/test_personal_code-h.sql](sql/package/test_personal_code-h.sql), and [sql/package/test_personal_code-b.sql](sql/package/test_personal_code-b.sql).
Use installed utPLSQL testing framework to run the tests.

# usage

Use package function `personal_code.parse_personal_code` to check validity of a given personal code 
```sql
FUNCTION parse_personal_code(p_personal_code IN VARCHAR2,
                             p_country       IN VARCHAR2)
RETURN tr_personal_code;
``` 
Parameters are the personal code you wish to parse, and the country from which this personal code is from. 
Result is:
```sql
TYPE tr_personal_code IS RECORD (
 personal_code VARCHAR2(11),
 is_valid BOOLEAN,
 gender VARCHAR2(1),
 birth_date DATE
);
```
All possible values are parsed out from the personal code, this depends on the country, as not all countries have the
same level of information available, if it is not possible to obtain something from the personal code, but the code is still 
valid, the record value will be NULL. You can check `is_valid` for if personal code is correct for a given country.

# possible improvements

1. Do not use your own implementation of personal code checking. Latvian government provides a module for a reasonable price [Latvija.lv "Fizisko personu reģistra personas koda korektuma pārbaudes moduļa standarta programmatūras izsniegšana"](https://latvija.lv/lv/PPK/socialie-pakalpojumi/sociala-apdrosinasana/p871/ProcesaApraksts). 
Estonia and Lithuania likely have their own versions of this.
1. Provide reason why personal code was not valid in return value, or as a custom exception. 
1. Add logging to debug tables.
1. Use constants instead of M/F characters for gender, use constants for country codes as well.
1. Add more tests for Estonia/Lithuania 
