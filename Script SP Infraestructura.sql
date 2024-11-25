/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
*/

use COM2900G09
go

-------------------- EMPLEADO -----------------------------------------

CREATE OR ALTER PROCEDURE infraestructura.InsertarEmpleado
    @Legajo        INT,
    @Nombre        VARCHAR(30),
    @Apellido      VARCHAR(30),
    @DNI           INT,
    @Direccion     VARCHAR(100),
    @EmailPersonal VARCHAR(100),
    @EmailEmpresa  VARCHAR(100),
    @CUIL          CHAR(11),
    @Turno         CHAR(16),
    @Cargo         INT,
    @Sucursal      INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el Empleado: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF @CUIL IS NULL OR @CUIL = '' 
            SET @CUIL = '00000000000'; -- CUIL por defecto (11 ceros)
        
        INSERT INTO infraestructura.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
            VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal)
        COMMIT TRANSACTION
        PRINT 'Empleado insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH    
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarEmpleado
    @Legajo		   INT,
    @Nombre		   VARCHAR(30)  = NULL,
    @Apellido	   VARCHAR(30)  = NULL,
    @DNI		   INT		    = NULL,
    @Direccion	   VARCHAR(100) = NULL,
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa  VARCHAR(100) = NULL,
    @CUIL		   CHAR(11)		= NULL,
    @Turno		   CHAR(16)		= NULL,
    @Cargo		   INT			= NULL,
    @Sucursal	   INT			= NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Empleado: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Empleado WHERE Legajo = @Legajo)
        BEGIN
            UPDATE infraestructura.Empleado
				SET Nombre		  = COALESCE(@Nombre, Nombre),
					Apellido	  = COALESCE(@Apellido, Apellido),
					DNI			  = COALESCE(@DNI, DNI),
					Direccion	  = COALESCE(@Direccion, Direccion),
					EmailPersonal = COALESCE(@EmailPersonal, EmailPersonal),
					EmailEmpresa  = COALESCE(@EmailEmpresa, EmailEmpresa),
					CUIL		  = COALESCE(@CUIL, CUIL),
					Turno		  = COALESCE(@Turno, Turno),
					Cargo		  = COALESCE(@Cargo, Cargo),
					Sucursal	  = COALESCE(@Sucursal, Sucursal)
					WHERE Legajo = @Legajo

	        COMMIT TRANSACTION            
            PRINT 'Empleado actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró el empleado con Legajo:' + CAST(@Legajo as char)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarEmpleado
    @Legajo INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Empleado: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.empleado WHERE Legajo = @Legajo)
        BEGIN
            DELETE FROM infraestructura.empleado 
                WHERE Legajo = @Legajo
            COMMIT TRANSACTION
            PRINT 'Empleado eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró el empleado con Legajo:' + CAST(@Legajo as char)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

-------------------- CARGO --------------------------------------

CREATE OR ALTER PROCEDURE infraestructura.InsertarCargo
    @Descripcion VARCHAR(25)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el Cargo: '
    BEGIN TRANSACTION

	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IDcargo),0) FROM infraestructura.cargo)
    BEGIN TRY
        INSERT INTO infraestructura.Cargo (Descripcion)
            VALUES (@Descripcion)
        COMMIT TRANSACTION
        PRINT 'Cargo insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DBCC CHECKIDENT ('infraestructura.Cargo', RESEED, @MaxID)
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH    
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarCargo
    @IdCargo     INT,
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Cargo: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Cargo WHERE IdCargo = @IdCargo)
        BEGIN
            UPDATE infraestructura.Cargo
                SET Descripcion = COALESCE(@Descripcion, Descripcion)
    				WHERE IdCargo = @IdCargo
            COMMIT TRANSACTION
            PRINT 'Cargo actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró el registro de cargo con ID:' + CAST(@IDcargo as char)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarCargo
    @IdCargo INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar el Cargo: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.cargo WHERE IdCargo = @IdCargo)
        BEGIN
            DELETE FROM infraestructura.cargo WHERE IdCargo = @IdCargo
            COMMIT TRANSACTION
            PRINT 'Cargo eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró el registro de cargo con ID:' + CAST(@IDcargo as char)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

-------------------- SUCURSAL ---------------------------------------------

CREATE OR ALTER PROCEDURE infraestructura.InsertarSucursal
    @Direccion VARCHAR(100),
    @Ciudad    VARCHAR(20),
    @Horario   CHAR(45),
    @Telefono  CHAR(11)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar la Sucursal: '
    BEGIN TRANSACTION

	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IDsucursal),0) FROM infraestructura.Sucursal)

    BEGIN TRY
        INSERT INTO infraestructura.Sucursal (Direccion, Ciudad, Horario, Telefono)
            VALUES (@Direccion, @Ciudad, @Horario, @Telefono)
        PRINT 'Sucursal insertada correctamente.'
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DBCC CHECKIDENT ('infraestructura.Sucursal', RESEED, @MaxID)
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarSucursal
    @IDSucursal INT,
    @Direccion  VARCHAR(100) = NULL,
    @Ciudad		VARCHAR(20)  = NULL,
    @Horario	CHAR(45)     = NULL,
    @Telefono	CHAR(11)     = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar la Sucursal: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Sucursal WHERE IDSucursal = @IDSucursal)
        BEGIN
            UPDATE infraestructura.Sucursal
                SET Direccion = COALESCE(@Direccion, Direccion),
                    Ciudad	  = COALESCE(@Ciudad, Ciudad),
                    Horario	  = COALESCE(@Horario, Horario),
                    Telefono  = COALESCE(@Telefono, Telefono)
                    WHERE IDSucursal = @IDSucursal
            COMMIT TRANSACTION
            PRINT 'Sucursal actualizada correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró la sucursal con ID:' + CAST(@IDsucursal AS CHAR)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarSucursal
    @IDsucursal INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar la Sucursal: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal)
        BEGIN
            DELETE FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal
            COMMIT TRANSACTION
            PRINT 'Sucursal eliminada correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontró la sucursal con ID:' + CAST(@IDsucursal AS CHAR)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO