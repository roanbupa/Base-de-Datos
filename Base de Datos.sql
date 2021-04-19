CREATE DATABASE Periodico
GO
USE Periodico
GO
CREATE TABLE Categoria (
	CodigoCat varchar (3) check(len(codigoCat)=3) primary key,
	Nombre varchar (50) not null
)
CREATE TABLE Aviso (
	IdAviso int primary key identity (1,1),
	FechaPublicacion smalldatetime not null check(FechaPublicacion >= getdate()),
	
	PrecioBase money not null check (PrecioBase>=0),
	CodigoCat varchar (3) not null
		Foreign key (CodigoCat) references Categoria (CodigoCat)
)
CREATE TABLE Telefonos (
	IdAviso int,
	Telefono varchar(50)
	primary key (idAviso,Telefono)   
    foreign key (idaviso) references Aviso(Idaviso)
    )
CREATE TABLE Comun (
	IdAviso int primary key
		Foreign key (IdAviso) references Aviso (IdAviso)
)

CREATE TABLE PalabrasClaves (
	IdAviso int, 
	PalabraClave varchar (50)
		Primary key (IdAviso, PalabraClave),
		Foreign key (IdAviso) references Comun (IdAviso)
)

CREATE TABLE Articulo (
	CodigoArt varchar(6)check(len(codigoArt)=6)primary key,
	Precio money check (Precio>=0) not null,
	Descripcion varchar (max) NOT NULL
)

CREATE TABLE Destacado (
	IdAviso int primary key
		Foreign key (IdAviso) references Aviso (IdAviso)
)


CREATE TABLE Posee (
	IdAviso int unique,
	CodigoArt varchar (6) primary key
		Foreign key (IdAviso) references Destacado (IdAviso),
		Foreign key (CodigoArt) references Articulo (CodigoArt) 
)
-------------------------------------------------------------------------------------
USE Periodico
GO
INSERT INTO CATEGORIA

	(codigocat,Nombre)
values
	(111,'Vehiculos'),
	(222,'juguetes'),
	(333,'Informatica'),
	(444,'Jardineria'),
	(555,'Herramientas'),
	(666,'Alimentos'),
	(777,'Ropa'),
	(888,'Mascotas'),
	(999,'Muebles'),
	(112,'Vivienda')

INSERT INTO Articulo
	(CodigoArt ,Precio, Descripcion)
values
	('artic1',1500,'celular economico'),
	('artic2',3600,'juego de mesa'),
	('artic3',487,'Barra de chocolate'),
	('artic4',15,'Llaver'),
	('artic5',9000,'Celular alta gama'),
	('artic6',5888,' lavarropa'),
	('artic7',23567,'Moto de 4000cc ')
	


INSERT INTO Aviso (FechaPublicacion, PrecioBase, CodigoCat)
VALUES 
	('1/10/2021',300, 111),
	('1/05/2022',500, 333),
	('05/10/2022',1500, 444),
	('06/06/2021',3000, 999),
	('04/04/2022',200, 222),
	('08/08/2021',150, 111),
	('09/09/2021', 560, 444),
	('07/07/2021',600, 555),
	('1/11/2022', 700, 888),
	('1/12/2023', 2000, 999),
	('1/05/2022',500, 666),
	('1/07/2021', 600, 777)

INSERT INTO Comun (IdAviso)
VALUES 
	(1),
	(3),
	(5),
	(7)
INSERt INTO DESTACADO
	(Idaviso)
values
	(2),
	(4),
	(6),
	(8),
	(10),
	(12)
INSERT INTO POSEE
	(IdAVISO,Codigoart)
values
	(2,'artic1'),
	(6,'artic2'),
	(8,'artic3'),
	(12,'artic4'),
	(4,'artic5'),
	(10,'artic7')
	
INSERT INTO TELEFONOS
	(IdAviso,Telefono)
VALUES 
	(1,'095579836'),
	(2,'093579877'),
	(4,'092579123'),
	(8,'091579567'),
	(9,'099579654'),
	(10,'099579775'),
	(11,'098579234')
INSERT INTO PalabrasClaves
VALUES 
	(1,'USADO'),
	(3,'POCOS KM'),
	(5,'NUEVO'),
	(7,'ELECTRICO')
---------------------------------------------------------------------------------
USE Periodico
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='SP_Agregar_Destacado')
	DROP proc SP_Agregar_Destacado
	go
CREATE PROC SP_Agregar_Destacado 
			@CodigoCat varchar(3), @FechaPublicacion smalldatetime, @PrecioBase money,
			@Telefono varchar(50), @CodigoArt varchar(6),@precio money, @descripcion varchar(max)
