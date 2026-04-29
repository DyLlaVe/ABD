use AdventureWorks2008R2;

-- Ejercicio 1

DECLARE @TotalVentas MONEY;

SELECT @TotalVentas = SUM(d.LineTotal)
FROM Sales.SalesOrderDetail d
INNER JOIN Sales.SalesOrderHeader h
    ON d.SalesOrderID = h.SalesOrderID
WHERE YEAR(h.OrderDate) = 2006;

PRINT @TotalVentas;

-- Ejercicio 2

DECLARE @Promedio MONEY;

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

SELECT ProductID, ListPrice
FROM Production.Product
WHERE ListPrice < @Promedio;

PRINT @Promedio;


-- Ejercicio 3

DECLARE @Promedio MONEY;

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

UPDATE Production.Product
SET ListPrice = ListPrice * 1.10
WHERE ListPrice < @Promedio;

-- Ejercicio 4

DECLARE @TablaCategorias TABLE (
    Categoria NVARCHAR(50),
    Subcategoria NVARCHAR(50)
);

INSERT INTO @TablaCategorias (Categoria, Subcategoria)
SELECT 
    c.Name AS Categoria,
    s.Name AS Subcategoria
FROM Production.ProductSubcategory s
INNER JOIN Production.ProductCategory c
    ON s.ProductCategoryID = c.ProductCategoryID;

SELECT * FROM @TablaCategorias;

-- Ejercicio 5

DECLARE @Promedio MONEY;

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;

IF @Promedio < 500
    PRINT 'PROMEDIO BAJO';
ELSE
    PRINT 'PROMEDIO ALTO';