#1. For each order (identified by order ID), calculate a sub total for each order. The sub-total is defined by (UnitPrice * Quantity * (1-Discount))
use northwind;
SELECT 
    orderid, unitprice * quantity * (1 - Discount) AS subtotal
FROM
    `order details`;

#2. Get the sales by year (Hint : Use the shipped date column to get the year). The sub-total will be calculated in the same way as in question 1

SELECT 
    o.orderid,
    a.subtotal,
    YEAR(o.shippeddate) AS Year
FROM
    orders o
        INNER JOIN
    (SELECT 
        orderid, UnitPrice * Quantity * (1 - Discount) AS Subtotal
    FROM
        `order details`
    GROUP BY orderid) a ON o.orderid = a.orderid
WHERE
    o.shippeddate IS NOT NULL
ORDER BY o.shippeddate;

#3.For each employee, get their sales amount, broken down by country name

select distinct e.Country, 
    e.LastName, 
    e.FirstName, 
    o.ShippedDate, 
    o.OrderID, 
	d.UnitPrice * d.Quantity * (1 - d.Discount) AS Subtotal
     from 
     employees e join orders o on e.employeeid=o.employeeid
     join
     `order details` d on o.orderid=d.orderid;

#4. Get the alphabetical list of products along with the following information -ProductID, SupplierID, CategoryID, QuantityPerUnit and UnitPrice
SELECT 
    productname,
    productid,
    supplierid,
    categoryid,
    quantityperunit,
    unitprice
FROM
    products
ORDER BY productname;

#5. Get the current product list. (Hint : The product should not be discontinued)

SELECT 
    ProductID, ProductName
FROM
    Products
WHERE
    Discontinued = 0
ORDER BY ProductName;

#6. Calculate the sales price for each order after discount is applied. The table should contain the ProductID and ProductName information as well
select * from `order details`;

SELECT 
    o.orderid,
    p.productid,
    p.productname,
    o.UnitPrice * o.Quantity * (1 - o.Discount) AS Sales
FROM
    `order details` o
        JOIN
    products p ON p.productid = o.productid
ORDER BY orderid;

#7. For each category, get the list of products sold and the total sales amount. Get it using both normal joins and a combinationof join and sub-queries
#using joins
SELECT 
    c.CategoryName,
    c.categoryid,
    p.productname,
    sum(o.UnitPrice * o.Quantity * (1 - o.Discount)) AS Sales
FROM
    `order details` o
        JOIN
    products p ON p.productid = o.productid
       join 
	categories c on p.CategoryID=c.CategoryID
group by ProductName
ORDER BY p.categoryid;

#using subqueries n joins


SELECT 
    c.CategoryName,
    p.categoryid,
    p.productname,
    sum(Subtotal) as Sales
FROM
categories c join
    products p on p.CategoryID=c.CategoryID
        INNER JOIN
    (SELECT 
        productid, UnitPrice * Quantity * (1 - Discount) AS Subtotal
    FROM
        `order details` 
    ) o ON p.productid = o.productid
    group by p.productname
    order by CategoryID;

#8. Get the top ten most expensive products
SELECT 
    productname, unitprice
FROM
    products
ORDER BY unitprice DESC
LIMIT 10;

#9.Merge the customer and supplier into one result set and create a new column which will help identify the customer and the supplier. Get the city, companyname, contactname and the new column

select 'SUPPLIERS',ContactName,City, CompanyName
from suppliers
union
select 'CUSTOMERS',ContactName,City, CompanyName
from customers
order by companyname;

#10. Get all the distinct productnames which are above the average price of a product
SELECT DISTINCT
    productname, unitprice
FROM
    products
WHERE
    unitprice > (SELECT 
            AVG(unitprice)
        FROM
            products)
ORDER BY unitprice;

#11. For the year 1997, get the CategoryName, ProductName, Sales and the ShippedQuarter
SELECT 
    *
FROM
    orders
WHERE
    ShippedDate BETWEEN DATE('1997-01-01') AND DATE('1997-12-31');
#As you can see 1997 data is not present
    
select c.CategoryName,p.ProductName, d.UnitPrice * d.Quantity * (1 - d.Discount) AS Sales, quarter(o.ShippedDate) as quater
from    orders o join  `order details` d on o.orderid=d.OrderID
        JOIN
    products p ON p.productid = d.productid
       join 
	categories c on p.CategoryID=c.CategoryID
   where o.ShippedDate between date('1997-01-01') and date('1997-12-31')
   group by p.productname,c.categoryname;

# 12. For the year 1997, get the TotalSales by Category

SELECT 
    c.Categoryname,
    SUM(d.UnitPrice * d.Quantity * (1 - d.Discount)) AS TotalSales
FROM
    orders o
        JOIN
    `order details` d ON o.orderid = d.OrderID
        JOIN
    products p ON p.productid = d.productid
        JOIN
    categories c ON p.CategoryID = c.CategoryID
WHERE
    o.ShippedDate BETWEEN DATE('1997-01-01') AND DATE('1997-12-31')
GROUP BY c.categoryname;
   
#13. Get the quarterly sales by product.

SELECT 
    d.CompanyName,
    p.ProductName,
    YEAR(c.OrderDate) AS Year,
    SUM(CASE QUARTER(c.OrderDate)
        WHEN '1' THEN b.UnitPrice * b.Quantity * (1 - b.Discount)
        ELSE 0
    END) AS 'Qtr 1',
    SUM(CASE QUARTER(c.OrderDate)
        WHEN '2' THEN b.UnitPrice * b.Quantity * (1 - b.Discount)
        ELSE 0
    END) AS 'Qtr 2',
    SUM(CASE QUARTER(c.OrderDate)
        WHEN '3' THEN b.UnitPrice * b.Quantity * (1 - b.Discount)
        ELSE 0
    END) AS 'Qtr 3',
    SUM(CASE QUARTER(c.OrderDate)
        WHEN '4' THEN b.UnitPrice * b.Quantity * (1 - b.Discount)
        ELSE 0
    END) AS 'Qtr 4'
FROM
    Products p
        JOIN
    `Order Details` b ON p.ProductID = b.ProductID
        JOIN
    Orders c ON c.OrderID = b.OrderID
        JOIN
    Customers d ON d.CustomerID = c.CustomerID
WHERE
    c.OrderDate BETWEEN DATE('1997-01-01') AND DATE('1997-12-31')
GROUP BY p.ProductName , d.companyname;

