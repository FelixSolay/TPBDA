/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
*/

use COM2900G09
go

-------------------- CATEGORIA --------------------

CREATE OR ALTER PROCEDURE deposito.InsertarCategoria
    @Descripcion VARCHAR(50)
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar la Categoria: '
    BEGIN TRANSACTION

	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IDCategoria),0) FROM deposito.categoria)

    BEGIN TRY
        INSERT INTO deposito.Categoria (Descripcion)
			VALUES (@Descripcion)
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID)
        
        PRINT 'Categoria insertada correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID)
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE deposito.ActualizarCategoria
    @IDCategoria INT,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar la Categoria: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            UPDATE deposito.Categoria
				SET Descripcion = COALESCE(@Descripcion, Descripcion)
					WHERE IDCategoria = @IDCategoria

            PRINT 'Categoria actualizada correctamente.'
        END
        ELSE
        BEGIN
            PRINT 'No se encontro la categoria con el Id especificado.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

	COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE deposito.EliminarCategoria
    @IDCategoria INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar la Categoria: '	
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            DELETE FROM deposito.categoria 
				WHERE IDCategoria = @IDCategoria

            PRINT 'Categoria eliminada correctamente.'
        END
        ELSE
        BEGIN
            PRINT 'No se encontro el registro de Categoria con el ID especificado.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

	COMMIT TRANSACTION
END
GO

-------------------- PRODUCTO --------------------

CREATE OR ALTER PROCEDURE deposito.InsertarProducto
    @Categoria		  INT,
    @Nombre			  VARCHAR(100),
    @Precio			  DECIMAL(9, 2),
    @PrecioReferencia DECIMAL(9, 2),
    @UnidadReferencia VARCHAR(25),
    @Fecha			  DATETIME
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Insertar el Producto: '	
    BEGIN TRANSACTION

	DECLARE @MaxID INT
	SET @MaxID = (SELECT isnull(MAX(IDProducto),0) FROM deposito.producto)

    BEGIN TRY
        INSERT INTO deposito.Producto (Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
            VALUES (@Categoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia, @Fecha)
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID)
        
        PRINT 'Producto insertado correctamente.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID)
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE deposito.ActualizarProducto
    @IDProducto       INT,
    @Categoria        INT          = NULL,
    @Nombre           VARCHAR(100) = NULL,
    @Precio           DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia VARCHAR(25)  = NULL,
    @Fecha            DATETIME     = NULL
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Actualizar el Producto: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Producto WHERE IDProducto = @IDProducto)
        BEGIN
            UPDATE deposito.Producto
                SET Categoria = COALESCE(@Categoria, Categoria),
                    Nombre = COALESCE(@Nombre, Nombre),
                    Precio = COALESCE(@Precio, Precio),
                    PrecioReferencia = COALESCE(@PrecioReferencia, PrecioReferencia),
                    UnidadReferencia = COALESCE(@UnidadReferencia, UnidadReferencia),
                    Fecha = COALESCE(@Fecha, Fecha)
                    WHERE IDProducto = @IDProducto       
            
            PRINT 'Producto actualizado correctamente.'
        END
        ELSE
        BEGIN
            PRINT 'No se encontro el producto con el Id especificado.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE deposito.EliminarProducto
    @IDProducto INT
AS
BEGIN
	DECLARE @error VARCHAR(MAX) = 'Error al intentar Eliminar el Producto: '
    BEGIN TRANSACTION

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.producto WHERE IDProducto = @IDProducto)
        BEGIN
            DELETE FROM deposito.producto 
                WHERE IDProducto = @IDProducto

            PRINT 'Producto eliminado correctamente.'
        END
        ELSE
        BEGIN
            PRINT 'No se encontro el registro de Producto con el ID especificado.'
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
		SET @error = @error + ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
    END CATCH

    COMMIT TRANSACTION
END
GO