-- EJERCICIO 1

BEGIN TRY
    DECLARE @PromedioOriginal MONEY;
    DECLARE @MinPrecioModificado MONEY;
--1.Logica de negocio
    SELECT @PromedioOriginal = AVG(ListPrice)
    FROM Production.Product
    WHERE ListPrice > 0;

    UPDATE Production.Product
    SET ListPrice = ListPrice * 1.15
    WHERE ListPrice > 0;
-- 2.Control de transacciones
   BEGIN TRANSACTION;
      UPDATE Production.Product
      SET ListPrice = ListPrice * 1.15
      WHERE ListPrice > 0;
       SELECT @MinPrecioModificado = MIN(ListPrice)
       FROM Production.Product
       WHERE ListPrice > 0; 

        IF @MinPrecioModificado <= @PromedioOriginal
        BEGIN
            PRINT 'El precio mínimo modificado no supera el promedio original. Aplicando ROLLBACK.';
            ROLLBACK TRANSACTION;
        END
        ELSE
        BEGIN
            PRINT 'Validación de negocio correcta. Aplicando COMMIT.';
            COMMIT TRANSACTION;
        END

END TRY
-- 3. Manejo de Errores Dinámico
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Transacción revertida debido a un error inesperado.';
    END
    DECLARE @ErrorNum INT = ERROR_NUMBER();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @MensajeCritico NVARCHAR(4000);
    SET @MensajeCritico = FORMATMESSAGE('Falla crítica en el proceso de actualización. Error Nro: %d. Detalle: %s', @ErrorNum, @ErrorMessage);
    THROW 51000, @MensajeCritico, 1;
END CATCH;
GO

-- EJERCICIO 2

USE master;
GO
-- 1.Infraestructura de Almacenamiento (Sistema de Archivos): 
CREATE DATABASE SportNetDB
ON PRIMARY 
(
    NAME = SportNetDB_Primary,
    FILENAME = 'C:\SQLData\SportNetDB.mdf', 
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 2MB
),
FILEGROUP HISTORICO 
(
    NAME = SportNetDB_Historico,
    FILENAME = 'C:\SQLData\SportNetDB_Hist.ndf', 
    SIZE = 15MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5MB 
)
LOG ON 
(
    NAME = SportNetDB_Log,
    FILENAME = 'C:\SQLData\SportNetDB_Log.ldf', 
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1MB
);
GO

USE SportNetDB;
GO

-- 2.Organización de Objetos (Esquemas): 
CREATE SCHEMA Socios AUTHORIZATION dbo;
GO
CREATE SCHEMA Facturacion AUTHORIZATION dbo;
GO
-- 3. Estandarización de Dominios (UDT)
CREATE TYPE Socios.TipoDocumento FROM VARCHAR(12) NOT NULL; 
GO
CREATE TYPE Socios.CodigoPostal FROM CHAR(8) NULL; 
GOTE TYPE Socios.CodigoPostal FROM CHAR(8) NULL;
GO
-- 4. Construcción de Tablas Relacionales

CREATE TABLE Socios.FichaPersonal
(
    SocioID INT IDENTITY(1,1) NOT NULL,
    Documento Socios.TipoDocumento NOT NULL, 
    Apellido VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    CodigoPostal Socios.CodigoPostal,       
    FechaAlta DATE CONSTRAINT DF_FichaPersonal_FechaAlta DEFAULT GETDATE() NOT NULL,
    CONSTRAINT PK_FichaPersonal PRIMARY KEY NONCLUSTERED (SocioID) 
) ON [PRIMARY];
GO

CREATE TABLE Socios.RegistroAccesos
(
    AccesoID BIGINT IDENTITY(1,1) NOT NULL,
    SocioID INT NOT NULL,
    FechaIngreso DATETIME CONSTRAINT DF_RegistroAccesos_Fecha DEFAULT GETDATE() NOT NULL,
    DispositivoID INT NOT NULL,
    CONSTRAINT PK_RegistroAccesos PRIMARY KEY NONCLUSTERED (AccesoID),
    CONSTRAINT FK_RegistroAccesos_FichaPersonal FOREIGN KEY (SocioID) 
        REFERENCES Socios.FichaPersonal(SocioID)
) ON [HISTORICO]; 
GO

