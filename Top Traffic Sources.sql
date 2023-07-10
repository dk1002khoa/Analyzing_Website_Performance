#Key Tables : website-sessions, pageviews, orders 
Use mavenfuzzyfactory;
select * from website_sessions where website_session_id between 1000 and 2000;
select * from website_sessions where website_session_id = 1059;
select * from website_pageviews where website_session_id = 1059;
select * from orders where website_session_id = 1059;

#Paid Marketing Campaigns: UTM TRACKING PARAMETERS 
select distinct utm_campaign, utm_source
from website_sessions;
select * from website_sessions where website_session_id between 1000 and 2000;

select website_sessions.utm_content,count(distinct(website_sessions.website_session_id)) as sessions, 
count(distinct(orders.order_id)) as order_sessions
from website_sessions 
left join orders 
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by 1
order by sessions desc;

#Tỉ lệ chuyển đổi được thúc đẩy bởi các utm_content 
select website_sessions.utm_content, 
count(distinct(website_sessions.website_session_id)) as sessions, 
count(distinct(orders.order_id)) as order_sessions,
count(distinct(orders.order_id))/count(distinct(website_sessions.website_session_id)) 
as conversion_rate
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by 1
order by 2 desc;

#Finding top traffic sources 
select utm_source, utm_campaign, http_referer,
count(distinct(website_session_id)) as sessions
from website_sessions
where created_at < '2012-04-12'
group by 1,2,3 
order by 4 desc;

#Traffic Search Conversion Rate 
select
count(distinct(website_sessions.website_session_id)) as sessions,
count(distinct(orders.website_session_id)) as orders_session,
count(distinct(orders.website_session_id)) / count(distinct(website_sessions.website_session_id)) 
as sessions_to_order_conv_rate
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-04-14'
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand';

#Business concept: BID optimization
select website_session_id, created_at,
week(created_at) as Created_Week,
month(created_at) as Created_Month,
year(created_at) as Created_Year
from website_sessions
where website_session_id between 100000 and 115000;

select 
count(distinct(website_session_id)) as sessions,
week(created_at) as Created_Week,
month(created_at) as Created_Month,
year(created_at) as Created_Year,
min(date(created_at)) as Started_Week
from website_sessions
where website_session_id between 100000 and 115000
group by 2,3,4;

# "PIVOTING" data with count and case
select 
primary_product_id,
count(distinct case when items_purchased = 1 then order_id else null end ) as orders_1_items,
count(distinct case when items_purchased = 2 then order_id else null end ) as orders_2_items,
count(distinct(order_id)) as Total_Orders
from orders 
where order_id between 31000 and 32000
group by 1;

#gsearch volumne trend '2012-05-12'
select year(created_at) as year_, 
week(created_at) as week_, 
min(date(created_at)) as Started_Week_Date ,
count(distinct(website_session_id)) as sessions
from website_sessions
where created_at < '2012-05-12'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1,2;

# traffic source BID optimization 
select website_sessions.device_type, 
count(distinct(website_sessions.website_session_id)) as sessions, 
count(distinct(orders.order_id)) as order_sessions,
count(distinct(orders.website_session_id)) / count(distinct(website_sessions.website_session_id)) 
as sessions_to_order_conv_rate
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-05-11'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.utm_source = 'gsearch'
group by 1;

# Traffic Source Segment Trending 
select min(date(created_at)) as Started_Week, 
count(distinct case when device_type = 'desktop' then website_session_id else null end) as dtop_sessions,
count(distinct case when device_type = 'mobile' then website_session_id else null end) as mob_sessions
from website_sessions
where website_sessions.created_at < '2012-06-09'
and website_sessions.created_at > '2012-04-15'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.utm_source = 'gsearch'
group by week(created_at);

#ANALYZE TOP WEBSITE PAGES & ENTRY PAGES 
select * from website_pageviews
where website_pageview_id < 1000;
select * from website_pageviews;

