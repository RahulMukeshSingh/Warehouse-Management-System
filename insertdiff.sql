create or replace type FullName1 as object(
	first_name varchar2(20),
	last_name varchar2(20)	
)
/

create or replace type Location1 as object(
	street varchar2(20),
	city varchar2(20),
	state varchar2(20),
	zip number(6)
)
/

create or replace type PhoneNo1 as object(
	phone_no number(10)
)
/

create or replace type loc1 as varray(3) of Location1
/

create or replace type pno1 as varray(2) of PhoneNo1
/

--------------------------------------------------------------------------------------------------------------------------------------------


create table Employee_Details(
	id number,
	name FullName1,
	address loc1,
	phone_no pno1,
	image BLOB,
	joining_date date,
	retirement_date date
)
/

--------------------------------------------------------------------------------------------------------------------------------------------
create or replace type EmployeeTimingDetails as object(
	emp_id number,
	from_time timestamp,
	to_time timestamp
)
/



create or replace type EmployeeTiming as table of EmployeeTimingDetails
/

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace type Warehouse_Details as object(
	warehouse_id number,
	warehouse_name varchar2(30),
	employee_incharge EmployeeTiming,
	warehouse_type varchar2(30),
	region_sd MDSYS.SDO_GEOMETRY
)
/
CREATE TABLE Warehouse_Details_T of Warehouse_Details nested table employee_incharge store as employee_incharge_NestedTable;

--------------------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE Warehouse_Details_Seq MINVALUE 1 START WITH 1 INCREMENT BY 1;

INSERT INTO USER_SDO_GEOM_METADATA 
  VALUES (
  'Warehouse_Details_T',
  'region_sd',
  MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 200, 0.005),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 200, 0.005)
     ),
  NULL
);


CREATE INDEX warehouse_SPID
ON Warehouse_Details_T(region_sd)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

insert into Warehouse_Details_T values(Warehouse_Details(Warehouse_Details_Seq.nextval, 'Storage Warehouse1',
EmployeeTiming(EmployeeTimingDetails(1, to_timestamp('10:00:00', 'hh24:mi:ss'), to_timestamp('21:59:59', 'hh24:mi:ss')),EmployeeTimingDetails(3, to_timestamp('22:00:00', 'hh24:mi:ss'), to_timestamp('09:59:59', 'hh24:mi:ss'))),
'Storage',
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(20,60,90,170)
  )
));

insert into Warehouse_Details_T values(Warehouse_Details(Warehouse_Details_Seq.nextval, 'Storage Warehouse2',
EmployeeTiming(EmployeeTimingDetails(2,to_timestamp('10:00:00', 'hh24:mi:ss'), to_timestamp('21:59:59', 'hh24:mi:ss')),EmployeeTimingDetails(6,to_timestamp('22:00:00', 'hh24:mi:ss'), to_timestamp('09:59:59', 'hh24:mi:ss'))),
'Storage',
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(120,60,180,170)
  )
));

insert into Warehouse_Details_T values(Warehouse_Details(Warehouse_Details_Seq.nextval, 'Distribution Warehouse',
EmployeeTiming(EmployeeTimingDetails(4,to_timestamp('10:00:00', 'hh24:mi:ss'), to_timestamp('21:59:59', 'hh24:mi:ss')),EmployeeTimingDetails(5,to_timestamp('22:00:00', 'hh24:mi:ss'), to_timestamp('09:59:59', 'hh24:mi:ss'))),
'Distribution',
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(40,10,140,40)
  )
));

commit;
--------------------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE Employee_Details_Seq MINVALUE 1 START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE DIRECTORY IMAGE_LOCATION_EMPLOYEE AS 'E:\ADBMS Project\Employee_Image\\'
/

CREATE OR REPLACE PROCEDURE Employee_Insert
(
e_name IN Employee_Details_T.name%TYPE,
e_address IN Employee_Details_T.address%TYPE,
e_phone_no IN Employee_Details_T.phone_no%TYPE,
e_image_name varchar2,
e_joining_date IN Employee_Details_T.joining_date%TYPE,
e_retirement_date IN Employee_Details_T.retirement_date%TYPE
) 
IS
e_bfile BFILE;
e_blob BLOB;
BEGIN
INSERT INTO Employee_Details_T VALUES(Employee_Details(Employee_Details_Seq.nextval,e_name,e_address,e_phone_no, EMPTY_BLOB(),e_joining_date,e_retirement_date)) RETURN image INTO e_blob;
e_bfile := BFILENAME('IMAGE_LOCATION_EMPLOYEE', e_image_name);
DBMS_LOB.fileopen(e_bfile, DBMS_LOB.file_readonly);
DBMS_LOB.loadfromfile(e_blob, e_bfile, DBMS_LOB.getlength(e_bfile));
DBMS_LOB.fileclose(e_bfile);
COMMIT;
END;
/

EXECUTE Employee_Insert( FullName1('Employee','A'), loc1( Location1('Kalyan','Thane','Maharastra',400615) ), pno1( PhoneNo1(7894561234) ), 'e1.jpg','15-mar-2007','13-mar-2019' );

EXECUTE Employee_Insert( FullName1('Employee','B'), loc1( Location1('Ahemdabad','Ahemdabad City','Gujarat',401716) ), pno1( PhoneNo1(4563821970) ), 'e2.jpg','8-jan-2017','9-feb-2039' );

EXECUTE Employee_Insert( FullName1('Employee','C'), loc1( Location1('Bangalore','Bangalore City','Karnataka',400801) ), pno1( PhoneNo1(1345678203) ), 'e3.jpg','18-feb-2011','13-oct-2018' );

EXECUTE Employee_Insert( FullName1('Employee','D'), loc1( Location1('Vadodara','Vadodara','Gujarat',401706) ), pno1( PhoneNo1(9746310258) ), 'e4.jpg','18-feb-2009','13-nov-2018' );

EXECUTE Employee_Insert( FullName1('Employee','E'), loc1( Location1('Dombivli','Thane','Maharashtra',300603) ), pno1( PhoneNo1(4568523159) ), 'e5.jpg','28-apr-2006','16-nov-2020' );

EXECUTE Employee_Insert( FullName1('Employee','F'), loc1( Location1('Varanasi','Varanasi','Uttar Pradesh',465395) ), pno1( PhoneNo1(9513572846) ), 'e6.jpg','28-apr-2016','16-dec-2018' );


commit;
-----------------------------------------------------------------------------------------------
