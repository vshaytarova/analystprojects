/*==============================================================*/
/* Data Import (Query Data & Error Log)                         */
/* Name: Veronika Shaytarova                                    */
/*==============================================================*/

--Create WonderfulWheels database, if exist, drop existing databse before creating a new one.

USE master;
GO
IF DB_ID (N'WonderfulWheels') IS NOT NULL  
	DROP DATABASE WonderfulWheels;  
GO  
CREATE DATABASE WonderfulWheels 
GO

--UseWonderfulWheels Database from now on.

USE WonderfulWheels;
GO

--Start creating the tables
/*==============================================================*/
/* Table: Location                                              */
/*==============================================================*/
CREATE TABLE [Location]
(
   LocationID	int identity(1,1)	NOT NULL,
   StreetAddress	nvarchar(100)	NOT NULL,
   City			nvarchar(50)	NOT NULL,
   Province		char(2)			NOT NULL,
   PostalCode	char(7)			NOT NULL,
   CONSTRAINT PK_LOCATION PRIMARY KEY (LocationID)
)

GO

/*==============================================================*/
/* Table: Dealership                                            */
/*==============================================================*/
CREATE TABLE Dealership (
   DealershipID	int IDENTITY(1,1)	NOT NULL,
   LocationID	int					NOT NULL,
   DealerName	nvarchar(50)		NOT NULL,
   Phone		nvarchar(20)		      NULL,
   CONSTRAINT PK_DEALERSHIP PRIMARY KEY (DealershipID),
   CONSTRAINT FK_DEAL_LOC FOREIGN KEY (LocationID) REFERENCES Location (LocationID)
)
GO

/*==============================================================*/
/* Table: Person                                                */
/*==============================================================*/
CREATE TABLE Person (
   PersonID		int IDENTITY(1000,1)	NOT NULL,
   FirstName	nvarchar(50)	NOT NULL,
   LastName		nvarchar(50)	NOT NULL,
   Phone		nvarchar(20)	NULL,
   Email		nvarchar(100)	NULL,
   PerLocID	int				NOT NULL,
   DateofBirth	date			NULL,
   Title		char(2)			NULL,
   CONSTRAINT PK_PERSON PRIMARY KEY (PersonID),
   CONSTRAINT FK_PER_LOC FOREIGN KEY (PerLocID) REFERENCES Location (LocationID),
   CONSTRAINT CHK_TITLE	CHECK (Title='Mr' OR Title ='Ms')	
)
GO
/*==============================================================*/
/* Index: IndexPersonName                                       */
/*==============================================================*/
CREATE NONCLUSTERED INDEX IndexPersonName ON Person ( FirstName ASC, LastName ASC)
GO

/*==============================================================*/
/* Table: Customer                                              */
/*==============================================================*/
CREATE TABLE Customer (
   CustomerID		int				NOT NULL,
   RegDate			date			NOT NULL,
   CONSTRAINT PK_CUSTOMER PRIMARY KEY (CustomerID),
   CONSTRAINT FK_CUS_PER FOREIGN KEY (CustomerID) REFERENCES Person (PersonID)
)
GO

/*==============================================================*/
/* Table: Employee                                              */
/*==============================================================*/
CREATE TABLE Employee (
   EmployeeID		int				NOT NULL,
   EmpDealID		int				NOT NULL,
   HireDate			date			NOT NULL,
   EmpRole			nvarchar(50)	NOT NULL,
   ManagerID		int				NULL, 
   CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_EMP_PER FOREIGN KEY (EmployeeID) REFERENCES Person (PersonID),
   CONSTRAINT FK_EMP_DEAL FOREIGN KEY (EmpDealID) REFERENCES Dealership (DealershipID),
   CONSTRAINT FK_PER_MAN FOREIGN KEY (ManagerID) REFERENCES Employee (EmployeeID)
)
GO

