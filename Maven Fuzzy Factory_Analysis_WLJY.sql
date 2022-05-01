-- WEBSITE_SESSIONS
SELECT * FROM website_sessions;
-- WEBSITE_PAGEVIEWS
SELECT * FROM website_pageviews;
-- ORDERS
SELECT * FROM orders;

--
-- Traffic Source Analysis
--
SELECT * FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000;

SELECT website_sessions.utm_content,
		COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders,
        COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id=website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

SELECT utm_source, utm_campaign, http_referer,
		COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

SELECT 
		COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders,
        COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id=website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' AND 
website_sessions.utm_source= 'gsearch' AND website_sessions.utm_campaign= 'nonbrand';


--
-- Bid Optimization
--

SELECT 
YEAR(created_at) AS created_yr,
WEEK(created_at) AS created_wk,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1,2;

SELECT order_id, primary_product_id, items_purchased,created_at FROM orders WHERE order_id BETWEEN 31000 AND 32000;

SELECT primary_product_id,
COUNT(DISTINCT CASE WHEN items_purchased =1 THEN order_id ELSE NULL END) AS orders_w_1_item,
COUNT(DISTINCT CASE WHEN items_purchased =2 THEN order_id ELSE NULL END) AS orders_w_2_item,
COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

SELECT 
-- year(created_at) as created_yr,
-- week(created_at) as created_wk,
YEARWEEK(created_at),
MIN(DATE(created_at)) AS week_start_date, 
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE utm_source='gsearch' AND created_at < '2012-05-10' AND utm_campaign='nonbrand'
-- group by 1,2;
GROUP BY YEARWEEK(created_at); #每一周的最小的那一天

Select website_sessions.device_type,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id=website_sessions.website_session_id
WHERE utm_source='gsearch'  AND utm_campaign='nonbrand' AND website_sessions.created_at < '2012-05-11'
group by device_type;

SELECT 
-- year(created_at) as created_yr,
-- week(created_at) as created_wk,

MIN(DATE(created_at)) AS week_start_date,
count(case when device_type='desktop' then website_session_id else null end) as desk_session,
count(case when device_type='mobile' then website_session_id else null end) as mob_session
FROM website_sessions
WHERE utm_source='gsearch' 
	AND created_at >'2012-04-15' 
	AND created_at < '2012-06-09' 
	AND utm_campaign='nonbrand' 
-- group by 1,2;
GROUP BY YEARWEEK(created_at); #每一周的最小的那一天

--
-- Top Website Content
--

SELECT pageview_url,
COUNT(DISTINCT website_pageview_id) AS views
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1
ORDER BY 2 DESC;

-- DROP TEMPORARY TABLE IF EXISTS landing_pages;
-- CREATE TEMPORARY TABLE first_pageview
SELECT website_session_id,
MIN(website_pageview_id) AS min_pve_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1;  -- 第一次出现一个session_id时对应的pageview_id

select 
website_pageviews.pageview_url as landing_page,-- aka 'entry page'
count(distinct first_pageview.website_session_id) as sessions_hitiing_this_lander
from first_pageview -- 上表
left join website_pageviews
on first_pageview.min_pve_id=website_pageviews.website_pageview_id
group by 1;

use mavenfuzzyfactory;
SELECT 
pageview_url,
COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

SET global time_zone = '-5:00';

-- DROP TEMPORARY TABLE IF EXISTS  first_pageview;

SELECT 
	website_pageviews.pageview_url AS landing_page,-- aka 'entry page'
	COUNT(first_pageview.website_session_id) AS sessions_hitiing_this_lander
    
FROM (SELECT website_session_id,
			MIN(website_pageview_id) AS min_pve_id
			FROM website_pageviews
            WHERE created_at < '2012-06-12'
			GROUP BY 1) AS first_pageview
            
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id=first_pageview.min_pve_id
GROUP BY website_pageviews.pageview_url;