select pageview_url,
count(distinct(website_session_id)) as sessions,
count(distinct(website_pageview_id)) as pageview_sessions 
from website_pageviews 
where website_pageview_id < 1000
group by 1
order by pageview_sessions desc;

create temporary table t1
select website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews
where website_pageview_id < 1000
group by 1;

select * from t1;
select t1.website_session_id,
website_pageviews.pageview_url as entry_page
from t1
left join website_pageviews
on t1.min_pv_id = website_pageviews.website_pageview_id;

select 
website_pageviews.pageview_url as entry_page,
count(distinct t1.website_session_id) as sessions_hitting_this_url
from t1
left join website_pageviews
on t1.min_pv_id = website_pageviews.website_pageview_id
group by entry_page;

#Identifying top website pages 
select pageview_url,
count(distinct (website_session_id)) as sessions,
count(distinct (website_pageview_id)) as pvs
from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 3 desc;

#Identifying top entry pages 
-- Step 1: Find the first pageview for each session
create temporary table first_pageview_per_sessions1
select website_session_id,
min(website_pageview_id) as first_pv
from website_pageviews
where created_at < '2012-06-09'
group by 1;

select * from first_pageview_per_sessions1;

-- Step 2: Find the url the customer saw on that first pageview
select website_pageviews.pageview_url as entry_page,
first_pageview_per_sessions1.website_session_id as sessions_hitting_this_url
from first_pageview_per_sessions1
left join website_pageviews
on first_pageview_per_sessions1.first_pv = website_pageviews.website_pageview_id;

-- Step 3 Count them
select website_pageviews.pageview_url as entry_page,
count(distinct first_pageview_per_sessions1.website_session_id ) as sessions_hitting_this_url
from first_pageview_per_sessions1
left join website_pageviews
on first_pageview_per_sessions1.first_pv = website_pageviews.website_pageview_id
group by website_pageviews.pageview_url;

-- Business Context: We want to see entry page per formance for a certain time period

-- Step 1 Find the first website_pageview_id 
	-- Finding the minimum website pageview id associated with each sessions we care about 
select website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id 
from website_pageviews
inner join website_sessions
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1;
	-- Same query as above, but this time we are storing the dataset as temporary table
create temporary table first_pageviews_demo
select website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id 
from website_pageviews
inner join website_sessions
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1;
select * from first_pageviews_demo;

-- Step 2: Identify the entry page of each session
	-- We will bring the entry page to each session
select website_pageview_id from website_pageviews;
select 
first_pageviews_demo.website_session_id,
website_pageviews.pageview_url
from first_pageviews_demo
left join website_pageviews
on website_pageviews.website_pageview_id = first_pageviews_demo.min_pv_id; -- Website pageview as entry page view
	-- Same query as above, but this time we are storing the dataset as temporary table
create temporary table sessions_with_entry_page_demo
select 
first_pageviews_demo.website_session_id,
website_pageviews.pageview_url
from first_pageviews_demo
left join website_pageviews
on website_pageviews.website_pageview_id = first_pageviews_demo.min_pv_id; -- Website pageview as entry page view
select * from sessions_with_entry_page_demo;

-- Step 3: Counting pageviews for each session, to identify "bounces"
	-- We will make a table to include a count of pageviews per sessions
	-- First, we need to show all of  the sessions. The we will limit to bounced sessions and create a temp table 
select 
sessions_with_entry_page_demo.website_session_id,
sessions_with_entry_page_demo.pageview_url,
count(website_pageviews.website_pageview_id) as count_of_page_viewd
from sessions_with_entry_page_demo
left join website_pageviews
on website_pageviews.website_session_id = sessions_with_entry_page_demo.website_session_id
group by 1,2
having count_of_page_viewd = 1;
	-- Same query as above, but this time we are storing the dataset as temporary table
