use COM2900G09
go

/*CREATE OR ALTER PROCEDURE ImportVentas
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
GO*/


CREATE OR ALTER PROCEDURE VentasRegistradas
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
					FROM ' + @Path + '\' + 'Ventas_registradas.csv 
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '';'',
						ROWTERMINATOR = ''\n''
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk

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
		--Los identitys se mantienen avanzados a pesar del rollback
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE ImportInformacion
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Indice(
		id int identity(1,1),
		NomArch nvarchar(max)
	)

	create table #Producto(
		IDProducto varchar(max),
		Categoria varchar(max),
		Nombre varchar(max),
		Precio varchar(max),
		PrecioReferencia varchar(max),
		UnidadReferencia varchar(max),
		Fecha varchar(max)
	)



	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQL NVARCHAR(max)
	DECLARE @Producto NVARCHAR(max)
	DECLARE @IdenIni int


	BEGIN TRY
		-- Informacion_complementaria.xlsx -> catalogo
		SET @SQL = 'INSERT INTO #Indice(NomArch)

						SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'',
												 ''Excel 12.0;HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
												 ''SELECT * FROM [catalogo$]'')'

		EXEC sp_executesql @SQL

		select *
			from #Indice
		
		/*
		-- Electronic accessories.xlsx -> Sheet1
		SELECT @Producto = NomArch 
			FROM #Indice
				where id = 1

		SET @SQL = 'INSERT INTO #Producto(Nombre, Precio)
						SELECT * FROM OPENROWSET(Microsoft.ACE.OLEDB.12.0,
												 Excel 12.0 Xml;Database=' + @Path + '\' + @Producto + ';HDR=YES;IMEX=1,
												 SELECT * FROM [Sheet1$])'

		EXEC sp_executesql @SQL

			INSERT INTO deposito.producto(Categoria, Nombre, Precio, Fecha)
				SELECT 'Electronic accessories', Nombre, Precio, GETDATE()
					FROM #Producto

		TRUNCATE TABLE #Producto

		-- catalogo.csv -> catalogo
		SELECT @Producto = NomArch 
			FROM #Indice
				where id = 2

		SET @SQL = 'BULK INSERT #Producto
						FROM ''' + @Path + '\' + @Producto + ''' 
						WITH
						(
							FIRSTROW = 2,
							DATAFILETYPE = ''char'',
							FIELDTERMINATOR = '','',
							ROWTERMINATOR = ''\n''
						)'

		EXEC sp_executesql @SQL

		INSERT deposito.producto(Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
			SELECT Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha
				FROM #Producto

		TRUNCATE TABLE #Producto

		-- Productos_importados.xlsx -> Listado de Productos
		SELECT @Producto = NomArch 
			FROM #Indice
				where id = 3

		SET @SQL = 'INSERT INTO #Producto(Nombre, UnidadReferencia, PrecioReferencia)
						SELECT * FROM OPENROWSET(Microsoft.ACE.OLEDB.12.0,
												 Excel 12.0 Xml;Database=' + @Path + '\' + @Producto + ';HDR=YES;IMEX=1,
												 SELECT * FROM [Listado de Productos$]))'

		EXEC sp_executesql @SQL

		INSERT deposito.producto(Categoria, Nombre, UnidadReferencia, PrecioReferencia, Fecha)
			SELECT 'Productos importados', Nombre, UnidadReferencia, PrecioReferencia, GETDATE()
				FROM #Producto

		DROP TABLE #Producto
		DROP TABLE #Indice
		*/


		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
go


DECLARE @ConstantPath nvarchar(max)
SET @ConstantPath = 'C:\Users\juanp\Downloads'
EXEC ImportInformacion @Path = @ConstantPath
go

--EXEC ImportVentasRegistradas @Path = @ConstantPath
--go

use master
go