CREATE TABLE Facturacion.Aranceles
(
    FacturaID INT IDENTITY(1,1) NOT NULL,
    SocioID INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaEmision DATE NOT NULL,
    CONSTRAINT PK_Aranceles PRIMARY KEY CLUSTERED (FacturaID),
    CONSTRAINT FK_Aranceles_FichaPersonal FOREIGN KEY (SocioID) 
        REFERENCES Socios.FichaPersonal(SocioID)
) ON [PRIMARY];
GO

-- EJERCICIO 3
/*
Paso 1:

-- Identificar la clave primaria de la estructura original

Presupuesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total.

-- Como un presupuesto puede contener varios productos, la clave que identifica cada registro es:

(@#Presupuesto + @Codigo_Producto)


Paso 2: 

-- Aplicar Primera Forma Normal (1FN)

-- Se eliminan los grupos repetitivos separando los datos del presupuesto de los datos de los productos incluidos en él.

Presupuesto_Cabecera = @#Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Precio_Total.
Presupuesto_Detalle = @#Presupuesto + @Codigo_Producto + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad.


Paso 3:

-- Aplicar Segunda Forma Normal (2FN)

-- Ya que la clave primaria es:
(@#Presupuesto + @Codigo_Producto)

Descripcion_Producto depende únicamente de Codigo_Producto.
Precio_Unitario depende únicamente de Codigo_Producto.

-- Por lo tanto existe dependencia parcial y esos atributos deben separarse en una nueva entidad.

Presupuesto_Cabecera = @#Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Precio_Total.
Presupuesto_Detalle = @#Presupuesto + @Codigo_Producto + Cantidad + Precio_x_Cantidad.
Producto = @Codigo_Producto + Descripcion_Producto + Precio_Unitario.


Paso 4:

-- Aplicar Tercera Forma Normal (3FN)

Razon_Social_Cliente identifica al cliente.
Los datos del cliente pueden repetirse en muchos presupuestos.

-- Por lo tanto se crea una nueva entidad Cliente y se reemplaza el nombre por una clave foránea.

Presupuesto_Cabecera = @#Presupuesto + #Cliente + Fecha_Dia + Fecha_Caducidad + Precio_Total.
Cliente = @#Cliente + Razon_Social_Cliente.
Presupuesto_Detalle = @#Presupuesto + @Codigo_Producto + Cantidad + Precio_x_Cantidad.
Producto = @Codigo_Producto + Descripcion_Producto + Precio_Unitario.


Paso 5:

-- Eliminar atributos calculados

Precio_x_Cantidad = Precio_Unitario * Cantidad
Precio_Total = SUM(Precio_x_Cantidad)


Estructura Normalizada 

Presupuesto_Cabecera = @#Presupuesto + #Cliente + Fecha_Dia + Fecha_Caducidad.
Cliente = @#Cliente + Razon_Social_Cliente.
Presupuesto_Detalle = @#Presupuesto + @Codigo_Producto + Cantidad.
Producto = @Codigo_Producto + Descripcion_Producto + Precio_Unitario.
*/

-- EJERCICIO 4
USE SportNetDB;
GO
-- 1. Punto de partida ineficiente
IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL
    DROP TABLE Socios.FichaPersonal;
GO
CREATE TABLE Socios.FichaPersonal
(
    SocioID CHAR(5) NOT NULL,
    Documento CHAR(8) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    ArancelMensual DECIMAL(10,2) NULL
); 
GO

INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual) VALUES
('S0001', '40123456', 'Pérez', 'Juan', 8500.00),
('S0002', '41123457', 'Pérez', 'María', 7250.00),
('S0003', '42123458', 'Gómez', 'Lucas', 9000.00),
('S0004', '43123459', 'Rodríguez', 'Ana', 6500.00),
('S0005', '44123460', 'Fernández', 'Luis', 4000.00),
('S0006', '45123461', 'López', 'Laura', 9750.00); 
GO

-- 2. Conflicto de unicidad
BEGIN TRY
    CREATE UNIQUE CLUSTERED INDEX IX_FichaPersonal_Apellido_Unique 
    ON Socios.FichaPersonal(Apellido); 