create temporary table bounced_sessions_only
select 
sessions_with_entry_page_demo.website_session_id,
sessions_with_entry_page_demo.pageview_url,
count(website_pageviews.website_pageview_id) as count_of_page_viewd
from sessions_with_entry_page_demo
left join website_pageviews
on website_pageviews.website_session_id = sessions_with_entry_page_demo.website_session_id
group by 1,2
having count_of_page_viewd = 1;

select * from bounced_sessions_only;

	-- Next, we are going to have our sessions with entry page and join it to the bounced sessions
select * from sessions_with_entry_page_demo;
select * from bounced_sessions_only;

select 
sessions_with_entry_page_demo.website_session_id,
sessions_with_entry_page_demo.pageview_url,
bounced_sessions_only.website_session_id as bounced_website_session_id
from sessions_with_entry_page_demo
left join bounced_sessions_only
on bounced_sessions_only.website_session_id = sessions_with_entry_page_demo.website_session_id
order by sessions_with_entry_page_demo.website_session_id;

-- Step 4: Summarizing total sessions and bounced sessions , by LP
-- Final output:
	-- We will use the same query we previous ran, and run a count of records 
    -- We will group by entry page, and we will add a bounce rate column.
select 
count(distinct sessions_with_entry_page_demo.website_session_id) as sessions,
sessions_with_entry_page_demo.pageview_url,
count(distinct bounced_sessions_only.website_session_id) as bounced_website_sessions,
count(distinct bounced_sessions_only.website_session_id) / 
count(distinct sessions_with_entry_page_demo.website_session_id) as bounce_rate
from sessions_with_entry_page_demo
left join bounced_sessions_only
on bounced_sessions_only.website_session_id = sessions_with_entry_page_demo.website_session_id
group by sessions_with_entry_page_demo.pageview_url;

# Calculating Bounce Rates 
-- Step 1: Finding the first website_pageview_id for revalent sessions 
-- Step 2: Identifying the entry page of each session
-- Step 3: Counting pageviews for each session, to identify "bounces"
-- Step 4: Summarizing by counting total sessions and bounce sessions
 
 -- Step 1: Finding the first website_pageview_id for revalent sessions 
create temporary table first_pageview
select website_session_id,
min(website_pageview_id) as min_pv_id 
from website_pageviews
where created_at <'2012-06-14'
group by 1;
select * from first_pageview;
    
-- Step 2: Identifying the entry page of each session
-- Next, we will bring in the entry page, like last time, but restrict to home only
-- This is redundant in this case, since all to the /home
select website_pageview_id from website_pageviews;
create temporary table sessions_with_home_entry_page
select 
first_pageview.website_session_id,
website_pageviews.pageview_url as entry_page
from first_pageview
left join website_pageviews
on website_pageviews.website_pageview_id = first_pageview.min_pv_id
where website_pageviews.pageview_url = '/home' ; -- Website pageview as entry page view
select * from sessions_with_home_entry_page;

-- Step 3: Counting pageviews for each session, to identify "bounces"
-- Then  a table to have count pageviews per sessions 
-- Then limit it to just bounced sessions
create temporary table bounced_sessions_only
select 
sessions_with_home_entry_page.website_session_id,
sessions_with_home_entry_page.entry_page,
count( distinct website_pageviews.website_pageview_id) as count_of_page_viewd
from sessions_with_home_entry_page
left join website_pageviews
on website_pageviews.website_session_id = sessions_with_home_entry_page.website_session_id
group by 1,2
having count_of_page_viewd = 1;

select * from bounced_sessions_only;
select * from sessions_with_home_entry_page;

-- Step 4: Summarizing by counting total sessions and bounce sessions
-- -- Next, we are going to have our sessions with entry page 
select * from bounced_sessions_only;
select * from sessions_with_home_entry_page;

select sessions_with_home_entry_page.website_session_id,
sessions_with_home_entry_page.entry_page,
bounced_sessions_only.website_session_id as bounced_website_session_id
from sessions_with_home_entry_page
left join bounced_sessions_only
on bounced_sessions_only.website_session_id = sessions_with_home_entry_page.website_session_id
order by 1;

