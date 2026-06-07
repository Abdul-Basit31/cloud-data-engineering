
-- ============================================================
--  Top 5 Customers by Total Order Amount
--  Show CustomerID, CustomerName, and TotalSpent
-- ============================================================


-- select *
-- from dbo.SalesOrder;

-- select *
--from dbo.SalesOrder;

SELECT TOP 5
    c.customer_id AS CustomerID,
    c.first_name + ' ' + c.last_name AS CustomerName,
    SUM(o.total_amount) AS TotalSpent
FROM dbo.SalesOrder AS c
JOIN dbo.salesorders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY TotalSpent DESC;

-- Q2. Find the number of products supplied by each supplier

SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM dbo.customer c
INNER JOIN dbo.salesorder so
    ON c.CustomerID = so.CustomerID
GROUP BY
    c.CustomerID,
    c.Name
ORDER BY TotalSpent DESC;

-- Q3. Identify products that have been ordered but never returned
-- Show ProductID, ProductName, and total order quantity.

SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM dbo.supplier s
INNER JOIN dbo.purchaseorder po
    ON s.SupplierID = po.SupplierID
INNER JOIN dbo.purchaseorderdetail pod
    ON po.OrderID = pod.OrderID
GROUP BY
    s.SupplierID,
    s.Name
HAVING COUNT(DISTINCT pod.ProductID) > 10;


SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM dbo.product p
INNER JOIN dbo.salesorderdetail sod
    ON p.ProductID = sod.ProductID
LEFT JOIN dbo.returndetail rd
    ON p.ProductID = rd.ProductID
WHERE rd.ProductID IS NULL
GROUP BY
    p.ProductID,
    p.Name;

    -- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

    SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM dbo.product p
INNER JOIN dbo.category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price =
(
    SELECT MAX(p2.Price)
    FROM dbo.product p2
    WHERE p2.CategoryID = p.CategoryID
);

SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM dbo.salesorder so
INNER JOIN dbo.customer c
    ON so.CustomerID = c.CustomerID
INNER JOIN dbo.salesorderdetail sod
    ON so.OrderID = sod.OrderID
INNER JOIN dbo.product p
    ON sod.ProductID = p.ProductID
INNER JOIN dbo.category cat
    ON p.CategoryID = cat.CategoryID
INNER JOIN dbo.purchaseorderdetail pod
    ON p.ProductID = pod.ProductID
INNER JOIN dbo.purchaseorder po
    ON pod.OrderID = po.OrderID
INNER JOIN dbo.supplier s
    ON po.SupplierID = s.SupplierID;

    SELECT
    sh.ShipmentID,
    l.Name AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM dbo.shipment sh
INNER JOIN dbo.warehouse w
    ON sh.WarehouseID = w.WarehouseID
INNER JOIN dbo.employee e
    ON w.ManagerID = e.EmployeeID
INNER JOIN dbo.location l
    ON w.LocationID = l.LocationID
INNER JOIN dbo.shipmentdetail sd
    ON sh.ShipmentID = sd.ShipmentID
INNER JOIN dbo.product p
    ON sd.ProductID = p.ProductID;

    WITH RankedOrders AS
(
    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER
        (
            PARTITION BY c.CustomerID
            ORDER BY so.TotalAmount DESC
        ) AS OrderRank
    FROM dbo.customer c
    INNER JOIN dbo.salesorder so
        ON c.CustomerID = so.CustomerID
)
SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM RankedOrders
WHERE OrderRank <= 3
ORDER BY CustomerID, TotalAmount DESC;

SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity)
        OVER
        (
            PARTITION BY p.ProductID
            ORDER BY so.OrderDate
        ) AS PrevQuantity,
    LEAD(sod.Quantity)
        OVER
        (
            PARTITION BY p.ProductID
            ORDER BY so.OrderDate
        ) AS NextQuantity
FROM dbo.product p
INNER JOIN dbo.salesorderdetail sod
    ON p.ProductID = sod.ProductID
INNER JOIN dbo.salesorder so
    ON sod.OrderID = so.OrderID
ORDER BY p.ProductID, so.OrderDate;

-- Question 9

CREATE VIEW dbo.vw_CustomerOrderSummary
AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM dbo.customer c
LEFT JOIN dbo.salesorder so
    ON c.CustomerID = so.CustomerID
GROUP BY
    c.CustomerID,
    c.Name;
GO

SELECT *
FROM dbo.vw_CustomerOrderSummary;

-- Q10. 

CREATE PROCEDURE dbo.sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @SupplierID AS SupplierID,
        SUM(sod.TotalAmount) AS TotalSalesAmount
    FROM dbo.supplier s
    INNER JOIN dbo.purchaseorder po
        ON s.SupplierID = po.SupplierID
    INNER JOIN dbo.purchaseorderdetail pod
        ON po.OrderID = pod.OrderID
    INNER JOIN dbo.product p
        ON pod.ProductID = p.ProductID
    INNER JOIN dbo.salesorderdetail sod
        ON p.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID;
END;
GO

EXEC dbo.sp_GetSupplierSales @SupplierID = 1;