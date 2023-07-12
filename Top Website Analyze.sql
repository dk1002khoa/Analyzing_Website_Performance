/*
The Objective:
- Tell the story of the company's growth, using trend of the performance data.
- Use the database to explain, some of the details around your growth story, and 
	uantify the revenue impact of some your wins 
- Analyze current performance, and use the data available to assess upcoming oppotunities.
*/
select * from website_sessions;
select * from orders;

/*
1.	Gsearch seems to be the biggest driver of our business. Could you pull monthly 
trends for gsearch sessions and orders so that we can showcase the growth there? 
*/ 
/*
1. Gsearch dường như là động lực lớn nhất cho hoạt động kinh doanh của chúng tôi. 
Bạn có thể kéo xu hướng hàng tháng cho phiên gsearch và đơn đặt hàng để 
chúng tôi có thể giới thiệu sự tăng trưởng ở đó?
*/
select 
year(w.created_at) as yr,
month(w.created_at) as mth,
count(distinct(w.website_session_id)) as sessions,
count(distinct(o.order_id)) as orders_sessions,
count(distinct(o.order_id)) / count(distinct(w.website_session_id)) as conv_rate
from website_sessions as w
left join orders as o
on w.website_session_id = o.website_session_id
where w.created_at < '2012-11-27'
and w.utm_source = 'gsearch'
group by 1,2;

/*
2.	Next, it would be great to see a similar monthly trend for Gsearch, 
but this time splitting out nonbrand and brand campaigns separately. 
I am wondering if brand is picking up at all. If so, this is a good story to tell. 
*/ 
/*
2. Tiếp theo, thật tuyệt khi thấy xu hướng tương tự hàng tháng cho Gsearch,
nhưng lần này tách riêng các chiến dịch có 'brand' và 'nonbrand'.
Tôi tự hỏi liệu brand có đang tăng giá không. Nếu vậy, đây là 
một câu chuyện hay để kể.
*/
select * from website_sessions;
select * from orders;

select 
year(w.created_at) as yr,
month(w.created_at) as mo,
count(distinct case when w.utm_campaign = 'nonbrand' then w.website_session_id else null end) as nonbrand_sessions,
count(distinct case when w.utm_campaign = 'nonbrand' then o.order_id else null end) as nonbrand_orders_sessions,
count(distinct case when w.utm_campaign = 'brand' then w.website_session_id else null end) as brand_sessions,
count(distinct case when w.utm_campaign = 'brand' then o.order_id else null end) as brand_orders_sessions
from website_sessions as w
left join orders as o
on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
and w.utm_source = 'gsearch' 
group by 1,2;

/*
3.	While we’re on Gsearch, could you dive into nonbrand, and pull monthly 
sessions and orders split by device type? 
I want to flex our analytical muscles a little and 
show the board we really know our traffic sources. 
*/ 
/*
3. Trong khi chúng tôi đang sử dụng Gsearch, bạn có thể đi sâu vào mục không có 
thương hiệu và kéo hàng tháng phiên và đơn đặt hàng được chia theo loại thiết bị?
Tôi muốn uốn cong cơ bắp phân tích của chúng tôi một chút và cho hội đồng quản trị 
biết chúng tôi thực sự biết nguồn lưu lượng truy cập của mình.
*/
select * from website_sessions;
select * from orders;

select 
year(w.created_at) as yr,
month(w.created_at) as mth,
count(distinct case when w.device_type = 'desktop' 
then w.website_session_id else null end) as desktop_sessions,
count(distinct case when w.device_type = 'desktop' 
then o.order_id else null end) as desktop_orders_sessions,
count(distinct case when w.device_type = 'mobile'
then w.website_session_id else null end) as mobile_sessions,
count(distinct case when w.device_type = 'mobile'
then o.order_id else null end) as mobile_orders_sessions
from website_sessions as w
left join orders as o
on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
and w.utm_source = 'gsearch'
and w.utm_campaign = 'nonbrand'
group by 1,2;
 
/*
4.	I’m worried that one of our more pessimistic board members may be concerned 
about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of 
our other channels?
*/ 
-- first, finding the various 
-- utm sources and referers to see the traffic we're getting
select * from website_sessions;
select * from orders;

select distinct
utm_source, utm_campaign, http_referer
from website_sessions
where created_at < '2012-11-27';

select 
year(w.created_at) as yr, 
month(w.created_at) as mth,
count(distinct case when w.utm_source = 'gsearch' 
then w.website_session_id else null end) as gsearch_paid_sessions,
count(distinct case when w.utm_source = 'bsearch' 
then w.website_session_id else null end) as bsearch_paid_sessions,
count(distinct case when utm_source is null and http_referer is not null
then w.website_session_id else null end) as organic_search_sessions,
count(distinct case when utm_source is null and http_referer is null
then w.website_session_id else null end) as direct_type_in_sessions
from website_sessions as w
left join orders as o 
on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
group by 1,2;

/*
5.	I’d like to tell the story of our website performance improvements 
over the course of the first 8 months. 
Could you pull session to order conversion rates, by month? 
*/ 
select * from website_sessions
where created_at < '2012-11-27';
select * from orders;

select 
year(w.created_at) as yr,
month(w.created_at) as mth,
count(distinct(w.website_session_id)) as sessions,
count(distinct(o.order_id)) as orders_sessions,
count(distinct(o.order_id)) / count(distinct(w.website_session_id)) as conversion_rate
from website_sessions as w
left join orders as o  
on o.website_session_id = w.website_session_id 
where w.created_at < '2012-11-27'
group by 1,2;

/*
6.	For the gsearch lander test, please estimate the revenue that test earned us 
(Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use 
nonbrand sessions and revenue since then to calculate incremental value)
*/ 
select * from website_pageviews;
select * from website_sessions;
select 
min(website_pageview_id) as first_pv_id
from website_pageviews
where pageview_url = '/lander-1';
-- first_pv_id = 23504 --

-- for this step, we'll find the first pageview id 
create temporary table first_test_pageviews
select 
w.website_session_id,
min(w.website_pageview_id) as min_pv_id
from website_pageviews as w
inner join website_sessions as w1
on w1.website_session_id = w.website_session_id
where w1.created_at < '2012-07-28' -- prescribed by the assignment
and w.website_pageview_id >= 23504 -- first_pv_id with /lander-1
and w1.utm_source = 'gsearch'
and w1.utm_campaign = 'nonbrand'
group by 1;

select * from first_test_pageviews;
select * from website_pageviews;
select * from website_sessions;

-- next, we'll bring in the landing page to each session, like last time, 
-- but restricting to home or lander-1 this time
create temporary table nonbrand_test_sessions_w_landing_pages
select 
f.website_session_id,
w.pageview_url as landing_page
from first_test_pageviews as f 
left join website_pageviews as w
on w.website_session_id = f.website_session_id
where w.pageview_url in ('/home','/lander-1');

select * from nonbrand_test_sessions_w_landing_pages;
select * from orders;
select * from website_sessions;

-- then we make a table to bring in orders
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
select 
 n.website_session_id,
 n.landing_page,
 o.order_id
from nonbrand_test_sessions_w_landing_pages as n
left join orders as o
on o.website_session_id = n.website_session_id;

select * from nonbrand_test_sessions_w_orders;

-- to find the difference between conversion rates 
select 
n.landing_page,
count(distinct(n.website_session_id)) as sessions,
count(distinct(n.order_id)) as orders_sessions,
count(distinct(n.order_id)) / count(distinct(n.website_session_id)) as conversion_rate
from nonbrand_test_sessions_w_orders as n
group by 1;

-- .0319 for /home, vs .0406 for /lander-1 
-- .0087 additional orders per session

select * from website_pageviews;
select * from website_sessions;

-- finding the most recent pageview 
-- for gsearch nonbrand where the traffic was sent to /home
select 
max(w.website_session_id) as most_recent_gsearch_nonbrand_home_pv
from website_sessions as w
left join website_pageviews as w1
on w1.website_session_id = w.website_session_id
where w.utm_source = 'gsearch'
and w.utm_campaign = 'nonbrand'
and w1.pageview_url = '/home'
and w.created_at < '2012-11-27';
-- max_website_session_id = 17145

select 
count(website_session_id) as sessions_since_test
from website_sessions
where created_at < '2012-11-27'
and website_session_id > 17145 -- last /home session
and utm_campaign = 'nonbrand'
and utm_source = 'gsearch';

-- 22,972 website sessions since the test
-- 22,972 * .0087 incremental conversion = 202 incremental orders since 7/29
	-- roughly 4 months, so roughly 50 extra orders per month. Not bad!
-- 22.972 * .0087 chuyển đổi gia tăng = 202 đơn đặt hàng gia tăng kể từ ngày 29/7
-- khoảng 4 tháng, vậy khoảng 50 đơn đặt hàng thêm mỗi tháng. Không tệ!

