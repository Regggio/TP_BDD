--CREACION DE SP PARA LOS REGISTROS
GO
	USE Com2900G03
GO

--CREACION REPORTE Trimestral: mostrar el total facturado por turnos de trabajo por mes.
GO
CREATE or ALTER PROCEDURE grupo3.ReporteTrimestral (@trimestre int, @anio int)
as
begin
SELECT
	MONTH(v.fecha) as mes, 
	e.Turno, sum(d.Cantidad*d.Precio_Unitario) AS TotalMensual--over (partition by month(v.fecha), e.turno order by month(v.fecha)) as TotalMensual
	FROM grupo3.Detalle_Venta d
	inner join grupo3.Venta v on d.id_Venta=v.id_Venta
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
CREATE OR ALTER PROCEDURE grupo3.ReporteMensual (@mes INT, @anio INT)
AS
BEGIN
    SELECT 
        DATENAME(WEEKDAY, v.Fecha) AS DiaSemana,
        SUM(d.Cantidad * d.Precio_Unitario) AS TotalFacturado
    FROM 
        grupo3.Detalle_Venta d
        INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
    WHERE 
        MONTH(v.Fecha) = @mes AND YEAR(v.Fecha) = @anio
    GROUP BY 
        DATENAME(WEEKDAY, v.Fecha)
    ORDER BY 
        DiaSemana
    FOR XML PATH('ReporteMensual');
END
GO

/*CREACION REPORTE Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.*/
GO
CREATE OR ALTER PROCEDURE grupo3.ReporteRango (@fechaI DATE, @fechaF DATE)
AS
BEGIN
    SELECT
        p.id_Producto, 
        p.Nombre,
        SUM(d.Cantidad) AS TotalVendidos
    FROM 
        grupo3.Detalle_Venta d
        INNER JOIN grupo3.Producto p ON p.id_Producto = d.id_Producto
        INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
    WHERE
        v.Fecha BETWEEN @fechaI AND @fechaF
    GROUP BY
        p.id_Producto, 
        p.Nombre
    ORDER BY
        TotalVendidos DESC
    FOR XML PATH('ReporteRango');
END
GO

/*CREACION REPORTE Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor*/
GO
CREATE OR ALTER PROCEDURE grupo3.ReporteRangoSucursal (@fechaI DATE, @fechaF DATE)
AS
BEGIN
    SELECT
        s.Ciudad, 
        p.id_Producto, 
        p.Nombre,
        SUM(d.Cantidad) AS TotalVendidosSucursal
    FROM
        grupo3.Producto p
        INNER JOIN grupo3.Detalle_Venta d ON p.id_Producto = d.id_Producto
        INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
        INNER JOIN grupo3.Empleado e ON v.id_Empleado = e.id_Empleado
        INNER JOIN grupo3.Sucursal s ON e.id_Sucursal = s.id_sucursal
    WHERE
        v.fecha BETWEEN @fechaI AND @fechaF
    GROUP BY
        s.Ciudad, 
        p.id_Producto, 
        p.Nombre
    ORDER BY
        TotalVendidosSucursal DESC
    FOR XML PATH('ReporteRangoSucursal');
END
GO

/*CREACION REPORTE Mostrar los 5 productos más vendidos en un mes, por semana*/
GO
CREATE OR ALTER PROCEDURE grupo3.ReporteSemanal (@mes INT, @anio INT)
AS 
BEGIN
    WITH VentasSemanales (id_Producto, Nombre, Semana, CantidadSemanal, Top5) AS (
        SELECT 
            p.id_Producto, 
            p.Nombre,
            DATEPART(WEEK, v.Fecha) AS Semana,
            SUM(d.Cantidad) AS CantidadSemanal,
            RANK() OVER (PARTITION BY DATEPART(WEEK, v.Fecha) ORDER BY SUM(d.Cantidad) DESC) AS Top5
        FROM
            grupo3.Detalle_Venta d
            INNER JOIN grupo3.Producto p ON d.id_Producto = p.id_Producto
            INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
        WHERE 
            MONTH(v.Fecha) = @mes AND YEAR(v.Fecha) = @anio
        GROUP BY 
            p.id_Producto, 
            p.Nombre, 
            DATEPART(WEEK, v.Fecha)
    )
    SELECT *
    FROM VentasSemanales
    WHERE Top5 <= 5
    FOR XML PATH('ReporteSemanal');
END
GO

GO
CREATE OR ALTER PROCEDURE grupo3.ReporteMenosVendidos (@mes INT, @anio INT)
AS
BEGIN
    WITH VentasMensuales (id_Producto, Nombre, CantidadMensual, Top5) AS (
        SELECT 
            d.id_Producto, 
            p.Nombre,
            SUM(d.Cantidad) AS CantidadMensual,
            RANK() OVER (ORDER BY SUM(d.Cantidad) ASC) AS Top5
        FROM
            grupo3.Detalle_Venta d
            INNER JOIN grupo3.Producto p ON d.id_Producto = p.id_Producto
            INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
        WHERE 
            MONTH(v.fecha) = @mes AND YEAR(v.fecha) = @anio
        GROUP BY 
            d.id_Producto, 
            p.Nombre
    )
    SELECT *
    FROM VentasMensuales
    WHERE Top5 <= 5
    FOR XML PATH('ReporteMenosVendidos');
END
GO

GO
CREATE OR ALTER PROCEDURE grupo3.VentasFechaSucursal (@fecha DATE, @sucursal INT)
AS
BEGIN
    SELECT
        s.Ciudad, 
        v.fecha, 
        p.id_Producto, 
        p.Nombre,
        SUM(d.Cantidad) AS CantidadVendida,
        SUM(d.Cantidad * d.Precio_Unitario) AS TotalVendido
    FROM 
        grupo3.Detalle_Venta d
        INNER JOIN grupo3.Venta v ON d.id_Venta = v.id_Venta
        INNER JOIN grupo3.Producto p ON d.id_Producto = p.id_Producto
        INNER JOIN grupo3.Empleado e ON v.id_Empleado = e.id_Empleado
        INNER JOIN grupo3.Sucursal s ON e.id_Sucursal = s.id_sucursal
    WHERE 
        v.fecha = @fecha AND s.id_sucursal = @sucursal
    GROUP BY
        s.Ciudad, 
        v.fecha, 
        p.id_Producto, 
        p.Nombre
    FOR XML PATH('VentasFechaSucursal');
END
GO
