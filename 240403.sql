USE classicmodels;

SELECT * FROM orders;

-- page96 
-- 그룹별 구매 지표 구하기
-- 국가별, 도시별 매출액
-- 매출액 : orderdetails
-- 국가 : customers 
-- 중간 매개 테이블 : orders 

-- 결합 : LEFT JOIN 
SELECT * 
FROM orders A 
LEFT JOIN orderdetails B 
ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
ON A.customernumber = C.customernumber;

-- p98 Country, City로 그룹핑,  SUM(priceeach * quantityordered)
SELECT 
	C.country
    , C.city
    , SUM(priceeach * quantityordered) AS SALES
FROM orders A 
LEFT JOIN orderdetails B 
ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
ON A.customernumber = C.customernumber
GROUP BY 1, 2
ORDER BY 1, 2
;

-- 북미(USA, Canada) vs 비북미 매출액 비교
SELECT 
	CASE WHEN country IN ('USA', 'Canada') THEN '북미' 
    ELSE '비북미' 
    END country_grp
    , SUM(priceeach * quantityordered) AS SALES
FROM orders A 
LEFT JOIN orderdetails B 
ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
ON A.customernumber = C.customernumber
GROUP BY 1
ORDER BY 2
;

-- page 103, 매출 Top5 국가 매출
-- 순위 : windows 함수 
-- ROW_NUMBER, RANK, DENSE_RANK 

CREATE TABLE classicmodels.stat AS 
SELECT 
	C.country
    , SUM(priceeach * quantityordered) SALES 
FROM orders A 
LEFT JOIN orderdetails B 
ON A.ordernumber = B.ordernumber
LEFT JOIN customers C 
ON A.customernumber = C.customernumber
GROUP BY 1
ORDER BY 2 DESC
;

SELECT * FROM stat;


SELECT * FROM (
	SELECT 
		C.country
		, SUM(priceeach * quantityordered) SALES 
	FROM orders A 
	LEFT JOIN orderdetails B 
	ON A.ordernumber = B.ordernumber
	LEFT JOIN customers C 
	ON A.customernumber = C.customernumber
	GROUP BY 1
	ORDER BY 2 DESC
) A
;

-- 서브쿼리
SELECT * 
FROM (
	SELECT
		country
		, sales 
		, DENSE_RANK() OVER(ORDER BY sales DESC) RNK
	FROM (
		SELECT 
			C.country
			, SUM(priceeach * quantityordered) SALES 
		FROM orders A 
		LEFT JOIN orderdetails B 
		ON A.ordernumber = B.ordernumber
		LEFT JOIN customers C 
		ON A.customernumber = C.customernumber
		GROUP BY 1
		ORDER BY 2 DESC
	) A
) B 
WHERE RNK <= 5;

-- p106
SELECT 
	country
    , sales 
    , DENSE_RANK() OVER(ORDER BY sales DESC) RNK
FROM stat;

-- 출력 결과를 다시 테이블로 생성 
CREATE TABLE stat_rnk AS 
SELECT 
	country
    , sales
    , DENSE_RANK() OVER(ORDER BY sales DESC) RNK
FROM stat
;

SELECT * 
FROM stat_rnk
WHERE RNK BETWEEN 1 AND 5;


-- 재구매율
-- 연도별 재구매율을 구해본다. 
-- page 112
-- JOIN 하는 대상이 같은 테이블 (자기 자신)
-- SELF JOIN : 값은 값을 공유한다! 
SELECT 
	
    A.customernumber
    , A.orderdate
    , B.customernumber
    , B.orderdate
FROM orders A
LEFT JOIN orders B
ON A.customernumber = B.customernumber 
	AND substr(A.orderdate, 1, 4) = substr(B.orderdate, 1, 4) - 1
;


-- 
SELECT 
	C.country                     -- 국가
    , SUBSTR(A.orderdate, 1, 4) YY
    , COUNT(DISTINCT A.customernumber) BU_1
    , COUNT(DISTINCT B.customernumber) BU_2
    , COUNT(DISTINCT B.customernumber) / COUNT(DISTINCT A.customernumber) AS retention_rate
FROM orders A 
LEFT JOIN orders B
ON A.customernumber = B.customernumber 
	AND substr(A.orderdate, 1, 4) = substr(B.orderdate, 1, 4) - 1
