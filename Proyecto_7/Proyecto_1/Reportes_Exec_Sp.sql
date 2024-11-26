--EJECUCION DE LOS SP DE REGISTROS

GO
USE Com2900G03
GO

EXECUTE grupo3.ReporteMensual 3,2019

EXECUTE grupo3.ReporteRango '2024-01-01', '2024-12-31'

EXECUTE grupo3.ReporteRangoSucursal '2024-01-01', '2024-12-31'

EXECUTE grupo3.ReporteSemanal 01,2019
