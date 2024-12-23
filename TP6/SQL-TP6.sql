
select * from employe;

DROP database WORK4;
create database work4;
use work4;
select * from employe;
create table employe4 (
    Matricule INT PRIMARY KEY,
    Nom_Emp VARCHAR(100) ,
    Prenom_Emp VARCHAR(100) ,
    DateNaissance_Emp DATE ,
    Salaire_Emp DECIMAL(10, 2) ,
    Num_Dep INT, 
    Total_vente float DEFAULT 0
);
INSERT INTO Employe4 (Matricule, Nom_Emp, Prenom_Emp, DateNaissance_Emp, Salaire_Emp, Total_vente) VALUES
(101, 'Dupont', 'Jean', '1985-06-15', 3000.50, 1),
(102, 'Durand', 'Marie', '1990-08-22', 2800.75, 2),
(103, 'Martin', 'Paul', '1978-11-10', 3500.00, 1),
(104, 'Bernard', 'Laura', '1982-03-05', 3200.30, 3);


drop table employe4;
-- Q5
create user ali @localhost identified by "1234";







