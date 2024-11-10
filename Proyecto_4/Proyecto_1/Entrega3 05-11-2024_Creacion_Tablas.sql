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
DROP DATABASE IF exists Com2900G03
CREATE DATABASE Com2900G03 COLLATE modern_spanish_ci_as
GO
--- Pasamos a usar la base de datos creada
GO
use Com2900G03
GO

--Creacion del esquema

GO
DROP SCHEMA IF exists grupo3
GO
CREATE SCHEMA grupo3
GO

--Creacion del esquema INSERT

GO
DROP SCHEMA IF exists insert3
GO
CREATE SCHEMA insert3
GO

--Creacion del esquema DELETE

GO
DROP SCHEMA IF exists delete3
GO
CREATE SCHEMA delete3
GO

--Creacion del esquema UPDATE

GO
DROP SCHEMA IF exists update3
GO
CREATE SCHEMA update3
GO

--Creacion del esquema IMPORT

GO
DROP SCHEMA IF exists import3
GO
CREATE SCHEMA import3
GO

---Creacion de tablas

GO
DROP TABLE IF exists grupo3.Sucursal
CREATE TABLE grupo3.Sucursal( id_sucursal int identity(1,1) primary key,
							   Ciudad varchar(20) UNIQUE,
							   Sucursal varchar(30) UNIQUE,
							   Direccion varchar(100) not null,
							   Horario varchar(60),
							   Telefono char(9),
							   FechaBaja date)
GO

GO
DROP TABLE IF exists grupo3.Empleado
CREATE TABLE grupo3.Empleado(id_Empleado int identity (257020,1) primary key,
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
							 FechaBaja date,
							 constraint chk_Turno CHECK(Turno IN('TM','TT','Jornada Completa')))
GO
---????
/*
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
*/
--CREACION TABLA PRODUCTO
GO
DROP TABLE IF exists grupo3.Producto
CREATE TABLE grupo3.Producto(id_Producto int identity(1,1)  primary key,
                             Categoria varchar(40),
                             Linea_De_Producto varchar(25),
                             Nombre varchar(100),
                             Precio_Unitario decimal(10,2),
                             Precio_De_Referencia decimal(10,2),
                             Unidad_De_Referencia varchar(25),
                             FechaAlta date,
							 FechaBaja date)
GO

--CREACION TABLA FACTURA
GO
DROP TABLE IF exists grupo3.Factura
CREATE TABLE grupo3.Factura(id_Factura int identity (1,1) primary key,
							Numero_Fac char(11) UNIQUE,
							Tipo_Factura char(2),
							Fecha date,
							Hora time,
							Metodo_Pago varchar(15),
							Identificador_de_pago varchar(30),
							constraint chk_Metodo_Pago CHECK(Metodo_Pago IN ('Cash','Credit card', 'Ewallet')))
GO

--CREACION TABLA VENTA
GO
DROP TABLE IF exists grupo3.Venta
CREATE TABLE grupo3.Venta(id_Venta int identity(1,1) primary key,
						  Tipo_Cliente varchar(10),
						  Genero varchar(10),
						  id_Sucursal int references grupo3.Sucursal(id_sucursal),
						  id_Empleado int references grupo3.Empleado(id_Empleado),
						  id_Factura int references grupo3.Factura(id_Factura) UNIQUE,
						  Fecha date,
						  Fechabaja date,
						  constraint chk_Genero CHECK(Genero IN('Male','Female')),
						  constraint chk_Tipo CHECK(Tipo_Cliente IN ('Normal','Member')))
GO

--CREACION TABLA DETALLE DE VENTA
GO
DROP TABLE IF exists grupo3.Detalle_Venta
CREATE TABLE grupo3.Detalle_Venta(id_Detalle int identity(1,1) primary key,
									Cantidad int not null,
									id_Producto int references grupo3.Producto(id_Producto),
									Precio_Unitario decimal(10,2),
									id_Venta int references grupo3.Venta(id_Venta))
GO