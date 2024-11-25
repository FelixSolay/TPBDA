/*
Script para probar varios SP
la prueba debe:
Cargar cargos, medios de Pago, tipos de cliente,Datos facturacion
Cargar 3 categorias
Cargar 5 productos
Cargar 2 sucursales
Cargar 2 empleados
Cargar 2 clientes

*/
use COM2900G09
go

CREATE OR ALTER PROCEDURE test.CargarDatos 
AS
BEGIN
	DECLARE @FechaActual DATETIME;
	SET @FechaActual = GETDATE();
	--Datos Base
	EXEC infraestructura.InsertarCargo @descripcion='Cajero'
	EXEC infraestructura.InsertarCargo @descripcion='Supervisor'
	EXEC infraestructura.InsertarCargo @descripcion='Gerente de Sucursal'
	--Categorias
	EXEC deposito.InsertarCategoria @descripcion = 'Perfumeria'		--1
	EXEC deposito.InsertarCategoria @descripcion = 'Almacen'		--2
	EXEC deposito.InsertarCategoria @descripcion = 'Electronicos'	--3
	--Productos
	EXEC deposito.InsertarProducto 
		@Categoria = 2,
		@Nombre = 'Aceite de Oliva',
		@Precio = 2250,
		@PrecioReferencia = 2.25,
		@UnidadReferencia = 'ml',
		@Fecha = @FechaActual;
	EXEC deposito.InsertarProducto 
		@Categoria = 2,
		@Nombre = 'Fideos Mamamama',
		@Precio = 500,
		@PrecioReferencia = 0.5,
		@UnidadReferencia = 'gr',
		@Fecha = @FechaActual;
	EXEC deposito.InsertarProducto 
		@Categoria = 1,
		@Nombre = 'Desodorante alcantarilla',
		@Precio = 1950,
		@PrecioReferencia = 10,
		@UnidadReferencia = 'ml',
		@Fecha = @FechaActual;
	EXEC deposito.InsertarProducto 
		@Categoria = 1,
		@Nombre = 'Perfume Paco',
		@Precio = 2100,
		@PrecioReferencia = 10.5,
		@UnidadReferencia = 'ml',
		@Fecha = @FechaActual;
	EXEC deposito.InsertarProducto 
		@Categoria = 3,
		@Nombre = 'Televisor Ultravision',
		@Precio = 125000,
		@PrecioReferencia = 125000,
		@UnidadReferencia = 'U',
		@Fecha = @FechaActual;
	--Sucursales
	EXEC infraestructura.InsertarSucursal 
		@Direccion = 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires',
		@Ciudad = 'San Justo',
		@Horario = 'L a V 8?a. m.–9?p. m.S y D 9 a. m.-8?p. m.',
		@Telefono = '5555-5551'
	EXEC infraestructura.InsertarSucursal 
		@Direccion = 'Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires',
		@Ciudad = 'Ramos Mejia',
		@Horario = 'L a V 8?a. m.–9?p. m.S y D 9 a. m.-8?p. m.',
		@Telefono = '5555-5552'
	--Empleados

END
