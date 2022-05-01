SET GLOBAL local_infile = true;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


load data local infile'C:/Users/dalej/Documents/Universidad/7mo semestre/Bases de Datos/Laboratorio/Proyecto 2/BasesDeDatos1_Proyecto2/lista_municipios.csv'
    into table renap31.temp_dept fields terminated by ',' enclosed by '"'  lines terminated by '\n' ignore 1 lines;

select * from temp_dept;

insert into departamento (id, nombre) select distinct
(truncate(codigo/100, 0)), departamento from temp_dept;

select * from departamento;

select
codigo, municipio, id from temp_dept, departamento
where temp_dept.departamento = departamento.nombre;

insert into municipio (id, nombre, departamento)  select
codigo, municipio, id from temp_dept, departamento
where temp_dept.departamento = departamento.nombre;

select * from municipio;