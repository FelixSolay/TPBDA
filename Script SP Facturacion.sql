/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
*/

use COM2900G09
go

-------------------- Datos de Facturacion -------------------

CREATE OR ALTER PROCEDURE facturacion.ConfigurarDatosFacturacion
    @CUIT char(11),
    @FechaInicio datetime,
    @RazonSocial varchar(100)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al configurar los datos de facturación: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.DatosFacturacion WHERE ID = 1)
        BEGIN
            UPDATE facturacion.DatosFacturacion
            SET CUIT = @CUIT,
                FechaInicio = @FechaInicio,
                RazonSocial = @RazonSocial
            WHERE ID = 1
            PRINT 'Datos de facturación actualizados.'
        END
        ELSE
        BEGIN
            INSERT INTO facturacion.DatosFacturacion (CUIT, FechaInicio, RazonSocial)
            VALUES (@CUIT, @FechaInicio, @RazonSocial)
            PRINT 'Datos de facturación configurados por primera vez.'
        END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE facturacion.ObtenerDatosFacturacion
AS
BEGIN
    SELECT CUIT, FechaInicio, RazonSocial
    FROM facturacion.DatosFacturacion
    WHERE ID = 1
END
GO

-------------------- TIPO DE CLIENTE --------------------


CREATE OR ALTER PROCEDURE facturacion.InsertarTipoCliente
    @Nombre VARCHAR(20)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar insertar el TipoCliente: '
    BEGIN TRANSACTION
	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IDTipoCliente),0) FROM facturacion.TipoCliente)
    BEGIN TRY
        INSERT INTO facturacion.TipoCliente (Nombre)
            VALUES (@Nombre)
        COMMIT TRANSACTION
        PRINT 'TipoCliente insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		DBCC CHECKIDENT ('facturacion.TipoCliente', RESEED, @MaxID)
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarTipoCliente
    @IDTipoCliente INT,
    @Nombre        VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar actualizar el tipo de cliente: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            UPDATE facturacion.TipoCliente
				SET Nombre = COALESCE(@Nombre, Nombre)
					WHERE IDTipoCliente = @IDTipoCliente
            COMMIT TRANSACTION            
            PRINT 'Tipo de cliente actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el tipo de cliente con el Id: ' + cast(@IDTipoCliente as char)
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

CREATE OR ALTER PROCEDURE facturacion.EliminarTipoCliente
    @IDTipoCliente INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar eliminar el tipo de cliente: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            DELETE FROM facturacion.TipoCliente 
                WHERE IDTipoCliente = @IDTipoCliente
            PRINT 'Tipo de Cliente eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el tipo de cliente con el Id: ' + cast(@IDTipoCliente as char)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO

-------------------- CLIENTE --------------------

CREATE OR ALTER PROCEDURE facturacion.InsertarCliente
    @DNI           INT,
    @Nombre        VARCHAR(25),
    @Apellido      VARCHAR(25),
    @Genero        CHAR(1),
    @IDTipoCliente INT
AS
BEGIN
    DECLARE @CUIL_G INT;
    DECLARE @CUIL_N INT;
    DECLARE @CUIL   BIGINT;
    DECLARE @CUIL_FINAL CHAR(11);
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el cliente: '
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Número por género
        SET @CUIL_G = CASE 
                        WHEN @Genero = 'M' THEN 20 
                        ELSE 27 
                      END;

        -- Calcular número de verificación
        SET @CUIL_N = 11 - (
            (LEFT(CAST(@CUIL_G AS CHAR(2)), 1) * 5) +
            (RIGHT(CAST(@CUIL_G AS CHAR(2)), 1) * 4) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 1, 1) * 3) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 2, 1) * 2) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 3, 1) * 7) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 4, 1) * 6) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 5, 1) * 5) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 6, 1) * 4) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 7, 1) * 3) +
            (SUBSTRING(CAST(@DNI AS CHAR(8)), 8, 1) * 2)
        ) % 11;

        -- Ajustar número de verificación en caso de valores fuera de rango
        IF @CUIL_N = 10 SET @CUIL_N = 0;

        -- Armado de CUIL
        SET @CUIL = (@CUIL_G * 1000000000) + (@DNI * 10) + @CUIL_N;
        SET @CUIL_FINAL = CAST(@CUIL AS CHAR(11));

        -- Insertar cliente
        INSERT INTO facturacion.Cliente (DNI, CUIL, Nombre, Apellido, Genero, IDTipoCliente)
        VALUES (@DNI, @CUIL_FINAL, @Nombre, @Apellido, @Genero, @IDTipoCliente);

        COMMIT TRANSACTION;
        PRINT 'Cliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
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
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el cliente: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Cliente WHERE IDCliente = @IDCliente)
        BEGIN
            UPDATE facturacion.Cliente
                SET DNI			  = COALESCE(@DNI, DNI),
                    Nombre		  = COALESCE(@Nombre, Nombre),
                    Apellido	  = COALESCE(@Apellido, Apellido),
                    Genero		  = COALESCE(@Genero, Genero),
                    IDTipoCliente = COALESCE(@IDTipoCliente, IDTipoCliente)
                        WHERE IDCliente = @IDCliente

            PRINT 'Cliente actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error +  'No se encontro el cliente con el Id: ' + cast(@IDCliente AS CHAR)
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

