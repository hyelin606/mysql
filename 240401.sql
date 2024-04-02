-- 한줄 주석 처리

/*
여러줄 주석 처리
*/

-- Case 1
USE classicmodels;
SELECT * FROM customers;

-- Case 2
SELECT * FROM classicmodels.customers;

-- 현재 DB 확인
-- SELECT DATABASE();

SHOW TABLES;

DESC orders;

-- page 26
SELECT 
customernumber
, phone
, contactLastName
FROM customers;

-- 집계함수
-- COUNT, SUM, AVG 등
SELECT
SUM(AMOUNT)
, COUNT(checknumber)
FROM payments;

-- 모든 결과 조회 : * 사용,
-- 단, 실무에서 이거 쓰면 사수한테 혼남
SELECT * FROM payments;

-- 1억개의 데이터가 존재
-- 1억개의 데이터를 출력하겠다는 의미

-- p.30 AS
-- 컬럼명 변경

SELECT 
COUNT(productcode) AS N_PRODUCTS
FROM products;

-- DISTINCT 중복 제거
SELECT DISTINCT ordernumber
FROM orderdetails
ORDER BY ordernumber;

-- WHERE
SELECT *
FROM products
WHERE productline = 'Motorcycles';

-- WHERE, BETWEEN 연산자alter
-- 요청사항 2010~2014년에 출시된 상품 번호 필요
SELECT *
FROM orderdetails
WHERE priceeach BETWEEN 30 AND 50
;

-- WHERE 대소 관계 표현
SELECT *
FROM orderdetails
WHERE priceeach >= 30
ORDER BY priceeach ASC;

-- WHERE : IN
-- 꼭 기억하자 !!
# SELECT 컬럼명
# FROM 테이블명
# WHERE 컬럼명 IN(값1, 값2); -- OR 연산자 대체
-- 서비쿼리 할 때도 매우 자주 사용됨

SELECT *
FROM orderdetails
WHERE ordernumber IN (10184, 10104, 10124);

SELECT * 
FROM orderdetails
WHERE ordernumber = 10184 OR ordernumber = 10104 OR ordernumber = 10124;

DESC customers;
SELECT country
FROM customers
WHERE country NOT IN ('USA', 'CANADA');

-- IS NULL / IS NOT NULL 연산자
-- 블로그 주제로 작성

SELECT employeenumber
FROM employees
WHERE reportsTO IS NULL;

SELECT employeenumber
FROM employees
WHERE reportsTO IS NOT NULL;





