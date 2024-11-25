/*
Bases para el sistema y creación de SP de Importación

*/
USE COM2900G09
GO


EXEC deposito.InsertarCategoria @Descripcion = 'Electronic accessories'
GO

EXEC deposito.InsertarCategoria @Descripcion = 'Importados'
GO

EXEC deposito.InsertarCategoria @Descripcion = 'Descontinuado'
GO

EXEC deposito.InsertarProducto @Categoria = 3, @Nombre = 'Descontinuado', @Precio = 0, @PrecioReferencia = '0', @UnidadReferencia = '', @Fecha = ''
GO

DECLARE @FechaActual DATETIME;
SET @FechaActual = GETDATE();
EXEC facturacion.ConfigurarDatosFacturacion @CUIT='30646228685', @FechaInicio=@FechaActual, @RazonSocial='Aurora S.A.'
GO