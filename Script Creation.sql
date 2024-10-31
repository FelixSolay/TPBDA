/*
Entrega 3
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.

Fecha de entrega: 
Grupo: 09
Bases de datos Aplicadas
Alumnos:
Aguirre
Correa
De Solay, Félix 40971636
Weidmann


Script de Creación de Base de datos y tablas para el trabajo práctico
#############################################################################################
#CUIDADO: Podría eliminar datos involuntariamente se corre sobre la base de datos existente #
#############################################################################################
*/
create database AuroraVentas
go

--Para trabajar sobre la base de datos creada
use AuroraVentas
go

--Se crea el esquema para trabajar sin usar el default 'dbo'
create schema ddbba
go

--Se respeta este orden de borrado para que no haya conflictos con las Foreign Keys
IF OBJECT_ID('ddbba.lineaVenta', 'U') IS NOT NULL DROP TABLE ddbba.lineaVenta;
IF OBJECT_ID('ddbba.producto', 'U') IS NOT NULL DROP TABLE ddbba.producto;
IF OBJECT_ID('ddbba.categoria', 'U') IS NOT NULL DROP TABLE ddbba.categoria;
IF OBJECT_ID('ddbba.venta', 'U') IS NOT NULL DROP TABLE ddbba.venta;
IF OBJECT_ID('ddbba.Pago', 'U') IS NOT NULL DROP TABLE ddbba.Pago;
IF OBJECT_ID('ddbba.mediodePago', 'U') IS NOT NULL DROP TABLE ddbba.mediodePago;
IF OBJECT_ID('ddbba.cliente', 'U') IS NOT NULL DROP TABLE ddbba.cliente;
IF OBJECT_ID('ddbba.TipoCliente', 'U') IS NOT NULL DROP TABLE ddbba.TipoCliente;
IF OBJECT_ID('ddbba.empleado', 'U') IS NOT NULL DROP TABLE ddbba.empleado;
IF OBJECT_ID('ddbba.sucursal', 'U') IS NOT NULL DROP TABLE ddbba.sucursal;
IF OBJECT_ID('ddbba.cargo', 'U') IS NOT NULL DROP TABLE ddbba.cargo;
--IF OBJECT_ID('ddbba.Registro', 'U') IS NOT NULL DROP TABLE ddbba.Registro;
go

/*
--Tabla para log de Inserción/Modificación/Eliminado
create table ddbba.Registro(
	ID int Identity(1,1) primary key,
	Fecha datetime,
	modulo varchar(20),
	texto varchar(20),
)
go
*/

--Utilizamos como Pk en las tablas un int Identity para mejorar la velocidad de las consultas
create table ddbba.cargo(
	IdCargo int Identity(1,1) primary key,
	Descripcion varchar(25)
)
go

create table ddbba.sucursal(
	IDsucursal int primary key,
	Direccion nvarchar(50),
	Ciudad varchar(20),
	Horario varchar(50),
	Telefono varchar(15)
)
go


create table ddbba.empleado(
	Legajo int primary key,
	Nombre nvarchar(20),
	Apellido nvarchar(20),
	DNI int Unique,
	Direccion nvarchar(50),
	EmailPersonal nvarchar(50),
	EmailEmpresa nvarchar(50),
	CUIL char(11) Unique,
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	Sucursal int,
	FOREIGN KEY (Cargo) REFERENCES ddbba.cargo(IdCargo),
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IdSucursal)
)
go


create table ddbba.TipoCliente(
	IDTipoCliente int Identity(1,1) primary key, 
	Descripcion varchar(25) 	
)
go

create table ddbba.cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	Nombre varchar(20),
	Apellido varchar(20),
	Genero char check (Genero='M' or Genero='F'),
	TipoCliente int,
	FOREIGN KEY (TipoCliente) REFERENCES ddbba.TipoCliente(IDTipoCliente)
)
go

create table ddbba.MedioDePago(
	IDMedioDePago int Identity(1,1) primary key,
	Nombre char(20),
	Descripcion char(25)
)
go


create table ddbba.Pago(
	IDPago int Identity(1,1) primary key,
	IdentificadorDePago varchar(22),
	Fecha date,
	MedioDePago int,
	FOREIGN KEY (MedioDePago) REFERENCES ddbba.MedioDePago(IDMedioDePago)
)
go

create table ddbba.venta(
	IDVenta int Identity(1,1) primary key,
	IDFactura int Unique,
	TipoFactura char check (TipoFactura='A' or TipoFactura='B' or TipoFactura='C'),
	Fecha date,
	Total decimal (9,2),
	Cliente int,
	Sucursal int,
	Pago int,
	FOREIGN KEY (Cliente) REFERENCES ddbba.cliente(IDCliente),
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IDSucursal),
	FOREIGN KEY (Pago) REFERENCES ddbba.Pago(IdPago)
)
go

create table ddbba.categoria(
	IDCategoria int Identity(1,1) primary key,
	Descripcion varchar(50)	
)
go

create table ddbba.producto(
	IDProducto int Identity(1,1) primary key,
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia char(2),
	Categoria int,
	FOREIGN KEY (Categoria) REFERENCES ddbba.categoria(IDCategoria)
)
go