END TRY
BEGIN CATCH
    PRINT 'No se puede crear un índice ÚNICO sobre columnas con datos duplicados.';
    PRINT 'Mensaje de Error SQL Server: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 3. Estrategia de Indexación Mixta
ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal_SocioID PRIMARY KEY NONCLUSTERED (SocioID); 
CREATE CLUSTERED INDEX IX_FichaPersonal_Apellido ON Socios.FichaPersonal(Apellido);
GO
-- 4. Garantia de integridad
CREATE UNIQUE NONCLUSTERED INDEX IX_FichaPersonal_Documento_Unique ON Socios.FichaPersonal(Documento); 

BEGIN TRY
    INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
    VALUES ('S0007', '40123456', 'Casas', 'Pedro', 5000.00);
END TRY
BEGIN CATCH
    PRINT 'Inserción bloqueada por índice único.';
    PRINT 'Mensaje de Error SQL Server: ' + ERROR_MESSAGE(); 
END CATCH;
GO
-- 5. Reingeniería Estructural (Refactorización)
DROP INDEX IX_FichaPersonal_Apellido ON Socios.FichaPersonal; 

ALTER TABLE Socios.FichaPersonal
DROP CONSTRAINT PK_FichaPersonal_SocioID;

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal_SocioID PRIMARY KEY CLUSTERED (SocioID); 

GO

-- EJERCICIO 5
USE AdventureWorks;
GO
-- 1. Infraestructura fisica
ALTER DATABASE AdventureWorks ADD FILEGROUP FG_2011_Q1;
ALTER DATABASE AdventureWorks ADD FILEGROUP FG_2011_Q2;
ALTER DATABASE AdventureWorks ADD FILEGROUP FG_2011_Q3;
ALTER DATABASE AdventureWorks ADD FILEGROUP FG_2011_Q4; 

ALTER DATABASE AdventureWorks ADD FILE (NAME = N'AW_2011_Q1', FILENAME = N'C:\SQLData\AW_2011_Q1.ndf', SIZE = 10MB, FILEGROWTH = 5MB) TO FILEGROUP FG_2011_Q1;
ALTER DATABASE AdventureWorks ADD FILE (NAME = N'AW_2011_Q2', FILENAME = N'C:\SQLData\AW_2011_Q2.ndf', SIZE = 10MB, FILEGROWTH = 5MB) TO FILEGROUP FG_2011_Q2;
ALTER DATABASE AdventureWorks ADD FILE (NAME = N'AW_2011_Q3', FILENAME = N'C:\SQLData\AW_2011_Q3.ndf', SIZE = 10MB, FILEGROWTH = 5MB) TO FILEGROUP FG_2011_Q3;
ALTER DATABASE AdventureWorks ADD FILE (NAME = N'AW_2011_Q4', FILENAME = N'C:\SQLData\AW_2011_Q4.ndf', SIZE = 10MB, FILEGROWTH = 5MB) TO FILEGROUP FG_2011_Q4; -- [cite: 88]
GO
-- 2. Logica de particionado
CREATE PARTITION FUNCTION PF_Trimestres2011 (DATETIME)
AS RANGE RIGHT FOR VALUES 
(
    '2011-04-01 00:00:00', 
    '2011-07-01 00:00:00', 
    '2011-10-01 00:00:00' 
); 

CREATE PARTITION SCHEME PS_Trimestres2011
AS PARTITION PF_Trimestres2011
TO (FG_2011_Q1, FG_2011_Q2, FG_2011_Q3, FG_2011_Q4);
GO

-- 3. Migracion masiva
CREATE TABLE Sales.SalesOrderDetail_Particionada
(
    SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    CarrierTrackingNumber NVARCHAR(25) NULL,
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal AS (ISNULL((UnitPrice * (1.0 - UnitPriceDiscount)) * OrderQty, 0.0)),
    ModifiedDate DATETIME NOT NULL
) ON PS_Trimestres2011 (ModifiedDate);
GO

