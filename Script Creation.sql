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
Aguirre, Cesar Alan		42290514
Correa, Juan Pablo 		40653000
De Solay, Félix 		40971636
Weidmann, Germán Ariel 		40676211

Script de Creación de Base de datos y tablas para el trabajo práctico
*/

DROP DATABASE IF EXISTS COM2900G09
GO

CREATE DATABASE COM2900G09 COLLATE Modern_Spanish_CI_AS --Latin1_General_CI_AS
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
SET DATEFORMAT mdy
GO

--Para trabajar sobre la base de datos creada
USE COM2900G09
GO

--Se crean esquemas para trabajar sin usar el default 'dbo'
--Facturación se encargará de la generación y gestión de Ventas, pagos y clientes
CREATE SCHEMA facturacion
go
--Destinamos el esquema Depósito a lo relacionado a gestión de Productos
CREATE SCHEMA deposito
GO
--El esquema infraestructura tiene como objetivo gestionar sucursales y recursos humanos
CREATE SCHEMA infraestructura
GO
--Utilizamos el esquema test para crear y ejecutar SP de reportes en XML
CREATE SCHEMA reportes
GO
--Utilizamos el esquema test para crear y ejecutar SP de prueba con datos ficticios
create schema test
GO

--Se respeta este orden de borrado para que no haya conflictos con las Foreign Keys
DROP TABLE IF EXISTS facturacion.MedioDePago;
DROP TABLE IF EXISTS facturacion.TipoCliente;
DROP TABLE IF EXISTS deposito.Categoria;
DROP TABLE IF EXISTS facturacion.DatosFacturacion;
DROP TABLE IF EXISTS infraestructura.Cargo;
DROP TABLE IF EXISTS infraestructura.Sucursal;
DROP TABLE IF EXISTS facturacion.Factura;
DROP TABLE IF EXISTS facturacion.Pago;
DROP TABLE IF EXISTS facturacion.Nota;
DROP TABLE IF EXISTS facturacion.LineaNota;
DROP TABLE IF EXISTS facturacion.Venta;
DROP TABLE IF EXISTS facturacion.LineaVenta;
DROP TABLE IF EXISTS deposito.Producto;
DROP TABLE IF EXISTS infraestructura.Empleado;
DROP TABLE IF EXISTS facturacion.Cliente;
go


--Utilizamos como Pk en las tablas un int Identity para mejorar la velocidad de las consultas
--INFRAESTRUCTURA
CREATE TABLE infraestructura.cargo(
	IdCargo 	INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(25) UNIQUE NOT NULL
)
GO

CREATE TABLE infraestructura.sucursal(
	IDsucursal INT IDENTITY(1,1) PRIMARY KEY,
	Direccion  VARCHAR(100),
	Ciudad 	   VARCHAR(20),
	Horario    CHAR(45),
	Telefono   CHAR(11)
)
GO

create table infraestructura.empleado(
	Legajo int primary key,
	Nombre varchar(30),
	Apellido varchar(30),
	DNI INT CONSTRAINT UQ_Empleado_DNI UNIQUE,
	Direccion varchar(100),
	EmailPersonal varchar(100),
	EmailEmpresa varchar(100),
	CUIL CHAR(11) CONSTRAINT CHK_Empleado_CUIL CHECK (CUIL LIKE '[0-9]%'),
	Turno char(16) check (Turno='TN' or Turno='TM' or turno= 'TT' or Turno='Jornada Completa'),
	Cargo int,
	Sucursal int,
	FOREIGN KEY (Cargo) REFERENCES infraestructura.cargo(IdCargo),
	FOREIGN KEY (Sucursal) REFERENCES infraestructura.Sucursal(IdSucursal)
)
GO

CREATE TABLE facturacion.TipoCliente(
    IDTipoCliente INT IDENTITY(1,1) PRIMARY KEY,
	nombre 		  VARCHAR(20) UNIQUE NOT NULL 	
)
GO

create table facturacion.cliente(
	IDCliente int Identity(1,1) primary key,
	DNI int Unique,
	CUIL char(11), --UNIQUE CHECK (CUIL LIKE '[0-9]%'), -- calculable
	Nombre varchar(25),
	Apellido varchar(25),
	Genero char(1) check (Genero='M' or Genero='F'),
	IDTipoCliente int,
	FOREIGN KEY (IDTipoCliente) REFERENCES facturacion.TipoCliente(IDTipoCliente)
)
GO

--DEPOSITO
CREATE TABLE deposito.categoria(
	IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(50) UNIQUE NOT NULL,
)
GO

create table deposito.producto(
	IDProducto int Identity(1,1) primary key,
    categoria int,
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia varchar(25),
    Fecha datetime,
	FOREIGN KEY (categoria) REFERENCES deposito.categoria(IDCategoria)
)
GO

--FACTURACION
--Agregamos los datos de facturación para utilizarlos como una tabla parametrizada
CREATE TABLE facturacion.DatosFacturacion (
    ID 			INT IDENTITY(1,1) PRIMARY KEY,
    CUIT 		CHAR(11) NOT NULL UNIQUE CHECK (CUIT LIKE '[0-9]%'),
    FechaInicio DATETIME NOT NULL,
    RazonSocial VARCHAR(100) NOT NULL,
    CONSTRAINT CHK_Unico CHECK (ID = 1)
)
GO

