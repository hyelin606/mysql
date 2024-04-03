USE mydata2;

CREATE TABLE tasks (
	id INT PRIMARY KEY, 
    title VARCHAR(255) NOT NULL, 
    start_date DATE, 
    due_date DATE
);

SHOW TABLES;

-- 외래키
-- 각 task는 체크리스트가 있다고 가정한다. 
-- Primary Key는 두개의 컬럼으로 구성
-- 기본키에 제약 조건을 추가
-- task_id는 외래키 : task 테이블의 id 컬럼 참조 
CREATE TABLE checklists(
  id INT, 
  task_id INT, 
  title VARCHAR(255) NOT NULL, 
  is_completed BOOLEAN NOT NULL DEFAULT FALSE, 
  PRIMARY KEY (id, task_id), 
  FOREIGN KEY (task_id) 
      REFERENCES tasks (id) 
      ON UPDATE RESTRICT 
      ON DELETE CASCADE
);

-- AUTO INCREMENT 
CREATE TABLE contacts(
	id INT AUTO_INCREMENT PRIMARY KEY, 
    name VARCHAR(255) NOT NULL, 
    email VARCHAR(255) NOT NULL
);

-- DATA INSERT
INSERT INTO contacts(name, email)
VALUES('evan', 'evan@mysql.org');

SELECT * FROM contacts;

-- 가장 최근에 추가된 데이터의 ID 조회
SELECT LAST_INSERT_ID();

-- 기존 컬럼에 AUTO_INCREMENT 컬럼 추가

CREATE TABLE subscribers(
   email VARCHAR(320) NOT NULL UNIQUE
);

INSERT INTO subscribers(email)
VALUES ('evan@mysql.org');

SELECT * FROM subscribers;

ALTER TABLE subscribers
ADD id INT AUTO_INCREMENT PRIMARY KEY;

INSERT INTO subscribers(email)
VALUES ('sara@mysql.org');

SELECT * FROM subscribers;

/*------------
- ADD COLUMN -
-------------*/

CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);

-- 컬럼 추가
ALTER TABLE vendors
ADD COLUMN phone VARCHAR(15) AFTER name;

-- DESC statement를 통해 추가된 컬럼 확인
DESC vendors;

-- 또다른 컬럼 추가
ALTER TABLE vendors
ADD COLUMN vendor_group INT NOT NULL;

DESC vendors;

-- 데이터 추가
INSERT INTO vendors(name,phone,vendor_group)
VALUES('IBM','(408)-298-2987',1),
      ('Microsoft','(408)-298-2988',1);
      
SELECT 
  id, name, phone, vendor_group 
FROM 
  vendors;
  
-- 또 다른 컬럼 2개를 추가한다. 
ALTER TABLE vendors
ADD COLUMN email VARCHAR(100) NOT NULL,
ADD COLUMN hourly_rate decimal(10,2) NOT NULL;

SELECT 
  id, name, phone, vendor_group, email, hourly_rate
FROM 
  vendors;
  
/*------------
- DROP COLUMN -
-------------*/

ALTER TABLE vendors
DROP COLUMN email; 

DESCRIBE vendors;

-- 두 개의 컬럼 제거 
ALTER TABLE vendors
DROP COLUMN phone, 
DROP COLUMN vendor_group;

DESCRIBE vendors;

/*------------
-  INSERT  -
-------------*/

DROP TABLE IF EXISTS hr.tasks;

CREATE TABLE tasks (
  task_id INT AUTO_INCREMENT PRIMARY KEY, 
  title VARCHAR(255) NOT NULL, 
  start_date DATE, 
  due_date DATE, 
  priority TINYINT NOT NULL DEFAULT 3, 
  description TEXT
);

INSERT INTO tasks(title, priority) 
VALUES('Learn MySQL INSERT Statement', 1);

SELECT * FROM tasks;

-- DEFAULT VALE
INSERT INTO tasks(title, priority) 
VALUES('디폴트 키워드', DEFAULT);

 SELECT * FROM tasks;
 
