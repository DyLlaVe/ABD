-- Select - Where

-- 1: Mostrar los empleados que tienen mas de 90 horas de vacaciones
SELECT Name as 'Nombre de Producto'
FROM	[Production].[Product]

-- 2: Nombre, precio y precio con IVA(21%) de productos fabricados
SELECT [Name].[ListPrice].
[ListPrice] * 1.21 'Precio con IVA'
FROM [Production].[Product]

-- 3: Diferentes titulos de trabajo existentes
SELECT DISTINCT JobTitle
FROM HumanResources.Employee
WHERE	[JobTitle] IS NOT NULL;

-- 4: Todos los posibles colores de productos
SELECT DISTINCT Color
FROM Production.Product
WHERE Color IS NOT NULL;

-- 5: Mostrar todos los tipos de pesonas que existen
SELECT DISTINCT PersonType
FROM Person.Person

-- 6: Mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson 
SELECT FirstName + ' ' + LastName AS NombreCompleto
FROM Person.Person
WHERE LastName = 'Johnson';

-- 7: Mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro
SELECT Name, ListPrice, Color
FROM Production.Product
WHERE (ListPrice < 150 AND Color = 'Red') 
   OR (ListPrice > 500 AND Color = 'Black');

-- 8: Mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000 
SELECT BusinessEntityID,
FROM HumanResources.Employee
WHERE YEAR(HireDate) >= 2000;

-- 9: Mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya fecha de fin de venta sea anerior al dia de hoy
SELECT Name, ProductNumber, ListPrice, (ListPrice * 1.10) AS PrecioIncrementado
FROM Production.Product
WHERE SellEndDate < GETDATE();

-- Between & In

-- 10: Mostrar todos los porductos cuyo precio de lista este entre 200 y 300 
SELECT * 
FROM Production.Product
WHERE ListPrice BETWEEN 200 AND 300;

-- 11: Mostrar todos los empleados que nacieron entre 1970 y 1985 
SELECT * 
FROM HumanResources.Employee
WHERE BirthDate BETWEEN '1970-01-01' AND '1985-12-31';

-- 12: Mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 
SELECT SalesOrderID, ProductID, OrderQty, UnitPrice
FROM Sales.SalesOrderDetail
WHERE ProductID IN (750, 753, 770);

-- 13: Mostrar todos los porductos cuyo color sea verde, blanco y azul 
SELECT Name, Color
FROM Production.Product
WHERE Color IN ('Green', 'White', 'Blue');

-- 14: Mostrar el la fecha,nuero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 
SELECT OrderDate, RevisionNumber, SubTotal
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) IN (2005, 2006);

-- Like
-- 15: Mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos
SELECT Name Nombre,
			ListPrice Precio,
			Color
FROM Production.Product
WHERE Name LIKE '%seat%' 
  AND ListPrice > 100 and Name LIKE '%seat%';

-- 16: Mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 
SELECT Name
FROM Production.Product
WHERE Name LIKE '%Mountain Bike%' 
  AND ListPrice BETWEEN 1000 AND 1200;

-- 17: Mostrar los nombre de los productos que tengan cualquier combinacion de "mountain bike" 
SELECT Name
FROM Production.Product
WHERE Name LIKE '%mountain bike%';

-- 18: Mostrar las personas que su nombre empiece con la letra y 
SELECT FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE 'Y%';

-- 19: Mostrar las personas que la segunda letra de su apellido es una s 
SELECT FirstName, LastName
FROM Person.Person
WHERE LastName LIKE '_s%';

-- 20: Mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez) 
SELECT FirstName + ' ' + LastName AS Persona
FROM Person.Person
WHERE LastName LIKE '%ez';

-- 21: Mostrar los nombres de los productos que su nombre termine en un numero 
SELECT Name as Producto                                                                                                                                                                           
FROM Production.Product
WHERE Name LIKE '%[0-9]';