AS

	IF NOT EXISTS (SELECT * FROM Categoria WHERE CodigoCat = @codigoCat)
	BEGIN
		PRINT 'El codigo de la categoria no existe'
		RETURN -1
	END
	IF EXISTS (SELECT * FROM Articulo WHERE CodigoArt = @CodigoArt)
	BEGIN
		PRINT 'El codigo del articulo ya existe'
		RETURN -2
	END
	IF (@FechaPublicacion < GETDATE())
	BEGIN
		PRINT 'La fecha y hora de publicacion debe ser mayor a la actual'
		RETURN -3
	END
	IF (@PrecioBase < 0)
	BEGIN
		PRINT 'El precio base debe ser mayor o igual a 0'
		RETURN -4
	END
	IF (@precio < 0)
	BEGIN
		PRINT 'El precio del articulo debe ser mayor o igual a 0'
		RETURN -5
	END
	BEGIN TRY
		DECLARE @IDNUEVO INT
		BEGIN TRAN
			INSERT INTO Articulo (CodigoArt,Precio,Descripcion)
				VALUES (@CodigoArt,@precio,@descripcion)
			INSERT INTO Aviso (FechaPublicacion,PrecioBase,CodigoCat)
				VALUES (@FechaPublicacion,@PrecioBase,@CodigoCat)
				SET @IDNUEVO = @@IDENTITY
			INSERT INTO TELEFONOS (IdAviso,Telefono)
				VALUES (@IDNUEVO,@Telefono)
			INSERT INTO Destacado (IdAviso)
				VALUES (@IDNUEVO)
			INSERT INTO Posee (IdAviso,CodigoArt)
				VALUES (@IDNUEVO,@CodigoArt)
		COMMIT TRAN
		RETURN @IDNUEVO
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
		RETURN @@ERROR
	END CATCH
GO

DECLARE @R INT
EXEC @R = SP_Agregar_Destacado 111, '05-10-2024 22:00:00', 12,'23045309','NICO53', 12,'FORD FIESTA 1.6'
SELECT @R
PRINT @R
-------------------------------------------------------------------------------------------------------------

USE Periodico
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='SP_Cant_Aviso_Por_Rango')
	DROP proc SP_Cant_Aviso_Por_Rango
GO

CREATE PROC SP_Cant_Aviso_Por_Rango @FECHA1 DATE, @FECHA2 DATE
AS
	BEGIN TRY
	IF (@FECHA1 <@FECHA2)
	BEGIN 
		SELECT COUNT(*)'cantidad de avisos en ese rango' 
		FROM Aviso
		WHERE FechaPublicacion BETWEEN @FECHA1 AND @FECHA2
	END
	IF (@FECHA2 <@FECHA1)
	BEGIN 
		SELECT COUNT(*)'cantidad de avisos en ese rango' 
		FROM Aviso
		WHERE FechaPublicacion BETWEEN @FECHA2 AND @FECHA1
	END
	END TRY
	BEGIN CATCH
	PRINT 'ERROR DE FECHA'
	RETURN @@ERROR
	END CATCH
GO

DECLARE @R INT	
EXEC @R = SP_Cant_Aviso_Por_Rango '10-10-2021','10-10-2022'
SELECT @R
--------------------------------------------------------------------------------------------------------------

USE Periodico
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='sp_Cantidad_Aviso')
	DROP proc sp_Cantidad_Aviso
GO
CREATE PROC sp_Cantidad_Aviso
AS

	SELECT  AVISO.CodigoCat 'CODIGO DE CATEGORIA', Nombre 'NOMBRE DE LA CATEGORIA',COUNT(*)'CANTIDAD DE AVISOS'
	 FROM Categoria
	 INNER JOIN Aviso ON Categoria.CodigoCat = Aviso.CodigoCat
	 GROUP BY Aviso.CodigoCat, Nombre
GO	 
	 
EXEC sp_Cantidad_Aviso
----------------------------------------------------------------------------------------------------------------------------

USE Periodico
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='SP_Eliminar_Aviso')
	DROP proc SP_Eliminar_Aviso
GO
CREATE PROC SP_Eliminar_Aviso
			@idaviso INT
AS
	
		IF NOT EXISTS (SELECT * FROM Aviso WHERE Idaviso = @IdAviso)
			BEGIN 
				PRINT 'NO EXISTE EL AVISO'
				RETURN -1
			END
			BEGIN TRY
			BEGIN TRANSACTION
		IF EXISTS (SELECT * FROM Posee WHERE IdAviso = @idaviso)
		BEGIN
		
				DECLARE @ART varchar(6)
					SELECT @ART = CodigoArt FROM Posee WHERE IdAviso = @idaviso
				DELETE Posee WHERE IdAviso = @idAviso
				DELETE Articulo WHERE CodigoArt = @ART
				DELETE Destacado WHERE IdAviso = @IdAviso
				DELETE TELEFONOS WHERE IdAviso =@idaviso
				DELETE Aviso WHERE IdAviso =@IdAviso
					
		END
		ELSE IF exists (select * from Comun where IdAviso = @idaviso)
		BEGIN
				DELETE PalabrasClaves WHERE IdAviso = @idaviso
				DELETE Comun WHERE IdAviso = @idaviso
				DELETE TELEFONOS WHERE IdAviso =@idaviso
				DELETE Aviso WHERE IdAviso =@idaviso
					
		END
		COMMIT TRAN
		RETURN 1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RETURN -2
	END CATCH
GO
	
declare @r int
exec @r=  SP_Eliminar_Aviso 1
SELECT @r
PRINT @r
---------------------------------------------------------------------------------------------------------------

USE Periodico
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='SP_Monto_Total_Por_Fecha')
	DROP proc SP_Monto_Total_Por_Fecha
GO
CREATE PROC SP_Monto_Total_Por_Fecha
AS
	SELECT SUM(precioBase)'Monto', fechaPublicacion 'fecha' 
	FROM Aviso
	GROUP BY FechaPublicacion 
GO

EXEC SP_Monto_Total_Por_Fecha



