ALTER TABLE persona AUTO_INCREMENT=100000000;

insert into persona (nombre1, apellido1, apellido2, genero, estadoCivil)
values ('Francisco','Gomez','Garcia', 'M', 'Soltero'),
('Oscar', 'Morales', 'Perez', 'M', 'Casado'),
('Maria', 'Valdez', 'Lopez', 'F', 'Casada'),
('Eugenia', 'Garcia', 'Gonzalez', 'F', 'Viuda'),
('Paola', 'Martinez', 'Martinez', 'F', 'Soltera'),
('Edgard', 'Figueroa', 'Molina', 'F', 'Casada'),
('Mayra', 'Archila', 'Hernandez', 'F', 'Casada'),
('Alejandra', 'Gonzales', 'Morales', 'F', 'Divorciada'),
('Estela', 'Montoya', 'Rodriguez', 'F', 'Divorciada'),
('Esteban', 'Solorzano', 'Gomez', 'M', 'Casado'),
('Juan', 'Gabriel', 'Martinez', 'M', 'Casado'),
('Barabara', 'Quiñones', 'Smith', 'M', 'Viudo'),
('Erick', 'Barrondo', 'Brown', 'M', 'Divorciado'),
('Ricardo', 'Arjona','Ramos', 'M', 'Divorciado'),
('Gabriela', 'Moreno', 'Cruz', 'F', 'Soltera');

insert into nacimiento (fecha, municipio, persona, padre, madre)
VALUES ('1990-01-01', 101, 100000001, 100000000, 100000014),
       ('1990-01-01', 101, 100000002, 100000000, 100000014),
       ('1990-01-01', 101, 100000003, 100000000, 100000014),
       ('1990-01-01', 101, 100000004, 100000000, 100000014),
       ('1990-01-01', 101, 100000005, 100000000, 100000014),
       ('1990-01-01', 101, 100000006, 100000000, 100000014),
       ('1990-01-01', 101, 100000007, 100000000, 100000014),
       ('1990-01-01', 101, 100000008, 100000000, 100000014),
       ('1990-01-01', 101, 100000009, 100000000, 100000014),
       ('1990-01-01', 101, 100000010, 100000000, 100000014),
       ('1990-01-01', 101, 100000011, 100000000, 100000014),
       ('1990-01-01', 101, 100000012, 100000000, 100000014),
       ('1990-01-01', 101, 100000013, 100000000, 100000014);


insert into dpi (emision, municipio, cui)
VALUES (curdate(), 101, 100000000),
       (curdate(), 105, 100000001),
       (curdate(), 1101, 100000002),
       (curdate(), 1604, 100000003),
       (curdate(), 1401, 100000004),
       (curdate(), 101, 100000005),
       (curdate(), 101, 100000006),
       (curdate(), 101, 100000007),
       (curdate(), 1202, 100000008),
       (curdate(), 501, 100000009),
       (curdate(), 1502, 100000010),
       (curdate(), 101, 100000011),
       (curdate(), 901, 100000012),
       (curdate(), 101, 100000013),
       (curdate(), 101, 100000014);

insert into defuncion (fecha, motivo, persona)
VALUES (curdate(), 'COVID', 100000000),
       (curdate(), 'COVID', 100000003),
       (curdate(), 'COVID', 100000004),
       (curdate(), 'COVID', 100000011),
       (curdate(), 'COVID', 100000014);

insert into matrimonio (fecha, marido, mujer)
VALUES (curdate(), 100000001, 100000011),
       (curdate(), 100000003, 100000002),
       (curdate(), 100000001, 100000002),
       (curdate(), 100000003, 100000011),
       (curdate(), 100000005, 100000009),
       (curdate(), 100000006, 100000010),
       (curdate(), 100000007, 100000012),
       (curdate(), 100000008, 100000013),
       (curdate(), 100000007, 100000013),
       (curdate(), 100000008, 100000012);

insert into divorcio (fecha, matrimonio)
VALUES (curdate(), 1),
       (curdate(), 2),
       (curdate(), 7),
       (curdate(), 8),
       (curdate(), 9),
       (curdate(), 10);

insert into  licencia (emision, vencimiento, tipo, persona)
VALUES
       (curdate(), '2025-01-01', 'C', 100000000),
       (curdate(), '2023-01-01', 'C', 100000001),
       (curdate(), '2024-01-01', 'B', 100000002),
       (curdate(), '2025-01-01', 'C', 100000003),
       (curdate(), '2025-01-01', 'B', 100000004),
       (curdate(), '2024-01-01', 'B', 100000005),
       (curdate(), '2024-01-01', 'C', 100000006),
       (curdate(), '2023-01-01', 'M', 100000007),
       (curdate(), '2026-01-01', 'C', 100000008),
       (curdate(), '2026-01-01', 'M', 100000009),
       (curdate(), '2027-01-01', 'C', 100000010),
       (curdate(), '2027-01-01', 'C', 100000011),
       (curdate(), '2027-01-01', 'A', 100000012),
       (curdate(), '2027-01-01', 'E', 100000013),
       (curdate(), '2027-01-01', 'M', 100000014);