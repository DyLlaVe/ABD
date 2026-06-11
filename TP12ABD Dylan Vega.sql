﻿-- ════════════════════════════════════════════════════════════════════════════════
-- 📝 TRABAJO PRÁCTICO: SEGURIDAD A NIVEL DE BASE DE DATOS
-- ════════════════════════════════════════════════════════════════════════════════

-- 
-- INSTRUCCIONES:
-- 1. Lee cada enunciado con atención
-- 2. Resuelve los ejercicios en SSMS
-- 3. Verifica los resultados con las consultas de validación
-- 4. Este TP es sobre seguridad DENTRO de una base de datos (usuarios, roles, permisos)

-- ════════════════════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────────────────
-- CONFIGURACIÓN INICIAL: Crear base de datos y estructura de prueba
-- ────────────────────────────────────────────────────────────────────────────────

-- Crear base de datos para el ejercicio
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'EmpresaDB')
    DROP DATABASE EmpresaDB;
GO

CREATE DATABASE EmpresaDB;
GO

USE EmpresaDB;
GO

-- Crear tablas de ejemplo
CREATE TABLE dbo.Empleados (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Salario DECIMAL(10,2),
    Departamento NVARCHAR(50)
);
GO

CREATE TABLE dbo.Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Precio DECIMAL(10,2),
    Stock INT
);
GO

CREATE TABLE dbo.Ventas (
    VentaID INT PRIMARY KEY IDENTITY(1,1),
    ProductoID INT,
    Cantidad INT,
    FechaVenta DATE,
    Total DECIMAL(10,2)
);
GO

-- Insertar datos de ejemplo
INSERT INTO dbo.Empleados (Nombre, Apellido, Salario, Departamento)
VALUES 
    ('Juan', 'Pérez', 50000, 'Ventas'),
    ('María', 'González', 60000, 'IT'),
    ('Carlos', 'López', 45000, 'Ventas'),
    ('Ana', 'Martínez', 75000, 'Gerencia');
GO

INSERT INTO dbo.Productos (Nombre, Precio, Stock)
VALUES 
    ('Laptop', 1200.00, 50),
    ('Mouse', 25.00, 200),
    ('Teclado', 45.00, 150);
GO

INSERT INTO dbo.Ventas (ProductoID, Cantidad, FechaVenta, Total)
VALUES 
    (1, 2, '2026-06-01', 2400.00),
    (2, 10, '2026-06-02', 250.00);
GO

PRINT '✅ Base de datos EmpresaDB creada con datos de ejemplo';
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- IMPORTANTE: Asegúrate de tener los LOGINS creados en el servidor primero
-- ════════════════════════════════════════════════════════════════════════════════

USE [master];
GO

-- Crear logins si no existen (ejecutar solo si es necesario)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_ventas')
    CREATE LOGIN [usuario_ventas] WITH PASSWORD = 'Ventas2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_it')
    CREATE LOGIN [usuario_it] WITH PASSWORD = 'IT2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_rrhh')
    CREATE LOGIN [usuario_rrhh] WITH PASSWORD = 'RRHH2026!';
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_gerente')
    CREATE LOGIN [usuario_gerente] WITH PASSWORD = 'Gerente2026!';
GO

USE EmpresaDB;
GO


-- ════════════════════════════════════════════════════════════════════════════════
-- INICIO DE EJERCICIOS
-- ════════════════════════════════════════════════════════════════════════════════


-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 1: Crear Usuarios en la Base de Datos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa tiene una base de datos (EmpresaDB) y necesitas crear usuarios
para que los empleados puedan acceder a ella.

IMPORTANTE: Un LOGIN es a nivel servidor, un USER es a nivel de base de datos.
Para crear un USER, primero debe existir el LOGIN correspondiente.

TAREAS:
a) Crea un usuario llamado "usuario_ventas" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)
   
b) Crea un usuario llamado "usuario_it" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)
   
c) Crea un usuario llamado "usuario_rrhh" en la base de datos EmpresaDB
   (asociado al login del mismo nombre)
*/

-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a:
CREATE USER [usuario_ventas] FOR LOGIN [usuario_ventas];
GO
-- b:
CREATE USER [usuario_it] FOR LOGIN [usuario_it];
GO
-- c:
CREATE USER [usuario_rrhh] FOR LOGIN [usuario_rrhh];
GO