-- 22: Mostrar las personas cuyo  nombre tenga una c o c como primer caracter, cualquier otro como segundo caracter, ni d ni d ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto sin restricciones 
SELECT FirstName Nombre
FROM Person.Person
WHERE FirstName LIKE '[Cc]_[^dfg][j-rs-w]%';

-- Order by

-- 23: Mostrar las personas ordernadas primero por su apellido y luego por su nombre
select		FirstName + '            ' + LastName as Persona 
from		Person.Person
order by	LastName asc, FirstName asc;

-- 24: Mostrar cinco productos mas caros y su nombre ordenado en forma alfabetica 
select	top 5	*
from			Production.Product
order by		ListPrice desc, Name asc;

-- Funciones de agrupacion

-- 25. mostrar la fecha mas reciente de venta
select	MAX(OrderDate) as 'fecha mas reciente de venta'
from	Sales.SalesOrderHeader;

-- 26. mostrar el precio mas barato de todas las bicicletas
select	MIN(ListPrice) as 'bici mas barata'
from	Production.Product
where	ProductNumber like '%bk%';

-- 27. mostrar la fecha de nacimiento del empleado mas joven
select	Max(BirthDate) as 'Nacimiento del empleado mas joven'
from	HumanResources.Employee;

--  Null

-- 28. mostrar los representantes de ventas (vendedores) que no tienen definido el numero de territorio
SELECT *
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL;

-- 29. mostrar el peso promedio de todos los articulos. si el peso no estuviese definido, reemplazar por cero
select	AVG(ISNULL(Weight, 0)) as 'Peso Promedio'
from	Production.Product;

-- Group by

-- 30. mostrar el codigo de subcategoria y el precio del producto mas barato de cada una de ellas
select		ProductSubcategoryID as Subcategoria,
			MIN(ListPrice) 'Precio mas barato'
from		Production.Product
group by	ProductSubcategoryID
use [AdventureWorks2008R2];

-- 31. mostrar los productos y la cantidad total vendida de cada uno de ellos
select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID
order by	1;

-- 32. mostrar los productos y la cantidad total vendida de cada uno de ellos, ordenarlos por mayor cantidad de ventas
select		Name as [Productos], SUM (OrderQty) as [Cantidad Total Vendida]
from		Sales.SalesOrderDetail S
join		Production.Product p on s.ProductID = p.ProductID
group by	P.Name
order by	[Cantidad Total Vendida] DESC;

-- 33. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por numero de factura.
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
order by	Factura;

-- Having

-- 34. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por nro de factura pero solo de aquellas ordenes superen un total de $10.000
select		SalesOrderID as Factura,
			SUM(OrderQty * UnitPrice) as Subtotal
from		Sales.SalesOrderDetail
group by	SalesOrderID
having		SUM(OrderQty * UnitPrice) > 10000
order by	1;

-- 35. mostrar la cantidad de facturas que vendieron mas de 20 unidades
select		SalesOrderID [Nro Factura], 
			SUM(OrderQty) [+ 20 Unidades]
from		Sales.SalesOrderDetail
group by	SalesOrderID
having		SUM(OrderQty) > 20
order by	SalesOrderID ASC;

-- 36. mostrar las subcategorias de los productos que tienen dos o mas productos que cuestan menos de $150
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as Cantidad
from		Production.Product
where		ListPrice < 150
group by	ProductSubcategoryID
having		COUNT(*) >= 2
order by	2 desc;

-- 37. mostrar todos los codigos de categorias existentes junto con la cantidad de productos y el precio de lista promedio por 
--      cada uno de aquellos productos que cuestan mas de $70 y el precio promedio es mayor a $300 compute
select		ProductSubcategoryID as 'Subcategoria de Producto',
			COUNT(*) as cantidad,
			AVG(ListPrice) as 'Precio Promedio'
from		Production.Product
where		ListPrice > 70
group by	ProductSubcategoryID
having		AVG(ListPrice) > 300
order by	2 desc;

--Joins