LEFT JOIN customers C 
ON A.customernumber = C.customernumber 
GROUP BY 1, 2
;
	
    
-- BEST Seller 
-- 미국으로 한정해 데이터 뽑아주세요
-- 미국의 Top5 판매량 차량 모델  추출 해달라. 

-- 국가 필드 : customers
-- 차량모델 : products 테이블
SELECT * FROM products;

CREATE TABLE CLASSICMODELS.PRODUCT_SALES AS
SELECT D.PRODUCTNAME,
SUM(QUANTITYORDERED*PRICEEACH) SALES
FROM CLASSICMODELS.ORDERS A
LEFT
JOIN CLASSICMODELS.CUSTOMERS B
ON A.CUSTOMERNUMBER = B.CUSTOMERNUMBER
LEFT
JOIN CLASSICMODELS.ORDERDETAILS C
ON A.ORDERNUMBER = C.ORDERNUMBER
LEFT
JOIN CLASSICMODELS.PRODUCTS D
ON C.PRODUCTCODE = D.PRODUCTCODE
WHERE B.COUNTRY = 'USA'
GROUP
BY 1
;

SELECT *
FROM
(SELECT *,
ROW_NUMBER() OVER(ORDER BY SALES DESC) RNK
FROM CLASSICMODELS.PRODUCT_SALES) A
WHERE RNK <=5
ORDER
BY RNK
;

-- p117 Churn Rate
-- 마케팅 : 활성고객, 비활동 고객 
-- Churn에 대한 정의가 필요함, 회사 바이 회사
-- 분석하기 좋은 회사 : 쇼핑몰
-- 커리어 추천 : 경력직 이직 성과를 가지고 이직, 
-- Churn에 대한 정의 or 기준 / 구매기준, 접속기준 ==> 회사의 이익 

-- 마지막 구매일이 언제인지 확인하자
SELECT 
	MAX(orderdate) AS MAX_최근구매날짜
    , MIN(orderdate) AS MIN_최초구매날짜
FROM orders;

SELECT 
	customernumber
    , MAX(orderdate) MX_ORDER -- 최근구매날짜
    , MIN(orderdate) MN_ORDER -- 최초구매날짜
FROM orders
GROUP BY 1;

-- 2005-06-01 기준으로 며칠이 소요되었는지 계산한다. 
-- DATEDIFF() 
SELECT
	customernumber
    , MX_ORDER
    , '2005-06-01' AS END_POINT
    , DATEDIFF('2005-06-01', MX_ORDER) DIFF
FROM (
	SELECT 
		customernumber
		, MAX(orderdate) MX_ORDER -- 최근구매날짜
	FROM orders
	GROUP BY 1
) BASE;

-- 추가 
SELECT
	*
    , CASE WHEN DIFF >= 90 THEN 'CHURN'
		ELSE 'NON-CHURN' END CHURN_TYPE
FROM (
	SELECT
		customernumber
		, MX_ORDER
		, '2005-06-01' AS END_POINT
		, DATEDIFF('2005-06-01', MX_ORDER) DIFF
	FROM (
		SELECT 
			customernumber
			, MAX(orderdate) MX_ORDER -- 최근구매날짜
		FROM orders
		GROUP BY 1
	) BASE
) BASE
;

-- Churn Type CNT 
SELECT 
	CASE WHEN DIFF >= 90 THEN 'CHURN'
		ELSE 'NON-CHURN' END CHURN_TYPE
	, COUNT(DISTINCT customernumber) N_CUS
FROM (
	SELECT
		customernumber
		, MX_ORDER
		, '2005-06-01' AS END_POINT
		, DATEDIFF('2005-06-01', MX_ORDER) DIFF
	FROM (
		SELECT 
			customernumber
			, MAX(orderdate) MX_ORDER -- 최근구매날짜
		FROM orders
		GROUP BY 1
	) BASE
) BASE
GROUP BY 1
;

-- 4/3일 Churn Rate 70% / 일 매출액 100만원
-- 4/4일 Churn Rate 72% / 일 매출액 110만원
-- 4/4일 Churn Rate 59% / 일 매출액 50만원

