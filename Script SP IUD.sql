/*
Creación de los Store procedures

Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.

*/
--Insert Store Procedures
use AuroraVentas
go

CREATE OR ALTER PROCEDURE ddbba.insertarCargo
	@Descripcion varchar(50)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Cargo values (@Descripcion)
		COMMIT TRANSACTION;
		PRINT 'Cargo Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cargo: ' + ERROR_MESSAGE();
    END CATCH;
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarSucursal
	@Direccion 	nvarchar(100),
	@Ciudad 	varchar(20),
	@Horario 	varchar(50),
	@Telefono 	varchar(15)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Sucursal values (@Direccion, @Ciudad, @Horario, @Telefono)
		COMMIT TRANSACTION;
		PRINT 'Sucursal Insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Sucursal: ' + ERROR_MESSAGE();
    END CATCH;		
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarEmpleado
	@Legajo INT,
	@Nombre nvarchar(20),
	@Apellido nvarchar(20),
	@DNI int,
	@Direccion nvarchar(100),
	@EmailPersonal varchar(50),
	@EmailEmpresa varchar(50),
	@CUIL char(11),
	@Turno char (16),
	@Cargo int,
	@Sucursal int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Empleado  values (@legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal)
		COMMIT TRANSACTION;
		PRINT 'Empleado Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarTipoCliente
	@TipoCliente char(6),
	@Descripcion varchar(50)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.TipoCliente values (@TipoCliente, @Descripcion)
		COMMIT TRANSACTION;
		PRINT 'Tipo de Cliente Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;	
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarCliente
	@DNI int,
	@Nombre varchar(20),
	@Apellido varchar(20),
	@Genero char,
	@IDTipoCliente int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Cliente values (@DNI, @Nombre, @Apellido, @Genero, @IDtipoCliente)
		COMMIT TRANSACTION;
		PRINT 'Cliente Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
	
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarMedioDePago
	@Nombre char(20),
	@Descripcion char(25)
as	
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.MedioDePago values (@Nombre, @Descripcion)
		COMMIT TRANSACTION;
		PRINT 'Medio de Pago Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Medio de Pago: ' + ERROR_MESSAGE();
    END CATCH;
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarPago
	@IdentificadorDePago char(25),
	@Fecha date,
	@MedioDePago int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Pago values (@IdentificadorDePago, @Fecha, @MedioDePago)
		COMMIT TRANSACTION;
		PRINT 'Pago Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarVenta
	@Factura int,
	@TipoFactura char(11),
	@Fecha date,
	@Hora time,
	@Total decimal(9,2),
	@Cliente int,
	@Empleado int,
	@Pago int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Venta values (@Factura, @TipoFactura, @Fecha, @Hora, @Total, @Cliente, @Empleado, @Pago)
		COMMIT TRANSACTION;
		PRINT 'Venta Insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Venta: ' + ERROR_MESSAGE();
    END CATCH;
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarCategoria 
	@Descripcion varchar(50)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Categoria values (@Descripcion)
		COMMIT TRANSACTION;
		PRINT 'Categoria Insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Categoria: ' + ERROR_MESSAGE();
    END CATCH;	
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarProducto
	@IDCategoria int,
	@Nombre varchar(100),
	@Precio decimal (9,2),
	@PrecioReferencia decimal (9,2),
	@UnidadReferencia varchar(2),
	@Fecha datetime
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Producto values (@IDCategoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia, @Fecha)
		COMMIT TRANSACTION;
		PRINT 'Producto Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Producto: ' + ERROR_MESSAGE();
    END CATCH;	
end
go

CREATE OR ALTER PROCEDURE ddbba.insertarLineaVenta
	@IDVenta int,
	@Orden int,
	@Cantidad int,
	@Monto decimal (9,2),
	@Producto int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.LineaVenta values (@IDVenta, @Orden, @Cantidad, @Monto, @Producto)
		COMMIT TRANSACTION;
		PRINT 'Linea de venta Insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Linea de Venta: ' + ERROR_MESSAGE();
    END CATCH;		
end
go


/*--Sp Registro
CREATE OR ALTER PROCEDURE ddbba.InsertarLog
	@modulo varchar(20),
	@texto varchar(20)
AS
BEGIN
	INSERT INTO ddbba.Registro VALUES (GETDATE(), @modulo, @texto)
END
*/


--Sp eliminar producto
CREATE OR ALTER PROCEDURE ddbba.EliminarProducto
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.producto WHERE IDProducto = @IDProducto)
        BEGIN
            DELETE FROM ddbba.producto WHERE IDProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Producto eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Producto con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--Sp Delete Linea Venta
