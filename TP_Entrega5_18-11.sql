CREATE or ALTER PROCEDURE grupo3.GenerarNotaDeCredito (@id_Usuario int, @id_Factura int, @Total decimal (10,2))
as
begin
	DECLARE @Rol varchar (50);
	DECLARE @EstadoFactura varchar(50);

	--Obtengo rol--
	SELECT @Rol = rol FROM Usuarios WHERE id_Usuario = @id_Usuario;
	--verifico que sea supervisor--
	IF @Rol <> 'Supervisor'
	begin
		RAISERROR ('Solo los supervisores pueden generar notas de credito',16,1);
		RETURN;
	end

	--OBtengo estado factura--
	SELECT @EstadoFactura = Estado FROM Factura WHERE id_Factura = @id_Factura
	--Verifico que este paga--
	IF @EstadoFactura <> 'Pagada'
	begin
		RAISERROR ('La factura debe estar pagada para generar notas de credito',16,1);
		RETURN;
	end

	--Inserto nota de credito--
	INSERT INTO NotaDeCredito (id_Factura, Total) VALUES (@id_Factura, @Total);
end

--Back UP--
BACKUP DATABASE TP_Supermercado_GRPO3
TO DISK = 'C:\Backups\TP_Supermercado_GRPO3.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Backup TP_Supermercado_GRPO3';