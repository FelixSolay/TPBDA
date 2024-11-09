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


CREATE OR ALTER PROCEDURE ImportVentas
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

CREATE OR ALTER PROCEDURE ImportProductos
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Producto(
		IDProducto		 varchar(max),
		Categoria		 varchar(max),
		Nombre			 varchar(max),
		Precio			 varchar(max),
		PrecioReferencia varchar(max),
		UnidadReferencia varchar(max),
		Fecha			 varchar(max),
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(max)
	DECLARE @OLEDB NVARCHAR(max) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(max) = 'Excel 12.0'

	BEGIN TRY
		-- Electronic accessories.xlsx -> Sheet1
		SET @SQL = 'INSERT INTO #Producto(Nombre, Precio)
						SELECT * 
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Electronic accessories.xlsx'',
											''SELECT * FROM [Sheet1$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO deposito.producto(Categoria, Nombre, Precio, Fecha)
			SELECT 1, Nombre, Precio, GETDATE()
				FROM #Producto

		TRUNCATE TABLE #Producto

		-- catalogo.csv -> catalogo
		SET @SQL = 'BULK INSERT #Producto
						FROM ''' + @Path + '\catalogo.csv''
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
		SET @SQL = 'INSERT INTO #Producto(Nombre, Categoria, UnidadReferencia, PrecioReferencia)
						SELECT NombreProducto, Categoría, CantidadPorUnidad, PrecioUnidad
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Productos_importados.xlsx'',
											''SELECT * FROM [Listado de Productos$]'')'								

		EXEC sp_executesql @SQL

		INSERT deposito.producto(Categoria, Nombre, UnidadReferencia, PrecioReferencia, Fecha)
			SELECT 3, Nombre, UnidadReferencia, PrecioReferencia, GETDATE()
				FROM #Producto
		
		DROP TABLE #Producto

		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE ImportSucursal
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Sucursal(
		IDsucursal	varchar(max),
		Direccion	varchar(max),
		Ciudad		varchar(max),
		Horario		varchar(max),
		Telefono	varchar(max)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(max)
	DECLARE @OLEDB NVARCHAR(max) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(max) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> sucursal
		SET @SQL = 'INSERT INTO #Sucursal(Ciudad, Direccion, Horario, Telefono)
						SELECT Reemplazar por, direccion, Horario, Telefono
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [sucursal$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO infraestructura.sucursal(Ciudad, Direccion, Horario, Telefono)
			SELECT Ciudad, Direccion, Horario, Telefono 
				FROM #Sucursal

		DROP TABLE #Sucursal


		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO


CREATE OR ALTER PROCEDURE ImportEmpleados
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Empleados(
	Legajo			varchar(max),
	Nombre			varchar(max),
	Apellido		varchar(max),
	DNI				varchar(max),
	Direccion		varchar(max),
	EmailPersonal	varchar(max),
	EmailEmpresa	varchar(max),
	CUIL			varchar(max),
	Turno			varchar(max),
	Cargo			varchar(max),
	Sucursal		varchar(max),
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(max)
	DECLARE @OLEDB NVARCHAR(max) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(max) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> Empleados
		SET @SQL = 'INSERT INTO #Empelados(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Empelados$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO infraestructura.empleado(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
			SELECT Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno 
				FROM #Empleados

		DROP TABLE #Empleados


		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE ImportMediosdepago
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Mediosdepago(
	IDMedioDePago	varchar(max),
	Nombre			varchar(max),
	Descripcion		varchar(max)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(max)
	DECLARE @OLEDB NVARCHAR(max) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(max) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> medios de pago
		SET @SQL = 'INSERT INTO #Mediosdepago(Nombre, Descripcion)
						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=NO;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [medios de pago$B3:C5]'')'

		EXEC sp_executesql @SQL

		INSERT INTO facturacion.MedioDePago(Nombre, Descripcion)
			SELECT Nombre, Descripcion
				FROM #Mediosdepago

		DROP TABLE #Mediosdepago


		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE ImportCategoria
	@Path NVARCHAR(max)
AS
BEGIN
	create table #Categoria(
	IDCategoria		varchar(max),
	Descripcion		varchar(max),
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(max)
	DECLARE @OLEDB NVARCHAR(max) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(max) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> Clasificacion de productos
		SET @SQL = 'INSERT INTO #Categoria(Descripcion)
						SELECT Línea de producto
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=NO;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Clasificacion de productos$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO deposito.categoria(Descripcion)
			SELECT distinct Descripcion
				FROM #Categoria

		DROP TABLE #Categoria


		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO


/*
DECLARE @ConstantPath nvarchar(max)
SET @ConstantPath = 'C:\Users\juanp\Downloads'
EXEC ImportInformacion @Path = @ConstantPath
go
*/
--EXEC ImportVentasRegistradas @Path = @ConstantPath
--go

use master
go