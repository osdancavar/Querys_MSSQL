--Cual es la ciudad de entrega que tiene el mayor numero de ordenes realizadas
SELECT O.ShipCity, COUNT(1) AS Cant_Orders FROM Orders O 
GROUP BY O.ShipCity 
ORDER BY COUNT(1) DESC

--Cuantos diferentes numeros existen en los telefonos de los proveedores tomando  en cuenta
--unicamente el ultimo caracter de dicha columna
SELECT COUNT(1) FROM Suppliers S
GROUP BY RIGHT(CAST(S.Phone AS varchar(25)), 1)