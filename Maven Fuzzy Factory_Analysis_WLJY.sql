-- WEBSITE_SESSIONS
SELECT * FROM website_sessions;
-- WEBSITE_PAGEVIEWS
SELECT * FROM website_pageviews;
-- ORDERS
SELECT * FROM orders;
-- ORDER ITEMS
SELECT * FROM order_items;
-- ORDER refunds
SELECT * FROM order_item_refunds;


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


-- 
-- Channel portfolio analysis
-- 
SELECT utm_content, 
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT ws.website_session_id)  as sessions_to_order_cvr
FROM website_sessions AS ws
	LEFT JOIN orders 
	ON orders.website_session_id=ws.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY sessions DESC;

SELECT 
MIN(DATE(created_at)) AS week_start_date,
COUNT(CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
COUNT(CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at > '2012-08-22' 
AND created_at <'2012-11-29'
AND utm_campaign='nonbrand'
GROUP BY YEARWEEK(created_at);

SELECT utm_source,
COUNT(website_session_id) AS sessions,
COUNT(CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
COUNT(CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) /COUNT(website_session_id) AS mob_pct
FROM website_sessions
WHERE created_at > '2012-08-22' 
AND created_at <'2012-11-30'
AND utm_campaign='nonbrand'
GROUP BY 1;


SELECT ws.device_type,ws.utm_source,
COUNT(ws.website_session_id) AS sessions,
count(orders.order_id) as orders,
count(orders.order_id)/COUNT(ws.website_session_id) as cov_rate
FROM website_sessions as ws
	left join orders
	ON orders.website_session_id=ws.website_session_id
WHERE ws.created_at > '2012-08-22' 
AND ws.created_at <'2012-09-19'
AND ws.utm_campaign='nonbrand'
GROUP BY 1,2;

select 
MIN(DATE(created_at)) AS week_start_date,
COUNT(CASE WHEN device_type='desktop' and utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
COUNT(CASE WHEN device_type='desktop' and utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
COUNT(CASE WHEN device_type='desktop' and utm_source='bsearch' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN device_type='desktop' and utm_source='gsearch' THEN website_session_id ELSE NULL END)  as b_pct_of_g_dtop,
COUNT(CASE WHEN device_type='mobile' and utm_source='gsearch' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
COUNT(CASE WHEN device_type='mobile' and utm_source='bsearch' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
COUNT(CASE WHEN device_type='mobile' and utm_source='bsearch' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN device_type='mobile' and utm_source='gsearch' THEN website_session_id ELSE NULL END)  as b_pct_of_g_mob
from website_sessions
WHERE created_at > '2012-11-04' 
AND created_at <'2012-12-22'
AND utm_campaign='nonbrand'
group by yearweek(created_at);



--
-- Analyzing direct traffic
-- 

SELECT 
CASE 
	WHEN http_referer IS NULL THEN 'direct_type_in'
	WHEN http_referer='https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic'
    WHEN http_referer='https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
    ELSE 'other'
    END AS Type1,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
	-- AND utm_source IS NULL
GROUP BY 1;





SELECT YEAR(created_at) AS yr,
MONTH(created_at) AS mo,
COUNT(CASE WHEN channel_group='paid_nonbrand' THEN website_session_id END) AS nonbrand,
COUNT(CASE WHEN channel_group='paid_brand' THEN website_session_id END) AS brand,
COUNT(CASE WHEN channel_group='paid_brand' THEN website_session_id END)/COUNT(CASE WHEN channel_group='paid_nonbrand' THEN website_session_id END) AS brand_pct_of_nonbrand,
COUNT(CASE WHEN channel_group='direct_type_in' THEN website_session_id END) AS direct,
COUNT(CASE WHEN channel_group='direct_type_in' THEN website_session_id END)/COUNT(CASE WHEN channel_group='paid_nonbrand' THEN website_session_id END) AS direct_pct_of_nonbrand,
COUNT(CASE WHEN channel_group='organic' THEN website_session_id END) AS organic,
COUNT(CASE WHEN channel_group='organic' THEN website_session_id END)/COUNT(CASE WHEN channel_group='paid_nonbrand' THEN website_session_id END) AS organic_pct_of_nonbrand 
FROM
(
SELECT 
created_at,
website_session_id,
CASE 
	WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
    END AS channel_group
FROM website_sessions
WHERE created_at<'2012-12-23') AS sessions_w_channel_group
GROUP BY 
	YEAR(created_at),
	MONTH(created_at);

-- So it looks like the organic search is picking up and it seems to be growing faster than non brand
-- Not only is direct, organic and brand search growing, but it's also growing as a percentage of paid traffic overall


--
-- Seaonality & business patterns
--
SELECT
website_session_id,
created_at,
HOUR(created_at) AS hr,
WEEKDAY(created_at) AS wkday, -- 0=mon,1=tues
QUARTER(created_at) AS qtr,
MONTH(created_at) AS mo,
DATE(created_at) AS date,
WEEK(created_at) AS wk
FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000;

SELECT
YEAR(ws.created_at),
MONTH(ws.created_at),
COUNT(ws.website_session_id) AS sessions,
COUNT(orders.order_id) AS orders
FROM website_sessions AS ws
LEFT JOIN orders ON orders.website_session_id=ws.website_session_id
WHERE ws.created_at<'2013-01-01'
GROUP BY 1,2;

SELECT
MIN(DATE(ws.created_at)) AS week_start_date,
COUNT(ws.website_session_id) AS sessions,
COUNT(orders.order_id) AS orders
FROM website_sessions AS ws
LEFT JOIN orders ON orders.website_session_id=ws.website_session_id
WHERE ws.created_at<'2013-01-01'
GROUP BY YEARWEEK(ws.created_at);


SELECT 
DATE(created_at) AS created_date,
WEEKDAY(created_at) AS wkday,
HOUR(created_at) AS hr,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3;

SELECT
hr,
ROUND(AVG(CASE WHEN wkday=0 THEN sessions END),1) AS mon,
ROUND(AVG(CASE WHEN wkday=1 THEN sessions END),1) AS tue,
ROUND(AVG(CASE WHEN wkday=2 THEN sessions END),1) AS wed,
ROUND(AVG(CASE WHEN wkday=3 THEN sessions END),1) AS thu,
ROUND(AVG(CASE WHEN wkday=4 THEN sessions END),1) AS fir,
ROUND(AVG(CASE WHEN wkday=5 THEN sessions END),1) AS sat,
ROUND(AVG(CASE WHEN wkday=6 THEN sessions END),1) AS sun
FROM(
SELECT 
DATE(created_at) AS created_date,
WEEKDAY(created_at) AS wkday,
HOUR(created_at) AS hr,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) AS daily_hourly_sessions
GROUP BY daily_hourly_sessions.hr;

--
-- Product sales analysis
--

SELECT
	primary_product_id,
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd-cogs_usd) AS margin,
    AVG(price_usd) AS aov
FROM orders
WHERE order_id BETWEEN 10000 AND 11000
GROUP BY 1;

SELECT
YEAR(created_at),
MONTH(created_at),
COUNT(order_id) AS orders,
SUM(price_usd) AS total_revenue,
SUM(price_usd-cogs_usd) AS margin
FROM orders
WHERE created_at <'2013-01-04'
GROUP BY 1,2;


SELECT
YEAR(ws.created_at),
MONTH(ws.created_at),
COUNT(distinct o.order_id) AS number_of_sales,
COUNT(distinct o.order_id)/count(distinct ws.website_session_id) as conv,
SUM(o.price_usd)/count(distinct ws.website_session_id) AS revenue_per_session,
count(case when o.primary_product_id=1 then o.order_id end) as product_one_orders,
count(case when o.primary_product_id=2 then o.order_id end) as product_two_orders
FROM website_sessions as ws
left join orders as o 
on ws.website_session_id = o.website_session_id
WHERE ws.created_at between '2012-04-01' and  '2013-04-05'
GROUP BY 1,2; 



--
-- product level website analysis
--


-- step 1: find the relevant/ products pageviews with website_session_id
-- step 2: find the next pageview id that occurs after the product pageview
-- step 3: find the pageview_url associated with any applicable next pageview_id
-- step 4: summarize the data and analyze the pre vs post periods

SELECT DISTINCT pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-02-01' AND '2013-03-01';

SELECT 
website_session_id,
pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-02-01' AND '2013-03-01'
AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');


SELECT 
	website_pageviews.pageview_url,
    COUNT(DISTINCT website_pageviews.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_pageviews.website_session_id) AS viewed_product_to_order
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2013-02-01' AND '2013-03-01'
	AND website_pageviews.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
GROUP BY 1;


-- p141

-- step 1: find the relevant /products pageviews with website_session_id
drop temporary table pp;
create temporary table pp -- product_pageviews
Select
	website_pageview_id,
    website_session_id,
    created_at,
    case when created_at<'2013-01-06' then 'A.Pre_Product_2'
		 when created_at>='2013-01-06' then 'B.Post_Product_2'
         else 'uh oh .. check logic'
         end as time_period
from website_pageviews
where created_at<'2013-04-06' -- date of request
	and created_at>'2012-10-06' -- start of 3 mo before product 2 launch(2013-01-06)
    and pageview_url = '/products';
    
-- step 2: find the next pageview id that occurs after the product pageview
drop temporary table sessions_w_next_pageview_id;
Create temporary table sessions_w_next_pageview_id
select 
	pp.time_period,
    pp.website_session_id,
    min(wp.website_pageview_id) as min_next_pageview_id
from pp
	left join website_pageviews as wp
    on wp.website_session_id=pp.website_session_id
    and wp.website_pageview_id > pp.website_pageview_id 
    -- And we've got a restriction here that when we do our join, not only does Website session I.D. you have to match, 
    -- but the Website pageviews.Website pageview I.D. must be greater than the product page view.
	-- So this is saying that we're only going to do our join for page use that happened after the products pageviw
group by 1,2;

	-- And you see that some of them are null because the person just abandoned on the products page and didn't
	-- see another page.
    
-- step 3: find the pageview_url associated with any applicable next pageview id
DROP temporary table sessions_w_next_pageview_url;
create temporary table sessions_w_next_pageview_url
select 
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    wp.pageview_url as next_pageview_url
from sessions_w_next_pageview_id
	left join website_pageviews as wp
		on wp.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;
        
-- just to show the distinct next pageview urls
-- select distinct next_pageview_url from sessions_w_next_pageview_url

-- step 4:summarize the data and analyze the pre and post periods
select
	time_period,
    count(distinct website_session_id) as sessions,
    count(distinct case when next_pageview_url is not null then website_session_id else null end) as w_next_pg,
    count(distinct case when next_pageview_url is not null then website_session_id else null end)/count(distinct website_session_id) as pct_w_next_pg,
    count(distinct case when next_pageview_url='/the-original-mr-fuzzy' then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when next_pageview_url='/the-original-mr-fuzzy' then website_session_id else null end)/count(distinct website_session_id) as pct_to_mrfuzzy,
	count(distinct case when next_pageview_url='/the-forever-love-bear' then website_session_id else null end) as to_lovebear,
    count(distinct case when next_pageview_url='/the-forever-love-bear' then website_session_id else null end)/count(distinct website_session_id) as pct_to_lovebear
    from sessions_w_next_pageview_url
    group by 1;


-- Building product-level conversion funnels
-- step 1: select all pageviews for relevant sessions
-- step 2: figure out which pageview urls to look for
-- step 3: pull all pageviews and identify the funnel steps
-- step 4: create the session-level conversion funnel view
-- step 5: aggregate the data to assess funnel performance

--
drop temporary table tbl1;
create temporary table tbl1
Select 
	website_pageview_id,
	website_session_id,
    pageview_url as product_page_seen
from website_pageviews
where created_at>'2013-01-06' and created_at<'2013-04-10'
and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear');

-- finding the right pageview_urls to build the funnels
select distinct website_pageviews.pageview_url
from tbl1
left join website_pageviews on website_pageviews.website_session_id=tbl1.website_session_id
and website_pageviews.website_pageview_id>tbl1.website_pageview_id;


-- we'll look at the inner query first to look over the pageview_level results
-- then, turn it into a subquery and make it the summary with flags
drop temporary table tbl2;
create temporary table tbl2
select 
tbl1.website_session_id,
tbl1.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
from tbl1
left join website_pageviews on 
	tbl1.website_session_id=website_pageviews.website_session_id 
	and website_pageviews.website_pageview_id > tbl1.website_pageview_id;
    

drop temporary table tbl3;
create temporary table tbl3
select 
	website_session_id,
    case when product_page_seen='/the-original-mr-fuzzy' then 'mrfuzzy'
		 when product_page_seen='/the-forever-love-bear' then 'lovebear'
		 else 'uh..problem'
    end as product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
    from tbl2
    group by 1,2;

-- final output part 1
Select 
product_seen,
count(distinct website_session_id) as sessions,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
from tbl3
group by product_seen;

-- final output part 2
Select 
product_seen,
  COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/count(distinct website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM tbl3
GROUP BY 1;


-- 
-- Cross-selling & product protfolio analysis
--
select * from order_items;


Select
orders.primary_product_id,
count(distinct orders.order_id) as orders,
count(distinct case when order_items.product_id=1 then orders.order_id else null end) as x_sell_prod1,
count(distinct case when order_items.product_id=2 then orders.order_id else null end) as x_sell_prod2,
count(distinct case when order_items.product_id=3 then orders.order_id else null end) as x_sell_prod3,
count(distinct case when order_items.product_id=1 then orders.order_id else null end)/count(distinct orders.order_id) as x_sell_prod1_rt,
count(distinct case when order_items.product_id=2 then orders.order_id else null end)/count(distinct orders.order_id) as x_sell_prod2_rt,
count(distinct case when order_items.product_id=3 then orders.order_id else null end)/count(distinct orders.order_id) as x_sell_prod3_rt
from orders
	left join order_items on order_items.order_id=orders.order_id
    and order_items.is_primary_item=0 -- cross sell only
where orders.order_id between 10000 and 11000
group by 1;


-- cross-sell analysis
drop TEMPORARY table tbl1;
create TEMPORARY table tbl1
select 
	pageview_url,
    website_pageview_id,
    website_session_id,
    case when created_at<'2013-09-25' then 'Pre_cross_sell'
		 when created_at>='2013-09-25' then 'Post_cross_sell'
         else 'uh oh .. check logic'
         end as time_period
from website_pageviews
where created_at between '2013-08-25' and '2013-10-25'
and pageview_url = '/cart';

select 
	distinct website_pageviews.pageview_url
from tbl1
left join website_pageviews
on tbl1.website_session_id=website_pageviews.website_session_id
and website_pageviews.website_pageview_id>=tbl1.website_pageview_id;

drop TEMPORARY table tbl2;
create TEMPORARY table tbl2
select 
    tbl1.website_session_id,
    tbl1.time_period,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page
from tbl1
left join website_pageviews
on tbl1.website_session_id=website_pageviews.website_session_id
and website_pageviews.website_pageview_id>tbl1.website_pageview_id;


drop TEMPORARY table tbl3;
create TEMPORARY table tbl3
select
	tbl2.website_session_id,
    tbl2.time_period,
    orders.order_id,
    orders.price_usd,
    orders.items_purchased,
	max(shipping_page) AS shipping_made_it
    from tbl2
	left join orders on orders.website_session_id=tbl2.website_session_id
    group by 1,2,3,4,5;
    

select 
time_period,
count(distinct website_session_id) as cart_sessions,
count(case when shipping_made_it=1 then website_session_id end) as clickthroughs,
count(case when shipping_made_it=1 then website_session_id end)/count(distinct website_session_id) as cart_ctr,
sum(items_purchased)/count(order_id), -- 这里一个sum 一个count
AVG(price_usd) AS AOV, -- average product per oder
sum(price_usd)/count(distinct website_session_id) as rev_per_cart_session
from tbl3
group by 1
order by 1 desc; 

-- simple version
SELECT
CASE
WHEN website_pageviews.created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell'
WHEN website_pageviews.created_at >= '2013-09-25' THEN 'B.Post_Cross_Sell'
ELSE 'logic_error'
END AS time_period,
COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS cart_sessions,
COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/shipping' THEN website_pageviews.website_session_id ELSE NULL END) AS clicktroughs,
COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/shipping' THEN website_pageviews.website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS cart_crt,
sum(orders.items_purchased)/COUNT(orders.order_id) AS products_per_order,
AVG(orders.price_usd) AS AOV,
SUM(CASE WHEN website_pageviews.pageview_url ='/cart' THEN orders.price_usd  ELSE NULL END)/
COUNT(DISTINCT CASE WHEN website_pageviews.pageview_url ='/cart' THEN website_pageviews.website_session_id ELSE NULL END) AS rev_per_cart_sessions
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE
website_pageviews.created_at > '2013-08-25'
AND website_pageviews.created_at < '2013-10-25'
GROUP BY 1;


-- Product Portfolio Expansion

select 
    case when ws.created_at<'2013-12-12' then 'Pre_birthday_bear'
		 when ws.created_at>='2013-12-12' then 'Post_birthday_bear'
         else 'uh oh .. check logic'
         end as time_period,
	count(distinct orders.order_id)/count(distinct ws.website_session_id) as conv_rate,
    sum(orders.price_usd)/count(distinct orders.order_id) AS AOV,
    -- avg(orders.price_usd),
    sum(orders.items_purchased)/COUNT(distinct orders.order_id) AS products_per_order,
	sum(orders.price_usd)/count(distinct ws.website_session_id) as revenue_per_session
from website_sessions as ws
left join orders
on orders.website_session_id=ws.website_session_id
where ws.created_at between '2013-11-12' and '2014-01-12'
group by 1
order by 2;


-- 
-- Analyzing product refund rates
--

Select 
order_items.order_id,
order_items.order_item_id,
order_items.price_usd as price_paid_usd,
order_items.created_at,
order_item_refunds.order_item_refund_id,
order_item_refunds.refund_amount_usd,
order_item_refunds.created_at
from order_items
left join order_item_refunds
on order_items.order_item_id=order_item_refunds.order_item_id
where order_items.order_id in (3489,32049,27061);

-- Analyzing product refund rates
Select 

	year(order_items.created_at),
    month(order_items.created_at),
    count(case when product_id=1 then order_items.order_item_id end) as p1_orders,
	count(case when product_id=1 then order_item_refunds.order_item_refund_id end)/count(case when product_id=1 then order_items.order_item_id end) as p1_refund_rt,
    count(case when product_id=2 then order_items.order_item_id end) as p2_orders,
    count(case when product_id=2 then order_item_refunds.order_item_refund_id end)/count(case when product_id=2 then order_items.order_item_id end) as p2_refund_rt,
	count(case when product_id=3 then order_items.order_item_id end) as p3_orders,
    count(case when product_id=3 then order_item_refunds.order_item_refund_id end)/count(case when product_id=3 then order_items.order_item_id end) as p3_refund_rt,
    count(case when product_id=4 then order_items.order_item_id end) as p4_orders,
    count(case when product_id=4 then order_item_refunds.order_item_refund_id end)/count(case when product_id=4 then order_items.order_item_id end) as p4_refund_rt
    from order_items
left join order_item_refunds
on order_items.order_item_id=order_item_refunds.order_item_id
where order_items.created_at<'2014-10-15'
group by 1,2;


-- 
-- Analyzing repeat visit & purchase behavior
-- 
select
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd as price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at,
    datediff(order_item_refunds.created_at,order_items.created_at) as days_order_to_refund
from order_items
	left join order_item_refunds
    on order_item_refunds.order_item_id=order_items.order_item_id
    where order_items.order_id in (3489,32049,27061);
  
-- identifying repeat visitors

create temporary table sessions_w_repeats

select 
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    website_sessions.website_session_id as repeat_session_id
from 
	(select
    user_id, website_session_id
    from website_sessions
    where created_at <'2014-11-01' and created_at >='2014-01-01'
    and is_repeat_session=0 -- new_sessions only
    ) as new_sessions
    left join  website_sessions
    on website_sessions.user_id=new_sessions.user_id
    and website_sessions.is_repeat_session=1 -- was a repeat session
    and website_sessions.website_session_id > new_sessions.website_session_id
    and website_sessions.created_at <'2014-11-01'
    and website_sessions.created_at >= '2014-01-01';
    
select repeat_sessions,
count(distinct user_id) as users
from 
(select user_id,
count(distinct new_session_id) as new_sessions,
count(distinct repeat_session_id) as repeat_sessions
from sessions_w_repeats
group by 1
order by 3 desc) as user_level
group by 1;

-- Analyzing time to repeat

drop temporary table sessions_w_repeats_for_time_diff;
create temporary table sessions_w_repeats_for_time_diff

select 
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    new_sessions.created_at as new_session_created_at,
    website_sessions.website_session_id as repeat_session_id,
    website_sessions.created_at as repeat_session_created_at
from 
	(select
    user_id, website_session_id,created_at
    from website_sessions
    where created_at <'2014-11-01' and created_at >='2014-01-01'
    and is_repeat_session=0 -- new_sessions only　
    ) as new_sessions
    left join  website_sessions
    on website_sessions.user_id=new_sessions.user_id
    and website_sessions.is_repeat_session=1 -- was a repeat session
    and website_sessions.website_session_id > new_sessions.website_session_id
    and website_sessions.created_at <'2014-11-03'
	and website_sessions.created_at >= '2014-01-01';
    

select 
user_id,new_session_id,new_session_created_at,
min(repeat_session_id) as second_session_id,
min(repeat_session_created_at) as second_session_created_at
from sessions_w_repeats_for_time_diff
where repeat_session_id is not null
group by 1,2,3;

SET GLOBAL TIME_ZONE = '-05:00';

drop temporary table users_first_to_second;
create temporary table users_first_to_second
select user_id,
datediff(second_session_created_at,new_session_created_at) as days_first_to_second_session
from 
(select 
user_id,new_session_id,new_session_created_at,
min(repeat_session_id) as second_session_id,
min(repeat_session_created_at) as second_session_created_at
from sessions_w_repeats_for_time_diff
where repeat_session_id is not null
group by 1,2,3) as first_second;

select * from users_fist_to_second;

Select 
avg(days_first_to_second_session) as avg_days_first_to_second_session,
min(days_first_to_second_session) as min_days_first_to_second_session,
max(days_first_to_second_session) as max_days_first_to_second_session
from users_first_to_second;


Select
CASE 
	WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
    when utm_source = 'socialbook'  then 'paid social'
    END AS channel_group,
count(CASE when is_repeat_session=0 then website_session_id else null end) as new_sessions,
count(CASE when is_repeat_session=1 then website_session_id else null end) as repeat_sessions
from website_Sessions
where created_at<'2014-11-05' AND created_at >= '2014-01-01'
group by 1
order by 3 desc;

-- Analyzing new&repeat conversion rates
SELECT
is_repeat_SESSION,
COUNT(DISTINCT website_Sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.order_id) AS orders,
SUM(price_usd) AS total_revenue
FROM website_Sessions
LEFT JOIN orders
ON orders.website_session_id=website_Sessions.website_session_id
WHERE website_sessions.created_At <'2014-11-08'
AND website_sessions.created_At >='2014-01-01'
GROUP BY 1;