/*==============================================================*/
/* Table: SalaryEmployee                                        */
/* Set Salary to Default 1000 since Check contraint should      */
/* not be less than 1000										*/
/*==============================================================*/
CREATE TABLE SalaryEmployee (
   EmployeeID		int				NOT NULL,
   Salary			decimal(12,2)	NOT NULL DEFAULT 1000.00,
   CONSTRAINT PK_SALEMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_SEMP_EMP FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID),
   CONSTRAINT CHK_SALARY	CHECK (Salary>=1000)
)
GO

/*==============================================================*/
/* Table: CommissionEmployee                                    */
/* Set Commission to Default 10 since Check contraint should    */
/* not be less than 10  										*/
/*==============================================================*/
CREATE TABLE CommissionEmployee (
   EmployeeID		int				NOT NULL,
   Commission		decimal(12,2)	NOT NULL DEFAULT 10.00,
   CONSTRAINT PK_COMEMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_CEMP_EMP FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID),
   CONSTRAINT CHK_COMMISSION	CHECK (Commission>=10)
)
GO

/*==============================================================*/
/* Table: Vehicle                                               */
/* Set Price to Default 1 since Check contraint should          */
/* not be less than 1											*/
/* Set VehicleYear Check contraint to be greater than 1800      */
/* and less than current year to capture appropriate Year   	*/
/*==============================================================*/

CREATE TABLE Vehicle (
   VehicleID	int	IDENTITY(1,1) NOT NULL,
   Make			nvarchar(50)	NOT NULL,
   Model		nvarchar(50)	NOT NULL,
   VehicleYear	int				NOT NULL,
   Colour		nvarchar(10)	NOT NULL,
   KM			int				NOT NULL,
   Price		decimal(12,2)	NULL DEFAULT 1.00,
   CONSTRAINT PK_VEHICLE PRIMARY KEY (VehicleID),
   CONSTRAINT CHK_PRICE	CHECK (Price>=1),
   CONSTRAINT CHK_YEAR	CHECK (VehicleYear>=1800 AND VehicleYear <= YEAR(GETDATE()))

)
GO

/*==============================================================*/
/* Table: VehicleOrder                                          */
/*==============================================================*/
CREATE TABLE [Order] (
   OrderID		int IDENTITY(1,1)	NOT NULL,
   OrderCustID	int				NOT NULL,
   OrderEmpID	int				NOT NULL,
   OrderDate	date			NOT NULL DEFAULT GetDate(),
   OrderDealID	int				NOT NULL,
   CONSTRAINT PK_ORDER PRIMARY KEY (OrderID),
   CONSTRAINT FK_ORD_CUST FOREIGN KEY (OrderCustID) REFERENCES Customer (CustomerID),
   CONSTRAINT FK_ORD_EMP FOREIGN KEY (OrderEmpID) REFERENCES Employee (EmployeeID),
   CONSTRAINT FK_ORD_DEAL FOREIGN KEY (OrderDealID) REFERENCES Dealership (DealershipID)
)
GO


/*==============================================================*/
/* Table:  OrderItem                                            */
/* Set FinalSalePrice to Default 1 since Check contraint should */
/* not be less than 1											*/
/*==============================================================*/
CREATE TABLE OrderItem (
   OrderID			int		NOT NULL,
   VehicleID		int		NOT NULL,
   FinalSalePrice	decimal(12,2)	NULL DEFAULT 1.00,
   CONSTRAINT PK_ORDERITEM PRIMARY KEY (OrderID, VehicleID),
   CONSTRAINT FK_ORDITM_ORD FOREIGN KEY (OrderID) REFERENCES [Order] (OrderID),
   CONSTRAINT FK_ORDITM_VEHICLE FOREIGN KEY (VehicleID) REFERENCES Vehicle (VehicleID),
   CONSTRAINT CHK_FINALSALEPRICE	CHECK (FinalSalePrice>=1)

)
GO

/*==============================================================*/
/* Table: Account                                               */
/*==============================================================*/
CREATE TABLE Account (
   AccountID			int	IDENTITY(1,1)	NOT NULL,
   CustomerID			int		NOT NULL,
   AccountBalance		decimal(12,2)	NOT NULL DEFAULT 0.00,
   LastPaymentAmount	decimal(12,2)	NOT NULL DEFAULT 0.00,
   LastPaymentDate		date	NULL,
   CONSTRAINT PK_ACCOUNT PRIMARY KEY (AccountID),
   CONSTRAINT FK_ACC_CUST FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
   CONSTRAINT CHK_BALANCE	CHECK (AccountBalance>=0),
   CONSTRAINT CHK_AMOUNT	CHECK (LastPaymentAmount>=0)

)
GO

/*==============================================================*/
/* Create Log Errors table                                      */
/*==============================================================*/

CREATE TABLE dbo.DbErrorLog
	(
		ErrorID        INT IDENTITY(1, 1),
		UserName       VARCHAR(100),
		ErrorNumber    INT,
		ErrorState     INT,
		ErrorSeverity  INT,
		ErrorLine      INT,
		ErrorProcedure VARCHAR(MAX),
		ErrorMessage   VARCHAR(MAX),
		ErrorDateTime  DATETIME DEFAULT GETDATE()
	)
GO

/*==============================================================*/
/* Insert Data to the Tables.                                   */
/*==============================================================*/


USE WonderfulWheels
GO

	BEGIN TRY

		BEGIN TRANSACTION

---Insert addresses under Location-----------------------------------------------------------

		INSERT INTO dbo.Location (StreetAddress,City,Province,PostalCode)
		VALUES ('22 Queen St', 'Waterloo', 'ON', 'N2A48B'),
				('44 King St', 'Guelph', 'ON', 'G2A47U'),
				('55 Krug St', 'Kitchener', 'ON', 'N2A4U7'),
				('77 Lynn Ct', 'Toronto', 'ON', 'M7U4BA'),
				('221 Kitng St W', 'Kitchener', 'ON', 'G8B3C6'),
				('77 Victoria St N', 'Campbridge', 'ON', 'N1Z8B8'),
				('100 White Oak Rd', 'London', 'ON', 'L9B1W2'),
				('88 King St', 'Guelph', 'ON', 'G2A47U'),
				('99 Lynn Ct', 'Toronto', 'ON', 'M7U4BA'),
				('44 Cedar St', 'Kitchener', 'ON', 'N2A7L6');
		select * from Location

---Insert Dealerships' information-----------------------------------------------------------

		INSERT INTO dbo.Dealership(LocationID,DealerName,Phone)
		VALUES ((SELECT LocationID FROM Location WHERE StreetAddress = '221 Kitng St W'), 'Kitchener', '519-111-1111'),
				((SELECT LocationID FROM Location WHERE StreetAddress = '77 Victoria St N'), 'Cambridge', '519-222-2222'),
				((SELECT LocationID FROM Location WHERE StreetAddress = '100 White Oak Rd'), 'London', '519-333-3333');

		select * from Dealership

---Insert information for table Person-----------------------------------------------------------

		INSERT INTO dbo.Person(FirstName,LastName,Phone,Email,PerLocID,DateofBirth,Title)
		VALUES ('John', 'Smith', '519-444-3333', 'jsmtith@email.com', (SELECT LocationID from Location WHERE StreetAddress = '22 Queen St'), '1968-04-09', 'Mr'),
				('Mary', 'Brown', '519-888-3333', 'mbrown@email.com', (SELECT LocationID from Location WHERE StreetAddress = '44 King St'), '1972-02-04', 'Ms'),
				('Tracy', 'Spencer', '519-888-2222', 'tspencer@email.com', (SELECT LocationID from Location WHERE StreetAddress = '55 Krug St'), '1998-07-22', 'Ms'),
				('James', 'Stewart', '416-888-1111', 'jstewart@email.com', (SELECT LocationID from Location WHERE StreetAddress = '77 Victoria St N'), '1996-11-22', 'Mr'),
				('Paul', 'Newman', '519-888-4444', 'pnewman@email.com', (SELECT LocationID from Location WHERE StreetAddress = '55 Krug St'), '1992-09-23', 'Mr'),
				('Tom', 'Cruise', '519-333-2222', 'tcruise@email.com', (SELECT LocationID from Location WHERE StreetAddress = '55 Krug St'), '1962-03-22',	'Mr'),
				('Bette', 'Davis', '519-452-1111', 'bdavis@email.com', (SELECT LocationID from Location WHERE StreetAddress = '88 King St'), '1952-09-01', 'Ms'),
				('Grace', 'Kelly', '416-887-2222', 'gkelly@email.com', (SELECT LocationID from Location WHERE StreetAddress = '99 Lynn Ct'), '1973-06-09', 'Ms'),
				('Doris', 'Day', '519-888-5456', 'dday@email.com', (SELECT LocationID from Location WHERE StreetAddress = '44 Cedar St'), '1980-05-25', 'Ms');
		select * from Person

---Insert Vehicle information-----------------------------------------------------------

		SET IDENTITY_INSERT dbo.Vehicle ON

		INSERT INTO dbo.Vehicle(VehicleID,Make,Model,VehicleYear,Colour,KM,Price)
		VALUES (100001, 'Toyota', 'Corola',	2018, 'Silver', 45000, 18000),
				(100002,'Toyota', 'Corola',	2016, 'White', 60000, 15000),
				(100003,'Toyota', 'Corola',	2016, 'Black', 65000, 14000),
				(100004, 'Toyota', 'Camry', 2018, 'White', 35000, 22000),
				(100005, 'Honda', 'Acord', 2020, 'Gray',10000,24000),
				(100006, 'Honda', 'Acord', 2015, 'Red', 85000, 16000),
				(100007, 'Honda', 'Acord', 2000, 'Gray', 10000, 40000),
				(100008, 'Ford', 'Focus', 2017,	'Blue', 40000, 16000);

		SET IDENTITY_INSERT dbo.Vehicle OFF

		select * from Vehicle

