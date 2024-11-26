/*
El sistema debe ofrecer los siguientes reportes en xml:
- Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
- Trimestral: mostrar el total facturado por turnos de trabajo por mes.
- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor.
- Mostrar los 5 productos más vendidos en un mes, por semana
- Mostrar los 5 productos menos vendidos en el mes.
- Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares
*/

USE COM2900G09
GO

-- Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
CREATE OR ALTER PROCEDURE reportes.Mensual
	@Mes INT,
	@Año INT
AS
BEGIN
	WITH FacMes AS(
	SELECT DATEPART(WEEKDAY, fecha) AS DiaNum, MontoBruto
		FROM facturacion.factura
			WHERE Fecha >= DATEFROMPARTS(@Año, @Mes, 1) -- Fecha inicio
			  AND Fecha <= DATEADD(DAY,-1, DATEADD(MONTH, 1, DATEFROMPARTS(@Año, @Mes, 1))) -- Fecha fin
    )
    
    -- Generar .XML
    SELECT *
        FROM (SELECT CASE DiaNum 
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'
			END DiaSemana,
			SUM(MontoBruto) AS TotalFacturado
		FROM FacMes
			GROUP BY DiaNum) Datos
			FOR XML PATH('MENSUAL')
END
GO

-- Trimestral: mostrar el total facturado por turnos de trabajo por "trimestre".
CREATE OR ALTER PROCEDURE reportes.Trimestral
AS
BEGIN
	WITH Datos AS(
	-- Trimetre 1
	SELECT c.Turno, 'Trimestre 1' AS Trimestre, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
			  AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 4, 1))
			/*WHERE a.fecha >= DATEFROMPARTS(2019, 1, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2019, 4, 1))*/
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 2
	SELECT c.Turno, 'Trimestre 2' AS Trimestre, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), 4, 1)
			  AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 7, 1))
			/*WHERE a.fecha >= DATEFROMPARTS(2019, 4, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2019, 7, 1))*/
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 3
	SELECT c.Turno, 'Trimestre 3' AS Trimestre, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), 7, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 10, 1))
			/*WHERE a.fecha >= DATEFROMPARTS(2019, 7, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2019, 10, 1))*/
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 4
	SELECT c.Turno, 'Trimestre 4' AS Trimestre, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), 10, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()) +1, 1, 1))
			/*WHERE a.fecha >= DATEFROMPARTS(2019, 10, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2020, 1, 1))*/
			GROUP BY c.Turno
	)
	
    -- Generar .XML
	SELECT *
        FROM Datos
        FOR XML PATH('TRIMESTRALxTURNO')
END
GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
CREATE OR ALTER PROCEDURE reportes.ProductosFecha
    @Inicio DATE,
    @Fin    DATE
AS
BEGIN
    WITH Datos AS(
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha >= @Inicio
              AND a.fecha <= @Fin
            GROUP BY d.nombre		
    )

    -- Generar .XML
    SELECT *
        FROM Datos
			ORDER BY Acumulado DESC
        FOR XML PATH('CANTIDADxRANGO')
END
GO

-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor.
CREATE OR ALTER PROCEDURE reportes.ProductosSucursalFecha
  @Inicio DATE,
  @Fin    DATE
AS
BEGIN
    WITH Datos AS(
    SELECT f.Ciudad, d.nombre, SUM(c.cantidad) AS Acumulado
        FROM facturacion.factura            AS a
        INNER JOIN facturacion.venta        AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta   AS c ON c.ID		 = b.ID
        INNER JOIN deposito.producto        AS d ON d.IDProducto = c.IDProducto
        INNER JOIN infraestructura.empleado AS e ON e.Legajo	 = b.empleado
        INNER JOIN infraestructura.sucursal AS f ON f.IDsucursal = e.Sucursal
            WHERE a.fecha >= @Inicio
              AND a.fecha <= @Fin
            GROUP BY f.Ciudad, d.nombre
    )
    
    -- Generar .XML
    SELECT *
        FROM Datos
            ORDER BY Acumulado DESC
			FOR XML PATH('CANTIDADxSUCURSAL')
END
GO

