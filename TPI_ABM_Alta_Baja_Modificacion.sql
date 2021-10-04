-- -----------------------------------------------------------------
-- TPI; ESTUDIO DE LOS ABM PRINCIPALES
-- se presentan los siguientes procedimientos que confirman el estudio de ABM de Alta, Baja, y Modificacion
-- Estudio de abm del tpi 2021
-- -----------------------------------------------------------------
-- TABLAS A UTILIZAR
-- AUTOMOVIL_________________________________________________________________________
-- (`Id` INT(11) NOT NULL AUTO_INCREMENT,`Chasis` VARCHAR(45),`FechaInicio` DATETIME,
--  `FechaFin` DATETIME,`Eliminado` BIT(1),`FechaEliminado` DATETIME,
--  `pedido_detalle_Id` INT(11),`pedido_detalle_modelo_Id` INT(11),PRIMARY KEY (`Id`))
-- CONCESIONARIO______________________________________________________________________
-- (`Id` INT(11) NOT NULL AUTO_INCREMENT, `Nombre` VARCHAR(45),`Eliminado` BIT(1),
-- `FechaEliminado` DATETIME,PRIMARY KEY (`Id`))
-- PEDIDO_DETALLE_____________________________________________________________________
-- (`Id` INT(11) NOT NULL AUTO_INCREMENT,`modelo_Id` INT(11),
--  `Eliminado` BIT(1),`FechaEliminado` DATETIME,
--  `pedido_Id` INT(11),`modelo_Id1` INT(11),PRIMARY KEY (`Id`, `modelo_Id`))
-- PEDIDO____________________________________________________________________________
-- (`Id` INT(11) NOT NULL AUTO_INCREMENT,`FechaDeVenta` DATETIME,
-- `FechaDeEntrega` DATETIME,`Eliminado` BIT(1),`FechaEliminado` DATETIME,
-- `consecionaria_Id` INT(11),PRIMARY KEY (`Id`),)
-- -----------------------------------------------------------------------------------------------------------------------------------
-- ALTA
-- -----------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE `AltaVehiculo`(IN modeloId INT, IN PedidoDetalleId INT)
BEGIN
DECLARE ChasisParam VARCHAR(45);
DECLARE FechaInicio datetime;
SELECT LEFT(MD5(RAND()), 8) into ChasisParam;
Insert INTO automovil VALUES	(ChasisParam,0, PedidoDetalleId, modeloId);
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `AltaConcesionario`(IN nombre VARCHAR(45))
BEGIN
insert into consecionaria(Nombre, Eliminado) VALUES(nombre, 0);
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `AltaPedidoDetalle`(IN id_pedido INT , IN Cantidad INT, IN modelo_Id INT)
BEGIN
insert into pedido_detalle VALUES(modelo_Id, modelo_Id, Cantidad, id_pedido, 0);
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `AltaPedido`(IN Id_Cons INT)
BEGIN
insert into pedido(consecionaria_Id,FechaDeVenta,Eliminado) values (Id_Cons,now(),0);
END;
-- -----------------------------------------------------------------------------------------------------------------------------------
-- BAJA(logica)
-- -----------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE `BajaAutomovil` (IN Id_Automovil INT)
BEGIN
update automovil SET
Eliminado = 1,FechaEliminado = now()
where Id = Id_Automovil;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `BajaConcesionario`(IN Id_Cons INT)
BEGIN
update consecionaria SET
Eliminado = 1,FechaEliminado = now()
where Id = Id_Cons;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `BajaPedidoDetalle`(IN ParamPedido_detalle INT)
BEGIN
DECLARE finished int default 0;
DECLARE Id_Automovil INT;
DECLARE C cursor for
select Id from automovil where pedido_detalle_Id = ParamPedido_detalle;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

update pedido_detalle SET Eliminado = 1,FechaEliminado = now()
WHERE Id = ParamPedido_detalle;

OPEN C;
delAuto: LOOP
FETCH C into Id_Automovil;

IF finished = 1 THEN 
	LEAVE delAuto;
END IF;

call delete_automovil(Id_Automovil);
END LOOP delAuto;
CLOSE C;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `BajaPedido`(IN ParamPedido INT)
BEGIN
DECLARE finished int default 0;
DECLARE Id_PedidoDetalle INT;
DECLARE C cursor for
select Id from pedido_detalle where pedido_Id = ParamPedido;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

