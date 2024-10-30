---ENTREGA 4
--Importacion de Catalogo (Archivo CSV)
--ES NECESARIA LA CTE? FUNCIONA BIEN DENTRO DE UN SP?, COMO CORRIJO LOS PROBLEMAS QUE GENERAN LOS CARACTERES EXTRAÑOS?, PUEDO EVITAR CARGAR TOODS LOS DATOS DEL ARCHIVO?
--- EL FROM @DIRECCION ES VALIDO? O TENGO QUE HARCODEAR LA DIRECCION DEL ARCHIVO
---DEBERIA SER EN UNA TABLA TEMPORAL Y DESPUES SE ABRE EL OTRO ARCHIVO DE PRODUCTOS PARA AGREGARLE LA CATEGORIA
-- A LA HORA DE LA INSERCION HACER UN SELECT X UN VALOR PARA QUE NO INSERTE DE VULETA CAMPOS QUE YA INSERTO
GO
CREATE OR ALTER PROCEDURE grupo3.Importacion_catalogo as
begin
	BULK INSERT TP_Supermercado_GRPO3.grupo3.Producto
	FROM 'C:\Users\HP\Desktop\TP_integrador_Archivos\Productos\catalogo.csv'
	WITH
	(
	FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
	CODEPAGE = '65001'
	);
end
GO

GO
exec grupo3.Importacion_catalogo 
GO

---Habilitacion de la configuracion del	servidor para consultas distribuidas (necesarias para utilizar el openrowset)
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

---CREARCION DE SP PARA INSERCION DE CUCURSALES DEL ARCHIVO INFORMACION COMPLEMENTARIA
/* Seguimos el ejemplo del https://learn.microsoft.com/es-es/sql/relational-databases/import-export/import-data-from-excel-to-sql?view=sql-server-ver16#openrowset-and-linked-servers 
 Si esta bien deberia hacerse la insercion igual para los otros tabs de la hoja de excel */
GO
CREATE OR ALTER PROCEDURE grupo3.Insercion_Suc as
begin 
	CREATE TABLE grupo3.#Sucursal_Temp(Ciudad varchar(10), 
										Reemplazo varchar(10),
										Direccion varchar(50),
										Horario varchar(30),
										Telefono char(9))
	INSERT INTO grupo3.#Sucursal_Temp SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
	'Excel 12.0; Database=C:\Users\HP\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
	'SELECT * FROM [sucursal$]');
	INSERT INTO grupo3.Sucursal(Ciudad,Direccion,Horario,Telefono)
	SELECT Reemplazo, Direccion, Horario, Telefono
	from grupo3.#Sucursal_Temp
end
go

exec grupo3.Insercion_Suc