CREATE OR ALTER PROCEDURE ddbba.EliminarLineaVenta
    @IDVenta INT,
    @Orden INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.lineaVenta WHERE IDVenta = @IDVenta AND Orden = @Orden)
        BEGIN
            DELETE FROM ddbba.lineaVenta WHERE IDVenta = @IDVenta AND Orden = @Orden;
            COMMIT TRANSACTION;
            PRINT 'Linea de Venta eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Linea de Venta con el IDVenta y Orden especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Linea de Venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarCategoria
    @IDCategoria INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            DELETE FROM ddbba.categoria WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Categoria con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarVenta
    @IDVenta INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.venta WHERE IDVenta = @IDVenta)
        BEGIN
            DELETE FROM ddbba.venta WHERE IDVenta = @IDVenta;
            COMMIT TRANSACTION;
            PRINT 'Venta eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Venta con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarPago
    @IDPago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.Pago WHERE IDPago = @IDPago)
        BEGIN
            DELETE FROM ddbba.Pago WHERE IDPago = @IDPago;
            COMMIT TRANSACTION;
            PRINT 'Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarMedioDePago
    @IDMedioDePago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            DELETE FROM ddbba.MedioDePago WHERE IDMedioDePago = @IDMedioDePago;
            COMMIT TRANSACTION;
            PRINT 'Medio De Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Medio De Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Medio De Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarCliente
    @IDCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.cliente WHERE IDCliente = @IDCliente)
        BEGIN
            DELETE FROM ddbba.cliente WHERE IDCliente = @IDCliente;
            COMMIT TRANSACTION;
            PRINT 'Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarTipoCliente
    @IDTipoCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            DELETE FROM ddbba.TipoCliente WHERE IDTipoCliente = @IDTipoCliente;
            COMMIT TRANSACTION;
            PRINT 'Tipo de Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Tipo de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarEmpleado
    @Legajo INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.empleado WHERE Legajo = @Legajo)
        BEGIN
            DELETE FROM ddbba.empleado WHERE Legajo = @Legajo;
            COMMIT TRANSACTION;
            PRINT 'Empleado eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Empleado con el Legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarSucursal
    @IDsucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE IDsucursal = @IDsucursal)
        BEGIN
            DELETE FROM ddbba.sucursal WHERE IDsucursal = @IDsucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Sucursal con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.EliminarCargo
    @IdCargo INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.cargo WHERE IdCargo = @IdCargo)
        BEGIN
            DELETE FROM ddbba.cargo WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Cargo con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--Update Store procedures

