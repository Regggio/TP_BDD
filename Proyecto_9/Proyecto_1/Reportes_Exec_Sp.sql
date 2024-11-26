--EJECUCION DE LOS SP DE REGISTROS

GO
USE Com2900G03
GO

EXECUTE grupo3.ReporteTrimestral 1, 2019

EXECUTE grupo3.ReporteMensual 3,2019

EXECUTE grupo3.ReporteRango '2019-01-01', '2019-12-31'

EXECUTE grupo3.ReporteRangoSucursal '2019-01-01', '2019-12-31'

EXECUTE grupo3.ReporteSemanal 01,2019

EXECUTE grupo3.ReporteMenosVendidos 01, 2019

EXECUTE grupo3.VentasFechaSucursal '2019-01-01', 1

EXECUTE grupo3.ReporteGeneral
