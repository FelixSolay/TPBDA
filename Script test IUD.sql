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
GO	
--			Prueba con descripción nula o inválida para generar un error
EXEC deposito.InsertarCategoria 
    @Descripcion = NULL;
GO
--      Update
--			Prueba de actualización de una categoría existente
EXEC deposito.ActualizarCategoria 
    @IDCategoria = 1, 
    @Descripcion = 'Amacen';
GO
--			Prueba con ID inexistente para verificar manejo de errores
EXEC deposito.ActualizarCategoria 
    @IDCategoria = 999, 
    @Descripcion = 'Inexistente';
GO
--      Delete
--			Prueba de eliminación de una categoría existente
EXEC deposito.EliminarCategoria
	@idcategoria = 1
GO
--			Prueba con ID inexistente para verificar manejo de errores
EXEC deposito.EliminarCategoria
	@idcategoria = 999999
GO
--  Producto
--      Insert valdio
EXEC deposito.InsertarProducto 
	@Categoria = 1,
	@Nombre = 'Aceite de Oliva',
	@Precio = 57.25,
	@PrecioReferencia = 57.25,
	@UnidadReferencia = 'ml',
	@Fecha = '2024-11-09 15:53:56.127';
GO
-- Prueba insert valdio con variable
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 2,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;
GO
	--Prueba insert invalido con Categira repetida
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 1,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual
GO
--	Prueba insert invalido con Categira invalida
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 'Paco',
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual
GO
--	Prueba insert invalido con Precio invalido
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 'Paco',
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual
GO
--	Prueba insert invalido con PrecioReferencai invalido
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 'Paco',
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual
GO
--	Prueba insert invalido con UnidadReferencai invalida
DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'Paco',
	@Fecha = @FechaActual
GO	
--	Prueba insert invalido con Fecha invalida
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'Paco',
	@Fecha = 'Paco';
GO	
--      Update IdProducto valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'L'
GO	
--      Update IdProducto invalido 
EXEC deposito.ActualizarProducto 
	@IdProducto = 999,
	@UnidadReferencia = 'L'
GO	
--      Update categoria valida 
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@categoria = 20	
GO	
--      Update categoria invalida 
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@categoria = 'L'	
GO
--      Update Precio valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@Precio = 120
GO
--      Update Precio invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@Precio = 'L'
GO
--      Update PrecioReferencia valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@PrecioReferencia = 2.5
GO
--      Update PrecioReferencia invalido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@PrecioReferencia = 'L'
GO
--      Update UnidadReferencia alida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'L'
GO
--      Update UnidadReferencia invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'Paco'
GO		
--      Update Fecha valida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@fecha = '2024-11-09 19:24:33.122'
GO
--      Update Fecha invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@fecha = 'L'
GO
--      Delete
--	Prueba de eliminación valdia de un producto existente
EXEC deposito.EliminarProducto
	@IdProducto = 1
GO
--	Prueba de eliminación invaldia de un producto inexistente
EXEC deposito.EliminarProducto
	@IdProducto = 999999
GO
--ESQUEMA INFRAESTRUCTURA
-- Infraestructura Cargo
-- Insert valido
EXEC infraestructura.InsertarCargo
	@descripcion = 'Paco' 
GO
-- Insert descripción invalido
EXEC infraestructura.InsertarCargo
	@descripcion = 'aca ponemos una descripcion de mas de 25 caracteres para asegurarnos de que sea invalida y que no se cree' 
GO
-- Updates
-- Update valido
EXEC infraestructura.ActualizarCargo
	@IdCargo = 1,
	@descripcion = 'Pacos' 
GO
-- Update ID invalido
EXEC infraestructura.ActualizarCargo
	@IdCargo = 'Pacos',
	@descripcion = 'Paco' 
GO
-- Update descripcion invalida
EXEC infraestructura.ActualizarCargo
	@IdCargo = 'Pacos',
	@descripcion = 'aca ponemos una descripcion de mas de 25 caracteres para asegurarnos de que sea invalida y que no se cree'
GO	
--Delete
-- Delete valido
EXEC infraestructura.EliminarCargo
	@IdCargo = 1
GO	
-- Delete invalido, Id inexistente 
EXEC infraestructura.EliminarCargo
	@IdCargo = 999999
GO
-- Delete invalido, Id inexistente 
EXEC infraestructura.EliminarCargo
	@IdCargo = NULL
GO
-- Sucursal
-- Insert valido
EXEC infraestructura.InsertarSucursal
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 12345678915
GO
-- Insert Ciudad invalida
EXEC infraestructura.InsertarSucursal
	@Direccion = 'Paco' ,
	@Ciudad =  'Aca escribimos algo de mas de 25 carateres para asegurarnos superar el maximo',
	@Horario = '13:50',
	@Telefono = 12345678915
