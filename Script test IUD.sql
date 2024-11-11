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
	@idcategoria = 999999

--  Producto
--      Insert valdio
EXEC deposito.InsertarProducto 
	@Categoria = 1,
	@Nombre = 'Aceite de Oliva',
	@Precio = 57.25,
	@PrecioReferencia = 57.25,
	@UnidadReferencia = 'ml',
	@Fecha = '2024-11-09 15:53:56.127';
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

	--Prueba insert invalido con Categira repetida
EXEC deposito.InsertarProducto 
	@Categoria = 1,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;

--	Prueba insert invalido con Categira invalida
EXEC deposito.InsertarProducto 
	@Categoria = 'Paco',
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;

--	Prueba insert invalido con Precio invalido
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 'Paco',
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;

--	Prueba insert invalido con PrecioReferencai invalido
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 'Paco',
	@UnidadReferencia = 'ml',
	@Fecha = @FechaActual;

--	Prueba insert invalido con UnidadReferencai invalida
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'Paco',
	@Fecha = @FechaActual;
	
--	Prueba insert invalido con Fecha invalida
EXEC deposito.InsertarProducto 
	@Categoria = 5,
	@Nombre = 'Paco',
	@Precio = 120,
	@PrecioReferencia = 2.5,
	@UnidadReferencia = 'Paco',
	@Fecha = 'Paco';
	
--      Update IdProducto valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'L'
	
--      Update IdProducto invalido 
EXEC deposito.ActualizarProducto 
	@IdProducto = 999,
	@UnidadReferencia = 'L'
	
--      Update categoria valida 
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@categoria = 20	
	
--      Update categoria invalida 
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@categoria = 'L'	

--      Update Precio valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@Precio = 120

--      Update Precio invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@Precio = 'L'

--      Update PrecioReferencia valido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@PrecioReferencia = 2,5

--      Update PrecioReferencia invalido
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@PrecioReferencia = 'L'

--      Update UnidadReferencia alida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'L'

--      Update UnidadReferencia invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@UnidadReferencia = 'Paco'
		
--      Update Fecha valida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@fecha = '2024-11-09 19:24:33.122'

--      Update Fecha invalida
EXEC deposito.ActualizarProducto 
	@IdProducto = 1,
	@fecha = 'L'

--      Delete
--	Prueba de eliminación valdia de un producto existente
EXEC deposito.EliminarProducto
	@IdProducto = 1

--	Prueba de eliminación invaldia de un producto inexistente
EXEC deposito.EliminarProducto
	@IdProducto = 999999

--ESQUEMA INFRAESTRUCTURA
-- Infraestructura Cargo
-- Insert valido
EXEC infraestructura.InsertarCargo
	@IdCargo = 1,
	@descripcion = 'Paco' 

-- Insert ID invalido
EXEC infraestructura.InsertarCargo
	@IdCargo = 'Paco',
	@descripcion = 'Paco' 

-- Insert descripción invalido
EXEC infraestructura.InsertarCargo
	@IdCargo = 1,
	@descripcion = 'aca ponemos una descripcion de mas de 25 caracteres para asegurarnos de que sea invalida y que no se cree' 

-- Updates
-- Update valido
EXEC infraestructura.ActualizarCargo
	@IdCargo = 1,
	@descripcion = 'Pacos' 

-- Update ID invalido
EXEC infraestructura.ActualizarCargo
	@IdCargo = 'Pacos',
	@descripcion = 'Paco' 

-- Update descripcion invalida
EXEC infraestructura.ActualizarCargo
	@IdCargo = 'Pacos',
	@descripcion = 'aca ponemos una descripcion de mas de 25 caracteres para asegurarnos de que sea invalida y que no se cree'
	
--Delete
-- Delete valido
EXEC infraestructura.EliminarCargo
	@IdCargo = 1,
	
-- Delete invalido, Id inexistente 
EXEC infraestructura.EliminarCargo
	@IdCargo = 999999,

-- Delete invalido, Id inexistente 
EXEC infraestructura.EliminarCargo
	@IdCargo = NULL,

-- Sucursal
-- Insert valido
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 12345678915

-- Insert Id invalido
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 'Paco',
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 12345678915

-- Insert Ciudad invalida
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 1,
	@Direccion = 'Paco' ,
	@Ciudad =  'Aca escribimos algo de mas de 25 carateres para asegurarnos superar el maximo',
	@Horario = '13:50',
	@Telefono = 12345678915

-- Insert Horario invalido
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = 'Aca escribimos algo de mas de 45 carateres para asegurarnos superar el maximo',
	@Telefono = 12345678915
	
-- Insert Telefono invalido
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 'Paco'
	