update pedido
SET Eliminado = 1,FechaEliminado = now()
WHERE Id = ParamPedido;

OPEN C;
delDetalle: LOOP
FETCH C into Id_PedidoDetalle;

IF finished = 1 THEN 
	LEAVE delDetalle;
END IF;
call delete_PedidoDetalle(Id_PedidoDetalle);



END LOOP delDetalle;
CLOSE C;
END;
-- -----------------------------------------------------------------------------------------------------------------------------------
-- MODIFICACION
-- -----------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE `ModAutomovil`(in Nid INT(11),in`N_chasis`VARCHAR(45),in`N_fecini`DATETIME,in`N_fecfin`DATETIME)
BEGIN
update automovil SET
chasis = N_chasis,fechainicial=N_fecinifechafinal=N_fecfin
where Id = Nid;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `ModConcesionario`(in NId INT(11),in`N_Nombre` VARCHAR(45))
BEGIN
update consecionaria SET
Nombre=N_Nombre
where Id = Nid;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `ModPedidoDetalle`(in`NId`INT(11),in`Nmodelo_Id`INT(11),in`Npedido_Id`INT(11),in`Nmodelo_Id1`INT(11))
BEGIN
update pedido_detalle SET modelo=`Nmodelo_Id`,pedido_Id=`Npedido_Id`,modelo_Id1`Nmodelo_Id1`
WHERE Id = `NId`;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `ModPedido`(in`NId` INT(11),in`NFechaDeEntrega` DATETIME,in`Nconsecionaria_Id` INT(11))
BEGIN
update pedido SET FechaDeEntrega= `NFechaDeEntrega`,concesionaria_Id=`Nconsecionaria_Id`
WHERE Id = `NId`;
END;
-- -----------------------------------------------------------------------------------------------------------------------------------
-- OTROS(SEGUN ABM)
-- -----------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE `creacion_automoviles`(IN ParamIdDetalle INT)
BEGIN
DECLARE idModeloParametro INT;
DECLARE nCantidadDetalle INT;
DECLARE finished INT DEFAULT 0;
DECLARE nInsertados INT;
DECLARE curDetallePedido CURSOR
FOR SELECT modelo_Id, Cantidad_modelo FROM pedido_detalle WHERE pedido_detalle.Id = ParamIdDetalle;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'  
SET finished = 1;  
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'  
SET finished = 1; 
OPEN curDetallePedido;
FETCH curDetallePedido INTO idModeloParametro, nCantidadDetalle;
SET nInsertados = 0;
WHILE nInsertados < nCantidadDetalle DO
	call altaVehiculo(idModeloParametro, ParamIdDetalle);
	SET nInsertados = nInsertados +1;
END WHILE;
CLOSE curDetallePedido;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `creacion_Automoviles_de_Pedido`(IN ParamIdPedido INT)
BEGIN
DECLARE idDetallePedido INT;
DECLARE finished INT default 0;
DECLARE curDetallePedido CURSOR FOR
select Id FROM pedido_detalle WHERE pedido_Id = ParamIdPedido;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
OPEN curDetallePedido;
getModelo: LOOP
FETCH curDetallePedido INTO idDetallePedido;
IF finished = 1 THEN 
	LEAVE getModelo;
END IF;
call creacion_automoviles(idDetallePedido);
END LOOP getModelo;
CLOSE curDetallePedido;
END;
-- -----------------------------------------------------------------
CREATE PROCEDURE `CantConsecionarios`(IN nombreC VARCHAR(45), OUT resultado INT)
BEGIN
declare valor int;
DECLARE c CURSOR FOR
select Count(Nombre) from consecionaria
WHERE Nombre = nombreC;
OPEN c;
FETCH c into resultado;
CLOSE c;
END;
-- -----------------------------------------------------------------
CREATE FUNCTION `consecionariosRepetidos`(nombre VARCHAR(45)) RETURNS int(11)
BEGIN
declare b INT;
call CantConsecionarios(nombre,b);
return b;
END:
-- -----------------------------------------------------------------
CREATE PROCEDURE `update_consecionario`(id INT ,nombreNuevo VARCHAR(45))
BEGIN
if consecionariosRepetidos(nombreNuevo) = 0 THEN
	update consecionaria c
    set Nombre = nombreNuevo
    where c.Id = id;
END IF;
END;
-- -----------------------------------------------------------------