use AuroraVentas
go

CREATE OR ALTER PROCEDURE ddbba.BulkProducto
	@Path NVARCHAR(max)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(max)

	SET @SQLBulk = 'BULK INSERT ddbba.CSVMem
					FROM ''' + @Path + ''' 
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '','',
						ROWTERMINATOR = ''\n''
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk

		INSERT ddbba.producto(Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
			SELECT Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha
				FROM ddbba.CSVMem WITH (SNAPSHOT)

				commit transaction
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

EXEC ddbba.BulkProducto @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'
go