--Drop all tables, sequences and procedures
DROP TABLE payment; 
DROP TABLE trips;
DROP TABLE vehicles;
DROP TABLE vehicle_types;
DROP TABLE vehicle_owners;
DROP TABLE customer;
DROP TABLE distances;
DROP SEQUENCE vehicle_id_seq;
DROP SEQUENCE distance_in;
DROP SEQUENCE vehicle_owner_id_seq;
Drop PROCEDURE displayVehicleType;
DROP PROCEDURE distance_insert;
DROP PROCEDURE one_leg;
DROP PROCEDURE find_rides;
DROP FUNCTION distanceCheck;
DROP VIEW vehicle_states;

--Create vehicle_types table
--No data will needed to be inserted into this table or changed

create table vehicle_types (
    sedan           char(5),
    truck           char(5),
    suv             char(3),
    crossover       char(9),
    minivan         char(7),
    bus             char(3)
);


--Create table vehicle owners

create table vehicle_owners (
--all fields are required for transactions to take place 
--and be able to contact owners

    owner_id                NUMBER          NOT NULL,
    owner_name              VARCHAR(50)     NOT NULL,
    owner_email             VARCHAR(50)     NOT NULL,
    credit_card_number      INT             NOT NULL,
    Primary key (owner_id)
);

--Create a sequence to auto increment the vehicle id PK
create sequence vehicle_id_seq
    start with 1
    increment by 1;

--Create vehicle table 
create table vehicles (
    vehicle_id          int             NOT NULL,
    owner_id            NUMBER,
    vehicle_type        varchar(10),
    vehicle_make        varchar(20),
    vehicle_year        char(4),
    vehicle_tag_number  varchar(7),
    vehicle_state       varchar(2),
    vehicle_seats       number,
    vehicle_luggage     char(25),
    --PK of vehicle ID
    Primary Key         (vehicle_id),
    --FK of owner ID since this is the owners vehicle and how 
    --we will tie it to billing customer
    FOREIGN KEY         (owner_id) REFERENCES vehicle_owners(owner_id) 
);

create table customer 
--CREATE NEW CUSTOMER TABLE
( 
   c_id                         NUMBER               NOT NULL,
   cname                        VARCHAR(50)          NOT NULL,
   email                        VARCHAR(50)          NOT NULL,
   payment_information          NUMBER               NOT NULL,
    PRIMARY KEY (c_id)
);

--Create a sequence to auto increment the distance id PK
create sequence distance_in start with 1 increment by 1;

CREATE TABLE distances (
    Distance_id		    INT            	 NOT NULL,
    Source_town		    VARCHAR2(50)   	 NOT NULL,
    Source_state		VARCHAR2(50)   	 NOT NULL,
    Destination_town    VARCHAR2(50)  	 NOT NULL,
    Destination_state	VARCHAR2(50)  	 NOT NULL,
    num_miles          	NUMBER         	 NOT NULL,
    PRIMARY KEY (distance_id)
    );

create sequence vehicle_owner_id_seq
    start with 1
    increment by 1;    

create or replace PROCEDURE owner_insert(
	   o_owner_name                 IN vehicle_owners.owner_name%TYPE,
	   o_owner_email                IN vehicle_owners.owner_name%TYPE,
       o_owner_credit_card_number   IN vehicle_owners.owner_name%TYPE)
IS
BEGIN
--insert statements which use nextval for PK automation
  INSERT INTO vehicle_owners (owner_id, owner_name, owner_email, credit_card_number) 
  Values (vehicle_owner_id_seq.nextval, o_owner_name, o_owner_email, 
        o_owner_credit_card_number);
        
exception when DUP_VAL_ON_INDEX THEN
    dbms_output.put_line('Duplicate entry. Please try again');
    
COMMIT;

END owner_insert;


create table payment
--CREATE TABLE PAYMENT 

(
   pid              NUMBER         NOT NULL,        
   owner_id         INT,
   c_id      	    NUMBER, 
   PRIMARY KEY      (pid),     
   FOREIGN KEY      (owner_id) REFERENCES vehicle_owners(owner_id),
   FOREIGN KEY      (c_id) REFERENCES customer(c_id)
);

CREATE TABLE trips
(
  trip_id		       NUMBER        		NOT NULL,
  c_id             	   NUMBER,
  owner_id             NUMBER,  
  date_of_trip         DATE	         		NOT NULL,
  trip_source          VARCHAR2(50)  		NOT NULL,
  destination  	       VARCHAR2(50)  		NOT NULL,
  payment_amount       NUMBER,      
  PRIMARY KEY (trip_id)
);

