create database work7;
use work7;
CREATE TABLE Departements (
    NumD INT PRIMARY KEY,
    NomD VARCHAR(100),
    Ville VARCHAR(100)
);


CREATE TABLE Employes (
    NumE INT PRIMARY KEY auto_increment,
    Courtoisie VARCHAR(10),
    NomE VARCHAR(100),
    Prenom VARCHAR(100),
    DateNaissance DATE,
    DateEmbauche DATE,
    Paie varchar(100),
    Salaire float,
    NumD INT,
    FOREIGN KEY (NumD) REFERENCES Departements(NumD)
);

INSERT INTO Departements (NumD, NomD, Ville) VALUES 
(101, 'Informatique', 'Casablanca'),
(102, 'Ressources Humaines', 'Rabat'),
(103, 'Marketing', 'Marrakech');

INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(1, 'Mr.', 'El Idrissi', 'Mohamed', '1985-04-12', '2010-06-01', 'par heure', 200000.00, 101),
(2, 'Mme.', 'Benjelloun', 'Fatima', '1990-09-23', '2015-03-15', 'par mois', 180000.00, 102),
(3, 'Dr.', 'Haddad', 'Omar', '1978-11-05', '2005-01-22', 'par semaine', 220000.00, 101),
(4, 'Mme.', 'El Amrani', 'Sanae', '1988-07-14', '2018-09-10', 'par heure', 160000.00, 103);

drop procedure addEmployes;
delimiter //
create procedure addEmployes()
begin
	declare count int;
    set count =0;
    while count<100000 do
    INSERT INTO Employes (Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
	('Mr.', 'El Idrissi', 'Mohamed', '1985-04-12', '2010-06-01', 'par heure', 100000.00, 101);
    end while;
end;//
 select * from employes;
drop table employes;

call addEmployes();

explain select * from employes where Paie ='par heure';

create index myindex on employes(Paie);
show index on employes;



