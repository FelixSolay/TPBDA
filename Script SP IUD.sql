/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.

*/

use COM2900G09
go

--Insert Store Procedures
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
        PRINT 'Medio De Pago insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Medio De Pago: ' + ERROR_MESSAGE();
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
        PRINT 'Tipo de Cliente insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Tipo de Cliente: ' + ERROR_MESSAGE();
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
        PRINT 'Linea de Comprobante insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Linea de Comprobante: ' + ERROR_MESSAGE();
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
        PRINT 'Categoria insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Categoria: ' + ERROR_MESSAGE();
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


--Delete Stored Procedures
CREATE OR ALTER PROCEDURE deposito.EliminarProducto
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.producto WHERE IDProducto = @IDProducto)
        BEGIN
            DELETE FROM deposito.producto WHERE IDProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Producto eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Producto con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarLineaComprobante
    @ID INT,
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IDProducto)
        BEGIN
            DELETE FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Linea de Comprobante eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Linea de Comprobante con el ID y Producto especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Linea de Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.EliminarCategoria
    @IDCategoria INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            DELETE FROM deposito.categoria WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Categoria con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarComprobante
    @ID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.comprobante WHERE ID = @ID)
        BEGIN
            DELETE FROM facturacion.comprobante WHERE ID = @ID;
            COMMIT TRANSACTION;
            PRINT 'Comprobante eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Comprobante con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarPago
    @IDPago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            DELETE FROM facturacion.Pago WHERE IDPago = @IDPago;
            COMMIT TRANSACTION;
            PRINT 'Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarMedioDePago
    @IDMedioDePago INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            DELETE FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago;
            COMMIT TRANSACTION;
            PRINT 'Medio De Pago eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Medio De Pago con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Medio De Pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarCliente
    @IDCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.cliente WHERE IDCliente = @IDCliente)
        BEGIN
            DELETE FROM facturacion.cliente WHERE IDCliente = @IDCliente;
            COMMIT TRANSACTION;
            PRINT 'Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.EliminarTipoCliente
    @IDTipoCliente INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            DELETE FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente;
            COMMIT TRANSACTION;
            PRINT 'Tipo de Cliente eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Tipo de Cliente con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarEmpleado
    @Legajo INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.empleado WHERE Legajo = @Legajo)
        BEGIN
            DELETE FROM infraestructura.empleado WHERE Legajo = @Legajo;
            COMMIT TRANSACTION;
            PRINT 'Empleado eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Empleado con el Legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarSucursal
    @IDsucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal)
        BEGIN
            DELETE FROM infraestructura.sucursal WHERE IDsucursal = @IDsucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Sucursal con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.EliminarCargo
    @IdCargo INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.cargo WHERE IdCargo = @IdCargo)
        BEGIN
            DELETE FROM infraestructura.cargo WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Cargo con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

--Update Store procedures

