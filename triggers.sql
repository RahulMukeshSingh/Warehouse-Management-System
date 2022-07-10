SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------------------------------------------------------------------
create or replace trigger trigger_Product_Insert_T
before insert on Product_Details_T
for each row
declare
isExists number;
isDelicate number(1);
temperatureControl varchar(30);
regId number;
begin
	select count(*) into isExists from Allocation_Details_T where product_id = :new.id;
	IF isExists = 0 THEN
		select extractValue(column_value,'/description/needs_temperature_control') into temperatureControl from TABLE(XMLSEQUENCE(:new.details));
		IF temperatureControl = 'cold' THEN
			select region_id into regId from StorageWarehouse_Region_T where storage_compartment_id IN (select s_compartment_id from Storage_Compartments_T where s_compartment_name = 'Cold');
		ELSIF temperatureControl = 'hot' THEN
			select region_id into regId from StorageWarehouse_Region_T where storage_compartment_id IN (select s_compartment_id from Storage_Compartments_T where s_compartment_name = 'Hold');
		ELSE
			select extractValue(column_value,'/description/is_delicate') into isDelicate from TABLE(XMLSEQUENCE(:new.details));
			IF isDelicate = 1 THEN
				select region_id into regId from StorageWarehouse_Region_T where storage_compartment_id IN (select s_compartment_id from Storage_Compartments_T where s_compartment_name = 'Delicate');
			ELSIF isDelicate = 0 THEN
				select region_id into regId from StorageWarehouse_Region_T where storage_compartment_id IN (select s_compartment_id from Storage_Compartments_T where s_compartment_name = 'Normal');
			END IF;
		END IF;
			insert into Allocation_Details_T values(Allocation_Details_Seq.nextval,regId, :new.id);
	END IF; 
END;
/

EXECUTE Product_Insert('Bread', XMLTYPE('<description> 	<area>5</area> 	<price>40</price> 	<is_delicate>0</is_delicate> 	<needs_temperature_control>cold</needs_temperature_control> </description>'), 'p1.jpg','ShortLived' );

EXECUTE Product_Insert('Milk', XMLTYPE('<description> 	<area>4</area> 	<price>30</price> 	<is_delicate>1</is_delicate> 	<needs_temperature_control>cold</needs_temperature_control> </description>'), 'p2.jpeg','ShortLived' );

EXECUTE Product_Insert('Moto G4 Plus', XMLTYPE('<description> 	<area>5</area> 	<price>14000</price> 	<is_delicate>0</is_delicate> 	<needs_temperature_control>no</needs_temperature_control> 	<features> 		<camera>15mp</camera> 		<ram>2gb</ram> 	</features> </description>'), 'p3.jpeg','Electronic');

EXECUTE Product_Insert('Dell Inspiron', XMLTYPE('<description> 	<area>8</area> 	<price>40000</price> 	<is_delicate>0</is_delicate> 	<needs_temperature_control>cold</needs_temperature_control> 		<features> 		<camera>2mp</camera> 		<ram>4gb</ram> 		<processor>Intel i3</processor> 	</features> </description>'), 'p4.jpg','Electronic' );

EXECUTE Product_Insert('Denim', XMLTYPE('<description> 	<area>8</area> 	<price>1000</price> 	<is_delicate>0</is_delicate> 	<needs_temperature_control>no</needs_temperature_control> </description>'), 'p5.jpg','Other' );

EXECUTE Product_Insert('Biscuits', XMLTYPE('<description> 	<area>3</area> 	<price>50</price> 	<is_delicate>1</is_delicate> 	<needs_temperature_control>no</needs_temperature_control> </description>'), 'p6.jpg','Other' );

--------------------------------------------------------------------------------------------------------------------------------------------
create or replace trigger Trigger_Storage_Product_T
before insert on Storage_Products_T
for each row
declare
totalWarehouseArea number;
productArea number;
totalProductArea number;
pArea number;
BEGIN
	totalProductArea := 0;
	select SDO_GEOM.SDO_AREA(s.region_sd,0.005) into totalWarehouseArea from StorageWarehouse_Region_T s where region_id = :new.region_id;
	FOR pr IN(select s.product_id, s.quantity from Storage_Products_T s where region_id = :new.region_id) LOOP
		select (extractvalue(column_value,'/description/area') * pr.quantity) into productArea from Product_Details_T p, TABLE(XMLSEQUENCE(p.DETAILS)) q where p.id = pr.product_id;
		totalProductArea := totalProductArea + productArea;
	END LOOP;
	select extractvalue(column_value,'/description/area') into pArea from Product_Details_T p, TABLE(XMLSEQUENCE(p.DETAILS)) q where p.id = :new.product_id;
	IF (totalWarehouseArea - totalProductArea) < pArea THEN
		RAISE_APPLICATION_ERROR(-20001,'No Space Available');
	END IF;
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace trigger trigger_Purchase_Order_T
before insert on Purchase_Order_T
for each row
declare
	cursor prod is select * from TABLE(:new.products);
	reg_id number;
	isExists number;
	pType varchar2(30);
	supplierCount number;