--38. mostrar numero de factura, el monto vendido y al final totalizar la facturacion joins
select			SalesOrderID AS [Numero de Factura], 
				TotalDue AS [Monto Vendido]
from			Sales.SalesOrderHeader
GROUP BY ROLLUP (SalesOrderID)
order by		SalesOrderID;

-- 39.mostrar los empleados que tambien son vendedores
select		e.*
from		HumanResources.Employee e
inner join	Sales.SalesPerson s
on			e.BusinessEntityID = s.BusinessEntityID;

-- 40. mostrar los empleados ordenados alfabeticamente por apellido y por nombre
select		p.LastName + ' ' + p.FirstName as Empleado
from		Person.Person p
inner join	HumanResources.Employee e
on			e.BusinessEntityID = p.BusinessEntityID
order by	1;

-- 41. mostrar el codigo de logueo, numero de territorio y sueldo basico de los vendedores
select		e.LoginID 'Codigo de Logueo',
			s.TerritoryID 'Numero de Territorio',
			s.Bonus 'Sueldo Basico'
from		HumanResources.Employee e
inner join	Sales.SalesPerson s
on			e.BusinessEntityID = s.BusinessEntityID;

-- 42.mostrar los productos que sean ruedas
select		*
from		Production.Product p
inner join	Production.ProductSubcategory ps
on			p.ProductSubcategoryID = ps.ProductSubcategoryID
where		ps.Name = 'Wheels';

-- 43. mostrar los nombres de los productos que no son bicicletas
select		*
from		Production.Product p
inner join	Production.ProductSubcategory ps
on			p.ProductSubcategoryID = ps.ProductSubcategoryID
where		ps.Name not like '%bikes%';

-- 44.mostrar los precios de venta de aquellos productos donde el precio de venta sea inferior al precio de lista recomendado para ese producto ordenados por nombre de producto
select		p.Name Producto,
			sd.UnitPrice 'Precio Unitario',
			p.ListPrice 'Precio de Lista'
from		Production.Product p
inner join	Sales.SalesOrderDetail sd
on			p.ProductID = sd.ProductID
where		sd.UnitPrice < p.ListPrice
order by	p.Name;

-- 45. mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares. codigo y nombre de cada uno de los dos productos y el precio de ambos.ordenar por precio en forma descendente
select		p1.Name 'Producto 1', 
			p2.Name 'Producto 2',
			p1.ListPrice 'Precio 1',
			p2.ListPrice 'Precio 2'
from		Production.Product p1
inner join	Production.Product p2
on			p1.ListPrice = p2.ListPrice
where		p1.ProductID > p2.ProductID
order by	3 desc;

-- 46.mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares. codigo y nombre de cada uno de los dos productos y el precio de ambos mayores a $15
select		
    p1.ListPrice AS Precio,
    p1.ProductID AS Codigo_Prod1, 
    p1.Name AS Nombre_Prod1,
    p2.ProductID AS Codigo_Prod2, 
    p2.Name AS Nombre_Prod2
from		
    Production.Product p1
INNER JOIN	
    Production.Product p2 ON p1.ListPrice = p2.ListPrice
where		
    p1.ProductID < p2.ProductID 
	AND p1.ListPrice > 15
order by	
    p1.ListPrice DESC;

-- 47.mostrar el nombre de los productos y de los proveedores cuya subcategoria es 15 ordenados por nombre de proveedor
use AdventureWorks2008R2
go

select		p.Name Producto,
			v.Name Proveedor
from		Production.Product p
inner join	Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
inner join	Purchasing.Vendor v on pv.BusinessEntityID = v.BusinessEntityID
where		p.ProductSubcategoryID = 15
order by	v.Name;

-- 48.mostrar todas las personas (nombre y apellido) y en el caso que sean empleados mostrar tambien el login id, sino mostrar null
select			p.FirstName + ' ' + p.LastName 'Nombre Completo'
				-- ,e.LoginID as Login