--
-- Landing page performace & testing 
--
-- Business context: we want to see landing page performance for a certain time period
-- STEP 1 : find the first website_pageview_id for relevant sessions
-- STEP 2 : identify the landing page of each session
-- STEP 3 : counting pageviews for each session, to identify 'bounces'
-- 跳出率是指在只访问了入口页面（例如网站首页）就离开的访问量与所产生总访问量的百分比。跳出率计算公式：跳出率=访问一个页面后离开网站的次数/总访问次数
-- STEP 4 : summarizing total sessions and bounced sessions, by Landing page

-- finding the minuimum website pageview id associated with each session we care about
-- 找出每一个session id 对应的最小的pageview_id（找到进入页）
SELECT 
Website_pageviews.website_session_id,
MIN(Website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id =website_pageviews.website_session_id
AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
website_pageviews.website_session_id;


-- same quary as above, but this time we are storing the dataset as a temporary table

create temporary table first_pageviews_demo
SELECT 
Website_pageviews.website_session_id,
MIN(Website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id =website_pageviews.website_session_id
AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
website_pageviews.website_session_id;

SELECT * FROM first_pageviews_demo;

-- next, we'll bring in the landing page in each session
-- 找到每一个人的第一个进入页
CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT 
	first_pageviews_demo.website_session_id,
	website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id; -- website pageview is the landing page view
        
SELECT * FROM sessions_w_landing_page_demo;

-- next, we make a table to include a count of pageviews per session

-- first,i'll show you all of the sessions.then we will limit to bounced sessions and create a temp table
-- 计算一下每一个session id用了几个网页，i.e.对应了几个pageview id
-- CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
sessions_w_landing_page_demo.website_session_id,
sessions_w_landing_page_demo.landing_page,
COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_demo
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id=sessions_w_landing_page_demo.website_session_id
GROUP BY 
sessions_w_landing_page_demo.website_session_id,
sessions_w_landing_page_demo.landing_page
HAVING 
COUNT(website_pageviews.website_pageview_id)=1;

Select * from bounced_sessions_only;


Select
	sessions_w_landing_page_demo.website_session_id,
	sessions_w_landing_page_demo.landing_page,
	bounced_sessions_only.website_session_id as bounced_website_session_id
from sessions_w_landing_page_demo
	left join bounced_sessions_only
		on sessions_w_landing_page_demo.website_session_id= bounced_sessions_only.website_session_id
order by 
	sessions_w_landing_page_demo.website_session_id;


-- final output 
	-- we will use the same query we previous ran, and ran a count of records
    -- we will group by landing page, and then we'll add a counce rate column

Select
	sessions_w_landing_page_demo.landing_page,
    count(Distinct sessions_w_landing_page_demo.website_session_id) as sessions,
    count(Distinct bounced_sessions_only.website_session_id) as bounced_sessions,
    count(Distinct bounced_sessions_only.website_session_id)/count(Distinct sessions_w_landing_page_demo.website_session_id) as bounce_rate
from sessions_w_landing_page_demo
left join bounced_sessions_only
on sessions_w_landing_page_demo.website_session_id= bounced_sessions_only.website_session_id
group by sessions_w_landing_page_demo.landing_page;

-- -------------------------------------
-- Calculating bounce rates
drop temporary table if exists A;
create temporary table A
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
	INNER JOIN website_sessions as ws
	ON ws.website_session_id =wp.website_session_id
	AND ws.created_at < '2012-06-14'
GROUP BY wp.website_session_id;

Select * from A;

drop temporary table if exists B;
create temporary table B
Select 
	A.website_session_id,
	wp.pageview_url as landing_page
from A
left join website_pageviews as wp
on wp.website_pageview_id=A.min_pageview_id;

Select * from B;

drop temporary table if exists C;
create temporary table C
Select 
	B.website_session_id,
	B.landing_page,
	count(wp.website_pageview_id) AS count_of_pages_viewed

FROM B
	LEFT JOIN website_pageviews as wp
	ON wp.website_session_id=B.website_session_id
    
GROUP BY 
	B.website_session_id,
	B.landing_page
HAVING 
	COUNT(wp.website_pageview_id)=1;

Select * from C;

-- select * from website_pageviews
-- where website_session_id=175252;

-- create temporary table D
-- Select
-- 	B.website_session_id,
-- 	B.landing_page,
-- 	C.website_session_id as bounced_website_session_id
-- from B
-- 	left join C
-- 		on B.website_session_id= C.website_session_id
-- order by 
-- 	B.website_session_id;
--     
-- Select * from D;
    
Select
    count(Distinct B.website_session_id) as total_sessions,
    count(Distinct C.website_session_id) as bounced_sessions,
    count(Distinct C.website_session_id)/count(Distinct B.website_session_id) as bounce_rate
from B
left join C
on B.website_session_id= C.website_session_id;


-- Analyzing landing page tests

select 
min(created_at) as first_created_at,
min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url='/lander-1'
and created_at is not null; -- this is the first time Lander one was displayed to a customer on the website

-- first_created_at 2012-06-19 00:35:54
-- first_pageview_id 23504'

drop temporary table if exists A;
create temporary table A -- first test pageviews
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
	INNER JOIN website_sessions as ws
	ON ws.website_session_id =wp.website_session_id
	AND ws.created_at < '2012-07-28'
    AND wp.website_pageview_id > 23504
    AND utm_source = 'gsearch'
    And utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;

Select * from A;

drop temporary table if exists B;
create temporary table B -- nonbrand_test_sessions_w_landing_page
Select 
	A.website_session_id,
	wp.pageview_url as landing_page
from A
left join website_pageviews as wp
on wp.website_pageview_id=A.min_pageview_id
where wp.pageview_url in ('/home','/lander-1');

Select * from B;

drop temporary table if exists C;
create temporary table C -- nonbrand_test_bounced_sessions
Select 
	B.website_session_id,
	B.landing_page,
	count(wp.website_pageview_id) AS count_of_pages_viewed

FROM B
	LEFT JOIN website_pageviews as wp
	ON wp.website_session_id=B.website_session_id
    
GROUP BY 
	B.website_session_id,
	B.landing_page
HAVING 
	COUNT(wp.website_pageview_id)=1;

Select * from C;

    
Select
	B.landing_page,
    count(Distinct B.website_session_id) as total_sessions,
    count(Distinct C.website_session_id) as bounced_sessions,
    count(Distinct C.website_session_id)/count(Distinct B.website_session_id) as bounce_rate
from B
left join C
on B.website_session_id= C.website_session_id
group by B.landing_page;

-- Landing page trend analysis 

drop temporary table if exists A;
create temporary table A -- sessions_w_min_pv_id_and_view_count
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) AS min_pageview_id,
    count(wp.website_pageview_id) as count_pageviews
FROM website_pageviews as wp
	INNER JOIN website_sessions as ws
	ON ws.website_session_id =wp.website_session_id
	AND ws.created_at between '2012-06-01'and '2012-08-31'
    AND utm_source = 'gsearch'
    And utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;

Select * from A;

drop temporary table if exists B;
create temporary table B -- sessions_w_counts_lander_and_created_At
Select 
	A.website_session_id,
	A.min_pageview_id,
	A.count_pageviews,
	wp.pageview_url as landing_page,
    wp.created_at as session_created_at
from A
left join website_pageviews as wp
on wp.website_pageview_id=A.min_pageview_id;
Select * from B;


Select
	yearweek(session_created_at) as year_week,
	min(date(session_created_at)) as week_start_date,
    count(Distinct website_session_id) as total_sessions,
    count(distinct case when count_pageviews=1 then website_session_id else null end) as bounced_sessions,
    count(distinct case when count_pageviews=1 then website_session_id else null end)*1.0/count(distinct website_session_id) as bounced_rate,
    count(distinct case when landing_page='/home' then website_session_id else null end) as home_sessions,
    count(distinct case when landing_page='/lander-1' then website_session_id else null end) as lander_sessions
from B
group by yearweek(session_created_at);

-- bounce rate starting in 60%, by time traffic primarily going to the lander, we se bounced rate closer to 50%


-- 
-- Analyzing & Testing conversion funnels
-- 

-- Demo on Building Conversion Funnels
-- Business context
	-- We want to build a mini conversion funnel, from /lander-2 to /cart
    -- we want to know how many people reach each step and also dropoff rates
    -- for simplicity of the demo, we're looking at/lander-2 tranffic only
    -- fro simplicity of the demo, we're looking at customers who like MR.Fuzzy only 
    
-- Step 1: Select all pageviews for relevant sessions
-- Step 2: Identify each relevant pageview as the specific funnel step
-- Step 3: Create the session-level conversion funnel view
-- Step 4: aggregate the data to assess funnel performance


Select * from website_pageviews where website_session_id=1059;
-- first I will show you all of the pageviews we care about
-- then, I will remove the comments from my flag columns one by one show you what that looks like 

-- 把一个session_id 的所有网页log 标记为1和0 
SELECT 
ws.website_session_id,
wp.pageview_url,
wp.created_at AS pageview_created_at,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
ON ws.website_session_id=wp.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo
AND wp.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
ws.website_session_id,
wp.created_at;

-- next we will put the previous query inside a subquery 
-- we will group by website_session_id, and take the max() of each of the flags
-- this max() becomes a made_it flag for that session, to show the session made it there
-- 把一个session_id 的所有网页log 标记为1和0 并总结到一行
create temporary table session_level_made_it_flags_down
select 
website_session_id,
max(products_page) as product_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it
-- max(shipping_page) as shipping_made_it,
-- max(billing_page) as billing_made_it,
-- max(thankyou_page) as thanyou_made_it
from (
	SELECT 
	ws.website_session_id,
	wp.pageview_url,
	wp.created_at AS pageview_created_at,
	case when pageview_url='/products' then 1 else 0 end as products_page,
	case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
	case when pageview_url='/cart' then 1 else 0 end as cart_page
	FROM website_sessions AS ws
	LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id=wp.website_session_id
	WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo
	AND wp.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
	ORDER BY 
	ws.website_session_id,
	wp.created_at) as pageview_level
group by website_session_id;

Select * from session_level_made_it_flags_down;

-- then this would produce the final output(part 1)

Select 
	count(Distinct website_session_id) as sessions,
    count(distinct case when product_made_it=1 then website_session_id else null end) as to_products,
    count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_made_it=1 then website_session_id else null end) as to_cart
