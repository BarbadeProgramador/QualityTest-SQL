
------
--CREACION DE BASE DE DATOS

--DB : [Quality-test]

CREATE TABLE Department (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Area (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Employee (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    nit INT NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    charge VARCHAR(100) NOT NULL,
    id_department INT NOT NULL,
    id_area INT NOT NULL,
    FOREIGN KEY (id_department) REFERENCES Department(id),
    FOREIGN KEY (id_area) REFERENCES Area(id)
);

CREATE TABLE Nomina (
    id INT PRIMARY KEY IDENTITY(1,1),
    employee_id INT NOT NULL,
    payment_day DATE NOT NULL,
    salary INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(id)
);

CREATE TABLE UserTable (
    id INT PRIMARY KEY IDENTITY(1,1),
    userName VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    id_person INT NOT NULL,
    FOREIGN KEY (id_person) REFERENCES Employee(id)
);

CREATE TABLE Rol (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE User_Rol (
    id INT PRIMARY KEY IDENTITY(1,1),
    rol_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (rol_id) REFERENCES Rol(id),
    FOREIGN KEY (user_id) REFERENCES UserTable(id)
);

CREATE TABLE Permission (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Rol_Permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES Rol(id),
    FOREIGN KEY (permission_id) REFERENCES Permission(id)
);

CREATE TABLE User_Permissions (
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    FOREIGN KEY (user_id) REFERENCES UserTable(id) ,
    FOREIGN KEY (permission_id) REFERENCES Permission(id) 
);

--
-- CREACION DE PROCEDIMIENTOS ALMACENADOS
CREATE PROCEDURE [dbo].[permisoVisualizacionEmpleadosSP5]
    @id_usuario INT 
AS 
BEGIN 
    DECLARE @id_departamento INT;
    DECLARE @id_area INT;
    DECLARE @rol_usuario VARCHAR(50);
    DECLARE @tienePermisoVerEmpleados BIT;

    -- SP Validacion Rol 
	EXEC validarRolesUsuario @id_usuario, @rol_usuario OUTPUT, @id_departamento OUTPUT, @id_area OUTPUT;
	-- SP Validacion Permisos asignados
	EXEC VerificarPermisoSP @id_usuario = @id_usuario , @permiso = 'Ver empleados', @tienePermiso = @tienePermisoVerEmpleados OUTPUT;
    
    --Ejecucion si se tiene permisos
    IF @tienePermisoVerEmpleados = 1
    BEGIN
	--Condicionales basados en los cargos 
        IF @rol_usuario = 'Supervisor'
        BEGIN
            -- Caso 1: Supervisor solo puede  ver empleados de su mismo departamento 
            SELECT e.id, e.name as Nombre, email, Charge as Cargo, d.name as Departamento, a.name as Area 
            FROM Employee e
			INNER JOIN Department d on  d.id = e.id_department
			INNER JOIN Area a on a.id = e.id_area
            WHERE id_department = @id_departamento;
        END
        ELSE IF @rol_usuario = 'Gerente'
        BEGIN
			-- Caso 2 : Gerente solo puede ver empleados de su misma area 
            SELECT  e.name as Nombre, e.nit, e.email, e.Charge, d.name as Departamento , a.name as Area 
            FROM Employee e
			INNER JOIN Department d on  d.id = e.id_department
			INNER JOIN Area a on a.id = e.id_area
            WHERE id_area = @id_area;
        END
    END
END;


CREATE PROCEDURE [dbo].[permisoVisualizacionNominaSP]
    @id_usuario INT 
AS 
BEGIN 
    DECLARE @id_departamento INT;
    DECLARE @id_area INT;
    DECLARE @rol_usuario VARCHAR(50);
    DECLARE @tienePermisoVerNomina BIT;

    -- Llamar al procedimiento para validar roles
    EXEC validarRolesUsuario @id_usuario, @rol_usuario OUTPUT, @id_departamento OUTPUT, @id_area OUTPUT;

    -- Verificar si el usuario tiene permiso para ver la nómina
    EXEC VerificarPermisoSP @id_usuario = @id_usuario , @permiso = 'Ver pagos', @tienePermiso = @tienePermisoVerNomina OUTPUT;
    
    -- Ejecución si se tiene permisos
    IF @tienePermisoVerNomina = 1
    BEGIN
		IF @rol_usuario = 'Gerente'
        BEGIN
            -- Gerente ve la nómina de su área
			SELECT e.name as nombre,e.nit,e.charge, a.name as Area , n.payment_day , n.salary FROM Employee e 
			INNER JOIN Nomina n on  e.id = n.employee_id 
			INNER JOIN Department d on d.id = e.id_department
			INNER JOIN Area a on a.id = e.id_area
			WHERE  id_area = @id_area;
        END
		ElSE 
		BEGIN
			select e.name as nombre ,n.payment_day,n.salary from Nomina n
			INNER JOIN Employee e on e.id = n.employee_id
		END
    END
END;

CREATE PROCEDURE [dbo].[validarRolesUsuario]
    @id_usuario INT,
    @rol_usuario VARCHAR(50) OUTPUT,
    @id_departamento INT OUTPUT,
    @id_area INT OUTPUT
AS
BEGIN
    SELECT @rol_usuario = r.name, @id_departamento = e.id_department, @id_area = e.id_area
    FROM UserTable u
    JOIN User_Rol ur ON u.id = ur.user_id
    JOIN Rol r ON ur.rol_id = r.id
    JOIN Employee e ON u.id_person = e.id
    WHERE u.id = @id_usuario;
END;


CREATE PROCEDURE [dbo].[VerificarPermisoSP]
    @id_usuario INT,
    @permiso VARCHAR(50),
    @tienePermiso BIT OUTPUT
AS
BEGIN
    SET @tienePermiso = 0;

    IF EXISTS (
        SELECT 1 
        FROM User_Rol ur
        JOIN Rol_Permissions rp ON ur.rol_id = rp.role_id
        JOIN Permission p ON rp.permission_id = p.id
        WHERE ur.user_id = @id_usuario AND p.name = @permiso
    ) 
    OR EXISTS (
        SELECT 1 
        FROM User_Permissions up
        JOIN Permission p ON up.permission_id = p.id
        WHERE up.user_id = @id_usuario AND p.name = @permiso
    )
    BEGIN
        SET @tienePermiso = 1;
    END
END;

--INSERTAR DATOS A TABLAS 
--CREACION DE DEPARTAMENTOS
INSERT INTO Department  VALUES
('Antioquia'),
('Cundinamarca'),
('Valle del Cauca'),
('Atlantico'),
('Santander'),
('Bolivar'),
('Choco'),
('Tolima'),
('Magdalena'),
('Cauca');


--AGREGAR AREAS DE LA EMPRESA
INSERT INTO Area  VALUES
('Recursos Humanos'),
('Tecnologia'),
('Finanzas'),
('Ventas'),
('Operaciones');



INSERT INTO Employee VALUES
('Carlos Perez', 123456, 'carlos.perez@empresa.com', 'Analista', 11, 6),
('Ana Gomez', 234567, 'ana.gomez@empresa.com', 'Desarrollador', 12, 7),
('Luis Rodriguez', 345678, 'luis.rodriguez@empresa.com', 'Gerente', 13, 8),
('Maria Fernanda Lopez', 456789, 'maria.lopez@empresa.com', 'Coordinador', 14, 9),
('Sofia Martinez', 567890, 'sofia.martinez@empresa.com', 'Vendedor', 15, 10),
('Pedro Ramirez', 678901, 'pedro.ramirez@empresa.com', 'Tecnico', 16, 6),
('Laura Castro', 789012, 'laura.castro@empresa.com', 'Auxiliar', 17, 7),
('Fernando Vargas', 890123, 'fernando.vargas@empresa.com', 'Gerente', 18, 8),
('Diana Salazar', 901234, 'diana.salazar@empresa.com', 'Desarrollador', 19, 9),
('Ricardo Medina', 112233, 'ricardo.medina@empresa.com', 'Contador', 20, 10),
('Patricia Naranjo', 445566, 'patricia.naranjo@empresa.com', 'Vendedor', 11, 7),
('Alejandro Rios', 778899, 'alejandro.rios@empresa.com', 'Tecnico', 12, 8),
('Carmen Ortiz', 990011, 'carmen.ortiz@empresa.com', 'Coordinador', 13, 9),
('Hernan Gil', 223344, 'hernan.gil@empresa.com', 'Analista', 14, 10),
('Gloria Fernandez', 556677, 'gloria.fernandez@empresa.com', 'Gerente', 15, 6),
('Samuel Quintero', 889900, 'samuel.quintero@empresa.com', 'Auxiliar', 16, 7),
('Natalia Arango', 334455, 'natalia.arango@empresa.com', 'Desarrollador', 17, 8),
('Raul Velasquez', 667788, 'raul.velasquez@empresa.com', 'Contador', 18, 9),
('Ximena Leon', 112244, 'ximena.leon@empresa.com', 'Tecnico', 19, 10),
('Diego Contreras', 334466, 'diego.contreras@empresa.com', 'Vendedor', 20, 6);


--PAGOS DE NOMINA
INSERT INTO Nomina VALUES
(23, '2024-01-01', 3200000),
(24, '2024-01-01', 4500000),
(25, '2024-01-01', 7800000),
(26, '2024-01-01', 3600000),
(27, '2024-01-01', 2900000),
(28, '2024-01-01', 4100000),
(29, '2024-01-01', 2700000),
(30, '2024-01-01', 8200000),
(31, '2024-01-01', 4300000),
(32, '2024-01-01', 5500000),
(33, '2024-01-01', 3100000),
(34, '2024-01-01', 3900000),
(35, '2024-01-01', 4700000),
(36, '2024-01-01', 3500000),
(37, '2024-01-01', 7700000),
(38, '2024-01-01', 2800000),
(39, '2024-01-01', 4900000),
(40, '2024-01-01', 5600000),
(41, '2024-01-01', 3800000),
(23, '2024-02-01', 3200000),
(24, '2024-02-01', 4500000),
(25, '2024-02-01', 7800000),
(26, '2024-02-01', 3600000),
(27, '2024-02-01', 2900000),
(28, '2024-02-01', 4100000),
(29, '2024-02-01', 2700000),
(30, '2024-02-01', 8200000),
(31, '2024-02-01', 4300000),
(32, '2024-02-01', 5500000),
(33, '2024-02-01', 3100000),
(34, '2024-02-01', 3900000),
(35, '2024-02-01', 4700000),
(36, '2024-02-01', 3500000),
(37, '2024-02-01', 7700000),
(38, '2024-02-01', 2800000),
(39, '2024-02-01', 4900000),
(40, '2024-02-01', 5600000),
(41, '2024-02-01', 3800000);

--CREACION DE USUARIOS 
INSERT INTO UserTable
VALUES 
('carlos200', HASHBYTES('SHA2_256', 'quality1'), 22),
('ana200', HASHBYTES('SHA2_256', 'quality2'), 23),
('luis200', HASHBYTES('SHA2_256', 'quality3'), 24),
('maria200', HASHBYTES('SHA2_256', 'quality4'), 25),
('sofia200', HASHBYTES('SHA2_256', 'quality5'), 26),
('pedro200', HASHBYTES('SHA2_256', 'quality6'), 27),
('laura200', HASHBYTES('SHA2_256', 'quality7'), 28),
('fernando200', HASHBYTES('SHA2_256', 'quality8'), 29),
('diana200', HASHBYTES('SHA2_256', 'quality9'), 30),
('ricardo200', HASHBYTES('SHA2_256', 'quality10'), 31);



--CREACION DE ROLES
INSERT INTO Rol VALUES 
('Supervisor'),
('Gerente'),
('General');

--CREACION DE PERMISOS 
INSERT INTO Permission  VALUES 
('Ver empleados'),
('Ver pagos');

--ASIGNACION DE PERMISOS A ROL 
-- Supervisor puede ver empleados pero no pagos
INSERT INTO Rol_Permissions VALUES (4, 3);

-- Gerente puede ver empleados y pagos
INSERT INTO Rol_Permissions  VALUES (5, 3);
INSERT INTO Rol_Permissions  VALUES (5, 4);


--ASIGNACION DE PERMISOS A USUARIO 
INSERT INTO [dbo].[User_Permissions] VALUES (15, 4)

-- General personalizado solo puede ver pagos
INSERT INTO User_Permissions VALUES (3, 2);

--ASIGNACION DE ROLES A USUARIOS  rol- usuario
INSERT INTO User_Rol VALUES 
(5, 11), --CARLOS Gerente
(5, 12), -- ANA Gerente
(4, 13), -- LUIS Supervisor
(4, 14), -- MARIA Supervisor
(6, 15), -- SOFIA General con permisos
(6, 16), -- PEDRO General
(6, 17), -- LAURA General
(6, 18), -- FERNANDO General
(6, 19), -- DIANA General
(6, 20); -- RICARDO General


Select * from UserTable
--id user


---CASO DE USO 1 
--Un rol "Supervisor" puede ver los empleados de su departamento, pero no los detalles de pagos.
---CASO DE USO 2
--Un rol "Gerente" puede ver tanto empleados como pagos, pero solo dentro de su área de supervisión.
---CASO DE USO 3
--daria gomez solo ver pagos

11 --CARLOS Gerente
12-- ANA Gerente
13 -- LUIS Supervisor
14 -- MARIA Supervisor
15 -- SOFIA General con permisos
16 -- PEDRO General

--EJECUCION DE SP

Exec[dbo].[permisoVisualizacionEmpleadosSP5] @id_usuario = 16

Exec[dbo].[permisoVisualizacionNominaSP] @id_usuario = 16