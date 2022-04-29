-- WEBSITE_SESSIONS
SELECT * FROM website_sessions;
-- WEBSITE_PAGEVIEWS
SELECT * FROM website_pageviews;
-- ORDERS
SELECT * FROM orders;


SET global time_zone = '-5:00';


-- 1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders 
-- so that we can showcase the growth there? ～0:12
-- 这里要用order id！！！！
SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT ws.website_session_id) as cov_rate
FROM website_sessions AS ws
	LEFT JOIN orders
	ON ws.website_session_id=orders.website_session_id
WHERE ws.utm_source='gsearch' AND ws.created_at < '2012-11-27'
GROUP BY 1,2;


/* sessions and orders both seems to be growing pretty substancially, about 4 times that order value(从4月full month开始算) */

-- 2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
-- brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. ~ 3:17
SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	ws.utm_campaign,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions AS ws
	LEFT JOIN orders
	ON ws.website_session_id=orders.website_session_id
WHERE ws.utm_source='gsearch' AND ws.created_at < '2012-11-27' AND ws.utm_campaign IN ('nonbrand','brand')
GROUP BY 1,2,3;


SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT case when ws.utm_campaign='nonbrand' then ws.website_session_id else null end) AS nonbrand_sessions,
	COUNT(DISTINCT case when ws.utm_campaign='nonbrand' then orders.order_id else null end) AS nonbrand_orders,
    COUNT(DISTINCT case when ws.utm_campaign='brand' then ws.website_session_id else null end) AS brand_sessions,
	COUNT(DISTINCT case when ws.utm_campaign='brand' then orders.order_id else null end) AS brand_orders
FROM website_sessions AS ws
	LEFT JOIN orders
	ON ws.website_session_id=orders.website_session_id
WHERE ws.utm_source='gsearch' AND ws.created_at < '2012-11-27' 
GROUP BY 1,2;

/* brand campaigns represent someone going into search engines and explicitly looking for your business. This has increased dramatically is a good sign 
for Cindy and the investors are going*/ 

-- 3. While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
-- type? I want to flex our analytical muscles a little and show the board we really know our traffic sources. ~ 5:32

SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT case when ws.device_type='desktop' then ws.website_session_id else null end) AS desktop_sessions,
	COUNT(DISTINCT case when ws.device_type='desktop' then orders.website_session_id else null end) AS desktop_orders,
	COUNT(DISTINCT case when ws.device_type='mobile' then ws.website_session_id else null end) AS mobile_sessions,
	COUNT(DISTINCT case when ws.device_type='mobile' then orders.website_session_id else null end) AS mobile_orders
FROM website_sessions AS ws
	LEFT JOIN orders
	ON ws.website_session_id=orders.website_session_id
WHERE ws.utm_source='gsearch' AND ws.created_at < '2012-11-27' And ws.utm_campaign='nonbrand'
GROUP BY 1,2;

select distinct ws.device_type from website_sessions AS ws;

/*And what we see here is a lot more desktop sessions, so from the beginning it was a little less than
a 2:1 ratio (1128 vs 724).But here at the end of this time period, we've got more than a 3:1 ratio(6457:2049).
And then when we look at the orders, it's even more drastic. So at the beginning of the time period, we had a 5:1 ratio (50:10) of desktop to mobile.
And by the end, we're almost looking at a 10:1 ratio(323:33).*/

-- 4. I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels? ~ 7:44

select distinct utm_source,utm_campaign,http_referer from website_sessions where created_at < '2012-11-27';

-- Organic sessions, specifically, refers to sessions from users who found the website via an organic search. 
-- This means that they found your website after clicking on your website’s link in the search engine results page - not including paid ads.
-- https://support.gospacecraft.com/hc/en-us/articles/360001637719-How-to-Read-Your-Monthly-SEO-Report

SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT case when utm_source='gsearch' then website_session_id else null end) AS gsearch_paid_sessions,
	COUNT(DISTINCT case when utm_source='bsearch' then website_session_id else null end) AS bsearch_paid_sessions,
    COUNT(DISTINCT case when utm_source is null and http_referer is not null then ws.website_session_id else null end) AS organic_search_sessions,
    COUNT(DISTINCT case when utm_source is null and http_referer is null then ws.website_session_id else null end) AS direct_type_in_sessions -- 全是null
FROM website_sessions as ws
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2;

-- we have our paid sessions building over time,we've got bsearch sessions taking off quite a bit more than they were at the beginning as well.
-- And we have organic search and direct type sessions which are also growing.
-- the board and your CEO are going to be really excited about organic search building up and direct type in sessions because these represent 
-- sessions that you're not paying for.
-- So with your gsearch and bsearch page sessions, there's a cost of customer acquisition for any orders that come in and paying for that marketing spend, 
-- it eats into your margin. But with the organic search sessions and the direct typein sessions, that's all margin when you sell order there.


-- 5. I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
-- Could you pull session to order conversion rates, by month? ~ 11:50
SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT ws.website_session_id) as cov_rate
FROM website_sessions AS ws
	LEFT JOIN orders
	ON ws.website_session_id=orders.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2;



-- 6.For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
-- from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value) ~ 13:15  难

select min(website_pageview_id) as first_test_pv
from website_pageviews
where pageview_url='/lander-1';


create temporary table A -- first_test_pageview
SELECT 
	wp.website_session_id,
    min(wp.website_pageview_id) as min_pageview_id
from website_pageviews as wp
	inner join website_sessions as ws
	on ws.website_session_id=wp.website_session_id
		and ws.created_at<'2012-07-28'
		and wp.website_pageview_id >=23504
		and utm_source='gsearch'
		and utm_campaign = 'nonbrand'
group by 1;


-- next, we will bring in the landing page to each session, like last time, but restricting to home or lander-1 this time 
-- DROP temporary table if exists B;
create temporary table B -- nonbrand_test_sessions_w_landing_page
Select A.website_session_id, A.min_pageview_id,wp.pageview_url as landing_page from A
left join website_pageviews as wp
on wp.website_pageview_id=A.min_pageview_id
where wp.pageview_url in ('/lander-1','/home');

create temporary table C -- nonbrand_test_sessions_w_orders
Select 
B.website_session_id, 
B.landing_page,
orders.order_id
from B 
left join orders 
on orders.website_session_id=B.website_session_id;

Select landing_page,
count(distinct website_session_id) as sessions,
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_session_id) as cov_rate
from C
group by 1;

-- 0.0318 fro home vs 0.0406 for lander
-- 0.0087 additional orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home
Select max(ws.website_session_id) as most_recent_gsearch_nonbrand_home_pageview
from website_sessions as ws
left join website_pageviews as wp
on ws.website_session_id=wp.website_session_id
where ws.created_at<'2012-11-27'
		and utm_source='gsearch'
		and utm_campaign = 'nonbrand'
        and wp.pageview_url='/home';

-- max id '17145'


Select count(website_session_id) as sessions_since_test
from website_sessions
where created_at<'2012-11-27'
		and website_session_id > 17145
		and utm_source='gsearch'
		and utm_campaign = 'nonbrand';

Select *
from website_sessions as ws
left join website_pageviews as wp
on ws.website_session_id=wp.website_session_id
where ws.created_at<'2012-11-27'
		and ws.website_session_id > 17145
		and utm_source='gsearch'
		and utm_campaign = 'nonbrand';


        
-- 22972 website sessions since test
-- x. 0087 incremental conversion = 202 increamental orders since 7/29 
-- roughly 4 months, so roughly 50 extra orders per month. not bad

-- 7. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
-- of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28). ~ 19:57
create temporary table session_level
Select 
website_session_id,
max(homepage) as home_made_it,
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
        case when pageview_url='/home' then 1 else 0 end as homepage,
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
	WHERE wp.created_at BETWEEN '2012-06-19' AND '2012-07-28' 
    and ws.utm_source='gsearch'
    and ws.utm_campaign='nonbrand'
	ORDER BY
	wp.website_session_id,
	wp.created_at) as pageview_level
group by website_session_id;

select * from session_level;

Select 
case when home_made_it=1 then 'saw_homepage'
when lander_made_it=1 then 'saw_landerpage'
else 'uh oh ... check logic' end as segement,
count(distinct website_session_id) as total_sessions,
count(distinct case when product_made_it=1 then website_session_id else null end) as to_products,
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_mrfuzzy,
count(distinct case when cart_made_it=1 then website_session_id else null end) as to_cart, 
count(distinct case when shipping_made_it=1 then website_session_id else null end) as to_shipping, 
count(distinct case when billing_made_it=1 then website_session_id else null end) as to_billing,
count(distinct case when thankyou_made_it=1 then website_session_id else null end) as to_thankyou
from session_level
group by 1;

Select 
case when home_made_it=1 then 'saw_homepage'
when lander_made_it=1 then 'saw_landerpage'
else 'uh oh ... check logic' end as segement,
count(distinct website_session_id) as total_sessions,
-- sum(lander_made_it)/count(distinct website_session_id) as to_lander_rate,
sum(product_made_it)/count(distinct website_session_id) as to_landerclick_rate, -- 点击了lander的rate lander 点击了就进入了products
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end)/count(distinct website_session_id) as to_mrfuzzy_rate,
count(distinct case when cart_made_it=1 then website_session_id else null end)/count(distinct website_session_id) as to_cart_rate, 
count(distinct case when shipping_made_it=1 then website_session_id else null end)/count(distinct website_session_id) as to_shipping_rate, 
count(distinct case when billing_made_it=1 then website_session_id else null end)/count(distinct website_session_id) as to_billing_rate,
count(distinct case when thankyou_made_it=1 then website_session_id else null end)/count(distinct website_session_id) as to_thankyou_rate
from session_level
group by 1;





-- 8. I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test 
-- (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact. ~ 25:17