---ENTREGA 4
---EJECUCION DE LOS SP PARA IMPORTACION DE ARCHIVOS
USE Com2900G03

--EJECUCION IMPORTACION Sucursales (xlsx)
GO
exec import3.Importacion_Suc 'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'
GO

---EJECUCION IMPORTACION Empleados (xlsx)
GO
exec import3.Importacion_Emp 'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'
GO

--EJECUCION IMPORTACION Productos Electronicos (xlsx)
GO
exec import3.Importacion_Productos_Electronicos 
				'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
GO

--EJECUCION IMPORTACION Productos Importados (xlsx)
GO
exec import3.Poductos_Importados 'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
GO

--EJECUCION IMPORTACION Catalogo de productos (csv)
GO
exec import3.Importacion_catalogo 'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\catalogo.csv',
								'C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx'
GO

---EJECUCION IMPORTACION Ventas Registadas (csv)
GO
exec import3.Importacion_Venta 'C:\Users\HP\Desktop\TP_integrador_Archivos\Ventas_registradas.csv'
GO


