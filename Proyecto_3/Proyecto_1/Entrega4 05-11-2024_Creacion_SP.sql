---ENTREGA 4
---CREACION DE SP PARA LA IMPORTACION DE ARCHIVOS
---Habilitacion de la configuracion del	servidor para consultas distribuidas (necesarias para utilizar el openrowset)
USE TP_Supermercado_GRPO3
GO
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 0
GO

--Importacion de Catalogo (Archivo CSV)
GO
CREATE OR ALTER PROCEDURE import3.Importacion_catalogo 
	@rutacsv nvarchar(max),
	@rutaxlsx nvarchar(max)
as
begin
	CREATE TABLE grupo3.#Producto_Temp(id_Producto int  primary key ,  
							 Categoria varchar(40),
							 Nombre varchar(100),
							 Precio_Unitario decimal(10,2),
							 Precio_De_Referencia decimal(10,2),
							 Unidad_De_Refrencia varchar(6),
							 Fecha date)
	CREATE TABLE grupo3.#Linea_Productos(Linea varchar(12) ,
										Producto varchar(50),
										CONSTRAINT pk_Linea primary key(Linea,Producto))
	DECLARE @sql nvarchar(max)
	SET @sql = '
	BULK INSERT grupo3.#Producto_Temp
	FROM ''' +@rutacsv+ '''
	WITH
	(
	FORMAT = ''CSV'',
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''0x0A'',
    FIRSTROW = 2,
	CODEPAGE = ''65001''
	)';

	EXEC sp_executesql @sql;

	SET @sql = '
    INSERT INTO grupo3.#Linea_Productos (Linea, Producto)
    SELECT [Línea de producto] as Linea, Producto
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @rutaxlsx + ''',
        ''SELECT * FROM [Clasificacion Productos$]'')';

	EXEC sp_executesql @sql;

	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,Unidad_De_Refrencia,FechaAlta)
	SELECT pt.Categoria, lp.Linea, pt.Nombre, pt.Precio_Unitario, pt.Precio_De_Referencia,
	pt.Unidad_De_Refrencia, pt.Fecha
	FROM grupo3.#Producto_Temp pt
	LEFT JOIN grupo3.#Linea_Productos lp ON lp.Producto = pt.Categoria
	where pt.nombre not in ( SELECT Nombre From grupo3.Producto)

	DROP TABLE if EXISTS grupo3.#Producto_Temp
	DROP TABLE IF EXISTS grupo3.#Linea_Productos
end
GO

exec import3.Importacion_catalogo 'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\catalogo.csv',
								'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'

---CREARCION DE SP PARA INSERCION DE CUCURSALES DEL ARCHIVO INFORMACION COMPLEMENTARIA
/* Seguimos el ejemplo del https://learn.microsoft.com/es-es/sql/relational-databases/import-export/import-data-from-excel-to-sql?view=sql-server-ver16#openrowset-and-linked-servers 
 Si esta bien deberia hacerse la insercion igual para los otros tabs de la hoja de excel */
 --SP PARA IMPORTACION DE SUCURSALES
GO
CREATE OR ALTER PROCEDURE import3.Importacion_Suc 
	@ruta nvarchar(max)
as
begin 
	CREATE TABLE grupo3.#Sucursal_Temp(Ciudad varchar(20), 
										Sucursal varchar(30),
										Direccion varchar(100),
										Horario varchar(60),
										Telefono char(9))
	DECLARE @sql nvarchar(max)

	SET @sql = '
    INSERT INTO grupo3.#Sucursal_Temp (Ciudad, Sucursal, Direccion, Horario, Telefono)
    SELECT Ciudad, [Reemplazar por] as Sucursal, direccion, Horario, Telefono
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @ruta + ''',
        ''SELECT * FROM [sucursal$]'')
		WHERE [Reemplazar por] NOT IN (SELECT Sucursal FROM grupo3.Sucursal)';

EXEC sp_executesql @sql;

	INSERT INTO grupo3.Sucursal(Ciudad,Sucursal,Direccion,Horario,Telefono)
	SELECT s.Ciudad, s.Sucursal, s.Direccion, s.Horario, s.Telefono
	from grupo3.#Sucursal_Temp s

	DROP TABLE IF EXISTS grupo3.#Sucursal_Temp 
end
go

exec import3.Importacion_Suc 'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'

--SP PARA INSERSCION DE EMPLEADOS
GO
CREATE OR ALTER PROCEDURE import3.Importacion_Emp 
	@ruta nvarchar(max)