-- We will use the same query we previous ran, and run a count of records 
select 
count(distinct sessions_with_home_entry_page.website_session_id ) as sessions,
sessions_with_home_entry_page.entry_page,
count(distinct bounced_sessions_only.website_session_id ) as bounced_sessions
from sessions_with_home_entry_page
left join bounced_sessions_only
on sessions_with_home_entry_page.website_session_id = bounced_sessions_only.website_session_id
group by sessions_with_home_entry_page.entry_page;

-- Final Output
select 
count(distinct sessions_with_home_entry_page.website_session_id ) as sessions,
sessions_with_home_entry_page.entry_page,
count(distinct bounced_sessions_only.website_session_id ) as bounced_sessions,
count(distinct bounced_sessions_only.website_session_id ) 
/ count(distinct sessions_with_home_entry_page.website_session_id ) as bounced_rate 
from sessions_with_home_entry_page
left join bounced_sessions_only
on sessions_with_home_entry_page.website_session_id = bounced_sessions_only.website_session_id
group by sessions_with_home_entry_page.entry_page;

# Analyzing Entry Page Test 
-- Step 0: Find out when the new page /lander launched
-- Step 1: Finding the first instance of /lander-1 to set analysis time frame
-- Step 2: Identifying the entry page of each session 
-- Step 3: Counting pageviews fro each sessions, to identify "bounces"
-- Step 4: Summarizing total sessions and bounced sessions, by LP
select * from website_pageviews;

-- Step 0: Find out when the new page /lander launched
select 
min(created_at) as first_date_created,
min(website_pageview_id) as first_pv_id
from website_pageviews
where pageview_url = '/lander-1' and created_at is not null;

-- first_date_created = '2012-06-19 00:35:54' 
-- first_pv_id = '23504'

-- Step 1: Finding the first instance of /lander-1 to set analysis time frame
create temporary table first_test_pageviews
select 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews
inner join website_sessions
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
and website_pageviews.website_pageview_id > 23504 -- the min_pv_id we found
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
group by website_pageviews.website_session_id;

select * from first_test_pageviews;

-- Step 2: Identifying the entry page of each session 
create temporary table nonbrand_test_session_with_entry_page
select 
first_test_pageviews.website_session_id,
website_pageviews.pageview_url as entry_page
from first_test_pageviews
left join website_pageviews
on website_pageviews.website_pageview_id = first_test_pageviews.min_pv_id
where website_pageviews.pageview_url in ('/home', '/lander-1') ; -- Website pageview as entry page view

select * from nonbrand_test_session_with_entry_page;

-- Step 3: Counting pageviews from each sessions, to identify "bounces"
create temporary table nonbrand_test_bounced_sessions
select 
nonbrand_test_session_with_entry_page.website_session_id,
nonbrand_test_session_with_entry_page.entry_page,
count( distinct website_pageviews.website_pageview_id) as count_of_page_viewd
from nonbrand_test_session_with_entry_page
left join website_pageviews
on website_pageviews.website_session_id = nonbrand_test_session_with_entry_page.website_session_id
group by 1,2
having count_of_page_viewd = 1;

select * from nonbrand_test_bounced_sessions;

-- Step 4: Summarizing total sessions and bounced sessions, by LP
select * from nonbrand_test_bounced_sessions;
select * from nonbrand_test_session_with_entry_page;

select 
nonbrand_test_session_with_entry_page.website_session_id,
nonbrand_test_session_with_entry_page.entry_page,
nonbrand_test_bounced_sessions.website_session_id as bounced_website_session_id
from nonbrand_test_session_with_entry_page
left join nonbrand_test_bounced_sessions
on nonbrand_test_bounced_sessions.website_session_id = nonbrand_test_session_with_entry_page.website_session_id
order by 1;

