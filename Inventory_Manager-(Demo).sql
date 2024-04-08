
--CREANDO BASE DE DATOS--
create database BD_YIM
go
--BORRAR BASE DE DATOS--
/*use master 
drop database BD_YIM
go*/
--usar BD--
use BD_YIM 
GO
--creando tabla vendedores--
create table vendedores
(
nombre varchar(50),
apellido varchar(50),
numero_celular int,
ID_compania varchar(50) not null,
ID_vendedor varchar(11) not null,
CONSTRAINT PK_vendedores PRIMARY KEY (ID_vendedor),
CONSTRAINT UC_vendedores UNIQUE (numero_celular,ID_vendedor)

);

create table distribuidora
(
telefono int,
nombre varchar(50),
ID_compania varchar(50) not null,
CONSTRAINT UC_distribuidora UNIQUE (ID_compania,telefono),
);
--creando llaver primaria usando ALTER TABLE de la tabla distribuidora--
ALTER TABLE distribuidora 
ADD CONSTRAINT PK_distribuidora PRIMARY KEY (ID_compania)

--creando foreign key usando ALTER TABLE de la tabla vendedores-distribuidora--
ALTER TABLE vendedores 
ADD CONSTRAINT FK_distribuidora FOREIGN KEY (ID_compania)
REFERENCES distribuidora(ID_compania);

--creando tabla productos  " ejecutar el alter table al final antes de correr esta tabla, el que dice primary key"--
create table productos
(
ID_producto varchar(15) not null,
ID_marca varchar(11),
ID_presentacion varchar(50),
ID_compania varchar(50),
precio money ,
stock int ,
peso float default 1,
ID_categoria varchar(11),
--constraints--
CONSTRAINT PK_productos PRIMARY KEY (ID_producto),
CONSTRAINT UC_productos UNIQUE (ID_producto,ID_compania),
CONSTRAINT CH_productos CHECK(precio<>0 AND peso <> 0),
CONSTRAINT FK_productos FOREIGN KEY(ID_compania)
REFERENCES distribuidora(ID_compania)
)

create table ordenes
(
ID_orden varchar(11) not null,
ID_producto varchar(15),
Fecha_orden date default GETDATE(),

CONSTRAINT PK_ID_orden PRIMARY KEY (ID_orden)
)

--creando foreign key usando ALTER TABLE de la tabla ordenes a tabla producto--
 alter table ordenes
 ADD CONSTRAINT FK_productos_ordenes FOREIGN KEY(ID_producto)
 REFERENCES productos(ID_producto)

--creando tabla orden-detalles--
create table detalles_orden
(
ID_detalles varchar(11) not null,
ID_orden varchar(11),
cantidad int default 1,
precio_unitario money,
precio_total money,
descuento float,
ID_empleado varchar(11),
--constraints--
CONSTRAINT CH_detalles_orden CHECK(cantidad<>0 and precio_unitario <>0 and precio_total<>0),
CONSTRAINT U_detalles_orden UNIQUE(ID_orden),
CONSTRAINT PK_detalles_orden PRIMARY KEY(ID_Detalles),
)
--luego ejecutar la foreign key detalles_ordenes_ordenes--
 --creando foreign key de la tabla detalles orden- ordenes--
 alter table detalles_orden
 ADD CONSTRAINT FK_DETALLESORD_ORDENES FOREIGN KEY(ID_orden)
 REFERENCES ordenes(ID_orden)

create table empleados
(
nombre varchar(50),
apellido varchar(50),
telefono int,
cedula varchar(15),
ID_empleado varchar(11) not null
CONSTRAINT PK_empleados PRIMARY KEY(ID_empleado),
CONSTRAINT U_empleados UNIQUE(cedula,telefono,ID_empleado)
)
--'luego ejecutar la foreing key de detalles orden a empleados'--

 --creando foreign key de la tabla detalles orden a empleados--
 ALTER TABLE detalles_orden
 ADD CONSTRAINT FK_detallesorden_empleados FOREIGN KEY(ID_empleado)
 REFERENCES empleados(ID_empleado)


