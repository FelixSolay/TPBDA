--------------------------- encriptacion de datos empleado -----------------------------------------
USE COM2900G09
GO

-- Vemos los datos no encriptados primero

SELECT 
    Legajo,
    DNI,
    Direccion,
    CUIL
FROM infraestructura.empleado
GO

--------------------------- PREPARAMOS LAS TABLAS ----------------------------------------------------
CREATE OR ALTER PROCEDURE PrerpararEncriptacionEmpleados
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.symmetric_keys 
        WHERE name = 'clave_simetrica_emp'
    )
    BEGIN
        CREATE SYMMETRIC KEY clave_simetrica_emp WITH ALGORITHM = AES_256
        ENCRYPTION BY PASSWORD = 'clavesegura1';
    END;

    DROP INDEX IF EXISTS idx_empleado_dni ON infraestructura.empleado;


	ALTER TABLE infraestructura.empleado DROP CONSTRAINT UQ_Empleado_DNI
	ALTER TABLE infraestructura.empleado DROP CONSTRAINT UQ_Empleado_CUIL
	ALTER TABLE infraestructura.empleado DROP CONSTRAINT CHK_Empleado_CUIL

	ALTER TABLE infraestructura.empleado ALTER COLUMN DNI nvarchar(256)
	ALTER TABLE infraestructura.empleado ALTER COLUMN Direccion nvarchar(256)
	ALTER TABLE infraestructura.empleado ALTER COLUMN CUIL nvarchar(256)
	ALTER TABLE infraestructura.empleado ADD Encriptado bit default 0 NOT NULL

	ALTER TABLE infraestructura.empleado ADD CONSTRAINT UQ_Empleado_DNI UNIQUE (DNI);
	ALTER TABLE infraestructura.empleado ADD CONSTRAINT UQ_Empleado_CUIL UNIQUE (CUIL);

	CREATE NONCLUSTERED INDEX idx_empleado_dni
    ON infraestructura.empleado (DNI);


END;
GO

EXEC PrerpararEncriptacionEmpleados;
GO

------------------------- SP DE ENCRIPTACION -----------------------------

CREATE OR ALTER PROCEDURE EncriptarEmpleados
AS
BEGIN
    OPEN SYMMETRIC KEY clave_simetrica_emp 
    DECRYPTION BY PASSWORD = 'clavesegura1';

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE infraestructura.empleado
        SET 
            DNI = EncryptByKey(Key_GUID('clave_simetrica_emp'), DNI),
            Direccion = EncryptByKey(Key_GUID('clave_simetrica_emp'), Direccion),
            CUIL = EncryptByKey(Key_GUID('clave_simetrica_emp'), CUIL),
            Encriptado = 1
        WHERE Encriptado = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al encriptar los datos: ' + ERROR_MESSAGE();
    END CATCH;
    CLOSE SYMMETRIC KEY clave_simetrica_emp;
END;
GO


---------------------------------- ENCRIPTAMOS --------------------------------------

EXEC EncriptarEmpleados;
GO

-- Vemos los datos despues de encriptar
SELECT 
    Legajo,
    DNI,
    Direccion,
    CUIL,
    Encriptado
FROM infraestructura.Empleado



------------------------------ DESENCRIPTAMOS ----------------------------------------

OPEN SYMMETRIC KEY clave_simetrica_emp 
DECRYPTION BY PASSWORD = 'clavesegura1';

SELECT 
    Legajo,
    CONVERT(NVARCHAR(256), DecryptByKey(DNI)) AS DNI_Original,
    CONVERT(NVARCHAR(256), DecryptByKey(Direccion)) AS Direccion_Original,
    CONVERT(NVARCHAR(256), DecryptByKey(CUIL)) AS CUIL_Original,
    Encriptado
FROM infraestructura.Empleado
CLOSE SYMMETRIC KEY clave_simetrica_emp;

