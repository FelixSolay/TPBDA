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

-- hay que agregar esto
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
--Facturación se encargará de la generación y gestión de Ventas, pagos y clientes
CREATE SCHEMA facturacion
go
--Destinamos el esquema Depósito a lo relacionado a gestión de Productos
CREATE SCHEMA deposito
GO
--El esquema infraestructura tiene como objetivo gestionar sucursales y recursos humanos
CREATE SCHEMA infraestructura
GO

CREATE SCHEMA reportes
GO

--Se respeta este orden de borrado para que no haya conflictos con las Foreign Keys
DROP TABLE IF EXISTS facturacion.LineaVenta
DROP TABLE IF EXISTS facturacion.Venta
DROP TABLE IF EXISTS facturacion.Pago
DROP TABLE IF EXISTS facturacion.Cliente
DROP TABLE IF EXISTS facturacion.MedioDePago
DROP TABLE IF EXISTS facturacion.TipoCliente
DROP TABLE IF EXISTS deposito.Producto
DROP TABLE IF EXISTS deposito.Categoria
DROP TABLE IF EXISTS infraestructura.Empleado
DROP TABLE IF EXISTS infraestructura.Sucursal
DROP TABLE IF EXISTS infraestructura.Cargo
GO

--Utilizamos como Pk en las tablas un int Identity para mejorar la velocidad de las consultas
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

CREATE TABLE infraestructura.empleado(
	Legajo 		  INT PRIMARY KEY,
	Nombre 	  	  VARCHAR(30),
	Apellido 	  VARCHAR(30),
	DNI 		  INT UNIQUE NOT NULL,
	Direccion 	  VARCHAR(100),
	EmailPersonal VARCHAR(100),
	EmailEmpresa  VARCHAR(100),
	CUIL          CHAR(11),
	Turno 		  CHAR(16) CHECK (Turno ='TN' OR Turno ='TM' OR turno = 'TT' OR Turno ='Jornada Completa'),
	Cargo 		  INT,
	Sucursal 	  INT,
	FOREIGN KEY (Cargo)    REFERENCES infraestructura.cargo(IdCargo),
	FOREIGN KEY (Sucursal) REFERENCES infraestructura.Sucursal(IdSucursal)
)
GO

CREATE TABLE facturacion.TipoCliente(
    IDTipoCliente INT IDENTITY(1,1) PRIMARY KEY,
	nombre 		  VARCHAR(20) UNIQUE NOT NULL 	
)
GO

CREATE TABLE facturacion.cliente(
	IDCliente 	  INT IDENTITY(1,1) PRIMARY KEY,
	DNI 	  	  INT UNIQUE NOT NULL,
	CUIL 	  	  INT UNIQUE NOT NULL, -- calculable
	Nombre 	  	  VARCHAR(25),
	Apellido  	  VARCHAR(25),
	Genero 		  CHAR(1) CHECK (Genero='M' OR Genero='F'),
	IDTipoCliente INT,
	FOREIGN KEY (IDTipoCliente) REFERENCES facturacion.TipoCliente(IDTipoCliente)
)
GO

CREATE TABLE deposito.categoria(
	IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
	Descripcion VARCHAR(50) UNIQUE NOT NULL,
)
GO

CREATE TABLE deposito.producto(
	IDProducto 		 INT IDENTITY(1,1) PRIMARY KEY,
    categoria 		 INT,
	Nombre 			 VARCHAR(100),
	Precio 			 DECIMAL(9,2),
	PrecioReferencia DECIMAL(9,2),
	UnidadReferencia CHAR(100),
    Fecha 			 DATETIME,
	FOREIGN KEY (categoria) REFERENCES deposito.categoria(IDCategoria)
)
GO

CREATE TABLE facturacion.factura(
	ID 		   INT IDENTITY(1,1) PRIMARY KEY,
	letra 	   CHAR CHECK (Letra = 'A' OR Letra = 'B' OR Letra = 'C'),
	numero 	   CHAR(11),
	Fecha 	   DATE,
	Hora 	   TIME,
	MontoIVA   DECIMAL(9,2),
	MontoNeto  DECIMAL(9,2),
	MontoBruto DECIMAL(9,2),
	CUIL 	   CHAR(13),
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

CREATE TABLE facturacion.nota(
	ID 		INT IDENTITY(1,1) PRIMARY KEY,
	factura INT,
	tipo 	CHAR(2) CHECK (tipo = 'NC' OR tipo = 'ND'), 
	numero 	CHAR(11),
	Fecha 	DATE,
	Hora 	TIME,
	Importe DECIMAL(9,2),
	CUIL 	CHAR(13),
	FOREIGN KEY (factura) REFERENCES facturacion.factura(ID)
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

/*CREATE NONCLUSTERED INDEX idx_Venta_Numero
ON facturacion.Venta (numero)
GO*/

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

USE master
GO