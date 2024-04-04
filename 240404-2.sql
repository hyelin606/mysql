-- p.192
-- UK commerce 데이터를 이용한 리포트 작성

-- 국가별, 상품별 구매자 수 및 매출액
use mydata;
select * from dataset3;

select
	country
    , stockcode
    , count(distinct customerid) bu
    , sum(quantity * unitprice) sales
from dataset3
group by 1,2
order by 3 desc, 4 desc
;

-- 특정 상품 구매자가 가장 많이 구매한 상품은?
-- 장바구니 분석
-- 예: 맥주를 구매할 경우, 기저귀를 구매하는 경향이 있는지 없는지 연관성 파악

-- 1. 특정 상품을 구매한 구매자가 어떤 상품을 많이 구매하는지 살펴보자
-- 가장많이 판매된 Top2 상품을 모두 구매한 고객을 찾아보자
-- 이 고객군이 구매한 상품 코드를 조회한다.

-- 2개 상품 조회 (max)
select *
	, row_number() over(order by qty desc) rnk
from (
	select
		stockcode
		, sum(quantity) qty
	from dataset3
	group by 1
) A
;

-- 1,2인 데이터만 조회
SELECT 
	stockcode
FROM (
	SELECT 
		* 
		, ROW_NUMBER() OVER(ORDER BY QTY DESC) RNK
	FROM (
		SELECT 
			stockcode
			, SUM(quantity) QTY 
		FROM dataset3
		GROUP BY 1
	) A
) A
WHERE RNK BETWEEN 1 AND 2
;

SELECT customerID 
FROM dataset3
GROUP BY 1
HAVING MAX(CASE WHEN stockcode = '84077' THEN 1 ELSE 0 END) = 1
	AND MAX(CASE WHEN stockcode = '85123A' THEN 1 ELSE 0 END) = 1
; -- 13488, 14669, 14911, 17211

SELECT * FROM dataset3;

SELECT DISTINCT a.customerID
FROM 
  (SELECT customerID FROM dataset3 WHERE stockcode = '84077') a
JOIN 
  (SELECT customerID FROM dataset3 WHERE stockcode = '85123A') b
ON a.customerID = b.customerID
ORDER BY 1
; -- 13488, 14669, 14911, 17211

-- 두 상품을 모두 구매한 구매자의 고객번호
create table mydata.bu_list as
select
	customerid
from dataset3
group by 1
having max(case when stockcode = '84077' then 1 else 0 end) = 1
and max(case when stockcode = '85123A' then 1 else 0 end) = 1
;

select
	distinct stockcode
from dataset3
where customerid in (select customerid from bu_list)
and stockcode not in ('84077', '85123A')
;

-- 국가별 재구매율
SELECT A.COUNTRY,
SUBSTR(A.INVOICEDATE,1,4) YY,
COUNT(DISTINCT B.CUSTOMERID)/COUNT(DISTINCT A.CUSTOMERID) RETENTION_RATE
FROM (SELECT DISTINCT COUNTRY,
INVOICEDATE,
CUSTOMERID
FROM MYDATA.DATASET3) A
LEFT
JOIN (SELECT DISTINCT COUNTRY,
INVOICEDATE,
CUSTOMERID
FROM MYDATA.DATASET3) B
ON SUBSTR(A.INVOICEDATE,1,4) = SUBSTR(B.INVOICEDATE,1,4) -1
AND A.COUNTRY = B.COUNTRY
AND A.CUSTOMERID = B.CUSTOMERID
GROUP
BY 1,2
ORDER
BY 1,2;

SELECT 
	*
FROM (
	SELECT DISTINCT COUNTRY,
	INVOICEDATE,
	CUSTOMERID
	FROM MYDATA.DATASET3) A
LEFT JOIN (SELECT DISTINCT COUNTRY,
	INVOICEDATE,
	CUSTOMERID
	FROM MYDATA.DATASET3
) B
ON SUBSTR(A.INVOICEDATE,1,4) = SUBSTR(B.INVOICEDATE,1,4) -1
AND A.COUNTRY = B.COUNTRY
AND A.CUSTOMERID = B.CUSTOMERID
;
-- GROUP BY 1,2
-- ORDER BY 1,2;

-- p.202
-- 코호트 분석
-- 실무적: sql에서 코호트 분석 쿼리를 작성하는 것보다는 python, R, Tableau 활용하여 시각화로 결과 도출하기

-- 첫 구매월을 기준으로 각 그룹 간의 패턴을 파악해본다.
-- 먼저 고객별로 첫 구매일을 구한다.
select
	customerid
    , min(invoicedate) nmdt
