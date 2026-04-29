use AdventureWorks2008R2;

-- Ejercicio 1

begin try
	begin transaction;

	DECLARE @Resultado INT;
	DECLARE @Numero INT = 5; 
	DECLARE @Divisor INT = 0;

	set @Resultado = @Numero / @Divisor;

	commit transaction;
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		rollback transaction;

	DECLARE @ErrorNumero INT = ERROR_NUMBER();
	DECLARE @ErrorMensaje NVARCHAR(3000) = ERROR_MESSAGE();
	DECLARE @ErrorLinea INT = ERROR_LINE();
	DECLARE @ErrorProcedimiento NVARCHAR(3000) = ERROR_PROCEDURE();

	PRINT 'Error';
	PRINT 'Numero: ' + CAST(@ErrorNumero AS NVARCHAR);
	PRINT 'Linea: '  + CAST(@ErrorLinea AS NVARCHAR);
	PRINT 'Mensaje: '+ @ErrorMensaje;
	PRINT 'Procedimiento: '+ ISNULL(@ErrorProcedimiento,'N/A');
END CATCH;

-- Ejercicio 2

begin try
	begin transaction;

	DECLARE @Resultado INT;
	DECLARE @Numero INT = 5; 
	DECLARE @Divisor INT = 0;

	set @Resultado = @Numero / @Divisor;

	commit transaction;
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		rollback transaction;

	print 'No se pudo hacer la division';

END CATCH;

-- Ejercicio 3

begin try
	begin transaction;

	DECLARE @Resultado INT;
	DECLARE @Numero INT = 5; 
	DECLARE @Divisor INT = 0;

	set @Resultado = @Numero / @Divisor;

	commit transaction;
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		rollback transaction;

	print 'No se pudo hacer la division';
	raiserror ('Division por cero detectada.', 16, 1);
END CATCH;

-- Ejercicio 4

begin try
	begin transaction;

	DECLARE @Resultado INT;
	DECLARE @Numero INT = 5; 
	DECLARE @Divisor INT = 0;

	set @Resultado = @Numero / @Divisor;

	commit transaction;
END TRY
BEGIN CATCH
	if @@TRANCOUNT > 0
		rollback transaction;

	print 'No se pudo hacer la division';
	throw;
END CATCH;