from session_level_made_it_flags_down;

-- then we will translate those counts to click rates for final output part 2 (click rates)
-- i'll start with the same query we just did, and show you how to calculate the rates


Select 
	count(Distinct website_session_id) as sessions,
    count(distinct case when product_made_it=1 then website_session_id else null end)/count(Distinct website_session_id) as clicked_to_products,
    count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end)/count(distinct case when product_made_it=1 then website_session_id else null end)as clicked_to_mrfuzzy,
    count(distinct case when cart_made_it=1 then website_session_id else null end)/ count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as clicked_to_cart
from session_level_made_it_flags_down;


-- Building conversion funnels


-- why are we taking session id from website_sessions table when session_id is already available in website_pageviews?
-- For this specific question, you can do it without website_sessions
drop temporary table if exists session_level;
create temporary table session_level
Select 
website_session_id,
max(lander_page) as lander_made_it,
max(products_page) as product_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it, 
max(cart_page) as cart_made_it, 
max(shipping_page) as shipping_made_it,
max(billing_page) as billing_made_it, 
max(thankyou_page) as thankyou_made_it
from (
	Select 
		ws.website_session_id,
		wp.pageview_url,
		-- wp.created_at AS pageview_created_at,
		case when pageview_url='/lander-1' then 1 else 0 end as lander_page,
		case when pageview_url='/products' then 1 else 0 end as products_page,
		case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
		case when pageview_url='/cart' then 1 else 0 end as cart_page,
		case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
		case when pageview_url='/billing' then 1 else 0 end as billing_page,
		case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_page
	FROM website_sessions AS ws
	LEFT JOIN website_pageviews AS wp
	ON ws.website_session_id=wp.website_session_id
	WHERE wp.created_at BETWEEN '2012-08-05' AND '2012-09-05' 
	-- AND wp.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
    and ws.utm_source='gsearch'
    and ws.utm_campaign='nonbrand'
	ORDER BY
	wp.website_session_id,
	wp.pageview_url) as pageview_level
