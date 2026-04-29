use AdventureWorks2008R2;

-- Ejercicio 1

BEGIN TRANSACTION;

DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail sod
    WHERE sod.ProductID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1
    FROM Production.BillOfMaterials bom
    WHERE bom.ComponentID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1
    FROM Production.ProductInventory pi
    WHERE pi.ProductID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1 FROM Production.ProductCostHistory pch
    WHERE pch.ProductID = Production.Product.ProductID
);
PRINT 'Se eliminaron productos sin ventas';

ROLLBACK;

PRINT 'Rollback ejecutado: no hay cambios permanentes';

-- Ejercicio 2

BEGIN TRANSACTION;

UPDATE Production.Product
SET ListPrice = 200
WHERE ListPrice = 0;

PRINT 'Precios actualizados correctamente';

COMMIT;

PRINT 'Transacción confirmada';

-- Ejercicio 3

BEGIN TRANSACTION;

DECLARE @Promedio DECIMAL(10,2);
DECLARE @Minimo DECIMAL(10,2);

SELECT @Promedio = AVG(ListPrice)
FROM Production.Product;
PRINT 'Promedio: ' + CAST(@Promedio AS VARCHAR);

SELECT @Minimo = MIN(ListPrice)
FROM Production.Product;
PRINT 'Mínimo: ' + CAST(@Minimo AS VARCHAR);

UPDATE Production.Product
SET ListPrice = ListPrice * 1.15;
PRINT 'Precios incrementados un 15%';

IF (@Minimo <= @Promedio)
BEGIN
    PRINT 'El precio mínimo no supera el promedio. Revertido';
    ROLLBACK;
END
ELSE
BEGIN
    COMMIT;
END