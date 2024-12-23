create database work4;
use work4;

-- exercice 1
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
(101, 'Dupont', 'Jean', '1985-06-15', 3000.50, 1, 0),
(102, 'Durand', 'Marie', '1990-08-22', 2800.75, 2, 0),
(103, 'Martin', 'Paul', '1978-11-10', 3500.00, 1, 0),
(104, 'Bernard', 'Laura', '1982-03-05', 3200.30, 3, 0);


CREATE TABLE Vente (
    Num_Vente INT AUTO_INCREMENT PRIMARY KEY,
    Matricule INT, 
    Date_Vente DATE NOT NULL,
    Montant float NOT NULL,
    FOREIGN KEY (Matricule) REFERENCES Employe(Matricule)
);
select * from employe;

INSERT INTO Vente (Matricule, Date_Vente, Montant) VALUES
(101, '2023-09-15', 1500.50),
(102, '2023-09-17', 2000.00),
(103, '2023-09-18', 1200.75),
(101, '2023-09-19', 800.90),
(104, '2023-09-20', 1750.00),
(103, '2023-09-21', 2200.00),
(102, '2023-09-22', 1850.40);


drop procedure SommeTotalVente;

delimiter //
create procedure SommeTotalVente()
begin

    declare findC boolean default false;
	declare m int;
    declare somme float default 0;

declare C cursor for select matricule from Employe;
    declare continue handler for not found 
	begin 
			set findC=true;
	end;	
 open C;
 
Boucle : loop
fetch C into m;
if(findC=true) then
	leave Boucle;
end if;
        SELECT SUM(Montant) INTO somme FROM Vente WHERE Matricule = m;
        UPDATE Employe SET Total_vente = somme WHERE Matricule = m;
 end loop ;
 close C;
 
 select * from employe;
end;//

delimiter ;
call SommeTotalVente();
select * from employe;




-- exercice 2
CREATE TABLE evenement (
    ID_evenement INT PRIMARY KEY AUTO_INCREMENT,
    Nom VARCHAR(255) ,
    Places_Disponibles INT 
);
drop table Reservation;
drop table evenement;
CREATE TABLE Reservation (
    ID_Reservation INT PRIMARY KEY AUTO_INCREMENT,
    ID_evenement INT,
    Nombre_Billets INT ,
    FOREIGN KEY (ID_evenement) REFERENCES evenement(ID_evenement)
);


INSERT INTO evenement (Nom, Places_Disponibles) 
VALUES 
('Concert de Rock', 100),
('Conference Tech', 50),
('Festival de Musique', 200),
('Match de Football', 500);

-- Insertion de données dans la table Réservation
INSERT INTO Reservation (ID_Evenement, Nombre_Billets)
VALUES 
(1, 40),   
(1, 20),   
(2, 10),   
(2, 15),   
(3, 100),  
(3, 50),   
(4, 200),  
(4, 150);  




drop procedure MiseAjourBillet;
delimiter //

create procedure MiseAjourBillet()
begin
	declare FindC boolean default false;
    declare id_event int;
    declare totalBillet int default 0;
    
    declare C cursor for select ID_evenement from evenement;
    declare continue handler for not found set FindC=true;
	open C;
    
    Boucle : loop
    fetch C into id_event;
    
    if FindC then 
		leave Boucle;
    end if;
		select sum(Nombre_Billets) into totalBillet from Reservation where ID_evenement=id_event;
		UPDATE evenement SET Places_Disponibles = Places_Disponibles - totalBillet WHERE ID_evenement=id_event;
    end loop;
    close C;
    
    select * from evenement;
    
end;//
delimiter ;

select * from evenement;
call MiseAjourBillet();

-- exercice 3


CREATE TABLE Produit (
    ID_Produit INT PRIMARY KEY AUTO_INCREMENT,
    Nom VARCHAR(100),
    Stock INT
);


CREATE TABLE Commandes (
    ID_Commande INT PRIMARY KEY AUTO_INCREMENT,
    ID_Produit INT,
    Quantite_Commandee INT,
    Date_Commande DATE,
    FOREIGN KEY (ID_Produit) REFERENCES Produit(ID_Produit)
);


CREATE TABLE RCommandes (
    ID_Commande INT,
    ID_Produit INT,
    Quantite_retournee INT,
    Date_Retour DATE,
    PRIMARY KEY (ID_Commande, ID_Produit),
    FOREIGN KEY (ID_Commande) REFERENCES Commandes(ID_Commande),
    FOREIGN KEY (ID_Produit) REFERENCES Produit(ID_Produit)
);


INSERT INTO Produit (Nom, Stock)
VALUES 
('Ordinateur Portable', 50),
('Clavier', 100),
('Souris', 150),
('Imprimante', 30);



INSERT INTO Commandes (ID_Produit, Quantite_Commandee, Date_Commande)
VALUES 
(1, 10, '2024-10-01'),   
(2, 20, '2024-10-02'),   
(3, 30, '2024-10-03'),   
(4, 5, '2024-10-04');    



INSERT INTO RCommandes (ID_Commande, ID_Produit, Quantite_retournee, Date_Retour)
VALUES 
(1, 1, 2, '2024-10-05'),  
(2, 2, 5, '2024-10-06'),  
(3, 3, 3, '2024-10-07'),  
(4, 4, 1, '2024-10-08');  


drop procedure Retours;
DELIMITER //
CREATE PROCEDURE Retours()
BEGIN
    DECLARE FindC INT DEFAULT false;
    DECLARE cmd_id INT;
    DECLARE prod_id INT;
    DECLARE qte_retournee INT;

    
    DECLARE C CURSOR FOR SELECT ID_Commande, ID_Produit FROM Commandes;

    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET FindC = true;
    OPEN C;
    Boucle: LOOP
		FETCH C INTO cmd_id, prod_id;
			IF FindC THEN
				LEAVE Boucle;
			END IF;
        
        SELECT SUM(Quantite_retournee) INTO qte_retournee FROM RCommandes
        WHERE ID_Commande = cmd_id AND ID_Produit = prod_id;
        
   
            UPDATE Produit SET Stock = Stock + qte_retournee WHERE ID_Produit = prod_id;
        
    END LOOP;

    CLOSE C;
    select 'les produits bien retournes' as message;
END;//

DELIMITER ;

call Retours();
select * from RCommandes;
select * from Produit;
select * from Commandes;


-- exercice 4
CREATE TABLE STAGIAIRE (
    codeS INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    groupe VARCHAR(50),
    dateNaissance DATE
);

CREATE TABLE MODULE (
    codeM INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    coef FLOAT NOT NULL
);

CREATE TABLE EVALUER (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    codeS INT,
    codeM INT,
    Date DATE,
    note FLOAT,
    FOREIGN KEY (codeS) REFERENCES STAGIAIRE(codeS),
    FOREIGN KEY (codeM) REFERENCES MODULE(codeM)
);
INSERT INTO STAGIAIRE (codeS, nom, groupe, dateNaissance) VALUES
(1, 'Mohammed El Amrani', 'Groupe A', '2000-01-12'),
(2, 'Fatima Zahra Benali', 'Groupe B', '1999-03-22'),
(3, 'Youssef Bouzid', 'Groupe A', '2001-05-30'),
(4, 'Amina El Idrissi', 'Groupe C', '1998-07-15'),
(5, 'Omar Khalladi', 'Groupe B', '2002-09-10');

INSERT INTO MODULE (codeM, nom, coef) VALUES
(101, 'Mathématiques', 4.0),
(102, 'Informatique', 3.5),
(103, 'Physique', 2.0),
(104, 'Chimie', 2.5),
(105, 'Culture Générale', 2.0);

