USE AdventureWorks;
GO	
-- EJERCICIO 1

CREATE PARTITION FUNCTION pf_SalesYear (datetime)
AS RANGE RIGHT FOR VALUES ('2005-01-01', '2006-01-01', '2007-01-01');
GO

--   ¿Qué diferencia hay entre RANGE LEFT y RANGE RIGHT?
--		La diferencia es dónde cae exactamente el valor de limite

--   ¿A qué partición pertenece la fecha '01/01/2006' con RANGE RIGHT?
--		Pertenece a la particion 3

--EJERCICIO 2
-- A
ALTER DATABASE AdventureWorks ADD FILEGROUP fgSales1;
ALTER DATABASE AdventureWorks ADD FILEGROUP fgSales2;
ALTER DATABASE AdventureWorks ADD FILEGROUP fgSales3;
ALTER DATABASE AdventureWorks ADD FILEGROUP fgSales4;
GO
-- B
ALTER DATABASE AdventureWorks ADD FILE (
    NAME = salesdata1,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist1.ndf',
    SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB
) TO FILEGROUP fgSales1;

ALTER DATABASE AdventureWorks ADD FILE (
    NAME = salesdata2,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist2.ndf',
    SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB
) TO FILEGROUP fgSales2;

ALTER DATABASE AdventureWorks ADD FILE (
    NAME = salesdata3,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist3.ndf',
    SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB
) TO FILEGROUP fgSales3;

ALTER DATABASE AdventureWorks ADD FILE (
    NAME = salesdata4,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SalesHist4.ndf',
    SIZE = 2MB, MAXSIZE = 200MB, FILEGROWTH = 2MB
) TO FILEGROUP fgSales4;
GO

--   ¿Para qué sirve distribuir particiones en filegroups distintos?
--		Permite separar físicamente los datos lógicos de una sola tabla en diferentes archivos de 
--		almacenamiento del disco duro. 

--   Mencione al menos dos ventajas operativas. 
--		Al asignar los filegroups a diferentes discos duros permite que las lecturas
--		y escrituras de distintos rangos de fechas se procesen en paralelo sin saturar un único disco.
--		Permite realizar copias de seguridad o restauraciones parciales por filegroup. Los datos históricos viejos que 
--		ya no cambian pueden respaldarse una sola vez y configurarse como de "sólo lectura", agilizando el mantenimiento diario 
--		enfocado únicamente en las particiones de datos activos.

-- EJERCICIO 3
CREATE PARTITION SCHEME ps_SalesYear
AS PARTITION pf_SalesYear
TO (fgSales1, fgSales2, fgSales3, fgSales4);
GO

-- EJERCICIO 4
CREATE TABLE dbo.SalesOrderHeader (
    SalesID INT IDENTITY(1,1) NOT NULL,
    SalesOrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT (getdate()),
    TotalDue MONEY NOT NULL,
    Status TINYINT NOT NULL
) ON ps_SalesYear(OrderDate); 
GO

-- EJERCICIO 5
-- A
INSERT INTO dbo.SalesOrderHeader (SalesOrderID, CustomerID, OrderDate, TotalDue, Status)
SELECT SalesOrderID, CustomerID, OrderDate, TotalDue, [Status]
FROM Sales.SalesOrderHeader;
GO
-- B
INSERT INTO dbo.SalesOrderHeader (SalesOrderID, CustomerID, OrderDate, TotalDue, Status)
VALUES (99999, 1, '2001-06-15', 500.00, 5);
GO

-- EJERCICIO 6
-- A
SELECT * FROM dbo.SalesOrderHeader;

-- B
SELECT 
    p.partition_number AS [Número de Partición],
    p.rows AS [Cantidad de Filas]
FROM sys.partitions p
INNER JOIN sys.tables t ON p.object_id = t.object_id
WHERE t.name = 'SalesOrderHeader' AND p.index_id IN (0, 1);

-- C
SELECT 
    SalesID,	
    OrderDate, 
    $PARTITION.pf_SalesYear(OrderDate) AS [Número de Partición]
FROM dbo.SalesOrderHeader;

-- D
SELECT 
    $PARTITION.pf_SalesYear(OrderDate) AS [Número de Partición],
    MIN(OrderDate) AS [Fecha Mínima],
    MAX(OrderDate) AS [Fecha Máxima],
    COUNT(*) AS [Cantidad de Registros]
FROM dbo.SalesOrderHeader
GROUP BY $PARTITION.pf_SalesYear(OrderDate)
ORDER BY [Número de Partición];
GO

-- ¿Los resultados coinciden con los rangos definidos en la función de partición? Justifique.
--		Sí, la consulta de cada partición contiene estrictamente las filas que corresponden a su intervalo temporal 
--		la Partición 1 procesó correctamente los registros anteriores al 2005 , la Partición 2 alojó los datos del 2005, 
--		la Partición 3 los del 2006 y la Partición 4 los registros del 2007 

-- limpieza
DROP TABLE dbo.SalesOrderHeader
DROP PARTITION SCHEME ps_SalesYear
DROP PARTITION FUNCTION pf_SalesYear
ALTER DATABASE AdventureWorks REMOVE FILE salesdata1
ALTER DATABASE AdventureWorks REMOVE FILE salesdata2
ALTER DATABASE AdventureWorks REMOVE FILE salesdata3
ALTER DATABASE AdventureWorks REMOVE FILE salesdata4
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales1
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales2
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales3
ALTER DATABASE AdventureWorks REMOVE FILEGROUP fgSales4
