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
BEGIN
	SET @MSJ = @MSJ + 'CIUDAD YA EXISTENTE '
END

	--Validar Sucursal
	IF(@MSJ = '' AND @Sucursal IN (SELECT Sucursal FROM grupo3.Sucursal))
BEGIN
	SET @MSJ = @MSJ + 'SUCURSAL YA EXISTENTE '
END
	---VALIDAR TAM DATOS
	IF(@MSJ = '' AND LEN(@Ciudad) > 20)
	SET @MSJ = @MSJ + 'TAM DE CIUDAD EXCEDE EL MAXIMO '

	IF(@MSJ = '' AND LEN(@Sucursal) > 20)
	SET @MSJ = @MSJ + 'TAM DE SUCURSAL EXCEDE EL MAXIMO '

	IF(@MSJ = '' AND LEN(@Direccion) > 100)
	SET @MSJ = @MSJ + 'TAM DE DIRECCION EXCEDE EL MAXIMO '

	IF(@MSJ = '' AND LEN(@Horario)>60)
	SET @MSJ = @MSJ + 'TAM DE HORARIO EXCEDE EL MAXIMO '

	IF(@MSJ = '' AND LEN(@Telefono)>9)
	SET @MSJ = @MSJ + 'TAM DE TELEFONO EXCEDE EL MAXIMO '

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Sucursal(Ciudad,Sucursal,Direccion,Horario,Telefono)
	VALUES(@Ciudad,@Sucursal,@Direccion,@Horario,@Telefono)
END
	ELSE
	PRINT @MSJ

END
GO

--MODIFICAR SUCURSAL
GO
CREATE OR ALTER PROCEDURE update3.ModificarSucursal
    @id_sucursal INT,
	@Ciudad VARCHAR(20),
	@Sucursal VARCHAR(20),
    @Direccion VARCHAR(100),
	@Horario varchar(60),
	@Telofono char(9)
	
AS
BEGIN
	DECLARE @MSJ varchar(50) = '';

	--Valdiar Ciudad
	IF(@Ciudad IN (SELECT Ciudad FROM grupo3.Sucursal))
BEGIN
	SET @MSJ = @MSJ + 'CIUDAD YA EXISTENTE '
END

	--Validar Sucursal
	IF(@MSJ = '' AND @Sucursal IN (SELECT Sucursal FROM grupo3.Sucursal))
BEGIN
	SET @MSJ = @MSJ + 'SUCURSAL YA EXISTENTE '
END
	IF(@MSJ = '')
BEGIN
    UPDATE grupo3.Sucursal
    SET Ciudad = @Ciudad,
		Sucursal = @Sucursal,
		Direccion = @Direccion,
		Horario = @Horario,
		Telefono = @Telofono
    WHERE id_sucursal = @id_sucursal;
END
ELSE
	PRINT @MSJ
END;
GO

-- sp para borrado logico 
GO
CREATE OR ALTER PROCEDURE delete3.BorrarSucursal
    @id_sucursal INT
AS
BEGIN
	IF(@id_sucursal IN (SELECT id_Sucursal FROM grupo3.Sucursal))
BEGIN
    UPDATE grupo3.Sucursal
    SET Fechabaja = CONVERT (date, GETDATE())
    WHERE id_sucursal = @id_sucursal;
END
ELSE
	PRINT 'LA SUCURSAL QUE SE DESEA ELIMINAR NO EXISTE'
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
	IF(@MSJ = '' AND @Turno NOT IN ('TM','TT','Jornada Completa'))
	SET @MSJ = @MSJ + 'TURNO INVALIDO'

	--Valida Tam
	IF(@MSJ = '' AND LEN(@Nombre) > 40)
	SET @MSJ = @MSJ + 'TAM DEL NOMBRE EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Apellido) > 40)
	SET @MSJ = @MSJ + 'TAM DE APELLIDO EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Direccion) > 100)
	SET @MSJ = @MSJ + 'TAM DE DIRECCION EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@email_Personal)>60)
	SET @MSJ = @MSJ + 'TAM DE EMAIL PERSONAL EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@email_Empresa)>60)
	SET @MSJ = @MSJ + 'TAM DE EMAIL DE LA EMPRESA EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@CUIL) > 11)
	SET @MSJ = @MSJ + 'TAM DEL CUIL EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Cargo) > 30)
	SET @MSJ = @MSJ + 'TAM DEL CARGO EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Turno) > 20)
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

----------------------BORRAR EMPLEADO
GO
CREATE OR ALTER PROCEDURE delete3.BorrarEmpleado
    @id_empleado INT
AS
BEGIN
	IF(@id_empleado IN (SELECT id_Empleado FROM grupo3.Empleado))
BEGIN
    UPDATE grupo3.Empleado
    SET Fechabaja = CONVERT (date, GETDATE())
    WHERE id_Empleado = @id_empleado;
END
ELSE
	PRINT 'EL EMPLEADO QUE SE DESEA ELIMINAR NO EXISTE'
END;
GO

----------------------INSERRTAR PRODUCTO
CREATE OR ALTER PROCEDURE insert3.InsertarProducto
	@Categoria varchar(50),
	@Linea_De_Producto varchar(30),
	@Nombre varchar(110),
	@Precio_Unitario decimal(10,2),
	@Precio_De_Referencia decimal(10,2),
	@Unidad_De_Referencia varchar(30)
AS
BEGIN
DECLARE @MSJ varchar(50) = '';

	---Validar precio positivo
	IF(@Precio_Unitario <= 0)
	SET @MSJ = @MSJ + 'EL PRECIO UNITARIO DEBE SER POSITIVO'

	IF(@MSJ = '' AND @Precio_De_Referencia <= 0)
	SET @MSJ = @MSJ + 'EL PRECIO DE REFERENCIA DEBE SER POSTIVO'

	--Valdiar Tam
	IF(@MSJ = '' AND LEN(@Categoria) > 40)
	SET @MSJ = @MSJ + 'TAM DEL CATEGORIA EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Linea_De_Producto) > 25)
	SET @MSJ = @MSJ + 'TAM DE LINEA DE PRODUCTO EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Nombre) > 100)
	SET @MSJ = @MSJ + 'TAM DE NOMBRE EXCEDE EL MAXIMO'

	IF(@MSJ = '' AND LEN(@Unidad_De_Referencia) > 25)
	SET @MSJ = @MSJ + 'TAM DE UNIDAD DE REFERENCIA EXCEDE EL MAXIMO'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Producto(Categoria,Linea_De_Producto,Nombre,Precio_Unitario,
								Precio_De_Referencia,Unidad_De_Referencia,FechaAlta)
	VALUES(@Categoria,@Linea_De_Producto,@Nombre,@Precio_Unitario,
								@Precio_De_Referencia,@Unidad_De_Referencia,CONVERT (date, GETDATE()))
END
	ELSE
	PRINT @MSJ

END
----------------------MODIFICAR PRODUCTO
GO
CREATE OR ALTER PROCEDURE update3.ModificarProducto
    @id_producto INT, 
	@categoria varchar (40),
	@linea_prod varchar(25),
	@nombre varchar(100),
	@precio_unitario decimal (10,2), 
	@precio_referencia decimal(10,2),
	@Unidad_De_Referencia varchar(25)
AS
BEGIN
DECLARE @MSJ varchar(50) = '';

	---Validar precio positivo
	IF(@Precio_Unitario <= 0)
	SET @MSJ = @MSJ + 'EL PRECIO UNITARIO DEBE SER POSITIVO'

	IF(@MSJ = '' AND @precio_referencia <= 0)
	SET @MSJ = @MSJ + 'EL PRECIO DE REFERENCIA DEBE SER POSTIVO'

	IF(@MSJ = '')
BEGIN
    UPDATE grupo3.Producto
    SET Linea_De_Producto= @linea_prod , 
		Nombre=@nombre ,
		Categoria=@categoria,
		Precio_Unitario=@precio_unitario , 
		Precio_De_Referencia=@precio_referencia ,
		Unidad_De_Referencia = @Unidad_De_Referencia,
		FechaAlta= CONVERT (date, GETDATE())
    WHERE id_Producto = @id_producto ;
END
ELSE
	PRINT @MSJ
END;
GO
----------------------BORRAR PRODUCTO
GO
CREATE OR ALTER PROCEDURE delete3.BorrarProducto
    @id_producto INT
AS
BEGIN
 	IF(@id_producto IN (SELECT id_Producto FROM grupo3.Producto))
BEGIN
    UPDATE grupo3.Producto
    SET Fechabaja = CONVERT (date, GETDATE())
    WHERE id_Producto = @id_producto;