INSERT INTO EVALUER (codeS, codeM, Date, note) VALUES
(1, 101, '2024-01-15', 16.0),
(1, 102, '2024-01-20', 14.5),
(2, 103, '2024-01-18', 12.0),
(3, 104, '2024-01-22', 15.0),
(4, 101, '2024-01-25', 9.5),
(5, 102, '2024-01-30', 17.0),
(1, 105, '2024-02-01', 13.0),
(2, 104, '2024-02-05', 10.0),
(3, 103, '2024-02-10', 11.0);


INSERT INTO EVALUER (codeS, codeM, Date, note) VALUES
(1, 102, '2024-02-12', 18.5),
(2, 101, '2024-01-15', 11.0),
(3, 102, '2024-01-20', 19.5),
(4, 103, '2024-01-18', 18.0),
(5, 104, '2024-01-22', 11.0),
(1, 101, '2024-01-25', 19.5),
(2, 102, '2024-01-30', 11.0),
(3, 105, '2024-02-01', 18.0),
(4, 104, '2024-02-05', 16.0),
(5, 103, '2024-02-10', 19.0),
(1, 102, '2024-02-12', 18.5);



DROP FUNCTION IF EXISTS p2;

-- Q2
delimiter //
create function CalculMoyenne(S_code int, M_code int)
returns float
reads sql data
begin
	return (select avg(note) from evaluer where codeS=S_code and codeM=M_code);
end;//
delimiter ;

select * from evaluer;
select CalculMoyenne(2,101);


-- Q3
delimiter //
create function MoyenneGeneral(S_code int)
returns float
reads sql data
begin
	declare M_code int;
	declare M_coef float;
	declare FindC boolean default false;
    declare somme float default 0;
    declare AllCoef float default 0;
	declare c cursor for select distinct codeM,Coef from evaluer inner join module using(codeM) where codeS=S_code;
    declare continue handler for not found 
		begin
			set FindC=true;
        end;
        
	open c;
    Boucle : loop
		fetch c into M_code,M_coef;
        if FindC then
			leave Boucle;
		end if;
        set AllCoef= AllCoef+M_coef;
        set somme = somme+(CalculMoyenne(S_code,M_code) * M_coef);
    end loop;
    close c;
    return somme/AllCoef;
    
end;//
delimiter ;
drop function if exists MoyenneGeneral;

select MoyenneGeneral(3);
select CalculMoyenne(1,102);
select  codes, codeM,Coef   from evaluer inner join module using(codem) where codes=1;
select distinct codeS, codeM,Coef from evaluer inner join module using(codeM) where codeS=1;


-- Q4
drop function if exists Mention;

delimiter //
create function Mention(S_code int)
returns varchar(50)
reads sql data
begin
	declare moyenne float;
    set moyenne=MoyenneGeneral(S_code);
    case 
		when moyenne<10 then
			return 'ajourne';
		when moyenne>=10 and moyenne<12 then
			return 'passable';	
		when moyenne>=12 and moyenne<14 then
			return 'A.Bien';		
		when moyenne>=14 and moyenne<16 then
			return 'Bien';		
		when moyenne>=16 and moyenne<=20 then
			return 'T.Bien';
	 else
			return 'Invalid';
	end case;
end;//
delimiter ;

select Mention(2);



-- Q5
delimiter //
create procedure afficheStagiaires()
begin
	declare cs int;
    declare n varchar(50);
    declare g varchar(50);
    declare findC boolean default false;
    declare moyeneG float;
    declare ment varchar(50);
    
    declare c cursor for select codeS,nom,groupe from STAGIAIRE;
    declare continue handler for not found set findC=true;
    
    open c;  
    Boucle : loop
    fetch c into cs,n,g;
    if findC then
		leave Boucle;
	end if;
    set moyeneG=MoyenneGeneral(cs);
    set ment=mention(cs);
    select cs as "Code stagiaire", n as "nom", g as "groupe", moyeneG as "Moyenne general",ment as "Mention";
    end loop;
    close c;
end;//
delimiter ;
call afficheStagiaires();
drop procedure afficheStagiaires;



