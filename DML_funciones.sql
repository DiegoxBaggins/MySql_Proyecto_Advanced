Create FUNCTION soloLetras(str Varchar(25))
RETURNS BOOLEAN DETERMINISTIC
RETURN IF(str regexp '^[a-zA-Záéíóú]+$', true, false);

delimiter //
Create FUNCTION getEdad(cui int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE edad int;
        SET edad = (TIMESTAMPDIFF(YEAR, (SELECT fecha FROM nacimiento WHERE persona = cui limit 1), CURDATE()));
        RETURN IF(edad >= 18, true, false);
    end //
delimiter ;

delimiter //
Create procedure mostrarError(mensaje varchar(100))
    BEGIN
        SELECT mensaje as Error;
    end //
delimiter ;

delimiter //
Create FUNCTION personaExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT cui FROM persona where cui = codigo);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
Create FUNCTION getNombreCompleto(codigo int)
    RETURNS VARCHAR(150) DETERMINISTIC
    BEGIN
        DECLARE nom2, nom3 varchar(25);
        SET nom2 = (SELECT nombre2 FROM persona WHERE cui = codigo limit 1);
        SET nom3 = (SELECT nombre3 FROM persona WHERE cui = codigo limit 1);
        IF nom2 IS NULL THEN
            SET nom2 = '';
        end if;
        IF nom3 IS NULL THEN
            SET nom3 = '';
        end if;
        RETURN (SELECT concat(nombre1, ' ', nom2, ' ', nom3, ' ', apellido1, ' ', apellido2) FROM persona WHERE cui = codigo limit 1);
    end //
delimiter ;

delimiter //
create procedure agregarNacimiento(
    IN pad bigint,
    IN mad bigint,
    IN primer varchar(25),
    IN segundo varchar(25),
    IN tercero varchar(25),
    IN fechaNac varchar(12),
    IN lugar int,
    IN genero char(1)
)
bloque:begin
DECLARE ape1 VARCHAR(25);
        DECLARE ape2 VARCHAR(25);
        DECLARE nuevoCui int;
        DECLARE cuiPapa int;
        DECLARE cuiMama int;
        DECLARE fecha_nacimiento date;
        SET fecha_nacimiento = STR_TO_DATE(fechaNac, '%d-%m-%Y');
        SET cuiPapa = pad div 10000;
        SET cuiMama = mad div 10000;
        IF primer IS NULL THEN
                CALL mostrarError('primer nombre debe ser obligatorio');
            LEAVE bloque;
        ELSEIF NOT soloLetras(primer) THEN
                CALL mostrarError('nombre solo puede tener letras');
            LEAVE bloque;
        ELSEIF segundo IS NOT NULL AND NOT soloLetras(segundo) THEN
                CALL mostrarError('nombre solo puede tener letras');
            LEAVE bloque;
        ELSEIF tercero IS NOT NULL AND NOT soloLetras(tercero) THEN
                CALL mostrarError('nombre solo puede tener letras');
            LEAVE bloque;
        ELSEIF (fecha_nacimiento > curdate()) THEN
                CALL mostrarError('nacimiento invalido');
            LEAVE bloque;
        ELSEIF NOT EXISTS (SELECT id from municipio where id = lugar) THEN
                CALL mostrarError('municipio no existe');
            LEAVE bloque;
        ELSEIF genero NOT IN ('M', 'F') THEN
                CALL mostrarError('genero invalido');
            LEAVE bloque;
        ELSEIF NOT personaExiste(cuiPapa) OR NOT personaExiste(cuiMama) THEN
                CALL mostrarError('padres no existentes');
            LEAVE bloque;
         ELSEIF ((NOT getEdad(cuiPapa)) OR (NOT getEdad(cuiMama))) THEN
                CALL mostrarError('padres no tienen edad suficiente');
            LEAVE bloque;
        end if;
         set ape1 = (select apellido1 from persona where cui = cuiPapa);
         set ape2 = (select apellido1 from persona where cui = cuiMama);
         insert into persona (nombre1, nombre2, nombre3, apellido1, apellido2, genero, estadoCivil)
             values (primer, segundo, tercero, ape1, ape2, genero, 'Soltero');
         set nuevoCui = (select cui from persona order by cui desc limit 1);
         insert into nacimiento (fecha, municipio, persona, padre, madre)
             VALUES (fecha_nacimiento, lugar, nuevoCui, cuiPapa, cuiMama);
         select ((cui*10000) + lugar) as CUI, getNombreCompleto(nuevoCui) as Nombre, genero, fecha_nacimiento from persona where cui = nuevoCui;
end //
delimiter ;

