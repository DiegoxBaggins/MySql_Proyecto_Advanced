delimiter //
Create FUNCTION getNombres(codigo int)
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
        RETURN (SELECT concat(nombre1, ' ', nom2, ' ', nom3) FROM persona WHERE cui = codigo limit 1);
    end //
delimiter ;

delimiter //
Create FUNCTION getApellidos(codigo int)
    RETURNS VARCHAR(150) DETERMINISTIC
    BEGIN
        RETURN (SELECT concat(apellido1, ' ', apellido2) FROM persona WHERE cui = codigo limit 1);
    end //
delimiter ;

delimiter //
create procedure getNacimiento(
    IN per bigint
)
bloque:begin
        DECLARE nombres, apellidos, papNom, mamNom, papAp, mamAp varchar(75);
        DECLARE cuiH, cuiM, cuiPer int;
        DECLARE cuiLargo1, cuiLargo2 bigint;
        DECLARE genChar char(1);
        DECLARE gene varchar(25);
        SET cuiPer = per div 10000;
        IF NOT personaExiste(cuiPer) THEN
                CALL mostrarError('persona no existente');
            LEAVE bloque;
        end if;
        set genChar = (select genero from persona where cui = cuiPer);
        IF genChar = 'M' THEN
            SET gene = 'Masculino';
        ELSE
            SET gene = 'Femenino';
        end if;
        SET cuiH = (select padre from nacimiento where persona = cuiPer);
        SET cuiM = (select madre from nacimiento where persona = cuiPer);
        SET nombres = getNombres(cuiPer);
        SET papNom = getNombres(cuiH);
        SET mamNom = getNombres(cuiM);
        SET apellidos = getApellidos(cuiPer);
        SET papAp = getApellidos(cuiH);
        SET mamAp = getApellidos(cuiM);
        SET cuiLargo1 = (cuiH *10000) + (select municipio from nacimiento where persona = cuiH);
        SET cuiLargo2 = (cuiM *10000) + (select municipio from nacimiento where persona = cuiM);
        SELECT N.id as No_Acta, per as CUI, apellidos, nombres,
               cuiLargo1 as DPI_Padre, papNom as Nombre_Padre, papAp as Apellido_Padre,
               cuiLargo2 as DPI_Madre, mamNom as Nombre_Madre, mamAp as Apellido_Madre,
               N.fecha as fecha_Nacimiento, D.nombre as departamento,
               M.nombre as municipio, gene as genero
        from persona p inner join nacimiento n on p.cui = n.persona
        inner join municipio m on n.municipio = m.id
        inner join departamento d on m.departamento = d.id
        where p.cui = cuiPer ;
end //
delimiter ;

call getNacimiento(1000000200101);

delimiter //
create procedure getMatrimonio(
    IN matr int
)
bloque:begin
        DECLARE nombreMarido, nombreMujer varchar(125);
        DECLARE cuiH, cuiM int;
        DECLARE cuiLargo1, cuiLargo2 bigint;
        IF NOT matrimonioExiste(matr) THEN
                CALL mostrarError('matrimonio no existe');
            LEAVE bloque;
        end if;
        SET cuiH = (select marido from matrimonio where id = matr);
        SET cuiM = (select mujer from matrimonio where id = matr);
        SET nombreMarido = getNombreCompleto(cuiH);
        SET nombreMujer = getNombreCompleto(cuiM);
        SET cuiLargo1 = (cuiH *10000) + (select municipio from nacimiento where persona = cuiH);
        SET cuiLargo2 = (cuiM *10000) + (select municipio from nacimiento where persona = cuiM);
        SELECT id as No_Acta, cuiLargo1 as DPI_Hombre, nombreMarido as Nombre_Hombre,
               cuiLargo2 as DPI_MUjer, nombreMujer as Nombre_Mujer, fecha
        from matrimonio where id = matr;
end //
delimiter ;

call getMatrimonio(12);

delimiter //
create procedure getDivorcio(
    IN matr int
)
bloque:begin
        DECLARE nombreMarido, nombreMujer varchar(125);
        DECLARE cuiH, cuiM int;
        DECLARE cuiLargo1, cuiLargo2 bigint;
        IF NOT matrimonioExiste(matr) THEN
                CALL mostrarError('matrimonio no existe');
            LEAVE bloque;
        ELSEIF NOT divorcioExiste(matr) THEN
                CALL mostrarError('no se han divorciado');
            LEAVE bloque;
        end if;
        SET cuiH = (select marido from matrimonio where id = matr);
        SET cuiM = (select mujer from matrimonio where id = matr);
        SET nombreMarido = getNombreCompleto(cuiH);
        SET nombreMujer = getNombreCompleto(cuiM);
        SET cuiLargo1 = (cuiH *10000) + (select municipio from nacimiento where persona = cuiH);
        SET cuiLargo2 = (cuiM *10000) + (select municipio from nacimiento where persona = cuiM);
        SELECT id as No_Acta, cuiLargo1 as DPI_Hombre, nombreMarido as Nombre_Hombre,
               cuiLargo2 as DPI_MUjer, nombreMujer as Nombre_Mujer, fecha
        from divorcio where matrimonio = matr;
end //
delimiter ;

call getDivorcio(11);