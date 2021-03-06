CREATE OR ALTER PROCEDURE uspINGRESO @PATH NVARCHAR(MAX) AS
BEGIN
	DECLARE @B NVARCHAR(2000)
	SET @B = N'BULK INSERT VISTA FROM ''' + @PATH + N''' WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')'
	EXEC sp_executesql @B
END

CREATE TRIGGER tiuUSUARIO ON USUARIO AFTER INSERT AS
	DECLARE @NUEVO VARCHAR(50)
	DECLARE @FECHA DATE 
	DECLARE @CANT INT

	SELECT @NUEVO =  ALIAS FROM inserted
	SELECT @FECHA = FECHADENACIMIENTO FROM inserted
	SET @CANT = (SELECT COUNT(1) FROM RELACION WHERE ALIAS = @NUEVO)

	DECLARE @ALIAS_C VARCHAR(50), @FECHANACIMIENTO_C DATE
	DECLARE C_INGRESO CURSOR FOR SELECT ALIAS, FECHADENACIMIENTO FROM USUARIO

	OPEN C_INGRESO
	FETCH C_INGRESO INTO @ALIAS_C, @FECHANACIMIENTO_C
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ((MONTH(@FECHANACIMIENTO_C) = MONTH(@FECHA)) AND (YEAR(@FECHANACIMIENTO_C) = YEAR(@FECHA)) AND @CANT < 50)
				BEGIN
					INSERT INTO RELACION (ALIAS, ALIASAMIGO) VALUES (@NUEVO, @ALIAS_C)
					SET @CANT = @CANT + 1
				END
		END
	COMMIT



EXEC uspINGRESO 'C:\Users\srgio\Desktop\Datos.txt'

SELECT * FROM VISTA
SELECT * FROM USUARIO

