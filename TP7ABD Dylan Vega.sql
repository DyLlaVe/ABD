-- Ejercicio 1

CREATE DATABASE GestionPersonal
ON PRIMARY
(
    NAME = GestionPersonal_Data,
    FILENAME = 'C:\DATA\GestionPersonal.MDF',
    SIZE = 5MB,
    FILEGROWTH = 1MB
)
LOG ON
(
    NAME = GestionPersonal_Log,
    FILENAME = 'C:\DATA\GestionPersonal_Log.LDF',
    SIZE = 2MB,
    FILEGROWTH = 1MB
);
GO

USE GestionPersonal;
GO;

-- Ejercicio 2

CREATE DATABASE Inventario
ON PRIMARY
(
    NAME = Inventario_Data1,
    FILENAME = 'C:\DATA\Inventario1.MDF',
    SIZE = 10MB
),
FILEGROUP HISTORICO
(
    NAME = Inventario_Data2,
    FILENAME = 'C:\DATA\Inventario2.NDF',
    SIZE = 10MB
)
LOG ON
(
    NAME = Inventario_Log,
    FILENAME = 'C:\DATA\Inventario_Log.LDF',
    SIZE = 5MB
);
GO

SELECT name
FROM sys.databases
WHERE name = 'Inventario';
GO

-- Ejercicio 3

USE GestionPersonal;
GO

CREATE SCHEMA Rrhh;
GO

CREATE SCHEMA Contabilidad;
GO

CREATE SCHEMA Logistica;
GO

SELECT name
FROM sys.schemas
WHERE name IN ('Rrhh', 'Contabilidad', 'Logistica');
GO

CREATE TABLE [Rrhh].[Empleados]
(
    [EmpleadoID]    INT PRIMARY KEY,
    [Apellido]      VARCHAR(40) NOT NULL,
    [Nombre]        VARCHAR(30) NOT NULL,
    [Cargo]         VARCHAR(30) NULL,
    [FechaIngreso]  DATE NULL
);
GO

CREATE TABLE [Contabilidad].[CuentasContables]
(
    [CuentaID]     INT PRIMARY KEY,
    [Descripcion]  VARCHAR(60) NOT NULL,
    [Saldo]        DECIMAL(18,2) NULL
);
GO

DROP SCHEMA Rrhh;
GO
-- Va a provocar un error porque la tabla Empleados depende del esquema Rrhh. 
-- Para eliminar el esquema, primero se deben eliminar las tablas que dependen de él o moverlas a otro esquema.

-- Ejercicio 4

USE GestionPersonal;
GO

CREATE TYPE DNI
FROM CHAR(8) NOT NULL;
GO

CREATE TYPE Telefono
FROM VARCHAR(20) NULL;
GO

CREATE TYPE Email
FROM VARCHAR(80) NULL;
GO

SELECT name, system_type_id, user_type_id
FROM sys.types
WHERE name IN ('DNI', 'Telefono', 'Email');
GO

CREATE TABLE [Rrhh].[Contactos]
(
    [ContactoID]  INT PRIMARY KEY,
    [EmpleadoID]  INT NOT NULL,
    [Dni]         DNI,
    [Celular]     Telefono,
    [CorreoElec]  Email,
    CONSTRAINT FK_Contactos_Empleados
    FOREIGN KEY ([EmpleadoID])
    REFERENCES [Rrhh].[Empleados]([EmpleadoID])
);
GO

-- Ejercicio 5

CREATE DATABASE Clinica
ON PRIMARY
(
    NAME = Clinica_Data,
    FILENAME = 'C:\DATA\Clinica.MDF',
    SIZE = 8MB,
    FILEGROWTH = 2MB
)
LOG ON
(
    NAME = Clinica_Log,
    FILENAME = 'C:\DATA\Clinica_Log.LDF',
    SIZE = 3MB,
    FILEGROWTH = 1MB
);
GO

USE Clinica;
GO

CREATE SCHEMA Pacientes;
GO

CREATE SCHEMA Medicos;
GO

CREATE TYPE MatriculaMedica
FROM VARCHAR(10) NOT NULL;
GO

CREATE TYPE ObraSocial
FROM VARCHAR(50) NULL;
GO

CREATE TABLE [Medicos].[Profesionales]
(
    [MedicoID]      INT PRIMARY KEY,
    [Apellido]      VARCHAR(40) NOT NULL,
    [Nombre]        VARCHAR(30) NOT NULL,
    [Matricula]     MatriculaMedica,
    [Especialidad]  VARCHAR(40) NULL
);
GO


CREATE TABLE [Pacientes].[Personas]
(
    [PacienteID]  INT PRIMARY KEY,
    [Apellido]    VARCHAR(40) NOT NULL,
    [Nombre]      VARCHAR(30) NOT NULL,
    [FechaNac]    DATE NULL,
    [Cobertura]   ObraSocial
);
GO


CREATE TABLE [Pacientes].[Turnos]
(
    [TurnoID]        INT PRIMARY KEY,
    [PacienteID]     INT NOT NULL,
    [MedicoID]       INT NOT NULL,
    [FechaTurno]     DATETIME NOT NULL,
    [Observaciones]  VARCHAR(200) NULL,
    CONSTRAINT FK_Turnos_Pacientes
    FOREIGN KEY ([PacienteID])
    REFERENCES [Pacientes].[Personas]([PacienteID]),

    CONSTRAINT FK_Turnos_Medicos
    FOREIGN KEY ([MedicoID])
    REFERENCES [Medicos].[Profesionales]([MedicoID])
);
GO

SELECT name
FROM sys.schemas
WHERE name IN ('Pacientes', 'Medicos');
GO


SELECT 
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;
GO

DROP TYPE MatriculaMedica;
GO

DROP TYPE ObraSocial;
GO

-- Va a provocar un error porque las tablas Profesionales y Personas 
-- dependen de los tipos MatriculaMedica y ObraSocial respectivamente.
-- Deberian eliminarse las tablas o modificar las columnas que utilizan esos tipos antes de eliminar los tipos.