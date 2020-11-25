--Adventure Works 2017

-- Para cliente con su dirección de casa en Redmond, mostrar el campo line1 de dicha dirección y los campos line1, city de la direccion
-- de entrega ( dejar en blanco si no tiene)

--SELECT * FROM tmp_dircasa;
TRUNCATE TABLE tmp_dircasa 
--Truncate hace un DELETE a la tabla, borra todo lo que hay en la tabla

INSERT INTO tmp_dircasa
-- Inserta dato a la tabla temporal, debe haberse echo el INTO ya
SELECT P.PersonType, P.LastName, AD.AddressLine1, AD.City
--INTO tmp_dircasa 
--INTO significa que se esta creando una tabla temporal que utiliza los datos del query que esta debajo, solo debo ponerlo
--una vez o ira ingresando datos cadavez que se ejecute
FROM Person.Person P INNER JOIN Person.BusinessEntity BE ON (P.BusinessEntityID = BE.BusinessEntityID)
		INNER JOIN Person.BusinessEntityAddress BEA ON (BE.BusinessEntityID = BEA.BusinessEntityID AND BEA.AddressTypeID = 2)
			INNER JOIN Person.Address AD ON (BEA.AddressID = AD.AddressID AND AD.City = 'Redmond');

SELECT * FROM tmp_dircasa BE LEFT JOIN Person.BusinessEntityAddress BEA ON (BE.BusinessEntityID = BEA.BusinessEntityID AND BEA.AddressID = 5)
	LEFT JOIN Person.Address AD ON (BEA.AddressID = AD.AddressID);



-- Mostrar las 3 mas importantes ciudades (en cuanto a las ventas realizadas)
SELECT SUM(SOH.TotalDue) AS CANT_VENTAS, PA.City
FROM Sales.SalesOrderHeader SOH INNER JOIN Person.Address PA ON (SOH.BillToAddressID = PA.AddressID)
GROUP BY PA.City
ORDER BY CANT_VENTAS DESC

-- Cuantas ventas se han realizado según los rango de venta de: 0-99; 100-999; 1000-9999; 10000-infitino

DECLARE C_SOH CURSOR FOR SELECT SOH.TotalDue FROM Sales.SalesOrderHeader SOH
DECLARE @C1 INTEGER, @C2 INTEGER, @C3 INTEGER, @C4 INTEGER, @TOTAL MONEY
SET @C1 = 0; SET @C2 = 0; SET @C3 = 0; SET @C4 = 0; 
OPEN C_SOH
FETCH C_SOH INTO @TOTAL
WHILE(@@FETCH_STATUS = 0)
BEGIN
	IF(@TOTAL >= 0 AND @TOTAL <= 99)
		SET @C1 = @C1 + 1
	IF(@TOTAL >= 100 AND @TOTAL <= 999)
		SET @C2 = @C2 + 1
	IF(@TOTAL >= 1000 AND @TOTAL <= 9999)
		SET @C3 = @C3 + 1
	IF(@TOTAL >= 10000)
		SET @C4 = @C4 + 1
END
CLOSE C_SOH
DEALLOCATE C_SOH
PRINT '0 - 99 HAY: ' + CAST(@C1 AS VARCHAR)
PRINT '100 - 999 HAY: ' + CAST(@C2 AS VARCHAR)
PRINT '1000 - 9999 HAY: ' + CAST(@C3 AS VARCHAR)
PRINT '10000 ó mas HAY: ' + CAST(@C4 AS VARCHAR);

--Otra forma de hacerlo sin Cursor
SELECT CASE WHEN SOH.TotalDue BETWEEN 0 AND 99 THEN 1
	WHEN SOH.TotalDue BETWEEN 100 AND 999 THEN 2 
		WHEN SOH.TotalDue BETWEEN 1000 AND 9999 THEN 3
			ELSE 4 END AS TIPO, 
			COUNT(DISTINCT SOH.SalesOrderID) AS CANTIDAD, --Solo con la PK y funciona por que esta bien normalizada la tabla
			COUNT(1) AS CANTIDAD_1, COUNT(*) AS CANTIDAD_2
FROM Sales.SalesOrderHeader SOH
GROUP BY CASE WHEN SOH.TotalDue BETWEEN 0 AND 99 THEN 1
	WHEN SOH.TotalDue BETWEEN 100 AND 999 THEN 2 
		WHEN SOH.TotalDue BETWEEN 1000 AND 9999 THEN 3
			ELSE 4 END
ORDER BY TIPO

-- Muestre el total de venta por cada Region. Del mayor al menor
SELECT CR.Name, SUM(SOH.TotalDue)as Total_De_Venta
FROM Sales.SalesOrderHeader SOH INNER JOIN Person.Address PA on SOH.BillToAddressID = PA.AddressID
	INNER JOIN Person.StateProvince SP on PA.StateProvinceID = SP.StateProvinceID
		INNER JOIN Person.CountryRegion CR on SP.CountryRegionCode = CR.CountryRegionCode
Group by CR.Name
Order by Total_De_Venta ASC