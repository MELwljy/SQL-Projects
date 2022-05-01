-- ctrl+/ 给注释

-- LEC 3
SELECT prod_id, prod_name,prod_price FROM Products;
SELECT * FROM Products;
SELECT * FROM Products limit 5;
SELECT vEND_id,prod_price FROM Products;
SELECT DISTINCT vEND_id FROM Products;
SELECT vEND_id,prod_price FROM Products;
/* 
SELECT vEND_id,prod_price FROM Products;
*/

-- Lec 4
SELECT prod_name FROM Products
-- SELECT prod_name FROM retail.Products
ORDER BY prod_name;

SELECT prod_id,prod_price,prod_name FROM Products
ORDER BY prod_price, prod_name;

SELECT prod_id,prod_price,prod_name FROM Products
ORDER BY 2,3; -- relative column position(prod_price,prod_name)

SELECT prod_id,prod_price,prod_name FROM Products
ORDER BY prod_price  desc; -- 降序排列

SELECT prod_id,prod_price,prod_name FROM Products
ORDER BY 2 desc, 3; -- price 降序排列 name 升序

SELECT prod_id,prod_price,prod_name FROM Products
where prod_price <=10
ORDER BY 1;

-- Check for Nonmatches:
SELECT vEND_id,prod_name FROM Products
where vEND_id <> 'DLL01';

-- Check for a Range of Values:
SELECT prod_name , prod_price FROM Products
WHERE prod_price BETWEEN 5 AND 10; -- inclusive

-- Check for No Value
SELECT * FROM Customers
WHERE cust_email is NULL;

SELECT * FROM Customers
WHERE cust_email is not NULL;

SELECT prod_id , vEND_id, prod_price , prod_name FROM Products
WHERE vEND_id = 'DLL01' AND prod_price <= 4;

SELECT prod_id , vEND_id, prod_price , prod_name FROM Products
WHERE vEND_id = 'DLL01' or prod_price <= 4;

-- Lec 5
SELECT prod_name, prod_price,vEND_id FROM retail.Products
WHERE (vEND_id = 'DLL01' OR vEND_id ='BRS01') 
AND prod_price >= 10;

-- in operator
SELECT prod_name, prod_price,vEND_id FROM retail.Products
WHERE vEND_id in ('DLL01','BRS01') ;

SELECT prod_name, prod_price,vEND_id FROM retail.Products
WHERE vEND_id = 'DLL01' OR vEND_id ='BRS01';

-- % wildcard 代表任意数量
SELECT prod_id , prod_name FROM Products
WHERE prod_name LIKE 'Fish%';

SELECT prod_id , prod_name FROM Products
WHERE prod_name LIKE '%bean bag%';

-- The Underscore (_) Wildcard match a single character 
SELECT prod_id , prod_name FROM Products
WHERE prod_name LIKE '__inch teddy bear'; -- 此处两个underscore 含空格

SELECT prod_id , prod_name FROM Products
WHERE prod_name LIKE '___inch teddy bear'; -- 此处三个underscore 前面一定要有三个值 含空格

SELECT prod_id,prod_name FROM Products
WHERE prod_name LIKE '%inch teddy bear';

-- Lec 6
-- MySQL uses CONCAT() to concatenate strings:
SELECT vEND_name, vEND_country,
CONCAT(vEND_name,'(',vEND_country,')')
FROM VENDors 
ORDER BY vEND_name;

-- Use AliASes to name the new calculated column
SELECT vEND_name, vEND_country,
CONCAT(vEND_name,'(',vEND_country,')') AS vEND_title -- 名字中间不要使用空格
FROM VENDors 
ORDER BY vEND_name;

SELECT quantity*item_price AS total_sales,
item_price,prod_id,quantity
FROM OrderItems
WHERE order_num = 20008;

-- Understand Functions
-- Upper cASe
SELECT vEND_name , UPPER(vEND_name) AS vEND_name_uppercASe 
FROM VENDors 
ORDER BY vEND_name;

-- 提取部分
SELECT vEND_name , SUBSTRING(vEND_name,1,4) AS first_4_letters_of_vEND_name 
FROM VENDors ORDER BY vEND_name;

SELECT order_date , SUBSTRING(order_date,1,7) AS month1,-- 带年份
SUBSTRING(order_date,6,2) AS month2 -- 不带年份
FROM Orders;

-- Date and time functions
SELECT order_num,order_date FROM Orders
WHERE YEAR(order_date)=2012;

-- 现在时间
SELECT order_num,order_date, Now()AS currentdateandtime 
FROM Orders;

-- datediff 时间差（前面的日期减后面的日期） curdate 返回日期不带时间
SELECT order_num,order_date, Now()AS currentdateandtime,curdate() AS curdt,
datediff(curdate(),order_date) AS dategap
FROM Orders;

SELECT prod_price,
CASE WHEN prod_price < 6 THEN 'low price' ELSE 'high price' END
FROM Products;

SELECT prod_price,
CASE WHEN  prod_price < 5 THEN 'low price' 
 WHEN prod_price < 6 THEN 'Median price'
 ELSE 'high price' END AS price_segment
FROM Products;


-- Lec 7
SELECT AVG(prod_price) AS avg_price
FROM Products;

SELECT AVG(prod_price) AS avg_price
FROM Products
WHERE vend_id="DLL01"; -- 如果有空值 avg 计算会忽略空值 （这条记录不参与计算）

SELECT COUNT(*) AS num_cust -- count rows 包含values and null
FROM Customers;

SELECT COUNT(cust_email) AS num_cust -- count rows 只包含values
FROM Customers;

SELECT *
FROM Customers;

SELECT MAX(prod_price) AS max_price
FROM Products;

SELECT MIN(prod_price) AS max_price
FROM Products;

SELECT SUM(quantity) AS items_ordered
FROM OrderItems
WHERE order_num = 20005;

SELECT SUM(quantity) AS items_ordered
FROM OrderItems
WHERE order_num = 20005;

SELECT SUM(item_price *quantity) AS total_sales  -- item_price *quantity 算一个item，也只能放一个
FROM OrderItems
WHERE order_num =20005;

-- Aggregates on Distinct Values
SELECT count(DISTINCT prod_price ) AS count_price
FROM Products
WHERE vend_id = 'DLL01';

SELECT count(DISTINCT vend_id) FROM Products; -- 有几个不同的vendor？
SELECT vend_id FROM Products;

-- Combine Aggregate Functions
SELECT COUNT(*) AS num_items,
MIN(prod_price ) AS price_min,
MAX(prod_price ) AS price_max,
AVG(prod_price ) AS price_avg
FROM Products;

-- identify 
-- 1) how many records?
-- 2) whether there are missings?
-- 3) whether there are dup records?

Select * FROM Products;
Select count(*),count(vend_id),count(distinct vend_id) FROM Products; 
-- 如果count(vend_id)<count(*) 则有missing


-- LEC 8
SELECT vend_id ,
COUNT(*) AS num_prod
FROM Products
GROUP BY vend_id
ORDER by num_prods;


-- Create groups
-- ASide FROM the aggregate calculation statements, every column in your SELECT statement
-- must be present in the GROUP BY clause!!!
-- 正确例子
SELECT order_num,prod_id, -- 这里有 order num 和 prod id 
sum(quantity)
FROM OrderItems
GROUP BY order_num,prod_id; -- 这里必须也有order num 和 prod id  两个层级做sum
-- GROUP BY 1,2; 第一列为第一个层级 第二列为第二个层级

-- 错误例子
SELECT order_num,prod_id, 
sum(quantity)
FROM OrderItems
GROUP BY order_num; -- 错误例子

-- Filter Groups
-- notice： where 在 GROUP BY 之前发生, having 在GROUP BY 之后发生
-- Use HAVING only in conjunction with GROUP BY clauses.
-- Use WHERE for standard row level filtering

SELECT cust_id , COUNT(*) AS orders
FROM Orders
GROUP BY cust_id
HAVING COUNT(*) >= 2;

SELECT COUNT(*) AS orders
FROM Orders;

SELECT cust_id , COUNT(*) AS orders
FROM Orders
GROUP BY cust_id
HAVING COUNT(*) >= 2;

SELECT vend_id , COUNT(*) AS num_prods
FROM Products
WHERE prod_price >= 4
GROUP BY vend_id
HAVING COUNT(*) >= 2;

SELECT vend_id, count(*) AS num_prods
FROM Products
GROUP BY vend_id
having num_prods > 3;

-- Subqueries
-- Example: Now suppose you wanted a list of all the customers who ordered item RGAN01:
-- 1. Retrieve the order numbers of all orders containing item RGAN01
SELECT order_num
FROM OrderItems
WHERE prod_id = 'RGAN01';
-- 2. Retrieve the customer ID of all the customers who have orders listed in the order numbers returned in the previous step
SELECT cust_id
FROM Orders
WHERE order_num IN (20007,20008);