INSERT INTO Sales.SalesOrderDetail_Particionada (SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, ModifiedDate)
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount, ModifiedDate
FROM Sales.SalesOrderDetail
WHERE ModifiedDate >= '2011-01-01' AND ModifiedDate < '2012-01-01'; 
GO

-- 4. Metadatos y auditoria
SELECT 
    p.partition_number AS NumeroParticion,
    fg.name AS NombreFilegroup,
    p.rows AS CantidadRegistros
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.destination_data_spaces dds ON p.partition_number = dds.destination_id
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE p.object_id = OBJECT_ID('Sales.SalesOrderDetail_Particionada') AND i.index_id <= 1;
GO

-- 5. ROLLBACK ESTRUCTURAL (Secuencia limpia de desmantelamiento seguro)
/*
DROP TABLE Sales.SalesOrderDetail_Particionada; 
DROP PARTITION SCHEME PS_Trimestres2011; 
DROP PARTITION FUNCTION PF_Trimestres2011;]

ALTER DATABASE AdventureWorks REMOVE FILE AW_2011_Q1;
ALTER DATABASE AdventureWorks REMOVE FILE AW_2011_Q2;
ALTER DATABASE AdventureWorks REMOVE FILE AW_2011_Q3;
ALTER DATABASE AdventureWorks REMOVE FILE AW_2011_Q4; 

ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_2011_Q1;
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_2011_Q2;
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_2011_Q3;
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_2011_Q4; 
*/

-- EJERCICIO 6

USE master;
GO
-- 1. Auditoria de instancia
DECLARE @AuthenticationMode INT;
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', @AuthenticationMode OUTPUT;
IF @AuthenticationMode = 1
BEGIN
    PRINT 'El servidor está en "Modo de Autenticación de Windows solamente" (No admite logins internos SQL).';
    PRINT 'PROCEDIMIENTO REQUERIDO DE CAMBIO A MODO MIXTO:';
    PRINT ' 1. Ejecutar en SSMS la siguiente instrucción de reconfiguración:';
    PRINT '    EXEC xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 2;';
    PRINT ' 2. REQUISITO OPERATIVO: Reiniciar de inmediato el servicio del motor SQL Server desde el Configuration Manager.';
END
ELSE IF @AuthenticationMode = 2
BEGIN
    PRINT 'Confirmado: El servidor ya se encuentra configurado en Modo Mixto (Windows y SQL Server Auth).'; -- [cite: 97, 98]
END;
GO

-- 2. Aprovisionamiento con politicas 
CREATE LOGIN SecAuditor_Gomez WITH PASSWORD = 'P@ssw0rd_SecAuditor2026!', CHECK_EXPIRATION = ON, CHECK_POLICY = ON; -- [cite: 100, 102]
CREATE LOGIN NocMonitor_Lopez WITH PASSWORD = 'P@ssw0rd_NocMonitor2026!', CHECK_EXPIRATION = ON, CHECK_POLICY = ON; -- [cite: 101, 102]
CREATE LOGIN DbaJunior_Paz WITH PASSWORD = 'P@ssw0rd_DbaJunior2026!', CHECK_EXPIRATION = ON, CHECK_POLICY = ON; -- [cite: 101, 102]
GO

-- 3. Gestion de ciclo de vida
ALTER LOGIN NocMonitor_Lopez DISABLE;

ALTER LOGIN DbaJunior_Paz WITH PASSWORD = 'NewP@ssw0rd_DbaJr2026!' MUST_CHANGE;

ALTER LOGIN SecAuditor_Gomez WITH DEFAULT_DATABASE = SportNetDB; 
GO
-- 4. Separacion de funciones
ALTER SERVER ROLE securityadmin ADD MEMBER SecAuditor_Gomez;

ALTER SERVER ROLE processadmin ADD MEMBER NocMonitor_Lopez; 

ALTER SERVER ROLE diskadmin ADD MEMBER DbaJunior_Paz; 
GO
-- 5. Validacion medica
SELECT 
    l.name AS LoginName,
    l.is_disabled AS IsDisabled,
    l.default_database_name AS DefaultDB,
    r.name AS ServerRoleAssign
