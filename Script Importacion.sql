/* EJECUTAR SOLO UNA VEZ */

use AuroraVentas
go

create table #ProductoCSV(
	IDProducto int primary key NONCLUSTERED,
    CategoriaDescripcion varchar(50),
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia varchar(2),
    Fecha datetime
)
go

create table #VentasRegistradasCSV(
	IDFactura int, 					--venta.Factura
	TipoFactura char, 				--venta.TipoFactura
	Ciudad varchar(20), 			--sucursal.ciudad NO SIRVE
	TipoCliente char(6), 			--cliente.tipocliente NO SIRVE
	Genero varchar(6), 				--venta.genero
	Producto varchar(100),			--lineaVenta.producto
	PrecioUnitario decimal(9,2),	--lineaVenta.Monto
	Cantidad int,					--lineaVenta.cantidad
	Fecha date,						--venta.fecha
	Hora time,						--venta.hora
	MedioPago char(20),				--MedioDePago.nombre
	Empleado bigint,				--venta.Empleado
	IdentificadorPago varchar(22)	--pago.IdentificadorDePago
)
go

CREATE OR ALTER PROCEDURE ddbba.BulkProducto
	@Path NVARCHAR(max)
AS
BEGIN
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

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

/*CREATE OR ALTER PROCEDURE ddbba.BulkVentasRegistradas
	@Path NVARCHAR(max)
AS
BEGIN
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
	
		INSERT ddbba.pago(IdentificadorDePago, Fecha, MedioDePago)
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
				LEFT JOIN ddbba.venta AS b ON a.IDFactura = b.Factura

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO*/

EXEC ddbba.BulkProducto @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'
go

--EXEC ddbba.BulkVentasRegistradas @Path = 'C:\Users\juanp\Downloads\Ventas_registradas.csv'
--go