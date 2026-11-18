--*************************************************************************--
-- Title: Assignment 06
-- Author: Elise C.
-- Desc: This file demonstrates how to use Views
-- Change Log: When, Who, What
-- 2017-01-01, RRoot, Created File
-- 2026-11-16, EC, Completed File
--**************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS (SELECT	Name
				FROM		SysDatabases
				WHERE	Name = 'Assignment06DB_EC')
		BEGIN
			ALTER DATABASE [Assignment06DB_EC]
				SET SINGLE_USER 
				WITH ROLLBACK IMMEDIATE;
			DROP DATABASE Assignment06DB_EC;
		END
	CREATE DATABASE Assignment06DB_EC;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH


GO
USE Assignment06DB_EC;

-- Create Tables (Module 01)-- 
CREATE TABLE Categories (
	[CategoryID]	INT				IDENTITY (1, 1) NOT NULL,
	[CategoryName]	NVARCHAR (100)	NOT NULL
);


GO
CREATE TABLE Products (
	[ProductID]		INT				IDENTITY (1, 1) NOT NULL,
	[ProductName]	NVARCHAR (100)	NOT NULL,
	[CategoryID]	INT				NULL,
	[UnitPrice]		MONEY			NOT NULL
);


GO
CREATE TABLE Employees ( -- New Table
	[EmployeeID]		INT				IDENTITY (1, 1) NOT NULL,
	[EmployeeFirstName]	NVARCHAR (100)	NOT NULL,
	[EmployeeLastName]	NVARCHAR (100)	NOT NULL,
	[ManagerID]			INT				NULL
);


GO
CREATE TABLE Inventories (
	[InventoryID]	INT		IDENTITY (1, 1) NOT NULL,
	[InventoryDate]	DATE	NOT NULL,
	[EmployeeID]	INT		NOT NULL, -- New Column
	[ProductID]		INT		NOT NULL,
	[Count]			INT		NOT NULL
);


GO
-- Add Constraints (Module 02) -- 
BEGIN
	-- Categories
	ALTER TABLE Categories
		ADD CONSTRAINT pkCategories PRIMARY KEY (CategoryId);
	ALTER TABLE Categories
		ADD CONSTRAINT ukCategories UNIQUE (CategoryName);
END


GO
BEGIN
	-- Products
	ALTER TABLE Products
		ADD CONSTRAINT pkProducts PRIMARY KEY (ProductId);
	ALTER TABLE Products
		ADD CONSTRAINT ukProducts UNIQUE (ProductName);
	ALTER TABLE Products
		ADD CONSTRAINT fkProductsToCategories FOREIGN KEY (CategoryId) REFERENCES Categories (CategoryId);
	ALTER TABLE Products
		ADD CONSTRAINT ckProductUnitPriceZeroOrHigher CHECK (UnitPrice >= 0);
END


GO
BEGIN
	-- Employees
	ALTER TABLE Employees
		ADD CONSTRAINT pkEmployees PRIMARY KEY (EmployeeId);
	ALTER TABLE Employees
		ADD CONSTRAINT fkEmployeesToEmployeesManager FOREIGN KEY (ManagerId) REFERENCES Employees (EmployeeId);
END


GO
BEGIN
	-- Inventories
	ALTER TABLE Inventories
		ADD CONSTRAINT pkInventories PRIMARY KEY (InventoryId);
	ALTER TABLE Inventories
		ADD CONSTRAINT dfInventoryDate DEFAULT GetDate() FOR InventoryDate;
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToProducts FOREIGN KEY (ProductId) REFERENCES Products (ProductId);
	ALTER TABLE Inventories
		ADD CONSTRAINT ckInventoryCountZeroOrHigher CHECK ([Count] >= 0);
	ALTER TABLE Inventories
		ADD CONSTRAINT fkInventoriesToEmployees FOREIGN KEY (EmployeeId) REFERENCES Employees (EmployeeId);
END


GO
-- Adding Data (Module 04) -- 
INSERT	INTO Categories (
	CategoryName
)
SELECT		CategoryName
FROM		Northwind.dbo.Categories
ORDER BY	CategoryID;


GO
INSERT	INTO Products (
	ProductName,
	CategoryID,
	UnitPrice
)
SELECT		ProductName,
			CategoryID,
			UnitPrice
FROM		Northwind.dbo.Products
ORDER BY	ProductID;


GO
INSERT	INTO Employees (
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
)
SELECT		E.FirstName,
			E.LastName,
			IsNull(E.ReportsTo, E.EmployeeID)
FROM		Northwind.dbo.Employees AS E
ORDER BY	E.EmployeeID;


GO
INSERT	INTO Inventories (
	InventoryDate,
	EmployeeID,
	ProductID,
	[Count]
)
SELECT		'20170101' AS InventoryDate,
			5 AS EmployeeID,
			ProductID,
			UnitsInStock
FROM		Northwind.dbo.Products
UNION
SELECT		'20170201' AS InventoryDate,
			7 AS EmployeeID,
			ProductID,
			UnitsInStock + 10 -- Using this is to create a made up value
FROM		Northwind.dbo.Products
UNION
SELECT		'20170301' AS InventoryDate,
			9 AS EmployeeID,
			ProductID,
			UnitsInStock + 20 -- Using this is to create a made up value
FROM		Northwind.dbo.Products
ORDER BY	1, 2;


GO
-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT	*
FROM	Categories;


GO
SELECT	*
FROM	Products;


GO
SELECT	*
FROM	Employees;


GO
SELECT	*
FROM	Inventories;


GO
-- /********************************* Questions and Answers *********************************/
-- 'NOTES------------------------------------------------------------------------------------ 
--  1) You can use any name you like for you views, but be descriptive and consistent
--  2) You can use your working code from assignment 5 for much of this assignment
--  3) You must use the BASIC views for each table after they are created in Question 1
-- ------------------------------------------------------------------------------------------'
-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT	CategoryID,
		CategoryName
FROM	dbo.Categories;


GO
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT	ProductID,
		ProductName,
		CategoryID,
		UnitPrice
FROM	dbo.Products;


GO
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT	EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
FROM	dbo.Employees;


GO
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT	InventoryID,
		InventoryDate,
		EmployeeID,
		ProductID,
		Count
FROM	dbo.Inventories;


GO
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY Select
	ON Categories TO PUBLIC;

DENY Select
	ON Products TO PUBLIC;

DENY Select
	ON Employees TO PUBLIC;

DENY Select
	ON Inventories TO PUBLIC;


GO
GRANT Select
	ON vCategories TO PUBLIC;

GRANT Select
	ON vProducts TO PUBLIC;

GRANT Select
	ON vEmployees TO PUBLIC;

GRANT Select
	ON vInventories TO PUBLIC;


GO
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
-- -- Look at all the data
-- Select * from Categories;
-- Select * from Products;
-- --Look at just the data we want
-- Select * from Categories Join Products
-- On Categories.CategoryID = Products.CategoryID;
-- -- Combine the results
-- Select CategoryName, ProductName, UnitPrice From Categories Join Products
-- On Categories.CategoryID = Products.CategoryID;
-- --Order the results
-- Select CategoryName, ProductName, UnitPrice From Categories Join Products
-- On Categories.CategoryID = Products.CategoryID
-- Order by CategoryName, ProductName;
-- Go
-- Create View
CREATE OR ALTER VIEW vProductsByCategories
AS
SELECT		TOP 1000000 CategoryName,
						ProductName,
						UnitPrice
FROM		vCategories
			INNER JOIN
			vProducts
			ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY	CategoryName, ProductName, UnitPrice;


GO
SELECT	*
FROM	vProductsByCategories;


GO
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
-- -- Look at all the data
-- Select * From Products;
-- go
-- Select * From Inventories;
-- go
-- --Look at just the data we want
-- Select ProductName From Products;
-- go
-- Select Count, InventoryDate From Inventories;
-- go
-- -- Combine the results
-- Select ProductName, InventoryDate, Count
-- From Products
-- Join Inventories on Products.ProductID = Inventories.ProductID;
-- go
-- --Order the results
-- Select ProductName, InventoryDate, Count
-- From Products
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Order By ProductName, InventoryDate, Count;
-- go
-- Create View
CREATE OR ALTER VIEW vInventoriesByProductsByDates
AS
SELECT		TOP 1000000 ProductName,
						InventoryDate,
						Count