create table facturacion.factura(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	letra 	   CHAR CHECK (Letra = 'A' OR Letra = 'B' OR Letra = 'C'),
	numero 	   CHAR(11),
	Fecha 	   DATE,
	Hora 	   TIME,
	MontoIVA   DECIMAL (9,2),
	MontoNeto  DECIMAL (9,2),
	MontoBruto DECIMAL (9,2),
	IDDatosFac INT,
	FOREIGN KEY (IDDatosFac) REFERENCES facturacion.DatosFacturacion(ID)
)
GO

CREATE TABLE facturacion.Venta(
	ID 		  INT IDENTITY(1,1) PRIMARY KEY,
	IDFactura INT,
	Cliente   INT,
	Empleado  INT,
	MontoNeto DECIMAL(9,2), -- no se inserta, se modifica
	Cerrado   BIT DEFAULT 0,
	FOREIGN KEY (Cliente)   REFERENCES facturacion.cliente(IDCliente),
	FOREIGN KEY (Empleado)  REFERENCES infraestructura.Empleado(Legajo),
	FOREIGN KEY (IDFactura) REFERENCES facturacion.Factura(ID)
)
GO

CREATE TABLE facturacion.lineaVenta(
	ID 	   	   INT,
	IDProducto INT,
	Cantidad   INT,
	Monto 	   DECIMAL(9,2),
	FOREIGN KEY (ID) 		 REFERENCES facturacion.Venta(ID),
	FOREIGN KEY (IdProducto) REFERENCES deposito.producto(IDProducto),
	CONSTRAINT pkLineaVenta PRIMARY KEY (ID, IdProducto)
)
GO

create table facturacion.nota(
	ID int Identity(1,1) primary key,
	factura int,
	tipo char(2) check (tipo='NC' or tipo='ND'), 
	numero char(11),
	Fecha date,
	Hora time,
	Importe decimal (9,2),
	FOREIGN KEY (factura) REFERENCES facturacion.factura(ID)
)
GO

CREATE TABLE facturacion.lineaNota(
    ID INT,
    IDProducto INT,
    Cantidad INT,
    Monto DECIMAL(9,2),
    FOREIGN KEY (ID) REFERENCES facturacion.nota(ID),
    FOREIGN KEY (IDProducto) REFERENCES deposito.producto(IDProducto),
    CONSTRAINT PK_lineaNota PRIMARY KEY (ID, IDProducto)
)
GO

CREATE TABLE facturacion.MedioDePago(
	IDMedioDePago INT IDENTITY(1,1) PRIMARY KEY,
	Nombre 		  VARCHAR(20) UNIQUE NOT NULL,
	Descripcion   VARCHAR(50)
)
GO

CREATE TABLE facturacion.Pago(
	IDPago 				INT IDENTITY(1,1) PRIMARY KEY,
	factura 			INT,
	IdentificadorDePago VARCHAR(22),
	Fecha 				DATETIME,
	MedioDePago 		INT,
	FOREIGN KEY (MedioDePago) REFERENCES facturacion.MedioDePago(IDMedioDePago),
	FOREIGN KEY (factura) 	  REFERENCES facturacion.factura(ID)
)
GO

CREATE NONCLUSTERED INDEX idx_Empleado_DNI
ON infraestructura.Empleado (DNI)
GO

CREATE NONCLUSTERED INDEX idx_Cliente_DNI
ON facturacion.Cliente (DNI)
GO

CREATE NONCLUSTERED INDEX idx_Empleado_Nombre
ON infraestructura.Empleado (Nombre)
GO

CREATE NONCLUSTERED INDEX idx_Cliente_Nombre
ON facturacion.Cliente (Nombre)
GO

CREATE NONCLUSTERED INDEX idx_Empleado_Apellido
ON infraestructura.Empleado (Apellido)
GO

CREATE NONCLUSTERED INDEX idx_Cliente_Apellido
ON facturacion.Cliente (Apellido)
GO

-- Secuencias para números de facturas

CREATE SEQUENCE FacturaASeq
    START WITH 1         -- Número inicial
    INCREMENT BY 1       -- Incremento
    MINVALUE 1           -- Valor mínimo
    MAXVALUE 9999999999  -- Valor máximo (opcional)
    NO CYCLE;            -- No reiniciar cuando se alcance el máximo
GO

CREATE SEQUENCE FacturaBSeq
    START WITH 1         -- Número inicial
    INCREMENT BY 1       -- Incremento
    MINVALUE 1           -- Valor mínimo
    MAXVALUE 9999999999  -- Valor máximo (opcional)
    NO CYCLE;            -- No reiniciar cuando se alcance el máximo
GO

CREATE SEQUENCE FacturaCSeq
    START WITH 1         -- Número inicial
    INCREMENT BY 1       -- Incremento
    MINVALUE 1           -- Valor mínimo
    MAXVALUE 9999999999  -- Valor máximo (opcional)
    NO CYCLE;            -- No reiniciar cuando se alcance el máximo
GO


USE master
GO
