Create schema Seguridad
--Encriptamiento de datos de la tabla empleado
--1) creamos clave maestra
create or alter procedure seguridad.crearclavemaestra
as
begin
     create master key encryption by password='passwordGrupo3!'
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
 update grupo3.Empleado
 set direccion=ENCRYPTBYKEY (key_guid('empleadoskey'),direccion),
     mailpersonal=ENCRYPTBYKEY (key_guid('empleadoskey'),mailpersonal),
	 dni=ENCRYPTBYKEY (key_guid('empleadoskey'),dni);
--cerramos clave simetrica
  close symmetric key empleadoskey;
end
go

--pruebas
--mostramos tabla empleados sin encirptar
select * from grupo3.empleado

--creamos clave para encriptar
exec seguridad.crearclavemaestra

--creamos certificado para encriptar
exec seguridad.crearcertifiado

--creamos clave simetrica
exec seguridad.clavesimetrica

--encriptamos datos de la tabla empleado
exec seguridad.encriptardatosempleado

--verificamos que los datos hayan sido encriptados
select * from grupo3.empleado
