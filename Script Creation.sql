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
	Localidad char(20),
)
go