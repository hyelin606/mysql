USE mydata;

select * from dataset2;

-- Division Name 별 평균 평점

select
	`Division Name`
    , avg(rating) avg_rate
from dataset2
group by 1
order by 2 desc;

SELECT
	`DEPARTMENT NAME`
    , AVG(RATING) AVG_RATE
FROM dataset2
GROUP BY 1
ORDER BY 1;

select *
from dataset2
where `department name` = 'trend'
	and rating <= 3;

-- 연령대 10으로    
select
	`department name`
	, floor(age/10) * 10 ageband
    , age
from dataset2
where `department name` = 'tops'
	and rating <= 3
;

-- trend의 평점 3점 이하 리뷰의 연령 분포
select
	floor(age/10) * 10 ageband
    , count(*) as cnt
from dataset2
where `department name` = 'trend'
	and rating <= 3
group by 1
order by 2 desc
;

-- department 연령별 리뷰 수
-- trend의 전체 연령별 리뷰 수
select
	floor(age/10) * 10 ageband
    , count(*) as cnt
from dataset2
where `department name` = 'trend'
group by 1
order by 2 desc
;

-- trend 전체 리뷰 수: 30, 40, 50 순으로 작성
-- 평점 3점 이하일 때: 50대 리뷰 수가 가장 많음
select *
from dataset2
where `department name` = 'trend'
and rating <= 3
and age between 50 and 59 limit 10
;

-- 평점이 낮은 상품의 주요 complain 찾기
-- department별 평점이 낮은 10개 상품을 임시 테이블로 생성
select
	`department name`
    , `clothing id`
    , avg(rating) avg_rate
from dataset2
group by 1, 2
;

-- department별 순위 생성
SELECT * FROM
(
	SELECT *
    , ROW_NUMBER() OVER(PARTITION BY `DEPARTMENT NAME` ORDER BY AVG_RATE) RNK
    FROM (
		SELECT 
			`DEPARTMENT NAME`
            , `CLOTHING ID`
            , AVG(RATING) AVG_RATE 
		FROM dataset2
        GROUP BY 1, 2
    ) A
) A 
WHERE RNK <= 10
;

CREATE TABLE mydata.stat AS 
SELECT * FROM
(
	SELECT *
    , ROW_NUMBER() OVER(PARTITION BY `DEPARTMENT NAME` ORDER BY AVG_RATE) RNK
    FROM (
		SELECT 
			`DEPARTMENT NAME`
            , `CLOTHING ID`
            , AVG(RATING) AVG_RATE 
		FROM dataset2
        GROUP BY 1, 2
    ) A
) A 
WHERE RNK <= 10
;

select * from stat;

select `clothing id`
from stat
where `department name` = 'bottoms'
;

-- 평점이 낮은 10개 상품의 clothing id의 리부 학인
-- 메인쿼리: 리뷰 확인
-- 서브쿼리: 평점이 낮은 10개 상품의 clothing id

select `clothing id`, `review text` from dataset2
where `clothing id` in (
	select `clothing id`
	from stat
	where `department name` = 'bottoms'
);

-- 연령별 worst department
-- p.140
-- 1. department 연령별로 가장 낮은 점수 계산
-- 2. 생성한 점수를 기반으로 rank 생성
-- 3. rank 값이 1인 데이터 조회

-- 1. department 연령별로 가장 낮은 점수 계산
select
	`department name`
    , floor(age/10) * 10 ageband
    , avg(rating) avg_rating
from dataset2
group by 1, 2
;

-- 2. 생성한 점수를 기반으로 rank 생성
select *
, row_number() over(partition by ageband order by avg_rating) rnk
from
(select
	`department name`
    , floor(age/10) * 10 ageband
    , avg(rating) avg_rating
from dataset2
group by 1, 2
) A
;

-- 3. rank 값이 1인 데이터 조회
select *
from
	(
	select *
		, row_number() over(partition by ageband order by avg_rating) rnk
	from
		(
		select
			`department name`
			, floor(age/10) * 10 ageband
			, avg(rating) avg_rating
		from dataset2
		group by 1, 2
	) A ) A
where rnk = 1
;

-- p.143 SIze Complain
select
	`review text`
    , case when `review text` like '%size%' then 1 else 0 end size_yn
from dataset2
;

select 
	sum(case when `review text` like '%size%' then 1 else 0 end) n_size
    , count(*) n_total
from dataset2
;

select 
	sum(case when `review text` like '%size%' then 1 else 0 end) n_size
    , sum(case when `review text` like '%large%' then 1 else 0 end) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) n_tight
    , count(*) n_total
from dataset2
;

-- p.146
-- 제품군별로 Complain 상황 확인
select
	`department name`
	, sum(case when `review text` like '%size%' then 1 else 0 end) n_size
    , sum(case when `review text` like '%large%' then 1 else 0 end) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) n_tight
    , sum(1) n_total -- count(*) n_total
from dataset2
group by 1
;

-- 연령별, 제품군별
select
	floor(age/10) * 10 ageband
    , `department name`
	, sum(case when `review text` like '%size%' then 1 else 0 end) n_size
    , sum(case when `review text` like '%large%' then 1 else 0 end) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) n_tight
    , sum(1) n_total -- count(*) n_total
from dataset2
group by 1, 2
order by 1, 2
;

-- 비율로 확인하기
select
	floor(age/10) * 10 ageband
    , `department name`
	, sum(case when `review text` like '%size%' then 1 else 0 end) / sum(1) n_size
    , sum(case when `review text` like '%large%' then 1 else 0 end) / sum(1) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) / sum(1)   n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) / sum(1)  n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) / sum(1)  n_tight
    , sum(1) n_total -- count(*) n_total
from dataset2
group by 1, 2
order by 1, 2
;

-- p.149
select
	`clothing id`
    , sum(case when `review text` like '%size%' then 1 else 0 end) n_size
from dataset2
group by 1
;

-- Size 타입을 추가해 집계
-- 기준 Clothing id
select
	`clothing id`
	, sum(case when `review text` like '%size%' then 1 else 0 end) n_size_t
    , sum(case when `review text` like '%large%' then 1 else 0 end) / sum(1) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) / sum(1)   n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) / sum(1)  n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) / sum(1)  n_tight
    , sum(1) n_total -- count(*) n_total
from dataset2
group by 1
;

create table mydata.size_stat as 
select
	`clothing id`
	, sum(case when `review text` like '%size%' then 1 else 0 end) n_size_t
    , sum(case when `review text` like '%large%' then 1 else 0 end) / sum(1) n_large
    , sum(case when `review text` like '%loose%' then 1 else 0 end) / sum(1)   n_loose
    , sum(case when `review text` like '%small%' then 1 else 0 end) / sum(1)  n_small
    , sum(case when `review text` like '%tight%' then 1 else 0 end) / sum(1)  n_tight
    , sum(1) n_total -- count(*) n_total
from dataset2
group by 1
;

select * from size_stat