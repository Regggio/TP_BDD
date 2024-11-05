/*Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/

/*
NRO GRUPO: 3
BASE DE DATOS APLICADAS
Julian Ezequiel Reggio Matina 44560058
Santino Bruno 44392059
Facu Goldring 44595085
Bianca Camila Zarlenga 43993165
*/

--- Creacion de la base de datos
GO
DROP DATABASE IF exists TP_Supermercado_GRPO3
CREATE DATABASE TP_Supermercado_GRPO3
GO
--- Pasamos a usar la base de datos creada
GO
use TP_Supermercado_GRPO3
GO

--Creacion del esquema

GO
DROP SCHEMA IF exists grupo3
GO
CREATE SCHEMA grupo3
GO

---Creacion de tablas

GO
DROP TABLE IF exists grupo3.Sucursal
CREATE TABLE grupo3.Sucursal( id_sucursal int identity(1,1) not null primary key,
							   Ciudad varchar(20) UNIQUE,	
							   Direccion varchar(100) not null,
							   Horario varchar(60),
							   Telefono char(9),
							   FechaBaja date)
GO

GO
DROP TABLE IF exists grupo3.Empleado
CREATE TABLE grupo3.Empleado(id_Empleado int primary key,
							 Nombre varchar (40),
							 Apellido varchar (40),
							 DNI int,
							 Direccion varchar (100),
							 email_Personal varchar(60),
							 email_Empresa varchar(60),
							 CUIL char(11),
							 Cargo varchar (30),
							 id_Sucursal int not null references grupo3.Sucursal(id_sucursal),
							 Turno varchar(20),
							 constraint chk_Turno CHECK(Turno IN('TM','TT','Jornada Completa')))
GO

GO
DROP TABLE IF exists grupo3.Cliente
CREATE TABLE grupo3.Cliente(id_cliente int identity(1,1) primary key not null,
							Alias varchar(20), 
							Ciudad varchar(20),
							Genero char(6),
							Fechabaja date,
							Tipo_Cliente char(6),
							constraint chk_Genero CHECK(Genero IN('Male','Female')),
							constraint chk_Tipo CHECK(Tipo_Cliente IN ('Normal','Member')))
GO
--LOS DATOS DE PRODUCTOS SALEN DEL ARCHIVO CSV DE CATAOLOGO, EXCLUIMOS FECHA?, PARA QUE SIRVE PRECIO DE REFERENCIA?

GO
DROP TABLE IF exists grupo3.Producto
CREATE TABLE grupo3.Producto(id_Producto int  primary key ,
                             Categoria varchar(40),
                             Linea_De_Producto varchar(20),
                             Nombre varchar(100),
                             Precio_Unitario decimal(10,2),
                             Precio_De_Referencia decimal(10,2),
                             Unidad_De_Refrencia varchar(6),
                             Fecha date)
GO

---PREGUNTAR SI EL FORMATO DE LA TABLA VENTA DEBE SER IGUAL AL DEL ARCHIVO CSV. PARA LA INSERCION DE LAS VENATAS O ESO ES LO QUE DEBERIA QUEDAR X PANTALLA?
GO
DROP TABLE IF exists grupo3.venta
CREATE TABLE grupo3.Venta(id_Venta int identity(1,1) primary key not null,
						  Total decimal(6,2),
						  Cantidad int,
						  id_Producto int references grupo3.Producto(id_Producto),
						---  id_Sucursal int references grupo3.Sucursal(id_Sucursal), ---PREGUNTAR SI YA CON EMPLEADO TENGO ESTE DATO O SI CAMBIA DE SUCRUSAL ME AFECTARIA
						  id_Empleado int references grupo3.Empleado(id_Empleado),
						  id_Cliente int references grupo3.Cliente(id_Cliente),
						  fecha date,
						  Fechabaja date)
GO

GO
DROP TABLE IF exists grupo3.factura
CREATE TABLE grupo3.Factura(id_Factura int identity (1,1) primary key not null,
							Tipo_Factura char(1),
							Fecha date,
							Hora time,
							Fechabaja date,
							id_venta int references grupo3.Venta(id_Venta),
							Metodo_Pago varchar(15),
							constraint chk_Metodo_Pago CHECK(Metodo_Pago IN ('Cash','Credit card', 'Ewallet')))
