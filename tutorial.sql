--install dbeaver (community edition) on your system: https://dbeaver.io/download/
--download the csv: https://github.com/Vassago1911/toy_examples/blob/master/geo_dev_app.csv

--add new database connection (upper left, first button in the bar), and choose type "csv"
--      choose the folder where you put the csv above as your path (below JDBC URL)
--      if necessary let dbeaver download the csv jdbc driver
--=> now you should see a "Flat files - <folder name>" connection in your database navigator

--open a new SQL Editor (7th button in the bar, symbol: a sheet of paper with a plus "+")

--===== SQL 101 =====--
-- SQL can be used on data that's in a rectangular shape, "has a schema", i.e. each row in a table
-- looks the same, e.g. User = id, first_name, last_name, day_of_birth and you have an entry for each user in each field
-- with the CSV-Database connection the folder is the "database" and the csv-files are the "tables"

--===== SELECT, FROM, ; =====--
--now we can learn the first SQL vocabulary: SELECT and FROM and ; 
select * from geo_dev_app;

-- select: which columns do you want displayed, e.g.
select geo from geo_dev_app;

select device from geo_dev_app;

select geo, device, install_date from geo_dev_app;

-- columns should be subscripted once you need more than one table (won't happen today, we won't cover JOINs)
select geo_dev_app.geo from geo_dev_app;

-- aliasing saves a lot of typing
select g.geo, g.device from geo_dev_app g;

-- from = from which file / usually *table*; imagine we had a dev_app.csv and atlas.csv in addition
select geo from geo_dev_app;

select geo from dev_app;

select geo from atlas;

-- every sql-statement needs to end in an ";" to tell the compiler "read from 'select' to ';'
--============================--
--===== WHERE =====--
--You usually don't want all data from a table, instead just data from a specific date, users of a specific age,
--users from a specific geo which came on a specific date,.. etc.

select * from geo_dev_app where 