-- Verificar:
SELECT 
    name AS UserName,
    type_desc AS UserType,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE type = 'S' AND name LIKE 'usuario_%'
ORDER BY name;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 2: Asignar Roles de Base de Datos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Ahora que los usuarios están creados, necesitas asignarles roles según
sus responsabilidades en la empresa:

- usuario_ventas: Debe poder LEER todas las tablas (SELECT)
- usuario_it: Debe poder LEER y ESCRIBIR en todas las tablas (SELECT, INSERT, UPDATE, DELETE)
- usuario_rrhh: Debe poder LEER todas las tablas

ROLES DE BASE DE DATOS MÁS COMUNES:
- db_datareader: Puede hacer SELECT en todas las tablas
- db_datawriter: Puede hacer INSERT, UPDATE, DELETE en todas las tablas
- db_owner: Control total sobre la base de datos

TAREAS:
a) Asigna al usuario "usuario_ventas" el rol "db_datareader"
b) Asigna al usuario "usuario_it" los roles "db_datareader" Y "db_datawriter"
c) Asigna al usuario "usuario_rrhh" el rol "db_datareader"

*/

-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a:
ALTER ROLE [db_datareader] ADD MEMBER [usuario_ventas];
GO
-- b:
ALTER ROLE [db_datareader] ADD MEMBER [usuario_it];
ALTER ROLE [db_datawriter] ADD MEMBER [usuario_it];
GO
-- c:
ALTER ROLE [db_datareader] ADD MEMBER [usuario_rrhh];
GO

-- Verificación:
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) LIKE 'usuario_%'
ORDER BY Usuario, Rol;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 3: Permisos Específicos con GRANT
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El gerente necesita un acceso especial. Crea un nuevo usuario y asígnale
permisos específicos sobre tablas individuales.

TAREAS:
a) Crea un usuario llamado "usuario_gerente" (asociado al login existente)

b) Otorga al usuario "usuario_gerente" permiso de SELECT en la tabla Empleados

c) Otorga al usuario "usuario_gerente" permisos de SELECT, INSERT y UPDATE 
   en la tabla Ventas (NO debe poder hacer DELETE)

d) Otorga al usuario "usuario_gerente" permiso SELECT en la tabla Productos

*/
-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a: 
CREATE USER [usuario_gerente] FOR LOGIN [usuario_gerente];
GO
-- b: 
GRANT SELECT ON dbo.Empleados TO [usuario_gerente];
GO
-- c: 
GRANT SELECT, INSERT, UPDATE ON dbo.Ventas TO [usuario_gerente];
GO
-- d: 
GRANT SELECT ON dbo.Productos TO [usuario_gerente];
GO

-- Verificar:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 4: Usar DENY para Restringir Acceso
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Por políticas de seguridad de la empresa, los empleados de RRHH pueden ver
todos los datos EXCEPTO los salarios, que son confidenciales.

Actualmente usuario_rrhh tiene el rol db_datareader (puede ver todo).
Necesitas DENEGAR específicamente el acceso a la columna Salario.

TAREAS:
a) Deniega al usuario "usuario_rrhh" el permiso SELECT sobre la columna 
   "Salario" de la tabla Empleados
   
b) Verifica que el DENY está activo consultando sys.database_permissions

NOTA: Recuerda que DENY siempre tiene prioridad sobre GRANT. Aunque usuario_rrhh
tenga db_datareader, el DENY bloqueará el acceso a esa columna específica.
*/

-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a:
DENY SELECT ON dbo.Empleados(Salario) TO [usuario_rrhh];
GO

-- b/verificar:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    COL_NAME(major_id, minor_id) AS Columna,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_rrhh'
  AND state_desc = 'DENY'
ORDER BY Tabla, Columna;
GO

-- Prueba:
EXECUTE AS USER = 'usuario_rrhh';
GO

SELECT Nombre, Apellido, Salario FROM dbo.Empleados;
GO

SELECT Nombre, Apellido FROM dbo.Empleados;
GO

REVERT;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 5: Modificar Permisos con REVOKE
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El departamento de IT ya no necesita modificar datos en la tabla Productos.
Necesitas quitarle los permisos de escritura pero mantener el de lectura.

Actualmente usuario_it tiene los roles db_datareader y db_datawriter (puede
hacer INSERT, UPDATE, DELETE en todas las tablas).