FROM sys.server_principals l
LEFT JOIN sys.server_role_members rm ON l.principal_id = rm.member_principal_id
LEFT JOIN sys.server_principals r ON rm.role_principal_id = r.principal_id
WHERE l.name IN ('SecAuditor_Gomez', 'NocMonitor_Lopez', 'DbaJunior_Paz'); 
GO

-- EJERCICIO 7

USE master;
GO
-- 1. Modelado base
CREATE DATABASE StreamPlayDB;
GO
USE StreamPlayDB;
GO
CREATE TABLE Suscripciones 
(
    UsuarioID INT PRIMARY KEY, 
    Email VARCHAR(100), 
    MetodoPago_Tarjeta VARCHAR(20),
    MontoMensual DECIMAL(10,2)
);
CREATE TABLE Catalogo (VideoID INT PRIMARY KEY, Titulo VARCHAR(150), Genero VARCHAR(50)); 

CREATE TABLE Visualizaciones (HistorialID INT PRIMARY KEY, UsuarioID INT, VideoID INT, Fecha DATETIME); 
GO

-- 2. Aprovisionamiento perimetral
USE master;
GO
CREATE LOGIN Login_Soporte WITH PASSWORD = 'Soporte_P@ss2026';
CREATE LOGIN Login_Creador WITH PASSWORD = 'Creador_P@ss2026';
CREATE LOGIN Login_Auditor WITH PASSWORD = 'Auditor_P@ss2026';
CREATE LOGIN Login_Gerente WITH PASSWORD = 'Gerente_P@ss2026';
CREATE LOGIN Login_Finanzas WITH PASSWORD = 'Finanzas_P@ss2026';
GO

USE StreamPlayDB;
GO
CREATE USER User_Soporte FOR LOGIN Login_Soporte;
CREATE USER User_Creador FOR LOGIN Login_Creador;
CREATE USER User_Auditor FOR LOGIN Login_Auditor;
CREATE USER User_Gerente FOR LOGIN Login_Gerente;
CREATE USER User_Finanzas FOR LOGIN Login_Finanzas; 
GO

-- 3. Roles fijos de base de datos
ALTER ROLE db_datareader ADD MEMBER User_Soporte; 
ALTER ROLE db_datareader ADD MEMBER User_Finanzas;
ALTER ROLE db_datawriter ADD MEMBER User_Finanzas; 
GO
-- 4. Seguridad granular
GRANT SELECT, INSERT, UPDATE ON Catalogo TO User_Gerente; 
GRANT SELECT ON Suscripciones TO User_Gerente;
GRANT SELECT ON Visualizaciones TO User_Gerente;
GO
-- 5. Restriccion de privilegios
DENY INSERT, UPDATE, DELETE ON Catalogo TO User_Soporte; 
DENY SELECT ON Suscripciones(MetodoPago_Tarjeta) TO User_Soporte;
DENY SELECT ON Suscripciones(MetodoPago_Tarjeta) TO User_Gerente;
GO
-- 6. Seguridad avanzada y roles personalizados
CREATE ROLE Custom_Auditor_Role; 
GRANT SELECT TO Custom_Auditor_Role; 
GRANT VIEW DEFINITION TO Custom_Auditor_Role;
ALTER ROLE Custom_Auditor_Role ADD MEMBER User_Auditor;
GO
-- 7. Normalizacion de permisos
REVOKE INSERT, UPDATE ON Catalogo FROM User_Gerente; 
GO

-- EJERCICIO 8

USE msdb;
GO
-- 1. Configuracion global
DECLARE @JobID BINARY(16);
EXEC dbo.sp_add_job 
    @job_name = N'Limpieza_Automatica_Accesos_SportNet', 
    @enabled = 1,
    @description = N'Eliminación automática de registros de accesos con más de 30 días de antigüedad.', 
    @owner_login_name = N'sa',
    @job_id = @JobID OUTPUT; 
-- 2. Definicion del paso
EXEC dbo.sp_add_jobstep 
    @job_id = @JobID,
    @step_name = N'Purga_Registros_Antiguos',
    @step_id = 1,
    @cmdexec_success_code = 0,
    @on_success_action = 1, 
    @on_fail_action = 2,    
    @retry_attempts = 2, 
    @retry_interval = 5,   
    @os_run_priority = 0,
    @subsystem = N'TSQL', 
    @command = N'DELETE FROM Socios.RegistroAccesos WHERE FechaIngreso < DATEADD(day, -30, GETDATE());', 
    @database_name = N'SportNetDB';