-- 3. Retrieve the customer information for all the customer IDs returned in the previous step
SELECT cust_name,cust_contact
FROM Customers
WHERE cust_id IN ('1000000004','1000000005');


SELECT cust_name , cust_contact
FROM Customers
WHERE cust_id IN (SELECT cust_id 
					FROM Orders 
					WHERE order_num IN (SELECT order_num 
											FROM OrderItems
											WHERE prod_id = 'RGAN01'));


-- LEC 9 & 10
-- Inner Join
SELECT * FROM Vendors;
SELECT * FROM Products;

-- Cartesian Product
SELECT * FROM Vendors, Products; -- 54 条

-- INNER JOIN
SELECT *
FROM Vendors, Products
WHERE Vendors.vend_id = Products.vend_id; 
-- and vend_country = 'USA';

SELECT vend_name , prod_name , prod_price
FROM Vendors INNER JOIN Products
ON Vendors.vend_id = Products.vend_id;
-- where vend_country = 'USA';

-- Join multiple table
select * from OrderItems;

SELECT order_num, prod_name, vend_name, prod_price, quantity
	FROM OrderItems, Products, Vendors   -- 顺序不重要
	WHERE Products.vend_id = Vendors.vend_id
	AND OrderItems.prod_id = Products.prod_id
	AND order_num = 20007;


-- EXAMPLE from last class
SELECT cust_name , cust_contact
FROM Customers
WHERE cust_id IN (SELECT cust_id 
					FROM Orders 
					WHERE order_num IN (SELECT order_num 
											FROM OrderItems
											WHERE prod_id = 'RGAN01'));  
    
SELECT cust_name , cust_contact
	FROM OrderItems, Orders, Customers  
	WHERE Orders.order_num=OrderItems.order_num
	AND Customers.cust_id = Orders.cust_id
    AND prod_id='RGAN01';
    
SELECT cust_name , cust_contact
	FROM OrderItems join Orders on Orders.order_num=OrderItems.order_num
    join Customers on Customers.cust_id = Orders.cust_id
    WHERE prod_id='RGAN01';

-- Table Aliases
SELECT C.cust_name , C.cust_contact as customer_contact
FROM Customers AS C, Orders AS O, OrderItems AS OI
WHERE C.cust_id = O.cust_id
AND OI.order_num = O.order_num
AND prod_id = 'RGAN01';

-- only write the column you need
SELECT C.*, O.order_num, O.order_date, OI.prod_id, OI.quantity, OI.item_price
	FROM Customers AS C, Orders AS O, OrderItems AS OI
	WHERE C.cust_id = O.cust_id AND OI.order_num = O.order_num 
	AND prod_id = 'RGAN01';

SELECT *
	FROM Customers AS C, Orders AS O, OrderItems AS OI
	WHERE C.cust_id = O.cust_id AND OI.order_num = O.order_num 
	AND prod_id = 'RGAN01';
    
-- Join 时where 不是先运行的 where 不要用calculated filed


-- LEC 11
-- 不能用where
SELECT * from Customers;
SELECT * from Orders;

SELECT Customers.cust_id , Orders.order_num
FROM Customers LEFT OUTER JOIN Orders
ON Customers.cust_id = Orders.cust_id; # 为null就是没有购买任何东西

SELECT Customers.cust_id , Orders.order_num
FROM Customers RIGHT JOIN Orders
ON Customers.cust_id = Orders.cust_id;

-- LEFT/RIGHT JOIN 表的order matters
-- A right outer join can be turned into a left outer join simply by reversing the order
-- of the tables in the FROM clause

-- You can still use WHERE clause after ON condition to do filtering

-- 每个customer order 了几次？活跃度 
SELECT Customers.cust_id , count(Orders.order_num) AS num_ord
FROM Customers
INNER JOIN Orders
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;
 
select count(*) from Customers;
select count(cust_contact) from Customers; -- notice 空格不是null
select * from Customers;

-- count missing 会返回0
SELECT Customers.cust_id , count(Orders.order_num) AS num_ord -- be careful about count（*） count（*）对于空值依然会计数
FROM Customers
Left JOIN Orders
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;


SELECT Customers.cust_id , count(*) AS num_ord -- be careful about count（*） count（*）会把missing 返回1
FROM Customers
Left JOIN Orders
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;