GO

---PREGUNTAR SI HACE FALTA UNA TABLA CATALOGO

---Creacion de Sp para insercion de datos en la tabla Sucursal
/*GO
CREATE PROCEDURE grupo3.Insercion_Sucursal 
as
begin
	Insert into grupo3.Sucursal (Ubicacion) VALUES('San Justo'),('Ramos Mejia'), ('Lomas del Mirador');
end
GO*/

--Insertamos los datos en la tabla Sucursal a travez de la SP
/*GO
exec grupo3.Insercion_Sucursal
GO*/

--Creacion de Sp para insercion de datos de Empleado
/*GO
CREATE or alter PROCEDURE grupo3.Insercion_Empleado(@cantInserciones int )
as
begin
	while @cantInserciones > 0
begin
	INSERT grupo3.Empleado(Nombre,Apellido,id_suc)
	select case cast (RAND()*(5-1)+1 as int)
	when 1 then 'Roberto'
	when 2 then 'Marcelo'
	when 3 then 'Sergio'
	when 4 then 'Mauro'
	else 'Miguel'
	end,
	case cast (RAND()*(5-1)+1 as int)
	when 1 then 'Fernandez'
	when 2 then 'Gomez'
	when 3 then 'Rodriguez'
	when 4 then 'Menendez'
	else 'Moran'
	end,
	(SELECT s.id_sucursal from grupo3.Sucursal s where id_sucursal = CAST(RAND()*(3-1)+1 as int))
	set @cantInserciones = @cantInserciones - 1	
end

end
GO*/

--Ejecutamos insercion de tabla empleados
/*GO
exec grupo3.Insercion_Empleado 5
GO*/

--Creamos SP para la insercion de Clientes
/*GO
CREATE or alter PROCEDURE grupo3.Insercion_Cliente(@cantidadInserciones int) as
begin
while @cantidadInserciones > 0
begin
	insert grupo3.Cliente(Alias,Ciudad,Genero,Tipo_Cliente)
	select case CAST(RAND()*(5-1)+1 as int) 
	when 1 then 'Analia'
	when 2 then 'Valeria'
	when 3 then 'Maria'
	when 4 then 'Duki'
	else 'Emilia'
	end,
	case CAST(RAND()*(3-1)+1 as int) 
	when 1 then 'Yangon'
	when 2 then 'Naypyitaw'
	else 'Mandalay'
	end,
	case  
	when RAND() < 0.5 then 'Male'
	else 'Female'
	end,
	case 
	when RAND() < 0.5  then 'Normal'
	else 'Member'
	end
set @cantidadInserciones = @cantidadInserciones - 1
end

end
GO*/

--Ejecuto la insercion de los clientes en el sistema
/*GO
exec grupo3.Insercion_Cliente 5
GO*/

------------

--Para ACTUALIZAR la ubicacion de una sucursal

CREATE OR ALTER PROCEDURE grupo3.ModificarSucursal
    @id_sucursal INT,
    @Ubicacion VARCHAR(20)
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Ciudad = @Ubicacion
    WHERE id_sucursal = @id_sucursal;
END;
--nose cuando es logico ejecutarlo 


-- para BORRAR una sucursal inactiva
--podemos agregar una columna que se llame estado: 1=activo/0=inactivo
--CREATE or ALTER TABLE grupo3.Sucursal
--ADD activo BIT DEFAULT 1;

-- sp para borrado logico 
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarSucursal
    @id_sucursal INT
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Fechabaja = getdate()
    WHERE id_sucursal = @id_sucursal;
END;
GO

----------------------MODIFICAR EMPLEADO
CREATE OR ALTER PROCEDURE grupo3.ModificarEmpleado
    @id_empleado INT,
    @CUIL char(11), 
	@sucursal varchar(20)
AS
BEGIN
    UPDATE grupo3.Empleado
    SET CUIL=@CUIL, 
		Sucurasal=@sucursal
    WHERE id_Empleado = @id_empleado;
END;
----------------------BORRAR EMPLEADO
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarEmpleado
    @id_empleado INT
AS
BEGIN
    UPDATE grupo3.Empleado
    SET Fechabaja = getdate()
    WHERE id_Empleado = @id_empleado;
