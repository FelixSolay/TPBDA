/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.

*/

use COM2900G09
go

--Insert Store Procedures 
--FACTURACION
CREATE OR ALTER PROCEDURE facturacion.InsertarPago
    @IdentificadorDePago VARCHAR(22),
    @Fecha DATETIME,
    @MedioDePago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Pago (IdentificadorDePago, Fecha, MedioDePago)
        VALUES (@IdentificadorDePago, @Fecha, @MedioDePago);
        
        COMMIT TRANSACTION;
        PRINT 'Pago insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarMedioDePago
    @Nombre VARCHAR(20),
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IdMedioDePago),0) FROM facturacion.MedioDePago);
    BEGIN TRY
        INSERT INTO facturacion.MedioDePago (Nombre, Descripcion)
        VALUES (@Nombre, @Descripcion);
        DBCC CHECKIDENT ('facturacion.MedioDePago', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'MedioDePago insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el MedioDePago: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('facturacion.MedioDePago', RESEED, @MaxID);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarCliente
    @DNI INT,
    @Nombre VARCHAR(25),
    @Apellido VARCHAR(25),
    @Genero CHAR(1),
    @IDTipoCliente INT
AS
BEGIN
    DECLARE @CUIL_G INT
    DECLARE @CUIL_N INT
    DECLARE @CUIL   INT

    -- Numero por genero
    IF @Genero = 'M'
    BEGIN
        SET @CUIL_G = 20
    END
    ELSE
    BEGIN
        SET @CUIL_G = 27
    END
    
    -- Numero de verificacion
    SET @CUIL_N = 11 - FLOOR( ( ( LEFT(CAST(@CUIL_G AS CHAR), 1) * 5 )          + ( RIGHT(CAST(@CUIL_G AS CHAR), 1) * 4 ) +
                                ( SUBSTRING(CAST(@DNI AS CHAR), 1, 1) * 3 )     + ( SUBSTRING(CAST(@DNI AS CHAR), 2, 1) * 2 )    + 
                                ( SUBSTRING(CAST(@DNI AS CHAR), 3, 1) * 7 )     + ( SUBSTRING(CAST(@DNI AS CHAR), 4, 1) * 6 )    + 
                                ( SUBSTRING(CAST(@DNI AS CHAR), 5, 1) * 5 )     + ( SUBSTRING(CAST(@DNI AS CHAR), 6, 1) * 4 )    + 
                                ( SUBSTRING(CAST(@DNI AS CHAR), 7, 1) * 3 )     + ( SUBSTRING(CAST(@DNI AS CHAR), 8, 1) * 2 )    )
                                / 11 ) -- SET @CUIL_N = SELECT FLOOR(RAND() * (9 - 1 + 1)) + 1;

    -- Armado de CUIL
    SET @CUIL = ( @CUIL_G * 1000000000 ) + ( @DNI * 10 ) + @CUIL_N

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Cliente (DNI, CUIL, Nombre, Apellido, Genero, IDTipoCliente)
        VALUES (@DNI, @CUIL, @Nombre, @Apellido, @Genero, @IDTipoCliente);        
        COMMIT TRANSACTION;
        PRINT 'Cliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarTipoCliente
    @Nombre VARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDTipoCliente),0) FROM facturacion.TipoCliente);
    BEGIN TRY
        INSERT INTO facturacion.TipoCliente (Nombre)
        VALUES (@Nombre);
        DBCC CHECKIDENT ('facturacion.TipoCliente', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'TipoCliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el TipoCliente: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('facturacion.TipoCliente', RESEED, @MaxID);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarLineaComprobante
    @ID         INT,
    @IdProducto INT,
    @Cantidad   INT,
    @Monto      DECIMAL(9,2)
AS
BEGIN
    DECLARE @ExCant INT

    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT *
                    FROM facturacion.comprobante 
                        WHERE ID = @ID 
                          AND Cerrado = 0 )
        BEGIN
            IF EXISTS (SELECT @ExCant = cantidad
                    FROM facturacion.LineaComprobante 
                        WHERE ID = @ID
                          AND IDProducto = @IdProducto )
            BEGIN
                UPDATE facturacion.LineaComprobante
                    SET Cantidad = @ExCant + @Cantidad
                        WHERE ID = @ID
                          AND IDProducto = @IDProducto
            END
            ELSE
            BEGIN
                INSERT INTO facturacion.LineaComprobante (ID, IdProducto, Cantidad, Monto)
                    VALUES (@ID, @IdProducto, @Cantidad, @Monto);
            END

            COMMIT TRANSACTION;
            PRINT 'Linea de Comprobante insertada correctamente.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Linea de Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.IniciarComprobante
    @Cliente  INT,
    @Empleado INT
AS
BEGIN
    DECLARE @ID INT

    BEGIN TRANSACTION
    BEGIN TRY
        INSERT INTO facturacion.Comprobante (Cliente, Empleado)
        VALUES (@Cliente, @Empleado);
        
        SELECT @ID = SCOPE_IDENTITY()
            FROM facturacion.Comprobante

        COMMIT TRANSACTION;
        PRINT 'Comprobante insertado correctamente.'

        RETURN @ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Comprobante: ' + ERROR_MESSAGE()
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarFactura -- SOLO SE EJECUTA DENTRO DE facturacion.CerrarComprobante. NO SE PUEDE LLAMAR POR SI SOLO
    @IDComprobante INT,
    @Importe DECIMAL(9,2)
AS
BEGIN
    DECLARE @NewFac CHAR(11)
    DECLARE @CUIL CHAR(13)
    DECLARE @chk BOOLEAN
    SET @chk = 1

    BEGIN TRY
        SELECT CUIL
            FROM facturacion.cliente

        WHILE @chk
        BEGIN
            SELECT @NewFac = CAST(FLOOR(RAND() * (99999999999 - 1000000000) + 1000000000) AS CHAR)
            IF NOT EXISTS (SELECT *
                            FROM facturacion.documento 
                                WHERE tipo = 'FC' 
                                  AND letra = 'A'
                                  AND numero = @NewFac)
            BEGIN
                SET @chk = 0
            END
        END

        SELECT @CUIL = CUIL
            FROM facturacion.cliente

        INSERT INTO facturacion.documento(Comprobante, tipo, letra, numero, Fecha, Hora, Importe, CUIL)
            VALUES (@IDComprobante, 'FC', 'C', @NewFac, GETDATE(), SELECT CONVERT(VARCHAR(10), GETDATE(), 108), @Importe, 
                    LEFT(@CUIL, 2) + '-' + SUBSTRING(@CUIL, 3, 8) + '-' + RIGHT(@CUIL, 1))
    END TRY
    BEGIN CATCH
        PRINT 'Error al intentar generar la factura A' + @NewFac + ': ' + ERROR_MESSAGE();
    END CATCH;
END
GO

--DEPOSITO

CREATE OR ALTER PROCEDURE deposito.InsertarCategoria
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDCategoria),0) FROM deposito.categoria);
    BEGIN TRY
        INSERT INTO deposito.Categoria (Descripcion)
        VALUES (@Descripcion);
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Categoria insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Categoria: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.InsertarProducto
    @Categoria INT,
    @Nombre VARCHAR(100),
    @Precio DECIMAL(9, 2),
    @PrecioReferencia DECIMAL(9, 2),
    @UnidadReferencia CHAR(2),
    @Fecha DATETIME
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDProducto),0) FROM deposito.producto);
    BEGIN TRY
        INSERT INTO deposito.Producto (Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
        VALUES (@Categoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia, @Fecha);
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Producto insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Producto: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID);
    END CATCH;
END;
GO

--INFRAESTRUCTURA
CREATE OR ALTER PROCEDURE infraestructura.InsertarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @DNI INT,
    @Direccion VARCHAR(100),
    @EmailPersonal VARCHAR(100),
    @EmailEmpresa VARCHAR(100),
    @CUIL CHAR(11),
    @Turno CHAR(16),
    @Cargo INT,
    @Sucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO infraestructura.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
        VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal);
        
        COMMIT TRANSACTION;
        PRINT 'Empleado insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.InsertarSucursal
    @Direccion VARCHAR(100),
    @Ciudad VARCHAR(20),
    @Horario CHAR(45),
    @Telefono CHAR(11)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDsucursal),0) FROM infraestructura.Sucursal);
    BEGIN TRY
        INSERT INTO infraestructura.Sucursal (Direccion, Ciudad, Horario, Telefono)
        VALUES (@Direccion, @Ciudad, @Horario, @Telefono);
        DBCC CHECKIDENT ('infraestructura.Sucursal', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Sucursal insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Sucursal: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('infraestructura.Sucursal', RESEED, @MaxID);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE infraestructura.InsertarCargo
    @Descripcion VARCHAR(25)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDcargo),0) FROM infraestructura.cargo);
    BEGIN TRY
        INSERT INTO infraestructura.Cargo (Descripcion)
        VALUES (@Descripcion);
        DBCC CHECKIDENT ('infraestructura.Cargo', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Cargo insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cargo: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('infraestructura.Cargo', RESEED, @MaxID);
    END CATCH;
END;
GO

--Delete Stored Procedures
--DEPOSITO
CREATE OR ALTER PROCEDURE deposito.EliminarProducto
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.producto WHERE IDProducto = @IDProducto)
        BEGIN
            DELETE FROM deposito.producto WHERE IDProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Producto eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Producto con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.EliminarCategoria
    @IDCategoria INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            DELETE FROM deposito.categoria WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Categoria con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO


--FACTURACION
CREATE OR ALTER PROCEDURE facturacion.EliminarLineaComprobante
    @ID INT,
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IDProducto)
        BEGIN
            DELETE FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Linea de Comprobante eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Linea de Comprobante con el ID y Producto especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Linea de Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarComprobante
    @ID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.comprobante WHERE ID = @ID)
        BEGIN
            DELETE FROM facturacion.comprobante WHERE ID = @ID;
            COMMIT TRANSACTION;
            PRINT 'Comprobante eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Comprobante con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarPago
    @IDPago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            DELETE FROM facturacion.Pago WHERE IDPago = @IDPago;
            COMMIT TRANSACTION;
            PRINT 'Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarMedioDePago
    @IDMedioDePago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            DELETE FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago;
            COMMIT TRANSACTION;
            PRINT 'Medio De Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Medio De Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Medio De Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarCliente
    @IDCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.cliente WHERE IDCliente = @IDCliente)
        BEGIN
            DELETE FROM facturacion.cliente WHERE IDCliente = @IDCliente;
            COMMIT TRANSACTION;
            PRINT 'Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarTipoCliente
    @IDTipoCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            DELETE FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente;
            COMMIT TRANSACTION;
            PRINT 'Tipo de Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Tipo de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--INFRAESTRUCTURA
CREATE OR ALTER PROCEDURE infraestructura.EliminarEmpleado
    @Legajo INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.empleado WHERE Legajo = @Legajo)
        BEGIN
            DELETE FROM infraestructura.empleado WHERE Legajo = @Legajo;
            COMMIT TRANSACTION;
            PRINT 'Empleado eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Empleado con el Legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarSucursal
    @IDsucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal)
        BEGIN
            DELETE FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Sucursal con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarCargo
    @IdCargo INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.cargo WHERE IdCargo = @IdCargo)
        BEGIN
            DELETE FROM infraestructura.cargo WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Cargo con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--Update Store procedures
--DEPOSITO
CREATE OR ALTER PROCEDURE deposito.ActualizarProducto
    @IDProducto INT,
    @Categoria INT = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia CHAR(2) = NULL,
    @Fecha DATETIME = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Producto WHERE IDProducto = @IDProducto)
        BEGIN
            UPDATE deposito.Producto
            SET Categoria = COALESCE(@Categoria, Categoria),
                Nombre = COALESCE(@Nombre, Nombre),
                Precio = COALESCE(@Precio, Precio),
                PrecioReferencia = COALESCE(@PrecioReferencia, PrecioReferencia),
                UnidadReferencia = COALESCE(@UnidadReferencia, UnidadReferencia),
                Fecha = COALESCE(@Fecha, Fecha)
            WHERE IDProducto = @IDProducto;            
            COMMIT TRANSACTION;
            PRINT 'Producto actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el producto con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.ActualizarCategoria
    @IDCategoria INT,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            UPDATE deposito.Categoria
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la categoria con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--INFRAESTRUCTURA
CREATE OR ALTER PROCEDURE infraestructura.ActualizarCargo
    @IdCargo INT,
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Cargo WHERE IdCargo = @IdCargo)
        BEGIN
            UPDATE infraestructura.Cargo
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el cargo con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarSucursal
    @IDSucursal INT,
    @Direccion VARCHAR(100) = NULL,
    @Ciudad VARCHAR(20) = NULL,
    @Horario CHAR(45) = NULL,
    @Telefono CHAR(11) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Sucursal WHERE IDSucursal = @IDSucursal)
        BEGIN
            UPDATE infraestructura.Sucursal
            SET Direccion = COALESCE(@Direccion, Direccion),
                Ciudad = COALESCE(@Ciudad, Ciudad),
                Horario = COALESCE(@Horario, Horario),
                Telefono = COALESCE(@Telefono, Telefono)
            WHERE IDSucursal = @IDSucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la sucursal con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(30) = NULL,
    @Apellido VARCHAR(30) = NULL,
    @DNI INT = NULL,
    @Direccion VARCHAR(100) = NULL,
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Turno CHAR(16) = NULL,
    @Cargo INT = NULL,
    @Sucursal INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Empleado WHERE Legajo = @Legajo)
        BEGIN
            UPDATE infraestructura.Empleado
            SET Nombre = COALESCE(@Nombre, Nombre),
                Apellido = COALESCE(@Apellido, Apellido),
                DNI = COALESCE(@DNI, DNI),
                Direccion = COALESCE(@Direccion, Direccion),
                EmailPersonal = COALESCE(@EmailPersonal, EmailPersonal),
                EmailEmpresa = COALESCE(@EmailEmpresa, EmailEmpresa),
                CUIL = COALESCE(@CUIL, CUIL),
                Turno = COALESCE(@Turno, Turno),
                Cargo = COALESCE(@Cargo, Cargo),
                Sucursal = COALESCE(@Sucursal, Sucursal)
            WHERE Legajo = @Legajo;
            COMMIT TRANSACTION;
            PRINT 'Empleado actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el empleado con el legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--FACTURACION
