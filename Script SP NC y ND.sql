USE COM2900G09
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaCredito
    @ComprobanteID INT,                -- ID de la factura original
	@EmpleadoID INT,                   -- ID del empleado que genera la nota
    --@Motivo VARCHAR(255),             -- no lo estamos usando
    @MontoCredito DECIMAL(9, 2),       
    @DevolucionProducto BIT = 0,        -- 0: Devolución monetaria, 1: Devolucion de producto
	@IdProductoDevolucion INT = NULL 
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        --si tiene pago asociado
        DECLARE @IDPago INT;
        SELECT @IDPago = Pago
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        IF @IDPago IS NULL
        BEGIN
            PRINT 'Error: La nota de crédito solo se puede emitir para facturas pagadas.';
            ROLLBACK TRANSACTION;
            RETURN;
        END


        DECLARE @TotalVenta DECIMAL(9, 2);
        SELECT @TotalVenta = Total FROM facturacion.comprobante WHERE ID = @ComprobanteID;

        IF @MontoCredito > @TotalVenta
        BEGIN
            PRINT 'Error: El monto de la nota de crédito no puede exceder el total de la venta.';
            ROLLBACK TRANSACTION;
            RETURN;
        END


		-- sacamos datos de la factura original
        DECLARE @ClienteID INT, @Letra CHAR(1);
        SELECT @ClienteID = Cliente, @Letra = Letra
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        -- para generar el numero correspondiente de la Factura NC
        DECLARE @NuevoNumero CHAR(11);
        SELECT @NuevoNumero = RIGHT('0000000000' + CAST(ISNULL(MAX(CAST(numero AS INT)) + 1, 1) AS VARCHAR), 11)
        FROM facturacion.comprobante
        WHERE tipo = 'NC';

        -- Insertar el nuevo comprobante de tipo 'NC' utilizando el SP InsertarComprobante
        DECLARE @Fecha DATETIME = GETDATE();
        EXEC facturacion.InsertarComprobante    --- no se si falta agregar lo de la hora en este SP  -- seria asi: CONVERT(TIME, GETDATE())
            @tipo = 'NC',
            @numero = @NuevoNumero,
            @letra = @Letra,
            @Fecha = @Fecha,
            @Total = @MontoCredito,
            @Cliente = @ClienteID,
            @Empleado = @EmpleadoID,
            @Pago = @IDPago;

        DECLARE @NotaCreditoID INT = SCOPE_IDENTITY();

		 -- Registrar el detalle de la nota de crédito en forma de producto específico de la misma categoría
        IF @DevolucionProducto = 1
        BEGIN
            DECLARE @PrecioProducto DECIMAL(9, 2), @IdCategoriaOriginal INT, @IdCategoriaProducto INT;
            DECLARE @Cantidad INT = 0, @MontoTotal DECIMAL(9,2) = 0;

            
            SELECT TOP 1 @IdCategoriaOriginal = p.categoria
            FROM facturacion.lineaComprobante lc
            JOIN deposito.producto p ON lc.IdProducto = p.IDProducto
            WHERE lc.ID = @ComprobanteID;

           
            SELECT @PrecioProducto = Precio, @IdCategoriaProducto = categoria
            FROM deposito.producto
            WHERE IDProducto = @IdProductoDevolucion;

            IF @IdCategoriaProducto IS NULL OR @IdCategoriaProducto <> @IdCategoriaOriginal
            BEGIN
                PRINT 'Error: El producto seleccionado para la nota de credito no pertenece a la misma categoria que el producto original.';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Calculo la cantidad de productos
            WHILE @MontoTotal + @PrecioProducto <= @MontoCredito
            BEGIN
                SET @MontoTotal = @MontoTotal + @PrecioProducto;
                SET @Cantidad = @Cantidad + 1;
            END

            EXEC facturacion.InsertarLineaComprobante
                @ID = @NotaCreditoID,
                @IdProducto = @IdProductoDevolucion,
                @Cantidad = @Cantidad,
                @Monto = @MontoTotal;

            PRINT 'Nota de credito generada con devolución de producto específico de la misma categoria.';
        END
        ELSE
        BEGIN
            -- Devolución monetaria
			EXEC facturacion.InsertarLineaComprobante
                @ID = @NotaCreditoID,
                @IdProducto = NULL,           -- No se asocia a ningún producto específico
                @Cantidad = 1,                -- Cantidad establecida en 1
                @Monto = @MontoCredito;     

            PRINT 'Nota de crédito generada como devolución monetaria.';
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de crédito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.GenerarNotaDebito
    @ComprobanteID INT,               -- ID de la factura original
    @EmpleadoID INT,                  -- ID del empleado que genera la nota
    -- @Motivo VARCHAR(255),            -- no lo estamos usando
    @MontoDebito DECIMAL(9, 2)        -- Monto del débito