GO
-- Insert Horario invalido
EXEC infraestructura.InsertarSucursal
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = 'Aca escribimos algo de mas de 45 carateres para asegurarnos superar el maximo',
	@Telefono = 12345678915
GO
-- Insert Telefono invalido
EXEC infraestructura.InsertarSucursal
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 'Paco'
GO
-- Insert Telefono invalido
EXEC infraestructura.InsertarSucursal
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral' ,
	@Horario =  'PacoCentral',
	@Telefono = 'Aca solo que supere los 11, ya no quiero escribir tanto'
GO
-- Updates
-- Update valido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal = 1,
	@Direccion = 'Pacos' ,
	@Ciudad =  'PacoCentral2',
	@Horario = '13:55',
	@Telefono = 1155115511551
GO
-- Update Id invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  'Paco',
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551
GO
	-- Update Id invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  NULL,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551
GO
-- Update invalido, Id inexistetne
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  999999,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551
GO
-- Update ciudad invalida
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'Aca escribimos algo de mas de 20 carateres para asegurarnos superar el maximo',
	@Horario = '13:50',
	@Telefono = 1155115511551
GO
-- Update Horario invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = 'Aca escribimos algo de mas de 45 carateres para asegurarnos superar el maximo',
	@Telefono = 1155115511551
GO
-- Update telefono invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '18:30',
	@Telefono = '18:30'
GO
-- Update telefono invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '18:30',
	@Telefono = 999999999999

-- Delete
-- Delete valido
EXEC infraestructura.EliminarSucursal
	@IdSucursal = 1
GO
-- Delete invalido, ID inexistente
EXEC infraestructura.EliminarSucursal
	@IdSucursal = 999999
GO
-- Delete invalido, ID NULL
EXEC infraestructura.EliminarSucursal
	@IdSucursal = NULL
GO
-- Empleado
-- Insert valido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert Legajo invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = NULL,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert Legajo invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 'Paco',
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert Nombre invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Aca nuevamente escribimos algo de mas de 30 caracteres para asegurar que no cumpla',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert Apellido invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aca nuevamente escribimos algo de mas de 30 caracteres para asegurar que no cumpla',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert DNI invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 'Paco',
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert DNI invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Aca nuevamente escribimos algo de mas de 11 caracteres para asegurar que no cumpla',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert turno invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completaaaaaaaaaa',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert turno invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'JC',
	@cargo = 1,
	@sucursal = 1
GO
-- Insert Cargo invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 'Paco',
	@sucursal = 1
GO
-- Insert Cargo invalido
EXEC infraestructura.InsertarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquero',
	@DNI = 1,
	@Direccion = 'PacoCallejon',
	@EmailPersonal = 'Paco@terra.org',
	@EmailEmpresa = 'Paco@terra.org',
	@CUIL = 'Paco',
	@turno = 'Jornada Completa',
	@cargo = 1,
	@sucursal = 'Paco'
GO
-- Update
-- Update valido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Pacos',
	@Apellido = 'Elpaquerisimo',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Legajo invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = NULL,
	@Nombre = 'Pacos',
	@Apellido = 'Elpaquerisimo',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Legajo invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 'Paco',
	@Nombre = 'Pacos',
	@Apellido = 'Elpaquerisimo',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Legajo invalido, inexistente
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 999999,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Nombre invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Aca nuevamente escribimos algo de mas de 30 caracteres para asegurar que no cumpla',
	@Apellido = 'Elpaquerisimo',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Apellido invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aca nuevamente escribimos algo de mas de 30 caracteres para asegurar que no cumpla',
	@DNI = 2,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update DNI invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 'Paco',
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update CUIL invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'Aca nuevamente escribimos algo de mas de 11 caracteres para asegurar que no cumpla',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 2
GO
-- Update turno invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'JC',
	@cargo = 2,
	@sucursal = 2
GO
-- Update turno invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'Jornada Completaaaaaaa',
	@cargo = 2,
	@sucursal = 2
GO
-- Update Cargo invalido
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = NULL,
	@sucursal = 2
GO
-- Update Cargo invalido, inexistente
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 999999,
	@sucursal = 2
GO
-- Update Sucursal invalida, inexistente
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = 999999
GO
-- Update Sucursal invalida
EXEC infraestructura.ActualizarEmpleado
	@Legajo = 1,
	@Nombre = 'Paco',
	@Apellido = 'Elpaquerisimo',
	@DNI = 1,
	@Direccion = 'PacoCallezuela',
	@EmailPersonal = 'Paco@yahoo.org',
	@EmailEmpresa = 'Paco@yahoo.org',
	@CUIL = 'PacoRisimo',
	@turno = 'TM',
	@cargo = 2,
	@sucursal = NULL
GO
-- DELETE
-- Delete valido
EXEC infraestructura.EliminarEmpleado
	@Legajo = 1
GO
-- Delete invalido, Legajo inexistente
EXEC infraestructura.EliminarEmpleado
	@Legajo = 999999
GO
-- Delete invalido, Legajo NULL
EXEC infraestructura.EliminarEmpleado
	@Legajo = NULL
GO
-- Delete Legajo invalido
EXEC infraestructura.EliminarEmpleado
	@Legajo = 'Paco'
GO
--ESQUEMA FACTURACION
-- Facturacion
-- Insert Liena Venta
-- Insert valido
EXEC facturacion.InsertarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120
GO
-- Insert ID invalido
EXEC facturacion.InsertarLineaVenta
	@ID = 'Paco',
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120
GO
-- Insert ID invalido
EXEC facturacion.InsertarLineaVenta
	@ID = NULL,
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120
GO
-- Insert IdProducto invalido
EXEC facturacion.InsertarLineaVenta
	@ID = 1,
	@IdProducto = 'Paco',
	@Cantidad = 1,
	@Monto = 120
GO
-- Insert Cantidad invalida
EXEC facturacion.InsertarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 'Paco',
	@Monto = 120
GO
-- Insert Monto invalido
EXEC facturacion.InsertarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 5,
	@Monto = 'Paco'
GO
-- Insert Monto invalido
EXEC facturacion.InsertarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 5,
	@Monto = NULL
GO
-- Update
-- Update valido
EXEC facturacion.ActualizarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update ID invalido
EXEC facturacion.ActualizarLineaVenta
	@ID = 'Paco',
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update ID invalido
EXEC facturacion.ActualizarLineaVenta
	@ID = NULL,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarLineaVenta
	@ID = 999999,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update IdProducto invalido
EXEC facturacion.ActualizarLineaVenta
	@ID = 1,
	@IdProducto = NULL,
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update IdProducto invalido
EXEC facturacion.ActualizarLineaVenta
	@ID = 1,
	@IdProducto = 'Paco',
	@Cantidad = 10,
	@Monto = 1200
GO
-- Update Cantidadinvalida
EXEC facturacion.ActualizarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 'Paco',
	@Monto = 1200
GO
-- Update Cantidadinvalida
EXEC facturacion.ActualizarLineaVenta
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 20,
	@Monto = 'Paco'
GO
-- Delete
-- Delete valido
EXEC facturacion.EliminarLineaVenta
	@ID = 1,
	@IdProducto  = 1
GO
-- Delete ID invalido
EXEC facturacion.EliminarLineaVenta
	@ID = 999999,
	@IdProducto = 1
GO
-- Delete ID invalido
EXEC facturacion.EliminarLineaVenta
	@ID = NULL,
	@IdProducto = 1
GO
-- Delete ID invalido
EXEC facturacion.EliminarLineaVenta
	@ID = 1,
	@IdProducto = 999999
GO
-- Delete ID invalido
EXEC facturacion.EliminarLineaVenta
	@ID = 1,
	@IdProducto = NULL
GO
-- Venta
-- Insertar Venta valido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar ID invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Tipo valido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Tipo invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'UI',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Tipo invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'Aca escribimos un texto mayor a 50 a fin de que salga por error de tamaño invalido',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Numero invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 1234567891011,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Letra invalida
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'FC',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Letra invalida
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'Paco',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Fechainvalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Fechainvalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 03',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Hora invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,12799999999',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Insertar Empleado invalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 999999,
	@Pago = 1
GO
-- Insertar Pagoinvalido
EXEC facturacion.InsertarVenta
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 99999
GO
-- Update
-- Update valido
EXEC facturacion.ActualizarVenta
	@ID = 1,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarVenta
	@ID = 999999,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update ID invalido
EXEC facturacion.ActualizarVenta
	@ID = NULL,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Tipo invalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'UI',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Tipo invalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'Aca escribimos un texto mayor a 50 a fin de que salga por error de tamaño invalido',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Numero Invalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 1234567891011,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update LetraInvalida
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'FC',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Letra Invalida
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'Paco',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Numero Invalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 03',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Hora Invalida
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,12799999999',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1
GO
-- Update Empleado Invalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 999999,
	@Pago = 1
GO
-- Update PagoInvalido
EXEC facturacion.ActualizarVenta
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09',
	@Hora = '15:53:56,127',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 99999
GO
-- Delete
-- Delete valido
EXEC facturacion.EliminarVenta
	@ID = 2
GO
-- Delete invalido
EXEC facturacion.EliminarVenta
	@ID = NULL
