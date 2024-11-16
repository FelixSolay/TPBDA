USE AuroraVentas
GO
--Cargar los datos de manera tal que tengan sentido con sus respectivas Foreign keys
--1° Cargar Categoría, Cargo, Tipo Cliente, Medio Pago, Sucursal
-- Categoría
INSERT INTO ddbba.categoria VALUES ('Almacen'),('Bazar'),('Bebidas'),
('Comida'),('Congelados'),('Frescos'),
('Hogar'),('Limpieza'),('Mascota'),
('Otros'),('Perfumeria')
GO
-- Cargo
INSERT INTO ddbba.cargo VALUES ('Cajero'),('Supervisor'),('Gerente de Sucursal')

select * from ddbba.sucursal
GO
-- Tipo Cliente
INSERT INTO ddbba.TipoCliente VALUES('Member'),('Normal')
GO
-- Medio Pago
INSERT INTO ddbba.MedioDePago VALUES('Credit card','Tarjeta de credito'),('Cash','Efectivo'),('Ewallet','Billetera Electronica')
GO
-- Sucursal
INSERT INTO ddbba.sucursal VALUES ('Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires','San Justo','L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.','5555-5551'),
								   ('Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires','Ramos Mejia','L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.','5555-5552'),
								   ('Pres. Juan Domingo Perón 763, B1753AWO Villa Luzuriaga, Provincia de Buenos Aires','Lomas del Mirador','L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.','5555-5553');
GO
--2° Cargar Empleado, Cliente, Pago, Producto
-- Empleado
INSERT INTO ddbba.empleado VALUES
(257020,'Romina Alejandra','ALIAS','36383025','Bernardo de Irigoyen 2647, San Isidro, Buenos Aires','RominaAlejandra_ALIAS@gmail.com','RominaAlejandra.ALIAS@superA.com','','TM',1,2),
(257021,'Romina Soledad','RODRIGUEZ','31816587','Av. Vergara 1910, Hurlingham, Buenos Aires','RominaSoledad_RODRIGUEZ@gmail.com','RominaSoledad.RODRIGUEZ@superA.com','','TT',1,2),
(257022,'Sergio Elio','RODRIGUEZ','30103258','Av. Belgrano 422, Avellaneda, Buenos Aires','SergioElio_RODRIGUEZ@gmail.com','SergioElio.RODRIGUEZ@superA.com','','TM',1,3),
(257023,'Christian Joel','ROJAS','41408274','Calle 7 767, La Plata, Buenos Aires','ChristianJoel_ROJAS@gmail.com','ChristianJoel.ROJAS@superA.com','','TT',1,3),
(257024,'María Roberta de los Angeles','ROLON GAMARRA','30417854','Av. Arturo Illia 3770, Malvinas Argentinas, Buenos Aires','MaríaRobertadelosAngeles_ROLONGAMARRA@gmail.com','MaríaRobertadelosAngeles.ROLONGAMARRA@superA.com','','TM',1,1),
(257025,'Rolando','LOPEZ','29943254','Av. Rivadavia 6538, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires','Rolando_LOPEZ@gmail.com','Rolando.LOPEZ@superA.com','','TT',1,1),
(257026,'Francisco Emmanuel','LUCENA','37633159','Av. Don Bosco 2680, San Justo, Buenos Aires','FranciscoEmmanuel_LUCENA@gmail.com','FranciscoEmmanuel.LUCENA@superA.com','','TM',2,2),
(257027,'Eduardo Matias','LUNA','30338745','Av. Santa Fe 1954, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires','EduardoMatias_LUNA@gmail.com','EduardoMatias.LUNA@superA.com','','TM',2,3),
(257028,'Mauro Alberto','LUNA','34605254','Av. San Martín 420, San Martín, Buenos Aires','MauroAlberto_LUNA@gmail.com','MauroAlberto.LUNA@superA.com','','TM',2,1),
(257029,'Emilce','MAIDANA','36508254','Independencia 3067, Carapachay, Buenos Aires','Emilce_MAIDANA@gmail.com','Emilce.MAIDANA@superA.com','','TT',2,2),
(257030,'NOELIA GISELA FABIOLA','MAIDANA','34636354','Bernardo de Irigoyen 2647, San Isidro, Buenos Aires','NOELIAGISELAFABIOLA_MAIDANA@gmail.com','NOELIAGISELAFABIOLA.MAIDANA@superA.com','','TT',2,3),
(257031,'Fernanda Gisela Evangelina','MAIZARES','33127114','Av. Rivadavia 2243, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires','FernandaGiselaEvangelina_MAIZARES@gmail.com','FernandaGiselaEvangelina.MAIZARES@superA.com','','TT',2,1),
(257032,'Oscar Martín','ORTIZ','39231254','Juramento 2971, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires','OscarMartín_ORTIZ@gmail.com','OscarMartín.ORTIZ@superA.com','','Jornada completa',3,2),
(257033,'Débora','PACHTMAN','30766254','Av. Presidente Hipólito Yrigoyen 299, Provincia de Buenos Aires, Provincia de Buenos Aires','Débora_PACHTMAN@gmail.com','Débora.PACHTMAN@superA.com','','Jornada completa',3,3),
(257034,'Romina Natalia','PADILLA','38974125','Lacroze 5910, Chilavert, Buenos Aires','RominaNatalia_PADILLA@gmail.com','RominaNatalia.PADILLA@superA.com','','Jornada completa',3,1)
-- Cliente

-- Pago

-- Producto

--3° Cargar Venta

--4° Cargar Linea_Venta




