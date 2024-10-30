create database AuroraVentas
go

use AuroraVentas
go

--drop table if exists ddbba.lineaVenta, ddbba.producto, ddbba.categoria, ddbba.venta,
--					   ddbba.pago, ddbba.mediodePago, ddbba.cliente, ddbba.tipoCliente,
--					   ddbba.empleado, ddbba.sucursal, ddbba.cargo
--go

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
go

create schema ddbba
go

create table ddbba.Cargo(
	IdCargo int Identity(1,1) primary key,
	Descripcion varchar(25)
)
go

create table ddbba.Sucursal(
	IDsucursal int primary key,
	Direccion nvarchar(50),
	Ciudad varchar(20),
	Horario varchar(50),
	Telefono varchar(15)
)
go

create table ddbba.Empleado(
	Legajo int primary key,
	Nombre nvarchar(20),
	Apellido nvarchar(20),
	DNI int Unique,
	Direccion nvarchar(50),
	EmailPersonal varchar(50),
	EmailEmpresa varchar(50),
	CUIL char(11) Unique,
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	IDSucursal int,
	FOREIGN KEY (Cargo) REFERENCES ddbba.cargo(IdCargo) ON DELETE CASCADE,
	FOREIGN KEY (Sucursal) REFERENCES ddbba.sucursal(IDSucursal) ON DELETE CASCADE
)
go

create table ddbba.TipoCliente(
	IDTipoCliente int Identity(1,1) primary key, 
	Descripcion varchar(25) 	
)
go

create table ddbba.Cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	Nombre varchar(20),
	Apellido varchar(20),
	Genero char check (Genero='M' or Genero='F'),
	TipoCliente int,
	FOREIGN KEY (TipoCliente) REFERENCES ddbba.TipoCliente(IDTipoCliente) ON DELETE CASCADE
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
	IdentificadorDePago char(25),
	Fecha date,
	MedioDePago int,
	FOREIGN KEY (MedioDePago) REFERENCES ddbba.MedioDePago(IDMedioDePago) ON DELETE CASCADE
)
go

create table ddbba.Venta(
	IDVenta int Identity(1,1) primary key,
	IDFactura int Unique,
	TipoFactura char check (TipoFactura='A' or TipoFactura='B' or TipoFactura='C'),
	Fecha date,
	Total decimal (9,2),
	Cliente int,
	Sucursal int,
	Pago int,
	FOREIGN KEY (Cliente) REFERENCES ddbba.Cliente(IDCliente) ON DELETE CASCADE,
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IDSucursal) ON DELETE CASCADE,
	FOREIGN KEY (Pago) REFERENCES ddbba.Pago(IDPago) ON DELETE CASCADE
)
go

create table ddbba.Categoria(
	IDCategoria int Identity(1,1) primary key,
	Descripcion varchar(50)	
)
go

create table ddbba.Producto(
	IDProducto int Identity(1,1) primary key,
	IDCategoria int,
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia char(2),
	FOREIGN KEY (IDCategoria) REFERENCES ddbba.Categoria(IDCategoria) ON DELETE CASCADE
)
go

create table ddbba.LineaVenta(
	IDVenta int,
	Orden int,
	Cantidad int,
	Monto decimal (9,2),
	Producto int,
	FOREIGN KEY (IDVenta) REFERENCES ddbba.Venta(IDVenta),
	FOREIGN KEY (Producto) REFERENCES ddbba.Producto(IDProducto),
	constraint PkLineaVenta primary key (IDVenta, Orden)
)
go

create or alter procedure ddbba.insercionCargo
	@Descripcion varchar(50)
as
begin
	insert into ddbba.Cargo values (@Descripcion)
end
go

create or alter procedure ddbba.insercionSucursal
	@Direccion 	nvarchar(50),
	@Ciudad 	varchar(20),
	@Horario 	varchar(50),
	@Telefono 	varchar(15)
as
begin
	insert into ddbba.Sucursal values (@Direccion, @Ciudad, @Horario, @Telefono)
end
go

create or alter procedure ddbba.insercionEmpleado
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
	insert into ddbba.Empleado  values (@Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal)
end
go

create or alter procedure ddbba.insercionTipoCliente
	@Descripcion varchar(50)
as
begin
	insert into ddbba.TipoCliente values (@Descripcion)
end
go

create or alter procedure ddbba.insercionCliente
as
	@DNI int,
	@Nombre varchar(20),
	@Apellido varchar(20),
	@Genero char,
	@TipoCliente int,
begin
	insert into ddbba.Cliente values (@DNI, @Nombre, @Apellido, @Genero, @tipoCliente)
end
go

create or alter procedure ddbba.insercionMedioDePago
as
	@Nombre char(20),
	@Descripcion char(25)
begin
	insert into ddbba.MedioDePago values (@Nombre, @Descripcion)
end
go

create or alter procedure ddbba.insercionPago
as
	@IdentificadorDePago char(25),
	@Fecha date,
	@MedioDePago int,
begin
	insert into ddbba.Pago values (@IdentificadorDePago, @Fecha, @MedioDePago)
end
go

create or alter procedure ddbba.insercionVenta
as
	@IDFactura int,
	@TipoFactura char,
	@@Fecha date,
	@Total decimal(9,2),
	@Cliente int,
	@Sucursal int,
	@Pago int,
begin
	insert into ddbba.Venta values (@IDFactura, @TipoFactura, @@Fecha, @Total, @Cliente, @Sucursal, @Pago)
end
go

create or alter procedure ddbba.insercionCategoria 
	@Descripcion varchar(50)
as
begin
	insert into ddbba.Categoria values (@Descripcion)
end
go

create or alter procedure ddbba.insercionProducto
as
	@IDCategoria int,
	@Nombre varchar(100),
	@Precio decimal (9,2),
	@PrecioReferencia decimal (9,2),
	@UnidadReferencia char(2),
begin
	insert into ddbba.Producto values (@IDCategoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia)
end
go

create or alter procedure ddbba.insercionLineaVenta
as
	@IDVenta int,
	@Orden int,
	@Cantidad int,
	@Monto decimal (9,2),
	@Producto int,
begin
	insert into ddbba.LineaVenta values (@IDVenta, @Orden, @Cantidad, @Monto, @Producto)
end
go