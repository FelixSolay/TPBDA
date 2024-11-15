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
*/

DROP DATABASE IF EXISTS COM2900G09
GO

CREATE DATABASE COM2900G09 COLLATE Latin1_General_CI_AI
GO
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE
GO
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO
EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1
GO
--EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 0
--GO
SET DATEFORMAT mdy
GO


/*
CONTAINMENT = NONE
ON PRIMARY(
	NAME = N'AuroraVentas', FILENAME = N'D:\DataTP\AuroraVentas'),
FILEGROUP [Memoria] CONTAINS MEMORY_OPTIMIZED_DATA DEFAULT(
	NAME = N'MemoryDB', FILENAME = N'D:\DataTP\AuroraVentasMem')
GO
*/
--Para trabajar sobre la base de datos creada
USE COM2900G09
GO


--Se crean esquemas para trabajar sin usar el default 'dbo'
--Facturación se encargará de la generación y gestión de comprobantes, pagos y clientes
create schema facturacion
go
--Destinamos el esquema Depósito a lo relacionado a gestión de Productos
create schema deposito
GO
--El esquema infraestructura tiene como objetivo gestionar sucursales y recursos humanos
create schema infraestructura
GO

--Se respeta este orden de borrado para que no haya conflictos con las Foreign Keys
DROP TABLE IF EXISTS facturacion.LineaComprobante;
DROP TABLE IF EXISTS facturacion.Comprobante;
DROP TABLE IF EXISTS facturacion.Pago;
DROP TABLE IF EXISTS facturacion.Cliente;
DROP TABLE IF EXISTS facturacion.MedioDePago;
DROP TABLE IF EXISTS facturacion.TipoCliente;   
DROP TABLE IF EXISTS deposito.Producto;
DROP TABLE IF EXISTS deposito.Categoria;
DROP TABLE IF EXISTS infraestructura.Empleado;
DROP TABLE IF EXISTS infraestructura.Sucursal;
DROP TABLE IF EXISTS infraestructura.Cargo;
go

--Utilizamos como Pk en las tablas un int Identity para mejorar la velocidad de las consultas
create table infraestructura.cargo(
	IdCargo int Identity(1,1) primary key,
	Descripcion varchar(25) Unique NOT NULL
)
go

create table infraestructura.sucursal(
	IDsucursal int Identity(1,1) primary key,
	Direccion varchar(100),
	Ciudad varchar(20),
	Horario char(45),
	Telefono char(11)
)
go

create table infraestructura.empleado(
	Legajo int primary key,
	Nombre varchar(30),
	Apellido varchar(30),
	DNI int Unique,
	Direccion varchar(100),
	EmailPersonal varchar(100),
	EmailEmpresa varchar(100),
	CUIL char(11),
	Turno char (16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	Sucursal int,
	FOREIGN KEY (Cargo) REFERENCES infraestructura.cargo(IdCargo),
	FOREIGN KEY (Sucursal) REFERENCES infraestructura.Sucursal(IdSucursal)
)
go

create table facturacion.TipoCliente(
    IDTipoCliente int Identity(1,1) primary key, 
	nombre varchar(20) Unique NOT NULL 	
)
go

create table facturacion.cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	CUIL int unique, -- calculable
	Nombre varchar(25),
	Apellido varchar(25),
	Genero char(1) check (Genero='M' or Genero='F'),
	IDTipoCliente int,
	FOREIGN KEY (IDTipoCliente) REFERENCES facturacion.TipoCliente(IDTipoCliente)
)
go

create table facturacion.MedioDePago(
	IDMedioDePago int Identity(1,1) primary key,
	Nombre varchar(20) Unique NOT NULL,
	Descripcion varchar(50)
)
go

create table facturacion.Pago(
	IDPago int Identity(1,1) primary key,
	IDComprobante int,
	IdentificadorDePago varchar(22),
	Fecha datetime,
	MedioDePago int,
	FOREIGN KEY (MedioDePago) REFERENCES facturacion.MedioDePago(IDMedioDePago),
	FOREIGN KEY (IDComprobante) REFERENCES facturacion.comprobante(ID)
)
go

create table deposito.categoria(
	IDCategoria int Identity(1,1) primary key,
	Descripcion varchar(50) Unique NOT NULL,
)
go

create table deposito.producto(
	IDProducto int Identity(1,1) primary key,
    categoria int,
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia char(2),
    Fecha datetime,
	FOREIGN KEY (categoria) REFERENCES deposito.categoria(IDCategoria)
)
go

create table facturacion.comprobante(
	ID int Identity(1,1) primary key,
	MontoIVA decimal (9,2), -- no se inserta, se modifica
	MontoNeto decimal (9,2), -- no se inserta, se modifica
	MontoBruto decimal (9,2), -- no se inserta, se modifica
	Cliente int,
	Empleado int,
	Cerrado boolean default 0,
	FOREIGN KEY (Cliente) REFERENCES facturacion.cliente(IDCliente),
	FOREIGN KEY (Empleado) REFERENCES infraestructura.Empleado(Legajo)
)
go

create table facturacion.lineaComprobante(
	ID int,
	IDProducto int,
	Cantidad int,
	Monto decimal (9,2),
	FOREIGN KEY (ID) REFERENCES facturacion.Comprobante(ID),
	FOREIGN KEY (IdProducto) REFERENCES deposito.producto(IDProducto),
	constraint pkLineaVenta primary key (ID, IdProducto)
)
go

create table facturacion.documento(
	ID int Identity(1,1) primary key,
	Comprobante int
	tipo char(2) check (tipo='FC' or tipo='NC' or tipo='ND'), 
	letra char check (Letra='A' or Letra='B' or Letra='C'),
	numero char(11),
	Fecha date,
	Hora time,
	Importe decimal (9,2),
	CUIL char(13),
	FOREIGN KEY (Comprobante) REFERENCES facturacion.comprobante(ID)
)
go

CREATE NONCLUSTERED INDEX idx_Comprobante_Numero
ON facturacion.Comprobante (numero);
GO

CREATE NONCLUSTERED INDEX idx_Empleado_DNI
ON infraestructura.Empleado (DNI);
GO

CREATE NONCLUSTERED INDEX idx_Cliente_DNI
ON facturacion.Cliente (DNI);
GO

CREATE NONCLUSTERED INDEX idx_Empleado_Nombre
ON infraestructura.Empleado (Nombre);
GO

CREATE NONCLUSTERED INDEX idx_Cliente_Nombre
ON facturacion.Cliente (Nombre);
GO

CREATE NONCLUSTERED INDEX idx_Empleado_Apellido
ON infraestructura.Empleado (Apellido);
GO

CREATE NONCLUSTERED INDEX idx_Cliente_Apellido
ON facturacion.Cliente (Apellido);
GO

USE master
GO