CREATE OR ALTER PROCEDURE facturacion.ActualizarLineaComprobante
    @ID INT,
    @IdProducto INT,
    @Cantidad INT = NULL,
    @Monto DECIMAL(9,2) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IdProducto)
        BEGIN
            UPDATE facturacion.LineaComprobante
            SET Cantidad = COALESCE(@Cantidad, Cantidad),
                Monto = COALESCE(@Monto, Monto)
            WHERE ID = @ID AND IdProducto = @IdProducto;
            COMMIT TRANSACTION;
            PRINT 'Linea de comprobante actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la linea de comprobante con los Ids especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la linea de comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.CerrarComprobante
    @ID INT,
AS
BEGIN
    DECLARE @Total DECIMAL(9,2)

    SELECT @Total = SUM(Importe)
        from (SELECT IDProducto, Cantidad * Monto AS Importe
                FROM facturacion.LineaComprobante)

    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Comprobante WHERE ID = @ID)
        BEGIN
            UPDATE facturacion.Comprobante
                SET Total   = COALESCE(@Total, Total),
                SET Cerrado = COALESCE(1, Cerrado)
            WHERE ID = @ID;

            -- llamar SP de creacion de factura

            COMMIT TRANSACTION;
            PRINT 'Comprobante actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el comprobante con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarPago
    @IDPago INT,
    @IdentificadorDePago VARCHAR(22) = NULL,
    @Fecha DATETIME = NULL,
    @MedioDePago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            UPDATE facturacion.Pago
            SET IdentificadorDePago = COALESCE(@IdentificadorDePago, IdentificadorDePago),
                Fecha = COALESCE(@Fecha, Fecha),
                MedioDePago = COALESCE(@MedioDePago, MedioDePago)
            WHERE IDPago = @IDPago;
            COMMIT TRANSACTION;
            PRINT 'Pago actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el pago con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarMedioDePago
    @IDMedioDePago INT,
    @Nombre VARCHAR(20) = NULL,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            UPDATE facturacion.MedioDePago
            SET Nombre = COALESCE(@Nombre, Nombre),
                Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDMedioDePago = @IDMedioDePago;
            
            COMMIT TRANSACTION;
            PRINT 'Medio de pago actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el medio de pago con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el medio de pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarCliente
    @IDCliente INT,
    @DNI INT = NULL,
    @Nombre VARCHAR(25) = NULL,
    @Apellido VARCHAR(25) = NULL,
    @Genero CHAR(1) = NULL,
    @IDTipoCliente INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Cliente WHERE IDCliente = @IDCliente)
        BEGIN
            UPDATE facturacion.Cliente
            SET DNI = COALESCE(@DNI, DNI),
                Nombre = COALESCE(@Nombre, Nombre),
                Apellido = COALESCE(@Apellido, Apellido),
                Genero = COALESCE(@Genero, Genero),
                IDTipoCliente = COALESCE(@IDTipoCliente, IDTipoCliente)
            WHERE IDCliente = @IDCliente;
            COMMIT TRANSACTION;
            PRINT 'Cliente actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el cliente con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarTipoCliente
    @IDTipoCliente INT,
    @Nombre VARCHAR(20) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            UPDATE facturacion.TipoCliente
            SET Nombre = COALESCE(@Nombre, Nombre)
            WHERE IDTipoCliente = @IDTipoCliente;
            
            COMMIT TRANSACTION;
            PRINT 'Tipo de cliente actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el tipo de cliente con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el tipo de cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO