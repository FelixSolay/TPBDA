/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
*/

use COM2900G09
go

-------------------- INSERTS --------------------

CREATE OR ALTER PROCEDURE facturacion.InsertarPago
	@Factura			 INT,
    @IdentificadorDePago VARCHAR(22),
    @MedioDePago		 INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Pago (factura, IdentificadorDePago, Fecha, MedioDePago)
        VALUES (@Factura, @IdentificadorDePago, GETDATE(), @MedioDePago);
        
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

CREATE OR ALTER PROCEDURE facturacion.InsertarLineaVenta
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
                    FROM facturacion.Venta 
                        WHERE ID = @ID 
                          AND Cerrado = 0 )
        BEGIN
			SELECT @ExCant = cantidad
                    FROM facturacion.LineaVenta
                        WHERE ID = @ID
                          AND IDProducto = @IdProducto

            IF ( @ExCant <> '' )
            BEGIN
                UPDATE facturacion.LineaVenta
                    SET Cantidad = @ExCant + @Cantidad
                        WHERE ID = @ID
                          AND IDProducto = @IDProducto
            END
            ELSE
            BEGIN
                INSERT INTO facturacion.LineaVenta (ID, IdProducto, Cantidad, Monto)
                    VALUES (@ID, @IdProducto, @Cantidad, @Monto);
            END

            COMMIT TRANSACTION;
            PRINT 'Linea de Venta insertada correctamente.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Linea de Venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.IniciarVenta
    @Cliente  INT,
    @Empleado INT
AS
BEGIN
    DECLARE @ID INT

    BEGIN TRANSACTION
    BEGIN TRY
        INSERT INTO facturacion.Venta (Cliente, Empleado)
        VALUES (@Cliente, @Empleado);
        
        SELECT @ID = SCOPE_IDENTITY()
            FROM facturacion.Venta

        COMMIT TRANSACTION;
        PRINT 'Venta insertado correctamente.'

        RETURN @ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Venta: ' + ERROR_MESSAGE()
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarFactura -- SOLO SE EJECUTA DENTRO DE facturacion.CerrarVenta. NO SE PUEDE LLAMAR POR SI SOLO
    @IDVenta INT,
    @Importe DECIMAL(9,2)
AS
BEGIN
    DECLARE @NewFac CHAR(11)
    DECLARE @CUIL CHAR(13)
    DECLARE @chk BIT
    SET @chk = 1

    BEGIN TRY
        SELECT CUIL
            FROM facturacion.cliente

        WHILE @chk = 1
        BEGIN
            SELECT @NewFac = CAST(FLOOR(RAND() * (99999999999 - 1000000000) + 1000000000) AS CHAR)
            IF NOT EXISTS (SELECT *
                            FROM facturacion.factura 
                                WHERE letra = 'A'
                                  AND numero = @NewFac)
            BEGIN
                SET @chk = 0
            END
        END

        SELECT @CUIL = CUIL
            FROM facturacion.cliente

        INSERT INTO facturacion.factura(Venta, letra, numero, Fecha, Hora, MontoIVA, MontoNeto, MontoBruto, CUIL)
            VALUES (@IDVenta, 'C', @NewFac, GETDATE(), CONVERT(VARCHAR(10), GETDATE(), 108), 
					@Importe, @Importe * 0.21, @Importe * 1.21,
                    LEFT(@CUIL, 2) + '-' + SUBSTRING(@CUIL, 3, 8) + '-' + RIGHT(@CUIL, 1))
    END TRY
    BEGIN CATCH
        PRINT 'Error al intentar generar la factura A' + @NewFac + ': ' + ERROR_MESSAGE();
    END CATCH;
END
GO

-------------------- DELETES --------------------

CREATE OR ALTER PROCEDURE facturacion.EliminarLineaVenta
    @ID INT,
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaVenta WHERE ID = @ID AND IdProducto = @IDProducto)
        BEGIN
            DELETE FROM facturacion.lineaVenta WHERE ID = @ID AND IdProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Linea de Venta eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Linea de Venta con el ID y Producto especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Linea de Venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarVenta
    @ID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Venta WHERE ID = @ID)
        BEGIN
            DELETE FROM facturacion.Venta WHERE ID = @ID;
            COMMIT TRANSACTION;
            PRINT 'Venta eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Venta con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Venta: ' + ERROR_MESSAGE();
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

-------------------- UPDATES --------------------

CREATE OR ALTER PROCEDURE facturacion.ActualizarLineaVenta
    @ID INT,
    @IdProducto INT,
    @Cantidad INT = NULL,
    @Monto DECIMAL(9,2) = NULL
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaVenta WHERE ID = @ID AND IdProducto = @IdProducto)
        BEGIN
            UPDATE facturacion.LineaVenta
				SET Cantidad = COALESCE(@Cantidad, Cantidad),
					Monto	 = COALESCE(@Monto, Monto)
					WHERE ID = @ID AND IdProducto = @IdProducto;

            COMMIT TRANSACTION;
            PRINT 'Linea de Venta actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la linea de Venta con los Ids especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la linea de Venta: ' + ERROR_MESSAGE();
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
    @IDCliente	   INT,
    @DNI		   INT		   = NULL,
    @Nombre		   VARCHAR(25) = NULL,
    @Apellido	   VARCHAR(25) = NULL,
    @Genero		   CHAR(1)	   = NULL,
    @IDTipoCliente INT		   = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Cliente WHERE IDCliente = @IDCliente)
        BEGIN
            UPDATE facturacion.Cliente
                SET DNI			  = COALESCE(@DNI, DNI),
                    Nombre		  = COALESCE(@Nombre, Nombre),
                    Apellido	  = COALESCE(@Apellido, Apellido),
                    Genero		  = COALESCE(@Genero, Genero),
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

CREATE OR ALTER PROCEDURE facturacion.CerrarVenta
    @ID INT
AS
BEGIN
    DECLARE @MontoNeto DECIMAL(9,2)

    SELECT @MontoNeto = SUM(Importe)
        from (SELECT IDProducto, Cantidad * Monto AS Importe
                FROM facturacion.LineaVenta
					WHERE ID = @ID) AS a

    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Venta WHERE ID = @ID)
        BEGIN
            UPDATE facturacion.Venta
                SET MontoNeto   = COALESCE(@MontoNeto, MontoNeto),
					Cerrado = 1
					WHERE ID = @ID;

            EXEC facturacion.GenerarFactura @IDVenta = @ID, @Importe = @MontoNeto

            COMMIT TRANSACTION;
            PRINT 'Venta actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el Venta con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el Venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO