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
	SELECT DATEPART(WEEKDAY, fecha) AS DiaSemana, MontoBruto
		FROM facturacion.factura
			WHERE Fecha <= DATEFROMPARTS(@Año, @Mes, 1) -- Fecha inicio
			  AND Fecha >= DATEADD(DAY, 30, DATEFROMPARTS(@Año, @Mes, 1)) -- Fecha fin
    )

	SELECT DiaSemana, SUM(MontoBruto) AS TotalFacturado
		FROM FacMes
			GROUP BY DiaSemana
    
    -- Generar .XML
END
GO
/*
-- Trimestral: mostrar el total facturado por turnos de trabajo por mes.
CREATE OR ALTER PROCEDURE reportes.Trimestral

AS
BEGIN

END
GO
*/
-- Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
CREATE OR ALTER PROCEDURE reportes.ProductosFecha
    @Inicio DATE,
    @Fin    DATE
AS
BEGIN
    WITH Datos AS(
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= @Inicio
              AND a.fecha >= @Fin
            GROUP BY d.nombre
    )
    
    SELECT *
        FROM Datos
            ORDER BY Acumulado

    -- Generar .XML
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
        INNER JOIN facturacion.venta        AS b ON b.factura  = a.ID
        INNER JOIN facturación.LineaVenta   AS c ON c.ID       = b.ID
        INNER JOIN deposito.producto        AS d ON d.ID       = c.IDProducto
        INNER JOIN infraestructura.empleado AS e ON e.Legajo   = b.empleado
        INNER JOIN infraestructura.sucursal AS f ON f.sucursal = b.IDsucursal
            WHERE a.fecha <= @Inicio
              AND a.fecha >= @Fin
            GROUP BY f.Ciudad, d.nombre
    )
    
    SELECT *
        FROM Datos
            ORDER BY Acumulado

    -- Generar .XML
END
GO

-- Mostrar los 5 productos más vendidos en un mes, por semana
CREATE OR ALTER PROCEDURE reportes.TopProductosXSemana
AS
BEGIN
    WITH Datos AS(
    -- Semana 1
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado TOP 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 1 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 7 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 2
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado TOP 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 8  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 14 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 3
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado TOP 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 15 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 22 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 4
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado TOP 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 23  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 30 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    )

    SELECT *
        FROM Datos

    -- Generar .XML
END
GO

-- Mostrar los 5 productos menos vendidos en el mes.
CREATE OR ALTER PROCEDURE reportes.LowProductos
    WITH Datos AS(
    -- Semana 1
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado LAST 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 1 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 7 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 2
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado LAST 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 8  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 14 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 3
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado LAST 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 15 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 22 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    UNION ALL
    -- Semana 4
    SELECT d.nombre, SUM(c.cantidad) AS Acumulado LAST 5
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.factura = a.ID
        INNER JOIN facturación.LineaVenta AS c ON c.ID      = b.ID
        INNER JOIN deposito.producto      AS d ON d.ID      = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 23 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 30 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
    )

    SELECT *
        FROM Datos

    -- Generar .XML
AS
BEGIN

END
GO
/*
-- Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha y sucursal particulares
CREATE OR ALTER PROCEDURE reportes.VentasFechaSucursal

AS
BEGIN

END
GO
*/

EXEC reportes.Mensual @Mes = 1, @Año = 2024

USE master
GO