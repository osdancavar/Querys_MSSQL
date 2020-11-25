--Adventure Works 2017

--Crear SP que obtenga el primer contacto ordenado por apellido de los Vendors
CREATE PROCEDURE Sales.upsGETContacts AS
BEGIN
	SELECT V.Name, P.FirstName, P.LastName
	FROM Purchasing.Vendor V INNER JOIN Person.BusinessEntityContact BEC ON (V.BusinessEntityID = BEC.BusinessEntityID)
		INNER JOIN Person.Person P ON (BEC.PersonID = P.BusinessEntityID)
			INNER JOIN Person.ContactType CT ON (BEC.ContactTypeID = CT.ContactTypeID)
	ORDER BY P.LastName ASC
END

EXEC Sales.upsGETContacts

CREATE PROCEDURE Sales.upsGETContacts2 @pLastName VARCHAR(50) AS
BEGIN
	SELECT V.Name, P.FirstName, P.LastName
	FROM Purchasing.Vendor V INNER JOIN Person.BusinessEntityContact BEC ON (V.BusinessEntityID = BEC.BusinessEntityID)
		INNER JOIN Person.Person P ON (BEC.PersonID = P.BusinessEntityID)
			INNER JOIN Person.ContactType CT ON (BEC.ContactTypeID = CT.ContactTypeID)
WHERE P.LastName = @pLastName
ORDER BY P.LastName ASC
END

EXEC Sales.upsGETContacts2 'Perko'
--aplicar el output y set en un SP 
--Crear un procedimiento que inserte el registro/contacto 

--Crear SP que obtenga el primer contacto ordenado por nombre recibiendo de parametro el apellido


--Crear SP que retorne el ID del contacto con los criterios del punto 1
--	Ejecutarlo en un bloque y si existe mostrar/buscar su nombre completo y su dirección