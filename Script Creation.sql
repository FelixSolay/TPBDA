create database AuroraVentas
go

use AuroraVentas
go

create schema ddbba
go

drop table if exists ddbba.empleado, ddbba.cargo, ddbba.sucursal, ddbba.venta, ddbba.cliente, ddbba.TipoCliente, 
					 ddbba.Pago, ddbba.mediodePago, ddbba.lineaVenta, ddbba.producto, ddbba.categoria
go

create table ddbba.empleado(
	Legajo int primary key,
	Nombre char(20),
	Apellido char(20),
	DNI int Unique,
	Direccion char(20),
	EmailPersonal char(25),
	EmailEmpresa char(25),
	CUIL int Unique,
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa')
	--constraint CHK_Turno check value ("TN","TM","TT","Jornada Completa")
)
go

create table ddbba.cargo(
	IdCargo int Identity(1,1) primary key,
	Descripcion char(25)
)
go

create table ddbba.sucursal(
	IDsucursal int primary key,
	Direccion char(20),
	Ciudad char(20),
	Horario int,
	Telefono int
)
go

create table ddbba.venta(
	IDVenta int Identity(1,1) primary key,
	IDFactura int,
	TipoFactura char check (TipoFactura='A' or TipoFactura='B' or TipoFactura='C'),
	Fecha date,
	Total int
)
go

create table ddbba.cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	Nombre char(20),
	Apellido char(20),
	Genero char check (Genero='M' or Genero='F')	
)
go

create table ddbba.TipoCliente(
	IDTipoCliente int Identity(1,1) primary key, 
	Descripcion char(25) 	
)
go

create table ddbba.Pago(
	IDPago int Identity(1,1) primary key,
	IdentificadorDePago char(25),
	Fecha date
)
go

create table ddbba.mediodePago(
	IDMedioPago int Identity(1,1) primary key,
	Nombre char(20),
	Descripcion char(25)
)
go

create table ddbba.lineaVenta(
	IDVenta int,
	Orden int,
	Cantidad int,
	Monto int
	constraint pkLineaVenta primary key (IDVenta, Orden)
)
go

create table ddbba.producto(
	IDProducto int Identity(1,1) primary key,
	Nombre char(20),
	Precio int,
	PrecioReferencia int,
	UnidadReferencia int	
)
go

create table ddbba.categoria(
	IDcategoria int Identity(1,1) primary key,
	Descripcion char(25)	
)
go