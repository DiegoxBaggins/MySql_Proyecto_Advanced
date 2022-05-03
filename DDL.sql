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
     nombre VARCHAR (35) NOT NULL , 
     departamento INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (departamento) REFERENCES Departamento(id)
    );

CREATE TABLE Persona 
    (
     cui INTEGER AUTO_INCREMENT NOT NULL , 
     nombre1 VARCHAR (25) NOT NULL , 
     nombre2 VARCHAR (25) , 
     nombre3 VARCHAR (25) , 
     apellido1 VARCHAR (25) NOT NULL , 
     apellido2 VARCHAR (25) NOT NULL , 
     genero CHAR (1) NOT NULL , 
     estadoCivil VARCHAR (10) NOT NULL ,
     PRIMARY KEY (cui) ,
     CONSTRAINT genValido CHECK (genero = 'M' OR genero = 'F') ,
     CONSTRAINT civValido CHECK (estadoCivil = 'Soltero' OR estadoCivil = 'Casado' 
     OR estadoCivil = 'Divorciado' OR estadoCivil = 'Viudo' 
     OR estadoCivil = 'Soltera' OR estadoCivil = 'Casada' 
     OR estadoCivil = 'Divorciada' OR estadoCivil = 'Viuda')
    );

CREATE TABLE DPI 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     emision DATE NOT NULL , 
     municipio INTEGER NOT NULL , 
     cui INTEGER NOT NULL, 
     PRIMARY KEY (id) ,
     FOREIGN KEY (municipio) REFERENCES Municipio(id),
     FOREIGN KEY (cui) REFERENCES Persona(cui)
    );

CREATE TABLE Nacimiento 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     fecha DATE NOT NULL , 
     municipio INTEGER NOT NULL , 
     persona INTEGER NOT NULL , 
     padre INTEGER NOT NULL , 
     madre INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (municipio) REFERENCES Municipio(id) ,
     FOREIGN KEY (persona) REFERENCES Persona(cui) ,
     FOREIGN KEY (padre) REFERENCES Persona(cui) ,
     FOREIGN KEY (madre) REFERENCES Persona(cui)
    );

CREATE TABLE Licencia 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     emision DATE NOT NULL , 
     vencimiento DATE NOT NULL , 
     tipo CHAR (1) NOT NULL, 
     persona INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (persona) REFERENCES Persona(cui) ,
     CONSTRAINT tipoValido CHECK (tipo = 'A' OR tipo = 'B' 
     OR tipo = 'C' OR tipo = 'M' OR tipo = 'E')  
    );


CREATE TABLE Anulacion 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     fechaFin DATE NOT NULL , 
     motivo VARCHAR (100) NOT NULL , 
     licencia INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (licencia) REFERENCES Licencia(id)
    );

CREATE TABLE Defuncion 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     fecha DATE NOT NULL , 
     motivo VARCHAR (100) NOT NULL , 
     persona INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (persona) REFERENCES Persona(cui) 
    );


CREATE TABLE Matrimonio 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     fecha DATE NOT NULL , 
     marido INTEGER NOT NULL , 
     mujer INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (marido) REFERENCES Persona(cui),
     FOREIGN KEY (mujer) REFERENCES Persona(cui) 
    );


CREATE TABLE Divorcio 
    (
     id INTEGER AUTO_INCREMENT NOT NULL , 
     fecha DATE NOT NULL , 
     matrimonio INTEGER NOT NULL ,
     PRIMARY KEY (id) ,
     FOREIGN KEY (matrimonio) REFERENCES Matrimonio(id) 
    );

CREATE TABLE TEMP_DEPT
    (
    codigo INTEGER NOT NULL ,
    departamento VARCHAR(25) NOT NULL ,
    municipio VARCHAR(35) NOT NULL
)

    