from			Person.Person p
left outer join	HumanResources.Employee e
on				p.BusinessEntityID = e.BusinessEntityID
where			e.BusinessEntityID is null;

-- 49. mostrar los vendedores (nombre y apellido) y el territorio asignado a c/u(identificador y nombre de territorio). En los casos en que un territorio no tiene vendedores mostrar igual los datos del territorio unicamente sin datos de vendedores
select				p.FirstName + ' ' + p.LastName Vendedor,
					st.TerritoryID Identidicador,
					st.Name Territorio
from				Sales.SalesPerson sp
right outer join	Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
inner join			Person.Person p on p.BusinessEntityID = sp.BusinessEntityID;

--50.mostrar el producto cartesiano ente la tabla de vendedores cuyo numero de identificacion de negociosea 280 y el territorio de venta sea el de francia subconsultas
select		*
from		Sales.SalesPerson sp
cross join	Sales.SalesTerritory st
where		sp.BusinessEntityID = 280 
and			st.Name = 'France';

-- 51.listar todos las productos cuyo precio sea inferior al precio promedio de todos los productos
select      * 
FROM        [Production].[Product]
where       ListPrice < (select avg(ListPrice) from [Production].[Product])
ORDER BY    ListPrice DESC;

-- 52.listar el nombre, precio de lista, precio promedio y diferencia de precios entre cada producto y el valor promedio general
SELECT          Name Producto, 
                ListPrice Precio, 
                (select avg(ListPrice) from Production.Product) as Promedio, 
                ListPrice - (select avg(ListPrice) from Production.Product) as Diferencia
FROM            Production.Product
ORDER BY        ListPrice DESC;

-- 53. mostrar el o los codigos del producto mas caro
SELECT      ProductID Codigo, 
            Name Producto,
            ListPrice Precio 
FROM        Production.Product
-- WHERE       ListPrice = (SELECT MAX(ListPrice) FROM Production.Product)
WHERE       ListPrice = 3578.27;

-- 54. mostrar el producto mas barato de cada subcategor�a. mostrar subcaterogia, codigo de producto y el precio de lista mas barato ordenado por subcategoria
SELECT      psc.Name Subcategoria, 
            p.ProductID Codigo, 
            p.ListPrice Precio
FROM        Production.Product p
INNER JOIN  Production.ProductSubcategory psc 
ON          p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE       ListPrice = (
                            SELECT  MIN(ListPrice) 
                            FROM    Production.Product p2 
                            WHERE   p2.ProductSubcategoryID = psc.ProductSubcategoryID
                        )
ORDER BY    psc.Name;

-- Subconsultas con exists

--55.mostrar los nombres de todos los productos presentes en la subcategor�a de ruedas

-- x join
SELECT      p.Name Producto
FROM        Production.Product p    
INNER JOIN  Production.ProductSubcategory psc 
ON          p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE       psc.Name = 'Wheels';

--x subconsulta
SELECT      Name Producto
FROM        Production.Product
WHERE       ProductSubcategoryID = (
                                        SELECT  ProductSubcategoryID 
                                        FROM    Production.ProductSubcategory 
                                        WHERE   Name = 'Wheels'
                                    );
                                    
--x subconsulta con EXISTS
SELECT      Name Producto
FROM        Production.Product p
WHERE       EXISTS (
                        SELECT  1 
                        FROM    Production.ProductSubcategory psc 
                        WHERE   psc.Name = 'Wheels' 
                                AND psc.ProductSubcategoryID = p.ProductSubcategoryID
                    );

--56.mostrar todos los productos que no fueron vendidos
-- X join
SELECT      p.Name Producto
FROM        Production.Product p
LEFT JOIN   Sales.SalesOrderDetail sod  
ON          p.ProductID = sod.ProductID
WHERE       sod.SalesOrderDetailID IS NULL;

-- por subconsulta con exists
SELECT      Name Producto
FROM        Production.Product p
WHERE       NOT EXISTS (
                            SELECT  1 
                            FROM    Sales.SalesOrderDetail sod 
                            WHERE   sod.ProductID = p.ProductID
                        );   

--57. mostrar la cantidad de personas que no son vendedores

--58.mostrar todos los vendedores (nombre y apellido) que no tengan asignado un territorio de ventas 

-- x join
SELECT      p.FirstName + ' ' + p.LastName as Vendedor
FROM        Person.Person p
INNER JOIN  Sales.SalesPerson sp
ON          p.BusinessEntityID = sp.BusinessEntityID
LEFT JOIN   Sales.SalesTerritory st
ON          st.TerritoryID = sp.TerritoryID
WHERE       st.TerritoryID IS NULL;

-- por subconsulta con exists
SELECT      p.FirstName + ' ' + p.LastName as Vendedor
FROM        Person.Person p
INNER JOIN  Sales.SalesPerson sp
ON          p.BusinessEntityID = sp.BusinessEntityID
WHERE       NOT EXISTS (
                            SELECT  1 
                            FROM    Sales.SalesTerritory st 
                            WHERE   st.TerritoryID = sp.TerritoryID
                        );

-- Subconsultas con in y not in

-- 59. mostrar las ordenes de venta que se hayan facturado en territorio de estado unidos unicamente 'us'
SELECT      soh.*
FROM        Sales.SalesOrderHeader AS soh
INNER JOIN  Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
WHERE       st.CountryRegionCode = 'US';

-- por subconsulta
SELECT      *
FROM        Sales.SalesOrderHeader 
WHERE       TerritoryID IN (SELECT TerritoryID 
                                FROM Sales.SalesTerritory 
                                WHERE CountryRegionCode = 'US');

-- 60. al ejercicio anterior agregar ordenes de francia e inglaterra
SELECT *
FROM Sales.SalesOrderHeader
WHERE ShipCountry IN ('France', 'United Kingdom');

-- 61.mostrar los nombres de los diez productos mas caros
SELECT TOP 10 Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

--62.mostrar aquellos productos cuya cantidad de pedidos de venta sea igual o superior a 20 
SELECT ProductID, COUNT(*) AS CantidadPedidos
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) >= 20;

--63. listar el nombre y apellido de los empleados que tienen un sueldo basico de 5000 pesos. 
--     no utilizar relaciones  para su resolucion 
SELECT FirstName, LastName
FROM HumanResources.EmployeePayHistory eph
JOIN Person.Person p ON eph.BusinessEntityID = p.BusinessEntityID
WHERE eph.Rate = 5000;

--Subconsultas con all y any

--64.mostrar los nombres de todos los productos de ruedas que fabrica adventure works cycles 
SELECT Name
FROM Production.Product
WHERE ProductSubcategoryID = ANY (
    SELECT ProductSubcategoryID
    FROM Production.ProductSubcategory
    WHERE Name LIKE '%Wheel%'
);

--65.mostrar los clientes ubicados en un territorio no cubierto por ning�n vendedor 
SELECT CustomerID
FROM Sales.Customer
WHERE TerritoryID NOT IN (
    SELECT TerritoryID
    FROM Sales.SalesPerson
    WHERE TerritoryID IS NOT NULL
);

--66. listar los productos cuyos precios de venta sean mayores o iguales que el precio de venta m�ximo 
--de cualquier subcategor�a de producto.
SELECT Name, ListPrice
FROM Production.Product
WHERE ListPrice >= ALL (
    SELECT MAX(ListPrice)
    FROM Production.Product
    GROUP BY ProductSubcategoryID
);

-- Expresion case

