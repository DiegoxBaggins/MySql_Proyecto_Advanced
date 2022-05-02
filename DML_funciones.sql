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
create procedure agregarNacimiento(
    IN pad bigint,
    IN mad bigint,
    IN primer varchar(25),
    IN segundo varchar(25),
    IN tercero varchar(25),
    IN fechaNac date,
    IN lugar int,
    IN genero char(1)
)
bloque:begin
DECLARE ape1 VARCHAR(25);
        DECLARE ape2 VARCHAR(25);
        DECLARE nuevoCui int;
        DECLARE cuiPapa int;
        DECLARE cuiMama int;
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
        ELSEIF (fechaNac > curdate()) THEN
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
             VALUES (fechaNac, lugar, nuevoCui, cuiPapa, cuiMama);
         select * from persona where cui = nuevoCui;
end //
delimiter ;

Call agregarNacimiento(1000000010105, 1000000021101,'Diego', 'fer', NULL, '2000-10-5', 0101, 'M');

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
    IN fechaFall date,
    IN motivacion varchar(100)
)
bloque:begin
        DECLARE muertoCui int;
        DECLARE fechaNac DATE;
        SET muertoCui = muerto div 10000;
        IF motivacion IS NULL THEN
            CALL mostrarError('motivo nulo');
            LEAVE bloque;
        ELSEIF NOT personaExiste(muertoCui) THEN
                CALL mostrarError('persona no existente');
            LEAVE bloque;
        ELSEIF (fechaFall > curdate()) THEN
                CALL mostrarError('fecha muerte invalida');
            LEAVE bloque;
        end if;
        Set fechaNac = (SELECT fecha from nacimiento where persona = muerto);
        IF (fechaFall < fechaNac) THEN
                CALL mostrarError('fecha muerte invalida, previa al nacimiento');
            LEAVE bloque;
        ELSEIF getMuerto(muertoCui) THEN
                CALL mostrarError('persona ya esta muerta');
            LEAVE bloque;
        end if;
        insert into defuncion (fecha, motivo, persona) VALUES (fechaFall, motivacion, muertoCui);
        select * from defuncion where persona = muertoCui;
end //
delimiter ;

call agregarDefuncion(1000000200101, '2020-01-01', 'COVID');