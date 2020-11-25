create view EmpleadosContratados AS
Select E.HireDate, E.JobTitle, p.FirstName, p.LastName 
from HumanResources.Employee E
inner join Person.Person P on e.BusinessEntityID = p.BusinessEntityID 

Select * from EmpleadosContratados

--vista normal o de bd
--vista materializadas: indice... si se mantiene

create table Persona
(
	ID int primary key,
	nombre varchar(50) not null,
	apellido varchar(50) not null,
	genero varchar(50) not null,
	dpi int not null
)

execute sp_helpindex Persona

create nonclustered index ix_persona_nombre
	on Persona(nombre asc)
