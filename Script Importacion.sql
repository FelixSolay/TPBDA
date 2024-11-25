USE COM2900G09
GO

CREATE TABLE #Constants(
	ID int identity(1,1),
	Valor NVARCHAR(MAX)
)
INSERT #Constants(Valor) VALUES ('C:\0\bda\TP_integrador_Archivos')
INSERT #Constants(Valor) VALUES ('Microsoft.ACE.OLEDB.16.0')
INSERT #Constants(Valor) VALUES ('Excel 12.0')
GO

CREATE OR ALTER PROCEDURE facturacion.ImportVentas
	@Path NVARCHAR(MAX)
AS
BEGIN
	create table #VentasRegistradasCSV(
		Factura			  VARCHAR(MAX), --Factura.numero
		TipoFactura		  VARCHAR(MAX), --Factura.letra
		Ciudad			  VARCHAR(MAX), --sucursal.ciudad
		TipoCliente		  VARCHAR(MAX), --cliente.IDtipocliente
		Genero			  VARCHAR(MAX), --cliente.genero
		Producto		  VARCHAR(MAX),	--producto.nombre
		PrecioUnitario	  VARCHAR(MAX),	--lineaVenta.Monto
		Cantidad		  VARCHAR(MAX),	--lineaVenta.cantidad
		Fecha			  VARCHAR(MAX),	--Factura.fecha
		Hora			  VARCHAR(MAX),	--Factura.hora
		MedioPago		  VARCHAR(MAX),	--MedioDePago.nombre
		Empleado		  VARCHAR(MAX),	--Venta.Empleado
		IdentificadorPago VARCHAR(MAX)	--pago.IdentificadorDePago
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(MAX)

	SET @SQLBulk = 'BULK INSERT #VentasRegistradasCSV
					FROM''' + @Path + '\Ventas_registradas.csv''
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '';'',
						ROWTERMINATOR = ''\n''
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk

		INSERT INTO facturacion.factura(letra, numero, Fecha, Hora, MontoIVA, MontoNeto, MontoBruto, IDDatosFac)
			SELECT TipoFactura, Factura, fecha, hora, 
				   (CAST(Cantidad AS INT) * CAST(PrecioUnitario AS DECIMAL(9,2)) * 0.21), 
				   (CAST(Cantidad AS INT) * CAST(PrecioUnitario AS DECIMAL(9,2))), 
				   (CAST(Cantidad AS INT) * CAST(PrecioUnitario AS DECIMAL(9,2)) * 1.21),
				   1
				FROM #VentasRegistradasCSV

		INSERT facturacion.Venta(IDFactura, Empleado, MontoNeto, Cerrado)
			SELECT b.ID, CAST(a.Empleado AS INT), b.MontoNeto, 1
				FROM #VentasRegistradasCSV	   AS a
				INNER JOIN facturacion.factura AS b ON a.TipoFactura = b.letra 
												   AND a.Factura	 = b.numero

		INSERT facturacion.lineaVenta(ID, IdProducto, Cantidad, Monto)
			SELECT b.ID, IIF(c.IDProducto IS NULL, 1, c.IDProducto), CAST(a.Cantidad AS INT), CAST(a.PrecioUnitario AS DECIMAL(9,2))
				FROM #VentasRegistradasCSV	   AS a
				INNER JOIN facturacion.factura AS b ON a.TipoFactura = b.letra 
												   AND a.Factura	 = b.numero
				LEFT JOIN deposito.producto   AS c ON a.producto	 = c.nombre

		INSERT facturacion.pago(factura, IdentificadorDePago, Fecha, MedioDePago)
			SELECT b.ID, IIF(a.IdentificadorPago = '--', NULL, LEFT(REPLACE(a.IdentificadorPago, '''',''), 22)), a.Fecha, c.IDMedioDePago
				FROM #VentasRegistradasCSV		   AS a
				INNER JOIN facturacion.factura	   AS b ON a.TipoFactura = b.letra 
													   AND a.Factura	 = b.numero
				INNER JOIN facturacion.MedioDePago AS c ON a.MedioPago	 = c.nombre

		DROP TABLE #VentasRegistradasCSV
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ImportVentas
		--Los identitys se mantienen avanzados a pesar del rollback
		ROLLBACK TRANSACTION
	END CATCH

	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE deposito.ImportProductos
	@Path  NVARCHAR(MAX),
	@OLEDB NVARCHAR(MAX),
	@EXCEL NVARCHAR(MAX)
AS
BEGIN
	create table #Producto(
		IDProducto		 VARCHAR(MAX),
		Categoria		 VARCHAR(MAX),
		Nombre			 VARCHAR(MAX),
		Precio			 VARCHAR(MAX),
		PrecioReferencia VARCHAR(MAX),
		UnidadReferencia VARCHAR(MAX),
		Fecha			 VARCHAR(MAX)
	)

	create table #Clasificacion(
		categoria		VARCHAR(MAX),
		categoriaImport VARCHAR(MAX)
	)

	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @dolar DECIMAL (9,2)

	SET @dolar = 1026.50 --https://dolarhoy.com/

	BEGIN TRY
		
		-- Electronic accessories.xlsx -> Sheet1
		SET @SQL = 'INSERT INTO #Producto(Nombre, Precio)
						SELECT * 
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Electronic accessories.xlsx'',
											''SELECT * FROM [Sheet1$]'')'

		EXEC sp_executesql @SQL

		INSERT INTO deposito.producto(Categoria, Nombre, Precio, PrecioReferencia, Fecha) 
			SELECT 1, Nombre, Precio * @dolar, Precio, GETDATE()
				FROM #Producto

		TRUNCATE TABLE #Producto
		
		-- Electronic accessories.xlsx -> Sheet1
		SET @SQL = 'INSERT INTO #Clasificacion(Categoria,CategoriaImport)
						SELECT [Línea de producto], Producto
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Clasificacion productos$]'')'

		EXEC sp_executesql @SQL
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
			SELECT b.IDCategoria categoria,--IIF(b.IDCategoria IS NULL, 3, b.IDCategoria) categoria,
			a.Nombre,
			Precio,
			PrecioReferencia,
			a.UnidadReferencia,
			a.Fecha
				FROM #Producto AS a
				LEFT JOIN #clasificacion AS c ON c.categoriaImport = a.Categoria
				LEFT JOIN deposito.categoria AS b ON c.categoria = b.Descripcion
				where ISNUMERIC(a.precio)=1 and ISNUMERIC(a.precioreferencia)=1
		
		
		TRUNCATE TABLE #Producto
		
		-- Productos_importados.xlsx -> Listado de Productos
		SET @SQL = 'INSERT INTO #Producto(Nombre, Categoria, UnidadReferencia, PrecioReferencia)
						SELECT NombreProducto, Categoría, CantidadPorUnidad, PrecioUnidad
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Productos_importados.xlsx'',
											''SELECT * FROM [Listado de Productos$]'')'								

		EXEC sp_executesql @SQL

		INSERT deposito.producto(Categoria, Nombre, UnidadReferencia, PrecioReferencia, Precio, Fecha)
			SELECT 2, Nombre, UnidadReferencia, PrecioReferencia, PrecioReferencia * @dolar, GETDATE()
				FROM #Producto
		
		DROP TABLE #Producto

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ImportProductos
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ImportSucursal
	@Path  NVARCHAR(MAX),
	@OLEDB NVARCHAR(MAX),
	@EXCEL NVARCHAR(MAX)
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
	DECLARE @SQL NVARCHAR(MAX)

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
		SELECT ERROR_MESSAGE() AS ImportSucursal
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ImportEmpleados
	@Path  NVARCHAR(MAX),
	@OLEDB NVARCHAR(MAX),
	@EXCEL NVARCHAR(MAX)
AS
BEGIN
	create table #Empleados(
		Legajo		  INT,
		Nombre		  VARCHAR(MAX),
		Apellido	  VARCHAR(MAX),
		DNI			  INT,
		Direccion	  VARCHAR(MAX),
		EmailPersonal VARCHAR(MAX),
		EmailEmpresa  VARCHAR(MAX),
		CUIL		  VARCHAR(MAX),
		Cargo		  VARCHAR(MAX),
		Sucursal	  VARCHAR(MAX),
		Turno		  VARCHAR(MAX)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL NVARCHAR(MAX)

	BEGIN TRY
		-- Informacion_complementaria.xlsx -> Empleados
		SET @SQL = 'INSERT INTO #Empleados(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Cargo, Sucursal, Turno)
					

						SELECT *
							FROM OPENROWSET(''' + @OLEDB + ''',
											''' + @EXCEL + ';HDR=YES;Database=' + @Path + '\Informacion_complementaria.xlsx'',
											''SELECT * FROM [Empleados$]'')'

		EXEC sp_executesql @SQL

		DELETE #Empleados WHERE Legajo IS NULL

		INSERT INTO infraestructura.cargo(Descripcion)
			SELECT DISTINCT Cargo
				FROM #Empleados

		INSERT INTO infraestructura.empleado(Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, Cargo, Sucursal, Turno)
			SELECT a.Legajo, a.Nombre, a.Apellido, a.DNI, a.Direccion, a.EmailPersonal, a.EmailEmpresa, b.IdCargo, c.IDsucursal, a.Turno
				FROM #Empleados AS a
				INNER JOIN infraestructura.cargo AS b ON a.Cargo = b.Descripcion
				INNER JOIN infraestructura.sucursal AS c ON a.Sucursal = c.Ciudad

		DROP TABLE #Empleados

		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ImportEmpleados
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE facturacion.ImportMediosPago
	@Path  NVARCHAR(MAX),
	@OLEDB NVARCHAR(MAX),
	@EXCEL NVARCHAR(MAX)
AS
BEGIN
	create table #MediosPago(
		blank		VARCHAR(MAX),
		Nombre		VARCHAR(MAX),
		Descripcion	VARCHAR(MAX)
	)
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 
	DECLARE @SQL NVARCHAR(MAX)

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
		SELECT ERROR_MESSAGE() AS ImportMediosPago
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE deposito.ImportCategoria
	@Path  NVARCHAR(MAX),
	@OLEDB NVARCHAR(MAX),
	@EXCEL NVARCHAR(MAX)
AS
BEGIN
	create table #Categoria(
		Descripcion	VARCHAR(MAX),
		Producto	VARCHAR(MAX),
	)

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 

	DECLARE @SQL NVARCHAR(MAX)

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
		SELECT ERROR_MESSAGE() AS ImportCategoria
		ROLLBACK TRANSACTION
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE infraestructura.ExecuteImports
AS
BEGIN
	DECLARE @Path  NVARCHAR(MAX)
	DECLARE @OLEDB NVARCHAR(MAX)
	DECLARE @Excel NVARCHAR(MAX)

	SELECT @Path = Valor  FROM #Constants
		WHERE ID = 1
	SELECT @OLEDB = Valor FROM #Constants
		WHERE ID = 2
	SELECT @Excel = Valor FROM #Constants
		WHERE ID = 3

	BEGIN TRY
		-- Secuencia 1
		EXEC infraestructura.ImportSucursal @Path = @Path, @OLEDB = @OLEDB, @Excel = @Excel
		EXEC deposito.ImportCategoria 		@Path = @Path, @OLEDB = @OLEDB, @Excel = @Excel 
		EXEC facturacion.ImportMediosPago 	@Path = @Path, @OLEDB = @OLEDB, @Excel = @Excel
		-- Secuencia 2	
		EXEC infraestructura.ImportEmpleados @Path = @Path, @OLEDB = @OLEDB, @Excel = @Excel
		EXEC deposito.ImportProductos 		 @Path = @Path, @OLEDB = @OLEDB, @Excel = @Excel
		-- Secuencia 3
		EXEC facturacion.ImportVentas @Path = @Path
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ExecuteImports
	END CATCH
END
GO

EXEC infraestructura.ExecuteImports

DROP TABLE #Constants
GO

USE master
GO