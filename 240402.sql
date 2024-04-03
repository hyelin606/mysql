-- 새로운 스키마명: mydata2
USE mydata2;

-- 테이블 생성
CREATE TABLE employees(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(225) NOT NULL,
    salary DECIMAL(10, 2)
);

INSERT INTO employees (name, salary) VALUES
('A', 40000.00),
('B', 52000.00),
('John Doe', 50000.00),
('Jane Smith', 60000.00),
('Jim Brown', 55000.00),
('Jack Black', 52000.00),
('Jill White', NULL),
('Jessica Jones', 62000.00),
('Jeremy Irons', 58000.00),
('Jasmine Rice', 50000.00),
('Jason Bourne', 55000.00),
('Julia Roberts', NULL),
('Jake Blues', 53000.00),
('Janis Joplin', 61000.00),
('Johnny Cash', 57000.00),
('Joan Baez', 59000.00),
('Jimi Hendrix', 56000.00),
('Jeff Beck', 54000.00),
('Janet Jackson', 60000.00),
('James Brown', 61000.00),
('Joni Mitchell', 58000.00),
('Jerry Garcia', 57000.00);

SELECT * FROM employees;

-- ALTER TABLE: 테이블을 변경
ALTER TABLE employees
ADD COLUMN department VARCHAR(255);

-- 데이터 추가
-- INSERT (X)

UPDATE employees SET department = 'A' WHERE id BETWEEN 1 AND 9;
UPDATE employees SET department = 'B' WHERE id BETWEEN 10 AND 16;
UPDATE employees SET department = 'C' WHERE id BETWEEN 1 AND 22;

SELECT * FROM employees;

-- NULL이 있는 데이터 확인
SELECT COUNT(*) FROM employees; -- 22개
SELECT COUNT(salary) FROM employees; -- 20개, NULL 제외하고 계산
SELECT SUM(salary) FROM employees; -- NULL을 제외하고 계산
SELECT AVG(salary) FROM employees; -- NULL을 제외하고 계산
SELECT salary FROM employees ORDER BY salary; -- NULL이 가장 앞에서부터 정렬됨

-- 교재 p.41
-- LIKE 연산자는 텍스트 관련

USE classicmodels; -- DB명 변경

SELECT addressline1
FROM customers
WHERE addressline1 LIKE '%ST%';

-- GROUP BY
SELECT
	country
    , city
    , COUNT(customernumber) N_CUSTOMERS
FROM customers
GROUP BY country, city;

SELECT * FROM customers WHERE country = 'USA';

-- p.46
-- USA 거주자 수를 계산하고, 그 비중을 구하기
-- CASE WHEN 은 if 구문과 비슷
SELECT 
	SUM(CASE WHEN country = 'USA' THEN 1 ELSE 0 END) N_USA
    , SUM(CASE WHEN country = 'USA' THEN 1 ELSE 0 END) / COUNT(*) USA_RATIO 
FROM customers;  

-- p.49
-- customers, orders 테이블 결합
-- ordernumber, country 출력
-- LEFT JOIN 사용
SELECT A.ordernumber
FROM orders A
LEFT JOIN customers B
on A.customernumber = B.customernumber;

-- p.56
-- customoers 테이블 country 컬럼을 이용해 북미 / 비북미 출력하는 컬럼
SELECT
	country
    , CASE WHEN country IN ('USA', 'Canada') THEN 'North America'
		ELSE 'Others'
        END AS region
FROM customers;

-- 북미, 비북미 거주 고객의 수를 계산
SELECT
    CASE WHEN country IN ('USA', 'Canada') THEN 'North America'
		ELSE 'Others'
        END AS region
	, COUNT(customernumber) N_CUSTOMERS
FROM customers
GROUP BY 1
;

-- p.59
-- products 테이블에서 buyprice 컬럼으로 순위 매기기 (오름차순)
SELECT 
	buyprice
    , ROW_NUMBER() OVER(ORDER BY buyprice) ROWNUMBER
    , RANK() OVER(ORDER BY buyprice) RNK
    , DENSE_RANK() OVER(ORDER BY buyprice) DENSERANK
FROM
	PRODUCTS
;

SELECT * FROM products;

SELECT 
	productline
	buyprice
    , ROW_NUMBER() OVER(PARTITION BY productline ORDER BY buyprice) ROWNUMBER
    , RANK() OVER(PARTITION BY productline ORDER BY buyprice) RNK
    , DENSE_RANK() OVER(PARTITION BY productline ORDER BY buyprice) DENSERANK
FROM
	PRODUCTS
;

-- p.62
-- NYC에 거주하는 고객들의 주문 번호를 조회
-- 서브쿼리 코드 작성 시, 기본원칙: Task를 분할하고 합치기
-- 메인쿼리: 주문 번호
-- 서브쿼리: NYC에 거주하는 고객

-- 메인쿼리
SELECT ordernumber
FROM orders;

-- 서브쿼리
SELECT customernumber FROM customers WHERE city = 'NYC';

SELECT ordernumber
FROM orders
WHERE customernumber IN (
		SELECT customernumber FROM customers WHERE city = 'NYC'
	);

-- p.87
-- 매출액(일자별, 월별, 연도별)
-- 일별 매출액
-- 테이블 : orders, orderdetails
-- 주문일, 판매액 필요
USE classicmodels;

SELECT 
	A.orderdate
    , priceeach * quantityordered AS revenue
FROM 
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
ORDER BY A.orderdate; -- 1

-- 월별 매출액 산출
-- 2003-01, 2003-01-06 텍스트에서 
-- 월별 매출액 (책 안보고 쿼리 작성하기!!) 

SELECT DATE_FORMAT('2003-01-06', '%Y-%m');
SELECT DATE_FORMAT(orderdate, '%Y-%m') FROM orders;
SELECT SUBSTR('2003-01-06', 1, 7);

SELECT 
	DATE_FORMAT(A.orderdate, '%Y-%m')
    , priceeach * quantityordered AS revenue
FROM 
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
ORDER BY 1; -- 1

-- p.91
-- 구매자 수, 구매 건수(일자별, 월별, 연도별)
SELECT 
	orderdate
    , customernumber
    , ordernumber
FROM orders
ORDER BY customernumber
;

-- 중복값 체크
-- ordernumber는 중복값 없음
SELECT 
	COUNT(ordernumber) N_ORDERS
	, COUNT(DISTINCT ordernumber) N_ORDERS_DISTINCT
FROM orders
;

SELECT
	orderdate
    , COUNT(DISTINCT customernumber) N_PURCHASER
    , COUNT(ordernumber) N_ORDERS
FROM orders
GROUP BY 1
ORDER BY 1
;

-- 인당 매출액 (연도별)
-- 연도별 매출액과 구매자수를 구하기!!
SELECT 
	SUBSTR(A.orderdate, 1, 4) YY
    , COUNT(DISTINCT A.customernumber) N_PURCHASER
    , SUM(priceeach * quantityordered) AS sales
    , SUM(priceeach * quantityordered) / COUNT(DISTINCT A.customernumber) AS AMV
FROM orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;