begin
	FOR p in prod LOOP
		select count(*) into isExists from Storage_Products_T where product_id = p.product_id;
		IF isExists > 0 THEN
			update Storage_Products_T set quantity = quantity + p.quantity where product_id = p.product_id;
		ELSE
			select region_id into reg_id from Allocation_Details_T where product_id = p.product_id;
			insert into Storage_Products_T values(Storage_Products(reg_id,p.product_id,p.quantity));
		END IF;	
		select productType into pType from Product_Details_T where id = p.product_id;
		IF pType = 'ShortLived' THEN
			FOR period in (select extractvalue(column_value,'/product/produced_date') produced_date,
			extractvalue(column_value,'/product/best_before_days') best_before_days from TABLE(XMLSEQUENCE(p.periods.extract('/periods/product')))) LOOP
				insert into Short_Lived_Products_T values(Short_Lived_Products(p.product_id, :new.order_id,TO_DATE(period.produced_date), TO_NUMBER(period.best_before_days)));
			END LOOP;
		ELSIF pType = 'Electronic' THEN
			FOR period in (select extractvalue(column_value,'/product/manufacturing_date') manufacturing_date,
			extractvalue(column_value,'/product/warranty_period_months') warranty_period_months from TABLE(XMLSEQUENCE(p.periods.extract('/periods/product')))) LOOP
				insert into Electronic_Products_T values(Electronic_Products(p.product_id, :new.order_id,TO_DATE(period.manufacturing_date), TO_NUMBER(period.warranty_period_months)));
			END LOOP;
		ELSIF pType = 'Other' THEN
			FOR period in (select extractvalue(column_value,'/product/manufacturing_date') manufacturing_date,
			extractvalue(column_value,'/product/expiry_date') expiry_date from TABLE(XMLSEQUENCE(p.periods.extract('/periods/product')))) LOOP
				insert into Other_Products_T values(Other_Products(p.product_id, :new.order_id,TO_DATE(period.manufacturing_date), 
				TO_DATE(period.expiry_date)));
			END LOOP;
		END IF;  
	END LOOP;
	select (count(*) + 1) into supplierCount from Purchase_Order_T where supplier_id = :new.supplier_id;
	IF supplierCount = 3 THEN
		update Supplier_Details_T set trusted = 1 where id = :new.supplier_id;
	END IF;
END;
/

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 1, 
ProductPurchase(
ProductPurchaseDetails(1,2,39,XMLTYPE('<periods> 	<product> 		<produced_date>17-OCT-2018</produced_date> 		<best_before_days>3</best_before_days> 	</product> 	<product> 		<produced_date>16-OCT-2018</produced_date> 		<best_before_days>3</best_before_days> 	</product>	 </periods>')),
ProductPurchaseDetails(2,1,30,XMLTYPE('<periods> 	<product> 		<produced_date>17-OCT-2018</produced_date> 		<best_before_days>4</best_before_days> 	</product> </periods>')),
ProductPurchaseDetails(3,1,13000,XMLTYPE('<periods> <product>	<manufacturing_date>03-MAR-2016</manufacturing_date> 	<warranty_period_months>12</warranty_period_months> </product> </periods>'))
)));

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 3, 
ProductPurchase(
ProductPurchaseDetails(4,1,40000,XMLTYPE('<periods> 	<product> 		<manufacturing_date>03-OCT-2017</manufacturing_date> 		<warranty_period_months>12</warranty_period_months> 	</product> </periods>')),
ProductPurchaseDetails(6,2,50,XMLTYPE('<periods> 	<product> 		<manufacturing_date>17-OCT-2018</manufacturing_date> 		<expiry_date>17-APR-2019</expiry_date> 	</product> 	<product> 	<manufacturing_date>27-SEP-2018</manufacturing_date> 		<expiry_date>27-MAR-2019</expiry_date> 	</product> </periods>')),
ProductPurchaseDetails(3,2,14000,XMLTYPE('<periods> 	<product> 		<manufacturing_date>03-OCT-2017</manufacturing_date> 		<warranty_period_months>12</warranty_period_months> 	</product> 	<product> 		<manufacturing_date>09-SEP-2017</manufacturing_date> 		<warranty_period_months>12</warranty_period_months> 	</product> </periods>'))
)));

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 5, 
ProductPurchase(
ProductPurchaseDetails(6,1,50,XMLTYPE('<periods> 	<product> 	<manufacturing_date>09-SEP-2018</manufacturing_date> 		<expiry_date>09-MAR-2019</expiry_date> 	</product> </periods>'))
)));

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 5, 
ProductPurchase(
ProductPurchaseDetails(6,1,50,XMLTYPE('<periods> 	<product> 	<manufacturing_date>09-AUG-2018</manufacturing_date> 		<expiry_date>09-FEB-2019</expiry_date> 	</product> </periods>'))
)));

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 5, 
ProductPurchase(
ProductPurchaseDetails(6,1,50,XMLTYPE('<periods> 	<product> 	<manufacturing_date>09-SEP-2018</manufacturing_date> 		<expiry_date>09-MAR-2019</expiry_date> 	</product> </periods>'))
)));

EXECUTE Product_Insert('Moto G4', XMLTYPE('<description> 	<area>5400</area> 	<price>14000</price> 	<is_delicate>0</is_delicate> 	<needs_temperature_control>no</needs_temperature_control> 	<features> 		<camera>15mp</camera> 		<ram>2gb</ram> 	</features> </description>'), 'p3.jpeg','Electronic');

insert into Purchase_Order_T values(Purchase_Order(Purchase_Order_seq.NEXTVAL, SYSTIMESTAMP, 5, 
ProductPurchase(
 ProductPurchaseDetails(7,2,14000,XMLTYPE('<periods> 	<product> 		<manufacturing_date>03-OCT-2017</manufacturing_date> 		<warranty_period_months>12</warranty_period_months> 	</product> 	<product> 		<manufacturing_date>09-SEP-2017</manufacturing_date> 		<warranty_period_months>12</warranty_period_months> 	</product> </periods>'))
 )));
 
select * from Storage_Products_T;
select * from Short_Lived_Products_T;
select * from Electronic_Products_T;
select * from Other_Products_T;
select id, trusted from Supplier_Details_T;


--------------------------------------------------------------------------------------------------------------------------------------------


create or replace trigger Trigger_Distribution_Product_T
before insert on Distribution_Products_T
for each row
declare
totalWarehouseArea number;
productArea number;
totalProductArea number;
pArea number;
BEGIN
	totalProductArea := 0;
	select SDO_GEOM.SDO_AREA(s.region_sd,0.005) into totalWarehouseArea from DistributionWarehouse_Region_T s where region_id = :new.region_id;
	FOR pr IN(select s.product_id, s.quantity from Distribution_Products_T s where region_id = :new.region_id) LOOP
		select (extractvalue(column_value,'/description/area') * pr.quantity) into productArea from Product_Details_T p, TABLE(XMLSEQUENCE(p.DETAILS)) q where p.id = pr.product_id;
		totalProductArea := totalProductArea + productArea;
	END LOOP;
	select extractvalue(column_value,'/description/area') into pArea from Product_Details_T p, TABLE(XMLSEQUENCE(p.DETAILS)) q where p.id = :new.product_id;
	IF (totalWarehouseArea - totalProductArea) < pArea THEN
		RAISE_APPLICATION_ERROR(-20001,'No Space Available');
	END IF;
END;
/
--------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION isOutOfStock(products IN ProductSales) RETURN VARCHAR2 
IS
cursor prod is select * from TABLE(products);
stockQty number;
outOfStock varchar2(500);
counter number;
countProduct number;
BEGIN
	counter := 0;
	FOR p in prod LOOP
		stockQty := 0;
		select count(*) into countProduct from Storage_Products_T where product_id = p.product_id;
		IF countProduct > 0 THEN
		select quantity into stockQty from Storage_Products_T where product_id = p.product_id;
		END IF;
		IF stockQty < p.quantity THEN
			IF counter = 0 THEN
			outOfStock := 'Products ordered more than in stock with ';
			END IF;
			outOfStock := outOfStock || ' id : '|| p.product_id;
		END IF;
	counter := counter + 1;	
	END LOOP;
	RETURN outOfStock;
END;
/


create or replace trigger trigger_Sales_Order_T
before insert on Sales_Order_T
for each row
declare
	cursor prod is select * from TABLE(:new.products);
	isExists number;
	storageProdQty number;
	outOfStock varchar2(500);
	customerCount number;