-- Final Output
select 
count(distinct nonbrand_test_session_with_entry_page.website_session_id) as sessions,
nonbrand_test_session_with_entry_page.entry_page,
count(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_session,
count(distinct nonbrand_test_bounced_sessions.website_session_id) 
/ count(distinct nonbrand_test_session_with_entry_page.website_session_id) as bounce_rate
from nonbrand_test_session_with_entry_page
left join nonbrand_test_bounced_sessions
on nonbrand_test_bounced_sessions.website_session_id = nonbrand_test_session_with_entry_page.website_session_id
group by 2;

## BUSINESS CONCEPT: ANALYZING & TESTING CONVERSION FUNNELS
select * from website_pageviews
where website_session_id = 1059;
#### Using Subqueries
select * from (
	select * from website_sessions
    where website_session_id <= 100) as first_hundred;

-- Business Context
	-- we want to build a mini conversion funnel, from /lander-2 to /cart
	-- we want to know how many people reach each step, and also drop off rates
    -- for simplicity , we are looking at /lander-2 traffic only
    -- for simplicity , we are looking at customer who like Mr Fuzzy only
    
# Step 1: Select all pageviews for relevant sessions 
# Step 2: Identify each relevant pageview as the specific funnel step
# Step 3: Create the sessions-level conversion funnel view
# Step 4: Aggreate the data assess funel performance

select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pv_created_at,
case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_page,
case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
left join website_pageviews
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
order by 1;
    
-- Next we will put the previous query inside a subquery 
-- We will group by website_sessions_id, and take the max() of each flags
-- This max() becomes a made_it flag for that session, to show session made it there
create temporary table session_level_made_it_flags
select website_session_id,
max(products_page) as products_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it
from ( 
	select website_sessions.website_session_id,
	website_pageviews.pageview_url,
	website_pageviews.created_at as pv_created_at,
	case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_page,
	case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
	case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page
	from website_sessions
	left join website_pageviews
	on website_pageviews.website_session_id = website_sessions.website_session_id
	where website_sessions.created_at between '2014-01-01' and '2014-02-01'
	and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
	order by 1) as pv_level
group by 1;

select * from session_level_made_it_flags;
 ### Final Output (1)
select 
count(distinct website_session_id) as sessions,
count(distinct case when products_made_it = 1 then website_session_id else null end) as to_products,
count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart
from session_level_made_it_flags;

 ### Final Output (2)
select 
count(distinct website_session_id) as sessions,
count(distinct case when products_made_it = 1 then website_session_id else null end)
/ count(distinct website_session_id) as lander_clicked_through_rate,
count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
/ count(distinct case when products_made_it = 1 then website_session_id else null end)  as products_clicked_through_rate,
count(distinct case when cart_made_it = 1 then website_session_id else null end)
/ count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_clicked_through_rate
from session_level_made_it_flags;

-- Business Context
	-- we want to build a mini conversion funnel, from /lander-1 to /thankiu
	-- we want to know how many people reach each step, and also drop off rates
    -- for simplicity , we are looking at /lander-1 traffic only
    -- for simplicity , we are looking at customer who like Mr Fuzzy only
    
# Step 1: Select all pageviews for relevant sessions 
# Step 2: Identify each relevant pageview as the specific funnel step
# Step 3: Create the sessions-level conversion funnel view
# Step 4: Aggreate the data assess funel performance

select pageview_url from website_pageviews;

select website_sessions.website_session_id, 
website_pageviews.pageview_url,
website_pageviews.created_at as pv_created_at,
case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_page,
case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' 
then 1 else 0 end as mrfuzzy_page,
case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page,
case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_page,
case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 
end as thank_page
from website_sessions
left join website_pageviews
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-08-05'
and website_sessions.created_at < '2012-09-05'
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
order by 1, 2;

-- Next we will put the previous query inside a subquery 
-- We will group by website_sessions_id, and take the max() of each flags
-- This max() becomes a made_it flag for that session, to show session made it there
create temporary table session2_level_made_it_flags
select website_session_id,
max(products_page) as products_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it,
max(shipping_page) as shipping_made_it,
max(billing_page) as billing_made_it,
max(thank_page) as thank_made_it
from (select website_sessions.website_session_id, 
website_pageviews.pageview_url,
website_pageviews.created_at as pv_created_at,
case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_page,
case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' 
then 1 else 0 end as mrfuzzy_page,
case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page,
case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_page,
case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 
end as thank_page
from website_sessions
left join website_pageviews
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-08-05'
and website_sessions.created_at < '2012-09-05'
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
 order by 1, 2) as pv_level
group by 1;
select * from session2_level_made_it_flags;

 ### Final Output (1)
 select 
 count(distinct website_session_id) as sessions,
 count(distinct case when products_made_it = 1 then website_session_id else null end) 
 as to_products,
 count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) 
 as to_mrfuzzy,
 count(distinct case when cart_made_it = 1 then website_session_id else null end) 
 as to_cart,
 count(distinct case when shipping_made_it = 1 then website_session_id else null end) 
 as to_shipping,
 count(distinct case when billing_made_it = 1 then website_session_id else null end) 
 as to_billing,
 count(distinct case when thank_made_it = 1 then website_session_id else null end) 
 as to_thank
 from session2_level_made_it_flags;
 ### Final Output (2)
 select 
 count(distinct website_session_id) as sessions,
 count(distinct case when products_made_it = 1 then website_session_id else null end) 
 /  count(distinct website_session_id) as lander_clicked_through_rate,
 count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) 