create table categorias
(
ID_Categoria varchar(11) not null default 0000,

Nombre_categoria varchar(50),
Descripcion_categoria varchar(100)
CONSTRAINT PK_categoria PRIMARY KEY(ID_categoria),
CONSTRAINT U_categorias UNIQUE(ID_categoria)
)
--'ejecutar el foreign key de la tabla productos a categorias'--

 --creando foreing key de la tabla productos a categoria--
 ALTER TABLE productos
 ADD CONSTRAINT FK_PRODUCTOS_CATEGORIAS FOREIGN KEY (ID_categoria)
 REFERENCES categorias(ID_categoria)

 ------------Tablas Auditorias de Producto y Ordenes para la utilizacion de TRIGGERS-----------------
 create table auditproductos
(
ID_producto varchar(15) not null,
ID_marca varchar(11),
ID_presentacion varchar(50),
ID_compania varchar(50),
precio money ,
stock int ,
peso float default 1,
ID_categoria varchar(11),
Tipo_de_modificacion varchar(20),
Fecha_de_modificacion datetime
);

create table auditordenes
(
ID_orden varchar(11) not null,
ID_producto varchar(15),
Fecha_orden date,
Tipo_de_modificacion varchar(20),
Fecha_de_modificacion datetime
);
go
--Creacion de Triggers sobre la tabla producto--
--Trigger Delete

CREATE TRIGGER trProductos_Delete 
ON productos
AFTER DELETE
AS
     BEGIN
         INSERT INTO auditproductos
                SELECT *,  
                       'Deleted',
					   GETDATE()
                FROM deleted;
     END;
	 GO
--Trigger Update
CREATE TRIGGER trProductos_Update 
ON productos
AFTER UPDATE
AS
     BEGIN
         INSERT INTO auditproductos
                SELECT *, 
                       'Previo Update',
					   GETDATE()
                FROM deleted;
         INSERT INTO auditproductos
                SELECT *, 
                       'Despues de Update',
					    GETDATE()
                FROM inserted;
     END;
	 GO
--Trigger Insert
CREATE TRIGGER trProductos_Insert
 ON productos
AFTER INSERT
AS
     BEGIN
         INSERT INTO auditproductos
                SELECT *,  
                       'Inserted',
					   GETDATE()
                FROM inserted;
     END;
GO
--Creacion de Triggers sobre la tabla Ordenes
--Trigger Delete

CREATE TRIGGER trOrdenes_Delete 
ON ordenes
AFTER DELETE
AS
     BEGIN
         INSERT INTO auditordenes
                SELECT *,  
                       'Deleted',
					   GETDATE()
                FROM deleted;
     END;
	 GO
--Trigger Update
CREATE TRIGGER trOrdenes_Update 
ON ordenes
AFTER UPDATE
AS
     BEGIN
         INSERT INTO auditordenes
                SELECT *, 
                       'Previo Update',
					   GETDATE()
                FROM deleted;
         INSERT INTO auditordenes
                SELECT *, 
                       'Despues de Update',
					    GETDATE()
                FROM inserted;
     END;
	 GO
--Trigger Insert
CREATE TRIGGER trOrdenes_Insert
 ON ordenes
AFTER INSERT
AS
     BEGIN
         INSERT INTO auditordenes
                SELECT *,  
                       'Inserted',
					   GETDATE()
                FROM inserted;
     END;
GO

/*Creacion de procedimientos almacenados*/
/*1. Procedimientos almacenados para ingresar datos en cada una de la tablas:*/
/*1.1 Creacion de Proc Alm para ingresar datos en tabla productos*/
Use BD_YIM 
Go

Create Procedure SP_InsertProduct
@idproducto Varchar(15),
@idmarca Varchar(11),
@idpresentacion Varchar(50),
@idcompania Varchar(50),
@precio Money,
@stock Int,
@peso Float,
@idcategory Varchar(11)
As
Begin
	Insert Into productos
		(ID_producto,ID_marca,ID_presentacion,ID_compania,precio,stock,peso,ID_categoria)
	Values
		(@idproducto,@idmarca,@idpresentacion,@idcompania,@precio,@stock,@peso,@idcategory)
	Print 'Producto ingresado exitosamente'