END;
GO

----------------------MODIFICAR CLIENTE
CREATE OR ALTER PROCEDURE grupo3.ModificarCliente
    @id_cliente INT,
    @alias varchar(20), 
	@genero varchar(6),
	@ciudad varchar(20),
	@tipo_cliente char(6)
AS
BEGIN
    UPDATE grupo3.Cliente
    SET Alias=@alias, 
		Genero=@genero,
		Ciudad=@ciudad,
		Tipo_Cliente=@tipo_cliente
    WHERE id_cliente = @id_cliente;
END;
----------------------BORRAR CLIENTE
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarCliente
    @id_cliente INT
AS
BEGIN
    UPDATE grupo3.Cliente
    SET Fechabaja = getdate()
    WHERE id_cliente = @id_cliente;
END;
GO
----------------------MODIFICAR PRODUCTO
CREATE OR ALTER PROCEDURE grupo3.ModificarProducto
    @id_producto INT,
    @linea_prod varchar(30), 
	@categoria varchar (40),
	@nombre varchar(20),
	@precio_unitario decimal (3,3), 
	@precio_referencia decimal(3,3),
	@Fecha date
AS
BEGIN
    UPDATE grupo3.Producto
    SET Linea_De_Producto= @linea_prod , 
		Nombre=@nombre ,
		Categoria=@categoria,
		Precio_Unitario=@precio_unitario , 
		Precio_De_Referencia=@precio_referencia ,
		Fecha=@Fecha
    WHERE id_Producto = @id_producto ;
END;
GO
----------------------BORRAR PRODUCTO
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarProducto
    @id_producto INT
AS
BEGIN
    DELETE FROM grupo3.Producto
    
    WHERE id_Producto = @id_producto ;
END;
GO

----------------------MODIFICAR VENTA	
CREATE OR ALTER PROCEDURE grupo3.ModificarVenta
    @id_venta INT,
    @total decimal(6,2), 
	@cant int,
	@id_prod int, 
	@id_empleado int,
	@id_cliente int
AS
BEGIN
    UPDATE grupo3.Venta
    SET Total = @total , 
		Cantidad =@cant ,
		id_Producto=@id_prod , 
		id_Empleado =@id_empleado ,
		id_Cliente = @id_cliente
    WHERE id_Venta = @id_venta ;
END;
GO
----------------------BORRAR VENTA
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarVenta
    @id_venta INT
AS
BEGIN
    UPDATE grupo3.Venta
    SET Fechabaja = getdate()
    WHERE id_Venta = @id_venta ;
END;
GO
----------------------MODIFICAR FACTURA	
CREATE OR ALTER PROCEDURE grupo3.ModificarFactura
    @id_factura INT,
    @tipo_factura char(1), 
	@fecha date,
	@hora time, 
	@id_venta int,
	@metodo_pago varchar (15)
AS
BEGIN
    UPDATE grupo3.Factura
    SET Tipo_Factura = @tipo_factura , 
		Fecha =@fecha,
		Hora=@hora , 
		id_venta =@id_venta ,
		Metodo_Pago = @metodo_pago
    WHERE id_Factura = @id_factura ;
END;
GO
----------------------BORRAR FACTURA
GO
CREATE OR ALTER PROCEDURE grupo3.BorrarFactura
    @id_factura INT
AS
BEGIN
    UPDATE grupo3.Factura
    SET Fechabaja = getdate()
    WHERE id_Factura = @id_factura ;
END;
GO

---Creacion de reportes:
---Reprorte Trimestral no se como improtarlo a xml
---EL NTILE ERA PARA SEPARARLO POR TRIMESTRE
/*go
CREATE OR ALTER PROCEDURE grupo3.GeneracionReporteTrimestral as
begin 
	with totalTrimestre(total,turno,mes, trimestre) as(
	select sum(v.Total) over (partition by(month(v.fecha),e.Turno)) as total,e.Turno,month(v.fecha),ntile(4) OVER (partition BY (MONTH(v.fecha))) as Trimestre
	from grupo3.Venta as v
	inner join from grupo3.Empleado as e ON e.id_Empleado = v.id_Empleado
end
go*/

