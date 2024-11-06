

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

CREATE OR ALTER PROCEDURE update3.ModificarSucursal
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
CREATE OR ALTER PROCEDURE update3.BorrarSucursal
    @id_sucursal INT
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Fechabaja = getdate()
    WHERE id_sucursal = @id_sucursal;
END;
GO

----------------------MODIFICAR EMPLEADO
CREATE OR ALTER PROCEDURE update3.ModificarEmpleado
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
CREATE OR ALTER PROCEDURE delete3.BorrarEmpleado
    @id_empleado INT
AS
BEGIN
    UPDATE grupo3.Empleado
    SET Fechabaja = getdate()
    WHERE id_Empleado = @id_empleado;
END;
GO

----------------------MODIFICAR CLIENTE
CREATE OR ALTER PROCEDURE update3.ModificarCliente
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
CREATE OR ALTER PROCEDURE delete3.BorrarCliente
    @id_cliente INT
AS
BEGIN
    UPDATE grupo3.Cliente
    SET Fechabaja = getdate()
    WHERE id_cliente = @id_cliente;
END;
GO
----------------------MODIFICAR PRODUCTO
CREATE OR ALTER PROCEDURE update3.ModificarProducto
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
CREATE OR ALTER PROCEDURE delete3.BorrarProducto
    @id_producto INT
AS
BEGIN
    DELETE FROM grupo3.Producto
    
    WHERE id_Producto = @id_producto ;
END;
GO

----------------------MODIFICAR VENTA	
CREATE OR ALTER PROCEDURE update3.ModificarVenta
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
CREATE OR ALTER PROCEDURE delete3.BorrarVenta
    @id_venta INT
AS
BEGIN
    UPDATE grupo3.Venta
    SET Fechabaja = getdate()
    WHERE id_Venta = @id_venta ;
END;
GO
----------------------MODIFICAR FACTURA	
CREATE OR ALTER PROCEDURE update3.ModificarFactura
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
CREATE OR ALTER PROCEDURE delete3.BorrarFactura
    @id_factura INT
AS
BEGIN
    UPDATE grupo3.Factura
    SET Fechabaja = getdate()
    WHERE id_Factura = @id_factura ;
END;
GO



----------------------------------------------------------------------------------------