TAREAS:
a) Deniega (DENY) al usuario "usuario_it" los permisos INSERT, UPDATE y DELETE
   específicamente en la tabla Productos
   
b) Verifica que usuario_it aún puede hacer SELECT en Productos (por db_datareader)
   pero NO puede modificarla

*/
-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a:
DENY INSERT, UPDATE, DELETE ON dbo.Productos TO [usuario_it];
GO

-- b/verificar:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_it'
  AND OBJECT_NAME(major_id) = 'Productos'
  AND state_desc = 'DENY'
ORDER BY Permiso;
GO

-- pruebas:
EXECUTE AS USER = 'usuario_it';
GO

SELECT * FROM dbo.Productos;
GO

UPDATE dbo.Productos SET Stock = 100 WHERE ProductoID = 1;
GO

REVERT;
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 6: Crear Rol Personalizado
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa necesita un rol personalizado para los auditores que:
- Puedan ver (SELECT) todas las tablas
- Puedan ver las definiciones de tablas y vistas
- NO puedan modificar ningún dato

TAREAS:
a) Crea un rol de base de datos llamado "AuditorRole"

b) Asigna al rol "AuditorRole" el rol de base de datos "db_datareader"

c) Otorga al rol "AuditorRole" el permiso VIEW DEFINITION a nivel de base de datos

d) Crea un usuario "usuario_auditor" (asociado al login, créalo si no existe)

e) Agrega al usuario "usuario_auditor" al rol "AuditorRole"
*/

-- TU SOLUCIÓN AQUÍ:
USE [master];
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usuario_auditor')
    CREATE LOGIN [usuario_auditor] WITH PASSWORD = 'Auditor2026!';
GO

USE EmpresaDB;
GO

-- a:
CREATE ROLE [AuditorRole];
GO
-- b:
ALTER ROLE [db_datareader] ADD MEMBER [AuditorRole];
GO
-- c:
GRANT VIEW DEFINITION TO [AuditorRole];
GO
-- d:
CREATE USER [usuario_auditor] FOR LOGIN [usuario_auditor];
GO
-- e:
ALTER ROLE [AuditorRole] ADD MEMBER [usuario_auditor];
GO

-- Verificar rol y sus miembros:
SELECT 
    USER_NAME(role_principal_id) AS Rol,
    USER_NAME(member_principal_id) AS Miembro
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id) = 'AuditorRole'
   OR USER_NAME(member_principal_id) = 'AuditorRole';
GO

-- Verificar permisos del rol
SELECT 
    USER_NAME(grantee_principal_id) AS Rol,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'AuditorRole';
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 7: Limpieza de Permisos
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
El usuario_gerente cambió de área y ya no necesita permisos sobre Ventas.
Necesitas limpiar sus permisos.

TAREAS:
a) Revoca (REVOKE) todos los permisos que tiene usuario_gerente sobre la tabla Ventas
   Recuerda: Son SELECT, INSERT y UPDATE

b) Verifica que se quitaron los permisos de Ventas pero conserva los de otras tablas
*/

-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a:
REVOKE SELECT, INSERT, UPDATE ON dbo.Ventas FROM [usuario_gerente];
GO

-- b/validar:
SELECT 
    USER_NAME(grantee_principal_id) AS Usuario,
    OBJECT_NAME(major_id) AS Tabla,
    permission_name AS Permiso,
    state_desc AS Estado
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) = 'usuario_gerente'
  AND class_desc = 'OBJECT_OR_COLUMN'
ORDER BY Tabla, Permiso;
GO

-- ════════════════════════════════════════════════════════════════════════════════
-- EJERCICIO BONUS: Consultas Útiles de Auditoría
-- ════════════════════════════════════════════════════════════════════════════════
/*
ENUNCIADO:
Como administrador de base de datos, necesitas consultas para auditar la seguridad.

TAREAS:
Escribe consultas para:

a) Listar TODOS los usuarios de la base de datos y sus roles

b) Listar TODOS los permisos GRANT otorgados a nivel de tabla

c) Listar TODOS los permisos DENY activos en la base de datos

d) Listar qué usuarios NO tienen ningún permiso asignado

e) Ver un resumen de permisos por usuario (cuántos GRANT, DENY tiene cada uno)
*/

-- TU SOLUCIÓN AQUÍ:
USE EmpresaDB;
GO

