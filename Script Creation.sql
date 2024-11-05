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
#CUIDADO: Podría eliminar datos involuntariamente si se corre sobre la base de datos existente #
#############################################################################################
*/
CREATE DATABASE AuroraVentas
CONTAINMENT = NONE
ON PRIMARY(
	NAME = N'AuroraVentas', FILENAME = N'D:\DataTP\AuroraVentas'),
FILEGROUP [Memoria] CONTAINS MEMORY_OPTIMIZED_DATA DEFAULT(
	NAME = N'MemoryDB', FILENAME = N'D:\DataTP\AuroraVentasMem')
GO

--Para trabajar sobre la base de datos creada
USE AuroraVentas
GO

/*
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'ddbba') DROP SCHEMA ddbba;
GO
--Se crea el esquema para trabajar sin usar el default 'dbo'*/
create schema ddbba
go

--Se respeta este orden de borrado para que no haya conflictos con las Foreign Keys
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
	IDsucursal int Identity(1,1) primary key,
	Direccion nvarchar(100),
	Ciudad varchar(20),
	Horario nvarchar(50),
	Telefono varchar(15)
)
go

create table ddbba.empleado(
	Legajo bigint primary key,
	Nombre nvarchar(30),
	Apellido nvarchar(30),
	DNI int Unique,
	Direccion nvarchar(100),
	EmailPersonal nvarchar(50),
	EmailEmpresa nvarchar(50),
	CUIL char(11),
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	Sucursal int,
	FOREIGN KEY (Cargo) REFERENCES ddbba.cargo(IdCargo),
	FOREIGN KEY (Sucursal) REFERENCES ddbba.Sucursal(IdSucursal)
)
go

create table ddbba.TipoCliente(
    IDTipoCliente int Identity(1,1) primary key,
	TipoCliente char(6) check (TipoCliente='Normal' or TipoCliente='Member'), 
	Descripcion varchar(20) 	
)
go

create table ddbba.cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	Nombre varchar(20),
	Apellido varchar(20),
	Genero varchar(6) check (Genero='Male' or Genero='Female'),
	IDTipoCliente int,
	FOREIGN KEY (IDTipoCliente) REFERENCES ddbba.TipoCliente(IDTipoCliente)
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
	Factura char(11),
	TipoFactura char check (TipoFactura='A' or TipoFactura='B' or TipoFactura='C'),
	Fecha date,
    Hora time,
	Total decimal (9,2),
	Cliente int,
	Empleado bigint,
	Pago int,
	FOREIGN KEY (Cliente) REFERENCES ddbba.cliente(IDCliente),
	FOREIGN KEY (Empleado) REFERENCES ddbba.Empleado(Legajo),
	FOREIGN KEY (Pago) REFERENCES ddbba.Pago(IdPago)
)
go

create table ddbba.categoria(
	IDCategoria int Identity(1,1) unique,
	Descripcion varchar(50) primary key,
)
go

create table ddbba.producto(
	IDProducto int Identity(1,1) primary key,
    CategoriaDescripcion varchar(50),
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia varchar(2),
    Fecha datetime,
	FOREIGN KEY (CategoriaDescripcion) REFERENCES ddbba.categoria(Descripcion)
)
go

create table ddbba.lineaVenta(
	IDVenta int,
	Orden int identity(1,1),
	Cantidad int,
	Monto decimal (9,2),
	producto int,
	FOREIGN KEY (IDVenta) REFERENCES ddbba.Venta(IDVenta),
	FOREIGN KEY (producto) REFERENCES ddbba.producto(IDProducto),
	constraint pkLineaVenta primary key (IDVenta, Orden)
)
go

IF OBJECT_ID(N'[ddbba].[CSVMem]', N'U') IS NULL
	BEGIN
		CREATE TABLE ddbba.CSVMem(
			IDProducto int primary key NONCLUSTERED,
    		CategoriaDescripcion varchar(50),
			Nombre varchar(100),
			Precio decimal (9,2),
			PrecioReferencia decimal (9,2),
			UnidadReferencia varchar(2),
    		Fecha datetime
		)
		WITH(
			MEMORY_OPTIMIZED = ON,
			DURABILITY = SCHEMA_ONLY
		)
	END