CREATE DATABASE PRUEBA
USE PRUEBA

GO
DROP TABLE IF exists venta
CREATE TABLE Venta(id_Venta int identity(1,1) primary key not null,
						  Total decimal(6,2),
						  Cantidad int,
						  id_Producto int ,
						---  id_Sucursal int references grupo3.Sucursal(id_Sucursal), ---PREGUNTAR SI YA CON EMPLEADO TENGO ESTE DATO O SI CAMBIA DE SUCRUSAL ME AFECTARIA
						  id_Empleado int ,
						  id_Cliente int ,
						  fecha date,
						  Fechabaja date)
GO

GO
DROP TABLE IF exists Empleado
CREATE TABLE Empleado(id_Empleado int identity(257020,1) primary key not null,
							 email_Personal varchar(40),
							 email_Emprsa varchar(40),
							 CUIL char(11),
							 Fechabaja date,
							 Sucurasal varchar(20) not null ,
							 Turno varchar(15),
							 --constraint chk_Cuil CHECK(CUIL LIKE ('[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')),
							 constraint chk_Turno CHECK(Turno IN('TM','TT','Jornada Completa')))
GO


GO
CREATE or ALTER PROCEDURE ReporteTrimestral (@trimestre int, @anio int)
as
begin
SELECT
	MONTH(v.fecha) as mes, 
	e.Turno, sum(v.total) --over (partition by month(v.fecha), e.turno order by month(v.fecha)) as TotalMensual
	FROM Venta v 
	inner join Empleado e on v.id_Empleado=e.id_Empleado
	WHERE 
        YEAR(v.fecha) = @anio 
        AND (
            (@trimestre = 1 AND MONTH(v.fecha) BETWEEN 1 AND 3) OR
            (@trimestre = 2 AND MONTH(v.fecha) BETWEEN 4 AND 6) OR
            (@trimestre = 3 AND MONTH(v.fecha) BETWEEN 7 AND 9) OR
            (@trimestre = 4 AND MONTH(v.fecha) BETWEEN 10 AND 12)
        )
	group by month(v.fecha), Turno
FOR XML PATH('ReporteTrimestral');
end

GO

execute ReporteTrimestral 1, 2024

CREATE or ALTER PROCEDURE ReporteMensual (@mes int, @anio int)
as
begin
SELECT 
    DATENAME(WEEKDAY, fecha) AS DiaSemana,
    SUM(Total) AS TotalFacturado
FROM 
    Venta v
WHERE 
    MONTH(fecha) = @mes AND YEAR(fecha) = @anio
GROUP BY 
    DATENAME(WEEKDAY, fecha)
FOR XML PATH('ReporteMensual');
end

EXECUTE ReporteMensual 3,2024