--Inserting information into vehicle_owners 



--procedure to run to insert vehicles
create or replace PROCEDURE vehicle_insert(
	   p_owner_id           IN vehicles.owner_id%TYPE,
	   p_vehicle_type       IN vehicles.vehicle_type%TYPE,
	   p_vehicle_make       IN vehicles.vehicle_make%TYPE,
       p_vehicle_year       IN vehicles.vehicle_year%TYPE,
       p_vehicle_tag_number IN vehicles.vehicle_tag_number%TYPE,
       p_vehicle_state      IN vehicles.vehicle_state%TYPE,
       p_vehicle_seats      IN vehicles.vehicle_seats%TYPE,
       p_vehicle_luggage    IN vehicles.vehicle_luggage%TYPE)
IS
BEGIN

--insert statements which use nextval for PK automation
  INSERT INTO vehicles (vehicle_id, owner_id, vehicle_type, vehicle_make, vehicle_year, 
        vehicle_tag_number, vehicle_state, vehicle_seats, vehicle_luggage) 
  Values (vehicle_id_seq.nextval, p_owner_id, p_vehicle_type, 
        p_vehicle_make, p_vehicle_year, p_vehicle_tag_number, p_vehicle_state, p_vehicle_seats
        , p_vehicle_luggage);
exception when DUP_VAL_ON_INDEX THEN
    dbms_output.put_line('Duplicate entry. Please try again');

  COMMIT;

END vehicle_insert;


--Procedure which can be run when a user wants to see all data for all
--vehicles of one vehicle type.
set serveroutput on;
CREATE OR REPLACE PROCEDURE 
displayVehicleType(vehicle_type_in IN  vehicles.vehicle_type%TYPE) IS
--cursor which adds all vehicle columns
CURSOR vehicleType_cursor IS
select vehicle_id, owner_id, vehicle_type, vehicle_make, vehicle_year, 
  vehicle_tag_number, vehicle_state, vehicle_seats, vehicle_luggage