--67.listar el nombre de los productos, el nombre de la subcategoria a la que pertenece junto a su categor�a de precio. La categor�a de precio se calcula de la siguiente manera. 
--	-si el precio est� entre 0 y 1000 la categor�a es econ�mica.
--	-si la categor�a est� entre 1000 y 2000, normal 
--	-y si su valor es mayor a 2000 la categor�a es cara. 
SELECT 
    p.Name,
    ps.Name AS Subcategoria,
    p.ListPrice,
    CASE 
        WHEN p.ListPrice BETWEEN 0 AND 1000 THEN 'Econ�mica'
        WHEN p.ListPrice BETWEEN 1000 AND 2000 THEN 'Normal'
        ELSE 'Cara'
    END AS CategoriaPrecio
FROM Production.Product p
JOIN Production.ProductSubcategory ps 
ON p.ProductSubcategoryID = ps.ProductSubcategoryID;

--68.tomando el ejercicio anterior, mostrar unicamente aquellos productos cuya categoria sea "economica"
SELECT *
FROM (
    SELECT 
        p.Name,
        CASE 
            WHEN p.ListPrice BETWEEN 0 AND 1000 THEN 'Econ�mica'
            WHEN p.ListPrice BETWEEN 1000 AND 2000 THEN 'Normal'
            ELSE 'Cara'
        END AS Categoria
    FROM Production.Product p
) AS sub
WHERE Categoria = 'Econ�mica';

-- Insert, update y delete

--69.aumentar un 20% el precio de lista de todos los productos  
UPDATE Production.Product
SET ListPrice = ListPrice * 1.20;

--70.aumentar un 20% el precio de lista de los productos del proveedor 1540 
UPDATE Production.Product
SET ListPrice = ListPrice * 1.20
WHERE ProductID IN (
    SELECT ProductID
    FROM Purchasing.ProductVendor
    WHERE BusinessEntityID = 1540
);

--71.agregar un dia de vacaciones a los 10 empleados con mayor antiguedad.
UPDATE HumanResources.Employee
SET VacationHours = VacationHours + 8
WHERE BusinessEntityID IN (
    SELECT TOP 10 BusinessEntityID
    FROM HumanResources.Employee
    ORDER BY HireDate ASC
);

--72. eliminar los detalles de compra (purchaseorderdetail) cuyas fechas de vencimiento pertenezcan al tercer trimestre del a�o 2006 
DELETE FROM Purchasing.PurchaseOrderDetail
WHERE DueDate BETWEEN '2006-07-01' AND '2006-09-30';

--73.quitar registros de la tabla salespersonquotahistory cuando las ventas del a�o hasta la fecha almacenadas en la tabla salesperson supere el valor de 2500000
DELETE FROM Sales.SalesPersonQuotaHistory
WHERE BusinessEntityID IN (
    SELECT BusinessEntityID
    FROM Sales.SalesPerson
    WHERE SalesYTD > 2500000
);

-- Bulk copy

-- 74. clonar estructura y datos de los campos nombre ,color y precio de lista de la tabla production.product en una tabla llamada productos
use [AdventureWorks2008R2] 

SELECT Name, Color, ListPrice
INTO 	productos
FROM	Production.product;

select * from productos;
-- 75. clonar solo estructura de los campos identificador ,nombre y apellido de la tabla person.person en una tabla llamada productos
SELECT BusinessEntityID, FirstName, LastName
INTO 	personas	
FROM	person.Person
WHERE 	1=2;

SELECT * FROM personas;
-- 76.insertar un producto dentro de la tabla productos.tener en cuenta los siguientes datos. el color de producto debe ser rojo, el nombre debe ser "bicicleta mountain bike" y el precio de lista debe ser de 4000 pesos.
INSERT INTO productos (Name, Color, ListPrice)
VALUES ('bicicleta mountain bike', 'rojo', 4000);

select * from productos;
-- 77. copiar los registros de la tabla person.person a la tabla personas cuyo identificador este entre 100 y 200
INSERT INTO personas (BusinessEntityID, FirstName, LastName)
SELECT BusinessEntityID, FirstName, LastName
FROM person.Person
WHERE BusinessEntityID BETWEEN 100 AND 200;

