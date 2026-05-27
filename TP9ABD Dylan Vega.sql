-- Ejercicio 1
CREATE TABLE alumnos (
    legajo CHAR(5) NOT NULL,
    documento CHAR(8) NOT NULL,
    apellido VARCHAR(30),
    nombre VARCHAR(30),
    nota DECIMAL(4,2)
);
GO
-- Ejercicio 2
INSERT INTO alumnos (legajo, documento, apellido, nombre, nota) VALUES 
('A0001', '12345678', 'Gomez', 'Juan', 8.50), 
('A0002', '23456789', 'Perez', 'Maria', 7.00),
('A0003', '34567890', 'Sanchez', 'Pedro', 7.25), 
('A0004', '45678901', 'Lopez', 'Ana', 10.00),
('A0005', '56789012', 'Perez', 'Luis', 1.50),
('A0006', '67890123', 'Martinez', 'Laura', 10.00);
GO
-- Ejercicio 3
-- No se puede porque hay elementos duplicados y UNIQUE no lo permite.
CREATE UNIQUE CLUSTERED INDEX IX_alumnos_apellido_unico_agrupado
ON alumnos(apellido);
GO
-- Ejercicio 4
CREATE CLUSTERED INDEX IX_alumnos_apellido_agrupado
ON alumnos(apellido);
GO
-- Ejercicio 5
-- No se puede porque se creo anteriormente un indice agrupado y no se puede tener mas.
ALTER TABLE alumnos
ADD CONSTRAINT PK_alumnos_legajo_agrupado PRIMARY KEY CLUSTERED (legajo);
GO
-- Ejercicio 6
ALTER TABLE alumnos
ADD CONSTRAINT PK_alumnos_legajo PRIMARY KEY NONCLUSTERED (legajo);
GO
-- Ejercicio 7
EXEC sp_helpindex 'alumnos';
EXEC sp_helpconstraint 'alumnos';
GO
-- Ejercicio 8
CREATE UNIQUE NONCLUSTERED INDEX IX_alumnos_documento_unique
ON alumnos(documento);
GO
-- Ejercicio 9
-- No se puede crear por la reestricion del indice el punto 8
INSERT INTO alumnos (legajo, documento, apellido, nombre, nota) 
VALUES ('A0007', '12345678', 'Arias', 'Juan', 8.00);
GO
-- Ejercicio 10
DROP INDEX IX_alumnos_apellido_agrupado ON alumnos;
GO
-- Ejercicio 11
ALTER TABLE alumnos
DROP CONSTRAINT PK_alumnos_legajo;
GO

ALTER TABLE alumnos
ADD CONSTRAINT PK_alumnos_legajo PRIMARY KEY CLUSTERED (legajo);
GO