End

/*1.2 Creacion de Proc Alm para ingresar datos en tabla ordenes*/

Create Procedure SP_InsertOrden
@idorden varchar(11),
@idproducto varchar(15),
@fechaorden datetime
As
Begin
	Insert Into ordenes
		(ID_orden,ID_producto,Fecha_orden)
	Values
		(@idorden,@idproducto,@fechaorden)
	Print 'Orden insertada exitosamente'
End

/*1.3 Creacion de proc alm para ingresar datos a la tabla detalles_orden*/
Create Procedure SP_InsertDetallesO
@iddetalles varchar(11),
@idorden varchar(11),
@cantidad int,
@precioU money,
@preciotot money,
@descuento float,
@idempleado varchar(11)
As
Begin
	Insert into detalles_orden
		(ID_detalles,ID_orden,cantidad,precio_unitario,precio_total,descuento,ID_empleado)
	Values
		(@iddetalles,@idorden,@cantidad,@precioU,@preciotot,@descuento,@idempleado)
	Print 'Ordenes detalladas'
End

/*1.4 Creacion de proc almacenado para ingresar datos en la tabla empleados*/
Create Procedure SP_InsertEmpleados
@nombre varchar(50),
@apellido varchar(50),
@telefono int,
@cedula varchar(15),
@idempleado varchar(11)
As
Begin
	Insert Into empleados 
		(nombre,apellido,telefono,cedula,ID_empleado)
	Values
		(@nombre,@apellido,@telefono,@cedula,@idempleado)
	Print 'Empleado insertado'
End

/*1.5 Creacion de Proc Alm para ingresar datos en categoria*/
Create Procedure SP_InsertCategory
@idcategoria varchar(11),
@nombre_categ varchar(50),
@descrip_categ varchar(100)
As 
Begin
	Insert Into categorias
		(ID_Categoria,Nombre_categoria,Descripcion_categoria)
	Values
		(@idcategoria,@nombre_categ,@descrip_categ)
	Print 'Categoria insertada!'
End

/*1.6 Creacion de Proc Alm para ingesar datos en distribuidora*/
Create Procedure SP_InsertDistribuidora
@telefono int,
@nombre varchar(50),
@idcompania varchar(50)
As
Begin
	Insert Into distribuidora 
		(telefono,nombre,ID_compania)
	Values
		(@telefono,@nombre,@idcompania)
End

/*1.7 Creacion de ProcAlm para ingresar datos en vendedores*/
Create Procedure SP_InsertVendedores
@nombre varchar(50),
@apellido varchar(50),
@celular int,
@idcompania varchar(50),
@idvendedor varchar(11)
As
Begin
	Insert Into vendedores
		(nombre,apellido,numero_celular,ID_compania,ID_vendedor)
	Values
		(@nombre,@apellido,@celular,@idcompania,@idvendedor)
End

/*Punto 2 de los procedimientos almacenados:
Proc Alm para realizar actualizacion de campos en cada tabla*/
/*2.1 Proc Alm para actualizar campos en productos:*/
Create Procedure SP_ActProduct
@idproducto Varchar(15),
@idmarca Varchar(11),
@idpresentacion Varchar(50),
@idcompania Varchar(50),
@precio Money,
@stock Int,
@peso Float,
@idcategory Varchar(11)
As
Begin
	Update  productos 
	SET 
		ID_producto = @idproducto,
		ID_marca = @idmarca,
		ID_presentacion = @idpresentacion,
		ID_compania = @idcompania,
		precio = @precio,
		stock = @stock,
		peso = @peso,
		ID_categoria = @idcategory
	Where ID_producto = @idproducto
	Print 'Producto actualizado exitosamente'
End

/*2.2 Proc Alm para actualizar campos en ordenes*/
Create Procedure SP_ActOrden
@idorden varchar(11),
@idproducto varchar(11),
@fechaorden datetime
As
Begin
	Update ordenes
	Set
		ID_orden = @idorden,
		ID_producto = @idproducto,
		Fecha_orden = @fechaorden
	Where ID_orden = @idorden
	Print 'Orden actualizada exitosamente'
End

