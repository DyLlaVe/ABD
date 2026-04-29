use AdventureWorks2008R2;

-- Ejercicio 1

CREATE PROCEDURE HumanResources.GetEmployeesByInitial
    @Initial CHAR(1)
AS
BEGIN
    SELECT 
        BusinessEntityID, 
        FirstName, 
        LastName, 
        EmailAddress
    FROM HumanResources.vEmployee
    WHERE FirstName LIKE @Initial + '%';
END;

EXEC HumanResources.GetEmployeesByInitial 'A';

-- 2Ejercicio 2

CREATE PROCEDURE ProductoVendido
    @ProductID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE ProductID = @ProductID)
    BEGIN
        PRINT 'El PRODUCTO HA SIDO VENDIDO';
    END
    ELSE
    BEGIN
        PRINT 'El PRODUCTO NO HA SIDO VENDIDO';
    END
END;

EXEC ProductoVendido 1;

-- Ejercicio 3

CREATE PROCEDURE dbo.ActualizaPrecio
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    UPDATE Production.Product
    SET ListPrice = @NewPrice
    WHERE ProductID = @ProductID;
END;

EXEC dbo.ActualizaPrecio 1,250;

-- Ejercicio 4

CREATE PROCEDURE ProveedorProducto
    @ProductID INT
AS
BEGIN
    SELECT 
        V.Name AS VendorName,
        P.Name AS ProductName,
        V.AccountNumber,
        PV.UnitMeasureCode
    FROM Purchasing.Vendor AS V
    INNER JOIN Purchasing.ProductVendor AS PV ON V.BusinessEntityID = PV.BusinessEntityID
    INNER JOIN Production.Product AS P ON PV.ProductID = P.ProductID
    WHERE P.ProductID = @ProductID;
END;

EXEC ProveedorProducto 1;

-- Ejercicio 5

CREATE PROCEDURE EmpleadoSector
    @Nombre NVARCHAR(50) = '%',
    @Apellido NVARCHAR(50) = '%'
AS
BEGIN
    SELECT 
        FirstName, 
        LastName, 
        Department
    FROM HumanResources.vEmployeeDepartmentHistory
    WHERE FirstName LIKE '%' + @Nombre + '%'
      AND LastName LIKE '%' + @Apellido + '%';
END;

EXEC EmpleadoSector 'A','A';