as
begin 
	CREATE TABLE grupo3.#Empleado_Temp(id_Empleado int,
							 Nombre varchar(40),
							 Apellido varchar(30),
							 DNI int,
							 Direccion varchar(100),
							 email_Personal varchar(60),
							 email_Empresa varchar(60),
							 CUIL char(11),
							 Cargo varchar(30),
							 Sucursal varchar(30),
							 Turno varchar(20),
							 constraint CHK_TURNO CHECK(Turno IN('TT','TM','Jornada completa')));
	DECLARE @sql nvarchar(max)

	SET @sql = '
    INSERT INTO grupo3.#Empleado_Temp (id_Empleado, Nombre, Apellido, DNI, Direccion, email_Personal, email_Empresa, Cargo, Sucursal, Turno)
    SELECT [Legajo/ID] as id_Empleado, Nombre, Apellido, DNI, Direccion, 
			[email personal] as email_Personal , [email empresa] as email_Empresa, Cargo, Sucursal, Turno
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @ruta + ''',
        ''SELECT * FROM [Empleados$]''
    ) WHERE [Legajo/ID] IS NOT NULL AND DNI NOT IN (SELECT DNI FROM grupo3.Empleado)';

EXEC sp_executesql @sql;

	INSERT INTO grupo3.Empleado(Nombre,Apellido,DNI,Direccion,email_Personal,email_Empresa,CUIL,id_Sucursal,Turno)
	SELECT e.Nombre, e.Apellido, e.DNI, e.Direccion ,REPLACE(REPLACE(e.email_Personal,' ',''),CHAR(9),''),
	       REPLACE(REPLACE(e.email_Empresa,' ',''),CHAR(9),''), e.CUIL, s.id_sucursal, e.Turno
	FROM grupo3.Sucursal s
	INNER JOIN grupo3.#Empleado_Temp e ON s.Sucursal = e.Sucursal
	
	DROP TABLE IF EXISTS grupo3.#Empleado_Temp
end
GO

exec import3.Importacion_Emp @ruta = 'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'

--IMPORTACION VENTAS	
---HACE FALTA UN JOIN CON EMPLEADOS?
--- VENTA Y FACTURA SON DOS TABLAS SEPARADAS? EN LA IMPORTACION ESTA TODO JUNTO Y SE RELACIONAN, COMO PODRIA SEPARARLO
GO
CREATE OR ALTER PROCEDURE import3.Importacion_Venta as
BEGIN

	CREATE TABLE grupo3.#Venta_Temp(id_factura int,
									Tipo_Factura char(1),
									Ciudad varchar(30),
									Tipo_Cliente varchar(20),
									Genero varchar(10),
									Producto varchar(100),
									Precio_Unitario decimal(10,2),
									Cantidad int,
									Fecha date,
									Hora time,
									Medio_De_Pago varchar(20),
									Empleado int,
									identificador_de_pago varchar(80),
									constraint chk_Tipo CHECK(Tipo_Cliente IN ('Normal','Member')));

	BULK INSERT TP_Supermercado_GRPO3.grupo3.#Venta_Temp
		FROM 'C:\Users\HP\Desktop\TP_integrador_Archivos\Ventas_registradas.csv'
		WITH
		(
		FORMAT = 'CSV',
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		CODEPAGE = '65001'
		);

	INSERT INTO grupo3.Venta(Total,Cantidad,id_Producto,id_Empleado,fecha)
	SELECT (vt.Cantidad*p.Precio_Unitario) as Total,vt.Cantidad, p.id_Producto, e.id_Empleado, vt.Fecha
	FROM grupo3.#Venta_Temp vt
	INNER JOIN grupo3.Producto p ON vt.Producto = p.Nombre
	INNER JOIN grupo3.Empleado e ON e.id_Empleado = vt.Empleado

	/*INSERT DE FACTURAS*/

END
GO

CREATE OR ALTER PROCEDURE import3.Importacion_Productos_Electronicos
	@ruta nvarchar(max)
AS
BEGIN
	CREATE TABLE grupo3.#Productos_Electronicos(Categoria varchar(40) default 'Electrodomesticos',
												Linea_De_Producto varchar(25) default 'Electronic_accessories',
												Nombre varchar(100),
												Precio_Unitario decimal(10,2),
												Unidad_De_Refrencia varchar(6) default 'ud',
												FechaAlta date default CONVERT(DATE,getdate()),
												FechaBaja date)
	DECLARE @sql nvarchar(max)

	SET @sql = '
    INSERT INTO grupo3.#Productos_Electronicos (Nombre, Precio_Unitario)
    SELECT [Product] as Nombre, [Precio Unitario en dolares] as Precio_Unitario
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @ruta + ''',
        ''SELECT * FROM [Sheet1$]'')
		WHERE [Product] NOT IN (SELECT Nombre FROM grupo3.Producto)';

EXEC sp_executesql @sql;
	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,
								Unidad_De_Refrencia,FechaAlta)
	SELECT p.Categoria, p.Linea_De_Producto, p.Nombre, p.Precio_Unitario, p.Precio_Unitario,
			p.Unidad_De_Refrencia, p.FechaAlta 
	from grupo3.#Productos_Electronicos p

	DROP TABLE IF EXISTS grupo3.#Empleado_Temp

END
GO

GO
exec import3.Importacion_Productos_Electronicos 
				'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
GO 
--INCOMPLETO, REVISAR
CREATE OR ALTER PROCEDURE import3.Poductos_Importados
	@ruta nvarchar(max)
AS
BEGIN
CREATE TABLE grupo3.#Productos_Importados(Categoria varchar(40) default 'Electrodomesticos',
												Linea_De_Producto varchar(25) default 'Electronic_accessories',
												Nombre varchar(100),
												Precio_Unitario decimal(10,2),
												Unidad_De_Refrencia varchar(6) default 'ud',
												FechaAlta date default CONVERT(DATE,getdate()),
												FechaBaja date)
	DECLARE @sql nvarchar(max)

	SET @sql = '
    INSERT INTO grupo3.#Productos_Importados (Nombre, Precio_Unitario)
    SELECT [Product] as Nombre, [Precio Unitario en dolares] as Precio_Unitario
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @ruta + ''',
        ''SELECT * FROM [Listado de Productos$]'')
		WHERE [Product] NOT IN (SELECT Nombre FROM grupo3.Producto)';

EXEC sp_executesql @sql;
	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,
								Unidad_De_Refrencia,FechaAlta)
	SELECT p.Categoria, p.Linea_De_Producto, p.Nombre, p.Precio_Unitario, p.Precio_Unitario,
			p.Unidad_De_Refrencia, p.FechaAlta 
	from grupo3.#Productos_Electronicos p

	DROP TABLE IF EXISTS grupo3.#Empleado_Temp
END