FROM		vProducts AS p
			INNER JOIN
			vInventories AS i
			ON p.ProductID = i.ProductID
ORDER BY	ProductName, InventoryDate, Count;


GO
SELECT	*
FROM	vInventoriesByProductsByDates;


GO
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
-- Here is are the rows selected from the view:
-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
-- -- Look at all the data
-- Select * From Inventories;
-- go
-- Select * From Employees;
-- go
-- --Look at just the data we want
-- Select InventoryDate From Inventories;
-- go
-- Select EmployeeFirstName, EmployeeLastName From Employees;
-- go
-- -- Combine the results
-- Select InventoryDate, 
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Employees
-- Join Inventories on Employees.EmployeeID = Inventories.EmployeeID;
-- go
-- --Order the results
-- Select InventoryDate,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Employees
-- Join Inventories on Employees.EmployeeID = Inventories.EmployeeID
-- Order By InventoryDate;
-- go
-- -- Create View, adding aliases and distinct to final code 
CREATE OR ALTER VIEW vInventoriesByEmployeesByDates
AS
SELECT		DISTINCT TOP 1000000 i.InventoryDate,
								e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		vEmployees AS e
			INNER JOIN
			vInventories AS i
			ON e.EmployeeID = i.EmployeeID
ORDER BY	InventoryDate;


GO
SELECT	*
FROM	vInventoriesByEmployeesByDates;


GO
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
-- -- Look at all the data
-- Select * From Categories;
-- go
-- Select * From Products;
-- go
-- Select * From Inventories;
-- go
-- --Look at just the data we want
-- Select CategoryName From Categories;
-- go
-- Select ProductName From Products;
-- go
-- Select InventoryDate, Count From Inventories;
-- go
-- -- Combine the results
-- Select CategoryName, ProductName, InventoryDate, Count
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID;
-- go
-- --Order the results
-- Select CategoryName, ProductName, InventoryDate, Count
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Order By CategoryName, ProductName, InventoryDate, Count;
-- go
-- -- Create View, adding aliases to final code 
CREATE OR ALTER VIEW vInventoriesByProductsByCategories
AS
SELECT		TOP 1000000 CategoryName,
						ProductName,
						InventoryDate,
						Count
FROM		vCategories AS c
			INNER JOIN
			vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			vInventories AS i
			ON p.ProductID = i.ProductID
ORDER BY	CategoryName, ProductName, InventoryDate, Count;


GO
SELECT	*
FROM	vInventoriesByProductsByCategories;


GO
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
-- -- Look at all the data
-- Select * From Categories;
-- go
-- Select * From Products;
-- go
-- Select * From Inventories;
-- go
-- Select * From Employees;
-- go
-- --Look at just the data we want
-- Select CategoryName From Categories;
-- go
-- Select ProductName From Products;
-- go
-- Select InventoryDate, Count From Inventories;
-- go
-- Select EmployeeFirstName, EmployeeLastName From Employees;
-- go
-- -- Combine the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID;
-- go
-- --Order the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID
-- Order By InventoryDate, CategoryName, ProductName, EmployeeName;
-- go
-- Create view, adding aliases to final code 
CREATE OR ALTER VIEW vInventoriesByProductsByEmployees
AS
SELECT		TOP 1000000 CategoryName,
						ProductName,
						InventoryDate,
						Count,
						e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		vCategories AS c
			INNER JOIN
			vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
ORDER BY	InventoryDate, CategoryName, ProductName, EmployeeName;


GO
SELECT	*
FROM	vInventoriesByProductsByEmployees;


GO
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- -- Look at all the data
-- Select * From Categories;
-- go
-- Select * From Products;
-- go
-- Select * From Inventories;
-- go
-- Select * From Employees;
-- go
-- --Look at just the data we want
-- Select CategoryName From Categories;
-- go
-- Select ProductName From Products;
-- go
-- Select InventoryDate, Count From Inventories;
-- go
-- Select EmployeeFirstName, EmployeeLastName From Employees;
-- go
-- -- Combine the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID;
-- go
-- --Order the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID
-- Order By InventoryDate, CategoryName, ProductName;
-- go
-- Create view, adding aliases and subquery to final code 
CREATE OR ALTER VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT		TOP 1000000 CategoryName,
						ProductName,
						InventoryDate,
						Count,
						e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [EmployeeName]
