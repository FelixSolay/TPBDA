CREATE OR ALTER trigger ON ddbba.lineaVenta FOR INSERT
AS
BEGIN
    DECLARE @Valor int

    BEGIN TRY
        SET @Valor = SELECT max(a.orden)
                        FROM ddbba.lineaVenta AS a
                        INNER JOIN inserted AS b ON a.IDVenta = b.IDVenta
    END TRY
    BEGIN CATCH
        set @Valor = 1
    END CATCH

    DBCC CHECKIDENT('ddbba.lineaVenta', RESEED, @Valor)
END
GO