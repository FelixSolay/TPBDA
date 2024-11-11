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
--------------------------- encriptacion de datos empleado -----------------------------------------
USE COM2900G09
GO
-- Agregamos campo para los datos cifrados
ALTER TABLE infraestructura.empleado
    ADD DireccionCifrada VARBINARY(MAX),
        EmailPersonalCifrado VARBINARY(MAX);
GO

-- Obtenemos la clave de cifrado 
DECLARE @FraseClave NVARCHAR(128) = 'CifraDatos';

-- Ciframos los datos personales de los empleados.
-- Agrega un Hash (PK IdEmpleado al cifrado)



------------------------- ACTUALIZACION DE TABLA EMPLEADOS DESPUES DE HABER SIDO IMPORTADOS -----------------------------

UPDATE infraestructura.empleado
SET 
    DireccionCifrada = EncryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(VARBINARY, Legajo)),
    EmailPersonalCifrado = EncryptByPassPhrase(@FraseClave, EmailPersonal, 1, CONVERT(VARBINARY, Legajo));
GO

-- vemos que se encripto correctamente 

SELECT Legajo, DireccionCifrada, EmailPersonalCifrado
FROM infraestructura.empleado;

-- PARA DESENCRIPTAR ------

DECLARE @FraseClave NVARCHAR(128) = 'CifraDatos';

SELECT 
    Legajo,
    CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, DireccionCifrada, 1, CONVERT(VARBINARY, Legajo))) AS DireccionDesencriptada,
    CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, EmailPersonalCifrado, 1, CONVERT(VARBINARY, Legajo))) AS EmailPersonalDesencriptado
FROM infraestructura.empleado;

-----------------------------------------------------------------------------




----------- SI QUISIERA HACERLO AL MOMENTO DE IMPORTARLO --------------------
CREATE OR ALTER PROCEDURE infraestructura.ImportEmpleados
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #Empleados(
		Legajo		  VARCHAR(MAX),
		Nombre		  VARCHAR(MAX),
		Apellido	  VARCHAR(MAX),
		DNI			  VARCHAR(MAX),
		Direccion	  VARCHAR(MAX),
		EmailPersonal VARCHAR(MAX),
		EmailEmpresa  VARCHAR(MAX),
		CUIL		  VARCHAR(MAX),
		Turno		  VARCHAR(MAX),
		Cargo		  VARCHAR(MAX),
		Sucursal	  VARCHAR(MAX),
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(MAX) = 'Excel 12.0'

	-------------------CAMBIO-------------------------
	 DECLARE @FraseClave NVARCHAR(128) = 'CifraDatos'; 
	 -------------------------------------------------


	BEGIN TRY
		-- Informacion_complementaria.xlsx -> Empleados
		SET @SQL = 'INSERT INTO #Empleados(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Empleados$]'',
											FIRSTROW = 2)'

		EXEC sp_executesql @SQL

		INSERT INTO infraestructura.empleado(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
		----CAMBIO-----------------------
		SELECT 
            Legajo,
            Nombre,
            Apellido,
            DNI,
            -- Cifrar Direccion y EmailPersonal al insertarlos en la tabla destino
            EncryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(VARBINARY, Legajo)) AS DireccionCifrada,
            EncryptByPassPhrase(@FraseClave, EmailPersonal, 1, CONVERT(VARBINARY, Legajo)) AS EmailPersonalCifrada,
            EmailEmpresa,
            CUIL,
            Cargo,
            Sucursal,
            Turno
        FROM #Empleados;
		--------------------------------
			
			--SELECT *                    --- esto se iria reemplazado por lo de arriba
			--	FROM #Empleados				-- idem

		DROP TABLE #Empleados

		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

--------------------------- para cualquiera de los casos para los siguietntes ingresos se modificaria el insert --------

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
		
        --INSERT INTO infraestructura.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
		--VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal);

		-----------------CAMBIO--------------------------
		INSERT INTO infraestructura.empleado (Legajo, Nombre, Apellido, DNI, DireccionCifrada, EmailPersonalCifrado, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
		VALUES 
            (
                @Legajo,
                @Nombre,
                @Apellido,
                @DNI,
                -- Encriptación de Direccion y EmailPersonal al momento de la inserción
                EncryptByPassPhrase(@FraseClave, @Direccion, 1, CONVERT(VARBINARY, @Legajo)),
                EncryptByPassPhrase(@FraseClave, @EmailPersonal, 1, CONVERT(VARBINARY, @Legajo)),
                @EmailEmpresa,
                @CUIL,
                @Turno,
                @Cargo,
                @Sucursal
            );
        ----------------------------------------------------------


        COMMIT TRANSACTION;
        PRINT 'Empleado insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO




*/