use COM2900G09
go

CREATE OR ALTER PROCEDURE BulkProducto
	@Path NVARCHAR(max)
AS
BEGIN
	create table #ProductoCSV(
	IDProducto int primary key,
    Categoria varchar(50),
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia varchar(2),
    Fecha datetime
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(max)

	SET @SQLBulk = 'BULK INSERT #ProductoCSV
					FROM ''' + @Path + ''' 
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '','',
						ROWTERMINATOR = ''\n''
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk

		INSERT deposito.producto(Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
			SELECT Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha
				FROM #ProductoCSV

		DROP TABLE #ProductoCSV
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE BulkVentasRegistradas
	@Path NVARCHAR(max)
AS
BEGIN
	create table #VentasRegistradasCSV(
	Factura varchar(max), 			--comprobante.numero
	TipoFactura varchar(max), 		--comprobante.tipo
	Ciudad varchar(max), 			--sucursal.ciudad NO SIRVE
	TipoCliente varchar(max), 		--cliente.tipocliente NO SIRVE
	Genero varchar(max), 			--cliente.genero NO SIRVE
	Producto varchar(max),			--producto.nombre
	PrecioUnitario varchar(max),	--lineaComprobante.Monto
	Cantidad varchar(max),			--lineaComprobante.cantidad
	Fecha varchar(max),				--comprobante.fecha
	Hora varchar(max),				--comprobante.hora
	MedioPago varchar(max),			--MedioDePago.nombre
	Empleado varchar(max),			--comprobante.Empleado
	IdentificadorPago varchar(max)	--pago.IdentificadorDePago
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(max)

	SET @SQLBulk = 'BULK INSERT #VentasRegistradasCSV
					FROM ''' + @Path + ''' 
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '';'',
						ROWTERMINATOR = ''\n''
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk
	
		SELECT *
			FROM #VentasRegistradasCSV

		INSERT facturacion.pago(IdentificadorDePago, Fecha, MedioDePago)
			SELECT IIF(a.IdentificadorPago = '--', NULL, LEFT(REPLACE(a.IdentificadorPago, '''',''), 22)), a.Fecha, b.IDMedioDePago
				FROM #VentasRegistradasCSV AS a
				LEFT JOIN facturacion.MedioDePago AS b ON a.MedioPago = b.nombre

		INSERT facturacion.comprobante(numero, letra, Fecha, Hora, Empleado, Pago)
			SELECT a.Factura, a.TipoFactura, a.Fecha, a.Hora, CAST(a.Empleado AS INT), b.IDPago
				FROM #VentasRegistradasCSV AS a
				LEFT JOIN facturacion.pago AS b ON a.IdentificadorPago = b.IdentificadorDePago

		INSERT facturacion.lineaComprobante(ID, IdProducto, Cantidad, Monto)
			SELECT b.ID, c.IdProducto, a.Cantidad, a.PrecioUnitario
				FROM #VentasRegistradasCSV 		  AS a
				LEFT JOIN facturacion.comprobante AS b ON a.Factura  = b.numero
				LEFT JOIN deposito.producto 	  AS c ON a.producto = c.nombre

		DROP TABLE #VentasRegistradasCSV
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION --Los identitys se mantienen avanzados a pesar del rollback
	END CATCH
END
GO

--EXEC ddbba.BulkProducto @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'
--go

--EXEC ddbba.BulkVentasRegistradas @Path = 'C:\Users\juanp\Downloads\Ventas_registradas.csv'
--go

use master
go