-- Insert Telefono invalido
EXEC infraestructura.InsertarSucursal
	@IDsucursal = 1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral' ,
	@Horario =  'PacoCentral',
	@Telefono = 'Aca solo que supere los 11, ya no queire escribir tanto'

-- Updates
-- Update valido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal = 1,
	@Direccion = 'Pacos' ,
	@Ciudad =  'PacoCentral2',
	@Horario = '13:55',
	@Telefono = 1155115511551

-- Update Id invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  'Paco',
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551

	-- Update Id invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  NULL,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551

-- Update invalido, Id inexistetne
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  999999,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral',
	@Horario = '13:50',
	@Telefono = 1155115511551

-- Update ciudad invalida
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'Aca escribimos algo de mas de 20 carateres para asegurarnos superar el maximo',
	@Horario = '13:50',
	@Telefono = 1155115511551

-- Update Horario invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral'
	@Horario = 'Aca escribimos algo de mas de 45 carateres para asegurarnos superar el maximo',
	@Telefono = 1155115511551

-- Update telefono invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral'
	@Horario = '18:30',
	@Telefono = '18:30'

-- Update telefono invalido
EXEC infraestructura.ActualizarSucursal
	@IDsucursal =  1,
	@Direccion = 'Paco' ,
	@Ciudad =  'PacoCentral'
	@Horario = '18:30',
	@Telefono = 999999999999

-- Delete
-- Delete valido
EXEC infraestructura.EliminarSucursal
	@IdSucursal = 1,

-- Delete invalido, ID inexistente
EXEC infraestructura.EliminarSucursal
	@IdSucursal = 999999,

-- Delete invalido, ID NULL
EXEC infraestructura.EliminarSucursal
	@IdSucursal = NULL,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 1,

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
	@sucursal = 'Paco',

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
	@sucursal = 2,
	
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
	@sucursal = 2,

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
	@sucursal = 2,

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
	@sucursal = 2,

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
	@sucursal = 2,
	
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
	@sucursal = 2,	

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
	@sucursal = 2,
	
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
	@sucursal = 2,

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
	@sucursal = 2,
	
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
	@sucursal = 2,

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
	@sucursal = 2,

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
	@sucursal = 2,

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
	@sucursal = 999999,
	
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
	@sucursal = NULL,

-- DELETE
-- Delete valido
EXEC infraestructura.EliminarEmpleado
	@Legajo = 1,

-- Delete invalido, Legajo inexistente
EXEC infraestructura.EliminarEmpleado
	@Legajo = 999999,

-- Delete invalido, Legajo NULL
EXEC infraestructura.EliminarEmpleado
	@Legajo = NULL,

-- Delete Legajo invalido
EXEC infraestructura.EliminarEmpleado
	@Legajo = 'Paco',

--ESQUEMA FACTURACION
-- Facturacion
-- Insert Liena Comprobante
-- Insert valido
EXEC facturacion.InsertarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120,

- Insert ID invalido
EXEC facturacion.InsertarLineaComprobante
	@ID = 'Paco',
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120,

- Insert ID invalido
EXEC facturacion.InsertarLineaComprobante
	@ID = NULL,
	@IdProducto = 1,
	@Cantidad = 1,
	@Monto = 120,

- Insert IdProducto invalido
EXEC facturacion.InsertarLineaComprobante
	@ID = 1,
	@IdProducto = 'Paco',
	@Cantidad = 1,
	@Monto = 120,

- Insert Cantidad invalida
EXEC facturacion.InsertarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 'Paco',
	@Monto = 120,

- Insert Monto invalido
EXEC facturacion.InsertarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 5,
	@Monto = 'Paco',

- Insert Monto invalido
EXEC facturacion.InsertarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 5,
	@Monto = NULL,

-- Update
-- Update valido
EXEC facturacion.ActualizarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200,

-- Update ID invalido
EXEC facturacion.ActualizarLineaComprobante
	@ID = 'Paco',
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200,

-- Update ID invalido
EXEC facturacion.ActualizarLineaComprobante
	@ID = NULL,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200,

-- Update ID invalido, inexistente
EXEC facturacion.ActualizarLineaComprobante
	@ID = 999999,
	@IdProducto = 1,
	@Cantidad = 10,
	@Monto = 1200,

-- Update IdProducto invalido
EXEC facturacion.ActualizarLineaComprobante
	@ID = 1,
	@IdProducto = NULL,
	@Cantidad = 10,
	@Monto = 1200,

-- Update IdProducto invalido
EXEC facturacion.ActualizarLineaComprobante
	@ID = 1,
	@IdProducto = 'Paco',
	@Cantidad = 10,
	@Monto = 1200,

-- Update Cantidadinvalida
EXEC facturacion.ActualizarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 'Paco',
	@Monto = 1200,

