use AuroraVentas
go

CREATE OR ALTER PROCEDURE ddbba.BulkProducto
	@Path NVARCHAR(max)
AS
BEGIN
	create table #ProductoCSV(
	IDProducto int primary key NONCLUSTERED,
    CategoriaDescripcion varchar(50),
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

		INSERT ddbba.producto(Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
			SELECT Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha
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

CREATE OR ALTER PROCEDURE ddbba.BulkVentasRegistradas
	@Path NVARCHAR(max)
AS
BEGIN
	create table #VentasRegistradasCSV(
	IDFactura varchar(max), 					--venta.Factura
	TipoFactura varchar(max), 				--venta.TipoFactura
	Ciudad varchar(max), 			--sucursal.ciudad NO SIRVE
	TipoCliente varchar(max), 			--cliente.tipocliente NO SIRVE
	Genero varchar(max), 				--venta.genero
	Producto varchar(max),			--lineaVenta.producto
	PrecioUnitario varchar(max),	--lineaVenta.Monto
	Cantidad varchar(max),					--lineaVenta.cantidad
	Fecha varchar(max),						--venta.fecha
	Hora varchar(max),						--venta.hora
	MedioPago varchar(max),				--MedioDePago.nombre
	Empleado varchar(max),				--venta.Empleado
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
	
		/*INSERT ddbba.pago(IdentificadorDePago, Fecha, MedioDePago)
			SELECT a.IdentificadorPago, a.Fecha, b.IDMedioDePago
				FROM #VentasRegistradasCSV AS a
				LEFT JOIN ddbba.MedioDePago AS b ON a.MedioPago = b.nombre

		INSERT ddbba.venta(Factura, TipoFactura, Fecha, Hora, Empleado, Pago)
			SELECT a.IDFactura, a.TipoFactura, a.Fecha, a.Hora, a.Empleado, b.IDPago
				FROM #VentasRegistradasCSV AS a
				LEFT JOIN ddbba.pago AS b ON a.IdentificadorPago = b.IdentificadorDePago

		INSERT ddbba.lineaVenta(IDVenta, Cantidad, Monto, producto)
			SELECT b.IDVenta, a.Cantidad, a.PrecioUnitario, a.producto
				FROM #VentasRegistradasCSV AS a
				LEFT JOIN ddbba.venta AS b ON a.IDFactura = b.Factura*/

		select *
			from #VentasRegistradasCSV

		DROP TABLE #VentasRegistradasCSV
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

--EXEC ddbba.BulkProducto @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'
--go

--EXEC ddbba.BulkVentasRegistradas @Path = 'C:\Users\juanp\Downloads\Ventas_registradas.csv'
--go