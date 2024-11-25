---ENTREGA 5
GO
use Com2900G03
GO

	--Crear Roles-- 

IF NOT EXISTS (SELECT 1 
               FROM sys.database_principals 
               WHERE type = 'R' 
               AND name = 'Vendedor')
CREATE ROLE Vendedor;
GO

IF NOT EXISTS (SELECT 1 
               FROM sys.database_principals 
               WHERE type = 'R' 
               AND name = 'Supervisor')
CREATE ROLE Supervisor;
GO

	--Crea permisos al rol Supervisor
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA ::ventas TO Supervisor;
GRANT EXECUTE ON SCHEMA:: ventas TO Supervisor; 

GRANT SELECT, INSERT, UPDATE, DELETE ON administracion.Producto TO Supervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON administracion.NotaDeCredito TO Supervisor;

GRANT SELECT ON administracion.Empleado TO Supervisor;
GRANT SELECT ON administracion.FacturaControl TO Supervisor;

GRANT EXECUTE ON administracion.InsertarProducto TO Supervisor;
GRANT EXECUTE ON administracion.ModificarProducto TO Supervisor;
GRANT EXECUTE ON administracion.EliminarProducto TO Supervisor;

GRANT EXECUTE ON administracion.InsertarNotaDeCredito TO Supervisor;
GRANT EXECUTE ON administracion.ModificarNotaDeCredito TO Supervisor;
GRANT EXECUTE ON administracion.CancelarNotaDeCredito TO Supervisor;

	--Crea permisos al rol Vendedor

GRANT SELECT, INSERT ON ventas.Venta TO Vendedor;
GRANT SELECT, INSERT ON ventas.DetalleVenta TO Vendedor;

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::administracion TO Vendedor;
DENY EXECUTE ON SCHEMA::administracion TO Vendedor;

-- Ventas
GRANT EXECUTE ON ventas.IniciarVenta TO Vendedor;
GRANT EXECUTE ON ventas.AgregarDetalleVenta TO Vendedor;
GRANT EXECUTE ON ventas.ConfirmarVenta TO Vendedor;
GRANT EXECUTE ON ventas.ConfirmarPago TO Vendedor;
GRANT EXECUTE ON ventas.CambiarMetodoPago TO Vendedor;
GRANT EXECUTE ON ventas.CancelarVenta TO Vendedor;

-- Clientes
GRANT EXECUTE ON ventas.InsertarCliente TO Vendedor;
GRANT EXECUTE ON ventas.ModificarCliente TO Vendedor;
GRANT EXECUTE ON ventas.EliminarCliente TO Vendedor;

	--Creacion del Loggin 

IF NOT EXISTS (SELECT name, type_desc from sys.server_principals 
		where name ="Prueba1_V") 
Create login Prueba1_V with password= '1234' , default_database = "Com2900G03" ;
	
IF NOT EXISTS (SELECT name, type_desc from sys.server_principals 
		where name ="Prueba1_S") 
Create login Prueba1_S with password= '1234' , default_database = "Com2900G03" ;

	--Crear usuario para el login
IF NOT EXISTS (SELECT * from sys.database_principals 
		where name ="Prueba1_Usuario_V") 
Create user Prueba1_Usuario_V for login Prueba1_V;

IF NOT EXISTS (SELECT * from sys.database_principals 
		where name ="Prueba1_Usuario_S") 
Create user Prueba1_Usuario_S for login Prueba1_S;

	--Asignacion de roles
alter role Vendedor add member Prueba1_Usuario_V;
go
alter role Supervisor add member Prueba1_Usuario_S;
go


---BACKUP
BACKUP DATABASE Com2900G03
TO DISK = 'C:\Backups\TP_Supermercado_GRPO3.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Backup TP_Supermercado_GRPO3';

