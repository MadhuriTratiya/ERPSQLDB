USE ERPDB;
GO

--Insert Product Categories
INSERT INTO Inventory.ProductCategory (CategoryName)
VALUES 
('Electronics'),
('Furniture'),
('Stationary'),
('Clothing'),
('Hardware');

--Insert 10,000 Customers (Dynamic Non-Duplicate)
SET NOCOUNT ON;

DECLARE @i INT = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Master.Customer
    (
        CustomerCode,
        CustomerName,
        Email,
        Phone,
        CreditLimit
    )
    VALUES
    (
        CONCAT('CUST', FORMAT(@i,'00000')),
        CONCAT('Customer ', @i),
        CONCAT('cust',@i,'@erp.com'),
        CONCAT('90000',FORMAT(@i,'00000')),
        RAND()*100000
    );

    SET @i = @i + 1;
END

--Insert 5,000 Products
DECLARE @i INT = 1;

WHILE @i <= 5000
BEGIN
    INSERT INTO Inventory.Product
    (
        ProductCode,
        ProductName,
        CategoryID,
        UnitPrice,
        ReorderLevel
    )
    VALUES
    (
        CONCAT('PROD',FORMAT(@i,'00000')),
        CONCAT('Product ',@i),
        (ABS(CHECKSUM(NEWID())) % 5) + 1,
        (ABS(CHECKSUM(NEWID())) % 10000) + 100,
        10
    );

    SET @i += 1;
END

--Initialize Stock
INSERT INTO Inventory.Stock (ProductID, QuantityOnHand)
SELECT ProductID, 1000
FROM Inventory.Product;

--Insert 50,000 Sales Orders
DECLARE @i INT = 1;

WHILE @i <= 50000
BEGIN
    INSERT INTO Sales.SalesOrderHeader
    (
        OrderNumber,
        CustomerID,
        Status
    )
    VALUES
    (
        CONCAT('SO',FORMAT(@i,'000000')),
        (ABS(CHECKSUM(NEWID())) % 10000) + 1,
        'Approved'
    );

    SET @i += 1;
END

--Insert 200,000 Sales Order Details
DECLARE @i INT = 1;

WHILE @i <= 200000
BEGIN
    INSERT INTO Sales.SalesOrderDetail
    (
        SalesOrderID,
        ProductID,
        Quantity,
        UnitPrice
    )
    VALUES
    (
        (ABS(CHECKSUM(NEWID())) % 50000) + 1,
        (ABS(CHECKSUM(NEWID())) % 5000) + 1,
        (ABS(CHECKSUM(NEWID())) % 10) + 1,
        (ABS(CHECKSUM(NEWID())) % 5000) + 100
    );

    SET @i += 1;
END


