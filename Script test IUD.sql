/*
Este script es utilizara para las pruebas de todos los Store Procedures generados
de Insersion, Actualizacion y eleminado, para cada tabla, ordenado por esquema

*/
USE COM2900G09
GO

--ESQUEMA DEPOSITO
--  Categoria
--      Insert
--			Prueba de inserción de una nueva categoría
EXEC deposito.InsertarCategoria 
    @Descripcion = 'Perfumeria';
--			Prueba con descripción nula o inválida para generar un error
EXEC deposito.InsertarCategoria 
    @Descripcion = NULL;
--      Update
--			Prueba de actualización de una categoría existente
EXEC deposito.ActualizarCategoria 
    @IDCategoria = 1, 
    @Descripcion = 'Amacen';
--			Prueba con ID inexistente para verificar manejo de errores
EXEC deposito.ActualizarCategoria 
    @IDCategoria = 999, 
    @Descripcion = 'Inexistente';
--      Delete
--			Prueba de eliminación de una categoría existente
EXEC deposito.EliminarCategoria
	@idcategoria = 1
--			Prueba con ID inexistente para verificar manejo de errores
EXEC deposito.EliminarCategoria
	@idcategoria = 999

--  Producto
--      Insert
EXEC deposito.InsertarProducto 
	@Categoria = 1,
	@Nombre = 'Aceite de Oliva',
	@Precio = 57.25,
	@PrecioReferencia = 57.25,
	@UnidadReferencia = 'ml',
	@Fecha = '2024-11-09 15:53:56.127';

DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 2,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;
--      Update
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'L'
--      Delete
--ESQUEMA FACTURACION
--  TipoCLiente
--      Insert
--      Update
--      Delete
--  Cliente
--      Insert
--      Update
--      Delete
--  Comprobante
--      Insert
--      Update
--      Delete
--  LineaComprobante
--      Insert
--      Update
--      Delete
--  MedioDePago
--      Insert
--      Update
--      Delete
--  Pago
--      Insert
--      Update
--      Delete
--ESQUEMA INFRAESTRUCTURA
--  Sucursal
--      Insert
--      Update
--      Delete
--  Cargo
--      Insert
--      Update
--      Delete
--  Empleado
--      Insert
--      Update
--      Delete

