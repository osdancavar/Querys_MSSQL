--Jorge Diaz [1135418]
--Andres Gálvez [1024718]
--Sergio Lara [1044418]

-- 1.Cuantas ordenes de trabajo se han realizado por producto en cada año
-- a. Nombre de producto
-- b. Año
-- c. Cantidad de ordenes de trabajo
SELECT P.Name, YEAR(WO.StartDate) AS Año, COUNT(1) AS [Ordenes de trabajo]
FROM Production.WorkOrder WO INNER JOIN Production.Product P
	ON WO.ProductID = P.ProductID
GROUP BY P.Name, YEAR(WO.StartDate)

--2.Crear procedimiento que actualice el metodo de entrega para todas las compras realizadas
--en un ano y mes especifico, validando que dicha compra contenga cierto producto (nombre)
CREATE PROCEDURE Purchasing.upsUpdateShipMethod
@pAño INTEGER, --Parametro de entrada
@pMes INTEGER,
@pProducto VARCHAR(50)
AS
BEGIN

	UPDATE Purchasing.PurchaseOrderHeader
	SET Purchasing.PurchaseOrderHeader.ShipMethodID = 3
	FROM Purchasing.PurchaseOrderHeader POH INNER JOIN Purchasing.PurchaseOrderDetail POD 
	ON POH.PurchaseOrderID = POD.PurchaseOrderID INNER JOIN Production.Product P
	ON POD.ProductID = P.ProductID 

	WHERE P.Name = @pProducto AND YEAR(POH.OrderDate) = @pAño AND MONTH(POH.OrderDate) = @pMes
END


EXEC Purchasing.upsUpdateShipMethod 2012, 1, 'External Lock Washer 3'

-- 3. Crear una función que calcule el promedio del precio unitario para una compra en especifico
-- Parametros: ano, mes, producto. Tabla y campo a actualizar
-- Mostrar: Numero de orden, fecha, total, promedio PU
FUNCTION ufnGetAVG (@SalesOrderID INT) RETURNS INT AS
BEGIN
	DECLARE	@PromedioDeArticulos MONEY
	SET @PromedioDeArticulos = 0.00
	SELECT @PromedioDeArticulos = AVG(p.ListPrice) FROM Sales.SalesOrderHeader soh
		INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
			INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE (@SalesOrderID = soh.SalesOrderID)
GROUP BY soh.SalesOrderID
RETURN @PromedioDeArticulos
END
----
SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue, dbo.ufnGetAVG(soh.SalesOrderID) AS 'Promedio precio unitario'
FROM Sales.SalesOrderHeader soh
