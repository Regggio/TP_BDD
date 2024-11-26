---ENTREGA 5
GO
use Com2900G03
GO

	--Crear Roles-- 

IF NOT EXISTS (SELECT 1 
               FROM sys.database_principals 
               WHERE type = 'R' 
               AND name = 'Cajero')
CREATE ROLE Cajero;
GO

IF NOT EXISTS (SELECT 1 
               FROM sys.database_principals 
               WHERE type = 'R' 
               AND name = 'Supervisor')
CREATE ROLE Supervisor;
GO

	--Crea permisos al rol Supervisor
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA ::ventas3 TO Supervisor;
GRANT EXECUTE ON SCHEMA:: ventas3 TO Supervisor; 

GRANT SELECT, INSERT, UPDATE, DELETE ON administracion3.Producto TO Supervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON administracion3.Notadecredito TO Supervisor;

GRANT SELECT ON administracion3.Empleado TO Supervisor;

GRANT EXECUTE ON administracion3.InsertarProducto TO Supervisor;
GRANT EXECUTE ON administracion3.ModificarProducto TO Supervisor;
GRANT EXECUTE ON administracion3.BorrarProducto TO Supervisor;

GRANT EXECUTE ON administracion3.GenerarNotaDeCredito TO Supervisor;
/*GRANT EXECUTE ON administracion3.ModificarNotaDeCredito TO Supervisor;
GRANT EXECUTE ON administracion3.CancelarNotaDeCredito TO Supervisor;*/

	--Crea permisos al rol Vendedor

GRANT SELECT, INSERT ON ventas3.Venta TO Cajero;
GRANT SELECT, INSERT ON ventas3.Detalle_Venta TO Cajero;

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::administracion3 TO Cajero;
DENY EXECUTE ON SCHEMA::administracion3 TO Cajero;

-- Ventas
GRANT EXECUTE ON ventas3.TestFacturayVenta TO Cajero;
GRANT EXECUTE ON ventas3.InsertarFactura TO Cajero;
GRANT EXECUTE ON ventas3.BorrarFactura TO Cajero;
GRANT EXECUTE ON ventas3.ModificarFactura TO Cajero;
GRANT EXECUTE ON ventas3.InsertarVenta TO Cajero;
GRANT EXECUTE ON ventas3.ModificarVenta TO Cajero;
GRANT EXECUTE ON ventas3.BorrarVenta TO Cajero;
GRANT EXECUTE ON ventas3.Insertar_Detalle TO Cajero;
GRANT EXECUTE ON ventas3.Modificar_Detalle TO Cajero;
GRANT EXECUTE ON ventas3.Borrar_Detalle TO Cajero;


	--Creacion del Loggin 

IF NOT EXISTS (SELECT name, type_desc from sys.server_principals 
		where name ='Prueba1_V') 
Create login Prueba1_V with password= '1234' , default_database = "Com2900G03" ;
	
IF NOT EXISTS (SELECT name, type_desc from sys.server_principals 
		where name ='Prueba1_S') 
Create login Prueba1_S with password= '1234' , default_database = "Com2900G03" ;

	--Crear usuario para el login
IF NOT EXISTS (SELECT * from sys.database_principals 
		where name ='Prueba1_Usuario_V') 
Create user Prueba1_Usuario_V for login Prueba1_V;

IF NOT EXISTS (SELECT * from sys.database_principals 
		where name ='Prueba1_Usuario_S') 
Create user Prueba1_Usuario_S for login Prueba1_S;

	--Asignacion de roles
alter role Cajero add member Prueba1_Usuario_V;
go
alter role Supervisor add member Prueba1_Usuario_S;
go


---BACKUP
BACKUP DATABASE Com2900G03
TO DISK = 'C:\Backups\TP_Supermercado_GRPO3.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Backup TP_Supermercado_GRPO3';