-- 78. aumentar en un 15% el precio de los pedales de bicicleta
UPDATE productos
SET ListPrice = ListPrice * 1.15
WHERE Name LIKE '%pedal%';

SELECT * FROM productos
WHERE Name LIKE '%pedal%';

-- 79. eliminar de las personas cuyo nombre empiecen con la letra m
DELETE FROM personas
WHERE FirstName LIKE 'm%';

SELECT * FROM personas;

-- 80. borrar todo el contenido de la tabla productos
DELETE FROM productos;

-- 81. borrar todo el contenido de la tabla personas sin utilizar la instrucci�n delete.
TRUNCATE TABLE personas;

-- Procedimientos almacenados
-- 82. crear un procedimiento almacenado que dada una determinada inicial ,devuelva codigo, nombre,apellido y direccion de correo de los empleados cuyo nombre coincida con la inicial ingresada
CREATE PROCEDURE InformarEmpleadosPorInicial(@inicial char(1))
 AS 
    BEGIN
        SELECT		BusinessEntityID as Codigo, 
                    FirstName +' '+ LastName as Empleado, 
                    EmailAddress as 'Correo Electronico'
        FROM		HumanResources.vEmployee
        WHERE		FirstName LIKE @inicial + '%'
        ORDER BY	FirstName
    END

GO
EXECUTE InformarEmpleadosPorInicial @inicial='a'
EXECUTE InformarEmpleadosPorInicial @inicial='j'
EXECUTE InformarEmpleadosPorInicial @inicial='m'
--83. crear un procedimiento almacenado que devuelva los productos que lleven de fabricado la cantidad de dias que le pasemos como parametro

create Procedure TiempoDeFabricacion(@dias int = 1)
AS
    BEGIN
        SELECT	    Name, ProductNumber, DaysToManufacture
        FROM		Production.Product
        WHERE		DaysToManufacture = @dias
    END
GO

EXECUTE TiempoDeFabricacion @dias=2
EXECUTE TiempoDeFabricacion @dias=4
EXECUTE TiempoDeFabricacion @dias=5 
EXECUTE TiempoDeFabricacion

-- 84. crear un procedimiento almacenado que permita actualizar y ver los precios de un determinado producto que reciba como parametro

CREATE PROCEDURE ActualizarPrecios
(@cantidad as float,@codigo as int)
AS
    BEGIN
        UPDATE Production.Product
        SET ListPrice = ListPrice*@cantidad
        WHERE ProductID=@codigo

        SELECT Name,ListPrice
        FROM Production.Product
        WHERE ProductID=@codigo
    END

GO
EXECUTE ActualizarPrecios 1.1, 886

SELECT listPrice from production.Product
WHERE ProductID=886 -- Antes: 366,762  Despues: 403,4382


-- 85. armar un procedimineto almacenado que devuelva los proveedores que proporcionan el producto especificado por parametro.

CREATE PROCEDURE Proveedores(@producto varchar(30)='%')
AS
    
    SELECT      v.Name proveedor,
                p.Name producto 
    
    FROM        Purchasing.Vendor AS v 
    INNER JOIN  Purchasing.ProductVendor AS pv
    ON          v.BusinessEntityID = pv.BusinessEntityID 
    INNER JOIN  Production.Product AS p 
    ON          pv.ProductID = p.ProductID 
    WHERE       p.Name LIKE @producto
    ORDER BY    v.Name 
GO    

EXECUTE Proveedores 'r%'
EXECUTE Proveedores 'reflector'
EXECUTE Proveedores 

-- 86. crear un procedimiento almacenado que devuelva nombre,apellido y sector del empleado que le pasemos como argumento.no es necesario pasar el nombre y apellido exactos al procedimiento.
CREATE PROCEDURE empleados
    @apellido nvarchar(50)='%', 
    @nombre nvarchar(50)='%' 
AS 
    SELECT FirstName, LastName,Department
    FROM HumanResources.vEmployeeDepartmentHistory
    WHERE FirstName LIKE @nombre AND LastName LIKE @apellido
