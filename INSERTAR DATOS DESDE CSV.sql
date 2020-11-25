create or alter Procedure dbo.INSERTAR
As
Begin
Create table #Datos( 
FECHA date not null,
HORA time not null,
origen varchar(8) not null,
destino varchar(8) null,
tipo int not null,
duracionOCantidad int not null,
estado int not null
)

BULK INSERT #Datos
FROM 'C:\Users\jalba\Downloads\UFamlilia.csv'--Agregar Pad
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
)

    declare @FECHA date 
    declare @HORA time not null 
    declare @origen varchar(8)
    declare @destino varchar(8) 
    declare @tipo int 
    declare @duracionOCantidad int
    declare @UID INT

    Declare CursorPersona Cursor for
    Select * from #Datos
    Open CursorPersona
    fetch next from CursorPersona into @PRIMER_NOMBRE,@SEGUNDO_NOMBRE,@PRIMER_APELLIDO,@SEGUNDO_APELLIDO,@CORREO,@FECHA_NACIMIENTO
    while @@FETCH_STATUS = 0
    Begin
        set transaction isolation level serializable
        begin tran
        Insert into USUARIO(PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,AMIGOS_PERMITIDOS,CORREO,FECHA_NACIMIENTO,FECHA_SIGN_UP)
        VALUES(@PRIMER_NOMBRE,@SEGUNDO_NOMBRE,@PRIMER_APELLIDO,@SEGUNDO_APELLIDO,50,@CORREO,@FECHA_NACIMIENTO,CAST( GETDATE() AS Date ))
        commit
        --Agregar como amigos si tienen mismos apellidos Es necesario separarlo en otro proceso?
        Select @UID = U.USERID
        FROM USUARIO u
        WHERE @CORREO = U.CORREO



    fetch next from CursorPersona into @PRIMER_NOMBRE,@SEGUNDO_NOMBRE,@PRIMER_APELLIDO,@SEGUNDO_APELLIDO,@CORREO,@FECHA_NACIMIENTO
    END
    Close CursorPersona
    Deallocate CursorPersona

Drop table #Datos

End