create table ddbba.lineaVenta(
	IDVenta int,
	Orden int,
	Cantidad int,
	Monto decimal (9,2),
	producto int,
	FOREIGN KEY (IDVenta) REFERENCES ddbba.Venta(IDVenta),
	FOREIGN KEY (producto) REFERENCES ddbba.producto(IDProducto),
	constraint pkLineaVenta primary key (IDVenta, Orden)
)
go



/*
Creación de los Store procedures

Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.

*/


--Insert Store Procedures
create or alter procedure ddbba.insertarCargo
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

create or alter procedure ddbba.insertarSucursal
	@Direccion 	nvarchar(50),
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

create or alter procedure ddbba.insertarEmpleado
	@Nombre nvarchar(20),
	@Apellido nvarchar(20),
	@DNI int,
	@Direccion nvarchar(50),
	@EmailPersonal varchar(50),
	@EmailEmpresa varchar(50),
	@CUIL char(11),
	@Turno char (16),
	@Cargo int,
	@IDSucursal int,
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Empleado  values (@Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal)
		COMMIT TRANSACTION;
		PRINT 'Empleado Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
end
go

create or alter procedure ddbba.insertarTipoCliente
	@Descripcion varchar(50)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.TipoCliente values (@Descripcion)
		COMMIT TRANSACTION;
		PRINT 'Tipo de Cliente Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Tipo de Cliente: ' + ERROR_MESSAGE();
    END CATCH;	
end
go

create or alter procedure ddbba.insertarCliente
	@DNI int,
	@Nombre varchar(20),
	@Apellido varchar(20),
	@Genero char,
	@TipoCliente int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Cliente values (@DNI, @Nombre, @Apellido, @Genero, @tipoCliente)
		COMMIT TRANSACTION;
		PRINT 'Cliente Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Cliente: ' + ERROR_MESSAGE();
    END CATCH;
	
end
go

create or alter procedure ddbba.insertarMedioDePago
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

create or alter procedure ddbba.insertarPago
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

create or alter procedure ddbba.insertarVenta
	@IDFactura int,
	@TipoFactura char,
	@@Fecha date,
	@Total decimal(9,2),
	@Cliente int,
	@Sucursal int,
	@Pago int
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Venta values (@IDFactura, @TipoFactura, @@Fecha, @Total, @Cliente, @Sucursal, @Pago)
		COMMIT TRANSACTION;
		PRINT 'Venta Insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Venta: ' + ERROR_MESSAGE();
    END CATCH;
end
go

create or alter procedure ddbba.insertarCategoria 
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

create or alter procedure ddbba.insertarProducto
	@IDCategoria int,
	@Nombre varchar(100),
	@Precio decimal (9,2),
	@PrecioReferencia decimal (9,2),
	@UnidadReferencia char(2)
as
begin
    BEGIN TRANSACTION;
    BEGIN TRY
		insert into ddbba.Producto values (@IDCategoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia)
		COMMIT TRANSACTION;
		PRINT 'Producto Insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Producto: ' + ERROR_MESSAGE();
    END CATCH;	
end
go

create or alter procedure ddbba.insertarLineaVenta
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
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia CHAR(2) = NULL,
    @Categoria INT = NULL
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
                Precio = COALESCE(@Precio, Precio),
                PrecioReferencia = COALESCE(@PrecioReferencia, PrecioReferencia),
                UnidadReferencia = COALESCE(@UnidadReferencia, UnidadReferencia),
                Categoria = COALESCE(@Categoria, Categoria)
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
    @Producto INT = NULL,
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
                Producto = COALESCE(@Producto, Producto),
            WHERE IDProducto = @IDProducto;
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
    @Direccion NVARCHAR(50) = NULL,
    @Ciudad VARCHAR(20) = NULL,
    @Horario VARCHAR(50) = NULL,
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
    @Direccion NVARCHAR(50) = NULL,
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
    @Descripcion VARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.TipoCliente WHERE IDTipoCliente = @IDTipoCliente)
        BEGIN
            UPDATE ddbba.TipoCliente
            SET Descripcion = COALESCE(@Descripcion, Descripcion)
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
    @TipoCliente INT = NULL
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
                TipoCliente = COALESCE(@TipoCliente, TipoCliente)
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
    @IDFactura INT = NULL,
    @TipoFactura CHAR = NULL,
    @Fecha DATE = NULL,
    @Total DECIMAL(9,2) = NULL,
    @Cliente INT = NULL,
    @Sucursal INT = NULL,
    @Pago INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ddbba.venta WHERE IDVenta = @IDVenta)
        BEGIN
            UPDATE ddbba.venta
            SET IDFactura = COALESCE(@IDFactura, IDFactura),
                TipoFactura = COALESCE(@TipoFactura, TipoFactura),
                Fecha = COALESCE(@Fecha, Fecha),
                Total = COALESCE(@Total, Total),
                Cliente = COALESCE(@Cliente, Cliente),
                Sucursal = COALESCE(@Sucursal, Sucursal),
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