CREATE OR ALTER PROCEDURE facturacion.EliminarCliente
    @IDCliente INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar el cliente: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.cliente WHERE IDCliente = @IDCliente)
        BEGIN
            DELETE FROM facturacion.cliente 
                WHERE IDCliente = @IDCliente
            COMMIT TRANSACTION    
            PRINT 'Cliente eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error +  'No se encontro el cliente con el Id: ' + cast(@IDCliente AS CHAR)
            RAISERROR(@error, 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO

-------------------- FACTURA --------------------

CREATE OR ALTER PROCEDURE facturacion.GenerarFactura
    @Letra CHAR(1),
    @Importe DECIMAL(9,2),
    @Factura INT OUTPUT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Generar la Factura: '
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @NewFac CHAR(11)
        IF @Letra = 'A'
            SET @NewFac = CAST(NEXT VALUE FOR FacturaASeq AS CHAR) --toma el próximo valor posible
        ELSE IF @Letra = 'B'
            SET @NewFac = CAST(NEXT VALUE FOR FacturaBSeq AS CHAR)--toma el próximo valor posible
        ELSE IF @letra = 'C'
            SET @NewFac = CAST(NEXT VALUE FOR FacturaCSeq AS CHAR)--toma el próximo valor posible (debería funcionar para A, B y C)
        INSERT INTO facturacion.factura (letra, numero, Fecha, Hora, MontoIVA, MontoNeto, MontoBruto)
        VALUES (@Letra, @NewFac, GETDATE(), CONVERT(VARCHAR(10), GETDATE(), 108), 
                @Importe * 0.21, @Importe, @Importe * 1.21)
        SET @Factura = SCOPE_IDENTITY()
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

-------------------- VENTA --------------------

CREATE OR ALTER PROCEDURE facturacion.IniciarVenta
    @Cliente  INT,
    @Empleado INT,
    @ID       INT OUTPUT
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = 'Error al intentar Iniciar la Venta: '
    BEGIN TRANSACTION

    BEGIN TRY
        INSERT INTO facturacion.Venta (Cliente, Empleado)
            VALUES (@Cliente, @Empleado)
        SELECT @ID = SCOPE_IDENTITY()
            FROM facturacion.Venta
        COMMIT TRANSACTION
        PRINT 'Venta insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
    
    RETURN @ID
END
GO

CREATE OR ALTER PROCEDURE facturacion.CerrarVenta
    @ID INT
AS
BEGIN
    DECLARE @MontoNeto DECIMAL(9,2)
	DECLARE @Factura INT
    DECLARE @Letr Char(1)
    DECLARE @IDCliente INT
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Cerrar la Venta: '
    BEGIN TRANSACTION
    BEGIN TRY
        --validación de existencia de venta
        IF NOT EXISTS (SELECT 1 FROM facturacion.Venta WHERE ID = @ID)
        BEGIN
            SET @error = @error + 'No se encontró la venta con el ID: ' + cast(@ID as CHAR)
		    RAISERROR(@error, 16, 1);
			RETURN
        END
        --Carga y validación de monto
        SELECT @MontoNeto = SUM(Cantidad * Monto)
        FROM facturacion.LineaVenta
        WHERE ID = @ID;
        IF @MontoNeto IS NULL OR @MontoNeto <= 0
        BEGIN
            SET @error = @error + 'El importe de la venta debe ser mayor a cero.'
            RAISERROR(@error, 16, 1);
			RETURN
        END   
        --tomo el DNI para determinar factura A o B
        SELECT @IDCliente = Cliente FROM facturacion.venta WHERE ID = @ID 
        SELECT @Letr = CASE WHEN c.DNI IS NOT NULL THEN 'A' ELSE 'B' END
            FROM facturacion.Cliente AS c
            WHERE c.IDCliente = @IDCliente;        
        --genero la factura
        EXEC facturacion.GenerarFactura @Letra=@Letr, 
            @Importe = @MontoNeto, 
            @Factura = @Factura OUTPUT
        --actualizo la venta con el número de factura y el monto
        UPDATE facturacion.Venta
            SET IDFactura = COALESCE(@Factura, IDFactura),
                MontoNeto = COALESCE(@MontoNeto, MontoNeto),
                Cerrado   = 1
                WHERE ID  = @ID
        PRINT 'Venta actualizada correctamente, La factura ha sido generada.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarVenta
    @ID INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar la Venta: '
    BEGIN TRANSACTION
    BEGIN TRY
        -- Verificar que exista la venta
        IF EXISTS (SELECT 1 FROM facturacion.Venta WHERE ID = @ID)
        BEGIN
            -- Validar que la venta no tenga una factura asignada
            IF EXISTS (SELECT 1 
                       FROM facturacion.Venta 
                       WHERE ID = @ID AND IDFactura IS NULL)
            BEGIN
                DELETE FROM facturacion.Venta
                WHERE ID = @ID;
                PRINT 'Venta eliminada correctamente.';
            END
            ELSE
            BEGIN
                SET @error = @error + 'No se puede eliminar la venta porque tiene una factura asignada.'
                RAISERROR(@error, 16, 1);
            END
        END
        ELSE
        BEGIN
            SET @error = @error +  'No se encontró el registro de venta con el ID: ' + cast(@ID as CHAR)
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END;
GO
-------------------- LINEA DE VENTA --------------------

CREATE OR ALTER PROCEDURE facturacion.InsertarLineaVenta
    @ID         INT,
    @IdProducto INT,
    @Cantidad   INT,
    @Monto      DECIMAL(9,2)
AS
BEGIN
    DECLARE @ExCant INT
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar la Linea de Venta: '
    BEGIN TRANSACTION
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
                    VALUES (@ID, @IdProducto, @Cantidad, @Monto)
            END
            COMMIT TRANSACTION
            PRINT 'Linea de Venta insertada correctamente.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarLineaVenta
    @ID         INT,
    @IdProducto INT,
    @Cantidad   INT = NULL,
    @Monto      DECIMAL(9,2) = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar la Linea de Venta: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaVenta WHERE ID = @ID AND IdProducto = @IdProducto)
        BEGIN
            UPDATE facturacion.LineaVenta
				SET Cantidad = COALESCE(@Cantidad, Cantidad),
					Monto	 = COALESCE(@Monto, Monto)
					WHERE ID = @ID AND IdProducto = @IdProducto
            COMMIT TRANSACTION
            PRINT 'Linea de Venta actualizada correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro la linea de Venta con los Ids especificados.'
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