/*2.3 Proc Alm para actualizar los detalles de la orden*/
Create Procedure SP_ActDetallesO
@iddetalles varchar(11),
@idorden varchar(11),
@cantidad int,
@precioU money,
@preciotot money,
@descuento float,
@idempleado varchar(11)
As
Begin
	Update detalles_orden
	SET
		ID_detalles = @iddetalles,
		ID_orden = @iddetalles,
		cantidad = @cantidad,
		precio_unitario = @precioU,
		precio_total = @preciotot,
		descuento = @descuento,
		ID_empleado = @idempleado
	Where ID_detalles = @iddetalles
	Print 'Detalles actualizados'
End

/*2.4 Proc Alm para actualizar los campos de empleados*/
Create Procedure SP_ActEmpleados
@nombre varchar(50),
@apellido varchar(50),
@telefono int,
@cedula varchar(15),
@idempleado varchar(11)
As
Begin
	Update empleados
	Set
		nombre = @nombre,
		apellido = @apellido,
		telefono = @telefono,
		cedula = @cedula,
		ID_empleado = @idempleado
	Where ID_empleado = @idempleado
	Print 'Empleado actualizado'
End

/*2.5 Proc Alm para actualizar los campos de categorias*/
Create Procedure SP_ActCategory
@idcategoria varchar(11),
@nombre_categ varchar(50),
@descrip_categ varchar(100)
As 
Begin
	Update categorias
	Set
		ID_Categoria = @idcategoria,
		Nombre_categoria = @nombre_categ,
		Descripcion_categoria = @descrip_categ
	Where ID_Categoria = @idcategoria
	Print 'Categoria actualizda!'
End

/*2.6 Proc Alm para actualizar los campos de la distribuidora*/
Create Procedure SP_ActDistribuidora
@telefono int,
@nombre varchar(50),
@idcompania varchar(50)
As
Begin
	Update distribuidora
	Set 
		telefono = @telefono,
		nombre = @nombre,
		ID_compania = @idcompania
	Where ID_compania = @idcompania
End

/*2.7 Proc Alm para actualizar los campos de vendedores*/
Create Procedure SP_ActVendedores
@nombre varchar(50),
@apellido varchar(50),
@celular int,
@idcompania varchar(50),
@idvendedor varchar(11)
As
Begin
	Update vendedores 
	Set
		nombre = @nombre,
		apellido = @apellido,
		numero_celular = @celular,
		ID_compania = @idcompania,
		ID_vendedor = @idvendedor
	Where ID_vendedor = @idvendedor
	Print 'Vendedor actualizado'
End

/*Punto 3 de los procedimientos almacenados:
Proc Alm para borrar una fila o registro por su PK, en cada tabla*/
/*3.1 Delete en productos*/
Create Procedure SP_BorraProductos
@idproduct varchar(15)
As 
Begin
	Delete from productos 
	Where ID_producto = @idproduct
End

/*3.2 Delete en Orden*/
Create Procedure SP_BorraOrdenes
@idorden varchar(11)
As 
Begin
	Delete from ordenes 
	Where ID_orden = @idorden
End

/*3.3 Delete en Detalles de Orden*/
Create Procedure SP_BorraDetalles
@iddetalle varchar(11)
As 
Begin
	Delete from detalles_orden 
	Where ID_detalles = @iddetalle
End

/*3.4 Delete en Empleados*/
Create Procedure SP_BorraEmpleados
@idEmpleado varchar(11)
As 
Begin
	Delete from empleados 
	Where ID_empleado = @idEmpleado
End

/*3.5 delete en distribuidora*/
Create Procedure SP_BorraDistribuidora
@idcompany varchar(50)
As 
Begin
	Delete from distribuidora 
	Where ID_compania = @idcompany
End

/*3.6 delete en vendedores*/
Create Procedure SP_BorraVendedores
@idvendedor varchar(11)
As 
Begin
	Delete from vendedores 
	Where ID_vendedor = @idvendedor
End

/*3.7 delete en categoria*/
Create Procedure SP_BorraCategory
@idcategory varchar(11)
As 
Begin
	Delete from categorias
	Where ID_Categoria = @idcategory
End

/*Punto 4 de los procedimientos almacenados
Realizar busca de un registro a traves de la PK*/
/*4.1 busqueda con pk en productos*/
Create Procedure SP_BuscaProducto
@idproduct varchar(15)
As 
Begin
	Select * from productos 
	where ID_producto = @idproduct
End

/*4.2 busqueda con pk en ordenes*/
Create Procedure SP_BuscaOrden
@idorden varchar(11)
As 
Begin
	Select * from ordenes 
	Where ID_orden = @idorden
End

/*4.3 busqueda con pk en detalles*/
Create Procedure SP_BuscaDetalles
@iddetalle varchar(11)
As 
Begin
	Select * from detalles_orden 
	Where ID_detalles = @iddetalle
End

/*4.4 busqueda con pk en empleados*/
Create procedure SP_BuscaEmpleado
@idEmpleado varchar(11)
As 
Begin
	Select * from empleados 
	Where ID_empleado = @idEmpleado
End

/*4.5 busqueda con pk en categoria**/
Create Procedure SP_BuscaCategory
@idcategory varchar(11)
As 
Begin
	Select * from categorias
	Where ID_Categoria = @idcategory
End

/*4.6 busqueda con pk en distribuidora*/
Create  Procedure SP_BuscaDistribuidora
@idcompany varchar(50)
As 
Begin
	Select * from distribuidora 
	Where ID_compania = @idcompany
End

/*4.7 busqueda con pk en vendedores*/
Create Procedure SP_BuscaVendedores
@idvendedor varchar(11)
As 
Begin
	Select * from vendedores 
	Where ID_vendedor = @idvendedor
End

/*Punto 5 de los procedimientos almacenados:
Proc Alm que devuelva todos los registros en cada tabla*/
/*5.1 Motrar todos los registros de productos*/
Create Procedure SP_TodoProducto
As
Begin 
	Select * from productos
End

/*5.2 Mostrar todos los registros de ordenes*/
Create Procedure SP_Todo_Ordenes
As
Begin 
	Select * from ordenes
End

/*5.3 Mostrar todos los registros de los detalles de la orden*/
Create Procedure SP_Todo_Detalles
As
Begin 
	Select * from detalles_orden
End

/*5.4 Mostrar todos los registros de la tabla empleados*/
Create Procedure SP_Todo_Empleados
As
Begin 
	Select * from empleados
End

/*5.5 Mostrar todos los registors de la tabla categoria:*/
Create Procedure SP_Todo_Categoria
AS
Begin 
	Select * from categorias
End

/*5.6 Mostrar todos los registros de la tabla distribuidora*/
Create Procedure SP_Todo_Distribuidora
As
Begin 
	Select * from distribuidora
End

/*5.7 Mostrar todos los registros de la tabla vendedores*/
Create Procedure SP_Todo_Vendedores
As
Begin 
	Select * from vendedores
End

-- Inserts --

--Insert tabla empleados--
USE [BD_YIM]
GO

INSERT INTO [dbo].[empleados]
           ([nombre]
           ,[apellido]
           ,[telefono]
           ,[cedula]
           ,[ID_empleado])
     VALUES
           ('Federico','Yau',2693651,'8-908-1234','Ec-01'),
		   ('Alejandro','Young',2673623,'8-906-1248','Ec-02'),
		   ('Jenny','Yang',6674613,'8-960-1648','Ec-03'),
		   ('Enrique','Zheng',6773543,'8-9076-1748','Ec-04');
GO

--Insert tabla distribuidora--
USE [BD_YIM]
GO

INSERT INTO [dbo].[distribuidora]
           ([telefono]
           ,[nombre]
           ,[ID_compania])
     VALUES
           (3031550,'Dicarina','dicar-507'),
		   (3044444,'Feduro','fedur-507'),
		   (2301600,'HieloFiesta','Hielo-507'),
		   (3056000,'Cerveceria Nacional','CN-507'),
		   (3049100,'Heineken Panama','HN-507');
GO

--Insert tabla vendedores--
USE [BD_YIM]
GO

