--No permite ingresar una tarjeta de crédito con diferencia de fecha de expiración menor a 30 días.
CREATE TRIGGER Sales.ti_TarjetaAviso ON Sales.CreditCard AFTER INSERT AS DECLARE @mesExp INT
SET @mesExp = (SELECT ExpMonth FROM inserted)

        if( @mesExp <= MONTH(GETDATE()) + 1)
        BEGIN
            DELETE FROM Sales.CreditCard
            WHERE CreditCardID = (SELECT CreditCardID from inserted)
            PRINT 'Fecha de expiración menor a 30 días.'
        END;
        ELSE
        BEGIN
            PRINT 'Tarjeta válida.';
	END;

--No permite ingresar y/o atualizar un correo electrónico asociado a otra persona.
CREATE TRIGGER Person.tiu_ValidarCorreo ON Person.EmailAddress FOR INSERT, UPDATE AS
    DECLARE @correoNuevo VARCHAR(50)
    DECLARE @correoExistente VARCHAR(50)

    SELECT @correoExistente = EA.EmailAddress
    FROM Person.EmailAddress EA
    WHERE EA.EmailAddress = (SELECT EmailAddress FROM INSERTED)

    SELECT @correoNuevo = EmailAddress FROM INSERTED

    IF (@correoExistente = @correoNuevo)
    BEGIN
        PRINT 'El correo ya existe en la base de datos.'
        ROLLBACK TRANSACTION
    END

--Actulizar el inventario del producto al vender cada uno de ellos. Al momento que se confirma y/o cancela la venta
CREATE TRIGGER Sales.tu_Inventario ON Sales.SalesOrderDetail
AFTER UPDATE, INSERT AS
	DECLARE @pUnidades INT
	SELECT @pUnidades =  d.OrderQty
	FROM Sales.SalesOrderDetail INNER JOIN deleted d on d.SalesOrderDetailID = Sales.SalesOrderDetail.SalesOrderDetailID 

	DECLARE @pUnidadesinsertado INT
	SELECT @pUnidadesinsertado =  i.OrderQty
	FROM Sales.SalesOrderDetail INNER JOIN inserted i ON i.SalesOrderDetailID = Sales.SalesOrderDetail.SalesOrderDetailID 

UPDATE Production.ProductInventory 
SET Production.ProductInventory.Quantity = Production.ProductInventory.Quantity-(i.OrderQty- @pUnidades) 
	FROM inserted i WHERE i.ProductID = Production.ProductInventory.ProductID;

	SELECT * FROM Sales.SalesOrderDetail
	SELECT * FROM Production.ProductInventory

UPDATE Sales.SalesOrderDetail
SET OrderQty = 25
WHERE SalesOrderDetailID = 1 AND  SalesOrderID = 43659