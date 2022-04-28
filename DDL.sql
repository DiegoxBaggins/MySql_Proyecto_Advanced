CREATE database Renap31;

use Renap31;

CREATE TABLE Departamento 
    (
     id INTEGER NOT NULL , 
     nombre VARCHAR (25) NOT NULL ,
     PRIMARY KEY (id) 
    );

CREATE TABLE Municipio 
    (
     id INTEGER NOT NULL , 
     nombre VARCHAR (25) NOT NULL , 
     departamento INTEGER NOT NULL ,
     PRIMARY KEY (id, departamento) ,
     FOREIGN KEY (departamento) REFERENCES Departamento(id)
    );

CREATE TABLE Persona 
    (
     cui INTEGER NOT NULL , 
     nombre1 VARCHAR (25) NOT NULL , 
     nombre2 VARCHAR (25) , 
     nombre3 VARCHAR (25) , 
     apellido1 VARCHAR (25) NOT NULL , 
     apellido2 VARCHAR (25) NOT NULL , 
     genero CHAR (1) NOT NULL , 
     estadoCivil CHAR NOT NULL , 
     PRIMARY KEY (cui) ,
     CONSTRAINT genValido CHECK (genero = 'M' || genero = 'F')
    );

CREATE TABLE DPI 
    (
     id INTEGER NOT NULL , 
     emision DATE NOT NULL , 
     municipio INTEGER NOT NULL , 
     departamento INTEGER NOT NULL , 
     cui INTEGER NOT NULL, 
     PRIMARY KEY (id) ,
     FOREIGN KEY (municipio, departamento) REFERENCES Municipio(id, departamento)
    );

CREATE TABLE Nacimiento 
    (
     id INTEGER NOT NULL , 
     fecha DATE NOT NULL , 
     municipio INTEGER NOT NULL , 
     departamento INTEGER NOT NULL , 
     persona INTEGER NOT NULL , 
     padre INTEGER NOT NULL , 
     madre INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (municipio, departamento) REFERENCES Municipio(id, departamento) ,
     FOREIGN KEY (persona, padre, madre) REFERENCES Persona(cui, cui, cui)
    );

CREATE TABLE Licencia 
    (
     id INTEGER NOT NULL , 
     emision DATE NOT NULL , 
     vencimiento DATE NOT NULL , 
     tipo CHAR (1) NOT NULL, 
     persona INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (persona) REFERENCES Persona(cui)  
    );


CREATE TABLE Anulacion 
    (
     id INTEGER NOT NULL , 
     fechaFin DATE NOT NULL , 
     motivo VARCHAR (100) NOT NULL , 
     licencia INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (licencia) REFERENCES Licencia(id)
    );

CREATE TABLE Defuncion 
    (
     id INTEGER NOT NULL , 
     fecha DATE NOT NULL , 
     motivo VARCHAR (100) NOT NULL , 
     persona INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (persona) REFERENCES Persona(cui) 
    );


CREATE TABLE Matrimonio 
    (
     id INTEGER NOT NULL , 
     fecha DATE NOT NULL , 
     marido INTEGER NOT NULL , 
     mujer INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (marido, mujer) REFERENCES Persona(cui, cui) 
    );


CREATE TABLE Divorcio 
    (
     id INTEGER NOT NULL , 
     fecha DATE NOT NULL , 
     matrimonio INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (matrimonio) REFERENCES Matrimonio(id) 
    );

    