CREATE OR ALTER PROCEDURE facturacion.EliminarLineaVenta
    @ID         INT,
    @IDProducto INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar la Linea de Venta: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaVenta WHERE ID = @ID AND IdProducto = @IDProducto)
        BEGIN
            DELETE FROM facturacion.lineaVenta 
                WHERE ID         = @ID
                  AND IdProducto = @IDProducto
            COMMIT TRANSACTION
            PRINT 'Linea de Venta eliminada correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el registro de Linea de Venta con el ID y Producto especificados.'
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

-------------------- MEDIO DE PAGO --------------------

CREATE OR ALTER PROCEDURE facturacion.InsertarMedioDePago
    @Nombre      VARCHAR(20),
    @Descripcion VARCHAR(50)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el Medio De Pago: '
    BEGIN TRANSACTION
	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IdMedioDePago),0) FROM facturacion.MedioDePago)

    BEGIN TRY
        INSERT INTO facturacion.MedioDePago (Nombre, Descripcion)
            VALUES (@Nombre, @Descripcion)
        COMMIT TRANSACTION
        PRINT 'Medio De Pago insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DBCC CHECKIDENT ('facturacion.MedioDePago', RESEED, @MaxID)
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH    
END
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarMedioDePago
    @IDMedioDePago INT,
    @Nombre        VARCHAR(20) = NULL,
    @Descripcion   VARCHAR(50) = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Medio De Pago: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            UPDATE facturacion.MedioDePago
                SET Nombre      = COALESCE(@Nombre, Nombre),
                    Descripcion = COALESCE(@Descripcion, Descripcion)
                    WHERE IDMedioDePago = @IDMedioDePago
            COMMIT TRANSACTION                    
            PRINT 'Medio de pago actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el medio de pago con el Id: ' + CAST(@IdMedioDePago as CHAR)
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