/*
7.	For the landing page test you analyzed previously, it would be great to 
show a full conversion funnel from each of the two pages to orders. 
You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/ 
select * from website_pageviews;
select * from website_sessions;

select 
w.website_session_id,
w1.pageview_url,
w1.created_at as pv_created_at,
case when pageview_url= '/home' then 1 else 0 end as homepage,
case when pageview_url= '/lander-1' then 1 else 0 end as custom_lander,
case when pageview_url= '/products' then 1 else 0 end as products_page,
case when pageview_url= '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url= '/cart' then 1 else 0 end as cart_page,
case when pageview_url= '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url= '/billing' then 1 else 0 end as billing_page,
case when pageview_url= '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions as w
left join website_pageviews as w1
on w1.website_session_id = w.website_session_id
where w.utm_campaign = 'nonbrand'
and w.utm_source = 'gsearch'
and w.created_at < '2012-06-19'
order by 1,3;

CREATE TEMPORARY TABLE session_level_made_it_flagged1
select 
website_session_id,
max(homepage) as saw_homepage,
max(custom_lander) as saw_custom_lander,
max(products_page) as saw_products_page,
max(mrfuzzy_page) as saw_mrfuzzy_page,
max(cart_page) as saw_cart_page,
max(shipping_page) as saw_shipping_page,
max(billing_page) as saw_billing_page,
max(thank_page) as saw_thank_page
from ( select 
w.website_session_id,
w1.pageview_url,
w1.created_at as pv_created_at,
case when pageview_url= '/home' then 1 else 0 end as homepage,
case when pageview_url= '/lander-1' then 1 else 0 end as custom_lander,
case when pageview_url= '/products' then 1 else 0 end as products_page,
case when pageview_url= '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url= '/cart' then 1 else 0 end as cart_page,
case when pageview_url= '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url= '/billing' then 1 else 0 end as billing_page,
case when pageview_url= '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions as w
left join website_pageviews as w1
on w1.website_session_id = w.website_session_id
where w.utm_campaign = 'nonbrand'
and w.utm_source = 'gsearch'
and w.created_at < '2012-07-28'
and w.created_at > '2012-06-19'
order by 1,3) as pageview_level
group by 1;

select * from session_level_made_it_flagged1;

# Final Output 1
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment,
count(distinct website_session_id ) as sessions,
count(distinct case when saw_products_page = 1 
then website_session_id else null end) as to_products,
count(distinct case when saw_mrfuzzy_page = 1 
then website_session_id else null end) as to_mrfuzzy,
count(distinct case when saw_cart_page = 1 
then website_session_id else null end) as to_cart,
count(distinct case when saw_shipping_page = 1 
then website_session_id else null end) as to_shipping,
count(distinct case when saw_billing_page = 1 
then website_session_id else null end) as to_billing,
count(distinct case when saw_thank_page = 1 
then website_session_id else null end) as to_thank
from session_level_made_it_flagged1
group by 1;

# Final Output 2 - click rates
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment,
count(distinct case when saw_products_page = 1 
then website_session_id else null end) / count(distinct website_session_id )
as lander_click_rt,
count(distinct case when saw_mrfuzzy_page = 1 
then website_session_id else null end) / count(distinct case when saw_products_page = 1 
then website_session_id else null end) 
as products_click_rt,
count(distinct case when saw_cart_page = 1 
then website_session_id else null end) / count(distinct case when saw_mrfuzzy_page = 1 
then website_session_id else null end) 
as mrfuzzy_click_rt,
count(distinct case when saw_shipping_page = 1 
then website_session_id else null end) / count(distinct case when saw_cart_page = 1 
then website_session_id else null end)
as cart_click_rt,
count(distinct case when saw_billing_page = 1 
then website_session_id else null end) / count(distinct case when saw_shipping_page = 1 
then website_session_id else null end)
as shipping_click_rt,
count(distinct case when saw_thank_page = 1 
then website_session_id else null end) / count(distinct case when saw_billing_page = 1 
then website_session_id else null end)
as billing_click_rt
from session_level_made_it_flagged1
group by 1;    

/*
8.	I’d love for you to quantify the impact of our billing test, as well. 
Please analyze the lift generated from the test (Sep 10 – Nov 10), 
in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2');

select 
billing_version_seen,
count(distinct(website_session_id)) as sessions,
sum(price_usd)/count(distinct(website_session_id)) as revenue_per_billing_page_seen 
from ( SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2'))
as billing_pv_and_order_data
group by 1;

-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view

select 
count(website_session_id) as billing_sessions_past_month
from website_pageviews
where pageview_url in ('/billing', '/billing-2')
and created_at between '2012-10-27' AND '2012-11-27' -- past month

-- 1,193 billing sessions past month
-- LIFT: $8.51 per billing session
-- VALUE OF BILLING TEST :1,193 x  $8.51 = $10,152 over the past month



