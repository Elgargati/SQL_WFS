create database work5;
use work5;

CREATE TABLE Departement (
    Num_Dep INT PRIMARY KEY,
    Nom_Dep VARCHAR(100) ,
    Ville_Dep VARCHAR(100)
);

INSERT INTO Departement (Num_Dep, Nom_Dep, Ville_Dep) VALUES
(1, 'Informatique', 'Paris'),
(2, 'Comptabilité', 'Lyon'),
(3, 'Marketing', 'Marseille');


CREATE TABLE Employe (
    Matricule INT PRIMARY KEY,
    Nom_Emp VARCHAR(100) ,
    Prenom_Emp VARCHAR(100) ,
    DateNaissance_Emp DATE ,
    Salaire_Emp DECIMAL(10, 2) ,
    Num_Dep INT, 
    Total_vente float DEFAULT 0,
    FOREIGN KEY (Num_Dep) REFERENCES Departement(Num_Dep)
);

-- Insertion de données dans Employé
INSERT INTO Employe (Matricule, Nom_Emp, Prenom_Emp, DateNaissance_Emp, Salaire_Emp, Num_Dep, Total_vente) VALUES
(101, 'El Mansouri', 'Youssef', '1985-06-15', 3000.50, 1, 0),
(102, 'Benzakour', 'Fatima', '1990-08-22', 2800.75, 2, 0),
(103, 'El Idrissi', 'Mohammed', '1978-11-10', 3500.00, 1, 0),
(104, 'Bouazza', 'Khadija', '1982-03-05', 3200.30, 3, 0);



CREATE TABLE Vente (
    Num_Vente INT AUTO_INCREMENT PRIMARY KEY,
    Matricule INT, 
    Date_Vente DATE NOT NULL,
    Montant float NOT NULL,
    FOREIGN KEY (Matricule) REFERENCES Employe(Matricule)
);


INSERT INTO Vente (Matricule, Date_Vente, Montant) VALUES
(101, '2023-09-15', 1500.50),
(102, '2023-09-17', 2000.00),
(103, '2023-09-18', 1200.75),
(101, '2023-09-19', 800.90),
(104, '2023-09-20', 1750.00),
(103, '2023-09-21', 2200.00),
(102, '2023-09-22', 1850.40);

select * from departement;
select * from employe;
select * from Vente;


-- Ex1

-- Q1
delimiter //
create trigger tr1
before insert
on employe
for each row
begin
	if(new.Salaire_Emp <1000) then
		signal sqlstate '45000' set message_text = 'salaire invalid';
	end if;
end;//
delimiter ;
insert into employe values
(106, 'El Idrissi', 'Mohammed', '1978-11-10', 2500.00, 1, 0);

-- Q2

delimiter //
create trigger tr2
before insert
on employe
for each row
begin
 if  ( timestampdiff(year,new.DateNaissance_Emp,curdate())<18) then
	signal sqlstate '45000' set message_text ='age invalid';
    
 end if;
end;//
delimiter ;

insert into employe values 
(107, 'Hamid', 'abderahman', '2000-03-05', 3200.30, 3, 0);


-- Q3
delimiter //
create trigger tr3
before delete
on employe
for each row
begin 
	if exists (select * from vente where Matricule=old.Matricule) then
		signal sqlstate '45000' set message_text ="l'employe deja effectue dans  ventes";
	end if;
end;//
delimiter ;

delete from employe where matricule=102;

-- Q4
delimiter //
create trigger tr4
before update
on departement
for each row
begin
	if ( new.Num_Dep !=  old.Num_Dep ) then
		signal sqlstate '45000' set message_text = "modification en id departement interdite" ;
    end if ;
end;//
delimiter ;
drop trigger tr4;
update  departement set Num_dep = 4 where Num_dep =1;

-- Q5
delimiter //
create trigger tr5
after insert
on vente
for each row
begin 
	update employe set Total_vente = Total_vente + new.Montant where Matricule=new.Matricule;
end ;//
delimiter ;

select * from employe;
select * from vente;
insert into Vente (Matricule, Date_Vente, Montant) values
(101, curdate(), 1850.40);

-- Q6
create table journal_vente (
	num_vente int primary key auto_increment,
	id_vente int ,
	id_employe int ,
    date_vente date
);

