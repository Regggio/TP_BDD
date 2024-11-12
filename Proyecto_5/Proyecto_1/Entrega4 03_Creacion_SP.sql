---ENTREGA 4
---CREACION DE SP PARA LA IMPORTACION DE ARCHIVOS
---Habilitacion de la configuracion del	servidor para consultas distribuidas (necesarias para utilizar el openrowset)
---------------------------------------------------------------------------------------------
GO
USE Com2900G03
GO
GO
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

---------------------------------------------------------------------------------------------

--Importacion de Catalogo (Archivo CSV)
---------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE import3.Importacion_catalogo 
	@rutacsv nvarchar(max),
	@rutaxlsx nvarchar(max)
as
begin
	CREATE TABLE grupo3.#Producto_Temp(id_Producto int primary key,  
							 Categoria varchar(40),
							 Nombre varchar(100),
							 Precio_Unitario decimal(10,2),
							 Precio_De_Referencia decimal(10,2),
							 Unidad_De_Referencia varchar(6),
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
	WITH EliminarDup AS (	--Hay repetidos, me fijo de quedarme solo la primera aparicion
		SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Nombre ORDER BY id_Producto) AS cantidad_rep
		FROM grupo3.#Producto_Temp
	)
	DELETE 
	FROM EliminarDup
	WHERE cantidad_rep > 1

	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,Unidad_De_Referencia,FechaAlta)
	SELECT pt.Categoria, lp.Linea, pt.Nombre, pt.Precio_Unitario, pt.Precio_De_Referencia,
	pt.Unidad_De_Referencia, pt.Fecha
	FROM grupo3.#Producto_Temp pt
	LEFT JOIN grupo3.Producto p ON pt.Nombre = p.Nombre
	LEFT JOIN grupo3.#Linea_Productos lp ON lp.Producto = pt.Categoria
	where p.nombre IS NULL

	DROP TABLE if EXISTS grupo3.#Producto_Temp
	DROP TABLE IF EXISTS grupo3.#Linea_Productos
end
GO
---------------------------------------------------------------------------------------------


 --SP PARA IMPORTACION DE SUCURSALES
 ---------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------


--SP PARA IMPORTACION DE EMPLEADOS
---------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------


--IMPORTACION VENTAS	
---------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE import3.Importacion_Venta 
	@ruta nvarchar(max)
AS
BEGIN

	CREATE TABLE grupo3.#Venta_Temp(Numero_Fac char(11),
									Tipo_Factura char(1),
									Ciudad varchar(30),
									Tipo_Cliente varchar(20),
									Genero varchar(10),
									Producto varchar(100),
									Precio_Unitario decimal(10,2),
									Cantidad int,
									Fecha date,
									Hora time,
									Metodo_Pago varchar(20),
									Empleado int,
									identificador_de_pago varchar(80),
									constraint chk_Tipo CHECK(Tipo_Cliente IN ('Normal','Member')));

	DECLARE @sql nvarchar(max)
		SET @sql = '
		BULK INSERT grupo3.#Venta_Temp
		FROM ''' +@ruta+ '''
		WITH
		(
		FORMAT = ''CSV'',
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''0x0A'',
		FIRSTROW = 2,
		CODEPAGE = ''65001''
		)';

	EXEC sp_executesql @sql;

	INSERT INTO grupo3.Factura(Numero_Fac,Tipo_Factura,Fecha,Hora,Metodo_Pago,Identificador_de_pago)
	SELECT v.Numero_Fac, v.Tipo_Factura, v.Fecha, v.Hora, v.Metodo_Pago, v.identificador_de_pago
	FROM  grupo3.#Venta_Temp v
	where (v.Numero_Fac NOT IN (SELECT Numero_Fac FROM grupo3.Factura) AND v.Producto IN (SELECT Nombre FROM grupo3.Producto))

	INSERT INTO grupo3.Venta(Tipo_Cliente,Genero,id_Sucursal,id_Empleado,id_Factura,Fecha)
	SELECT v.Tipo_Cliente, v.Genero, s.id_sucursal, e.id_Empleado, f.id_Factura, v.Fecha
	FROM grupo3.#Venta_Temp v
	INNER JOIN grupo3.Factura f ON v.Numero_Fac = f.Numero_Fac
	INNER JOIN grupo3.Sucursal s ON v.Ciudad = s.Ciudad
	INNER JOIN grupo3.Empleado e ON v.Empleado = e.id_Empleado
	where f.id_Factura NOT IN (SELECT id_Factura FROM grupo3.Venta)

	INSERT INTO  grupo3.Detalle_Venta(Cantidad, id_Producto,Precio_Unitario, id_Venta)
	SELECT v.Cantidad, p.id_Producto, p.Precio_Unitario, vt.id_Venta
	FROM grupo3.#Venta_Temp v
	LEFT JOIN grupo3.Producto p ON v.Producto = p.Nombre
	INNER JOIN grupo3.Factura f ON v.Numero_Fac = f.Numero_Fac
	INNER JOIN grupo3.Venta vt ON vt.id_Factura = f.id_Factura
	WHERE (p.id_Producto NOT IN (SELECT id_Producto FROM grupo3.Detalle_Venta dv where dv.id_Venta = vt.id_Venta))


	DROP TABLE IF EXISTS grupo3.#Venta_Temp
