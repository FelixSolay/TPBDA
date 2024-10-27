create database AuroraVentas
go

use AuroraVentas
go

create schema ddbba
go

create table ddbba.empleado(
	DNI int primary key,
	Nombre char(20),
	Apellido char(20),
	Puesto char(20)
)
go

create table ddbba.sucursal(
	Id int primary key,
	Nombre char(20),
	Ciudad char(20),
)
go

create table ddbba.catalogo(
	Id int primary key,
	cant_prod int,

)
go

create table ddbba.cliente(
	IDVneta int primary key,
	Cliente cliente foreign key
	
)
go

create table ddbba.detalleVenta(
	IDVneta int primary key,
	
)
go

create table ddbba.Venta(
	IDVneta int primary key,
	Cliente cliente foreign key
	
)
go