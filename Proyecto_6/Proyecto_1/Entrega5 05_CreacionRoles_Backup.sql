---ENTREGA 5
GO
use Com2900G03
GO
--Crear usuario--

CREATE LOGIN SupervisorLogin WITH PASSWORD = 'BaseDatos1';
CREATE USER SupervisorUser FOR LOGIN SupervisorLogin;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
begin
    CREATE ROLE Supervisor;
end
GRANT EXECUTE ON OBJECT::insert3.GenerarNotaDeCredito TO Supervisor;
ALTER ROLE Supervisor ADD MEMBER SupervisorUser;


--Encriptamiento de datos de la tabla empleado
--1) creamos clave maestra
create or alter procedure seguridad.crearclavemaestra
as
begin
     create master key encryption by password='passwordGrupo3'
end
go

--2) crear un certificado para encriptar
create or alter procedure seguridad.crearcertifiado
as
begin
	
    create certificate certificadoempleados
	   with subject='encriptacion de datos personales empleados'
end
go

--3) crear una clave simetrica, protegida por el certificado
create or alter procedure seguridad.clavesimetrica
as
begin
    create symmetric key empleadoskey
	with algorithm= aes_256
	encryption by certificate certificadoempleados
end
go

--4) SP para encriptar los datos del empleado
create or alter procedure seguridad.encriptardatosempleado
as
begin
 --primero abrimos la clave simetrica para encriptar los datos
open symmetric key empleadoskey
decryption by certificate certificadoempleados;
 --encriptamos las columnas con datos personales
 ALTER TABLE grupo3.Empleado ALTER COLUMN direccion nvarchar(256)
 ALTER TABLE grupo3.Empleado ALTER COLUMN email_Personal nvarchar(256)
 update grupo3.Empleado
 set direccion=ENCRYPTBYKEY (key_guid('empleadoskey'),direccion),
     email_Personal=ENCRYPTBYKEY (key_guid('empleadoskey'),email_Personal)
	 --dni=ENCRYPTBYKEY (key_guid('empleadoskey'),dni);
--cerramos clave simetrica
  close symmetric key empleadoskey;
end
go

--pruebas
--mostramos tabla empleados sin encirptar
select * from grupo3.empleado

--creamos clave para encriptar
drop master key
exec seguridad.crearclavemaestra

--creamos certificado para encriptar
exec seguridad.crearcertifiado

--creamos clave simetrica
exec seguridad.clavesimetrica

--encriptamos datos de la tabla empleado
exec seguridad.encriptardatosempleado

--verificamos que los datos hayan sido encriptados
select * from grupo3.empleado

---BACKUP
BACKUP DATABASE Com2900G03
TO DISK = 'C:\Backups\TP_Supermercado_GRPO3.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Backup TP_Supermercado_GRPO3';