END
GO

---------------------------------------------------------------------------------------------


---IMPORTACION DE PRODUCTOS ELECTRONICOS
---------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE import3.Importacion_Productos_Electronicos
	@ruta nvarchar(max)
AS
BEGIN
	CREATE TABLE grupo3.#Productos_Electronicos(Categoria varchar(40) default 'Electrodomesticos',
												Linea_De_Producto varchar(25) default 'Electronic_accessories',
												Nombre varchar(100),
												Precio_Unitario decimal(10,2),
												Unidad_De_Referencia varchar(6) default 'ud',
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
								Unidad_De_Referencia,FechaAlta)
	SELECT p.Categoria, p.Linea_De_Producto, p.Nombre, p.Precio_Unitario, p.Precio_Unitario,
			p.Unidad_De_Referencia, p.FechaAlta 
	from grupo3.#Productos_Electronicos p

	DROP TABLE IF EXISTS grupo3.#Productos_Electronicos

END
GO
---------------------------------------------------------------------------------------------


--IMPORTACION DE PRODUCTOS IMPORTADOS
---------------------------------------------------------------------------------------------
GO 
CREATE OR ALTER PROCEDURE import3.Poductos_Importados
	@ruta nvarchar(max)
AS
BEGIN
CREATE TABLE grupo3.#Productos_Importados( id_producto int,
											Categoria varchar(40),
											Linea_De_Producto varchar(25) default 'Importados',
											Nombre varchar(100),
											Precio_Unitario decimal(10,2),
											Unidad_De_Referencia varchar(25),
											FechaAlta date default CONVERT(DATE,getdate()),
											FechaBaja date)
	DECLARE @sql nvarchar(max)

	SET @sql = '
    INSERT INTO grupo3.#Productos_Importados (id_producto,Nombre,Categoria,Unidad_De_Referencia,Precio_Unitario)
    SELECT [idProducto] as id_producto, [NombreProducto] as Nombre, [Categoría] as Categoria,
			[CantidadPorUnidad] as Unidad_De_Referencia, [PrecioUnidad] as Precio_Unitario
     FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @ruta + ''',
        ''SELECT * FROM [Listado de Productos$]'')
		WHERE [NombreProducto] NOT IN (SELECT Nombre FROM grupo3.Producto)';

EXEC sp_executesql @sql;
	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,
								Unidad_De_Referencia,FechaAlta)
	SELECT p.Categoria, p.Linea_De_Producto, p.Nombre, p.Precio_Unitario, p.Precio_Unitario,
			p.Unidad_De_Referencia, p.FechaAlta 
	from grupo3.#Productos_Importados p

	DROP TABLE IF EXISTS grupo3.#Productos_Importados
END
GO
---------------------------------------------------------------------------------------------