END
ELSE
	PRINT 'EL PRODUCTO QUE SE DESEA ELIMINAR NO EXISTE'
END;
GO

----------------------INSERTAR VENTA
GO
CREATE OR ALTER PROCEDURE insert3.InsertarVenta
	@Tipo_Cliente varchar(10),
	@Genero varchar(10),
	@id_Empleado int,
	@Numero_Fac char(11)

AS
BEGIN
DECLARE @MSJ varchar(50) = ''
		---VALIDACION GENERO
	IF(@Genero NOT IN ('Male','Female'))
	SET @MSJ = @MSJ + 'EL GENERO INGRESADO NO ES VALIDO'

	---VALIDACION TIPO CLIENTE
	IF(@MSJ = '' AND @Tipo_Cliente NOT IN ('Normal','Member'))
	SET @MSJ = @MSJ + 'EL TIPO DE CLIENTE INGRESADO NO ES VALIDO'

	---VALIDACION DE EMPLEADO 
	IF(@MSJ = '' AND @id_empleado NOT IN (SELECT id_Empleado FROM grupo3.Empleado))
	SET @MSJ = @MSJ + 'ID DE EMPLEADO INEXISTENTE'

	---VALIDACION DE FACTURA
	IF(@MSJ = '' AND @Numero_Fac not IN (SELECT Numero_Fac FROM grupo3.Factura))
	SET @MSJ = @MSJ + 'NO EXISTE TAL FACTURA'

	IF(@MSJ ='')
BEGIN
	INSERT INTO grupo3.Venta(Tipo_Cliente,Genero,id_Sucursal,id_Empleado,id_Factura,Fecha)
	VALUES(@Tipo_Cliente,
			@Genero,
			(SELECT id_Sucursal FROM grupo3.Empleado WHERE id_Empleado = @id_Empleado),
			@id_Empleado,
			(SELECT id_Factura FROM grupo3.Factura WHERE Numero_Fac = @Numero_Fac),
			CONVERT(DATE, GETDATE()))
END
ELSE
	PRINT @MSJ		
END
GO

----------------------MODIFICAR VENTA	
CREATE OR ALTER PROCEDURE update3.ModificarVenta
    @id_venta INT,
	@Tipo_Cliente varchar(20),
	@Genero varchar(20),
	@id_empleado int

AS
BEGIN
DECLARE @MSJ varchar(50) = ''

	---VALIDACION GENERO
	IF(@Genero NOT IN ('Male','Female'))
	SET @MSJ = @MSJ + 'EL GENERO INGRESADO NO ES VALIDO'

	---VALIDACION TIPO CLIENTE
	IF(@MSJ = '' AND @Tipo_Cliente NOT IN ('Normal','Member'))
	SET @MSJ = @MSJ + 'EL TIPO DE CLIENTE INGRESADO NO ES VALIDO'

	---VALIDACION DE EMPLEADO 
	IF(@MSJ = '' AND @id_empleado NOT IN (SELECT id_Empleado FROM grupo3.Empleado))
	SET @MSJ = @MSJ + 'ID DE EMPLEADO INEXISTENTE'

	IF(@MSJ = '')
BEGIN
    UPDATE grupo3.Venta
    SET Tipo_Cliente = @Tipo_Cliente,
		Genero = @Genero,
		id_Sucursal = (SELECT id_Sucursal FROM grupo3.Empleado WHERE id_Empleado = @id_Empleado),
		Fecha = CONVERT (date, GETDATE()),
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
 	IF(@id_venta IN (SELECT id_Venta FROM grupo3.Venta))
BEGIN

    UPDATE grupo3.Venta
    SET Fechabaja = CONVERT (date, GETDATE())
    WHERE id_Venta = @id_venta;
END
ELSE
	PRINT 'LA VENTA QUE SE DESEA ELIMINAR NO EXISTE'
END;
GO

--------------------INSERTAR FACTURA (tambien genera la venta asociada a la misma)
GO
CREATE OR ALTER PROCEDURE insert3.InsertarFactura
    @Numero_Factura Char(11),
	@tipo_factura char(2),
	@metodo_pago varchar (15),
	@Identificador_de_pago varchar(30)
