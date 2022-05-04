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
create procedure addNacimiento(
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

Call addNacimiento(1000000010105, 1000000021101,'Fernana', 'fer', NULL, '05-09-2000', 0101, 'F');

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
create procedure addDefuncion(
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

call addDefuncion(1000000260101, '01-01-2022', 'COVID');

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
        SET iden = (SELECT id FROM dpi where cui = codigo);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
create procedure addMatrimonio(
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

call addMatrimonio(1000000270101, 1000000280101, '05-03-2022');

delimiter //
Create FUNCTION matrimonioExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT id FROM matrimonio where id = codigo);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
Create FUNCTION divorcioExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT id FROM divorcio where matrimonio = codigo);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
create procedure addDivorcio(
    IN acta int,
    IN fechaDiv varchar(12)
)
bloque:begin
        DECLARE fecha_divorcio date;
        DECLARE fecha_matrimonio date;
        DECLARE cuiH int;
        DECLARE cuiM int;
        SET fecha_divorcio = STR_TO_DATE(fechaDiv, '%d-%m-%Y');
        IF (fecha_divorcio > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF NOT matrimonioExiste(acta) THEN
                CALL mostrarError('matrimonio no existe');
            LEAVE bloque;
        end if;
        SET fecha_matrimonio = (select fecha from matrimonio where id = acta);
        SET cuiH = (select marido from matrimonio where id = acta);
        SET cuiM = (select mujer from matrimonio where id = acta);
        IF divorcioExiste(acta) THEN
                CALL mostrarError('matrimonio ya ha sido anulado');
            LEAVE bloque;
        ELSEIF fecha_divorcio < fecha_matrimonio THEN
                CALL mostrarError('error en la fecha');
            LEAVE bloque;
        end if;
        insert into divorcio (fecha, matrimonio) VALUES (fecha_divorcio, acta);
        update persona set estadoCivil = 'Divorciado' where cui =cuiH;
        update persona set estadoCivil = 'Divorciada' where cui =cuiM;
        select * from matrimonio order by id desc limit 1;
end //
delimiter ;

call addDivorcio(11, '08-03-2022');

delimiter //
create procedure generarDPI(
    IN documento bigint,
    IN fechaEm varchar(12),
    IN lugar int
)
bloque:begin
        DECLARE cuiPersona int;
        DECLARE fecha_emision date;
        SET fecha_emision = STR_TO_DATE(fechaEm, '%d-%m-%Y');
        SET cuiPersona = documento div 10000;
        IF (fecha_emision > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF NOT EXISTS (SELECT id from municipio where id = lugar) THEN
                CALL mostrarError('municipio no existe');
            LEAVE bloque;
        ELSEIF NOT personaExiste(cuiPersona) THEN
                CALL mostrarError('persona no existente');
            LEAVE bloque;
         ELSEIF (NOT getEdad(cuiPersona)) THEN
                CALL mostrarError('no tiene edad suficiente');
            LEAVE bloque;
        ELSEIF (dpiExiste(cuiPersona)) THEN
                CALL mostrarError('Ya tiene dpi');
            LEAVE bloque;
        end if;
         insert into dpi (emision, municipio, cui) values (fecha_emision, lugar, cuiPersona);
         select p.cui, nombre1, apellido1, apellido2, emision, municipio from persona p, dpi where p.cui = dpi.cui and p.cui = cuiPersona;
end //
delimiter ;

Call generarDPI(1000000260101, '05-09-2021', 1401);

delimiter //
Create FUNCTION getEdadLic(cui int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE edad int;
        SET edad = (TIMESTAMPDIFF(YEAR, (SELECT fecha FROM nacimiento WHERE persona = cui limit 1), CURDATE()));
        RETURN IF(edad >= 16, true, false);
    end //
delimiter ;

delimiter //
Create FUNCTION LicenciaExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT id FROM licencia where persona = codigo order by id desc limit 1);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
Create FUNCTION LicenciaTipoExiste(codigo int, type char)
    RETURNS BOOLEAN DETERMINISTIC
    cuerpo:BEGIN
         DECLARE iden int;
        IF type in ('C','M') THEN
            SET iden = (SELECT id FROM licencia where persona = codigo and (tipo = 'C' or tipo = 'M') order by id desc limit 1);
            RETURN IF(iden > 0, true, false);
            LEAVE cuerpo;
        ELSE
            SET iden = (SELECT id FROM licencia where persona = codigo and type = tipo order by id desc limit 1);
            RETURN IF(iden > 0, true, false);
            LEAVE cuerpo;
        end if;
    end //
delimiter ;

delimiter //
create procedure addLicencia(
    IN documento bigint,
    IN fechaEm varchar(12),
    IN type CHAR(1)
)
bloque:begin
        DECLARE cuiPersona int;
        DECLARE fecha_emision date;
        SET fecha_emision = STR_TO_DATE(fechaEm, '%d-%m-%Y');
        SET cuiPersona = documento div 10000;
        IF (fecha_emision > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF NOT personaExiste(cuiPersona) THEN
                CALL mostrarError('persona no existente');
            LEAVE bloque;
         ELSEIF (NOT getEdadLic(cuiPersona)) THEN
                CALL mostrarError('no tiene edad suficiente');
            LEAVE bloque;
        ELSEIF type NOT IN ('E', 'C', 'M') THEN
                CALL mostrarError('tipo de licencia invalido');
            LEAVE bloque;
        ELSEIF (LicenciaTipoExiste(cuiPersona, type)) THEN
                CALL mostrarError(concat('Ya tiene licencia tipo ', type));
            LEAVE bloque;
        end if;
        insert into licencia (emision, vencimiento, tipo, persona)
            VALUES (fecha_emision, DATE_ADD(fecha_emision, INTERVAL 1 YEAR), type, cuiPersona);
        SELECT * FROM licencia where persona = cuiPersona order by id desc limit 1;
end //
delimiter ;

Call addLicencia(1000000260101, '05-09-2021', 'C');

delimiter //
Create FUNCTION LicenciaCodigoExiste(codigo int)
    RETURNS BOOLEAN DETERMINISTIC
    BEGIN
        DECLARE iden int;
        SET iden = (SELECT id FROM licencia where id = codigo order by id desc limit 1);
        RETURN IF(iden > 0, true, false);
    end //
delimiter ;

delimiter //
create procedure anularLicencia(
    IN documento int,
    IN fechaAn varchar(12),
    IN motivacion varchar(100)
)
bloque:begin
        DECLARE fecha_emision date;
        DECLARE fecha_anulada date;
        DECLARE fecha_nueva date;
        DECLARE anu int;
        SET fecha_anulada = STR_TO_DATE(fechaAn, '%d-%m-%Y');
        SET fecha_nueva = DATE_ADD(fecha_anulada, INTERVAL 2 YEAR);
        IF (fecha_anulada > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF NOT licenciaCodigoExiste(documento) THEN
                CALL mostrarError('licencia no existe');
            LEAVE bloque;
        end if;
        SET  fecha_emision = (select emision from licencia where id = documento);
        IF fecha_emision > fecha_anulada THEN
            CALL mostrarError('fecha invalida');
            LEAVE bloque;
        end if;
        Set anu = (select id from anulacion where licencia = documento);
        IF anu > 0 THEN
            UPDATE anulacion set fechaFin = fecha_nueva, motivo = motivacion where id = anu;
        ELSE
            insert into anulacion (fechaFin, motivo, licencia) values (fecha_nueva, motivacion, documento);
        end if ;
        SELECT * FROM anulacion where documento = licencia;
end //
delimiter ;

Call anularLicencia(26, '06-04-2022', 'Tontotonto');

delimiter //
create procedure renewLicencia(
    IN documento int,
    IN fechaRen varchar(12),
    IN type char(1)
)
bloque:begin
        DECLARE fecha_actual date;
        DECLARE fecha_renovacion date;
        DECLARE fecha_nueva date;
        DECLARE anu int;
        DECLARE tipo_actual char(1);
        DECLARE anios int;
        DECLARE duenio int;
        SET fecha_renovacion = STR_TO_DATE(fechaRen, '%d-%m-%Y');
        IF (fecha_renovacion > curdate()) THEN
                CALL mostrarError('fecha invalida');
            LEAVE bloque;
        ELSEIF type NOT IN ('E', 'C', 'M', 'A', 'B') THEN
                CALL mostrarError('tipo de licencia invalido');
            LEAVE bloque;
        ELSEIF NOT licenciaCodigoExiste(documento) THEN
                CALL mostrarError('licencia no existe');
            LEAVE bloque;
        end if;
        Set anu = (select id from anulacion where licencia = documento);
        IF anu > 0 THEN
            CALL mostrarError('licencia esta anulada');
            LEAVE bloque;
        end if ;
        SET duenio = (select persona from licencia where id = documento);
        SET tipo_actual = (select tipo from licencia where id = documento);
        IF type != tipo_actual THEN
            IF type = 'B' THEN
                SET anios = (TIMESTAMPDIFF(YEAR, (SELECT emision FROM licencia WHERE persona = duenio and tipo = 'C' limit 1), CURDATE()));
                IF anios < 2 THEN
                    CALL mostrarError('No cumple con los requisitos para tipo B');
                LEAVE bloque;
                ELSE
                    set tipo_actual = type;
                end if;
            ELSEIF type = 'A' THEN
                SET anios = (TIMESTAMPDIFF(YEAR, (SELECT emision FROM licencia WHERE persona = duenio and tipo = 'C' limit 1), CURDATE()));
                IF anios IS NULL THEN
                    set anios = 0;
                end if;
                IF anios < 3 THEN
                    SET anios = (TIMESTAMPDIFF(YEAR, (SELECT emision FROM licencia WHERE persona = duenio and tipo = 'B' limit 1), CURDATE()));
                    IF anios IS NULL THEN
                    set anios = 0;
                    end if;
                    IF anios < 2 THEN
                        CALL mostrarError('No cumple con los requisitos para tipo A');
                        LEAVE bloque;
                    ELSE
                    set tipo_actual = type;
                    end if;
                ELSE
                    set tipo_actual = type;
                end if;
            end if;
            IF type != tipo_actual THEN
                CALL mostrarError(CONCAT('No puede cambiar de tipo ', tipo_actual,' a ', type));
                LEAVE bloque;
                end if ;
        end if ;
        SET fecha_actual = (select vencimiento from licencia where id = documento);
        IF fecha_actual > fecha_renovacion THEN
            SET fecha_renovacion = fecha_actual;
        end if;
        SET fecha_nueva = DATE_ADD(fecha_renovacion, INTERVAL 1 YEAR);
        UPDATE licencia SET vencimiento = fecha_nueva, tipo = type where id = documento;
        SELECT id, emision, vencimiento, tipo FROM licencia where id = documento;
end //
delimiter ;

Call renewLicencia(16, '08-04-2022', 'A');