---Insert Employees' data---------------------------------------------------------

		INSERT INTO dbo.Employee(EmployeeID,EmpDealID,HireDate,EmpRole)
		VALUES 	((SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09'),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'), '2020-04-09', 'Manager');

		INSERT INTO dbo.Employee(EmployeeID,EmpDealID,HireDate,EmpRole,ManagerID)
		VALUES 	((SELECT PersonID FROM Person WHERE FirstName = 'Mary' AND LastName = 'Brown' AND DateofBirth = '1972-02-04'),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'), '2020-04-01', 'Office Admin',
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09'))),
				
				((SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22'),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'), '2020-07-22', 'Sales',
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09'))),

				((SELECT PersonID FROM Person WHERE FirstName = 'James' AND LastName = 'Stewart' AND DateofBirth = '1996-11-22'),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'), '2020-07-01', 'Sales', 
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09'))),

				((SELECT PersonID FROM Person WHERE FirstName = 'Paul' AND LastName = 'Newman' AND DateofBirth = '1992-09-23'),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'), '2020-01-22', 'Sales',
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09')));

				select * from Employee

		INSERT INTO dbo.SalaryEmployee(EmployeeID,Salary)
		VALUES 	((SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'John' AND LastName = 'Smith' AND DateofBirth = '1968-04-09')), 95000),
				((SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Mary' AND LastName = 'Brown' AND DateofBirth = '1972-02-04')), 65000);
		select * from SalaryEmployee

		INSERT INTO dbo.CommissionEmployee(EmployeeID,Commission)
		VALUES 	((SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22')), 13),
				((SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'James' AND LastName = 'Stewart' AND DateofBirth = '1996-11-22')), 15),
				((SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Paul' AND LastName = 'Newman' AND DateofBirth = '1992-09-23')), 10);

		select * from CommissionEmployee

---Insert Customer details------------------------------------------

		INSERT INTO dbo.Customer(CustomerID,RegDate)
		VALUES 	((SELECT PersonID FROM Person WHERE FirstName = 'Tom' AND LastName = 'Cruise' AND DateofBirth = '1962-03-22'), '2021-03-01'),
				((SELECT PersonID FROM Person WHERE FirstName = 'Bette' AND LastName = 'Davis' AND DateofBirth = '1952-09-01'), '2021-03-02'),
				((SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22'), '2021-03-03'),
				((SELECT PersonID FROM Person WHERE FirstName = 'Grace' AND LastName = 'Kelly' AND DateofBirth = '1973-06-09'), '2021-03-04'),
				((SELECT PersonID FROM Person WHERE FirstName = 'Doris' AND LastName = 'Day' AND DateofBirth = '1980-05-25'), '2021-03-05');
	
		select * from Customer

---Insert Order details------------------------------------------

		SET IDENTITY_INSERT dbo.[Order] ON

		INSERT INTO dbo.[Order](OrderID,OrderCustID,OrderEmpID,OrderDealID)
		VALUES 	(100, (SELECT CustomerID FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Tom' AND LastName = 'Cruise' AND DateofBirth = '1962-03-22')),
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22')),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener')),

				(101, (SELECT CustomerID FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Bette' AND LastName = 'Davis' AND DateofBirth = '1952-09-01')),
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22')),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener')),

				(102, (SELECT CustomerID FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22')),
				(SELECT EmployeeID FROM Employee WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'James' AND LastName = 'Stewart' AND DateofBirth = '1996-11-22')),
				(SELECT DealershipID FROM Dealership WHERE DealerName = 'Kitchener'));

		SET IDENTITY_INSERT dbo.[Order] OFF

		select * from [Order]

---Insert Order details------------------------------------------

		INSERT INTO dbo.OrderItem(OrderID,VehicleID,FinalSalePrice)
		VALUES 	((SELECT OrderID FROM [Order] WHERE OrderCustID = (SELECT CustomerID  FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Tom' AND LastName = 'Cruise' AND DateofBirth = '1962-03-22'))), 
				(SELECT VehicleID FROM Vehicle WHERE Make='Toyota' AND Model='Corola' AND VehicleYear=2018 AND Colour ='Silver' AND KM=45000), 17500),
				
				((SELECT OrderID FROM [Order] WHERE OrderCustID = (SELECT CustomerID  FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Tom' AND LastName = 'Cruise' AND DateofBirth = '1962-03-22'))),
				(SELECT VehicleID FROM Vehicle WHERE Make='Toyota' AND Model='Camry' AND VehicleYear=2018 AND Colour ='White' AND KM=35000), 21000),
				
				((SELECT OrderID FROM [Order] WHERE OrderCustID = (SELECT CustomerID  FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Bette' AND LastName = 'Davis' AND DateofBirth = '1952-09-01'))),
				(SELECT VehicleID FROM Vehicle WHERE Make='Ford' AND Model='Focus' AND VehicleYear=2017 AND Colour ='Blue' AND KM=40000), 15000),

				((SELECT OrderID FROM [Order] WHERE OrderCustID = (SELECT CustomerID  FROM Customer WHERE CustomerID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer' AND DateofBirth = '1998-07-22'))),
				(SELECT VehicleID FROM Vehicle WHERE Make='Honda' AND Model='Acord' AND VehicleYear=2015 AND Colour ='Red' AND KM=85000), 15000);

		select * from OrderItem

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

---Start error check and rollback the transaction if an error accures

		ROLLBACK TRANSACTION		

		INSERT INTO dbo.DbErrorLog (UserName, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage)
		VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE());		
		
	END CATCH
GO

	SELECT * FROM dbo.DbErrorLog

/*==============================================================*/
/* Data Warehouse   Script                                      */
/* Name: Veronika Shaytarova                                    */
/*==============================================================*/

---1) Creating warehouse database named "WonderfulWheelsDW"

USE master;  
GO  
IF DB_ID (N'WonderfulWheelsDW') IS NOT NULL  
	DROP DATABASE WonderfulWheelsDW;  
GO  
CREATE DATABASE WonderfulWheelsDW  
GO

---2) Creating the first dimension - commission employee

USE [WonderfulWheelsDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Dim_CommissionEmployee](
	[EmployeeSK] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeAK] [int] NOT NULL,
	[Title] [char](2) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[DateofBirth] [date] NULL,
	[EmpRole] [nvarchar](50) NOT NULL,
	[Commission] [decimal](12,2) NOT NULL,
 CONSTRAINT [PK_Dim_CommissionEmployee] PRIMARY KEY CLUSTERED 
(
	[EmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

---3)	Creating the second dimension - customer

USE [WonderfulWheelsDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Dim_Customer](
	[CustomerSK] [int] IDENTITY(1,1) NOT NULL,
	[CustomerAK] [int] NOT NULL,
	[Title] [char](2) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [nvarchar](20) NULL,
	[DateofBirth] [date] NULL,
	[RegDate] [date] NOT NULL,
 CONSTRAINT [PK_Dim_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

---4)	Creating the third dimension - vehicle

USE [WonderfulWheelsDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Dim_Vehicle](
	[VehicleSK] [int] IDENTITY(1,1) NOT NULL,
	[VehicleAK] [int] NOT NULL,
	[Make] [nvarchar](50) NOT NULL,
	[Model] [nvarchar](50) NOT NULL,
	[VehicleYear] [int] NOT NULL,
	[Colour] [nvarchar](10) NOT NULL,
	[KM] [int] NOT NULL,
	[Price] [decimal](12,2) NULL,
 CONSTRAINT [PK_Dim_Vehicle] PRIMARY KEY CLUSTERED 
(
	[VehicleSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


---5)	Creating the forth dimension - dealership

USE [WonderfulWheelsDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Dim_Dealership](
	[DealershipSK] [int] IDENTITY(1,1) NOT NULL,
	[DealershipAK] [int] NOT NULL,
	[DealerName] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](20) NULL,
	[StreetAddress] [nvarchar](100) NOT NULL,
	[City] [nvarchar](50) NOT NULL,
	[Province] [char](2) NOT NULL,
	[PostalCode] [char](7) NOT NULL,
 CONSTRAINT [PK_Dim_Dealership] PRIMARY KEY CLUSTERED 
(
	[DealershipSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

---6) Creating a Date Dimension

USE [WonderfulWheelsDW]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Dim_Date](
   [DateSK] [int] IDENTITY(1,1) NOT NULL,
   [Date] DATE NOT NULL,
   [Day] TINYINT NOT NULL,
   [Month] TINYINT NOT NULL,
   [Year] INT NOT NULL,
 CONSTRAINT [PK_Dim_DateSK] PRIMARY KEY CLUSTERED 
(
	[DateSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

---7) Populate Date dimension

SET NOCOUNT ON

TRUNCATE TABLE [WonderfulWheelsDW].[dbo].[Dim_Date]

DECLARE @CurrentDate DATETIME = '2020-01-01'
DECLARE @EndDate DATETIME = '2025-04-08'
WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [WonderfulWheelsDW].[dbo].[Dim_Date] (
      [Date],
	  [Month],
      [Day],
      [Year]
      )
   SELECT
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [Year] = YEAR(@CurrentDate)
   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_Date]


---8) Creating the database for data loading

USE master;  
GO  
IF DB_ID (N'WonderfulWheelsDW') IS NOT NULL  
	DROP DATABASE WonderfulWheelsDWb;  
GO  
CREATE DATABASE WonderfulWheelsDWb  
GO

USE WonderfulWheels
GO	

---9) Loading Commission Employee

	SELECT 		
		IDENTITY(INT,1,1) AS EmployeeSK,
		e.EmployeeID AS EmployeeAK,
		p.Title,
		p.FirstName,
		p.LastName,
		p.Email,
		p.Phone,
		p.DateofBirth,
		e.EmpRole,
		ce.Commission
	INTO [WonderfulWheelsDWb].[dbo].[Dim_CommissionEmployee]
	FROM Employee e
		JOIN Person p on e.EmployeeID = p.PersonID
		JOIN CommissionEmployee ce on e.EmployeeID = ce.EmployeeID

	-- Test 
	SELECT * FROM [WonderfulWheelsDWb].[dbo].[Dim_CommissionEmployee]

GO

---10) Loading Customer

	SELECT 
		IDENTITY(INT,1,1) AS CustomerSK,
		c.CustomerID AS CustomerAK,
		p.Title,
		p.FirstName,
		p.LastName,
		p.Email,
		p.Phone,
		p.DateofBirth,
		c.RegDate
	INTO [WonderfulWheelsDWb].[dbo].[Dim_Customer]
	FROM Customer c
		JOIN Person p ON c.CustomerID = p.PersonID

	-- Test 
	SELECT * FROM [WonderfulWheelsDWb].[dbo].[Dim_Customer]
GO

---11) Loading Vehicles

	SELECT
		IDENTITY(INT,1,1) AS VehicleSK,
		v.VehicleID AS VehicleAK,
		v.Make,
		v.Model,
		v.VehicleYear,
		v.Colour,
		v.KM,
		v.Price,
		oi.FinalSalePrice
	INTO [WonderfulWheelsDWb].[dbo].[Dim_Vehicle]
	FROM Vehicle v
	LEFT JOIN OrderItem oi ON v.VehicleID = oi.VehicleID
GO		

	-- Test 
	SELECT * FROM [WonderfulWheelsDWb].[dbo].[Dim_Vehicle]
GO

---12) Loading Dealerships

	SELECT 
		IDENTITY(INT,1,1) AS DealershipSK,
		d.DealershipID AS DealershipAK,
		d.DealerName,
		d.Phone,
		l.StreetAddress,
		l.City,
		l.Province,
		l.PostalCode
	INTO [WonderfulWheelsDWb].[dbo].[Dim_Dealership]
	FROM Dealership d
		LEFT JOIN [Location] l ON d.LocationID = l.LocationID

	-- Test 
	SELECT * FROM [WonderfulWheelsDWb].[dbo].[Dim_Dealership]
GO

---13) Creating report for tracking Employee Sales and Customer Orders

		SELECT 
		EmployeeSK,
		CustomerSK,
		VehicleSK,
		DealershipSK,
		YEAR(o.OrderDate) * 10000 + MONTH(o.OrderDate) * 100 + DAY(o.OrderDate) AS OrderDateSK
	INTO [WonderfulWheelsDWb].[dbo].[Fact_Sales]
	FROM [Order] o
		JOIN OrderItem oi ON oi.OrderId = o.OrderID	
		-- Join to dimensions to get SKs
		JOIN [WonderfulWheelsDWb].[dbo].[Dim_CommissionEmployee] ON o.OrderEmpID = EmployeeAK
		JOIN [WonderfulWheelsDWb].[dbo].[Dim_Customer] ON o.OrderCustID = CustomerAK
		JOIN [WonderfulWheelsDWb].[dbo].[Dim_Dealership] ON o.OrderDealID = DealershipAK
		JOIN [WonderfulWheelsDWb].[dbo].[Dim_Vehicle] ON oi.VehicleID = VehicleAK
		LEFT JOIN [WonderfulWheelsDW].[dbo].[Dim_Date] ON o.OrderDate=[Date]


	-- Test 
	SELECT * FROM [WonderfulWheelsDWb].[dbo].[Fact_Sales]

GO