group by website_session_id;

select * from session_level;


Select 
count(distinct website_session_id) as total_sessions,
count(distinct case when lander_made_it=1 then website_session_id else null end) as to_lander,
count(distinct case when product_made_it=1 then website_session_id else null end) as to_products,
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_mrfuzzy,
count(distinct case when cart_made_it=1 then website_session_id else null end) as to_cart, 
count(distinct case when shipping_made_it=1 then website_session_id else null end) as to_shipping, 
count(distinct case when billing_made_it=1 then website_session_id else null end) as to_billing,
count(distinct case when thankyou_made_it=1 then website_session_id else null end) as to_thankyou
from session_level;

Select 
count(distinct website_session_id) as total_sessions,
-- sum(lander_made_it)/count(distinct website_session_id) as to_lander_rate,
sum(product_made_it)/count(distinct website_session_id) as to_landerclick_rate, -- 点击了lander的rate lander 点击了就进入了products
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end)/sum(product_made_it) as to_mrfuzzy_rate,
count(distinct case when cart_made_it=1 then website_session_id else null end)/count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_cart_rate, 
count(distinct case when shipping_made_it=1 then website_session_id else null end)/count(distinct case when cart_made_it=1 then website_session_id else null end)as to_shipping_rate, 
count(distinct case when billing_made_it=1 then website_session_id else null end)/count(distinct case when shipping_made_it=1 then website_session_id else null end)as to_billing_rate,
count(distinct case when thankyou_made_it=1 then website_session_id else null end)/count(distinct case when billing_made_it=1 then website_session_id else null end) as to_thankyou_rate
from session_level;