AS
BEGIN
DECLARE @MSJ varchar(50) = ''
	
	---VALIDAR NUMERO FACTURA
	IF(@Numero_Factura IN (SELECT Numero_Fac FROM grupo3.Factura))
	SET @MSJ = @MSJ + 'EL NUMERO DE FACTURA INGRESADO YA EXISTE'

	---VALIDAR TIPO DE FACTURA
	IF(@MSJ = '' AND @tipo_factura NOT IN ('A','B','C','D','E','NC','ND'))
	SET @MSJ = @MSJ + 'EL TIPO DE FACTURA INGRESADO NO ES VALIDO'

	---VALIDAR METODO DE PAGO
	IF(@MSJ = '' AND @metodo_pago NOT IN ('Cash','Credit card', 'Ewallet'))
	SET @MSJ = @MSJ + 'EL METODO DE PAGO INGRESADO NO ES VALIDO'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Factura(Numero_Fac,Tipo_Factura,Metodo_Pago,Identificador_de_pago,Fecha,Hora)
	VALUES(@Numero_Factura,@tipo_factura,@metodo_pago,@Identificador_de_pago,CONVERT(DATE, GETDATE()), CONVERT(TIME, GETDATE()))
END
ELSE
	PRINT @MSJ

END

GO

----------------------MODIFICAR FACTURA	
CREATE OR ALTER PROCEDURE update3.ModificarFactura
    @id_factura INT,
    @tipo_factura char(2),
	@metodo_pago varchar (15),
	@Identificador_de_pago varchar(30)
AS
BEGIN
	IF(@metodo_pago IN ('Cash','Credit card', 'Ewallet'))
BEGIN
	IF(@tipo_factura IN ('A','B','C','D','E','NC','ND'))
BEGIN
    UPDATE grupo3.Factura
    SET Tipo_Factura = @tipo_factura , 
		Fecha =CONVERT (date, GETDATE()),
		Hora=CONVERT (time, GETDATE()),
		Metodo_Pago = @metodo_pago,
		Identificador_de_pago = @Identificador_de_pago
    WHERE id_Factura = @id_factura ;
END
ELSE
	PRINT 'TIPO DE FACTURA INVALIDO'
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
---CREO LA NOTA DE CREDITO PARA LA FACTURA EN CUESTION
	INSERT INTO grupo3.Factura (Tipo_Factura, Numero_Fac, Fecha, Hora)
	VALUES('NC',@Numero_Fac,CAST(GETDATE() AS DATE),CAST(GETDATE() AS TIME))

---CAMBIO PARA QUE LA VENTA AHORA ESTE RELACIONADA CON ESA NC
	UPDATE grupo3.Venta
	SET id_Factura = (SELECT id_factura FROM grupo3.Factura where Numero_Fac = @Numero_Fac)
	WHERE id_Factura = @id_factura
END
ELSE
	PRINT 'EL NUMERO DE FACTURA QUE DESEA INGRESAR  YA EXISTE EN EL SISTEMA'
END
ELSE
	PRINT 'LA FACTURA A LA QUE DESEA APLCIAR LA NC NO EXISTE EN EL SISTEMA'
END;
GO



----------------------------------------------------------------------------------------
---INSERTAR DETALLE DE VENTA
GO
CREATE OR ALTER PROCEDURE insert3.Insertar_Detalle
	@Cantidad int,
	@Nombre_Producto varchar(110),
	@id_Venta int 
AS
BEGIN 
DECLARE @MSJ varchar(50) = ''
DECLARE @id_Producto int
DECLARE @Precio_Unitario decimal(10,2)
---VALIDAR EXISTENCIA DE LA VENTA
	IF(@id_Venta NOT IN (SELECT id_Venta FROM grupo3.Venta))
	SET @MSJ = @MSJ + 'ID DE VENTA INEXISTENTE'

---VALIDAR EXISTENCIA DEL PRODUCTO
	IF(@MSJ = '' AND @Nombre_Producto NOT IN (SELECT Nombre FROM grupo3.Producto))
	SET @MSJ = @MSJ + 'EL PRODUCTO INGRESADO ES INEXISTENTE'
	ELSE
BEGIN
	SET @id_Producto = (SELECT id_Producto FROM grupo3.Producto WHERE Nombre = @Nombre_Producto)
	SET @Precio_Unitario = (SELECT Precio_Unitario FROM grupo3.Producto WHERE Nombre = @Nombre_Producto)
END

