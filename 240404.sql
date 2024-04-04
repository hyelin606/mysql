USE instacart;

select * from aisles;
select * from departments;
select * from order_products__prior;
select * from orders;
select * from products;

-- 지표 추출
-- 1. 전체 주문 건수
-- 테이블: orders
select 
	count(distinct order_ID) F
from orders
;

-- 2. 전체 구매자 수
select
	count(distinct user_id) BU
from orders
;

-- 3. 상품별 주문 건수
select 
	B.product_name
    , count(distinct A.order_id) F
from order_products__prior A
left join products B
on A.product_id = B.product_id
group by 1
order by 2 desc
;

-- 장바구니에 가장 먼저 넣는 상품 10개
select
	product_id
    , sum(case when add_to_cart_order = 1 then 1 else 0 end) f_1st
from order_products__prior
group by 1
;

-- 순위 매기기
select *
, row_number() over(order by f_1st desc) rnk
from 
(
select
	product_id
    , sum(case when add_to_cart_order = 1 then 1 else 0 end) f_1st
from order_products__prior
group by 1
) A
;

-- 상위 10개만
select *
from
(
select *
, row_number() over(order by f_1st desc) rnk
from 
(
select
	product_id
    , sum(case when add_to_cart_order = 1 then 1 else 0 end) f_1st
from order_products__prior
group by 1
) A ) base
where rnk between 1 and 10
;

-- order by를 활용하여 간단하게
select
	product_id
    , sum(case when add_to_cart_order = 1 then 1 else 0 end) f_1st
from order_products__prior
group by 1
order by 2 desc
limit 10
;

-- 시간별 주문 건수
select
	order_hour_of_day
    , count(distinct order_id) F
from orders
group by 1
order by 1
;

-- 첫 구매 후 다음 구매까지 걸린 평균 일수
select
	avg(days_since_prior_order) avg_recency
from orders
where order_number = 2 -- 이전 주문이 이루어진지 며칠 뒤에 구매를 했느냐
;

-- 주문 건당 평균 구매 상품 수 (UPT, Unit Per Transaction)
select
	count(product_id) / count(distinct order_id) upt
from order_products__prior
;

-- 인당 평균 주문 건수
select count(distinct order_id) / count(distinct user_id) avg_f
from orders
;

-- 재구매율이 가장 높은 상품 10개
-- 1. 상품별 재구매율 계산
select
	product_id
    , sum(case when reordered = 1 then 1 else 0 end) / count(*) ret_ratio
from order_products__prior
group by 1
;

-- 2. 재구매율 순위 생성
select *
	, row_number() over (order by ret_ratio desc)rnk
from 
(select
	product_id
    , sum(case when reordered = 1 then 1 else 0 end) / count(*) ret_ratio
from order_products__prior
group by 1
) A
;

-- Top10 재구매율 상품 추출
select *
from
(
select *
	, row_number() over (order by ret_ratio desc)rnk
from 
(select
	product_id
    , sum(case when reordered = 1 then 1 else 0 end) / count(*) ret_ratio
from order_products__prior
group by 1
) A ) A
where rnk between 1 and 10
;

-- 4. department별 재구매율이 가장 높은 상품 10개
select *
from (
    select *,
        row_number() over (order by ret_ratio desc) as rnk
    from (
        select
            C.department,
            B.product_id,
            sum(case when reordered = 1 then 1 else 0 end) / count(*) ret_ratio
        from order_products__prior A
        left join products B 
        on A.product_id = B.product_id
        left join departments C
        on B.department_id = C.department_id
        group by 1, 2) A ) A
where ret_ratio between 1 and 10
;

-- p.174 구매자 분석
-- 10분위 분석
select 
	count(distinct user_id)
from 
(
select 
user_id
	, count(distinct order_id) f
    from orders
    group by 1
) A
;

CREATE TEMPORARY TABLE INSTACART.USER_QUANTILE AS
SELECT *,
CASE WHEN RNK <= 316 THEN 'Quantile_1'
WHEN RNK <= 632 THEN 'Quantile_2'
WHEN RNK <= 948 THEN 'Quantile_3'
WHEN RNK <= 1264 THEN 'Quantile_4'
WHEN RNK <= 1580 THEN 'Quantile_5'
WHEN RNK <= 1895 THEN 'Quantile_6'
WHEN RNK <= 2211 THEN 'Quantile_7'
WHEN RNK <= 2527 THEN 'Quantile_8'
WHEN RNK <= 2843 THEN 'Quantile_9'
WHEN RNK <= 3159 THEN 'Quantile_10' END quantile
FROM
(SELECT *,
ROW_NUMBER() OVER(ORDER BY F DESC) RNK
FROM
(SELECT USER_ID,
COUNT(DISTINCT ORDER_ID) F
FROM INSTACART.ORDERS
GROUP
BY 1) A) A
;

select
	quantile
    , sum(f) f
from user_quantile
group by 1
;

-- p.181 상품 분석
select 
	A.product_id
    , sum(reordered) / sum(1) reorder_rate
    , count(distinct order_id) f
from order_products__prior A
left join products B
on A.product_id = B.product_id
group by product_id
having count(distinct order_id) > 10
;










