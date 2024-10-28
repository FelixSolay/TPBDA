create database AuroraVentas
go

use AuroraVentas
go

create schema ddbba
go

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
	EmailPersonal varchar(50),
	EmailEmpresa varchar(50),
	CUIL char(11) Unique,
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	Sucursal int,
	FOREIGN KEY (Cargo) REFERENCES ddbba.cargo(IdCargo) ON DELETE CASCADE,
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IdSucursal) ON DELETE CASCADE
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

create table ddbba.venta(
	IDVenta int Identity(1,1) primary key,
	IDFactura int Unique,
	TipoFactura char check (TipoFactura='A' or TipoFactura='B' or TipoFactura='C'),
	Fecha date,
	Total decimal (9,2),
	Cliente int,
	Sucursal int,
	Pago int,
	FOREIGN KEY (Cliente) REFERENCES ddbba.cliente(IDCliente) ON DELETE CASCADE,
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IDSucursal) ON DELETE CASCADE,
	FOREIGN KEY (Pago) REFERENCES ddbba.Pago(IdPago) ON DELETE CASCADE
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
	FOREIGN KEY (Categoria) REFERENCES ddbba.categoria(IDCategoria) ON DELETE CASCADE
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