-- Update Cantidadinvalida
EXEC facturacion.ActualizarLineaComprobante
	@ID = 1,
	@IdProducto = 1,
	@Cantidad = 20,
	@Monto = 'Paco',

-- Delete
-- Delete valido
EXEC facturacion.EliminarLineaComprobante
	@ID = 1,
	@IdProducto  = 1,

-- Delete ID invalido
EXEC facturacion.EliminarLineaComprobante
	@ID = 999999,
	@IdProducto = 1,

-- Delete ID invalido
EXEC facturacion.EliminarLineaComprobante
	@ID = NULL,
	@IdProducto = 1,

-- Delete ID invalido
EXEC facturacion.EliminarLineaComprobante
	@ID = 1,
	@IdProducto = 999999,

-- Delete ID invalido
EXEC facturacion.EliminarLineaComprobante
	@ID = 1,
	@IdProducto = NULL

-- Comprobante
-- Insertar Comprobante valido
EXEC facturacion.InsertarComprobante
	@ID = 1,
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,


-- Insertar ID invalido
EXEC facturacion.InsertarComprobante
	@ID = NULL,
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Tipo valido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Tipo invalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'UI',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Tipo invalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'Aca escribimos un texto mayor a 50 a fin de que salga por error de tamaño invalido',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Numero invalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 1234567891011,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Letra invalida
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'FC',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Letra invalida
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'Paco',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Fechainvalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-14-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Fechainvalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 03',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Hora invalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,000000000000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Insertar Empleado invalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 999999,
	@Pago = 1,

-- Insertar Pagoinvalido
EXEC facturacion.InsertarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 99999,

-- Update
-- Update valido
EXEC facturacion.ActualizarComprobante
	@ID = 1,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update ID invalido, inexistente
EXEC facturacion.ActualizarComprobante
	@ID = 999999,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update ID invalido
EXEC facturacion.ActualizarComprobante
	@ID = NULL,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Tipo invalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'UI',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Tipo invalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'Aca escribimos un texto mayor a 50 a fin de que salga por error de tamaño invalido',
	@Numero = 11223344556,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Numero Invalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 1234567891011,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update LetraInvalida
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'FC',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Letra Invalida
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'Paco',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Numero Invalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 03',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Hora Invalida
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,000000000000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 1,

-- Update Empleado Invalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 999999,
	@Pago = 1,

-- Update PagoInvalido
EXEC facturacion.ActualizarComprobante
	@ID = 2,
	@Tipo = 'FC',
	@Numero = 12345678910,
	@Letra = 'A',
	@Fecha = '2024-11-09 15:53:56.127',
	@Hora = '00:00:00,0000000',
	@Total = 120,
	@Cliente = 1,
	@Empleado = 1,
	@Pago = 99999,

-- Delete
-- Delete valido
EXEC facturacion.EliminarComprobante
	@ID = 2,

-- Delete invalido
EXEC facturacion.EliminarComprobante
	@ID = NULL,

-- Delete invalido, inexistente
EXEC facturacion.EliminarComprobante
	@ID = 999999,

--PAGO
-- Insert Pago valido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

-- Insert IDPago invalido
EXEC facturacion.InsertarPago
	@IDPago = NULL,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,


-- Insert IDPago invalido, duplicado
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

-- Insert  IdentificadorDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 'Aqui escribimos un texto que supere los 22 caracteres para asegurar todo',
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

-- Insert IdentificadorDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

-- Insert Fecha invalida
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-44-09 15:53:56.127',
	@MedioDePago = 1,

-- Insert MedioDePago invalido
EXEC facturacion.InsertarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = NULL,

-- Update
-- Update Pago valido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

-- Update ID invalido
EXEC facturacion.ActualizarPago
	@IDPago = NULL,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,


-- Update ID invalido, inexistente
EXEC facturacion.ActualizarPago
	@IDPago = 999999,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = 1,

Update IdentificadorDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 'Aqui escribimos un texto que supere los 22 caracteres para asegurar todo',
	@Fecha = '2024-11-09 15:53:56.127'
	@MedioDePago = 1,

-- Update IdentificadorDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127'
	@MedioDePago = 1,

-- Update Fecha invalida
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-44-09 15:53:56.127',
	@MedioDePago = 1,

-- Update MedioDePago invalido
EXEC facturacion.ActualizarPago
	@IDPago = 1,
	@IdentificadorDePago = 12,
	@Fecha = '2024-11-09 15:53:56.127',
	@MedioDePago = NULL,

-- Delete
-- Delete valido
EXEC facturacion.EliminarPago
	@IDPago =1

-- Delete invalido
EXEC facturacion.EliminarPago
	@IDPago = 990

-- Delete invalido
EXEC facturacion.EliminarPago
	@IDPago =NULL