/count(distinct case when products_made_it = 1 then website_session_id else null end) 
as products_clicked_through_rate,
 count(distinct case when cart_made_it = 1 then website_session_id else null end)
 /count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
 as mrfuzzy_clicked_through_rate,
 count(distinct case when shipping_made_it = 1 then website_session_id else null end) 
 / count(distinct case when cart_made_it = 1 then website_session_id else null end)
 as  cart_clicked_through_rate,
 count(distinct case when billing_made_it = 1 then website_session_id else null end) 
 / count(distinct case when shipping_made_it = 1 then website_session_id else null end) 
 as shipping_clicked_through_rate,
 count(distinct case when thank_made_it = 1 then website_session_id else null end)
 /count(distinct case when billing_made_it = 1 then website_session_id else null end)
 as billing_clicked_through_rate
 from session2_level_made_it_flags;
 
 ### Analyzing Conversion Funel Test
 -- Finding the first time / billing-2 was seen 
 select website_session_id,
 min(website_pageview_id) as first_pv_id
 from website_pageviews
 where pageview_url = '/billing-2'
 group by 1;
 
 select website_pageviews.website_session_id,
 website_pageviews.pageview_url as billing_version_seen,
 orders.order_id 
 from website_pageviews
 left join orders 
 on orders.website_session_id = website_pageviews.website_session_id
 where website_pageviews.website_pageview_id >= '53550' -- first pv id where the test was live
 and website_pageviews.created_at <'2012-11-10' -- time of assignment
 and website_pageviews.pageview_url in ('/billing-2','/billing');
 
 ### Final Output Analyzing Conversion Funel Test
 select billing_version_seen,
 count(distinct website_session_id) as sessions,
 count(distinct order_id) as orders,
 count(distinct order_id) / count(distinct website_session_id) as billing_to_order_rate
 from ( select website_pageviews.website_session_id,
 website_pageviews.pageview_url as billing_version_seen,
 orders.order_id 
 from website_pageviews
 left join orders 
 on orders.website_session_id = website_pageviews.website_session_id
 where website_pageviews.website_pageview_id >= '53550' -- first pv id where the test was live
 and website_pageviews.created_at <'2012-11-10' -- time of assignment
 and website_pageviews.pageview_url in ('/billing-2','/billing')
 ) as billing_sessions_w_orders
group by 1;
 
