
USE Com2900G03

--Encriptamiento de datos de la tabla empleado
--1) creamos clave maestra
go
create or alter procedure seguridad3.crearclavemaestra
as
begin
     create master key encryption by password='passwordGrupo3'
end
go

--creamos clave para encriptar
exec seguridad3.crearclavemaestra

--2) crear un certificado para encriptar
GO
create or alter procedure seguridad3.crearcertifiado
as
begin
	
    create certificate certificadoempleados
	   with subject='encriptacion de datos personales empleados'
end
go

--creamos certificado para encriptar
exec seguridad3.crearcertifiado

--3) crear una clave simetrica, protegida por el certificado
GO
create or alter procedure seguridad3.clavesimetrica
as
begin
    create symmetric key empleadoskey
	with algorithm= aes_256
	encryption by certificate certificadoempleados
	ALTER TABLE administracion3.Empleado ALTER COLUMN direccion nvarchar(256);
    ALTER TABLE administracion3.Empleado ALTER COLUMN email_Personal nvarchar(256);
	ALTER TABLE administracion3.Empleado ALTER COLUMN DNI nvarchar(256);
    ALTER TABLE administracion3.Empleado ALTER COLUMN CUIL nvarchar(256);
end
go

--creamos clave simetrica
exec seguridad3.clavesimetrica


--4) SP para encriptar datos
GO
create or alter procedure seguridad3.encriptardatosempleado
as
begin
    -- Abrimos la clave simétrica para encriptar los datos
    open symmetric key empleadoskey
    decryption by certificate certificadoempleados;

    -- Alteramos las columnas para soportar datos binarios

    -- Encriptamos las columnas con datos personales
    update administracion3.Empleado
    set Direccion = ENCRYPTBYKEY(key_guid('empleadoskey'), Direccion),
        email_Personal = ENCRYPTBYKEY(key_guid('empleadoskey'),email_Personal),
		DNI = ENCRYPTBYKEY(key_guid('empleadoskey'),DNI),
		CUIL = ENCRYPTBYKEY(key_guid('empleadoskey'),CUIL)
    where Direccion IS NOT NULL or email_Personal IS NOT NULL;

    -- Cerramos la clave simétrica
    close symmetric key empleadoskey;
end;
go

-- Procedimiento para desencriptar datos
	GO
	create or alter procedure seguridad3.desencriptardatosempleado
	as
	begin
		-- Abrimos la clave simétrica con el certificado
		open symmetric key empleadoskey
		decryption by certificate certificadoempleados;
		-- Seleccionamos los datos desencriptados
		UPDATE administracion3.Empleado
		  SET Direccion = CONVERT(nvarchar(256),DECRYPTBYKEY(direccion)),
			email_personal = CONVERT(nvarchar(256),DECRYPTBYKEY(email_Personal)),
			DNI =CONVERT(nvarchar(256),DECRYPTBYKEY(DNI)),
			CUIL =CONVERT(nvarchar(256),DECRYPTBYKEY(CUIL))
		ALTER TABLE administracion3.Empleado ALTER COLUMN DNI INT;

		-- Cerramos la clave simétrica
		close symmetric key empleadoskey;
	end;
	go
--pruebas
--mostramos tabla empleados sin encirptar
select * from administracion3.Empleado

--encriptamos datos de la tabla empleado
exec seguridad3.encriptardatosempleado

--verificamos que los datos hayan sido encriptados
select * from administracion3.Empleado
--Desencriptar Datos
exec seguridad3.desencriptardatosempleado;

--verificamos que los datos hayan sido desencriptados
select * from administracion3.Empleado