from vehicles
--set vehicle_type variable equal to the user input
where vehicle_type = vehicle_type_in;
vehicle_row vehicleType_cursor%rowtype;
BEGIN
--where the input is equal to a row in the table, to find all info in cursor
For vehicle_row in vehicleType_cursor
--loop to print all required data from each column/row
LOOP
    dbms_output.put_line('The Vehicle ID is ' || vehicle_row.vehicle_id || '
    The owner ID for this vehicle is ' || vehicle_row.owner_id || '
    This is a ' || vehicle_row.vehicle_type || '
    The make is ' || vehicle_row.vehicle_make || '
    The model year is ' || vehicle_row.vehicle_year || '
    The vehicle tag number is ' || vehicle_row.vehicle_tag_number || '
    This vehicle is registered in ' || vehicle_row.vehicle_state || '
    This vehicle sits ' || vehicle_row.vehicle_seats || '
    And can hold ' || vehicle_row.vehicle_luggage || 'luggages');
END LOOp;

IF vehicle_type_in is NULL then
dbms_output.put_line('No vehicles of that type');
end IF;

COMMIT;
END;



INSERT INTO trips
(trip_id, c_id, owner_id, date_of_trip, trip_source, destination, payment_amount)
VALUES
(1,1,1, TO_DATE('3-Jan-21','DD-MON-RR'), 'Maryland', 'Virginia', null);
INSERT INTO trips
(trip_id, c_id, owner_id, date_of_trip, trip_source, destination, payment_amount)
VALUES
(2,2,2, TO_DATE('12-APR-21','DD-MON-RR'), 'BWI', 'Gaithursburg', null);
INSERT INTO TRIPS
(trip_id, c_id, owner_id, date_of_trip, trip_source, destination, payment_amount)
VALUES
(3,3,3, TO_DATE('17-Jul-21','DD-MON-RR'), 'Ellicott City', 'DC', null);
INSERT INTO trips
(trip_id, c_id, owner_id, date_of_trip, trip_source, destination, payment_amount)
VALUES
(4,4,4, TO_DATE('5-Oct-21','DD-MON-RR'), 'Baltimore', 'Ocean City', null);
INSERT INTO trips
(trip_id, c_id, owner_id, date_of_trip, trip_source, destination, payment_amount)
VALUES
(5,5,5, TO_DATE('23-Aug-21','DD-MON-RR'), 'Salisbury', 'Canada', null);

insert into customer
(c_id, cname, email, Payment_information)
   values (1,'Bob','bob@gmail.com',5547845785692541);

insert into customer
(c_id, cname, email, Payment_information)
   values (2,'Dave','dave@gmail.com',2584485178956415);

insert into customer
(c_id, cname, email, Payment_information)
  values(3,'Mark','mark@gmail.com',5541447812895643);

insert into customer
(c_id, cname, email, Payment_information)
   values(4,'Steve','steve@gmail.com',5542228456123895);

insert into customer
(c_id, cname, email, Payment_information)
values(5,'Conner','conner@gmail.com',2361845978451145);



--Insert values into distances. 
INSERT INTO distances (distance_id, source_town, source_state, destination_town, destination_state, num_miles)
VALUES (distance_in.nextVal, 'Baclay', 'Maryland', 'Edgewater', 'Florida', 752);

INSERT INTO distances (distance_id, source_town, source_state, destination_town, destination_state, num_miles)
VALUES (distance_in.nextVal, 'Baltimore', 'Maryland', 'Queens', 'New York', 206);

INSERT INTO distances (distance_id, source_town, source_state, destination_town, destination_state, num_miles)
VALUES (distance_in.nextVal, 'Annapolis', 'Maryland', 'Chicago', 'Illinois', 723);

INSERT INTO distances (distance_id, source_town, source_state, destination_town, destination_state, num_miles)
VALUES (distance_in.nextVal, 'Richmond', 'Virgina', 'Dallas', 'Texas', 1276);

INSERT INTO distances (distance_id, source_town, source_state, destination_town, destination_state, num_miles)
VALUES (distance_in.nextVal, 'Eglin', 'Florida', 'Birmingham', 'Alabama', 247);


insert into payment 
(pid)
   values(1);

insert into payment 
(pid)
   values(2);

insert into payment
(pid)
   values(3);

insert into payment 
(pid)
   values(4);

insert into payment 
(pid)
   values(5);
   
------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_vehicle
(v_owner_id     IN  vehicle_owners.owner_email%type)
as
BEGIN  
    Delete from(Select * from vehicles
    inner join vehicle_owners on vehicle_owners.owner_id = vehicles.owner_id 
    WHERE owner_email = v_owner_id); 
END;
 



Create or replace view vehicle_states (vehicle_id, vehicle_state) AS
select vehicle_state,
count(vehicle_id)
from vehicles
group by vehicle_state
order by count(vehicle_id);

--Run vehicle_states view
Select * from vehicle_states;

SET SERVEROUT ON;
--Procedure to add values to the distance table.
--Values passed by function call
--Contain data to be added
CREATE OR REPLACE PROCEDURE distance_insert(
    d_id                IN distances.distance_id%type,
    d_source_town       IN distances.source_town%TYPE,
    d_source_state      IN distances.source_state%TYPE,
    d_destination_town  IN distances.destination_town%TYPE,
    d_destination_state IN distances.destination_state%TYPE,
    d_num_miles         IN distances.num_miles%TYPE
    )
IS
BEGIN
--To insert values into existing attributes.
INSERT INTO distances(DISTANCE_ID, SOURCE_TOWN, SOURCE_STATE, DESTINATION_TOWN, 
                      DESTINATION_STATE, NUM_MILES)
            values (d_id, d_source_town, d_source_state, 
            d_destination_town, d_destination_state, d_NUM_MILES);
--Exception to catch improper input.
EXCEPTION WHEN  DUP_VAL_ON_INDEX THEN
dbms_output.put_line('Duplicate Data. Please try again');
    COMMIT;
END distance_insert;


--This function exists to validate
--The existence of a vehicle moving
--Toward a specific destination.
SET SERVEROUT ON;
--The user passes their source and destination.
CREATE OR REPLACE Function distanceCheck(
d_source_town IN varchar2,
d_source_state IN varchar2,
d_destination_town IN varchar2,
d_destination_state IN varchar2)
RETURN varchar2 IS
exist varchar2(50);
--Cursor to interact with existing table.
--Checks to see if the input matches.
CURSOR distance_cursor IS
select distance_id from distances 
where source_town = d_source_town AND source_state = d_source_state AND
      destination_town = d_destination_town AND destination_state = d_destination_state;
BEGIN
--Assigns the sql results to the exist variable.
open distance_cursor;
fetch distance_cursor into exist;
if distance_cursor%notfound then
exist := 'N/A';
end if;
close distance_cursor;
RETURN exist;
END;



--Procedure to display available rides
--as per user request
--The user requests the values that are passed.
SET SERVEROUT ON;
CREATE OR REPLACE PROCEDURE find_rides(
    d_source_town       IN varchar2,
    d_source_state      IN varchar2,
    d_destination_town  IN varchar2,
    d_destination_state IN varchar2,
    d_num_seats         IN varchar2,
    d_num_luggage       IN varchar2
    )
IS
--Local variables
d_vehicle_id vehicles.vehicle_id%TYPE;
d_owner_id vehicles.owner_id%TYPE;
exist varchar(50);
--Cursor to navigate table and interact with variables.
CURSOR vehicle_cursor is select vehicle_id, owner_id, vehicle_seats, 
vehicle_luggage 
from vehicles
where vehicle_seats >= d_num_seats AND vehicle_luggage >= d_num_luggage;
vehicle_row vehicle_cursor%rowtype;
--Begin sql statements
BEGIN
--Function call 
SELECT distanceCheck(d_source_town, d_source_state, d_destination_town, d_destination_state) INTO exist from distances
where (distances.source_town = d_source_town AND distances.source_state = d_source_state AND
        distances.destination_town = d_destination_town AND distances.destination_state = d_destination_state);
--Loop through the cursor.
for vehicle_row in vehicle_cursor
loop      
if exist != 'N/A' then

--Display available rides.
dbms_output.put_line('Vehicle ID:' ||vehicle_row.vehicle_id || ' Driver ID:' || vehicle_row.owner_id
                     || ' Number of Seats:' || vehicle_row.vehicle_seats|| 'Number of Luggage:' || vehicle_row.vehicle_luggage);
Else
--If norides are found
 dbms_output.put_line('Incorrect distance qualifiers');
end if; 
end loop;
--Exception handler
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No vehicle available.');  
    commit;
END;


--This Procedure shows the user
--The amount of avalible rides
--That leave from their starting point.
SET SERVEROUT ON;
--The user passes the town they are leaving from.
CREATE OR REPLACE Procedure one_leg(d_source_town IN varchar2) IS
--Local variables
exist varchar2(50);
p_id distances.distance_id%type;
--Cursor to fetch data from existing records.

CURSOR distance_cursor IS SELECT source_town, destination_town, destination_state, num_miles
FROM distances
WHERE distances.source_town = d_source_town;



distance_row distance_cursor%rowtype;
BEGIN
select distance_id 
into p_id
from Distances
WHERE distances.source_town = d_source_town;

for distance_row in distance_cursor

loop
if distance_row.source_town != d_source_town then 
dbms_output.put_line('Incorrect source town');
--Display one-legged trips.
else 
dbms_output.put_line('Source town: ' ||distance_row.source_town || ' Destination Town: ' || distance_row.destination_town
                    ||' Destination State: '|| distance_row.destination_state || ' Miles: ' || distance_row.num_miles);
end if;
end loop;
--Exception Handler
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No trips leaving from that destination');  
    commit;
end;



--Procedure to insert a record of a trip
CREATE OR REPLACE PROCEDURE insertTrip(
               p_trip IN TRIPS.TRIP_ID%TYPE,
	   p_customer IN TRIPS.C_ID%TYPE,
	   p_vehicleowner IN TRIPS.OWNER_ID%TYPE,
               p_date IN TRIPS.DATE_OF_TRIP%TYPE,
	   p_source IN TRIPS.TRIP_SOURCE%TYPE,
	   p_destination IN TRIPS.DESTINATION%TYPE,
               p_paymentamount IN TRIPS.PAYMENT_AMOUNT%TYPE)
IS
BEGIN

INSERT INTO TRIPS (TRIP_ID, C_ID, OWNER_ID, DATE_OF_TRIP, TRIP_SOURCE, DESTINATION, PAYMENT_AMOUNT) 
VALUES (p_trip, p_customer, p_vehicleowner, p_date, p_source, p_destination, p_paymentamount);

  COMMIT;

END;
/



create or replace PROCEDURE displayID 
(   
   p_c_id number,
   p_owner_id number,
   p_source varchar2,
   P_destination varchar2,
   p_date_of_trip date
)
AS
   p_trip_id   trips.trip_id%TYPE;

BEGIN

   SELECT trip_id
     INTO p_trip_id
     FROM trips
     WHERE c_id = p_c_id and owner_id = p_owner_id and trip_source = p_source and date_of_trip = p_date_of_trip;
  
   DBMS_OUTPUT.PUT_LINE('Trip ID: ' || p_trip_id);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Trip ID not found.');
END;

