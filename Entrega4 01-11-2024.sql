---ENTREGA 4
--Importacion de Catalogo (Archivo CSV)
--ES NECESARIA LA CTE? FUNCIONA BIEN DENTRO DE UN SP?, COMO CORRIJO LOS PROBLEMAS QUE GENERAN LOS CARACTERES EXTRAÑOS?, PUEDO EVITAR CARGAR TOODS LOS DATOS DEL ARCHIVO?
--- EL FROM @DIRECCION ES VALIDO? O TENGO QUE HARCODEAR LA DIRECCION DEL ARCHIVO
---DEBERIA SER EN UNA TABLA TEMPORAL Y DESPUES SE ABRE EL OTRO ARCHIVO DE PRODUCTOS PARA AGREGARLE LA CATEGORIA
-- A LA HORA DE LA INSERCION HACER UN SELECT X UN VALOR PARA QUE NO INSERTE DE VULETA CAMPOS QUE YA INSERTO
GO
CREATE OR ALTER PROCEDURE grupo3.Importacion_catalogo as
begin
	CREATE TABLE grupo3.#Producto_Temp(id_Producto int  primary key ,  
							 Categoria varchar(40),
							 Nombre varchar(100),
							 Precio_Unitario decimal(10,2),
							 Precio_De_Referencia decimal(10,2),
							 Unidad_De_Refrencia varchar(6),
							 Fecha date)

	BULK INSERT TP_Supermercado_GRPO3.grupo3.#Producto_Temp
	FROM 'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\catalogo.csv'
	WITH
	(
	FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
	CODEPAGE = '65001'
	);

	INSERT INTO grupo3.Producto(id_Producto,Categoria,Nombre,Precio_Unitario,Precio_De_Referencia,Unidad_De_Refrencia,Fecha)
	SELECT * FROM grupo3.#Producto_Temp
end
GO

GO
exec grupo3.Importacion_catalogo 
GO

---Habilitacion de la configuracion del	servidor para consultas distribuidas (necesarias para utilizar el openrowset)
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
--PARAN LA EJECUCUION DEL SQL (PREGUNTAR OTRA FORMA PARA GARANTIZAR ACCESOS)
/*
EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 0;
EXEC sp_MSSet_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 0; 
*/

---CREARCION DE SP PARA INSERCION DE CUCURSALES DEL ARCHIVO INFORMACION COMPLEMENTARIA
/* Seguimos el ejemplo del https://learn.microsoft.com/es-es/sql/relational-databases/import-export/import-data-from-excel-to-sql?view=sql-server-ver16#openrowset-and-linked-servers 
 Si esta bien deberia hacerse la insercion igual para los otros tabs de la hoja de excel */
 --SP PARA INSERCION DE SUCURSALES
GO
CREATE OR ALTER PROCEDURE grupo3.Insercion_Suc as
begin 
	CREATE TABLE grupo3.#Sucursal_Temp(Ciudad varchar(20), 
										Reemplazo varchar(20),
										Direccion varchar(100),
										Horario varchar(60),
										Telefono char(9))
	INSERT INTO grupo3.#Sucursal_Temp SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0; Database=C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
	'SELECT * FROM [sucursal$]');

	INSERT INTO grupo3.Sucursal(Ciudad,Direccion,Horario,Telefono)
	SELECT Reemplazo, Direccion, Horario, Telefono
	from grupo3.#Sucursal_Temp
end
go

exec grupo3.Insercion_Suc

--
GO
CREATE OR ALTER PROCEDURE grupo3.Insercion_Emp as
begin 
	CREATE TABLE grupo3.#Empleado_Temp(id_Empleado int identity(257020,1) primary key not null,
							 email_Personal varchar(40),
							 email_Empresa varchar(40),
							 CUIL char(11),
							 Sucursal varchar(20) not null references grupo3.Sucursal(Ciudad),
							 Turno varchar(15),
							 constraint chk_Cuil CHECK(CUIL LIKE ('[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')),
							 constraint chk_Turno CHECK(Turno IN('TM','TT','Joranada Completa')));

	INSERT INTO grupo3.#Empleado_Temp SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0; Database=C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
	'SELECT * FROM [Empleados$]');
	INSERT INTO grupo3.Empleado(email_Personal,email_Empresa,CUIL,id_Sucursal,Turno)
	SELECT email_Personal, email_Emprsa, CUIL, id_sucursal, Turno
	FROM grupo3.#Empleado_Temp 
	INNER JOIN from grupo3.Sucursal as s ON s.Ciudad = grupo3.#Empleado_Temp.Sucursal
end
go
