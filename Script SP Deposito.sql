/*
Creacion de los Store procedures

Genere store procedures para manejar la insercion, modificado, borrado (si corresponde,
tambien debe decidir si determinadas entidades solo admitiran borrado logico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
*/

use COM2900G09
go

-- INSERTS

CREATE OR ALTER PROCEDURE deposito.InsertarCategoria
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDCategoria),0) FROM deposito.categoria);
    BEGIN TRY
        INSERT INTO deposito.Categoria (Descripcion)
        VALUES (@Descripcion);
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Categoria insertada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar la Categoria: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('deposito.Categoria', RESEED, @MaxID);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.InsertarProducto
    @Categoria INT,
    @Nombre VARCHAR(100),
    @Precio DECIMAL(9, 2),
    @PrecioReferencia DECIMAL(9, 2),
    @UnidadReferencia CHAR(2),
    @Fecha DATETIME
AS
BEGIN
    BEGIN TRANSACTION;
	DECLARE @MaxID INT;
	SET @MaxID = (SELECT isnull(MAX(IDProducto),0) FROM deposito.producto);
    BEGIN TRY
        INSERT INTO deposito.Producto (Categoria, Nombre, Precio, PrecioReferencia, UnidadReferencia, Fecha)
        VALUES (@Categoria, @Nombre, @Precio, @PrecioReferencia, @UnidadReferencia, @Fecha);
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID);
        COMMIT TRANSACTION;
        PRINT 'Producto insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Producto: ' + ERROR_MESSAGE();
        DBCC CHECKIDENT ('deposito.Producto', RESEED, @MaxID);
    END CATCH;
END;
GO

-- DELETES

CREATE OR ALTER PROCEDURE deposito.EliminarProducto
    @IDProducto INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.producto WHERE IDProducto = @IDProducto)
        BEGIN
            DELETE FROM deposito.producto WHERE IDProducto = @IDProducto;
            COMMIT TRANSACTION;
            PRINT 'Producto eliminado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Producto con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar el Producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.EliminarCategoria
    @IDCategoria INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            DELETE FROM deposito.categoria WHERE IDCategoria = @IDCategoria;
            COMMIT TRANSACTION;
            PRINT 'Categoria eliminada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el registro de Categoria con el ID especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar eliminar la Categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- UPDATES

CREATE OR ALTER PROCEDURE deposito.ActualizarProducto
    @IDProducto INT,
    @Categoria INT = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Precio DECIMAL(9,2) = NULL,
    @PrecioReferencia DECIMAL(9,2) = NULL,
    @UnidadReferencia CHAR(2) = NULL,
    @Fecha DATETIME = NULL
AS
BEGIN
    BEGIN TRANSACTION;
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
            WHERE IDProducto = @IDProducto;            
            COMMIT TRANSACTION;
            PRINT 'Producto actualizado correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro el producto con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar el producto: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE deposito.ActualizarCategoria
    @IDCategoria INT,
    @Descripcion VARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM deposito.Categoria WHERE IDCategoria = @IDCategoria)
        BEGIN
            UPDATE deposito.Categoria
				SET Descripcion = COALESCE(@Descripcion, Descripcion)
					WHERE IDCategoria = @IDCategoria;

            COMMIT TRANSACTION;
            PRINT 'Categoria actualizada correctamente.';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'No se encontro la categoria con el Id especificado.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar actualizar la categoria: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO
