/*
--------------------------- encriptacion de datos empleado -----------------------------------------
USE COM2900G09
GO
-- Agregamos campo para los datos cifrados
ALTER TABLE infraestructura.empleado
    ADD DireccionCifrada VARBINARY(256),
        EmailPersonalCifrado VARBINARY(256);
GO

---- dropeamos la direccion sin cifrar? ------


-- Obtenemos la clave de cifrado 
DECLARE @FraseClave NVARCHAR(128) = 'CifraDatos';

-- Ciframos los datos personales de los empleados.



------------------------- ACTUALIZACION DE TABLA EMPLEADOS DESPUES DE HABER SIDO IMPORTADOS -----------------------------

UPDATE infraestructura.empleado
SET 
    DireccionCifrada = EncryptByPassPhrase(@FraseClave, Direccion, 1, CONVERT(VARBINARY, Legajo)),
    EmailPersonalCifrado = EncryptByPassPhrase(@FraseClave, EmailPersonal, 1, CONVERT(VARBINARY, Legajo));
GO

-- vemos que se encripto correctamente 

SELECT Legajo, DireccionCifrada, EmailPersonalCifrado
FROM infraestructura.empleado;

-- PARA DESENCRIPTAR ------

DECLARE @FraseClave NVARCHAR(128) = 'CifraDatos';

SELECT 
    Legajo,
    CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, DireccionCifrada, 1, CONVERT(VARBINARY, Legajo))) AS DireccionDesencriptada,
    CONVERT(NVARCHAR(MAX), DecryptByPassPhrase(@FraseClave, EmailPersonalCifrado, 1, CONVERT(VARBINARY, Legajo))) AS EmailPersonalDesencriptado
FROM infraestructura.empleado;

-----------------------------------------------------------------------------


--------------------------- para cualquiera de los casos para los siguietntes ingresos se modificaria el insert --------

CREATE OR ALTER PROCEDURE infraestructura.InsertarEmpleado
    @Legajo INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @DNI INT,
    @Direccion VARCHAR(100),
    @EmailPersonal VARCHAR(100),
    @EmailEmpresa VARCHAR(100),
    @CUIL CHAR(11),
    @Turno CHAR(16),
    @Cargo INT,
    @Sucursal INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		
        --INSERT INTO infraestructura.Empleado (Legajo, Nombre, Apellido, DNI, Direccion, EmailPersonal, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
		--VALUES (@Legajo, @Nombre, @Apellido, @DNI, @Direccion, @EmailPersonal, @EmailEmpresa, @CUIL, @Turno, @Cargo, @Sucursal);

		-----------------CAMBIO--------------------------
		INSERT INTO infraestructura.empleado (Legajo, Nombre, Apellido, DNI, DireccionCifrada, EmailPersonalCifrado, EmailEmpresa, CUIL, Turno, Cargo, Sucursal)
		VALUES 
            (
                @Legajo,
                @Nombre,
                @Apellido,
                @DNI,
                -- Encriptaci?n de Direccion y EmailPersonal al momento de la inserci?n
                EncryptByPassPhrase(@FraseClave, @Direccion, 1, CONVERT(VARBINARY, @Legajo)),
                EncryptByPassPhrase(@FraseClave, @EmailPersonal, 1, CONVERT(VARBINARY, @Legajo)),
                @EmailEmpresa,
                @CUIL,
                @Turno,
                @Cargo,
                @Sucursal
            );
        ----------------------------------------------------------


        COMMIT TRANSACTION;
        PRINT 'Empleado insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al intentar insertar el Empleado: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO




*/