CREATE OR ALTER PROCEDURE deposito.ActualizarProducto
    @IDProducto INT,
    @Categoria INT = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia CHAR(2) = NULL,
    @Fecha DATETIME = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Producto WHERE IDProducto = @IDProducto)
        BEGIN
            UPDATE deposito.Producto
            SET Categoria = COALESCE(@Categoria, Categoria),
                Nombre = COALESCE(@Nombre, Nombre),
                Precio = COALESCE(@Precio, Precio),
                PrecioReferencia = COALESCE(@PrecioReferencia, PrecioReferencia),
                UnidadReferencia = COALESCE(@UnidadReferencia, UnidadReferencia),
                Fecha = COALESCE(@Fecha, Fecha)
            WHERE IDProducto = @IDProducto;            
            COMMIT TRANSACTION;
            PRINT 'Producto actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el producto con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.ActualizarCategoria
    @IDCategoria INT,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            UPDATE deposito.Categoria
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la categoria con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarCargo
    @IdCargo INT,
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Cargo WHERE IdCargo = @IdCargo)
        BEGIN
            UPDATE infraestructura.Cargo
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IdCargo = @IdCargo;
            COMMIT TRANSACTION;
            PRINT 'Cargo actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el cargo con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cargo: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarSucursal
    @IDSucursal INT,
    @Direccion VARCHAR(100) = NULL,
    @Ciudad VARCHAR(20) = NULL,
    @Horario CHAR(45) = NULL,
    @Telefono CHAR(11) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Sucursal WHERE IDSucursal = @IDSucursal)
        BEGIN
            UPDATE infraestructura.Sucursal
            SET Direccion = COALESCE(@Direccion, Direccion),
                Ciudad = COALESCE(@Ciudad, Ciudad),
                Horario = COALESCE(@Horario, Horario),
                Telefono = COALESCE(@Telefono, Telefono)
            WHERE IDSucursal = @IDSucursal;
            COMMIT TRANSACTION;
            PRINT 'Sucursal actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la sucursal con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la sucursal: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE infraestructura.ActualizarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(30) = NULL,
    @Apellido VARCHAR(30) = NULL,
    @DNI INT = NULL,
    @Direccion VARCHAR(100) = NULL,
    @EmailPersonal VARCHAR(100) = NULL,
    @EmailEmpresa VARCHAR(100) = NULL,
    @CUIL CHAR(11) = NULL,
    @Turno CHAR(16) = NULL,
    @Cargo INT = NULL,
    @Sucursal INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM infraestructura.Empleado WHERE Legajo = @Legajo)
        BEGIN
            UPDATE infraestructura.Empleado
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
            PRINT 'No se encontro el empleado con el legajo especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarLineaComprobante
    @ID INT,
    @IdProducto INT,
    @Cantidad INT = NULL,
    @Monto DECIMAL(9,2) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.LineaComprobante WHERE ID = @ID AND IdProducto = @IdProducto)
        BEGIN
            UPDATE facturacion.LineaComprobante
            SET Cantidad = COALESCE(@Cantidad, Cantidad),
                Monto = COALESCE(@Monto, Monto)
            WHERE ID = @ID AND IdProducto = @IdProducto;
            COMMIT TRANSACTION;
            PRINT 'Linea de comprobante actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la linea de comprobante con los Ids especificados.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la linea de comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarComprobante
    @ID INT,
    @Tipo CHAR(2) = NULL,
    @Numero CHAR(11) = NULL,
    @Letra CHAR(1) = NULL,
    @Fecha DATETIME = NULL,
    @Total DECIMAL(9,2) = NULL,
    @Cliente INT = NULL,
    @Empleado INT = NULL,
    @Pago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Comprobante WHERE ID = @ID)
        BEGIN
            UPDATE facturacion.Comprobante
            SET Tipo = COALESCE(@Tipo, Tipo),
                Numero = COALESCE(@Numero, Numero),
                Letra = COALESCE(@Letra, Letra),
                Fecha = COALESCE(@Fecha, Fecha),
                Total = COALESCE(@Total, Total),
                Cliente = COALESCE(@Cliente, Cliente),
                Empleado = COALESCE(@Empleado, Empleado),
                Pago = COALESCE(@Pago, Pago)
            WHERE ID = @ID;
            COMMIT TRANSACTION;
            PRINT 'Comprobante actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el comprobante con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el comprobante: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarPago
    @IDPago INT,
    @IdentificadorDePago VARCHAR(22) = NULL,
    @Fecha DATETIME = NULL,
    @MedioDePago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Pago WHERE IDPago = @IDPago)
        BEGIN
            UPDATE facturacion.Pago
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
            PRINT 'No se encontro el pago con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarMedioDePago
    @IDMedioDePago INT,
    @Nombre VARCHAR(20) = NULL,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.MedioDePago WHERE IDMedioDePago = @IDMedioDePago)
        BEGIN
            UPDATE facturacion.MedioDePago
            SET Nombre = COALESCE(@Nombre, Nombre),
                Descripcion = COALESCE(@Descripcion, Descripcion)
            WHERE IDMedioDePago = @IDMedioDePago;
            
            COMMIT TRANSACTION;
            PRINT 'Medio de pago actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el medio de pago con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el medio de pago: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarCliente
    @IDCliente INT,
    @DNI INT = NULL,
    @Nombre VARCHAR(25) = NULL,
    @Apellido VARCHAR(25) = NULL,
    @Genero CHAR(1) = NULL,
    @IDTipoCliente INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.Cliente WHERE IDCliente = @IDCliente)
        BEGIN
            UPDATE facturacion.Cliente
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
            PRINT 'No se encontro el cliente con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE facturacion.ActualizarTipoCliente
    @IDTipoCliente INT,
    @Nombre VARCHAR(20) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM facturacion.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            UPDATE facturacion.TipoCliente
            SET Nombre = COALESCE(@Nombre, Nombre)
            WHERE IDTipoCliente = @IDTipoCliente;
            
            COMMIT TRANSACTION;
            PRINT 'Tipo de cliente actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el tipo de cliente con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el tipo de cliente: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO