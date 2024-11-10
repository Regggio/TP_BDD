USE Com2900G03
------------
--INSERTAR SUCURSAL
GO
CREATE OR ALTER PROCEDURE insert3.InsertarSucursal
	@Ciudad varchar(30),
	@Sucursal varchar(50),
	@Direccion varchar(120),
	@Horario varchar(70),
	@Telefono char(15)
AS
BEGIN 
	DECLARE @MSJ varchar(50) = '';

	--Valdiar Ciudad
	IF(@Ciudad IN (SELECT Ciudad FROM grupo3.Sucursal))
	SET @MSJ = @MSJ + 'CIUDAD YA EXISTENTE'

	--Validar Sucursal
	IF(@Sucursal IN (SELECT Sucursal FROM grupo3.Sucursal))
	SET @MSJ = @MSJ + 'SUCURSAL YA EXISTENTE'

	---VALIDAR TAM DATOS
	IF(LEN(@Ciudad) > 20)
	SET @MSJ = @MSJ + 'TAM DE CIUDAD EXCEDE EL MAXIMO'

	IF(LEN(@Sucursal) > 20)
	SET @MSJ = @MSJ + 'TAM DE SUCURSAL EXCEDE EL MAXIMO'

	IF(LEN(@Direccion) > 100)
	SET @MSJ = @MSJ + 'TAM DE DIRECCION EXCEDE EL MAXIMO'

	IF(LEN(@Horario)>60)
	SET @MSJ = @MSJ + 'TAM DE HORARIO EXCEDE EL MAXIMO'

	IF(LEN(@Telefono)>9)
	SET @MSJ = @MSJ + 'TAM DE TELEFONO EXCEDE EL MAXIMO'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Sucursal(Ciudad,Direccion,Horario,Telefono)
	VALUES(@Ciudad,@Direccion,@Horario,@Telefono)
END
	ELSE
	PRINT @MSJ

END
GO

--MODIFICAR SUCURSAL

CREATE OR ALTER PROCEDURE update3.ModificarSucursal
    @id_sucursal INT,
	@Ciudad VARCHAR(20),
	@Sucursal VARCHAR(20),
    @Direccion VARCHAR(100),
	@Horario varchar(60),
	@Telofono char(9)
	
AS
BEGIN
    UPDATE grupo3.Sucursal
    SET Ciudad = @Ciudad,
		Sucursal = @Sucursal,
		Direccion = @Direccion,
		Horario = @Horario,
		Telefono = @Telofono
    WHERE id_sucursal = @id_sucursal;
END;


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

---------------------INSERTAR EMPLEADO
CREATE OR ALTER PROCEDURE insert3.InsertarEmpleado
	@Nombre varchar (50),
	@Apellido varchar (50),
	@DNI int,
	@Direccion varchar (120),
	@email_Personal varchar(80),
	@email_Empresa varchar(80),
	@CUIL char(14),
	@Cargo varchar (50),
	@id_Sucursal int,
	@Turno varchar(40)
AS
BEGIN
DECLARE @MSJ varchar(50) = '';

	--Valdiar Ciudad
	IF(@id_Sucursal NOT IN (SELECT id_sucursal FROM grupo3.Sucursal))
	SET @MSJ = @MSJ + 'SUCURSAL INEXISTENTE'

	--Valdiar Turno
	IF(@Turno NOT IN ('TM','TT','Jornada Completa'))
	SET @MSJ = @MSJ + 'TURNO INVALIDO'

	--Valida Tam
	IF(LEN(@Nombre) > 40)
	SET @MSJ = @MSJ + 'TAM DEL NOMBRE EXCEDE EL MAXIMO'

	IF(LEN(@Apellido) > 40)
	SET @MSJ = @MSJ + 'TAM DE APELLIDO EXCEDE EL MAXIMO'

	IF(LEN(@Direccion) > 100)
	SET @MSJ = @MSJ + 'TAM DE DIRECCION EXCEDE EL MAXIMO'

	IF(LEN(@email_Personal)>60)
	SET @MSJ = @MSJ + 'TAM DE EMAIL PERSONAL EXCEDE EL MAXIMO'

	IF(LEN(@email_Empresa)>60)
	SET @MSJ = @MSJ + 'TAM DE EMAIL DE LA EMPRESA EXCEDE EL MAXIMO'

	IF(LEN(@CUIL) > 11)
	SET @MSJ = @MSJ + 'TAM DEL CUIL EXCEDE EL MAXIMO'

	IF(LEN(@Cargo) > 30)
	SET @MSJ = @MSJ + 'TAM DEL CARGO EXCEDE EL MAXIMO'

	IF(LEN(@Turno) > 20)
	SET @MSJ = @MSJ + 'TAM DE TURNO EXCEDE EL MAXIMO'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Empleado(Nombre,Apellido,DNI,Direccion, email_Personal,email_Empresa,CUIL,Cargo,id_Sucursal,Turno)
	VALUES(@Nombre,@Apellido,@DNI,@Direccion, @email_Personal,@email_Empresa,@CUIL,@Cargo,@id_Sucursal,@Turno)
END
	ELSE
	PRINT @MSJ
END




----------------------MODIFICAR EMPLEADO
GO
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

----------------------INSERRTAR PRODUCTO
CREATE OR ALTER PROCEDURE insert3.InsertarProducto
	@Categoria varchar(50),
	@Linea_De_Producto varchar(30),
	@Nombre varchar(110),
	@Precio_Unitario decimal(11,2),
	@Precio_De_Referencia decimal(11,2),
	@Unidad_De_Referencia varchar(30),
	@FechaAlta date
AS
BEGIN
DECLARE @MSJ varchar(50) = '';

	--Valdiar Tam
	IF(LEN(@Categoria) > 50)
	SET @MSJ = @MSJ + 'TAM DEL CATEGORIA EXCEDE EL MAXIMO'

	IF(LEN(@Linea_De_Producto) > 30)
	SET @MSJ = @MSJ + 'TAM DE LINEA DE PRODUCTO EXCEDE EL MAXIMO'

	IF(LEN(@Nombre) > 100)
	SET @MSJ = @MSJ + 'TAM DE NOMBRE EXCEDE EL MAXIMO'

	IF(LEN(@Unidad_De_Referencia) > 25)
	SET @MSJ = @MSJ + 'TAM DE UNIDADE DE REFERENCIA EXCEDE EL MAXIMO'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,
								Precio_De_Referencia,Unidad_De_Referencia,FechaAlta)
	VALUES(@Categoria,@Linea_De_Producto,@Nombre,@Precio_Unitario,
								@Precio_De_Referencia,@Unidad_De_Referencia,@FechaAlta)
END
	ELSE
	PRINT @MSJ

END
----------------------MODIFICAR PRODUCTO
GO
CREATE OR ALTER PROCEDURE update3.ModificarProducto
    @id_producto INT,
    @linea_prod varchar(30), 
	@categoria varchar (40),
	@nombre varchar(20),
	@precio_unitario decimal (3,3), 
	@precio_referencia decimal(3,3),
	@Unidad_De_Referencia varchar(6),
	@Fecha date
AS
BEGIN
    UPDATE grupo3.Producto
    SET Linea_De_Producto= @linea_prod , 
		Nombre=@nombre ,
		Categoria=@categoria,
		Precio_Unitario=@precio_unitario , 
		Precio_De_Referencia=@precio_referencia ,
		Unidad_De_Referencia = @Unidad_De_Referencia,
		FechaAlta=@Fecha
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
	@Tipo_Cliente varchar(20),
	@Genero varchar(20),
	@id_Sucursal int,
	@id_Factura int,
	@Fecha date,
	@id_empleado int

AS
BEGIN
DECLARE @MSJ varchar(50) = ''

	---VALIDACION DE PRODUCTO 
	IF(@id_Sucursal NOT IN (SELECT id_Sucursal FROM grupo3.Sucursal))
	SET @MSJ = @MSJ + 'ID DE SUCURSAL INEXISTENTE'

	---VALIDACION DE EMPLEADO 
	IF(@id_empleado NOT IN (SELECT id_Empleado FROM grupo3.Empleado))
	SET @MSJ = @MSJ + 'ID DE SUCURSAL INEXISTENTE'

	---VALDIACION DE FACTURA
	IF(@id_Factura NOT IN (SELECT id_Factura FROM grupo3.Factura))
	SET @MSJ = @MSJ + 'ID DE SUCURSAL INEXISTENTE'

	IF(@MSJ = '')
BEGIN
    UPDATE grupo3.Venta
    SET Tipo_Cliente = @Tipo_Cliente,
		Genero = @Genero,
		id_Sucursal = @id_Sucursal,
		id_Factura = @id_Factura,
		Fecha = @Fecha,
		id_empleado = @id_empleado 
    WHERE id_Venta = @id_venta ;
	
END
ELSE
	PRINT @MSJ
END
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
	@Numero_Fac char(11),
    @tipo_factura char(2), 
	@fecha date,
	@hora time, 
	@id_venta int,
	@metodo_pago varchar (15),
	@Identificador_de_pago varchar(30)
AS
BEGIN
	IF(@metodo_pago IN ('Cash','Credit card', 'Ewallet'))
BEGIN
    UPDATE grupo3.Factura
    SET Tipo_Factura = @tipo_factura , 
		Numero_Fac = @Numero_Fac,
		Fecha =@fecha,
		Hora=@hora,
		Metodo_Pago = @metodo_pago,
		Identificador_de_pago = @Identificador_de_pago,
    WHERE id_Factura = @id_factura ;
END
ELSE
	PRINT 'METODO DE PAGO INVALIDO'
END;
GO
----------------------BORRAR FACTURA
GO
CREATE OR ALTER PROCEDURE delete3.BorrarFactura
    @id_factura INT,
	@Numero_Fac char(11)
AS
BEGIN
	IF(@id_factura IN (SELECT id_Factura FROM grupo3.Factura))
BEGIN
	IF(@Numero_Fac NOT IN (SELECT Numero_Fac FROM grupo3.Factura))
BEGIN
	INSERT INTO grupo3.Factura (Tipo_Factura, Numero_Fac, Fecha, Hora)
	VALUES('NC',@Numero_Fac,CAST(GETDATE() AS DATE),CAST(GETDATE() AS TIME))
END
ELSE
	PRINT 'EL NUMERO DE FACTURA QUE DESEA INGRESAR  YA EXISTE EN EL SISTEMA'
END
ELSE
	PRINT 'LA FACTURA A LA QUE DESEA APLCIAR LA NC NO EXISTE EN EL SISTEMA'
END;
GO



----------------------------------------------------------------------------------------