AS
BEGIN

	BEGIN TRANSACTION;
    BEGIN TRY
       
        DECLARE @ClienteID INT, @Letra CHAR(1);
        SELECT @ClienteID = Cliente, @Letra = Letra
        FROM facturacion.comprobante
        WHERE ID = @ComprobanteID;

        
        DECLARE @NuevoNumero CHAR(11);
        SELECT @NuevoNumero = RIGHT('0000000000' + CAST(ISNULL(MAX(CAST(numero AS INT)) + 1, 1) AS VARCHAR), 11)
        FROM facturacion.comprobante
        WHERE tipo = 'ND';

       
        DECLARE @Fecha DATETIME = GETDATE();
        EXEC facturacion.InsertarComprobante
            @tipo = 'ND',
            @numero = @NuevoNumero,
            @letra = @Letra,
            @Fecha = @Fecha,							--- no se si falta agregar lo de la hora en este SP  -- seria asi: CONVERT(TIME, GETDATE())
            @Total = @MontoDebito,
            @Cliente = @ClienteID,
            @Empleado = @EmpleadoID,
            @Pago = NULL;  -- no requiere pago inicial

       
        DECLARE @NotaDebitoID INT = SCOPE_IDENTITY();

        
        EXEC facturacion.InsertarLineaComprobante
            @ID = @NotaDebitoID,
            @IdProducto = NULL,         -- no asociada a un producto específico
            @Cantidad = 1,              
            @Monto = @MontoDebito;      -- Monto de la nota de débito

        PRINT 'Nota de débito generada exitosamente.';

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al generar la nota de débito: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-----------------------------------------------------------------
------------------- EJEMPLO DE EJECUCION ------------------------
-----------------------------------------------------------------

DECLARE @MontoCredito DECIMAL(9, 2) = 200.00;
DECLARE @EmpleadoSupervisorID INT = 1;



--Supervisor - monetario

EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaCredito 
    @ComprobanteID = 1, 
	@EmpleadoID = @EmpleadoSupervisorID, 
    --@Motivo = 'Devolución parcial', 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO

--Supervisor - producto

DECLARE @EmpleadoSupervisorID INT = 1;
DECLARE @IdProductoDevolucion INT = 102;

EXECUTE AS LOGIN = 'usuario_supervisor';
EXEC facturacion.GenerarNotaCredito
	@EmpleadoID = @EmpleadoSupervisorID, 
	@ComprobanteID = 1,
    --@Motivo = 'Devolución de producto de la misma categoría',
    @MontoCredito = 100.00,
    @DevolucionProducto = 1,                  -- Indica que es devolucion por producto
    @IdProductoDevolucion = @IdProductoDevolucion;

REVERT;
GO

--Vendedor

DECLARE @EmpleadoNoSupervisorID INT = 2;
EXECUTE AS LOGIN = 'usuario_vendedor';
EXEC facturacion.GenerarNotaCredito 
    @ComprobanteID = 1, 
    @EmpleadoID = @EmpleadoNoSupervisorID, 
    --@Motivo = 'Devolución parcial', 
    @MontoCredito = 100.00, 
    @DevolucionProducto = 0; 

REVERT;
GO

/*
USE COM2900G09
GO
-- Agregamos campo para los datos cifrados
ALTER TABLE infraestructura.Empleado
	ADD DireccionCifrada VARBINARY(256);
GO

-- Obtenemos la clave de cifrado 
DECLARE @FraseClaveCargada NVARCHAR(128);
SET @FraseClaveCargada  = 'CifraDatos';

-- Ciframos los datos personales de los empleados.
-- Agrega un Hash (PK IdEmpleado al cifrado)

UPDATE infraestructura.Empleado
SET DireccionCifrada = EncryptByPassPhrase(@FraseClaveCargada, Direccion, 1 ,CONVERT(varbinary, IdEmpleado))
WHERE IdEmpleado = '1';

GO

-- PARA DESENCRIPTAR 

DECLARE @FraseClaveCargadaPorUsuario NVARCHAR(128);
SET @FraseClaveCargadaPorUsuario  = 'CifraDatos'

SELECT 
    IdEmpleado,
    CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, DireccionCifrada, 1, CONVERT(VARBINARY, IdEmpleado))) AS DireccionDesencriptada
FROM infraestructura.Empleado;
GO

*/