GO
-- Delete invalido, inexistente
EXEC facturacion.EliminarVenta
	@ID = 999999
GO
--PAGO
-- Insert Pago valido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert IDPago invalido
EXEC facturacion.InsertarPago
	@IDPago = NULL,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert IDPago invalido, duplicado
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert  IdentificadorDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 'Aqui escribimos un texto que supere los 22 caracteres para asegurar todo',
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert IdentificadorDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert Fecha invalida
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-44-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Insert MedioDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = NULL
GO
-- Update
-- Update Pago valido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update ID invalido
EXEC facturacion.ActualizarPago
	@IDPago = NULL,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarPago
	@IDPago = 999999,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update IdentificadorDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 'Aqui escribimos un texto que supere los 22 caracteres para asegurar todo',
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update IdentificadorDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update Fecha invalida
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-44-09 15:53:56.127',
	@MedioDePago = 1
GO
-- Update MedioDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = NULL
GO
-- Delete
-- Delete valido
EXEC facturacion.EliminarPago
	@IDPago =1
GO
-- Delete invalido
EXEC facturacion.EliminarPago
	@IDPago = 990
GO
-- Delete invalido
EXEC facturacion.EliminarPago
	@IDPago =NULL
GO
-- Medio de Pago
-- Insert Medio de Pago
-- Insert valido
EXEC facturacion.InsertarMedioDePago
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'
GO
-- Insert ID invalido
EXEC facturacion.MedioDePago
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'
GO
-- Insert ID invalido
EXEC facturacion.InsertarMedioDePago
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'
GO
-- Insert nombre invalido
EXEC facturacion.InsertarMedioDePago
	@Nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion',
	@Descripcion = 'El Paco hace mal'
GO
-- Insert Descripcion invalida
EXEC facturacion.InsertarMedioDePago
	@Nombre = 'Paco',
	@Descripcion = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'
GO
-- Update
-- Update valido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Pacos',
	@Descripcion = 'El Paco hace muy mal'
GO
-- Update ID invalido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = NULL,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 999999,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'
GO
-- Update nombre invalido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion',
	@Descripcion = 'El Paco hace mal'
GO
-- Update Descripcion invalida
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Paco',
	@Descripcion = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'
GO
-- Delete
-- Delete valido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = 1
GO
-- Delete invalido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = NULL
GO
-- Delete invalido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = 'Paco'
GO
-- Insert Tipo de Cliente
-- Insert valido
EXEC facturacion.InsertarTipoCliente
	@nombre = 'Paco'
GO
-- Insert Nombre invalido
EXEC facturacion.InsertarTipoCliente
	@nombre = NULL
GO
-- Insert Nombre invalido
EXEC facturacion.InsertarTipoCliente
	@nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'
GO
-- Update
-- Update valido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Pacos'
GO
-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = NULL,
	@nombre = 'Paco'
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 999999,
	@nombre = 'Paco'
GO
-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 'Paco',
	@nombre = 'Paco'
GO
-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = NULLGO
GO
-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'
GO
-- Delete
-- Delete valido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = 1
GO
-- Delete invalido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = NULL
GO
-- Delete invalido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = 999999
GO
-- Insert cliente
-- Insert valido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Insert DNI invalido
EXEC facturacion.InsertarCliente
	@DNI = 'Paco',
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Insert Nombre invalido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Insert Apellido invalido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Insert Genero invalido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'P',
	@IDTipoCliente = 1
GO
-- Insert Genero invalido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 1
GO
-- Insert IDTipoCliente invalido
EXEC facturacion.InsertarCliente
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 'Paco'
GO
-- Insert IDTipoCliente invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = NULL
GO
-- Update 
-- Update valido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update ID invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = NULL,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update ID invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update ID invalido, inexistente
EXEC facturacion.ActualizarCliente
	@IDCliente = 999999,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update DNI invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 'Paco',
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update Nombre invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update Apellido invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Genero = 'M',
	@IDTipoCliente = 1
GO
-- Update Genero invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'P',
	@IDTipoCliente = 1
GO
-- Update Genero invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 1
GO
-- Update IDTipoCliente invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 'Paco'
GO
-- Update IDTipoCliente invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = NULL
GO
-- Delete
-- Delte valido
EXEC facturacion.EliminarCliente
	@IDCliente = 1
GO
-- Delte ID invalido
EXEC facturacion.EliminarCliente
	@IDCliente = NULL
GO
-- Delte ID invalido
EXEC facturacion.EliminarCliente
	@IDCliente = 'Paco'
GO
-- Delte ID invalido, inexistente
EXEC facturacion.EliminarCliente
	@IDCliente = 999999
GO