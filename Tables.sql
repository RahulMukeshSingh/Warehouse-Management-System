create or replace type FullName as object(
	first_name varchar2(20),
	last_name varchar2(20)	
)
/

create or replace type Location as object(
	street varchar2(20),
	city varchar2(20),
	state varchar2(20),
	zip number(6)
)
/

create or replace type PhoneNo as object(
	phone_no number(10)
)
/

create or replace type loc as varray(3) of Location
/

create or replace type pno as varray(2) of PhoneNo
/

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace type Associate_Details as object(
	id number,
	name FullName,
	address loc,
	phone_no pno
)
NOT FINAL
/

create or replace type Supplier_Details under Associate_Details(
	trusted number(1)
)
/

create or replace type Customer_Details under Associate_Details(
	regular number(1)
)
/

create or replace type Transporter_Details under Associate_Details(
	cost_per_km number,
	delicate_protection number(1),
	temperature_control number(1)
)
/
--------------------------------------------------------------------------------------------------------------------------------------------


create or replace type Product_Details as object(
	id number,
	name varchar2(30),
	details XMLTYPE, --area, price, is_delicate, needs_temperature_control
	image BLOB,
	productType varchar2(30) 
)
/

--------------------------------------------------------------------------------------------------------------------------------------------
create or replace type Product_Classification as object(
	product_id number,
	order_id number,
	NOT INSTANTIABLE MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2
	)
	NOT INSTANTIABLE NOT FINAL
/

create or replace type Short_Lived_Products under Product_Classification(
	produced_date date,
	best_before_days number,
	OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2
)
/

CREATE OR REPLACE TYPE BODY Short_Lived_Products 
AS
OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2 
IS
differ number(5,2);
BEGIN
	differ := (produced_date + best_before_days) - SYSDATE;
	IF differ > 0 THEN
		RETURN CONCAT(differ, ' Days Remaining');
	ELSE
		RETURN 'NO DAYS REMAINING';
	END IF;
END;
END;
/

create or replace type Electronic_Products under Product_Classification(
	manufacturing_date date,
	warranty_period_months number,
	OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2
)
/

CREATE OR REPLACE TYPE BODY Electronic_Products 
AS
OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2 
IS
BEGIN
	RETURN CONCAT(warranty_period_months, ' Months Remaining');
END;
END;
/

create or replace type Other_Products under Product_Classification(
	manufacturing_date date,
	expiry_date date,
	OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2
)
/

CREATE OR REPLACE TYPE BODY Other_Products 
AS
OVERRIDING MEMBER FUNCTION getRemainingPeriods RETURN VARCHAR2 
IS
differ number(5,2);
BEGIN
	differ := MONTHS_BETWEEN(expiry_date, SYSDATE);
	IF differ > 0 THEN
		RETURN CONCAT(differ, ' Months Remaining');
	ELSE
		RETURN 'NO DAYS REMAINING';
	END IF;
END;
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------



create or replace type Storage_Compartments as object(
	s_compartment_id number,
	s_compartment_name varchar2(30) 
)
/

create or replace type Distribution_Compartments as object(
	d_compartment_id number,
	d_compartment_name varchar2(30)
)
/

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace type Warehouse_Region as object(
	region_id number ,
	region_name varchar2(50) ,
	warehouse_id number,
	region_sd MDSYS.SDO_GEOMETRY 
)
NOT FINAL
/

create or replace type StorageWarehouse_Region under Warehouse_Region(
	storage_compartment_id number
)
/

create or replace type DistributionWarehouse_Region under Warehouse_Region(
	distribution_compartment_id number
)
/

--------------------------------------------------------------------------------------------------------------------------------------------
create or replace type ProductPurchaseDetails as object(
	product_id number,
	quantity number,
	price number,
	periods XMLTYPE
)
/

create or replace type ProductSalesDetails as object(
	product_id number,
	quantity number,
	price number
)
/

create or replace type ProductTransportDetails as object(
	sales_order_id number
)
/

create or replace type ProductPurchase as table of ProductPurchaseDetails
/

create or replace type ProductSales as table of ProductSalesDetails
/

create or replace type productTransport as table of ProductTransportDetails
/

create or replace type Order_Details as object(
	order_id number,
	order_date timestamp 
)
NOT FINAL
/

create or replace type Purchase_Order under Order_Details(
	supplier_id number,
	products ProductPurchase
)
/

create or replace type Sales_Order under Order_Details(
	customer_id number,
	products ProductSales,
	isFaulty number(1),
	isTransported number(1)
)
/

create or replace type Transport_Order under Order_Details(
	transporter_id number,
	products productTransport,
	cost_per_km number,
	kilometers number
)
/

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace type Storage_Products as object(
	region_id number,
	product_id number,
	quantity number
)
/

create or replace type Distribution_Products as object(
	region_id number,
	product_id number,
	quantity number
)
/

create or replace type Allocation_Details as object(
	allocation_id number,
	region_id number,
	product_id number	
)
/

--------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Supplier_Details_T of Supplier_Details;
CREATE TABLE Customer_Details_T of Customer_Details;
CREATE TABLE Transporter_Details_T of Transporter_Details;


CREATE TABLE Product_Details_T of Product_Details;
CREATE TABLE Short_Lived_Products_T of Short_Lived_Products;
CREATE TABLE Electronic_Products_T of Electronic_Products;
CREATE TABLE Other_Products_T of Other_Products;

CREATE TABLE Storage_Compartments_T of Storage_Compartments;
CREATE TABLE Distribution_Compartments_T of Distribution_Compartments;

CREATE TABLE StorageWarehouse_Region_T of StorageWarehouse_Region;
CREATE TABLE DistributionWarehouse_Region_T of DistributionWarehouse_Region;

CREATE TABLE Allocation_Details_T of Allocation_Details;

CREATE TABLE Purchase_Order_T of Purchase_Order nested table products store as productsPurchase_NestedTable;
CREATE TABLE Sales_Order_T of Sales_Order nested table products store as productsSales_NestedTable;
CREATE TABLE Transport_Order_T of Transport_Order nested table products store as productsTransport_NestedTable;


CREATE TABLE Storage_Products_T of Storage_Products;
CREATE TABLE Distribution_Products_T of Distribution_Products;

--------------------------------------------------------------------------------------------------------------------------------------------