----------------------------------------------------------------------------------------
GO
CREATE or ALTER PROCEDURE grupo3.ReporteTrimestral (@trimestre int, @anio int)
as
begin
SELECT
	MONTH(v.fecha) as mes, 
	e.Turno, sum(v.total) --over (partition by month(v.fecha), e.turno order by month(v.fecha)) as TotalMensual
	FROM grupo3.Venta v 
	inner join grupo3.Empleado e on v.id_Empleado=e.id_Empleado
	WHERE 
        YEAR(v.fecha) = @anio 
        AND (
            (@trimestre = 1 AND MONTH(v.fecha) BETWEEN 1 AND 3) OR
            (@trimestre = 2 AND MONTH(v.fecha) BETWEEN 4 AND 6) OR
            (@trimestre = 3 AND MONTH(v.fecha) BETWEEN 7 AND 9) OR
            (@trimestre = 4 AND MONTH(v.fecha) BETWEEN 10 AND 12)
        )
	GROUP BY month(v.fecha), Turno
FOR XML PATH('ReporteTrimestral');
end
GO
EXECUTE grupo3.ReporteTrimestral 1, 2024

GO
CREATE or ALTER PROCEDURE grupo3.ReporteMensual (@mes int, @anio int)
as
begin
SELECT 
    DATENAME(WEEKDAY, fecha) AS DiaSemana,
    SUM(Total) AS TotalFacturado
FROM 
    grupo3.Venta v
WHERE 
    MONTH(fecha) = @mes AND YEAR(fecha) = @anio
GROUP BY 
    DATENAME(WEEKDAY, fecha)
FOR XML PATH('ReporteMensual');
end
GO
EXECUTE grupo3.ReporteMensual 3,2024

GO
CREATE or ALTER PROCEDURE grupo3.ReporteRango (@fechaI date, @fechaF date)
as
begin
SELECT
	p.id_Producto, p.Nombre,
	SUM(v.cantidad) OVER (PARTITION BY v.id_Producto) AS TotalVendidos
FROM
	grupo3.Producto p
	inner join grupo3.Venta v on p.id_Producto = v.id_Producto
WHERE
	v.fecha BETWEEN @fechaI AND @fechaF
ORDER BY
	TotalVendidos DESC
FOR XML PATH('ReporteRango');
end
GO
EXECUTE grupo3.ReporteRango '2024,01,01','2024,12,31'

GO
CREATE or ALTER PROCEDURE grupo3.ReporteRangoSucursal (@fechaI date, @fechaF date)
as
begin
SELECT
	s.Ciudad, p.id_Producto, p.Nombre,
	SUM(v.cantidad) OVER (PARTITION BY v.id_Producto,s.Ciudad) AS TotalVendidosSucursal
FROM
	grupo3.Producto p
	inner join grupo3.Venta v on p.id_Producto = v.id_Producto
	inner join grupo3.Empleado e on v.id_Empleado = e.id_Empleado
	inner join grupo3.Sucursal s on e.id_Sucursal = s.id_sucursal
WHERE
	v.fecha BETWEEN @fechaI AND @fechaF
ORDER BY
	TotalVendidosSucursal DESC
FOR XML PATH('ReporteRangoSucursal');
end
GO
EXECUTE grupo3.ReporteRangoSucursal '2024,01,01','2024,12,31'

GO
CREATE or ALTER PROCEDURE grupo3.ReporteSemanal (@mes int, @anio int)
as 
begin
	WITH VentasSemanales (id_Producto,Nombre,Semana,CantidadSemanal,Top5) AS (
		SELECT p.id_Producto, p.Nombre,
			NTILE (4) OVER (PARTITION BY DAY (v.fecha)) AS Semana,
			SUM(v.Cantidad) OVER (PARTITION BY v.id_Producto, Semana) AS CantidadSemanal,
			RANK () OVER (PARTITION BY Semana ORDER BY CantidadSemanal DESC) AS Top5
		FROM
			grupo3.Venta v
			inner join grupo3.Producto p on v.id_Producto = p.id_Producto
		WHERE 
			MONTH (v.fecha) = @mes AND YEAR (v.fecha) = @anio)
	SELECT *
	FROM VentasSemanales
	WHERE Top5 <= 5
FOR XML PATH('ReporteSemanal');
end
GO
EXECUTE grupo3.ReporteSemanal 01,2024