INSERT INTO [dbo].[vendedores]
           ([nombre]
           ,[apellido]
           ,[numero_celular]
           ,[ID_compania]
           ,[ID_vendedor])
     VALUES
           ('Liz','Angelica',7201261,'dicar-507','Di_Ve01'),
		   ('Alphonso','Piers',69303762,'fedur-507','Fe_Ve05'),
		   ('Muriel','Isabela',2330192,'Hielo-507','Hf_Ve10'),
		   ('Adolfo','Gloria',2618812,'CN-507','CN-Ve06'),
		   ('Danilo','Frona',2101101,'HN-507','HN_Ve08');
GO

--Insert categorias--
USE [BD_YIM]
GO

INSERT INTO [dbo].[categorias]
           ([ID_Categoria]
           ,[Nombre_categoria]
           ,[Descripcion_categoria])
     VALUES
           ('SN_01','Snacks','Categoria dedicada a los diferentes tipos de snacks salados.'),
		   ('Lc_01','Lacteos_Bonlac','Categoria dedicada a los lacteos de Bonlac '),
		   ('EstAz_01','Lacteos_EstrellaAzul','Categoria dedicada a los lacteos de Estrella Azul '),
		   ('Leg_02','legumbres','Categoria para legumbres '),
		   ('En_01','Enlatados','Comidas enlatadas como Tuna y sardinas'),
		   ('Cui_01','Higiene','Categoria productos de cuidado personal'),
		   ('Cer_10','Cervezas','Categoria dedicada a bedidas alcholicas '),
		   ('Alc_02','Alchol','Categoria dedicada a bedidas alcholicas como el seco.');
GO

--Insert Productos--Peso solo necesario para productos como carnes--
USE [BD_YIM]
GO

INSERT INTO [dbo].[productos]
           ([ID_producto]
           ,[ID_marca]
           ,[ID_presentacion]
           ,[ID_compania]
           ,[precio]
           ,[stock]
           ,[peso]
           ,[ID_categoria])
     VALUES
           ('8992760221028','Oreo_01','Oreo_familypack','fedur-507',3.67,40,0.1,'SN_01'),
		   ('751752100332','Panama_lig','Sixpack_Panamalight_lata','HN-507',4.50,40,0.1,'Cer_10'),
		   ('7501017004416','la costeña','Frijoles_enteros_bayos','dicar-507',1.07,40,0.1,'En_01'),
		   ('7451015604159','Amapola','lenteja_amapola_454g','dicar-507',0.98,40,0.1,'Leg_02'),
		   ('52577010791','Pascual','Galleta_Saltines_Pascual_181g','dicar-507',1.15,30,0.1,'SN_01');
GO
USE [BD_YIM]
GO

INSERT INTO [dbo].[ordenes]
           ([ID_orden]
           ,[ID_producto]
           ,[Fecha_orden])
     VALUES
           ('Wed_001','751752100332','2021-12-08'),
		   ('Wed_002','7501017004416','2021-12-08'),
		   ('Wed_003','52577010791','2021-12-08'),
		   ('Wed_004','7451015604159','2021-12-08');


GO

USE [BD_YIM]
GO

INSERT INTO [dbo].[detalles_orden]
           ([ID_detalles]
           ,[ID_orden]
           ,[cantidad]
           ,[precio_unitario]
           ,[precio_total]
           ,[descuento]
           ,[ID_empleado])
     VALUES
           ('Ord_001','Wed_001',40,3.50,140,10.0,'Ec-01'),
		   ('Ord_002','Wed_002',30,0.96,28.80,0.0,'Ec-02'),
		   ('Ord_003','Wed_003',15,0.95,14.25,0.0,'Ec-03'),
		   ('Ord_004','Wed_004',20,0.85,17.00,0.0,'Ec-01');
GO


--procedimientos almacenados importantes Que tengan sentido para la empreza --

-- procedimiento para ver de que empresa es cada vendedor--

Create Procedure SP_Consulta_informacion
As
Begin 
	Select distribuidora.nombre, vendedores.nombre,vendedores.apellido,vendedores.numero_celular
	from [dbo].[distribuidora]
	inner join vendedores on distribuidora.ID_compania= vendedores.ID_compania
