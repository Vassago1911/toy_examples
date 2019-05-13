--install dbeaver (community edition) on your system: https://dbeaver.io/download/
--download the example database: https://github.com/Vassago1911/toy_examples/blob/master/sqlite.db

--add new database connection (upper left, first button in the bar), and choose type "sqlite"
--      choose the folder where you put the db above as your path (below JDBC URL)
--      if necessary let dbeaver download the sqlite jdbc driver
--=> now you should see a "SQLite - sqlite.db" connection in your database navigator

--open a new SQL Editor (7th button in the bar, symbol: a sheet of paper with a plus "+")

--===== SQL 101 =====--
-- SQL can be used on data that's in a rectangular shape, "has a schema", i.e. each row in a table
-- looks the same, e.g. User = id, first_name, last_name, day_of_birth and you have an entry for each user in each field
-- with the SQLite-Database connection the file is the "database" and its data can be organised into "tables", we only have one here

--===== SELECT, FROM, ; =====--
--now we can learn the first SQL vocabulary: SELECT and FROM and ; 
select * from app_sales;

-- select: which columns do you want displayed, e.g.
select id from app_sales;

select useruuid from app_sales;

select id, useruuid, geo from app_sales;

-- columns should be subscripted once you need more than one table (won't happen today, we won't cover JOINs)
select app_sales.geo from app_sales;

-- from = from which *table*; imagine we had more customer-information, it might be a table "users"
select * from users; -- won't work of course

select * from app_sales;

-- every sql-statement needs to end in an ";" to tell the compiler "read from 'select' to ';'

--==============================--
--========== AS, aka Aliases ===--
-- aliasing saves a lot of typing
-- you can alias the table (usual case)
select a.geo, a.useruuid from app_sales as a;

--you can alias columns (less often)
select geo as country, useruuid as uuid from app_sales;

--you need "as" often, hence you don't need to write it at all
select id id_alias, useruuid uuid_alias, geo country, net network, user_create creat, app_install ai, app_sale as_, app_price price from app_sales as__;

--you can alias derived columns (very useful, probably not that often)
select geo, useruuid, user_create, app_install, JULIANDAY(app_install) - JULIANDAY(user_create) + 1 install_dx from app_sales;

--alias more columns
select geo, useruuid, user_create, app_install, app_sale, 
       JULIANDAY(app_install) - JULIANDAY(user_create) + 1 install_dx, 
       JULIANDAY(app_install) - JULIANDAY(app_sale) + 1 sale_to_install_dx  
  from app_sales;

  --============================--
--===== WHERE =====--
--You usually don't want all data from a table, instead just data from a specific date, users of a specific age,
--users from a specific geo which came on a specific date,.. etc.

select * from app_sales where user_create = '2019-05-06';

select * from app_sales where user_create = '2019-05-06' and app_install = '2019-05-06' and app_sale = '2019-05-06';

--typically it's fast to filter for the id-column
select * from app_sales where id > 101000;

select geo, user_create from app_sales where id > 113000;
--============================--
--===== ORDER BY, ASC, DESC =====--
--if you look at raw data, sorting it is usually essential to get a feeling for it:
select * from app_sales order by random();

select * from app_sales order by geo, user_create, app_install desc;

--============================--
--===== subqueries! =====--
--we don't look into any joins today, but most can be avoided if you know subqueries, which most find easier
select * from app_sales 
where useruuid in (select distinct useruuid from app_sales where app_sale > '')
  and net in ('Adwords','Facebook');

--============================--
--===== GROUP BY, HAVING =====--
------- COUNT, SUM, MIN, MAX, AVG -------  
--let's count the rows in app_sales
select count(*) from app_sales;  
  
--let's count them split by geo
select geo, count(*) from app_sales group by geo;

--let's count them split by net 
select net, count(*) from app_sales group by net;

--let's count split by net and geo!
select geo, net, count(*) from app_sales group by geo, net;

--let's not look into trivial entries and discard all counts below 100
select geo, net, count(*) cnt from app_sales group by geo, net having cnt > 100;

--maybe even 1000
select geo, net, count(*) cnt from app_sales group by geo, net having cnt > 1000;

--now sort by relevance
select geo, net, count(*) cnt from app_sales group by geo, net having cnt > 1000 order by cnt desc;

--we can SUM too, or MIN, MAX, ..
select geo, user_create, max(app_install), sum(app_price) from app_sales group by geo, user_create;

--let's MIN
select geo, user_create, min(app_install) from app_sales;

--oops, let's MIN again
select geo, user_create, min(app_install) from app_sales where app_install > '';

--try avg on prices
select geo, net, avg(app_price) mean from app_sales group by geo, net;

--in sqlite you have to use sigma²(X) = E(X)² - E(X²), in some dialects you have stddev
select geo, net, avg(app_price) mean, sqrt(-avg(app_price)*2+ avg(app_price*app_price)) stddev from app_sales group by geo, net;

---========================---
--===case-statement===--
--say we want to split the world in facebook versus rest
select case when net = 'Facebook' then net else 'Other' end net, * from app_sales;

--now we can group by this 
select case when net = 'Facebook' then net else 'Other' end net, count(*) from app_sales group by net;

--oh, the alias doesn't work well
select case when net = 'Facebook' then net else 'Other' end net1, count(*) from app_sales group by net1;

--============================--
--==Where the wild KPIs grow==-- 
--==count under conditions: count user, install, sale==--
select geo, net, count(a.id) users, 
       sum(case when a.app_install >'' then 1 else 0 end) app_installs, 
       sum(case when a.app_sale > '' then 1 else 0 end) app_sales
  from app_sales as a group by geo, net;  

--then we can define new kpis on this
select geo, net, count(a.id) users, 
       sum(case when a.app_install >'' then 1 else 0 end) app_installs, 
       sum(case when a.app_sale > '' then 1 else 0 end) app_sales,
       sum(case when a.app_install >'' then 1 else 0 end)*1.0/count(a.id) installs_per_user,
       sum(case when a.app_sale > '' then 1 else 0 end)*1.0/sum(case when a.app_install >'' then 1 else 0 end) sell_per_install,
       1.0/(sum(case when a.app_sale > '' then 1 else 0 end)*1.0/sum(case when a.app_install >'' then 1 else 0 end)) install_per_sell
  from app_sales as a group by geo, net;    