delimiter //
create trigger tr6
after insert
on vente
for each row
begin
	insert into journal_vente (id_vente,id_employe,date_vente) values (new.Num_Vente,new.Matricule,curdate());
end;//
delimiter ;

select * from journal_vente;
INSERT INTO Vente (Matricule, Date_Vente, Montant) VALUES
(101, '2023-09-15', 1500.50);



-- ex2
CREATE TABLE Departements (
    NumD INT PRIMARY KEY,
    NomD VARCHAR(100),
    Ville VARCHAR(100)
);
drop table Departements;
drop table employes;
CREATE TABLE Employes (
    NumE INT PRIMARY KEY,
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
(1, 'Informatique', 'Casablanca'),
(2, 'Ressources Humaines', 'Rabat'),
(3, 'Marketing', 'Marrakech');

INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(101, 'Mr.', 'El Idrissi', 'Mohamed', '1985-04-12', '2010-06-01', 'par heure', 200000.00, 1),
(102, 'Mme.', 'Benjelloun', 'Fatima', '1990-09-23', '2015-03-15', 'par mois', 180000.00, 2),
(103, 'Dr.', 'Haddad', 'Omar', '1978-11-05', '2005-01-22', 'par semaine', 220000.00, 1),
(104, 'Mme.', 'El Amrani', 'Sanae', '1988-07-14', '2018-09-10', 'par heure', 160000.00, 3);

select * from employes;

-- Q1
drop trigger th1;
delimiter //
create trigger th1
before update
on employes
for each row
begin 
	-- if ((dayname(curdate()) = 'saturday') or (dayname(curdate()) = 'sunday')) then
	if ((dayname(curdate()) = 'tuesday') or (dayname(curdate()) = 'wednesday')) then
		signal sqlstate '45000' set message_text = 'Interdit la modification en weekend';
	end if;
end;//
delimiter ;
update employes set NomE='Mohammed' where NumE=101;


-- Q2
drop trigger th2;
delimiter //
create trigger th2
before insert
on Departements
for each row
begin
	if exists (select * from Departements where NomD=new.NomD or new.NomD is null ) then
		signal sqlstate '45000' set message_text = "Nome de departement invalid";
    end if;
end;//
delimiter ;

INSERT INTO Departements VALUES 
(12,'info', 'Casablanca');
select * from departements;
select * from employes;
-- Q3
delimiter //
create trigger th3
before insert
on employes
for each row
begin
	if (new.Paie = 'par heure' and new.salaire < 75) then
		signal sqlstate '45000' set message_text = "le salaire par heure doit superieur a 75";
	else if (new.Paie != 'par heure' and new.salaire < 10000) then
		signal sqlstate '45000' set message_text = "le salaire doit superieur a 1000";
	end if;
    end if;
end ;//
delimiter ;

INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(120, 'Mr.', 'El Idrissi', 'Mohamed', '1985-04-12', '2010-06-01', 'par heure', 60, 1);




-- 4
 CREATE TABLE Historique_Salaires (
    matricule INT,
    ancien_salaire DECIMAL(10, 2),
    nouveau_salaire DECIMAL(10, 2),
    date_changement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
delimiter //
create trigger TracesUpdateSalaire
BEFORE UPDATE 
ON employe
for each row
begin
    if old.salaire != new.salaire then
        insert into Historique_Salaires (matricule, ancien_salaire, nouveau_salaire) values (OLD.matricule, OLD.salaire, NEW.salaire);
    end if;
end;//
delimiter ;

INSERT INTO employe
VALUES (83, 'Durand', 'Marie', 15000 ,20,'1990-04-10', 'par heure', '2023/09/06');
UPDATE employe
SET Salaire = 16000
WHERE Matricule = 83;
SELECT * FROM Historique_Salaires WHERE Matricule = 83;

-- 5
alter table departement3 add column nbrEmployes int default 0//
update departement3 set nbrEmployes=(select count(num_emp) from employe where num_dep=30 )  where num_dep=30//


delimiter //
create trigger update_nbr_employes
AFTER INSERT 
on employe
for each row
begin
    update departement3 SET NbrEmployes = NbrEmployes + 1 where Num_dep = new.Num_dep;
END;//
delimiter ;
select * from departement3;
insert into employe(num_emp,num_dep) values(17,10);


-- 6
delimiter //
CREATE TRIGGER suppression
before delete
ON departement
FOR EACH ROW
BEGIN

    delete from employe where num_dep = old.num_dep ;
END;//
delimiter ;


-- exercice 3
CREATE TABLE Client2 (
    Codeclt INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    tel VARCHAR(20)
);

CREATE TABLE Produit2 (
    Codeprd INT PRIMARY KEY,
    designation VARCHAR(50),
    prix DECIMAL(10,2),
    qte_dispo INT
);

CREATE TABLE Commande2 (
    numero INT PRIMARY KEY,
    Codeclt INT ,
    datecmd DATE,
    Montant DECIMAL(10,2),
    FOREIGN KEY (codeclt) REFERENCES Client2(Codeclt)
);

CREATE TABLE Detail (
    numero INT,
    Codeprd INT,
    qte_cmd INT,
    PRIMARY KEY (numero, Codeprd),
    FOREIGN KEY (numero) REFERENCES Commande2(numero),
    FOREIGN KEY (Codeprd) REFERENCES Produit2(Codeprd)
);



INSERT INTO Client2 (Codeclt, nom, prenom, tel) VALUES
(1, 'Dupont', 'Jean', '0123456789'),
(2, 'Martin', 'Alice', '0987654321'),
(3, 'Bernard', 'Paul', '0112233445'),
(4, 'Leroy', 'Sophie', '0778899000'),
(5, 'Durand', 'Luc', '0666778899');


INSERT INTO Produit2 (Codeprd, designation, prix, qte_dispo) VALUES
(1, 'Produit A', 15.50, 100),
(2, 'Produit B', 25.00, 200),
(3, 'Produit C', 10.75, 150),
(4, 'Produit D', 30.00, 80),
(5, 'Produit E', 45.25, 50);


INSERT INTO Commande2 (numero, Codeclt, datecmd, Montant) VALUES
(1, 1, '2024-10-01', 155.50),
(2, 2, '2024-10-02', 200.00),
(3, 3, '2024-10-03', 120.75),
(4, 4, '2024-10-04', 90.00),
(5, 5, '2024-10-05', 45.25);

select * from commande2;


INSERT INTO Detail (numero, Codeprd, qte_cmd) VALUES
(1, 1, 3),  
(1, 2, 2),  
(2, 3, 1),  
(3, 4, 4),  
(4, 5, 1),  
(5, 1, 2);


# 1 ---
DELIMITER //
CREATE TRIGGER TR_Produit_QuantiteNegative
BEFORE INSERT ON Produit2
FOR EACH ROW
BEGIN
    IF NEW.qte_dispo < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantité non acceptée !';
    END IF;
END;//
DELIMITER ;


# 2 ---
DELIMITER //
CREATE TRIGGER TR_Detail_NoUpdate
BEFORE UPDATE ON Detail
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La table DETAIL ne peut être modifiée !';
END;//
DELIMITER ;

# 3 ---
DELIMITER //
CREATE TRIGGER TR_Commande_NumeroUnique
BEFORE INSERT ON Commande2
FOR EACH ROW
BEGIN
    DECLARE newNumero INT;
    SELECT COALESCE(MAX(numero), 0) + 1 INTO newNumero FROM Commande;
    SET NEW.numero = newNumero;
END;
//
DELIMITER ;

# 4 ---
DELIMITER //
CREATE TRIGGER TR_Detail_UpdateCommande
AFTER INSERT ON Detail
FOR EACH ROW
BEGIN
    UPDATE Commande2 C
    SET Montant = (
        SELECT SUM(D.qte_cmd * P.prix) 
        FROM Detail D 
        INNER JOIN Produit2 P ON D.Codeprd = P.Codeprd 
        WHERE D.numero = C.numero
    )
    WHERE C.numero = NEW.numero;

    UPDATE Produit2 P
    SET P.qte_dispo = P.qte_dispo - NEW.qte_cmd
    WHERE P.Codeprd = NEW.Codeprd;

    IF (SELECT P.qte_dispo FROM Produit2 P WHERE P.Codeprd = NEW.Codeprd) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantité disponible insuffisante pour un ou plusieurs produits.';
    END IF;
END //
DELIMITER ;

# 5 ----
DELIMITER //
CREATE TRIGGER TR_Client_UpdateTel
AFTER UPDATE ON Client2
FOR EACH ROW
BEGIN
    IF OLD.tel != NEW.tel THEN
        INSERT INTO Historique_Client (Codeclt, ancien_tel, nouv_tel, date_changement)
        VALUES (NEW.Codeclt, OLD.tel, NEW.tel, NOW());
    END IF;
END //
DELIMITER ;

# 6 ----
DELIMITER //
CREATE TRIGGER TR_Detail_Delete
AFTER DELETE ON Detail
FOR EACH ROW
BEGIN
    UPDATE Produit2 P
    SET P.qte_dispo = P.qte_dispo + OLD.qte_cmd
    WHERE P.Codeprd = OLD.Codeprd;

    -- Update Montant in Commande table
    UPDATE Commande2 C
    SET Montant = (
        SELECT SUM(D.qte_cmd * P.prix) 
        FROM Detail D 
        INNER JOIN Produit2 P ON D.Codeprd = P.Codeprd 
        WHERE D.numero = C.numero
    )
    WHERE C.numero = OLD.numero;
END //
DELIMITER ;




-- exercice 4

CREATE TABLE Client (
    NumCli INT AUTO_INCREMENT PRIMARY KEY,
    CINCli VARCHAR(20) NOT NULL,
    NomCli VARCHAR(100),
    AdrCli VARCHAR(255),
    TelCli VARCHAR(20)
);


CREATE TABLE Compte (
    NumCpt INT AUTO_INCREMENT PRIMARY KEY,
    SoldeCpt float DEFAULT 0.00,
    TypeCpt varchar(30) NOT NULL,
    NumCli INT,
    FOREIGN KEY (NumCli) REFERENCES Client(NumCli),
    CONSTRAINT unique_type_cpt UNIQUE (NumCli, TypeCpt)
);


CREATE TABLE Operation (
    NumOp INT AUTO_INCREMENT PRIMARY KEY,
    TypeOp varchar(30) NOT NULL,
    MtOp float NOT NULL,
    NumCpt INT,
    DateOp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NumCpt) REFERENCES Compte(NumCpt)
);

INSERT INTO Client (CINCli, NomCli, AdrCli, TelCli)
VALUES 
('D123456', 'Ahmed El Mansouri', '12 Rue Hassan II, Casablanca', '0612345678'),
('E654321', 'Fatima Boudra', '45 Avenue Mohamed V, Rabat', '0623456789'),
('F987654', 'Youssef Laabidi', '78 Boulevard Zerktouni, Marrakech', '0634567890'),
('G876543', 'Amina Benjelloun', '3 Rue Moulay Ismail, Fès', '0645678901'),
('H234567', 'Mohamed Ouazzani', '10 Rue Ibn Sina, Tanger', '0656789012');



INSERT INTO Compte (SoldeCpt, TypeCpt, NumCli)
VALUES 
(5000.00, 'CC', 1),
(12000.00, 'CC', 2),
(7000.00, 'CC', 3),
(3000.00, 'CC', 4),
(8000.00, 'CC', 5); 

INSERT INTO Compte (SoldeCpt, TypeCpt, NumCli)
VALUES 
(2000.00, 'CN', 1), 
(5000.00, 'CN', 2), 
(3500.00, 'CN', 3), 
(1500.00, 'CN', 4), 
(4500.00, 'CN', 5); 



INSERT INTO Operation (TypeOp, MtOp, NumCpt)
VALUES 
('D', 1000.00, 1), 
('D', 2000.00, 2), 
('D', 500.00, 3), 
('D', 300.00, 4), 
('D', 1500.00, 5);


INSERT INTO Operation (TypeOp, MtOp, NumCpt)
VALUES 
('R', 500.00, 1), 
('R', 1200.00, 2),
('R', 800.00, 3), 
('R', 400.00, 4), 
('R', 1000.00, 5);

select * from client;
select * from compte;

-- Q1 
DELIMITER //
CREATE TRIGGER verif_CIN_Client
BEFORE INSERT ON Client
FOR EACH ROW
BEGIN
    DECLARE exist_count INT;
    SELECT COUNT(*) INTO exist_count FROM Client  WHERE CINCli = NEW.CINCli AND NumCli != NEW.NumCli;
    
    IF exist_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le numéro de CIN existe déjà pour un autre client.';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER verif_CIN_Client_update
BEFORE update ON Client
FOR EACH ROW
BEGIN
    DECLARE exist_count INT;
    SELECT COUNT(*) INTO exist_count FROM Client  WHERE CINCli = NEW.CINCli AND NumCli != NEW.NumCli;
    
    IF exist_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le numéro de CIN existe déjà pour un autre client.';
    END IF;
END//
DELIMITER ;

INSERT INTO Client (NumCli, CINCli, NomCli, AdrCli, TelCli) VALUES (6, 'ABC12345', 'Client 1', 'Adresse 1', '0612345678');

INSERT INTO Client (NumCli, CINCli, NomCli, AdrCli, TelCli) VALUES (7, 'ABC12345', 'Client 2', 'Adresse 2', '0698765432');

UPDATE Client SET CINCli = 'ABC12345' WHERE NumCli = 3;



-- Q2
DELIMITER //
CREATE TRIGGER verif_Creation_Compte
BEFORE INSERT ON Compte
FOR EACH ROW
BEGIN

    DECLARE compte_count INT;

    IF NEW.SoldeCpt < 1500 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le solde initial doit être supérieur à 1500 DH.';
    END IF;


    IF NEW.TypeCpt NOT IN ('CC', 'CN') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le type de compte doit être CC ou CN.';
    END IF;


    SELECT COUNT(*) INTO compte_count FROM Compte WHERE NumCli = NEW.NumCli AND TypeCpt = NEW.TypeCpt;
    
    IF compte_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le client a déjà un compte de ce type.';
    END IF;
    
END;//
DELIMITER ;

INSERT INTO Compte (NumCpt, SoldeCpt, TypeCpt, NumCli) VALUES (1, 2000, 'CC', 1);

INSERT INTO Compte (NumCpt, SoldeCpt, TypeCpt, NumCli) VALUES (2, 1000, 'CC', 1);

INSERT INTO Compte (NumCpt, SoldeCpt, TypeCpt, NumCli) VALUES (3, 2000, 'XYZ', 1); 

INSERT INTO Compte (NumCpt, SoldeCpt, TypeCpt, NumCli) VALUES (4, 2000, 'CC', 1); 



-- Q3

DELIMITER //
CREATE TRIGGER interdiction_Suppression_Compte
BEFORE DELETE ON Compte
FOR EACH ROW
BEGIN
	DECLARE derniere_operation DATE;
    IF OLD.SoldeCpt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer un compte avec un solde supérieur à 0.';
    END IF;

    
    SELECT MAX(DateOp) INTO derniere_operation FROM Operation WHERE NumCpt = OLD.NumCpt;
    IF derniere_operation IS NOT NULL AND DATEDIFF(CURRENT_DATE, derniere_operation) < 90 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer un compte avec des opérations récentes (moins de 3 mois).';
    END IF;
END//
DELIMITER ;

DELETE FROM Compte WHERE NumCpt = 1;

INSERT INTO Operation (NumOp, TypeOp, MtOp, NumCpt, DateOp) VALUES (1, 'D', 500, 1, CURDATE());

DELETE FROM Compte WHERE NumCpt = 1;

DELETE FROM Compte WHERE NumCpt = 2;


-- Q4
DELIMITER //

CREATE TRIGGER interdiction_Modification_Compte
BEFORE UPDATE ON Compte
FOR EACH ROW
BEGIN
    DECLARE operation_count INT;
    
    IF OLD.NumCpt != NEW.NumCpt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il est interdit de modifier le numéro de compte.';
    END IF;

    
    SELECT COUNT(*) INTO operation_count FROM Operation WHERE NumCpt = OLD.NumCpt;   
    IF operation_count > 0 AND OLD.SoldeCpt != NEW.SoldeCpt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de modifier le solde du compte s''il y a des opérations associées.';
    END IF;

    
    IF OLD.TypeCpt = 'CN' AND NEW.TypeCpt = 'CC' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il est interdit de changer un compte sur carnet en compte courant.';
    END IF;
END//

DELIMITER ;

UPDATE Compte SET NumCpt = 5 WHERE NumCpt = 1;

UPDATE Compte SET SoldeCpt = 3000 WHERE NumCpt = 1;

UPDATE Compte SET TypeCpt = 'CC' WHERE NumCpt = 1 AND TypeCpt = 'CN';

UPDATE Compte SET SoldeCpt = 3500 WHERE NumCpt = 2;