FROM		vCategories AS c
			INNER JOIN
			vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
WHERE		p.ProductID = 1
			OR p.ProductID = 2
ORDER BY	InventoryDate, CategoryName, ProductName;


GO
SELECT	*
FROM	vInventoriesForChaiAndChangByEmployees;


GO
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
-- -- Look at all the data
-- Select * From Employees;
-- go
-- --Look at just the data we want
-- Select ManagerID, * From Employees;
-- go
-- -- Combine the results with aliases
-- Select [Manager] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
-- [Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
-- From Employees as Emp
-- Inner Join Employees as Mgr on Emp.ManagerID = Mgr.EmployeeID;
-- go
-- --Create view, order the results for the final code
CREATE OR ALTER VIEW vEmployeesByManager
AS
SELECT		TOP 1000000 Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName AS [Manager],
						Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS [Employee]
FROM		vEmployees AS Emp
			INNER JOIN
			vEmployees AS Mgr
			ON Emp.ManagerID = Mgr.EmployeeID
ORDER BY	Manager, Employee;


GO
SELECT	*
FROM	vEmployeesByManager;


GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
-- -- Look at all the data
-- Select * From Categories;
-- go
-- Select * From Products;
-- go
-- Select * From Inventories;
-- go
-- Select * From Employees;
-- go
-- --Look at just the data we want
-- Select CategoryName From Categories;
-- go
-- Select ProductName From Products;
-- go
-- Select InventoryDate, Count From Inventories;
-- go
-- Select EmployeeFirstName, EmployeeLastName From Employees;
-- go
-- -- Combine the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID;
-- go
-- --Order the results
-- Select CategoryName, ProductName, InventoryDate, Count,
-- [EmployeeName] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
-- From Categories
-- Join Products on Categories.CategoryID = Products.CategoryID
-- Join Inventories on Products.ProductID = Inventories.ProductID
-- Join Employees on Inventories.EmployeeID = Employees.EmployeeID
-- Order By CategoryID, ProductID, InventoryID, EmployeeID;
-- go
-- Create view, self join
CREATE OR ALTER VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT		TOP 1000000 c.CategoryID,
						c.CategoryName,
						p.ProductID,
						p.ProductName,
						p.UnitPrice,
						i.InventoryID,
						i.InventoryDate,
						i.Count,
						e.EmployeeID,
						e.EmployeeFirstName + ' ' + e.EmployeeLastName AS [Employee],
						Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName AS [Manager]
FROM		vCategories AS c
			INNER JOIN
			vProducts AS p
			ON c.CategoryID = p.CategoryID
			INNER JOIN
			vInventories AS i
			ON p.ProductID = i.ProductID
			INNER JOIN
			vEmployees AS e
			ON i.EmployeeID = e.EmployeeID
			INNER JOIN
			vEmployees AS Mgr
			ON e.ManagerID = Mgr.EmployeeID
ORDER BY	CategoryID, ProductID, InventoryID, EmployeeID;


GO
SELECT	*
FROM	vInventoriesByProductsByCategoriesByEmployees;


GO
/***************************************************************************************/
-- Test your Views (NOTE: You must change the your view names to match what I have below!)
PRINT 'Note: You will get an error until the views are created!';

SELECT	*
FROM	[dbo].[vCategories];

SELECT	*
FROM	[dbo].[vProducts];

SELECT	*
FROM	[dbo].[vInventories];

SELECT	*
FROM	[dbo].[vEmployees];

SELECT	*
FROM	[dbo].[vProductsByCategories];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByDates];

SELECT	*
FROM	[dbo].[vInventoriesByEmployeesByDates];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByCategories];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByEmployees];

SELECT	*
FROM	[dbo].[vInventoriesForChaiAndChangByEmployees];

SELECT	*
FROM	[dbo].[vEmployeesByManager];

SELECT	*
FROM	[dbo].[vInventoriesByProductsByCategoriesByEmployees];


/***************************************************************************************/