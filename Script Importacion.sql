use AuroraVentas
go

/*
insert ddbba.categoria values ('fruta')

select *
	from ddbba.categoria
go
*/

CREATE OR ALTER PROCEDURE ddbba.BulkCategoria
	@Path VARCHAR(max)
AS
BEGIN
	DECLARE @SQLBulk VARCHAR(max)

-- Hay que agregar la extracion de la categoria del CSV e insertarlo tambien por BULK

-- Este SQL dinamico no funciona todavia, la idea es poder meter el Path al SP y que lo levante solo
	SET @SQLBulk = 'BULK INSERT ddbba.producto 
					FROM ''' + @Path + '''
					WITH
					(
						FIRSTROW = 2,
						DATAFILETYPE = ''char'',
						FIELDTERMINATOR = '','',
						ROWTERMINATOR = ''\n'',
						TABLOCK
					)'

	BEGIN TRY
		EXEC @SQLBulk
	END TRY
	BEGIN CATCH
		PRINT 'Error al ejecutar: ' + @Path
	END CATCH
END

EXEC ddbba.BulkCategoria @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'

select *
	from ddbba.producto