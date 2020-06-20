#!/bin/bash

oddgen(){
	cd /opt/oddgen-main/examples
	sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		BEGIN
		   EXECUTE IMMEDIATE 'DROP USER oddgen CASCADE';
		EXCEPTION
		   WHEN OTHERS THEN
		      NULL;
		END;
		/
		@user/create_user_oddgen.sql
		ALTER USER oddgen DEFAULT TABLESPACE users;
		BEGIN
		   EXECUTE IMMEDIATE 'DROP USER ogdemo CASCADE';
		EXCEPTION
		   WHEN OTHERS THEN
		      NULL;
		END;
		/
		CREATE USER ogdemo IDENTIFIED BY ogdemo
		   DEFAULT TABLESPACE users
		   TEMPORARY TABLESPACE temp
		   QUOTA UNLIMITED ON users;
		GRANT CONNECT, RESOURCE to ogdemo;
		GRANT CREATE VIEW to ogdemo;
		GRANT SELECT_CATALOG_ROLE to ogdemo;
		GRANT SELECT ANY DICTIONARY to ogdemo;
EOF
	sqlplus -s -l oddgen/oddgen@${CONNECT_STRING} <<EOF
		@install.sql
		EXIT
EOF
	sqlplus -s -l ogdemo/ogdemo@${CONNECT_STRING} <<EOF
		CREATE TABLE dept (
		   deptno   NUMBER(2)     CONSTRAINT pk_dept PRIMARY KEY,
		   dname    VARCHAR2(14),
		   loc      VARCHAR2(13)
		);
		CREATE TABLE emp (
		   empno    NUMBER(4)     CONSTRAINT pk_emp PRIMARY KEY,
		   ename    VARCHAR2(10),
		   job      VARCHAR2(9),
		   mgr      NUMBER(4),
		   hiredate DATE,
 		  sal      NUMBER(7,2),
		   comm     NUMBER(7,2),
		   deptno   NUMBER(2)     CONSTRAINT fk_deptno REFERENCES dept
		);
		INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
		INSERT INTO dept VALUES (20, 'RESEARCH', 'DALLAS');
		INSERT INTO dept VALUES (30, 'SALES', 'CHICAGO');
		INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');
		INSERT INTO emp VALUES (7369, 'SMITH', 'CLERK', 7902, DATE '1980-12-17', 800, NULL, 20);
		INSERT INTO emp VALUES (7499, 'ALLEN', 'SALESMAN', 7698, DATE '1981-02-20', 1600, 300, 30);
		INSERT INTO emp VALUES (7521, 'WARD', 'SALESMAN', 7698, DATE '1981-02-22', 1250, 500, 30);
		INSERT INTO emp VALUES (7566, 'JONES', 'MANAGER', 7839, DATE '1981-04-02', 2975, NULL, 20);
		INSERT INTO emp VALUES (7654, 'MARTIN', 'SALESMAN', 7698, DATE '1981-09-28', 1250, 1400, 30);
		INSERT INTO emp VALUES (7698, 'BLAKE', 'MANAGER', 7839, DATE '1981-05-01', 2850, NULL, 30);
		INSERT INTO emp VALUES (7782, 'CLARK', 'MANAGER', 7839, DATE '1981-06-09', 2450, NULL, 10);
		INSERT INTO emp VALUES (7788, 'SCOTT', 'ANALYST', 7566, DATE '1987-04-19', 3000, NULL, 20);
		INSERT INTO emp VALUES (7839, 'KING', 'PRESIDENT', NULL, DATE '1981-11-17', 5000, NULL, 10);
		INSERT INTO emp VALUES (7844, 'TURNER', 'SALESMAN', 7698, DATE '1981-09-08', 1500, 0, 30);
		INSERT INTO emp VALUES (7876, 'ADAMS', 'CLERK', 7788, DATE '1987-05-23', 1100, NULL, 20);
		INSERT INTO emp VALUES (7900, 'JAMES', 'CLERK', 7698, DATE '1981-12-03', 950, NULL, 30);
		INSERT INTO emp VALUES (7902, 'FORD', 'ANALYST', 7566, DATE '1981-12-03', 3000, NULL, 20);
		INSERT INTO emp VALUES (7934, 'MILLER', 'CLERK', 7782, DATE '1982-01-23', 1300, NULL, 10);
		COMMIT;
		@/opt/oddgen-main/examples/package/oddgen_types.pks
		@/opt/oddgen-main/examples/tutorial/01_minimal_view/minimal_view.pks
		@/opt/oddgen-main/examples/tutorial/01_minimal_view/minimal_view.pkb
		@/opt/oddgen-main/examples/tutorial/02_extended_view/extended_view.pks
		@/opt/oddgen-main/examples/tutorial/02_extended_view/extended_view.pkb
		GRANT EXECUTE ON minimal_view TO PUBLIC;
		GRANT EXECUTE ON extended_view TO PUBLIC;
EOF
}

user_settings(){
	sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		ALTER PROFILE default LIMIT PASSWORD_LIFE_TIME UNLIMITED;
		ALTER USER scott ACCOUNT UNLOCK;
		ALTER USER scott IDENTIFIED BY tiger;
EOF
}

user_settings
oddgen
cd /
