USE TP_Supermercado_GRPO3
------------

--Para ACTUALIZAR la ubicacion de una sucursal

CREATE OR ALTER PROCEDURE update3.ModificarSucursal
    @id_sucursal INT,
	@Ciudad VARCHAR(20),
    @Direccion VARCHAR(100),
	@Horario varchar(60),
	@Telofono char(9)
	
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Ciudad = @Ciudad,
		Direccion = @Direccion,
		Horario = @Horario,
		Telefono = @Telofono
    WHERE id_sucursal = @id_sucursal;
END;
--nose cuando es logico ejecutarlo 


-- para BORRAR una sucursal inactiva
--podemos agregar una columna que se llame estado: 1=activo/0=inactivo
--CREATE or ALTER TABLE grupo3.Sucursal
--ADD activo BIT DEFAULT 1;

-- sp para borrado logico 
GO
CREATE OR ALTER PROCEDURE delete3.BorrarSucursal
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
	@Nombre varchar(40),
	@Apellido varchar (40),
	@DNI int,
	@Direccion varchar (100),
	@email_Personal varchar(60),
	@email_Empresa varchar(60),
    @CUIL char(11),
	@Cargo varchar (30),
	@id_sucursal int,
	@Turno varchar(20)
AS
BEGIN
	if(@id_sucursal IN (SELECT id_sucursal FROM grupo3.Sucursal))
	BEGIN
    UPDATE grupo3.Empleado
    SET Nombre = @Nombre,
		Apellido = @Apellido,
		DNI = @DNI,
		Direccion = @Direccion,
		email_Personal = @email_Personal,
		email_Empresa = @email_Empresa,
		CUIL= @CUIL, 
		Cargo = @Cargo,
		id_Sucursal=@id_sucursal,
		Turno = @Turno
    WHERE id_Empleado = @id_empleado;
	END
	ELSE
	PRINT 'NUMERO DE SUCURSAL INEXISTENTE'
END;

EXEC update3.ModificarEmpleado 1, 'pedro', 'pepe', 200, 'san justo', 'ss', 'ss', '222', 'Sup', 5, 'TT'
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
	@Unidad_De_Refrencia varchar(6),
	@Fecha date
AS
BEGIN
    UPDATE grupo3.Producto
    SET Linea_De_Producto= @linea_prod , 
		Nombre=@nombre ,
		Categoria=@categoria,
		Precio_Unitario=@precio_unitario , 
		Precio_De_Referencia=@precio_referencia ,
		Unidad_De_Refrencia = @Unidad_De_Refrencia,
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
    UPDATE grupo3.Producto
    SET Fechabaja = getdate() 
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
	IF(@id_prod IN (SELECT id_Producto FROM grupo3.Producto))
	BEGIN
	IF(@id_empleado IN (SELECT id_Empleado FROM grupo3.Empleado))
	BEGIN
    UPDATE grupo3.Venta
    SET Total = @total , 
		Cantidad =@cant ,
		id_Producto=@id_prod , 
		id_Empleado =@id_empleado ,
		id_Cliente = @id_cliente
    WHERE id_Venta = @id_venta ;
	END
	ELSE
	PRINT 'NUMERO DE PRODUCTO INEXISTENTE'
	END
	ELSE
	PRINT 'NUMERO DE PRODUCTO INEXISTENTE'
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