Select 
sum(lander_made_it) from session_level;

-- Analyzing conversion funnel test

select 
min(created_at) as first_created_at,
min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url='/billing-2'
and created_at is not null; 


drop temporary table if exists session_level;
create temporary table session_level
Select 
pageview_url,
count(distinct website_session_id),
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rt
from (
	Select 
		wp.website_session_id,
		wp.pageview_url,
        orders.order_id
	FROM website_pageviews AS wp
		left join orders
		ON orders.website_session_id=wp.website_session_id
	WHERE wp.created_at<'2012-11-10'
    and wp.website_pageview_id >= 53550
    and wp.pageview_url in ('/billing','/billing-2')
	ORDER BY
	wp.website_session_id,
	wp.pageview_url) as billing_sessions_w_order
group by pageview_url;

select * from session_level;

Select 
		wp.website_session_id,
		wp.pageview_url,
        orders.order_id
	FROM website_pageviews AS wp
		left join orders
		ON orders.website_session_id=wp.website_session_id
	WHERE wp.created_at<'2012-11-10'
    and wp.website_pageview_id >= 53550
    and wp.pageview_url in ('/billing','/billing-2')
	ORDER BY
	wp.website_session_id,
	wp.pageview_url; 
    
-- So here you see for some of the sessions, there is an order ID and then for some of the sessions it's null because no order was placed.