End

-- procedimiento para consultar toda la informacion referente a una sola distribuidora--


Create Procedure SP_Consulta_dicarina --Procedimento almacenado para toda la informacion relacionada a una distribuidora en especifico--

As
Begin 
	Select distribuidora.nombre,distribuidora.telefono,vendedores.nombre,vendedores.apellido,vendedores.numero_celular
	from [dbo].[distribuidora]
	inner join vendedores on distribuidora.ID_compania= vendedores.ID_compania
	where distribuidora.nombre= 'Dicarina'
End


--Comando para consultar todas las ordenes del dia de actual por medio de getdate--
Create Procedure Sp_Ordenes_Del_dia 

As
Begin
select  ordenes.[Fecha_orden],productos.ID_presentacion,detalles_orden.[cantidad],detalles_orden.[precio_unitario],detalles_orden.precio_total,detalles_orden.descuento
From [dbo].[ordenes]
inner join [dbo].[detalles_orden] on ordenes.ID_orden= detalles_orden.ID_orden

inner join [dbo].[productos]  on ordenes.ID_producto=productos.ID_producto
 
where  ordenes.Fecha_orden=  convert(date,GETDATE())

end





-- Comando para consultar de que distribuidora viene el producto--
Create procedure Sp_Origen_del_producto
As
Begin 
select productos.ID_presentacion,distribuidora.nombre
From [dbo].[productos]
inner join [dbo].[distribuidora] on productos.ID_compania=distribuidora.ID_compania
end



--comando para ver que empleado realizo la que orden 
Create procedure Sp_pedidos
As 
Begin 
select [dbo].[detalles_orden].[ID_orden],[dbo].[empleados].[apellido],[dbo].[empleados].[nombre]
From [dbo].[detalles_orden]
Inner join [dbo].[empleados] on empleados.ID_empleado=detalles_orden.ID_empleado
End


--comando para ver cuales son los productos con menos stock--
create procedure Sp_stock_restante
As 
Begin
Select [ID_presentacion],[stock],[ID_producto]
from [dbo].[productos]
order by [stock] Asc
end
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------



--FUNCIONES--
/* Funcion que cuando insertas el id del vendedor te aparezca el nombre completo de este*/
Create Function NombreCompleto(@ID_vendedor varchar(11)) returns varchar(50)
As
Begin
Declare @Nombrecomplet varchar(50)
select @Nombrecomplet = (nombre +','+ apellido) FROM vendedores WHERE ID_vendedor=@ID_vendedor
return @Nombrecomplet
End

Select ID_vendedor as ID_Vendedor, dbo.NombreCompleto('HN_Ve08') as Nombre_Completo FROM vendedores WHERE ID_vendedor = 'HN_Ve08'

Drop Function NombreCompleto
Go



/* Funcion que ingresando el codigo del producto nos de el stock*/
Create Function datos_producto	(@ID_producto varchar(15)) returns varchar(15)
As
Begin
Declare @elstock int
select @elstock = stock FROM productos WHERE ID_producto = @ID_producto
return @elstock
End

Select ID_producto as ID_Producto, dbo.datos_producto('8992760221028') as Stock_Producto FROM productos WHERE ID_producto = '8992760221028'

Drop Function datos_producto
Go


/* Funcion	que devuelva el nombre de la distribuidora*/	
 create function DEVUELVENOMBRE
 (@nombre varchar(11))
 returns table
 as
 return (
  select *
  from distribuidora
  where nombre = @nombre
 );

 select * From dbo.DEVUELVENOMBRE('Feduro')

 Drop Function DEVUELVENOMBRE 
 GO


 /* Funcion que tire ID_producto, ID_marca, ID_presentación, precio dependiendo y el stock si hay productos en stock */

  create function datos_de_stock
 (@minimo int)
 returns @productos table-- nombre de la tabla
 --formato de la tabla
 (ID_producto varchar(15),
  ID_marca varchar(11),
  ID_presentacion varchar(50),
  precio money,
  stock int
 )
 as
 begin
   insert @productos
    select ID_producto,ID_marca,ID_presentacion,precio,stock
    from productos
    where stock > @minimo
   return
 end;

 select *from dbo.datos_de_stock(0)

 Drop Function datos_de_stock
 Go


 /* Funcion que nos de precio total incluyendo el itbms */

Create Function PrecioT_ITBMS (@precio_total Float)
Returns Float
As
Begin
Declare @PrecioCon7 Float
Set @PrecioCon7 = @precio_total * 0.07
Return @PrecioCon7
End

Select precio_total, dbo.PrecioT_ITBMS (precio_total) As Valor_Total_ITBMS From detalles_orden
-------------------------------------------------------------------------------------------------------------
--Vistas---
--Creacion de vistas para cada tabla
--Vendedores
Create View ReportVendedors As
Select dbo.NombreCompleto(ID_vendedor) as Nombre_Completo,ID_vendedor as ID, numero_celular as Celular, D.nombre as Compañia from Vendedores V
inner join distribuidora D on V.ID_compania = D.ID_compania
go
Select * from ReportVendedors order by Nombre_Completo
go
--Distribuidoras
Create View ReportDist As
Select nombre as Compañia, ID_compania as ID, telefono as Telefono from distribuidora
go
Select * from ReportDist order by Compañia
go
--Productos
Create View ReportProducto As
Select (Id_presentacion+', '+ID_marca) as Producto, ID_producto as ID,precio as Precio, Stock as Cantidad, C.Nombre_Categoria as Categoria
from productos P inner join Categorias C on P.ID_categoria = C.ID_Categoria
go
Select * from ReportProducto order by Producto
Go
--Categorias
Create View ReportCategorias As
Select id_categoria as ID, nombre_categoria as Categorias,Descripcion_categoria as Descripción from categorias
go
Select * from ReportCategorias order by Categorias
Go
--Ordenes
Create View ReportOrdenes As
Select O.ID_orden as ID, (P.Id_presentacion+', '+p.ID_marca) as Producto, D.Cantidad as Cantidad,
(Precio_total - Descuento) as Precio from 
Ordenes O inner join detalles_orden D on O.ID_orden = D.ID_orden
inner join productos P on O.ID_producto = P.ID_producto
GO
Select * from ReportOrdenes order by ID
GO
--Empleados
Create View ReportEmpleados As
Select Nombre+' '+Apellido as Nombre_Completo,ID_Empleado as ID, Cedula as Cedula,telefono as Telefono from Empleados
go
Select * from ReportEmpleados
-----------------------------------------------------------------------------------------------------------------

/*CONSULTAS*/
--1 consulta para ver de que empresa es cada vendedor--
exec SP_Consulta_informacion
--2 consulta almacenado para toda la informacion relacionada a una distribuidora en especifico--
exec SP_Consulta_dicarina
--3 consulta todas las ordenes del dia de actual por medio de getdate--
Exec Sp_Ordenes_Del_dia
--4 consultar de que distribuidora viene el producto--
Exec  Sp_Origen_del_producto
--5 Consulta quien hizo el pedido del producto--
Exec Sp_pedidos
--6 consulta para ver cuales son los productos con menos stock--
Exec Sp_stock_restante
--7 consulta todos los productos
Exec SP_TodoProducto
--8 consulta todas las ordenes
Exec  SP_Todo_Ordenes
--9 Consulta todos los detalles
Exec SP_Todo_Detalles
--10 Consulta todos empleados
Exec SP_Todo_Empleados
--11 Consulta todas las categorias
Exec SP_Todo_Categoria
--12 consulta todas las distribuidoras
Exec SP_Todo_Distribuidora
--13 consulta todos los vendedores
Exec SP_Todo_Vendedores
--14 consulta precio total incluyendo el itbms
Select precio_total, dbo.PrecioT_ITBMS (precio_total) As Valor_Total_ITBMS From detalles_orden
--15 Consulta el stock especifico de un producto
Select ID_producto as ID_Producto, dbo.datos_producto('8992760221028') as Stock_Producto FROM productos WHERE ID_producto = '8992760221028'
--16 consulta una busqueda con pk de un empleado especifico*/
Exec SP_BuscaEmpleado 'Ec-03'