GO

EXECUTE empleados  'eric%' 
EXECUTE empleados


-- funciones escalares
-- 87.armar una funcion que devuelva los productos que estan por encima del promedio de precios general
CREATE FUNCTION promedio()
RETURNS MONEY
AS
BEGIN
        DECLARE @promedio MONEY
        SELECT @promedio=AVG(ListPrice) FROM Production.Product
        RETURN @promedio
END


--uso de la funcion
SELECT  * 
FROM    Production.Product 
WHERE   ListPrice >dbo.promedio()

SELECT AVG(ListPrice) FROM Production.Product --438.6662


-- 88.armar una funci�n que dado un c�digo de producto devuelva el total de ventas para dicho producto. luego, mediante una consulta, traer codigo, nombre y total de ventas ordenados por esta ultima columna
CREATE FUNCTION VentasProductos(@codigoProducto int) 
RETURNS int
AS
 BEGIN
   DECLARE @total int
   SELECT @total = SUM(OrderQty)
   FROM Sales.SalesOrderDetail WHERE ProductID = @codigoProducto
   IF (@total IS NULL)
      SET @total = 0
   RETURN @total
 END
 
--uso de la funcion
SELECT      ProductID "codigo producto",
            Name nombre,
            dbo.VentasProductos(ProductID) AS "total de ventas"
FROM        Production.Product
ORDER BY    3 DESC

-- Funciones de tabla en linea

-- 89.armar una funci�n que dado un a�o , devuelva nombre y  apellido de los empleados 
--     que ingresaron ese a�o 
CREATE FUNCTION fn_EmpleadosPorAnio (@anio INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.FirstName, p.LastName
    FROM HumanResources.Employee e
    JOIN Person.Person p 
        ON e.BusinessEntityID = p.BusinessEntityID
    WHERE YEAR(e.HireDate) = @anio
);

--90.armar una funci�n que dado el codigo de negocio cliente de la fabrica, devuelva el codigo, nombre y las ventas del a�o hasta la fecha para cada producto vendido en el negocio ordenadas por esta ultima columna. 

CREATE FUNCTION fn_VentasPorCliente (@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.ProductID,
        p.Name,
        SUM(sod.LineTotal) AS VentasYTD
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod 
        ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p 
        ON sod.ProductID = p.ProductID
    WHERE soh.CustomerID = @CustomerID
    GROUP BY p.ProductID, p.Name
);


SELECT * 
FROM fn_VentasPorCliente(11000)
ORDER BY VentasYTD DESC;

-- Funciones de multisentencia

--91. crear una  funci�n llmada "ofertas" que reciba un par�metro correspondiente a un precio y nos retorne una tabla 
--    con c�digo,nombre, color y precio de todos los productos cuyo precio sea inferior al par�metro ingresado
CREATE FUNCTION ofertas (@precio DECIMAL(10,2))
RETURNS @resultado TABLE
(
    ProductID INT,
    Nombre NVARCHAR(100),
    Color NVARCHAR(50),
    Precio DECIMAL(10,2)
)
AS
BEGIN

    INSERT INTO @resultado
    SELECT 
        ProductID,
        Name,
        Color,
        ListPrice
    FROM Production.Product
    WHERE ListPrice < @precio;

    RETURN;
END;
 SELECT * FROM ofertas(1000);

--Datetime

--92. mostrar la cantidad de horas que transcurrieron desde el comienzo del a�o
SELECT DATEDIFF(HOUR, 
    DATEFROMPARTS(YEAR(GETDATE()), 1, 1), 
    GETDATE()
) AS HorasTranscurridas;

--93. mostrar la cantidad de dias transcurridos entre la primer y la ultima venta
SELECT DATEDIFF(DAY, 
    MIN(OrderDate), 
    MAX(OrderDate)
) AS DiasTranscurridos
FROM Sales.SalesOrderHeader;
