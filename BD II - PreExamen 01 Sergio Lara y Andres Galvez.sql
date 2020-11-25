-- PRE-EXAMEN 1

-- 1. Crear una tabla resumen con la siguiente información sobre las ventas que se han realizado:
--	  a. Nombre de cliente
--    b. Año compra
--    c. Mes de compra
--    d. Canditad de compras para ese año-mes del cliente
--    e. Código de la primer OC de ese año-mes
--    f. Numero de meses de compra [0-6]
--		f.1. De los productos de la primer OC, 6 meses para atras en cuantos de ellos realzo por lo menos una compra con alguno de dichos productos.
CREATE PROCEDURE SP_RESUMEN_VENTAS
AS
BEGIN
	IF OBJECT_ID ('RESUMEN_VENTAS') IS NOT NULL
	BEGIN
		TRUNCATE TABLE RESUMEN_VENTAS;
	END
	ELSE
	BEGIN
		CREATE TABLE RESUMEN_VENTAS(
		ID INT, NOMBRE VARCHAR(100), AÑO INT, MES INT, CANTIDAD_COMPRAS INT, CODIGO_PRIMER_SO INT, NUMERO_MESES_COMPRA INT,
		CONSTRAINT PK PRIMARY KEY(ID, AÑO, MES))
	END

	DECLARE @CID INT, @ID INT, @NOMBRE VARCHAR (100), @AÑO INT, @MES INT, @CANTIDAD_COMPRAS INT

	DECLARE C_RESUMEN_VENTAS CURSOR FOR 
	SELECT C.CustomerID, P.BusinessEntityID, P.FirstName, YEAR(SO.OrderDate), MONTH(SO.OrderDate), COUNT(1)
	FROM Sales.SalesOrderHeader SO INNER JOIN Sales.Customer C ON (SO.CustomerID = C.CustomerID)
		INNER JOIN Person.Person P ON (C.PersonID = P.BusinessEntityID)
	GROUP BY C.CustomerID, P.BusinessEntityID, P.FirstName, YEAR(SO.OrderDate), MONTH(SO.OrderDate)

	OPEN C_RESUMEN_VENTAS
	FETCH C_RESUMEN_VENTAS INTO @CID, @ID, @NOMBRE, @AÑO, @MES, @CANTIDAD_COMPRAS
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		DECLARE @CODIGO INT, @MENOR_FECHA DATE, @CANT INT
		SET @MENOR_FECHA = (SELECT MIN(SO.OrderDate) FROM Sales.SalesOrderHeader SO WHERE YEAR(SO.OrderDate) = @AÑO AND MONTH(SO.OrderDate) = @MES AND SO.CustomerID = @CID)
		SET @CODIGO = (SELECT SO.SalesOrderID FROM Sales.SalesOrderHeader SO WHERE SO.OrderDate = @MENOR_FECHA AND SO.CustomerID = @CID)
		SET @CANT = (SELECT TOP 1 COUNT(1) FROM Sales.SalesOrderHeader SO INNER JOIN Sales.SalesOrderDetail SOD ON (SO.SalesOrderID = SOD.SalesOrderID)
						WHERE SO.CustomerID = @CID AND SO.OrderDate <= @MENOR_FECHA AND SO.OrderDate >= DATEADD(MONTH, -6, @MENOR_FECHA)
						GROUP BY SOD.ProductID, SO.CustomerID
						ORDER BY COUNT(1) DESC)

		INSERT INTO RESUMEN_VENTAS VALUES (@ID, @NOMBRE, @AÑO, @MES, @CANTIDAD_COMPRAS, @CODIGO, @CANT) 
		
		FETCH C_RESUMEN_VENTAS INTO @CID, @ID, @NOMBRE, @AÑO, @MES, @CANTIDAD_COMPRAS
	END
	CLOSE C_RESUMEN_VENTAS
	DEALLOCATE C_RESUMEN_VENTAS
END

EXEC SP_RESUMEN_VENTAS


-- 2. Mostrar las personas con sus respectivas direcciones
--	a. Nombre	b. Apellido		c. Tipo dirección	d. Línea 1	e. Línea 2	f. Ciudad
SELECT P.FirstName, P.LastName, T.Name, A.AddressLine1, A.AddressLine2, A.City
FROM Person.Person P INNER JOIN Person.BusinessEntityAddress BA ON (P.BusinessEntityID = BA.BusinessEntityID)
	INNER JOIN Person.AddressType T ON (BA.AddressTypeID = T.AddressTypeID)
		INNER JOIN Person.Address A ON (BA.AddressID = A.AddressID)