-- 3. Planificacion horaria recurrente
DECLARE @ScheduleID INT;
EXEC dbo.sp_add_jobschedule 
    @job_id = @JobID,
    @name = N'Planificacion_Semanal_Domingos_Madrugada',
    @enabled = 1,
    @freq_type = 8,         
    @freq_interval = 1,     
    @freq_recurrence_factor = 1,
    @active_start_date = 20260101,
    @active_start_time = 030000,
    @schedule_id = @ScheduleID OUTPUT;
-- 4. Asignacion del destino
EXEC dbo.sp_add_jobserver 
    @job_id = @JobID,
    @server_name = N'(local)'; 
GO

-- EJERCICIO 9

USE master;
GO

-- 1. Infraestructura Base
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CoffeeHouseDB')
BEGIN
    ALTER DATABASE CoffeeHouseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CoffeeHouseDB;
END
GO

CREATE DATABASE CoffeeHouseDB;
GO

USE CoffeeHouseDB;
GO

CREATE TABLE dbo.Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    PuntosAcumulados INT DEFAULT 0
);

CREATE TABLE dbo.OrdenesCompra (
    OrdenID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT NOT NULL,
    Producto VARCHAR(100) NOT NULL,
    TotalFacturado DECIMAL(10,2) NOT NULL,
    FechaVenta DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Ordenes_Clientes FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID)
);
GO

INSERT INTO dbo.Clientes (Nombre, PuntosAcumulados) VALUES ('Juan Pérez', 10), ('Ana Gómez', 25);
INSERT INTO dbo.OrdenesCompra (ClienteID, Producto, TotalFacturado, FechaVenta) 
VALUES 
(1, 'Espresso + Croissant', 4500.00, '2026-06-13 08:15:00'),
(2, 'Latte Macchiato XL', 3200.00, '2026-06-13 08:45:00');
GO

-- Base de datos e infraestructura base de las 08:00 AM lista.


-- 2. Linea Base General (Backup Full)
ALTER DATABASE CoffeeHouseDB SET RECOVERY FULL;
GO

BACKUP DATABASE CoffeeHouseDB
TO DISK = 'C:\SQLBackups\CoffeeHouse_Full.bak'
WITH FORMAT, INIT, NAME = 'CoffeeHouseDB - Backup Completo Inicial (09:00 AM)';
GO
-- Backup FULL generado de forma segura en disco. 09:00 AM.


-- 3. Punto de Control Acumulativo (Backup Diferencial)
INSERT INTO dbo.Clientes (Nombre, PuntosAcumulados) VALUES ('Carlos López', 5);
INSERT INTO dbo.OrdenesCompra (ClienteID, Producto, TotalFacturado, FechaVenta) 
VALUES (3, 'Capuccino Italiano', 2800.00, '2026-06-13 10:20:00');
GO

BACKUP DATABASE CoffeeHouseDB
TO DISK = 'C:\SQLBackups\CoffeeHouse_Diff.bak'
WITH DIFFERENTIAL, FORMAT, INIT, NAME = 'CoffeeHouseDB - Backup Diferencial (11:00 AM)';
GO

-- Backup Diferencial generado con los cambios de la mañana. 11:00 AM.


-- 4. Resguardos Transaccionales (Backup de Logs)

-- Ventas del mediodía
INSERT INTO dbo.OrdenesCompra (ClienteID, Producto, TotalFacturado, FechaVenta) 
VALUES (1, 'Cold Brew Coffee', 2500.00, '2026-06-13 11:45:00');
GO

-- Backup del Log 1 (12:00 PM)
BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\SQLBackups\CoffeeHouse_Log1.trn'
WITH FORMAT, INIT, NAME = 'CoffeeHouseDB - Backup de Log 1 (12:00 PM)';
GO

-- Ventas de la tarde
INSERT INTO dbo.OrdenesCompra (ClienteID, Producto, TotalFacturado, FechaVenta) 
VALUES (2, 'Frappuccino Dulce de Leche', 3800.00, '2026-06-13 13:30:00');
GO

