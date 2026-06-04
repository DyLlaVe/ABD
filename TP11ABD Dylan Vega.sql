USE [master];
GO

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 1: Verificación del Modo de Autenticación
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu jefe te pidió verificar si el servidor SQL Server está configurado para aceptar
logins de SQL Server Authentication, o solo acepta Windows Authentication.

TAREAS:
a) Escribe una consulta que muestre el modo de autenticación actual del servidor
   y que muestre un mensaje claro como "Mixed Mode" o "Windows Only"
*/

SELECT 
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN 'Mixed Mode (Windows & SQL Server Authentication)'
        WHEN 1 THEN 'Windows Only Authentication'
    END AS [Modo de Autenticación Actual];
GO
/* 
b) Si el resultado muestra "Windows Only", escribe el script necesario para
   cambiar a "Mixed Mode" (comentado, para no ejecutarlo accidentalmente)
*/

/*
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer', 
    N'LoginMode', 
    REG_DWORD, 
    2; 
GO
*/

/*
c) ¿Qué debes hacer después de ejecutar el script del punto b) para que el
   cambio tenga efecto?

	 Se debe reiniciar por completo el servicio de SQL Server
	 Hasta que el servicio no se reinicie, el motor de la base de datos no volverá a leer el registro de Windows y seguirá operando bajo el modo anterior.

VALIDACIÓN:
-- Ejecuta esta consulta para verificar:
SELECT 
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN 'Mixed Mode ✅'
        WHEN 1 THEN 'Windows Only ⚠️'
    END AS ModoAutenticacion;
GO
*/

-- ────────────────────────────────────────────────────────────────────────────────
-- EJERCICIO 2: Crear Logins con Políticas de Seguridad
-- ────────────────────────────────────────────────────────────────────────────────
/*
ENUNCIADO:
Tu empresa contrata a tres nuevos empleados para el departamento de Ventas:
- Ana García
- Carlos Rodríguez  
- Laura Martínez

Necesitas crear logins de SQL Server para cada uno, siguiendo las políticas
de seguridad corporativas.

TAREAS:
a) Crea un login llamado "AnaGarcia" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Verificación de políticas de Windows: ACTIVADA
   - Expiración de contraseña: ACTIVADA
   
CREATE LOGIN AnaGarcia 
WITH PASSWORD = 'Ventas2026!', 
     DEFAULT_DATABASE = [master], 
     CHECK_POLICY = ON,       
     CHECK_EXPIRATION = ON;   
GO
   
b) Crea un login llamado "CarlosRodriguez" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Mismas políticas que Ana
   
CREATE LOGIN CarlosRodriguez 
WITH PASSWORD = 'Ventas2026!',
     DEFAULT_DATABASE = [master], 
     CHECK_POLICY = ON, 
     CHECK_EXPIRATION = ON;
GO

c) Crea un login llamado "LauraMartinez" con:
   - Contraseña: Ventas2026!
   - Base de datos por defecto: master
   - Mismas políticas que Ana

CREATE LOGIN LauraMartinez 
WITH PASSWORD = 'Ventas2026!', 
     DEFAULT_DATABASE = [master], 
     CHECK_POLICY = ON, 
     CHECK_EXPIRATION = ON;
GO


VALIDACIÓN:
-- Ejecuta esta consulta para verificar que se crearon correctamente:
SELECT 
    name AS LoginName,
    type_desc AS Type,
    default_database_name AS DefaultDB,
    is_policy_checked AS CheckPolicy,
    is_expiration_checked AS CheckExpiration,
    create_date AS FechaCreacion
FROM sys.server_principals
WHERE name IN ('AnaGarcia', 'CarlosRodriguez', 'LauraMartinez')
ORDER BY name;
GO
*/