SELECT C.cust_id,cust_name,cust_contact
	FROM Customers AS C
    LEFT JOIN Orders AS O
    ON C.cust_id = O.cust_id
    LEFT JOIN OrderItems AS OI
    ON OI.order_num = O.order_num
    where prod_id= 'RGAN01';
    


-- JOIN 是横向添加列 ！ UNION=APPEND 是上下接起来表
-- UNION
select
cust_name , cust_contact , cust_email
from Customers where
cust_state in ('IL', 'IN','MI')
UNION
select 
cust_name , cust_contact , cust_email
from Customers where
cust_name = 'Fun4All';

-- 对比两个result，Union 会自动去重

select
cust_name , cust_contact , cust_email,cust_state
from Customers where
cust_state in ('IL', 'IN','MI')
UNION
select 
cust_name , cust_contact , cust_email,cust_state
from Customers where
cust_name = 'Fun4All';

SELECT cust_name , cust_contact , cust_email,cust_state
from Customers where
cust_state in ('IL', 'IN','MI')
UNION ALL
select cust_name , cust_contact , cust_email,cust_state
from Customers where
cust_name = 'Fun4All'; 

-- 保证最后一个query 有order by
select cust_name , cust_contact , cust_email
from Customers where cust_state in ('IL', 'IN','MI')
UNION ALL
select cust_name , cust_contact , cust_email
from Customers where cust_name = 'Fun4All'
ORDER BY
cust_name,cust_contact;

-- LEC 12
select * from Customers;

INSERT INTO Customers
(cust_id,cust_name,cust_address,cust_city,cust_state,cust_zip,cust_country,cust_contact,cust_email)
VALUES
('1000000007','Toy Land','123 Any Street', 'New York','NY','11111','USA',NULL,NULL);
-- 会报错 说100000007 已经存在了
INSERT INTO Customers
(cust_id,cust_name,cust_address,cust_city,cust_state,cust_zip,cust_country,cust_contact,cust_email)
VALUES
('100000016','Toy Land','123 Any Street', 'New York','NY','11111','USA',NULL,NULL);

select * from Customers;

INSERT INTO
Customers
(cust_id,cust_name,cust_address,cust_city,cust_state,cust_zip,cust_country,cust_contact,cust_email)
SELECT
cust_id,cust_name,cust_address,cust_city,cust_state,cust_zip,cust_country,cust_contact,cust_email
FROM CustNew;

select * from Customers where cust_id='1000000005';

-- To update specific rows in a table
UPDATE Customers
SET
cust_email = 'kim@gmail.com'
WHERE
cust_id = '1000000005';

-- Update multiple columns:
UPDATE Customers
SET
cust_email = 'kim@gmail.com',
cust_contact = 'Sam Roberts'
WHERE
cust_id = '1000000005';

-- 不加where那么all rows 被影响
UPDATE Customers
SET
cust_email = 'kim@gmail.com',
cust_contact = 'Sam Roberts';

DELETE FROM Customers
WHERE cust_id= 'To Land2';


select * from Customers;

-- Create table
CREATE TABLE
new_c AS 
SELECT * FROM Customers;

-- Drop table 
DROP TABLE if exists new_c;

Select vend_id,
count(*) as num_prods
From Products
Where prod_price >= 4
			Group by vend_id
            Order by num_prods;
            
-- Derived Table 必须要给一个名字
SELECT a.vend_id , b.vend_city FROM
	(SELECT vend_id , COUNT(*) AS num_prods
	FROM Products WHERE
	prod_price >= 4
	GROUP BY vend_id
	Having num_prods >=2
    order by num_prods) AS A
LEFT JOIN Vendors as B
on a.vend_id=b.vend_id;

-- 或者可以但是很麻烦：
drop table a;
Create table a as
SELECT vend_id , COUNT(*) AS num_prods
	FROM Products WHERE
	prod_price >= 4
	GROUP BY vend_id
	Having num_prods >=2
    order by num_prods;
    
SELECT a.vend_id , b.vend_city FROM a 
left join Vendors as b
on a.vend_id=b.vend_id;


-- Lec 13 
Select * from Orders;

Select cust_id, order_date, 
row_number() over (Partition by cust_id order by order_date desc) as row_num
From Orders;

Select cust_id, order_date, order_num from 
(select *,
row_number() over (Partition by cust_id order by order_date desc) as row_num
From Orders) as t
where t.row_num=1;

Select cust_id, order_date, 
row_number() over (Partition by cust_id, order_date order by order_date desc) as row_num
From Orders;