from dataset3
group by 1
;

-- 각 고객의 주문일자, 구매액 조회
select
	customerid
    , invoicedate
    , unitprice * quantity sales
from dataset3
;

select *
from
(select
	customerid
    , min(invoicedate) nmdt
from dataset3
group by 1
) A
left join
(select
	customerid
    , invoicedate
    , unitprice * quantity sales
from dataset3) B
on A.customerid = B.customerid
;

-- 구매월을 기준으로 코호트분석
-- mndt는 각 고객의 최초 구매월을 의미
-- datediff를 이용하여 첫 구매 이후, 몇 개월 뒤에 구매가 이루어졌는지 기간 확인
-- sales: 해당 기간에 구매한 총 매출액

SELECT 
	SUBSTR(MNDT, 1, 7) MM
    , TIMESTAMPDIFF(MONTH, MNDT, INVOICEDATE) DATEDIFF
    , COUNT(DISTINCT A.customerid) BU
    , SUM(SALES) SALES
FROM (
	SELECT 
		customerid
		, MIN(invoicedate) MNDT 
	FROM dataset3
	GROUP BY 1) A 
LEFT JOIN (SELECT 
	customerid
    , invoicedate
    , unitprice * quantity sales
FROM dataset3) B
ON A.customerid = B.customerid
GROUP BY 1, 2
;

-- 고객 세그먼트 (RFM)
-- 타겟 마케팅: 세대별 / 연령별

select
	customerid
    , max(invoicedate) mxdt
from dataset3
group by 1
;

select max(invoicedate) from dataset3; -- 마지막 구매일 2011-12-01

-- 이후 2011-12-02로부터의 timer interval을 계산한다.
select 
	customerid
    , datediff('2011-12-02', mxdt) recency
from
(
select
	customerid
    , max(invoicedate) mxdt
from dataset3
group by 1
) A
;

-- frequency는 구매 건수
-- monetary는 구매 금액
select
	customerid
    , count(distinct invoiceNo) frequency
    , sum(quantity * unitprice) monetary
from dataset3
group by 1
;

-- 쿼리 합치기
select 
	customerid
    , datediff('2011-12-02', mxdt) recency
    , frequency
    , monetary
from
(
select
	customerid
    , max(invoicedate) mxdt
    , count(distinct invoiceNo) frequency
    , sum(quantity * unitprice) monetary
from dataset3
group by 1
) A
;

-- 재구매 segment
-- 동일한 상품을 2개 연도에 걸쳐서 구매한 고객과 그렇지 않은 고객 나누자.
-- 예) A라는 상품을 2010년도, 2011년도에 걸쳐 구매한 고객
-- 	vs. A라는 상품을 특정 연도에만 구매한 고객으로 나눌 수 있느냐.

-- 고객별, 상품별 구매 연도를 unique하게 카운트
select
	customerid
    , stockcode
    , count(distinct substr(invoicedate, 1, 4)) unique_yy
from dataset3
group by 1,2
order by 3 desc
;

-- unique_yy가 2 이상인 고객, 그렇지 않은 고객으로 구분하자.
select
	customerid
    , max(unique_yy) mx_unique_yy
from
(
select
	customerid
    , stockcode
    , count(distinct substr(invoicedate, 1, 4)) unique_yy
from dataset3
group by 1,2
) A
group by 1
;

-- mx_unique_yy가 2 이상인 경우는 1, 그렇지 않은 경우는 0으로 설정
-- case when 사용
select
	customerid
    , case when mx_unique_yy >= 2 then 1 else 0 end repurchase_segment
from
(
select
	customerid
    , max(unique_yy) mx_unique_yy
from
(
select
	customerid
    , stockcode
    , count(distinct substr(invoicedate, 1, 4)) unique_yy
from dataset3
group by 1,2
) A
group by 1) A
group by 1
;

SELECT customerid
FROM (
	SELECT 
		customerid
		, CASE WHEN mx_unique_yy >= 2 THEN 1 else 0 END repurchase_segment
	FROM (
		SELECT 
			customerid
			, MAX(UNIQUE_YY) mx_unique_yy
		FROM (
			SELECT 
				customerid
				, stockcode
				, COUNT(DISTINCT SUBSTR(invoiceDate, 1, 4)) UNIQUE_YY 
			FROM dataset3
			GROUP BY 1, 2
		) A 
		GROUP BY 1
	) A 
	GROUP BY 1
) A
WHERE repurchase_segment = 1
;
