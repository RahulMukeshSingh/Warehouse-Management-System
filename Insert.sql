-----------------------------------------------------------------------------------------------

INSERT INTO USER_SDO_GEOM_METADATA 
  VALUES (
  'StorageWarehouse_Region_T',
  'region_sd',
  MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 200, 0.005),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 200, 0.005)
     ),
  NULL
);

INSERT INTO USER_SDO_GEOM_METADATA 
  VALUES (
  'DistributionWarehouse_Region_T',
  'region_sd',
  MDSYS.SDO_DIM_ARRAY(
    MDSYS.SDO_DIM_ELEMENT('X', 0, 200, 0.005),
    MDSYS.SDO_DIM_ELEMENT('Y', 0, 200, 0.005)
     ),
  NULL
);


CREATE INDEX storage_SPID
ON StorageWarehouse_Region_T(region_sd)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

CREATE INDEX distribution_SPID
ON DistributionWarehouse_Region_T(region_sd)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-----------------------------------------------------------------------------------------------

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('XYZ','LLC'), 
loc(
Location('Thane','Thane','Maharastra',400605),
Location('Vadodara','Vadodara','Gujarat',401706)
),
pno(
PhoneNo(9167089770),
PhoneNo(9999999999)
),
0
));

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('ABC','Ltd.'), 
loc(
Location('Mumbai','Mumbai','Maharastra',400601)
),
pno(
PhoneNo(9667889777),
PhoneNo(9898989898)
),
0
));

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('LMN','Co.'), 
loc(
Location('Bangalore','Bangalore City','Karnataka',400801)
),
pno(
PhoneNo(8777787777)
),
0
));

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('PQR','Enterprise'), 
loc(
Location('Bangalore','Bangalore City','Karnataka',400801)
),
pno(
PhoneNo(9693969366)
),
0
));

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('UVW','Corp.'), 
loc(
Location('Vadodara','Vadodara','Gujarat',401706)
),
pno(
PhoneNo(9999966666)
),
0
));

insert into Supplier_Details_T values( Supplier_Details(
Supplier_Details_Seq.nextval, 
FullName('XYZ','Company'), 
loc(
Location('Varanasi','Varanasi','Uttar Pradesh',465395)
),
pno(
PhoneNo(9764310134)
),
0
));
---------------------------------------------------------------------------------------------------------------

insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Rahul','Singh'), 
loc(
Location('Dadar','Mumbai','Maharashtra',400333),
Location('Thane','Thane City','Maharashtra',400666),
Location('CSMT','Mumbai','Maharashtra',400999)
),
pno(
PhoneNo(9797979797)
),
0
));

insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Sanjana','GopalKrishna'), 
loc(
Location('Vadodara','Vadodara','Gujarat',431679)
),
pno(
PhoneNo(9636363669)
),
0
));

insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Rahana','Singh'), 
loc(
Location('Dombivli','Thane','Maharashtra',300603)
),
pno(
PhoneNo(9639333999)
),
0
));


insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Ashutosh','Singh'), 
loc(
Location('Mumbai','Mumbai','Maharastra',400601)
),
pno(
PhoneNo(9794613258),
PhoneNo(1324654897)
),
0
));

insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Unmesh','Kadam'), 
loc(
Location('Bangalore','Bangalore City','Karnataka',400801)
),
pno(
PhoneNo(8795462130)
),
0
));

insert into Customer_Details_T values( Customer_Details(
Customer_Details_Seq.nextval, 
FullName('Saurabh','Pawar'), 
loc(
Location('Bangalore','Bangalore City','Karnataka',400801)
),
pno(
PhoneNo(9137546820)
),
0
));

-----------------------------------------------------------------------------------------------

insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('A','Transporter'), 
loc(
Location('Kalyan','Thane','Maharastra',400615)
),
pno(
PhoneNo(9111111111)
),
20,1,1
));

insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('B','Transporter'), 
loc(
Location('Kalyan','Thane','Maharastra',400615)
),
pno(
PhoneNo(933993396)
),
15,0,1
));

insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('C','Transporter'), 
loc(
Location('Ahemdabad','Ahemdabad City','Gujarat',401716)
),
pno(
PhoneNo(8888888888)
),
16,1,0
));


insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('D','Transporter'), 
loc(
Location('Kalyan','Thane','Maharastra',400615)
),
pno(
PhoneNo(9456789421)
),
10,0,0
));

insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('E','Transporter'), 
loc(
Location('Kalyan','Thane','Maharastra',400615)
),
pno(
PhoneNo(9894561230)
),
18,1,1
));

insert into Transporter_Details_T values( Transporter_Details(
Transporter_Details_Seq.nextval, 
FullName('F','Transporter'), 
loc(
Location('Ahemdabad','Ahemdabad City','Gujarat',401716)
),
pno(
PhoneNo(6666666666)
),
21,1,0
));

-----------------------------------------------------------------------------------------------

CREATE OR REPLACE DIRECTORY IMAGE_LOCATION_PRODUCT AS 'C:\Users\Rahul\Desktop\ADBMS Project\Product_Image\\'
/


CREATE OR REPLACE PROCEDURE Product_Insert
(
p_name IN Product_Details_T.name%TYPE,
p_details IN Product_Details_T.details%TYPE,
p_image_name varchar2,
p_type IN Product_Details_T.productType%TYPE
) 
IS
p_bfile BFILE;
p_blob BLOB;
BEGIN
INSERT INTO Product_Details_T VALUES(Product_Details(Products_Seq.nextval, p_name, p_details, EMPTY_BLOB(), p_type)) RETURN image INTO p_blob;
p_bfile := BFILENAME('IMAGE_LOCATION_PRODUCT', p_image_name);
DBMS_LOB.fileopen(p_bfile, DBMS_LOB.file_readonly);
DBMS_LOB.loadfromfile(p_blob, p_bfile, DBMS_LOB.getlength(p_bfile));
DBMS_LOB.fileclose(p_bfile);
COMMIT;
END;
/

-----------------------------------------------------------------------------------------------

insert into Storage_Compartments_T values(Storage_Compartments_Seq.nextval, 'Normal');
insert into Storage_Compartments_T values(Storage_Compartments_Seq.nextval, 'Delicate');
insert into Storage_Compartments_T values(Storage_Compartments_Seq.nextval, 'Hot');
insert into Storage_Compartments_T values(Storage_Compartments_Seq.nextval, 'Cold');

insert into Distribution_Compartments_T values(Distribution_Compartments_Seq.nextval, 'Faulty');
insert into Distribution_Compartments_T values(Distribution_Compartments_Seq.nextval, 'Normal');

-----------------------------------------------------------------------------------------------

insert into StorageWarehouse_Region_T values(StorageWarehouse_Region(
StorageW_Region_Seq.nextval,'Normal Storage Warehouse1',1,
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(40,120,170,160)
  ),
  1
));

insert into StorageWarehouse_Region_T values(StorageWarehouse_Region(
StorageW_Region_Seq.nextval,'Delicate Storage Warehouse1', 1,
  MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
    MDSYS.SDO_ORDINATE_ARRAY(60,120,90,90,60,60)
  ),
  2
));

insert into StorageWarehouse_Region_T values(StorageWarehouse_Region(
StorageW_Region_Seq.nextval,'Hot Storage Warehouse2',2,
  MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
    MDSYS.SDO_ORDINATE_ARRAY(140,110,140,140,170,160,170,130,140,110)
  ),
  3
));

insert into StorageWarehouse_Region_T values(StorageWarehouse_Region(
StorageW_Region_Seq.nextval,'Cold Storage Warehouse2', 2,
  MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
    MDSYS.SDO_ORDINATE_ARRAY(140,110,170,100,170,70,140,80,140,110)
  ),
  4
));

-----------------------------------------------------------------------------------------------

insert into DistributionWarehouse_Region_T values(DistributionWarehouse_Region(
DistributionW_Region_Seq.nextval,'Faulty Distribution Warehouse',3,
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(50,20,90,30)
  ),
  1
));

insert into DistributionWarehouse_Region_T values(DistributionWarehouse_Region(
DistributionW_Region_Seq.nextval,'Normal Distribution Warehouse',3,
MDSYS.SDO_GEOMETRY(
    2003, 
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
    MDSYS.SDO_ORDINATE_ARRAY(100,20,130,30)
  ),
  2
));

-----------------------------------------------------------------------------------------------


