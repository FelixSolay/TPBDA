use AuroraVentas
go

CREATE OR ALTER PROCEDURE ddbba.BulkCategoria
	@Path NVARCHAR(max)
AS
BEGIN
	DECLARE @SQLBulk NVARCHAR(max)

	SET @SQLBulk = 'BULK INSERT ddbba.producto 
					FROM '''+ @Path +''' 
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '','',
						ROWTERMINATOR = ''\n'',
						TABLOCK
					)'

	BEGIN TRY
		EXEC sp_executesql @SQLBulk
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH
END

EXEC ddbba.BulkCategoria @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'

select *
	from ddbba.producto

