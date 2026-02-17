-- ERP DATABASE

USE master;
GO
IF DB_ID('ERPDB') IS NOT NULL
BEGIN
    ALTER DATABASE ERPDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ERPDB;
END
GO

CREATE DATABASE ERPDB
ON PRIMARY
(
    NAME = ERPDB_Data,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\
\ERPDB_Data.mdf',
    SIZE = 200MB,
    MAXSIZE = 5GB,
    FILEGROWTH = 50MB
),
FILEGROUP FG_Transactions
(
    NAME = ERPDB_Trans,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\
\ERPDB_Trans.ndf',
    SIZE = 200MB,
    MAXSIZE = 10GB,
    FILEGROWTH = 100MB
)
LOG ON
(
    NAME = ERPDB_Log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\
\ERPDB_Log.ldf',
    SIZE = 100MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 50MB
);
GO

--Create Schemas
USE ERPDB;
GO

CREATE SCHEMA Master;
GO

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Purchase;
GO

CREATE SCHEMA Inventory;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Finance;
GO

--Company Table 
CREATE TABLE Master.Company
(
    CompanyID INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName NVARCHAR(200) NOT NULL,
    GSTNumber NVARCHAR(20) UNIQUE,
    PANNumber NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Customer table 
CREATE TABLE Master.Customer
(
    CustomerID INT IDENTITY(1,1),
    CustomerCode NVARCHAR(20) NOT NULL,
    CustomerName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(150),
    Phone NVARCHAR(20),
    CreditLimit DECIMAL(18,2) CHECK (CreditLimit >= 0),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT PK_Customer PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customer_Code UNIQUE (CustomerCode)
);

--Supplier Table 
CREATE TABLE Master.Supplier
(
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode NVARCHAR(20) NOT NULL UNIQUE,
    SupplierName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(150),
    Phone NVARCHAR(20),
    GSTNumber NVARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE()
);

--INVENTORY MODULE
--Product Category
CREATE TABLE Inventory.ProductCategory
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(150) NOT NULL UNIQUE,
    CreatedDate DATETIME DEFAULT GETDATE()
);

--Product Table
CREATE TABLE Inventory.Product
(
    ProductID INT IDENTITY(1,1),
    ProductCode NVARCHAR(50) NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice > 0),
    ReorderLevel INT DEFAULT 10,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT PK_Product PRIMARY KEY(ProductID),
    CONSTRAINT UQ_Product_Code UNIQUE(ProductCode),
    CONSTRAINT FK_Product_Category 
        FOREIGN KEY(CategoryID)
        REFERENCES Inventory.ProductCategory(CategoryID)
);

--Stock Table
CREATE TABLE Inventory.Stock
(
    ProductID INT PRIMARY KEY,
    QuantityOnHand INT NOT NULL DEFAULT 0 CHECK (QuantityOnHand >= 0),
    LastUpdated DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Stock_Product
        FOREIGN KEY(ProductID)
        REFERENCES Inventory.Product(ProductID)
);


--SALES MODULE
--Sales Order Header
CREATE TABLE Sales.SalesOrderHeader
(
    SalesOrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) DEFAULT 0,
    Status NVARCHAR(20) DEFAULT 'Pending'
        CHECK (Status IN ('Pending','Approved','Shipped','Cancelled')),

    CONSTRAINT FK_Sales_Customer
        FOREIGN KEY(CustomerID)
        REFERENCES Master.Customer(CustomerID)
) ON FG_Transactions;

--Sales Order Details
CREATE TABLE Sales.SalesOrderDetail
(
    SalesOrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice > 0),
    LineTotal AS (Quantity * UnitPrice) PERSISTED,

    CONSTRAINT FK_SOD_Header
        FOREIGN KEY(SalesOrderID)
        REFERENCES Sales.SalesOrderHeader(SalesOrderID),

    CONSTRAINT FK_SOD_Product
        FOREIGN KEY(ProductID)
        REFERENCES Inventory.Product(ProductID)
) ON FG_Transactions;

--PURCHASE MODULE
CREATE TABLE Purchase.PurchaseOrderHeader
(
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Open',

    CONSTRAINT FK_PO_Supplier
        FOREIGN KEY(SupplierID)
        REFERENCES Master.Supplier(SupplierID)
);

--HR MODULE
CREATE TABLE HR.Employee
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode NVARCHAR(20) UNIQUE NOT NULL,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(150) UNIQUE,
    HireDate DATE,
    Salary DECIMAL(18,2) CHECK (Salary > 0),
    IsActive BIT DEFAULT 1
);

--FINANCE MODULE
CREATE TABLE Finance.Account
(
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    AccountName NVARCHAR(200) NOT NULL,
    AccountType NVARCHAR(50)
        CHECK (AccountType IN ('Asset','Liability','Expense','Revenue')),
    CreatedDate DATETIME DEFAULT GETDATE()
);
--INDEXES (Performance Tuning Level)
CREATE NONCLUSTERED INDEX IX_Product_Category
ON Inventory.Product(CategoryID);

CREATE NONCLUSTERED INDEX IX_SalesOrder_Customer
ON Sales.SalesOrderHeader(CustomerID);

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_Product
ON Sales.SalesOrderDetail(ProductID);


--Trigger Example (Auto Update Stock on Sales)
CREATE TRIGGER TRG_UpdateStock_OnSale
ON Sales.SalesOrderDetail
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.QuantityOnHand = s.QuantityOnHand - i.Quantity
    FROM Inventory.Stock s
    INNER JOIN inserted i
        ON s.ProductID = i.ProductID;
END;

--Stored Procedure (Create Sales Order)
CREATE PROCEDURE Sales.sp_CreateSalesOrder
    @CustomerID INT,
    @OrderNumber NVARCHAR(50)
AS
BEGIN
    INSERT INTO Sales.SalesOrderHeader (CustomerID, OrderNumber)
    VALUES (@CustomerID, @OrderNumber);
END;