-- 3. Cuantas ordenes de trabajo se han realizado por producto en cada año
--	a. Nombre producto	b. Año	c. Cantidad de ordenes de trabajo
SELECT P.Name, YEAR(WO.StartDate) AS AÑO, COUNT(1) AS CANTIDAD 
FROM Production.WorkOrder WO INNER JOIN Production.Product P ON (WO.ProductID = P.ProductID)
GROUP BY P.Name, YEAR(WO.StartDate)

-- 4. Aplicar un aumento del 10% a todos los empleados de la empresa (usar un cursor)
--	a. Actualizar el "rate" en 10% del ultimo suelto
--	b. Si la persona es de ventas aumentar 10% el bono tambien (Esto con un trigger)
CREATE TRIGGER T_AUMENTO ON HumanResources.EmployeePayHistory FOR UPDATE 
AS
DECLARE @DEPARTAMENTO INT, @ID INT
SET @ID = (SELECT TOP 1 I.BusinessEntityID FROM inserted I)
SET @DEPARTAMENTO = (SELECT TOP 1 D.DepartmentID FROM HumanResources.EmployeeDepartmentHistory D WHERE D.BusinessEntityID = @ID)
IF @DEPARTAMENTO = 3
BEGIN
	UPDATE Sales.SalesPerson SET Bonus = Bonus * 1.1 WHERE BusinessEntityID = @ID
END

DECLARE @BID INT, @SUELDO MONEY
DECLARE C_AUMENTO CURSOR FOR
SELECT P.BusinessEntityID, P.Rate FROM HumanResources.EmployeePayHistory P

OPEN C_AUMENTO
FETCH C_AUMENTO INTO @BID, @SUELDO
WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE HumanResources.EmployeePayHistory SET Rate = @SUELDO * 1.1 WHERE BusinessEntityID = @BID
	FETCH C_AUMENTO INTO @BID, @SUELDO
END
CLOSE C_AUMENTO
DEALLOCATE C_AUMENTO

-- 5. Demuestre para los ejercicois 2 y 3 los querys creados sean los mas optimos, aplicando si es necesario alguna creación de indices.
--Si son optimos debido a que el Plan de ejecución no muestra la necesida de un indice para ejecutarlos


-- 6. Sobre los empleados, valide que no permite tener para 1 empleados más de un departamento activo
CREATE TRIGGER HumanResources.tiu_verificarDepto ON HumanResources.EmployeeDepartmentHistory AFTER INSERT, UPDATE AS
DECLARE @entidadID INT
DECLARE @deptoID INT

SELECT @deptoID = I.DepartmentID, @entidadID = I.BusinessEntityID
FROM INSERTED I

IF EXISTS (SELECT * FROM HumanResources.EmployeeDepartmentHistory WHERE BusinessEntityID = @entidadID)
BEGIN
	PRINT 'Error.'
	ROLLBACK TRANSACTION
END
ELSE
BEGIN
	PRINT 'Operación exitosa.'
END

-- 7. ¿Cual es el producto mas vendido por año? Tome en cuenta unicamente los productos que se hayan vendido a mas de un cliente
SELECT * FROM (SELECT ROW_NUMBER() OVER(PARTITION BY [anio] ORDER BY [cantidad] DESC ) AS rn, t1.* FROM (
		SELECT YEAR(SOH.DueDate) AS anio, p.Name AS producto, SUM(SOD.OrderQty) AS cantidad 
		FROM Sales.SalesOrderHeader SOH
			INNER JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
			INNER JOIN Production.Product p ON SOD.ProductID = p.ProductID
				GROUP BY YEAR(SOH.DueDate), p.Name) t1 ) as t2 where rn<=1

-- 8. Actualice la comisión a pagar para los vendedores, cada vez que ocurra algún movimiento de venta
ALTER TABLE Sales.SalesPerson 
ADD Comisiones MONEY

create trigger ti_actualizarComision ON Sales.SalesOrderHeader AFTER UPDATE AS
DECLARE @vendor INT
SELECT @vendor = SalesPersonID FROM INSERTED 
DECLARE @total MONEY
SELECT @total = TotalDue FROM INSERTED
UPDATE Sales.SalesPerson
SET Comisiones = Comisiones + (CommissionPct * @total)