CREATE OR ALTER PROCEDURE facturacion.EliminarMedioDePago
    @IDMedioDePago INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar el Medio De Pago: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            DELETE FROM facturacion.MedioDePago 
                WHERE IDMedioDePago = @IDMedioDePago
            COMMIT TRANSACTION            
            PRINT 'Medio De Pago eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el medio de pago con el Id: ' + CAST(@IdMedioDePago as CHAR)
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

-------------------- PAGO --------------------


CREATE OR ALTER PROCEDURE facturacion.InsertarPago
	@Factura			 INT,
    @IdentificadorDePago VARCHAR(22),
    @MedioDePago		 INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el Pago: '
    BEGIN TRANSACTION

    BEGIN TRY
        INSERT INTO facturacion.Pago (factura, IdentificadorDePago, Fecha, MedioDePago)
            VALUES (@Factura, @IdentificadorDePago, GETDATE(), @MedioDePago)
        COMMIT TRANSACTION
        PRINT 'Pago insertado correctamente.'

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarPago
    @IDPago              INT,
    @IdentificadorDePago VARCHAR(22) = NULL,
    @Fecha               DATETIME = NULL,
    @MedioDePago         INT = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Pago: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            UPDATE facturacion.Pago
                SET IdentificadorDePago = COALESCE(@IdentificadorDePago, IdentificadorDePago),
                    Fecha               = COALESCE(@Fecha, Fecha),
                    MedioDePago         = COALESCE(@MedioDePago, MedioDePago)
                    WHERE IDPago = @IDPago
            COMMIT TRANSACTION            
            PRINT 'Pago actualizado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el pago con el Id: ' + CAST(@IDPago as CHAR)
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

CREATE OR ALTER PROCEDURE facturacion.EliminarPago
    @IDPago INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Pago: '
    BEGIN TRANSACTION
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            DELETE FROM facturacion.Pago 
                WHERE IDPago = @IDPago
            COMMIT TRANSACTION            
            PRINT 'Pago eliminado correctamente.'
        END
        ELSE
        BEGIN
            SET @error = @error + 'No se encontro el pago con el Id: ' + CAST(@IDPago as CHAR)
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


/*
-------------------- FACTURA --------------------

CREATE OR ALTER PROCEDURE facturacion.GenerarFactura -- SOLO SE EJECUTA DENTRO DE facturacion.CerrarVenta. NO SE PUEDE LLAMAR POR SI SOLO
    @Importe DECIMAL(9,2),
	@Factura INT OUTPUT
AS
BEGIN
    DECLARE @NewFac CHAR(11)
    DECLARE @CUIL	CHAR(13)
    DECLARE @chk	BIT
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

        INSERT INTO facturacion.factura(letra, numero, Fecha, Hora, MontoIVA, MontoNeto, MontoBruto, CUIL)
            VALUES ('C', @NewFac, GETDATE(), CONVERT(VARCHAR(10), GETDATE(), 108), 
					@Importe, @Importe * 0.21, @Importe * 1.21,
                    LEFT(@CUIL, 2) + '-' + SUBSTRING(@CUIL, 3, 8) + '-' + RIGHT(@CUIL, 1))

		SELECT @Factura = SCOPE_IDENTITY()
			FROM facturacion.factura
    END TRY
    BEGIN CATCH
        PRINT 'Error al intentar generar la factura A' + @NewFac + ': ' + ERROR_MESSAGE()
    END CATCH

	RETURN @Factura
END
GO
*/


