USE COM2900G09
GO

EXEC deposito.InsertarCategoria @Descripcion = 'Accessorios electronicos'
EXEC deposito.InsertarCategoria @Descripcion = 'Productos importados'
GO


CREATE OR ALTER PROCEDURE facturacion.ImportVentas
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #VentasRegistradasCSV(
		Factura			  VARCHAR(MAX), --comprobante.numero
		TipoFactura		  VARCHAR(MAX), --comprobante.tipo
		Ciudad			  VARCHAR(MAX), --sucursal.ciudad NO SIRVE
		TipoCliente		  VARCHAR(MAX), --cliente.tipocliente NO SIRVE
		Genero			  VARCHAR(MAX), --cliente.genero NO SIRVE
		Producto		  VARCHAR(MAX),	--producto.nombre
		PrecioUnitario	  VARCHAR(MAX),	--lineaComprobante.Monto
		Cantidad		  VARCHAR(MAX),	--lineaComprobante.cantidad
		Fecha			  VARCHAR(MAX),	--comprobante.fecha
		Hora			  VARCHAR(MAX),	--comprobante.hora
		MedioPago		  VARCHAR(MAX),	--MedioDePago.nombre
		Empleado		  VARCHAR(MAX),	--comprobante.Empleado
		IdentificadorPago VARCHAR(MAX)	--pago.IdentificadorDePago
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(MAX)

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

CREATE OR ALTER PROCEDURE deposito.ImportProductos
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #Producto(
		IDProducto		 VARCHAR(MAX),
		Categoria		 VARCHAR(MAX),
		Nombre			 VARCHAR(MAX),
		Precio			 VARCHAR(MAX),
		PrecioReferencia VARCHAR(MAX),
		UnidadReferencia VARCHAR(MAX),
		Fecha			 VARCHAR(MAX),
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(MAX) = 'Excel 12.0'

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
			SELECT b.IDCategoria, a.Nombre, a.Precio, a.PrecioReferencia, a.UnidadReferencia, a.Fecha
				FROM #Producto AS a
				INNER JOIN deposito.categoria AS b ON a.categoria = b.Descripcion

		TRUNCATE TABLE #Producto

		-- Productos_importados.xlsx -> Listado de Productos
		SET @SQL = 'INSERT INTO #Producto(Nombre, Categoria, UnidadReferencia, PrecioReferencia)
						SELECT NombreProducto, Categoría, CantidadPorUnidad, PrecioUnidad
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Productos_importados.xlsx'',
											''SELECT * FROM [Listado de Productos$]'')'								

		EXEC sp_executesql @SQL

		INSERT deposito.producto(Categoria, Nombre, UnidadReferencia, PrecioReferencia, Fecha)
			SELECT 2, Nombre, UnidadReferencia, PrecioReferencia, GETDATE()
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

CREATE OR ALTER PROCEDURE infraestructura.ImportSucursal
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #Sucursal(
		Direccion VARCHAR(MAX),
		Ciudad	  VARCHAR(MAX),
		Horario	  VARCHAR(MAX),
		Telefono  VARCHAR(MAX)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(MAX) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> sucursal
		SET @SQL = 'INSERT INTO #Sucursal(Ciudad, Direccion, Horario, Telefono)
						SELECT [Reemplazar por], direccion, Horario, Telefono
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
			SELECT *
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

CREATE OR ALTER PROCEDURE facturacion.ImportMediosPago
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #MediosPago(
		blank		VARCHAR(MAX),
		Nombre		VARCHAR(MAX),
		Descripcion	VARCHAR(MAX)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL   NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(MAX) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> medios de pago
		SET @SQL = 'INSERT INTO #MediosPago(blank, Nombre, Descripcion)
						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [medios de pago$]'',
											FIRSTROW = 2)'

		EXEC sp_executesql @SQL

		INSERT INTO facturacion.MedioDePago(Nombre, Descripcion)
			SELECT Nombre, Descripcion
				FROM #MediosPago

		DROP TABLE #MediosPago

		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE deposito.ImportCategoria
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #Categoria(
		Descripcion	VARCHAR(MAX),
		Producto	VARCHAR(MAX),
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 

	DECLARE @SQL   NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX) = 'Microsoft.ACE.OLEDB.16.0'
	DECLARE @EXCEL NVARCHAR(MAX) = 'Excel 12.0'

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> Clasificacion de productos
		SET @SQL = 'INSERT INTO #Categoria(Descripcion, Producto)
						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Clasificacion productos$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO deposito.categoria(Descripcion)
			SELECT DISTINCT Descripcion
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

CREATE TABLE #Path(
			Valor NVARCHAR(MAX)
		)
INSERT #Path(Valor) VALUES ('C:\Users\juanp\Downloads')
GO

-- Secuencia 1
DECLARE @ConstantPath VARCHAR(MAX)
SELECT @ConstantPath = Valor FROM #Path
EXEC infraestructura.ImportSucursal @Path = @ConstantPath
EXEC deposito.ImportCategoria @Path = @ConstantPath
EXEC facturacion.mportMediosPago @Path = @ConstantPath
GO

-- Secuencia 2
DECLARE @ConstantPath VARCHAR(MAX)
SELECT @ConstantPath = Valor FROM #Path
EXEC infraestructura.ImportEmpleados @Path = @ConstantPath
EXEC deposito.ImportProductos @Path = @ConstantPath
GO

-- Secuencia 3
DECLARE @ConstantPath VARCHAR(MAX)
SELECT @ConstantPath = Valor FROM #Path
EXEC facturacion.ImportVentas @Path = @ConstantPath
GO

DROP TABLE #Path
GO

USE master
GO