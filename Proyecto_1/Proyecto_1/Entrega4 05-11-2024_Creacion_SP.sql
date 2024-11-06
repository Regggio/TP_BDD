---ENTREGA 4
---CREACION DE SP PARA LA IMPORTACION DE ARCHIVOS
---Habilitacion de la configuracion del	servidor para consultas distribuidas (necesarias para utilizar el openrowset)
GO
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

--Importacion de Catalogo (Archivo CSV)
GO
CREATE OR ALTER PROCEDURE update3.Importacion_catalogo as
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

	INSERT INTO grupo3.#Linea_Productos SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0; Database=C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
	'SELECT * FROM [Clasificacion productos$]');

	INSERT INTO grupo3.Producto(id_Producto,Categoria,Linea_De_Producto,Nombre,Precio_Unitario,Precio_De_Referencia,Unidad_De_Refrencia,Fecha)
	SELECT pt.id_Producto, pt.Categoria, lp.Linea, pt.Nombre, pt.Precio_Unitario, pt.Precio_De_Referencia,
	pt.Unidad_De_Refrencia, pt.Fecha
	FROM grupo3.#Producto_Temp pt
	LEFT JOIN grupo3.#Linea_Productos lp ON lp.Producto = pt.Categoria
	where pt.nombre not in ( SELECT Nombre From grupo3.Producto)
end
GO

---CREARCION DE SP PARA INSERCION DE CUCURSALES DEL ARCHIVO INFORMACION COMPLEMENTARIA
/* Seguimos el ejemplo del https://learn.microsoft.com/es-es/sql/relational-databases/import-export/import-data-from-excel-to-sql?view=sql-server-ver16#openrowset-and-linked-servers 
 Si esta bien deberia hacerse la insercion igual para los otros tabs de la hoja de excel */
 --SP PARA INSERCION DE SUCURSALES
GO
CREATE OR ALTER PROCEDURE update3.Insercion_Suc as
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

--SP PARA INSERSCION DE EMPLEADOS
--EL JOIN NO FUNCIONA PORQUE ES UNA TEMPORAL CON UNA TABLA NOMRAL?
GO
CREATE OR ALTER PROCEDURE update3.Insercion_Emp as
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

	INSERT INTO grupo3.#Empleado_Temp SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0; Database=C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
	'SELECT * FROM [Empleados$]');
	INSERT INTO grupo3.Empleado(id_Empleado,Nombre,Apellido,DNI,Direccion,email_Personal,email_Empresa,CUIL,id_Sucursal,Turno)
	SELECT e.id_Empleado, e.Nombre, e.Apellido, e.DNI, e.Direccion ,e.email_Personal, e.email_Empresa, e.CUIL, s.id_sucursal, e.Turno
	FROM grupo3.Sucursal s
	INNER JOIN grupo3.#Empleado_Temp e ON s.Ciudad = e.Sucursal
end
go

--IMPORTACION VENTAS	
---HACE FALTA UN JOIN CON EMPLEADOS?
--- VENTA Y FACTURA SON DOS TABLAS SEPARADAS? EN LA IMPORTACION ESTA TODO JUNTO Y SE RELACIONAN, COMO PODRIA SEPARARLO
GO
CREATE OR ALTER PROCEDURE update3.Importacion_Venta as
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