-- Medio de Pago
-- Insert Medio de Pago
-- Insert valido
EXEC facturacion.InsertarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'

-- Insert ID invalido
EXEC facturacion.MedioDePago
	@IDMedioDePago = NULL,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'

-- Insert ID invalido
EXEC facturacion.InsertarMedioDePago
	@IDMedioDePago = 'Paco',
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'

-- Insert nombre invalido
EXEC facturacion.InsertarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion',
	@Descripcion = 'El Paco hace mal'

-- Insert Descripcion invalida
EXEC facturacion.InsertarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Paco',
	@Descripcion = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'

-- Update
-- Update valido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Pacos',
	@Descripcion = 'El Paco hace muy mal'

-- Update ID invalido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = NULL,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'

-- Update ID invalido, inexistente
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 999999,
	@Nombre = 'Paco',
	@Descripcion = 'El Paco hace mal'

-- Update nombre invalido
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion',
	@Descripcion = 'El Paco hace mal'

-- Update Descripcion invalida
EXEC facturacion.ActualizarMedioDePago
	@IDMedioDePago = 1,
	@Nombre = 'Paco',
	@Descripcion = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'

-- Delete
-- Delete valido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = 1,

-- Delete invalido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = NULL,

-- Delete invalido
EXEC facturacion.EliminarMedioDePago
	@IDMedioDePago = 'Paco',

-- Insert Tipo de Cliente
-- Insert valido
EXEC facturacion.InsertarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Paco',

-- Insert ID invalido
EXEC facturacion.InsertarTipoCliente
	@IDTipoCliente = NULL,
	@nombre = 'Paco',

-- Insert ID invalido
EXEC facturacion.InsertarTipoCliente
	@IDTipoCliente = 'Paco',
	@nombre = 'Paco',

-- Insert ID invalido
EXEC facturacion.InsertarTipoCliente
	@IDTipoCliente = 1,
	@nombre = NULL,

-- Insert ID invalido
EXEC facturacion.InsertarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'

-- Update
-- Update valido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Pacos',

-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = NULL,
	@nombre = 'Paco',

-- Update ID invalido, inexistente
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 999999,
	@nombre = 'Paco',

-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 'Paco',
	@nombre = 'Paco',

-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = NULL,

-- Update ID invalido
EXEC facturacion.ActualizarTipoCliente
	@IDTipoCliente = 1,
	@nombre = 'Aqui escribimos un texto que supere los 50 caracteres, de esta manera el mismo texto me sirve para el test de nombre y descripcion, y no tengo que pesnar en otra redaccion'

-- Delete
-- Delete valido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = 1,

-- Delete invalido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = NULL,

-- Delete invalido
EXEC facturacion.EliminarTipoCliente
	@IDTipoCliente = 999999,

-- Insert cliente
-- Insert valido
EXEC facturacion.InsertarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert ID invalido
EXEC facturacion.InsertarCliente
	@IDCliente = NULL,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert ID invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert DNI invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 1,
	@DNI = 'Paco',
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert Nombre invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert Apellido invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Insert Genero invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'P',
	@IDTipoCliente = 1,

-- Insert Genero invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 1,

-- Insert IDTipoCliente invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 'Paco',

-- Insert IDTipoCliente invalido
EXEC facturacion.InsertarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = NULL,

-- Update 
-- Update valido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update ID invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = NULL,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update ID invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update ID invalido, inexistente
EXEC facturacion.ActualizarCliente
	@IDCliente = 999999,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update DNI invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 'Paco',
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update Nombre invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Apellido = 'Paco',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update Apellido invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 1,
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Aqui escribimos un texto que supere los 25 caracteres, de esta manera el mismo texto me sirve para el test de nombre y apellido',
	@Genero = 'M',
	@IDTipoCliente = 1,

-- Update Genero invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 'P',
	@IDTipoCliente = 1,

-- Update Genero invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 1,

-- Update IDTipoCliente invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = 'Paco',

-- Update IDTipoCliente invalido
EXEC facturacion.ActualizarCliente
	@IDCliente = 'Paco',
	@DNI = 1,
	@Nombre = 'Paco',
	@Apellido = 'Paco',
	@Genero = 1,
	@IDTipoCliente = NULL,

-- Delete
-- Delte valido
EXEC facturacion.ElimiarCliente
	@IDCliente = 1,

-- Delte ID invalido
EXEC facturacion.ElimiarCliente
	@IDCliente = NULL,

-- Delte ID invalido
EXEC facturacion.ElimiarCliente
	@IDCliente = 'Paco',

-- Delte ID invalido, inexistente
EXEC facturacion.ElimiarCliente
	@IDCliente = 999999,
