/*==============================================================*/
/* Lab 6 – Data Import (Query Data & Error Log)   Script 2      */
/* Name: Veronika Shaytarova                                    */
/* Student ID: 8730544                    			        	*/
/* 'Lab 4-SQL Answer' is taked from eConestoga 	             	*/
/*==============================================================*/

--UseWonderfulWheels Database from now on.

USE WonderfulWheels;
GO

/* 1) Display all dealerships. */

SELECT *FROM dbo.Dealership;

/* 2) Display all inventory/vehicles. Sort data by price where most expensive car is on the top. */

SELECT * 
FROM Vehicle 
ORDER BY Price DESC;

/* 3) Display all customers. Order data by first then last name in ascending order. */

SELECT CustomerID, Title, FirstName, LastName, DateofBirth, Phone, Email
FROM Customer
LEFT JOIN Person ON CustomerID = PersonID
ORDER BY FirstName, LastName ASC;

/* 4) Display all employees. Order data by first then last name in ascending order. */

SELECT EmployeeID, Title, FirstName, LastName, EmpRole, DateofBirth, Phone, Email
FROM Employee
LEFT JOIN Person ON EmployeeID = PersonID
ORDER BY FirstName, LastName ASC;

/* 5) Display all addresses , Sort data by city. */

SELECT *
FROM Location
ORDER BY City;

/* 6) Update Tracy Spencer commission. Set it to 9. Based on requirements from lab 5 you should not be able to do this. */

BEGIN TRY
	BEGIN TRANSACTION

		UPDATE CommissionEmployee
		SET Commission = 9
		WHERE EmployeeID = (SELECT PersonID FROM Person WHERE FirstName = 'Tracy' AND LastName = 'Spencer');

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION		

	INSERT INTO dbo.DbErrorLog (UserName, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage)
	VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE());		
		
END CATCH
GO

SELECT * FROM dbo.DbErrorLog

/* 7) Update Tracy Spencer title to “Mz”. Based on requirements from lab 5 you should not be able to do this. */

BEGIN TRY
	BEGIN TRANSACTION

		UPDATE Person
		SET Title = 'Mz'
		WHERE FirstName = 'Tracy' AND LastName = 'Spencer';

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION		

	INSERT INTO dbo.DbErrorLog (UserName, ErrorNumber, ErrorState, ErrorSeverity, ErrorLine, ErrorProcedure, ErrorMessage)
	VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE());		
		
END CATCH
GO

SELECT * FROM dbo.DbErrorLog

/* 8) Display vehicles that are not sold. These vehicles will be listed on dealership web site. Customers should be able to search only available vehicles. */

SELECT Vehicle.VehicleID, Make, Model, VehicleYear, Colour, KM, Price
FROM Vehicle
LEFT JOIN OrderItem ON Vehicle.VehicleID = OrderItem.VehicleID
WHERE OrderItem.VehicleID IS NULL;

/* 9) Display employee sales info. Include all employees including those who did not sell any cars.
Dealership, Employee Name, Employee Manger (Bonus), Customer name, Phone, Email, Date of Birth, Age, 
Address (Street, City, Province, and postal code) and Car info (Make, Model, Year, Color, Mileage and Final Sales Price). */

SELECT
	CONCAT (PE.FirstName, ' ', PE.LastName) AS EmployeeName,
	CONCAT (PC.FirstName, ' ', PC.LastName) AS CustomerName,
	CONCAT (M.FirstName, ' ', M.LastName) AS EmployeeManager,
	PC.Phone,
	PC.Email,
	PC.DateofBirth,
	DATEDIFF (YEAR, PC.DateofBirth, GETDATE()) AS [Age],
	CONCAT (StreetAddress, ' ', City, ' ', Province, ' ', PostalCode) AS [Address],
	CONCAT (V.Make, ' ', V.Model, ' ', V.VehicleYear,' ', V.Colour,' ', V.KM, ' ', OT.FinalSalePrice) AS CarInfo,
	D.DealerName

FROM Person PE
JOIN Employee E ON PE.PersonID = E.EmployeeID
LEFT JOIN [Order] O ON O.OrderEmpID = E.EmployeeID
LEFT JOIN OrderItem OT ON OT.OrderID = O.OrderID
LEFT JOIN Vehicle V ON V.VehicleID = OT.VehicleID
LEFT JOIN Dealership D ON D.DealershipID = OrderDealID
LEFT JOIN Customer C ON C.CustomerID = O.OrderCustID
LEFT JOIN Person PC ON PC.PersonID = C.CustomerID
LEFT JOIN [Location] L ON L.LocationID = PC.PerLocID
LEFT JOIN Person M ON M.PersonID = E.ManagerID
WHERE E.EmpRole = 'Sales'

