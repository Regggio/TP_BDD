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
CREATE DATABASE TP_Supermercado_GRPO3
GO
--- Pasamos a usar la base de datos creada
GO
use TP_Supermercado_GRPO3
GO

--Creacion del esquema

GO
CREATE SCHEMA grupo3
GO

---Creacion de tablas
GO
CREATE TABLE grupo3.Sucursal( id_sucursal int identity(1,1) not null primary key,
							   Ubicacion varchar(20) not null unique,
							  -- constraint pk_sucrusal primary key(id_sucursal,Ubicacion), -- Ubicacion y Id deben ser Pk para evitar repetidos
							   constraint chk_Ubicacion CHECK( Ubicacion IN ('San Justo','Ramos Mejia','Lomas del Mirador')))
GO

GO
CREATE TABLE grupo3.Empleado(id_Empleado int identity(257020,1) primary key not null,
							 Nombre varchar(20) not null,
							 Apellido varchar(20) not null,
							 id_suc int not null references grupo3.Sucursal(id_sucursal))
GO
GO
CREATE TABLE grupo3.Cliente(id_cliente int identity(1,1) primary key not null,
							Alias varchar(20), 
							Ciudad varchar(20),
							Genero char(6),
							Tipo_Cliente char(6),
							constraint chk_Genero CHECK(Genero IN('Male','Female')),
							constraint chk_Tipo CHECK(Tipo_Cliente IN ('Normal','Member')))
GO
GO
CREATE TABLE grupo3.Producto(id_Producto int identity(1,1) primary key not null,
							 Descripcion varchar(20),
							 Linea_Producto varchar(30),
							 Precio_Unitario decimal(2,2))
GO

GO
CREATE TABLE grupo3.Venta(id_Venta int identity(1,1) primary key not null,
						  Total decimal(6,2),
						  Cantidad int,
						  id_Producto int references grupo3.Producto(id_Producto),
						---  id_Sucursal int references grupo3.Sucursal(id_Sucursal), ---PREGUNTAR SI YA CON EMPLEADO TENGO ESTE DATO O SI CAMBIA DE SUCRUSAL ME AFECTARIA
						  id_Empleado int references grupo3.Empleado(id_Empleado),
						  id_Cliente int references grupo3.Cliente(id_Cliente))
GO
GO
CREATE TABLE grupo3.Factura(id_Factura int identity (1,1) primary key not null,
							Tipo_Factura char(1),
							Fecha date,
							Hora time,
							id_venta int references grupo3.Venta(id_Venta),
							Metodo_Pago varchar(15),
							constraint chk_Metodo_Pago CHECK(Metodo_Pago IN ('Cash','Credit card', 'Ewallet')))
GO

---PREGUNTAR SI HACE FALTA UNA TABLA CATALOGO

---Creacion de Sp para insercion de datos en la tabla Sucursal
GO
CREATE PROCEDURE grupo3.Insercion_Sucursal 
as
begin
	Insert into grupo3.Sucursal (Ubicacion) VALUES('San Justo'),('Ramos Mejia'), ('Lomas del Mirador');
end
GO

--Insertamos los datos en la tabla Sucursal a travez de la SP
GO
exec grupo3.Insercion_Sucursal
GO

--Creacion de Sp para insercion de datos de Empleado
GO
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
GO

--Ejecutamos insercion de tabla empleados
GO
exec grupo3.Insercion_Empleado 5
GO

--Creamos SP para la insercion de Clientes
GO
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
GO

--Ejecuto la insercion de los clientes en el sistema
GO
exec grupo3.Insercion_Cliente 5
GO

------------

--Para actualizar la ubicacion de una sucursal
CREATE PROCEDURE grupo3.ModificarSucursal
    @id_sucursal INT,
    @Ubicacion VARCHAR(20)
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Ubicacion = @Ubicacion
    WHERE id_sucursal = @id_sucursal;
END;
--nose cuando es logico ejecutarlo 

-- para borrar una sucursal inactiva
--podemos agregar una columna que se llame estado: 1=activo/0=inactivo
ALTER TABLE grupo3.Sucursal
ADD activo BIT DEFAULT 1;

-- sp para borrado logico 
GO
CREATE PROCEDURE grupo3.BorrarSucursal
    @id_sucursal INT
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET activo = 0
    WHERE id_sucursal = @id_sucursal;
END;
GO