---VALIDAR QUE LA CANTIDAD SEA POSITIVA
	IF(@MSJ = '' AND @Cantidad <= 0 OR @Cantidad = NULL)
	SET @MSJ = @MSJ + 'LA CANTIDAD INGRESADA NO ES VALIDA'

	IF(@MSJ = '')
BEGIN
	INSERT INTO grupo3.Detalle_Venta(Cantidad,id_Producto,id_Venta,Precio_Unitario)
	VALUES(@Cantidad,@id_Producto,@id_Venta,@Precio_Unitario)

END
ELSE
PRINT @MSJ

END
GO

---MODIFICAR DETALLE DE VENTA
GO
CREATE OR ALTER PROCEDURE update3.Modificar_Detalle
	@id_Detalle int,
	@Cantidad int,
	@Nombre_Producto varchar(110),
	@id_Venta int 
AS
BEGIN
	IF(@id_Venta IN (SELECT id_Venta FROM grupo3.Venta))
BEGIN 
	IF(@Nombre_Producto IN (SELECT Nombre FROM grupo3.Producto))
BEGIN
	IF(@Cantidad > 0)
BEGIN
	UPDATE grupo3.Detalle_Venta
	SET Cantidad = @Cantidad,
		id_Producto = (SELECT id_Producto FROM grupo3.Producto WHERE Nombre = @Nombre_Producto),
		Precio_Unitario = (SELECT Precio_Unitario FROM grupo3.Producto WHERE Nombre = @Nombre_Producto),
		id_Venta = @id_Venta
	WHERE id_Detalle = @id_Detalle
		
END
ELSE
PRINT 'CANTIDAD INGRESADA INVALIDA'

END
ELSE
PRINT 'EL PRODUCTO INGRESADO ES INEXISTENTE'

END
ELSE
PRINT 'ID DE VENTA INEXISTENTE'

END
GO

---BORARR DETALLE DE VENTA
GO
CREATE OR ALTER PROCEDURE delete3.Borrar_Detalle
	@id_Detalle int
AS
BEGIN 
	 IF(@id_Detalle IN (SELECT id_Detalle FROM grupo3.Detalle_Venta))
BEGIN

    UPDATE grupo3.Detalle_Venta
    SET Fechabaja = CONVERT (date, GETDATE())
    WHERE id_Detalle = @id_Detalle;
END
ELSE
	PRINT 'EL DETALLE DE VENTA QUE DESEA ELIMINAR NO EXISTE'

END
GO


----INSERCION FACTURA Y VENTA	
GO 
CREATE OR ALTER PROCEDURE insert3.FacturayVenta
	@Numero_Factura Char(11),
	@tipo_factura char(2),
	@metodo_pago varchar (15),
	@Identificador_de_pago varchar(30),
	@Tipo_Cliente varchar(10),
	@Genero varchar(10),
	@id_Empleado int,
	@Cantidad int,
	@Nombre_Producto varchar(110),
	@id_Venta int
AS
BEGIN 

EXEC insert3.InsertarFactura @Numero_Factura, @tipo_factura,@metodo_pago,@Identificador_de_pago 

EXEC insert3.InsertarVenta @Tipo_Cliente, @Genero, @id_Empleado, @Numero_Factura

EXEC insert3.Insertar_Detalle @Cantidad, @Nombre_Producto, @id_Venta

END

go
----INSERTAR NOTA DE CREDITO
CREATE OR ALTER PROCEDURE insert3.GenerarNotaDeCredito (@id_Factura int)
as
begin
	DECLARE @Rol varchar (50);
	DECLARE @EstadoFactura varchar(50);
	--Obtengo rol--
	--SELECT @Rol = IS_MEMBER('SupervisorUser') = 1
		
	--verifico que sea supervisor--
	IF (IS_ROLEMEMBER('Supervisor') = 1)
	begin
		RAISERROR ('Solo los supervisores pueden generar notas de credito',16,1);
		RETURN;
	end
	--OBtengo estado factura--
	SELECT @EstadoFactura = Estado FROM grupo3.Factura WHERE id_Factura = @id_Factura
	--Verifico que este paga--
	IF @EstadoFactura <> 'Pagada'
	begin
		RAISERROR ('La factura debe estar pagada para generar notas de credito',16,1);
		RETURN;
	end
	--Inserto nota de credito--
	INSERT INTO grupo3.Notadecredito (id_Factura, Total)
	SELECT id_Factura, Total
	FROM grupo3.Factura
	WHERE id_Factura = @id_Factura	
end
go
