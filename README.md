# personal_code_home_task
technical take-home assignment


# installation

1. get yourself an Oracle Database, one I used was from [Oracle Developer VMs](https://www.oracle.com/downloads/developer-vm/community-downloads.html)
1. install utPLSQL, follow instructions here: [utPLSQL install guide](http://www.utplsql.org/utPLSQL/latest/userguide/install.html)
1. install project to database
   1. create new schema as system user with [sql/database_setup.sql](sql/database_setup.sql)  
   1. connect to new schema and run [sql/install.sql](sql/install.sql) 
1. if you did install utPLSQL, verify code with `BEGIN ut.run() END;`