-- Mostrar los 5 productos más vendidos en un mes, por semana
CREATE OR ALTER PROCEDURE reportes.TopProductosXSemana
AS
BEGIN
    WITH Datos AS(
    -- Semana 1
    --SELECT TOP 5 d.nombre, MONTH(GETDATE()) AS Mes, SUM(c.cantidad) AS Acumulado
	SELECT TOP 5 d.nombre, '1' AS Mes, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            --WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
              --AND a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 7)
			WHERE a.fecha >= DATEFROMPARTS(2019, 1, 1)
              AND a.fecha <= DATEFROMPARTS(2019, 1, 7)
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 2
    --SELECT TOP 5 d.nombre, MONTH(GETDATE()) AS Mes, SUM(c.cantidad) AS Acumulado
	SELECT TOP 5 d.nombre, '1' AS Mes, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            --WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 8)
              --AND a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 14)
			WHERE a.fecha >= DATEFROMPARTS(2019, 1, 8)
              AND a.fecha <= DATEFROMPARTS(2019, 1, 14)
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 3
    --SELECT TOP 5 d.nombre, MONTH(GETDATE()) AS Mes, SUM(c.cantidad) AS Acumulado 
	SELECT TOP 5 d.nombre, '1' AS Mes, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            --WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)
              --AND a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 21)
			WHERE a.fecha >= DATEFROMPARTS(2019, 1, 15)
              AND a.fecha <= DATEFROMPARTS(2019, 1, 21)
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 4
    --SELECT TOP 5 d.nombre, MONTH(GETDATE()) AS Mes, SUM(c.cantidad) AS Acumulado 
	SELECT TOP 5 d.nombre, '1' AS Mes, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            --WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 22)
              --AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())+1, 1))
			WHERE a.fecha >= DATEFROMPARTS(2019, 1, 22)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2019, 2, 1))
            GROUP BY d.nombre
			ORDER BY Acumulado
    )

    -- Generar .XML
    SELECT Nombre,
		CASE Mes 
			WHEN 1  THEN 'Enero'
			WHEN 2  THEN 'Febrero'
			WHEN 3  THEN 'Marzo'
			WHEN 4  THEN 'Abril'
			WHEN 5  THEN 'Mayo'
			WHEN 6  THEN 'Junio'
			WHEN 7  THEN 'Julio'
			WHEN 8  THEN 'Agosto'
			WHEN 9  THEN 'Septiembre'
			WHEN 10 THEN 'Octubre'
			WHEN 11 THEN 'Noviembre'
			WHEN 12 THEN 'Diciembre'
			END MesNombre,
			Acumulado
        FROM Datos
        FOR XML PATH('TOP5xSEMANAxMES')
END
GO

-- Mostrar los 5 productos menos vendidos en el mes.
CREATE OR ALTER PROCEDURE reportes.LowProductos
AS
BEGIN
    WITH Datos AS(

    --SELECT TOP 5 d.nombre, MONTH(GETDATE()) AS Mes, SUM(c.cantidad) AS Acumulado 
	SELECT TOP 5 d.nombre, '1' AS Mes, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            --WHERE a.fecha >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
              --AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())+1, 1))
			WHERE a.fecha >= DATEFROMPARTS(2019, 1, 1)
              AND a.fecha <= DATEADD(DAY, -1, DATEFROMPARTS(2019, 2, 1))
            GROUP BY d.nombre
			ORDER BY Acumulado ASC
    )

    -- Generar .XML
    SELECT Nombre,
		CASE Mes 
			WHEN 1  THEN 'Enero'
			WHEN 2  THEN 'Febrero'
			WHEN 3  THEN 'Marzo'
			WHEN 4  THEN 'Abril'
			WHEN 5  THEN 'Mayo'
			WHEN 6  THEN 'Junio'
			WHEN 7  THEN 'Julio'
			WHEN 8  THEN 'Agosto'
			WHEN 9  THEN 'Septiembre'
			WHEN 10 THEN 'Octubre'
			WHEN 11 THEN 'Noviembre'
			WHEN 12 THEN 'Diciembre'
			END MesNombre,
			Acumulado
        FROM Datos
        FOR XML PATH('LOW5MES')
END
GO

-- Mostrar total acumulado de ventas (o sea, tambien mostrar el detalle) para una fecha y sucursal particulares
CREATE OR ALTER PROCEDURE reportes.VentasFechaSucursal
	@Fecha    DATE,
	@Sucursal VARCHAR(20)
AS
BEGIN
	WITH Datos AS(
	SELECT SUM(c.MontoBruto) AS AcFacturacion, COUNT(a.ID) AS CantVent, '???' AS Y_Ahora?
		FROM facturacion.Venta				AS a
		INNER JOIN facturacion.lineaVenta	AS b ON b.ID		 = a.ID
		INNER JOIN facturacion.factura		AS c ON c.ID		 = a.IDFactura
		INNER JOIN infraestructura.empleado AS d ON d.Legajo	 = a.Empleado
		INNER JOIN infraestructura.sucursal AS e ON e.IDsucursal = d.Sucursal
			WHERE e.Ciudad = @Sucursal
			  AND c.Fecha  = @Fecha
	)

    -- Generar .XML
    SELECT *
        FROM Datos
		FOR XML PATH('ACUMULADOPARTICULAR')
END
GO

/*
EXEC reportes.Mensual @Mes = 1, @Año = 2019
GO

EXEC reportes.Trimestral
GO

DECLARE @tmp1 DATETIME
DECLARE @tmp2 DATETIME
SET @tmp1 = DATEADD(YEAR, -6, GETDATE())
SET @tmp2 = GETDATE()

EXEC reportes.ProductosFecha @inicio = @tmp1, @fin = @tmp2
GO

DECLARE @tmp1 DATETIME
DECLARE @tmp2 DATETIME
SET @tmp1 = DATEADD(YEAR, -6, GETDATE())
SET @tmp2 = GETDATE()

EXEC reportes.ProductosSucursalFecha @inicio = @tmp1, @fin = @tmp2
GO

EXEC reportes.TopProductosXSemana
GO

EXEC reportes.LowProductos
GO
*/
DECLARE @tmp DATETIME
SET @tmp = GETDATE()

EXEC reportes.VentasFechaSucursal @Fecha = @tmp, @Sucursal = 'Ramos Mejia'
GO

USE master
GO