CREATE OR ALTER PROCEDURE ddbba.ActualizarProducto
    @IDProducto INT,
	@CategoriaDescripcion VARCHAR(50) = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia VARCHAR(2) = NULL,
    @Fecha DATETIME = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verifica que el producto exista antes de intentar actualizarlo
        IF EXISTS (SELECT 1 FROM ddbba.producto WHERE IDProducto = @IDProducto)
        BEGIN
            -- Actualiza solo los campos que no son NULL, conservando los valores actuales en los campos no especificados
            UPDATE ddbba.producto
            SET Nombre = COALESCE(@Nombre, Nombre),
				CategoriaDescripcion = COALESCE(@CategoriaDescripcion, CategoriaDescripcion),
                Precio = COALESCE(@Precio, Precio),
                PrecioReferencia = COALESCE(@PrecioReferencia, PrecioReferencia),
                UnidadReferencia = COALESCE(@UnidadReferencia, UnidadReferencia),
                Fecha = COALESCE(@Fecha, Fecha)
            WHERE IDProducto = @IDProducto;

            -- Confirma la transacción si no hay errores
            COMMIT TRANSACTION;
            PRINT 'Producto actualizado correctamente';
        END
        ELSE
        BEGIN
            PRINT 'No se encontró un producto con el ID especificado';
            ROLLBACK TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Deshace la transacción en caso de error
        ROLLBACK TRANSACTION;
        PRINT 'Error al actualizar el producto';
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarLineaVenta
    @IDVenta INT,
	@Orden INT,
    @Cantidad INT = NULL,
    @Monto DECIMAL(9,2) = NULL,
    @Producto INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verifica que el producto exista antes de intentar actualizarlo
        IF EXISTS (SELECT 1 FROM ddbba.LineaVenta WHERE IDVenta = @IDVenta AND Orden = @Orden)
        BEGIN
            -- Actualiza solo los campos que no son NULL, conservando los valores actuales en los campos no especificados
            UPDATE ddbba.LineaVenta
            SET Cantidad = COALESCE(@Cantidad, Cantidad),
                Monto = COALESCE(@Monto, Monto),
                Producto = COALESCE(@Producto, Producto)
            WHERE Producto = @Producto;
            -- Confirma la transacción si no hay errores
            COMMIT TRANSACTION;
            PRINT 'Linea de venta actualizada correctamente';
        END
        ELSE
        BEGIN
            PRINT 'No se encontró una Linea de venta con el ID especificado';
            ROLLBACK TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        -- Deshace la transacción en caso de error
        ROLLBACK TRANSACTION;
        PRINT 'Error al actualizar la linea de venta: ' + ERROR_MESSAGE();;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarCargo
    @IdCargo INT,
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.cargo WHERE IdCargo = @IdCargo)
        BEGIN
            UPDATE ddbba.cargo
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de cargo con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarSucursal
    @IDsucursal INT,
    @Direccion NVARCHAR(100) = NULL,
    @Ciudad VARCHAR(20) = NULL,
    @Horario NVARCHAR(50) = NULL,
    @Telefono VARCHAR(15) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.sucursal WHERE IDsucursal = @IDsucursal)
        BEGIN
            UPDATE ddbba.sucursal
            SET Direccion = COALESCE(@Direccion, Direccion),
                Ciudad = COALESCE(@Ciudad, Ciudad),
                Horario = COALESCE(@Horario, Horario),
                Telefono = COALESCE(@Telefono, Telefono)
            WHERE IDsucursal = @IDsucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de sucursal con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarEmpleado
    @Legajo INT,
    @Nombre NVARCHAR(20) = NULL,
    @Apellido NVARCHAR(20) = NULL,
    @DNI INT = NULL,
    @Direccion NVARCHAR(100) = NULL,
    @EmailPersonal NVARCHAR(50) = NULL,
    @EmailEmpresa NVARCHAR(50) = NULL,
    @CUIL CHAR(11) = NULL,
    @Turno CHAR(16) = NULL,
    @Cargo INT = NULL,
    @Sucursal INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.empleado WHERE Legajo = @Legajo)
        BEGIN
            UPDATE ddbba.empleado
            SET Nombre = COALESCE(@Nombre, Nombre),
                Apellido = COALESCE(@Apellido, Apellido),
                DNI = COALESCE(@DNI, DNI),
                Direccion = COALESCE(@Direccion, Direccion),
                EmailPersonal = COALESCE(@EmailPersonal, EmailPersonal),
                EmailEmpresa = COALESCE(@EmailEmpresa, EmailEmpresa),
                CUIL = COALESCE(@CUIL, CUIL),
                Turno = COALESCE(@Turno, Turno),
                Cargo = COALESCE(@Cargo, Cargo),
                Sucursal = COALESCE(@Sucursal, Sucursal)
            WHERE Legajo = @Legajo;
            COMMIT TRANSACTION;
            PRINT 'Empleado actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de empleado con el Legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarTipoCliente
    @IDTipoCliente INT,
    @TipoCliente char(6),
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            UPDATE ddbba.TipoCliente
            SET Descripcion = COALESCE(@Descripcion, Descripcion),
                TipoCliente = COALESCE(@TipoCliente, TipoCliente)
            WHERE IDTipoCliente = @IDTipoCliente;
            COMMIT TRANSACTION;
            PRINT 'Tipo de Cliente actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Tipo de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarCliente
    @IDCliente INT,
    @DNI INT = NULL,
    @Nombre VARCHAR(20) = NULL,
    @Apellido VARCHAR(20) = NULL,
    @Genero CHAR = NULL,
    @IDTipoCliente INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.cliente WHERE IDCliente = @IDCliente)
        BEGIN
            UPDATE ddbba.cliente
            SET DNI = COALESCE(@DNI, DNI),
                Nombre = COALESCE(@Nombre, Nombre),
                Apellido = COALESCE(@Apellido, Apellido),
                Genero = COALESCE(@Genero, Genero),
                IDTipoCliente = COALESCE(@IDTipoCliente, IDTipoCliente)
            WHERE IDCliente = @IDCliente;
            COMMIT TRANSACTION;
            PRINT 'Cliente actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarMedioDePago
    @IDMedioDePago INT,
    @Nombre CHAR(20) = NULL,
    @Descripcion CHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            UPDATE ddbba.MedioDePago
            SET Nombre = COALESCE(@Nombre, Nombre),
                Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDMedioDePago = @IDMedioDePago;
            COMMIT TRANSACTION;
            PRINT 'Medio De Pago actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de Medio De Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el Medio De Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarPago
    @IDPago INT,
    @IdentificadorDePago VARCHAR(22) = NULL,
    @Fecha DATE = NULL,
    @MedioDePago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.Pago WHERE IDPago = @IDPago)
        BEGIN
            UPDATE ddbba.Pago
            SET IdentificadorDePago = COALESCE(@IdentificadorDePago, IdentificadorDePago),
                Fecha = COALESCE(@Fecha, Fecha),
                MedioDePago = COALESCE(@MedioDePago, MedioDePago)
            WHERE IDPago = @IDPago;
            COMMIT TRANSACTION;
            PRINT 'Pago actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarVenta
    @IDVenta INT,
    @Factura INT = NULL,
    @TipoFactura CHAR = NULL,
    @Fecha DATE = NULL,
    @Total DECIMAL(9,2) = NULL,
    @Cliente INT = NULL,
    @Empleado INT = NULL,
    @Pago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.venta WHERE IDVenta = @IDVenta)
        BEGIN
            UPDATE ddbba.venta
            SET Factura = COALESCE(@Factura, Factura),
                TipoFactura = COALESCE(@TipoFactura, TipoFactura),
                Fecha = COALESCE(@Fecha, Fecha),
                Total = COALESCE(@Total, Total),
                Cliente = COALESCE(@Cliente, Cliente),
                Empleado = COALESCE(@Empleado, Empleado),
                Pago = COALESCE(@Pago, Pago)
            WHERE IDVenta = @IDVenta;
            COMMIT TRANSACTION;
            PRINT 'Venta actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de venta con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la venta: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE ddbba.ActualizarCategoria
    @IDCategoria INT,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            UPDATE ddbba.categoria
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontró el registro de categoria con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO