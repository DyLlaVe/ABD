use AdventureWorks2008R2;
-- Funciones escalares
-- Ejercicio 1
go
CREATE FUNCTION dbo.fn_PromedioProductos()
RETURNS MONEY
AS
BEGIN
    DECLARE @promedio MONEY;
    SELECT @promedio = AVG(ListPrice) FROM Production.Product; 
    RETURN @promedio;
END;
GO

SELECT dbo.fn_PromedioProductos() AS PromedioGeneralProductos;

-- Ejercicio 2

go
CREATE FUNCTION dbo.fn_TotalVentasPorProducto (@ID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @total MONEY;
    SELECT @total = SUM(LineTotal) FROM Sales.SalesOrderDetail WHERE ProductID = @ID; 
    RETURN ISNULL(@total, 0); 
END;
GO

SELECT ProductID, dbo.fn_TotalVentasPorProducto(ProductID) AS TotalVentas 
FROM Production.Product;

-- Ejercicio 3

go
CREATE FUNCTION dbo.fn_CantidadVendidaProductos (@ID INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT ISNULL(SUM(OrderQty), 0) 
        FROM Sales.SalesOrderDetail 
        WHERE ProductID = @ID
    ) 
END;
GO 

SELECT Name, dbo.fn_CantidadVendidaProductos(ProductID) AS CantidadTotal
FROM Production.Product;

-- Ejercicio 4

go
CREATE FUNCTION dbo.fn_PromedioTotalVenta()
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT AVG(LineTotal) FROM Sales.SalesOrderDetail); 
END;
GO

SELECT ProductID, ListPrice FROM Production.Product 
WHERE ListPrice < dbo.fn_PromedioTotalVenta(); 

-- Funciones de Tabla en Línea
-- Ejercicio 5

GO
CREATE FUNCTION dbo.fn_EmpleadosPorAnio (@Anio INT)
RETURNS TABLE
AS
RETURN (
    SELECT P.FirstName, P.LastName, E.HireDate
    FROM Person.Person AS P
    INNER JOIN HumanResources.Employee AS E ON P.BusinessEntityID = E.BusinessEntityID
    WHERE YEAR(E.HireDate) = @Anio
);
GO

SELECT * FROM dbo.fn_EmpleadosPorAnio(2003);

-- Ejercicio 6

GO
CREATE FUNCTION dbo.fn_ProductosParametroInferior (@PrecioMax MONEY)
RETURNS TABLE
AS
RETURN (
    SELECT ProductID, Name, Color, ListPrice
    FROM Production.Product
    WHERE ListPrice < @PrecioMax 
      AND ListPrice > 0 
      AND ListPrice IS NOT NULL -- para evitar ceros y nulos
);
GO

SELECT * FROM dbo.fn_ProductosParametroInferior(100);

--Funciones Multisentencia
-- Ejercicio 7

GO
CREATE FUNCTION dbo.fn_ProductosBaratosMulti (@PrecioMax MONEY)
RETURNS @TablaSalida TABLE (
    Codigo INT,
    Nombre VARCHAR(100),
    Color VARCHAR(20),
    Precio MONEY
) 
AS
BEGIN
    INSERT INTO @TablaSalida
    SELECT ProductID, Name, Color, ListPrice 
    FROM Production.Product 
    WHERE ListPrice < @PrecioMax 
      AND ListPrice > 0; 
    RETURN; 
END;
GO

SELECT * FROM dbo.fn_ProductosBaratosMulti(50);