-- 날짜 입력 
INSERT INTO tasks(title, start_date, due_date) 
VALUES ('날짜 입력', '2024-01-30', '2024-01-30');

SELECT * FROM tasks;
 
INSERT INTO tasks(title, start_date, due_date) 
VALUES 
  (
    '함수 사용', CURRENT_DATE(), CURRENT_DATE()
  );
  
SELECT * FROM tasks;

-- 여러 데이터 입력
INSERT INTO tasks(title, priority)
VALUES
	('My first task', 1),
	('It is the second task',2),
	('This is the third task of the week',3);
    
SELECT * FROM tasks;

/*------------
-  UPDATE  -
-------------*/

-- Mary의 email
USE classicmodels;
SELECT 
    firstname, 
    lastname, 
    email
FROM
    employees
WHERE
    employeeNumber = 1056;
    
-- 메일 갱신
UPDATE employees 
SET 
    email = 'sara@gmail.com'
WHERE
    employeeNumber = 1056;
    
SELECT 
    firstname, 
    lastname, 
    email
FROM
    employees
WHERE
    employeeNumber = 1056;
    
-- 다중 컬럼 수정
UPDATE employees 
SET 
    firstname = 'sara',
    lastname = 'evan',
    email = 'sara.evan@gmail.com'
WHERE
    employeeNumber = 1056;
    
SELECT 
    firstname, 
    lastname, 
    email
FROM
    employees
WHERE
    employeeNumber = 1056;
    
/*------------
-  DELEE  -
-------------*/
CREATE TABLE buildings (
    building_no INT PRIMARY KEY AUTO_INCREMENT,
    building_name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL
);

CREATE TABLE rooms (
    room_no INT PRIMARY KEY AUTO_INCREMENT,
    room_name VARCHAR(255) NOT NULL,
    building_no INT NOT NULL,
    FOREIGN KEY (building_no)
        REFERENCES buildings (building_no)
        ON DELETE CASCADE
);

INSERT INTO buildings(building_name,address)
VALUES('ACME Headquaters','3950 North 1st Street CA 95134'),
      ('ACME Sales','5000 North 1st Street CA 95134');
      
INSERT INTO rooms(room_name,building_no)
VALUES('Amazon',1),
      ('War Room',1),
      ('Office of CEO',1),
      ('Marketing',2),
      ('Showroom',2);
      
SELECT * FROM rooms;

DELETE FROM buildings 
WHERE building_no = 2;

-- building_no 2 또한 삭제됨
SELECT * FROM rooms;

-- ON DELETE CASCADE
USE information_schema;

SELECT 
    table_name
FROM
    referential_constraints
WHERE
    constraint_schema = 'classicmodels'
        AND referenced_table_name = 'buildings'
        AND delete_rule = 'CASCADE';
        
-- GetCustomerLevel()
USE classicmodels;

DELIMITER $$
CREATE PROCEDURE GetCustomerLevel(
    IN  pCustomerNumber INT, 
    OUT pCustomerLevel  VARCHAR(20))
BEGIN
    DECLARE credit DECIMAL(10,2) DEFAULT 0;

    SELECT creditLimit 
    INTO credit
    FROM customers
    WHERE customerNumber = pCustomerNumber;

    IF credit > 50000 THEN
        SET pCustomerLevel = 'PLATINUM';
    END IF;
END$$

SELECT 
    customerNumber, 
    creditLimit
FROM 
    customers
WHERE 
    creditLimit > 50000
ORDER BY 
    creditLimit DESC;
    
CALL GetCustomerLevel(141, @level);
SELECT @level;

-- VIEW
SELECT 
    customerName, 
    checkNumber, 
    paymentDate, 
    amount
FROM
    customers
INNER JOIN
    payments USING (customerNumber);
    
CREATE VIEW customerPayments
AS 
SELECT 
    customerName, 
    checkNumber, 
    paymentDate, 
    amount
FROM
    customers
INNER JOIN
    payments USING (customerNumber);

SELECT * FROM customerPayments;