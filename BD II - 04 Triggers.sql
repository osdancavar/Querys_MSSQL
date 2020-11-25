CREATE TRIGGER TIU_AVISOL ON sales.Customer AFTER INSERT, UPDATE
AS

DECLARE @valoranterior INT
DECLARE @VALORNUEVO INT

SELECT @valoranterior = PersonID FROM deleted;
SELECT @VALORNUEVO = PersonID from inserted;

	if UPDATE(personID)
	BEGIN
		--PRINT 'Se modica dato.'
		PRINT 'Se modifica dato de Persona ID'
		PRINT @valoranterior;
		PRINT @VALORNUEVO;
	END
	ELSE
	BEGIN
		PRINT 'No se modifica el campo correcto'
	END;


SELECT * FROM Sales.Customer
UPDATE Sales.Customer
SET PersonID = 8
WHERE CustomerID = 15