-- a) Usuarios y sus roles
SELECT 
    u.name AS [Usuario/Miembro],
    u.type_desc AS [Tipo Miembro],
    r.name AS [Rol Asignado],
    r.type_desc AS [Tipo Rol]
FROM sys.database_role_members rm
INNER JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
INNER JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE u.name NOT IN ('dbo', 'sys', 'INFORMATION_SCHEMA') -- Filtrar usuarios del sistema
ORDER BY [Usuario/Miembro], [Rol Asignado];
GO

-- b) Permisos GRANT a nivel de tabla
SELECT 
    USER_NAME(p.grantee_principal_id) AS [Usuario/Rol],
    o.name AS [Tabla],
    p.permission_name AS [Tipo Permiso],
    p.state_desc AS [Estado Permiso]
FROM sys.database_permissions p
INNER JOIN sys.objects o ON p.major_id = o.object_id
WHERE p.state_desc = 'GRANT' 
  AND o.type = 'U' -- 'U' = User Table (Tablas de usuario)
ORDER BY [Usuario/Rol], [Tabla];
GO

-- c) Permisos DENY activos
SELECT 
    USER_NAME(p.grantee_principal_id) AS [Usuario/Rol],
    p.class_desc AS [Clase Objeto],
    CASE 
        WHEN p.class_desc = 'OBJECT_OR_COLUMN' THEN OBJECT_NAME(p.major_id)
        ELSE 'A nivel de Base de Datos / Esquema'
    END AS [Nombre Objeto],
    ISNULL(COL_NAME(p.major_id, p.minor_id), 'Toda la Tabla/Objeto') AS [Columna Afectada],
    p.permission_name AS [Permiso Bloqueado],
    p.state_desc AS [Estado]
FROM sys.database_permissions p
WHERE p.state_desc = 'DENY'
ORDER BY [Usuario/Rol];
GO

-- d) Usuarios sin permisos
SELECT 
    dp.name AS [Usuario sin Permisos],
    dp.type_desc AS [Tipo],
    dp.create_date AS [Fecha Creación]
FROM sys.database_principals dp
WHERE dp.type IN ('S', 'U') -- S = SQL User, U = Windows User
  AND dp.name NOT IN ('dbo', 'guest', 'sys', 'INFORMATION_SCHEMA')
  -- Que no pertenezca a ningún rol:
  AND dp.principal_id NOT IN (SELECT member_principal_id FROM sys.database_role_members)
  -- Que no tenga permisos explícitos de objeto o BD:
  AND dp.principal_id NOT IN (SELECT grantee_principal_id FROM sys.database_permissions)
ORDER BY dp.name;
GO

-- e) Resumen de permisos por usuario
SELECT 
    dp.name AS [Usuario/Rol],
    dp.type_desc AS [Tipo Principal],
    COUNT(CASE WHEN per.state_desc = 'GRANT' THEN 1 END) AS [Total GRANTs],
    COUNT(CASE WHEN per.state_desc = 'DENY' THEN 1 END) AS [Total DENYs],
    COUNT(per.permission_name) AS [Total Permisos Registrados]
FROM sys.database_principals dp
LEFT JOIN sys.database_permissions per ON dp.principal_id = per.grantee_principal_id
WHERE dp.name NOT IN ('dbo', 'guest', 'sys', 'INFORMATION_SCHEMA')
  AND dp.type IN ('S', 'U', 'R') -- SQL Users, Windows Users, y Roles
GROUP BY dp.name, dp.type_desc
HAVING COUNT(per.permission_name) > 0 -- Solo mostrar los que tienen al menos un registro
ORDER BY [Total DENYs] DESC, [Total GRANTs] DESC;
GO



-- ════════════════════════════════════════════════════════════════════════════════
-- FIN DEL TRABAJO PRÁCTICO
-- ════════════════════════════════════════════════════════════════════════════════

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ Trabajo Práctico Completado';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📊 Resumen de lo aprendido:';
PRINT '   1. Crear USERS en una base de datos';
PRINT '   2. Asignar roles de base de datos (db_datareader, db_datawriter)';
PRINT '   3. Otorgar permisos específicos con GRANT';
PRINT '   4. Denegar permisos con DENY (bloquea incluso roles)';
PRINT '   5. Quitar permisos con REVOKE';
PRINT '   6. Crear roles personalizados';
PRINT '   7. Auditar permisos y seguridad';
PRINT '';
GO