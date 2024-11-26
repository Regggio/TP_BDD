---EJECUCION SP DE INSERCION, ELIMINCACION Y MODIFICACION
USE Com2900G03

----- EJECUCION INSERTAR SUCURSAL (FUNCIONA CORRECTAMENTE)
EXEC administracion3.InsertarSucursal 'Machipichu','Lanus','Av. El libertador 500','L-V De 2:00 pm a 7:00 pm','2355-6671'
--- EJECUCION INSERTAR SUCURSAL (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.InsertarSucursal 'Macaa','Lanus','Av. El libertador 500','L-V De 2:00 pm a 7:00 pm','2355-6671'

----- EJECUCION MODIFCIAR SUCURSAL (FUNCIONA CORRECTAMENTE)
EXEC administracion3.ModificarSucursal 1, 'Toronto','Moreno','Castillo de la rosa 300','L-V De 2:00 pm a 7:00 pm','2245-6671'

----- EJECUCION MODIFCIAR SUCURSAL (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.ModificarSucursal 1, 'Toronto','Moreno','Castillo de la rosa 300','L-V De 2:00 pm a 7:00 pm','2245-6671'

----- EJECUCION ELIMINAR SUCURSAL (FUNCIONA CORRECTAMENTE)
EXEC administracion3.BorrarSucursal 1

----- EJECUCION ELIMINAR SUCURSAL (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.BorrarSucursal 7

--- EJECUCION INSERTAR EMPLEADO (FUNCIONA BIEN)
EXEC administracion3.InsertarEmpleado 'Pedro', 'Aguilar', '44790785','Medrano 444','Paguilar@gmail.com','Paguilar@superA.com','20-440785-9',
								'Supervisor','1','TT'

--- EJECUCION INSERTAR EMPLEADO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.InsertarEmpleado 'Pepe', 'Aguilar', '44790785','Medrano 444','Paguilar@gmail.com','Paguilar@superA.com','20-44790785-9',
								'Supervisor','1','TP'

--- EJECUCION MODIFICAR EMPLEADO (FUNCIONA BIEN)
EXEC administracion3.ModificarEmpleado  257020, 'Pedro', 'Aguilar', '44790785','Medrano 444','Paguilar@gmail.com','Paguilar@superA.com',
								'20-44790785-9','Supervisor','1','TT'

--- EJECUCION MODIFICAR EMPLEADO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.ModificarEmpleado  257020, 'Pedro', 'Aguilar', '44790785','Medrano 444','Paguilar@gmail.com','Paguilar@superA.com',
								'20-44790785-9','Supervisor','99','TT'

----- EJECUCION ELIMINAR EMPLEADO (FUNCIONA CORRECTAMENTE)
EXEC administracion3.BorrarEmpleado 1 

----- EJECUCION ELIMINAR EMPLEADO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.BorrarEmpleado 99

--- EJECUCUION INSERTAR PRODUCTO (FUNCIONA CORRECTAMENTE)
EXEC administracion3.InsertarProducto 'Almacen', 'Condimentos_Salsas','Pomelo', 15.2, 15.2, ud

--- EJECUCUION INSERTAR PRODUCTO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.InsertarProducto 'Almacen', 'Condimentos_Salsas_Picada','Chimichurri', 15.2, -15.2, ud

--- EJECUCUION MODIFICAR PRODUCTO (FUNCIONA CORRECTAMENTE)
EXEC administracion3.ModificarProducto  22, 'Frescos', 'Fruta_Verdura','Arandanos_El_Rosal', 22.2, 11.2, ud

--- EJECUCUION MODIFICAR PRODUCTO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.ModificarProducto 11, 'Frescos', 'Fruta_Verdura','Arandanos_El_Rosal', 22.2, -11.2, ud

----- EJECUCION ELIMINAR PRODUCTO (FUNCIONA CORRECTAMENTE)
EXEC delete3.BorrarProducto 16

----- EJECUCION ELIMINAR PRODUCTO (SALE X ALGUNA CONDICION DE CORTE)
EXEC administracion3.BorrarProducto -12

---EJECUCION INSERTAR FACTURA (FUNCIONA CORRECTAMENTE)
EXEC insert3.InsertarFactura '223-91-7520', 'C'

---EJECUCION INSERTAR FACTURA (SALE X ALGUNA CONDICION DE CORTE)
EXEC insert3.InsertarFactura '222-91-4520', 'P'

---EJECUCION MODIFICAR FACTURA (FUNCIONA CORRECTAMENTE)
EXEC update3.ModificarFactura 2, 'B', 'Cash','----'

---EJECUCION MODIFICAR FACTURA (SALE X ALGUNA CONDICION DE CORTE)
EXEC update3.ModificarFactura 2, 'BD', 'Cash','----'

---EJECUCION BORRAR FACTURA (FUNCIONA BIEN)
EXEC delete3.BorrarFactura 1, '555-20-9710'

---EJECUCION BORRAR FACTURA (SALE X ALGUNA CONDICION DE CORTE)
EXEC delete3.BorrarFactura 91, '555-20-9710'

---EJECUCION INSERTAR VENTA (FUCIONA CORRECTAMENTE)
EXEC ventas3.InsertarVenta 'Member', 'Male','213-91-7521' , 257020, '223-91-7520' 

---EJECUCION INSERTAR VENTA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.InsertarVenta 'Members', 'Male','213-91-7521' , 257020, '223-91-7521' 

---EJECUCION MODIFICAR VENTA (FUNCIONA CORRECTAMENTE)
EXEC ventas3.ModificarVenta 5, 'Member', 'Male', 257020

---EJECUCION MODIFICAR VENTA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.ModificarVenta 5, 'Member', 'Male', 25702011

----- EJECUCION ELIMINAR VENTA (FUNCIONA CORRECTAMENTE)
EXEC ventas3.BorrarVenta 9

----- EJECUCION ELIMINAR VENTA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.BorrarVenta 7000

---EJECUCION INSERTAR DETALLE DE VENTA (FUNCIONA BIEN)
EXEC ventas3.Insertar_Detalle 20, 1, 1

---EJECUCION INSERTAR DETALLE DE VENTA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.Insertar_Detalle 20, -5, 1

---EJECUCION MODIFICAR DETALLE DE VENTA (FUNCIONA BIEN)
EXEC ventas3.Modificar_Detalle 5, 25, 1, 2

---EJECUCION MODIFICAR DETALLE DE VENTA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.Modificar_Detalle 5, 0, -1, 2

---EJECUCION BORRAR DETALLE DE VNETA (FUNCIONA BIEN)
EXEC ventas3.Borrar_Detalle 1

---EJECUCION BORRAR DETALLE DE VNETA (SALE X ALGUNA CONDICION DE CORTE)
EXEC ventas3.Borrar_Detalle -1

---------------------------------------------------------
-------------------------------------------------------
EXEC ventas3.TestFacturayVenta 
-------------------------------------------------------
------------------------------------------------------

EXEC administracion3.GenerarNotaDeCredito 1

EXEC administracion3.ModificarNotaDeCredito 1, 50

EXEC administracion3.EliminarNotaDeCredito 1

SELECT * FROM ventas3.Factura
SELECT * FROM ventas3.Venta
SELECT * FROM ventas3.Detalle_Venta


