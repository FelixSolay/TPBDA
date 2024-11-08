/*
Creación de los Store procedures

Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.

*/
--Insert Store Procedures
use COM2900G09
go

CREATE OR ALTER PROCEDURE facturacion.InsertarPago
    @IdentificadorDePago VARCHAR(22),
    @Fecha DATETIME,
    @MedioDePago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Pago (IdentificadorDePago, Fecha, MedioDePago)
        VALUES (@IdentificadorDePago, @Fecha, @MedioDePago);
        
        COMMIT TRANSACTION;
        PRINT 'Pago insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarMedioDePago
    @Nombre VARCHAR(20),
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.MedioDePago (Nombre, Descripcion)
        VALUES (@Nombre, @Descripcion);
        
        COMMIT TRANSACTION;
        PRINT 'MedioDePago insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el MedioDePago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarCliente
    @DNI INT,
    @Nombre VARCHAR(25),
    @Apellido VARCHAR(25),
    @Genero CHAR(1),
    @IDTipoCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Cliente (DNI, Nombre, Apellido, Genero, IDTipoCliente)
        VALUES (@DNI, @Nombre, @Apellido, @Genero, @IDTipoCliente);
        
        COMMIT TRANSACTION;
        PRINT 'Cliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarTipoCliente @nombre VARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.TipoCliente (nombre)
        VALUES (@nombre);
        COMMIT TRANSACTION;
        PRINT 'TipoCliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el TipoCliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarLineaComprobante
    @ID INT,
    @IdProducto INT,
    @Cantidad INT,
    @Monto DECIMAL(9,2)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.LineaComprobante (ID, IdProducto, Cantidad, Monto)
        VALUES (@ID, @IdProducto, @Cantidad, @Monto);
        
        COMMIT TRANSACTION;
        PRINT 'LineaComprobante insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la LineaComprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.InsertarComprobante
    @tipo CHAR(2),
    @numero CHAR(11),
    @letra CHAR(1),
    @Fecha DATETIME,
    @Total DECIMAL(9,2),
    @Cliente INT,
    @Empleado INT,
    @Pago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO facturacion.Comprobante (tipo, numero, letra, Fecha, Total, Cliente, Empleado, Pago)
        VALUES (@tipo, @numero, @letra, @Fecha, @Total, @Cliente, @Empleado, @Pago);
        
        COMMIT TRANSACTION;
        PRINT 'Comprobante insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.InsertarCategoria
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO deposito.Categoria (Descripcion)
        VALUES (@Descripcion);
        
        COMMIT TRANSACTION;
        PRINT 'Categoría insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Categoría: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.InsertarProducto
    @Categoria INT,
    @Nombre VARCHAR(100),
    @Precio DECIMAL(9,2),
    @PrecioReferencia DECIMAL(9,2),
    @UnidadReferencia CHAR(2),
    @Fecha DATETIME
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO deposito.Producto (Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
        VALUES (@Categoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia, @Fecha);
        
        COMMIT TRANSACTION;
        PRINT 'Producto insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.InsertarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @DNI INT,
    @Direccion VARCHAR(100),
    @EmailPersonal VARCHAR(100),
    @EmailEmpresa VARCHAR(100),
    @CUIL CHAR(11),
    @Turno CHAR(16),
    @Cargo INT,
    @Sucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO infraestructura.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
        VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal);
        
        COMMIT TRANSACTION;
        PRINT 'Empleado insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.InsertarSucursal
    @Direccion VARCHAR(100),
    @Ciudad VARCHAR(20),
    @Horario CHAR(45),
    @Telefono CHAR(11)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO infraestructura.Sucursal (Direccion, Ciudad, Horario, Telefono)
        VALUES (@Direccion, @Ciudad, @Horario, @Telefono);
        
        COMMIT TRANSACTION;
        PRINT 'Sucursal insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.InsertarCargo
    @Descripcion VARCHAR(25)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO infraestructura.Cargo (Descripcion)
        VALUES (@Descripcion);
        
        COMMIT TRANSACTION;
        PRINT 'Cargo insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO


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