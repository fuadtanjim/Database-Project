drop table counter cascade constraints;
drop table bus cascade constraints;
drop table passenger cascade constraints;
drop table ticket cascade constraints;
drop table employees cascade constraints;





create table counter(
countername varchar(100),
caddress varchar(100),
ccontact number(15),
cid number(10),
journey_date date,
dtime varchar(10),
primary key(countername)
);

create table bus(
route_id number(10),
seatno number(10),
coach number(10),
source varchar(100),
destination varchar(100),
primary key(route_id)
);

create table passenger(
pname varchar(100),
paddress varchar(100),
route_id number(10),
pcontact number(15),
primary key(pname),
FOREIGN KEY(route_id) REFERENCES bus(route_id) ON DELETE CASCADE
);


create table ticket(
coach number(10),
seat_fare number(10),
total_taka number(10),
pname varchar(100),
cname varchar(100),
discount number(10),
primary key(coach),
FOREIGN KEY (pname) REFERENCES passenger(pname) ON DELETE CASCADE,
FOREIGN KEY (cname) REFERENCES counter(countername) ON DELETE CASCADE
);


create table employees(
employee_id number(6),
employee_name varchar(20),
employee_countername varchar(100),
salary NUMBER(8,2) check(salary>0),
commission_pct NUMBER(2,2),
primary key(employee_id)
);




---------------------------------FOREIGN KEY  OUTSIDE TABLE---------------------------------------
ALTER TABLE employees ADD CONSTRAINT FK_employees FOREIGN KEY (employee_countername) REFERENCES counter(countername) ON DELETE CASCADE;




---------------------INSERT-----------------------

insert into counter values('fulbari','khulna',01837717859,123,'01-MAR-2017','5.30pm');
insert into bus values(133,5,16,'khulna','ctg');
insert into passenger values('p','khulna',133,01764514245);
insert into passenger values('t','khulna',133,01765245555);
insert into passenger values('k','khulna',133,01765245545);
insert into ticket values(17,1000,1000,'p','fulbari',null);
insert into ticket values(13,1500,1500,'p','fulbari',null);
insert into employees values(11,'Jd','fulbari',7000,null);
insert into employees values(11,'sam','fulbari',7500,null);





------------------------DESCRIBE TABLES-----------------------

describe counter;
describe bus;
describe passenger;
describe ticket;
describe employees;

---------------------------------------------------------------




alter table count
modify cname varchar(100);

select coach from ticket where seat_fare between 1000 and 1500;

select max(seat_fare) from ticket;

select count(*),sum(total_taka) from ticket;




-------------------PL/SQL--------------------



SET SERVEROUTPUT ON
DECLARE
full_price ticket.total_taka%type;
coach_number number(10);
discount_price ticket.total_taka%type;
BEGIN
coach_number:=16;

SELECT total_taka INTO full_price
FROM ticket
WHERE
coach like coach_number;

IF full_price<500 THEN
discount_price:=full_price;
ELSIF full_price>=500 and full_price<1000 THEN
discount_price:=full_price-(full_price*.20);
ELSIF full_price>=1000 and full_price<1500 THEN
discount_price:=full_price-(full_price*.30);
ELSE
discount_price:=full_price-(full_price*.40);
END IF;
DBMS_OUTPUT.PUT_LINE (coach_number || 'Full Price: '||full_price||' Discounted Pice: '|| ROUND(discount_price,2));
EXCEPTION
         WHEN others THEN
	      DBMS_OUTPUT.PUT_LINE (SQLERRM);
END;
/
SHOW ERRORS;









------------------PROCEDURE-----------------


-----------------Procedure to show passenger details---------------

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE show_passenger(p_name passenger.pname%TYPE) IS 
   
   p_a passenger.paddress%type;
   p_id passenger.route_id%type;
   p_con passenger.pcontact%type;
BEGIN
    SELECT paddress,route_id,pcontact INTO p_a,p_id,p_con
    FROM passenger
    WHERE pname =p_name;
	
    DBMS_OUTPUT.PUT_LINE( p_name||' '||' '||p_a||' '||p_id||' '||' '|| p_con);
END;
/
SHOW ERRORS;


-----------------Procedure to add passenger---------------
CREATE OR REPLACE PROCEDURE add_passenger (
  passengername passenger.pname%TYPE,
  passengeraddress passenger.paddress%TYPE) IS
BEGIN
  INSERT INTO passenger (pname, paddress)
  VALUES (passengername, passengeraddress);
  COMMIT;
END add_passenger;
/
SHOW ERRORS;



----------------END PROCEDURE---------------









-----------------TRIGGER-------------------

CREATE TRIGGER TR_DISCOUNT 
BEFORE UPDATE OR INSERT ON TICKET 
FOR EACH ROW 
BEGIN
IF :NEW.TOTAL_TAKA>1000 AND :NEW.TOTAL_TAKA<1500 THEN
:NEW.DISCOUNT:=80;
ELSIF :NEW.TOTAL_TAKA>=1500 AND :NEW.TOTAL_TAKA<2000 THEN
:NEW.DISCOUNT:=120;
ELSIF :NEW.TOTAL_TAKA>2000 AND :NEW.TOTAL_TAKA<4000 THEN
:NEW.DISCOUNT:=200;
ELSIF :NEW.TOTAL_TAKA>=4000 THEN
:NEW.DISCOUNT:=250;
END IF;
END TR_DISCOUNT;
/

insert into ticket values(17,1000,1000,'p','fulbari',null);
insert into ticket values(13,1500,1500,'p','fulbari',null);


--------------------------------------------------------






----------------FUNCTION------------------

---------------function for total ticket price--------------

CREATE OR REPLACE FUNCTION total_ticketprice RETURN NUMBER IS
   total ticket.total_taka%type;
BEGIN
  SELECT SUM(total_taka) INTO total
  FROM ticket;
   RETURN total;
END;
/

SET SERVEROUTPUT ON
BEGIN
dbms_output.put_line('Total price: ' || total_ticketprice);
END;
/


--------------------function for annual salary and commission-----------------
CREATE OR REPLACE FUNCTION get_annual_comp(
  sal  IN employees.salary%TYPE,
  comm IN employees.commission_pct%TYPE)
 RETURN NUMBER IS
BEGIN
  RETURN (NVL(sal,0) * 12 + (NVL(comm,0) * nvl(sal,0) * 12));
END get_annual_comp;
/

------------------END OF FUNCTION-------------------





-------------------CURSOR----------------------

SET SERVEROUTPUT ON
DECLARE
     CURSOR passenger_cur IS SELECT pname,pcontact FROM passenger;
  passenger_record passenger_cur%ROWTYPE;

BEGIN
OPEN passenger_cur;
      LOOP
        FETCH passenger_cur INTO passenger_record;
        EXIT WHEN passenger_cur%ROWCOUNT > 2;
      DBMS_OUTPUT.PUT_LINE ('Name : ' || passenger_record.pname || '  ' || passenger_record.pcontact);
      END LOOP;
      CLOSE passenger_cur;   
END;
/


-----------------------------------------------






----------------------FOR LOOP------------------------

SET SERVEROUTPUT ON
DECLARE
   counter    number(10);
   name       passenger.pname%type;
   
  
BEGIN

   FOR counter IN 1..3
   LOOP

      SELECT pname
      INTO name
      FROM passenger
      WHERE
      route_id = counter;

      DBMS_OUTPUT.PUT_LINE ('Record ' || counter);
      DBMS_OUTPUT.PUT_LINE ('Name '|| name);
      DBMS_OUTPUT.PUT_LINE ('-----------');
   END LOOP;

   EXCEPTION
      WHEN others THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
END;
/


------------------------------------------------
