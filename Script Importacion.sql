/* EJECUTAR SOLO UNA VEZ */

use AuroraVentas
go

create table #CSVMem(
	IDProducto int primary key NONCLUSTERED,
    CategoriaDescripcion varchar(50),
	Nombre varchar(100),
	Precio decimal (9,2),
	PrecioReferencia decimal (9,2),
	UnidadReferencia varchar(2),
    Fecha datetime
)
go

CREATE OR ALTER PROCEDURE ddbba.BulkProducto
	@Path NVARCHAR(max)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	DECLARE @SQLBulk NVARCHAR(max)

	SET @SQLBulk = 'BULK INSERT #CSVMem
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
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH

	BEGIN TRY
	INSERT ddbba.producto(Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
		SELECT Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha
			FROM #CSVMem

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH

END
GO

EXEC ddbba.BulkProducto @Path = 'C:\Users\juanp\Downloads\catalogo2.csv'
go