begin
	outOfStock := isOutOfStock(:new.products);
	DBMS_OUTPUT.PUT_LINE(LENGTH(outOfStock));
	IF LENGTH(outOfStock) > 0 THEN
		raise_application_error(-20001, outOfStock); 
	ELSE
		FOR p in prod LOOP
			select quantity into storageProdQty from Storage_Products_T where product_id = p.product_id;
			IF storageProdQty = p.quantity THEN
				delete from Storage_Products_T where product_id = p.product_id;
				DBMS_OUTPUT.PUT_LINE('It''s time to buy a product with product id : '|| p.product_id);
			ELSIF storageProdQty > p.quantity THEN 
				update Storage_Products_T set quantity = quantity - p.quantity where product_id = p.product_id;
			END IF;
			IF :new.isFaulty = 1 THEN
				select count(*) into isExists from Distribution_Products_T where product_id = p.product_id and region_id = 1;
				IF isExists > 0 THEN
					update Distribution_Products_T set quantity = quantity + p.quantity where product_id = p.product_id and region_id = 1;
				ELSE
					insert into Distribution_Products_T values(1,p.product_id,p.quantity);
				END IF;
			ELSE
				select count(*) into isExists from Distribution_Products_T where product_id = p.product_id and region_id = 2;
				IF isExists > 0 THEN
					update Distribution_Products_T set quantity = quantity + p.quantity where product_id = p.product_id and region_id = 2;
				ELSE
					insert into Distribution_Products_T values(2,p.product_id,p.quantity);
				END IF;			
			END IF;	
		END LOOP;
		select (count(*) + 1) into customerCount from Sales_Order_T where customer_id = :new.customer_id;
		IF customerCount = 3 THEN
			update Customer_Details_T set regular = 1 where id = :new.customer_id;
		END IF;
	END IF;
END;
/

insert into Sales_Order_T values(Sales_Order(Sales_Order_seq.NEXTVAL, SYSTIMESTAMP, 2, ProductSales(ProductSalesDetails(1,7,42),ProductSalesDetails(3,3,15000),ProductSalesDetails(6,3,53),ProductSalesDetails(5,2,1002)),1,0));

insert into Sales_Order_T values(Sales_Order(Sales_Order_seq.NEXTVAL, SYSTIMESTAMP, 4, ProductSales(ProductSalesDetails(3,3,15000),ProductSalesDetails(6,1,53)),1,0));

insert into Sales_Order_T values(Sales_Order(Sales_Order_seq.NEXTVAL, SYSTIMESTAMP, 6, ProductSales(ProductSalesDetails(6,1,49)),0,0));
insert into Sales_Order_T values(Sales_Order(Sales_Order_seq.NEXTVAL, SYSTIMESTAMP, 6, ProductSales(ProductSalesDetails(1,1,42)),1,0));
insert into Sales_Order_T values(Sales_Order(Sales_Order_seq.NEXTVAL, SYSTIMESTAMP, 6, ProductSales(ProductSalesDetails(1,1,43)),0,0));

select * from Storage_Products_T;
select * from Distribution_Products_T;
select id, regular from Customer_Details_T;
--------------------------------------------------------------------------------------------------------------------------------------------

create or replace trigger trigger_Transport_Order_T
before insert on Transport_Order_T
for each row
declare
	cursor orders is select * from TABLE(:new.products);
	distProdQty number;
	faulty number(1);
	reg_id number;
begin
	FOR o in orders LOOP
		select isFaulty into faulty from Sales_Order_T where order_id = o.sales_order_id;
		IF faulty = 1 THEN
			reg_id := 1;
		ELSE
			reg_id := 2;
		END IF;
		FOR prod in (select p.product_id, p.quantity from Sales_Order_T s,TABLE(s.products) p where s.order_id = o.sales_order_id) LOOP
			select quantity into distProdQty from Distribution_Products_T where product_id = prod.product_id and region_id = reg_id;
			IF distProdQty > prod.quantity THEN
				update Distribution_Products_T set quantity = quantity - prod.quantity where product_id = prod.product_id and region_id = reg_id;
			ELSIF distProdQty = prod.quantity THEN
				delete from Distribution_Products_T where product_id = prod.product_id and region_id = reg_id;
			ELSE
				RAISE_APPLICATION_ERROR(-20001,'Wrong Data');
			END IF;		
		END LOOP;
		UPDATE Sales_Order_T SET isTransported = 1 where order_id = o.sales_order_id;  
	END LOOP; 
END;
/

insert into Transport_Order_T values(Transport_Order(Transport_Order_seq.nextval,SYSTIMESTAMP,5,ProductTransport(
ProductTransportDetails(2),ProductTransportDetails(3)
),17,20
));

select * from Distribution_Products_T;
select order_id, isTransported from Sales_Order_T; 

--------------------------------------------------------------------------------------------------------------------------------------------

create or replace trigger delTrigger_Product_T
after delete on Product_Details_T
for each row
BEGIN
	delete from Short_Lived_Products_T where product_id = :old.id;
	delete from Electronic_Products_T where product_id = :old.id;
	delete from Other_Products_T where product_id = :old.id;
END;
/

delete from Product_Details_T where id = 3;
select * from Short_Lived_Products_T;
select * from Electronic_Products_T;
select * from Other_Products_T;

