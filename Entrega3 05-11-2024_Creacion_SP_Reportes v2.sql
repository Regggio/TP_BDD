--ENTREGA 3 CREACION DE SP PARA LOS REGISTROS
--CREACION REPORTE Trimestral: mostrar el total facturado por turnos de trabajo por mes.
GO
CREATE or ALTER PROCEDURE grupo3.ReporteTrimestral (@trimestre int, @anio int)
as
begin
SELECT
	MONTH(v.fecha) as mes, 
	e.Turno, sum(v.total) --over (partition by month(v.fecha), e.turno order by month(v.fecha)) as TotalMensual
	FROM grupo3.Venta v 
	inner join grupo3.Empleado e on v.id_Empleado=e.id_Empleado
	WHERE 
        YEAR(v.fecha) = @anio 
        AND (
            (@trimestre = 1 AND MONTH(v.fecha) BETWEEN 1 AND 3) OR
            (@trimestre = 2 AND MONTH(v.fecha) BETWEEN 4 AND 6) OR
            (@trimestre = 3 AND MONTH(v.fecha) BETWEEN 7 AND 9) OR
            (@trimestre = 4 AND MONTH(v.fecha) BETWEEN 10 AND 12)
        )
	GROUP BY month(v.fecha), Turno
FOR XML PATH('ReporteTrimestral');
end
GO

---CREACION REPORTE Mensual: ingresando un mes y año determinado mostrar el total facturado por días de la semana, incluyendo sábado y domingo.
GO
CREATE or ALTER PROCEDURE grupo3.ReporteMensual (@mes int, @anio int)
as
begin
SELECT 
    DATENAME(WEEKDAY, fecha) AS DiaSemana,
    SUM(Total) AS TotalFacturado
FROM 
    grupo3.Venta v
WHERE 
    MONTH(fecha) = @mes AND YEAR(fecha) = @anio
GROUP BY 
    DATENAME(WEEKDAY, fecha)
FOR XML PATH('ReporteMensual');
end
GO

/*CREACION REPORTE Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.*/
GO
CREATE or ALTER PROCEDURE grupo3.ReporteRango (@fechaI date, @fechaF date)
as
begin
SELECT
	p.id_Producto, p.Nombre,
	SUM(v.cantidad) OVER (PARTITION BY v.id_Producto) AS TotalVendidos
FROM
	grupo3.Producto p
	inner join grupo3.Venta v on p.id_Producto = v.id_Producto
WHERE
	v.fecha BETWEEN @fechaI AND @fechaF
ORDER BY
	TotalVendidos DESC
FOR XML PATH('ReporteRango');
end

GO

/*CREACION REPORTE Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor*/
GO
CREATE or ALTER PROCEDURE grupo3.ReporteRangoSucursal (@fechaI date, @fechaF date)
as
begin
SELECT
	s.Ciudad, p.id_Producto, p.Nombre,
	SUM(v.cantidad) OVER (PARTITION BY v.id_Producto,s.Ciudad) AS TotalVendidosSucursal
FROM
	grupo3.Producto p
	inner join grupo3.Venta v on p.id_Producto = v.id_Producto
	inner join grupo3.Empleado e on v.id_Empleado = e.id_Empleado
	inner join grupo3.Sucursal s on e.id_Sucursal = s.id_sucursal
WHERE
	v.fecha BETWEEN @fechaI AND @fechaF
ORDER BY
	TotalVendidosSucursal DESC
FOR XML PATH('ReporteRangoSucursal');
end
GO

/*CREACION REPORTE Mostrar los 5 productos más vendidos en un mes, por semana*/
GO
CREATE or ALTER PROCEDURE grupo3.ReporteSemanal (@mes int, @anio int)
as 
begin
	WITH VentasSemanales (id_Producto,Nombre,Semana,CantidadSemanal,Top5) AS (
		SELECT p.id_Producto, p.Nombre,
			NTILE (4) OVER (PARTITION BY DAY (v.fecha) order by DAY (v.fecha)) AS Semana,
			SUM(v.Cantidad) OVER (PARTITION BY v.id_Producto, WEEK(v.fecha)) AS CantidadSemanal,
			RANK () OVER (PARTITION BY WEEK(v.fecha) ORDER BY CantidadSemanal DESC) AS Top5
		FROM
			grupo3.Venta v
			inner join grupo3.Producto p on v.id_Producto = p.id_Producto
		WHERE 
			MONTH (v.fecha) = @mes AND YEAR (v.fecha) = @anio)
	SELECT *
	FROM VentasSemanales
	WHERE Top5 <= 5
FOR XML PATH('ReporteSemanal');
end
GO

GO
CREATE or ALTER PROCEDURE grupo3.ReporteMenosVendidos (@mes int, @anio int)
as
begin
	WITH VentasMensuales (id_Producto,Nombre,CantidadMensual) AS (
		SELECT p.id_Producto, p.Nombre,
		SUM(v.Cantidad) OVER (PARTITION BY v.id_Producto) AS CantidadMensual,
		RANK() OVER (ORDER BY CantidadMensual ASC) AS Top5
		FROM
			grupo3.Venta v
			inner join grupo3.Producto p on v.id_Producto = p.id_Producto
			WHERE 
            MONTH(v.fecha) = @mes AND YEAR(v.fecha) = @anio)
	SELECT *
	FROM VentasMensuales
	WHERE Top5 <= 5
FOR XML PATH('ReporteMenosVendidos');
end
GO

GO
CREATE or ALTER PROCEDURE grupo3.VentasFechaSucursal (@fecha date, @sucursal int)
as
begin
	SELECT
	s.Ciudad, v.fecha, p.id_Producto, p.Nombre,
	SUM (v.Cantidad) OVER (PARTITION BY v.id_Producto) as CantidadVendida,
	SUM (v.Total) OVER (PARTITION BY v.id_Producto) as TotalVendido
	FROM 
        grupo3.Venta v
    inner join
        grupo3.Producto p ON v.id_Producto = p.id_Producto
    inner join 
        grupo3.Empleado e ON v.id_Empleado = e.id_Empleado
    inner join
        grupo3.Sucursal s ON e.id_Sucursal = s.id_sucursal
    WHERE 
        v.fecha = @fecha AND s.id_sucursal = @sucursal
FOR XML PATH('VentasFechaSucursal');
end
GO