-- Backup del Log 2 (02:00 PM)
BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\SQLBackups\CoffeeHouse_Log2.trn'
WITH FORMAT, INIT, NAME = 'CoffeeHouseDB - Backup de Log 2 (02:00 PM)';
GO
-- Cadena de logs transaccionales guardada de forma secuencial.

-- 5. Protocolo de Recuperación

-- Simulamos la catástrofe
USE master;
GO
ALTER DATABASE CoffeeHouseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE CoffeeHouseDB;
-- Base de datos destruida por completo. Iniciando protocolo de Disaster Recovery...';
GO

-- PROTOCOLO DE RESTAURACIÓN PASO A PASO (Cadena ininterrumpida)

-- Restaurar el Backup FULL con NORECOVERY (La BD queda en estado RESTORING)
RESTORE DATABASE CoffeeHouseDB
FROM DISK = 'C:\SQLBackups\CoffeeHouse_Full.bak'
WITH NORECOVERY;
PRINT '    -> Paso 1/4: Backup FULL restaurado (Estado: NORECOVERY).';

-- Restaurar el Backup Diferencial con NORECOVERY (Avanza los datos hasta las 11:00 AM)
RESTORE DATABASE CoffeeHouseDB
FROM DISK = 'C:\SQLBackups\CoffeeHouse_Diff.bak'
WITH NORECOVERY;
PRINT '    -> Paso 2/4: Backup Diferencial acumulado aplicado (Estado: NORECOVERY).';

-- Restaurar el Log de las 12:00 PM con NORECOVERY
RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\SQLBackups\CoffeeHouse_Log1.trn'
WITH NORECOVERY;
PRINT '    -> Paso 3/4: Transacciones del mediodía (Log 1) integradas (Estado: NORECOVERY).';

-- Restaurar el último Log de las 02:00 PM con RECOVERY (Abre la base de datos al público)
RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\SQLBackups\CoffeeHouse_Log2.trn'
WITH RECOVERY;
PRINT '    -> Paso 4/4: Últimas transacciones (Log 2) integradas. Base de datos en producción (RECOVERY).';
GO

-- 6. Validación de Integridad

USE CoffeeHouseDB;
GO

SELECT 
    o.OrdenID,
    c.Nombre AS NombreCliente,
    o.Producto,
    o.TotalFacturado,
    CONVERT(VARCHAR(5), o.FechaVenta, 108) AS HoraVenta
FROM dbo.OrdenesCompra o
JOIN dbo.Clientes c ON o.ClienteID = c.ClienteID
ORDER BY o.OrdenID;
GO

-- EJERCICIO 10

/*
1. Si la prioridad absoluta de una empresa es poder utilizar el servidor secundario de respaldo para generar reportes pesados de forma aislada, ¿cuál es la solución tecnológica recomendada por defecto en la actualidad?
•	C) Always On AG, debido a que permite configurar copias legibles (Secondaries Read-Only) para reportes.
2. Al analizar la infraestructura de almacenamiento de la tecnología Clustering (FCI), ¿cuál es el principal riesgo técnico asociado a su diseño?
•	B) El uso de almacenamiento compartido (SAN/NAS), que introduce un riesgo de punto único de falla.
3. Un administrador de sistemas propone utilizar "Mirroring" (Reflejo) para proteger una base de datos individual en un proyecto nuevo. Según el estado actual de la tecnología (2026), ¿cuál es la postura correcta ante esta sugerencia?
•	B) Debe rechazarse, porque es una tecnología depreciada sin soporte activo por parte de Microsoft.
4. ¿Cuál es la diferencia conceptual clave en el "Nivel de Protección" entre Clustering (FCI) y Always On AG ante una falla de hardware?
•	D) FCI protege la instancia completa de SQL Server, mientras que Always On protege un grupo de bases de datos elegidas.
5. ¿Qué requisito del sistema operativo Windows comparten obligatoriamente las tecnologías "Clustering (FCI)" y "Always On AG" para poder operar?
•	C) Ambas dependen de la configuración de un Windows Server Failover Cluster (WSFC).
*/