Call agregarNacimiento(1000000010105, 1000000021101,'Fernana', 'fer', NULL, '05-09-2000', 0101, 'F');

delimiter //
Create FUNCTION getMuerto(cui int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE pers int;
        SET pers = (SELECT persona FROM defuncion WHERE persona = cui limit 1);
        RETURN IF(pers > 0, true, false);
    end //
delimiter ;

delimiter //
create procedure agregarDefuncion(
    IN muerto bigint,
    IN fechaFall varchar(12),
    IN motivacion varchar(100)
)
bloque:begin
        DECLARE muertoCui int;
        DECLARE fechaNac DATE;
        DECLARE fecha_muerte date;
        SET fecha_muerte = STR_TO_DATE(fechaFall, '%d-%m-%Y');
        SET muertoCui = muerto div 10000;
        IF motivacion IS NULL THEN
            CALL mostrarError('motivo nulo');
            LEAVE bloque;
        ELSEIF NOT personaExiste(muertoCui) THEN
                CALL mostrarError('persona no existente');
            LEAVE bloque;
        ELSEIF (fecha_muerte > curdate()) THEN
                CALL mostrarError('fecha muerte invalida');
            LEAVE bloque;
        end if;
        Set fechaNac = (SELECT fecha from nacimiento where persona = muerto);
        IF (fecha_muerte < fechaNac) THEN
                CALL mostrarError('fecha muerte invalida, previa al nacimiento');
            LEAVE bloque;
        ELSEIF getMuerto(muertoCui) THEN
                CALL mostrarError('persona ya esta muerta');
            LEAVE bloque;
        end if;
        insert into defuncion (fecha, motivo, persona) VALUES (fecha_muerte, motivacion, muertoCui);
        select id as acta, muerto as CUI, motivo, fecha from defuncion where persona = muertoCui;
end //
delimiter ;

call agregarDefuncion(1000000260101, '01-01-2022', 'COVID');

delimiter //
Create FUNCTION getMatrimonioActual(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE mat int;
        DECLARE divor int;
        SET mat = (SELECT id FROM matrimonio WHERE marido = codigo or mujer = codigo order by id desc limit 1);
        IF mat > 0 THEN
            SET divor = (select id FROM divorcio where matrimonio = mat);
            IF divor > 0 THEN
                RETURN false;
            ELSE
                RETURN true;
            end if;
        ELSE
            RETURN false;
        end if;
    end //
delimiter ;

delimiter //
Create FUNCTION dpiExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT cui FROM dpi where cui = codigo);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
create procedure agregarMatrimonio(
    IN hombre bigint,
    IN mujer bigint,
    IN fechaMat varchar(12)
)
bloque:begin
        DECLARE generoH char(1);
        DECLARE generoM char(1);
        DECLARE cuiH int;
        DECLARE cuiM int;
        DECLARE fecha_matrimonio date;
        DECLARE codigo_mat int;
        SET fecha_matrimonio = STR_TO_DATE(fechaMat, '%d-%m-%Y');
        SET cuiH = hombre div 10000;
        SET cuiM = mujer div 10000;
        IF (fecha_matrimonio > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF NOT personaExiste(cuiH) OR NOT personaExiste(cuiM) THEN
                CALL mostrarError('personas no existentes');
            LEAVE bloque;
        end if;
        SET generoH = (select genero from persona where cui = cuiH);
        SET generoM = (select genero from persona where cui = cuiM);
        IF generoH != 'M' OR generoM != 'F' THEN
                CALL mostrarError('no se aceptan matrimonio de estos generos');
            LEAVE bloque;
        ELSEIF ((NOT getEdad(cuiH)) OR (NOT getEdad(cuiM))) THEN
                CALL mostrarError('no tienen edad suficiente');
            LEAVE bloque;
        ELSEIF ((getMatrimonioActual(cuiH)) OR (getMatrimonioActual(cuiM))) THEN
                CALL mostrarError('pareja tiene matriminios validos');
            LEAVE bloque;
        ELSEIF NOT dpiExiste(cuiH) OR NOT dpiExiste(cuiM) THEN
                CALL mostrarError('personas sin dpi');
            LEAVE bloque;
        end if;
        insert into matrimonio (fecha, marido, mujer) VALUES
            (fecha_matrimonio, cuiH, cuiM);
        update persona set estadoCivil = 'Casado' where cui =cuiH;
        update persona set estadoCivil = 'Casada' where cui =cuiM;
        select * from matrimonio order by id desc limit 1;
end //
delimiter ;

call agregarMatrimonio(1000000270101, 1000000280101, '05-03-2022');