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
			  AND Fecha <= DATEADD(MONTH, 1, DATEFROMPARTS(@Año, @Mes, 1)) -- Fecha fin
    )

	SELECT CASE DiaNum 
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
			GROUP BY DiaNum
    
    -- Generar .XML
END
GO

-- Trimestral: mostrar el total facturado por turnos de trabajo por "trimestre".
CREATE OR ALTER PROCEDURE reportes.Trimestral
AS
BEGIN
	WITH Datos AS(
	-- Trimetre 1
	SELECT c.Turno, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
              AND a.fecha >= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 3, 1))
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 2
	SELECT c.Turno, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), 3, 1)
              AND a.fecha >= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 6, 1))
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 3
	SELECT c.Turno, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), 6, 1)
              AND a.fecha >= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), 9, 1))
			GROUP BY c.Turno
	UNION ALL
	-- Trimetre 4
	SELECT c.Turno, SUM(a.MontoBruto) AS Acumulado
		FROM facturacion.factura			AS a
		INNER JOIN facturacion.venta		AS b ON b.IDFactura  = a.ID
		INNER JOIN infraestructura.empleado AS c ON c.Legajo	 = b.empleado
			WHERE a.fecha <= DATEFROMPARTS(YEAR(GETDATE()), 9, 1)
              AND a.fecha >= DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE())+1, 1, 1))
			GROUP BY c.Turno
	)
	
	SELECT *
        FROM Datos

    -- Generar .XML
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
        INNER JOIN facturacion.venta        AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta   AS c ON c.ID		 = b.ID
        INNER JOIN deposito.producto        AS d ON d.IDProducto = c.IDProducto
        INNER JOIN infraestructura.empleado AS e ON e.Legajo	 = b.empleado
        INNER JOIN infraestructura.sucursal AS f ON f.IDsucursal = e.Sucursal
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
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 1 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 7 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 2
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 8  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 14 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 3
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 15 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 22 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado
    UNION ALL
    -- Semana 4
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 23  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 30 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado
    )

    SELECT *
        FROM Datos

    -- Generar .XML
END
GO

-- Mostrar los 5 productos menos vendidos en el mes.
CREATE OR ALTER PROCEDURE reportes.LowProductos
AS
BEGIN
    WITH Datos AS(
    -- Semana 1
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 1 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 7 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado ASC
    UNION ALL
    -- Semana 2
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 8  - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 14 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado ASC
    UNION ALL
    -- Semana 3
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 15 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 22 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado ASC
    UNION ALL
    -- Semana 4
    SELECT TOP 5 d.nombre, SUM(c.cantidad) AS Acumulado 
        FROM facturacion.factura          AS a
        INNER JOIN facturacion.venta      AS b ON b.IDFactura  = a.ID
        INNER JOIN facturacion.lineaVenta AS c ON c.ID		   = b.ID
        INNER JOIN deposito.producto      AS d ON d.IDProducto = c.IDProducto
            WHERE a.fecha <= DATEADD(DAY, 23 - DAY(GETDATE()), EOMONTH(GETDATE()))
              AND a.fecha >= DATEADD(DAY, 30 - DAY(GETDATE()), EOMONTH(GETDATE()))
            GROUP BY d.nombre
			ORDER BY Acumulado ASC
    )

    SELECT *
        FROM Datos

    -- Generar .XML
END
GO

-- Mostrar total acumulado de ventas (o sea, tambien mostrar el detalle) para una fecha y sucursal particulares
CREATE OR ALTER PROCEDURE reportes.VentasFechaSucursal
	@Fecha    DATE,
	@Sucursal VARCHAR(20)
AS
BEGIN
	WITH Datos AS(
	SELECT b.*
		FROM facturacion.Venta				AS a
		INNER JOIN facturacion.lineaVenta	AS b ON b.ID		 = a.ID
		INNER JOIN facturacion.factura		AS c ON c.ID		 = a.IDFactura
		INNER JOIN infraestructura.empleado AS d ON d.Legajo	 = a.Empleado
		INNER JOIN infraestructura.sucursal AS e ON e.IDsucursal = d.Sucursal
			WHERE e.Ciudad = @Sucursal
			  AND c.Fecha  = @Fecha
	)

    SELECT *
        FROM Datos

    -- Generar .XML
END
GO

--EXEC reportes.Mensual @Mes = 1, @Año = 2019
--EXEC reportes.Trimestral
--EXEC reportes.ProductosFecha @inicio =
--EXEC reportes.ProductosSucursalFecha @inicio =
--EXEC reportes.TopProductosXSemana
--EXEC reportes.LowProductos
--EXEC reportes.VentasFechaSucursal @Fecha = @Sucursal =

USE master
GO