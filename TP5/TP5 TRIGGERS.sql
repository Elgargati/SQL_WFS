create database work6;
use work6;

CREATE TABLE Departements (
    NumD INT PRIMARY KEY,
    NomD VARCHAR(100),
    Ville VARCHAR(100)
);


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

select dayofweek(curdate());
-- Q1
delimiter //
create trigger tr1
before update on Employes
for each row
begin
	if (dayofweek(curdate())=7 or dayofweek(curdate())=1) then
    signal sqlstate '45000' set message_text = "Interdit la modification en weekend";
    end if;
end;//
delimiter ;

delimiter //
create trigger tr1_2
before insert on Employes
for each row
begin
	if (dayofweek(curdate())=7 or dayofweek(curdate())=1) then
    signal sqlstate '45000' set message_text = "Interdit la modification en weekend";
    end if;
end;//
delimiter ;

delimiter //
create trigger tr1_3
before delete on Employes
for each row
begin
	if (dayofweek(curdate())=7 or dayofweek(curdate())=1) then
    signal sqlstate '45000' set message_text = "Interdit la modification en weekend";
    end if;
end;//
delimiter ;

drop trigger tr1;
drop trigger tr1_2;
drop trigger tr1_3;


-- Q2
delimiter //
create trigger tr2 
before insert on departements
for each row
begin
if exists(select * from Departements where NomD=new.NomD or new.nomD is null) then	
	signal sqlstate '45000' set message_text = 'Nom de departement invalid';
end if;
end;//
delimiter ;

insert into departements values (4,'finance' , 'Casablanca');

-- Q3
delimiter //
create trigger tr3 
before insert on employes 
for each row
begin
if(new.Paie='par heure' and new.salaire<75 ) then
	signal sqlstate '45000' set message_text = 'le salaire par heure doit superieur a 75';
elseif (new.paie !='par heure' and new.salaire <10000) then
	signal sqlstate '45000' set message_text = 'le salaire doit superieur a 10000';
end if;
end;//
delimiter ;




delimiter //
create trigger tr3_1
before update on employes 
for each row
begin
if(old.Paie='par heure' and new.salaire<75 ) then
	signal sqlstate '45000' set message_text = 'le salaire par heure doit superieur a 75';
elseif (old.paie !='par heure' and new.salaire <10000) then
	signal sqlstate '45000' set message_text = 'le salaire doit superieur a 10000';
end if;
end;//
delimiter ;
drop trigger tr3_1;



INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(105, 'Mr.', 'El gargati', 'Mohamed', '2000-04-12', '2010-06-01', 'par heure', 100, 1);
INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(106, 'Mr.', 'El ', 'Mohamed', '2002-04-12', '2010-06-01', 'par semaine', 12000, 1);

update employes set salaire=2 where NumE=105;

update employes set salaire=120 where NumE=106;
select * from employes;

-- Q4
create table historique_salaireE (
	Num_op int primary key auto_increment,
    NumE int ,
    old_salaire float,
    new_salaire float,
    date timestamp default current_timestamp,
    foreign key (nume) references employes (nume)
);

delimiter //
create trigger tr4 
after update on employes
for each row
begin
if old.salaire != new.salaire then
	insert into historique_salaireE (NumE,old_salaire,new_salaire) values (old.nume,old.salaire,new.salaire);
end if;
end;//
delimiter ;
drop trigger tr4;

select * from historique_salairee;
update employes set salaire=14000 where NumE=106;


-- Q5

alter table departements add column nbrEmployes int default 0;

select * from departements;
delimiter //
create trigger tr5
after insert on employes
for each row
begin
	update departements set nbrEmployes = nbrEmployes + 1 where numd=new.numd;
end; //
delimiter ;
INSERT INTO Employes (NumE, Courtoisie, NomE, Prenom, DateNaissance, DateEmbauche, Paie, Salaire, NumD) VALUES 
(107, 'Mr.', 'El gargati', 'Mohamed', '2000-04-12', '2010-06-01', 'par heure', 100, 1);
drop trigger tr5;
insert into employes(nume,numd) values(121,1);


-- Q6
delimiter //
create trigger tr6
before delete on departements
for each row
begin
	delete from employes where numd=old.numd;
end;//
delimiter ;

delete from departements where numd=1;



-- exercice 3
CREATE TABLE Clients (
    Codeclt INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    tel VARCHAR(20)
);

CREATE TABLE Produits (
    Codeprd INT PRIMARY KEY,
    designation VARCHAR(50),
    prix DECIMAL(10,2),
    qte_dispo INT
);

CREATE TABLE Commandes (
    numero INT PRIMARY KEY,
    Codeclt INT ,
    datecmd DATE,
    Montant DECIMAL(10,2),
    FOREIGN KEY (codeclt) REFERENCES Clients(Codeclt)
);

CREATE TABLE Details (
    numero INT,
    Codeprd INT,
    qte_cmd INT,
    PRIMARY KEY (numero, Codeprd),
    FOREIGN KEY (numero) REFERENCES Commandes(numero),
    FOREIGN KEY (Codeprd) REFERENCES Produits(Codeprd)
);


INSERT INTO Clients (Codeclt, nom, prenom, tel) VALUES
(1, 'Dupont', 'Jean', '0123456789'),
(2, 'Martin', 'Alice', '0987654321'),
(3, 'Bernard', 'Paul', '0112233445'),
(4, 'Leroy', 'Sophie', '0778899000'),
(5, 'Durand', 'Luc', '0666778899');


INSERT INTO Produits (Codeprd, designation, prix, qte_dispo) VALUES
(1, 'Produit A', 15.50, 100),
(2, 'Produit B', 25.00, 200),
(3, 'Produit C', 10.75, 150),
(4, 'Produit D', 30.00, 80),
(5, 'Produit E', 45.25, 50);


INSERT INTO Commandes (numero, Codeclt, datecmd, Montant) VALUES
(1, 1, '2024-10-01', 155.50),
(2, 2, '2024-10-02', 200.00),
(3, 3, '2024-10-03', 120.75),
(4, 4, '2024-10-04', 90.00),
(5, 5, '2024-10-05', 45.25);

select * from commande2;


INSERT INTO Details (numero, Codeprd, qte_cmd) VALUES
(1, 1, 3),  
(1, 2, 2),  
(2, 3, 1),  
(3, 4, 4),  
(4, 5, 1),  
(5, 1, 2);



-- Q2
delimiter //
create trigger tg2
before insert on produits 
for each row
begin 
	if(new.qte_dispo<0) then 
    signal sqlstate '45000' set message_text ="Quantite non acceptee";
    end if;
end;//
delimiter ;

-- Q3
delimiter //
create trigger tg3
before update on details
for each row
begin
	signal sqlstate '45000' set message_text ="La table details ne peut etre modifier !";
end;//
delimiter ;


-- Q4
delimiter //
create trigger tg4
before insert on Clients 
for each row 
begin 
	declare count int;
    set count =new.codeclt;
		while exists(select * from clients where codeclt = count) do 
    set count = count +1;
    end while;
    set new.codeclt=count;
end;//
delimiter ;
drop trigger tg4;
INSERT INTO Clients (Codeclt, nom, prenom, tel) VALUES
(1, 'Dupont', 'Jean', '0123456789');

select * from clients;


-- Q5
delimiter //
create trigger tg5
before insert on details
for each row
begin
	declare pre_prix float;
	declare pre_Qte int;
    
    select prix,qte_dispo into pre_prix,pre_qte from produits where codeprd=new.codeprd;
    
    if(pre_Qte<new.qte_cmd) then
    signal sqlstate '45000' set message_text='Quantitee disponible insuffisante!';
    end if;
    
    update produits set qte_dispo = qte_dispo - new.qte_cmd where codeprd=new.codeprd;
    
    update commandes set montant = montant + (pre_prix * new.qte_cmd ) where numero=new.numero;
end;//
delimiter ;
select * from produits;
select * from details;
select * from commandes;

insert into details values (6,1,10);




-- Q7
delimiter //
create trigger tg7
after delete on details
for each row
begin
	declare pre_prix float;
	    
    select prix into pre_prix from produits where codeprd=old.codeprd;
    
    update produits set qte_dispo = qte_dispo + old.qte_cmd where codeprd=old.codeprd;
    
    update commandes set montant = montant - (pre_prix * old.qte_cmd ) where numero=old.numero;
end;//
delimiter ;
drop trigger tg7;
delete from details where numero =6;
	

-- exercice 4
CREATE TABLE Client (
    NumCli INT AUTO_INCREMENT PRIMARY KEY,
    CINCli VARCHAR(20),
    NomCli VARCHAR(100),
    AdrCli VARCHAR(255),
    TelCli VARCHAR(20)
);


CREATE TABLE Compte (
    NumCpt INT AUTO_INCREMENT PRIMARY KEY,
    SoldeCpt float DEFAULT 0.00,
    TypeCpt varchar(30) ,
    NumCli INT,
    FOREIGN KEY (NumCli) REFERENCES Client(NumCli) on delete cascade    
);


CREATE TABLE Operation (
    NumOp INT AUTO_INCREMENT PRIMARY KEY,
    TypeOp varchar(30) ,
    MtOp float ,
    NumCpt INT,
    DateOp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NumCpt) REFERENCES Compte(NumCpt) on delete cascade  
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
select * from operation;


-- Q1
delimiter //
create trigger tc1
before insert on client
for each row
begin 
	if exists (select * from client where CINCli=new.CINCli) then 
    signal sqlstate '45000' set message_text='Client exist deja ';
    end if;
end;//
delimiter ;

delimiter //
create trigger tc1_2
before update on client
for each row
begin 
	if exists (select * from client where CINCli=new.CINCli) then 
		signal sqlstate '45000' set message_text='Client exist deja ';
    end if;
end;//
delimiter ;
insert into client (CINCli, NomCli, AdrCli, TelCli) values
('D123456', 'Ahmed El Mansouri', '12 Rue Hassan II, Casablanca', '0612345678');
update client set CINCli='H2345637' where NumCli=1;


-- Q2
delimiter //
create trigger tc2
before insert on compte
for each row
begin 
	if(new.SoldeCpt<1500)then
		signal sqlstate '45000' set message_text='sold doit superieur a 1500dh';
    end if;
    
    if(new.TypeCpt !='CC' and new.TypeCpt !='CN')then
		signal sqlstate '45000' set message_text =' le type de compte doit CC ou CN';
    end if;
    
    if exists(select * from compte where TypeCpt=new.TypeCpt and NumCpt=new.NumCpt) then 
		signal sqlstate '45000' set message_text ='deja un compte meme type';
	end if;
end;//
delimiter ;

INSERT INTO Compte (NumCpt, SoldeCpt, TypeCpt, NumCli) VALUES (12, 2000, 'CN', 1);

select * from compte;

-- Q3
delimiter //
create trigger tc3
before delete on compte 
for each row
begin
	declare last_op date;
	if(old.SoldeCpt>0)then 
		signal sqlstate '45000' set message_text = ' interdet supp compte suprerieur 0';
	end if;
    select max(DateOp) into last_op from Operation where NumCpt=old.NumCpt;
    if(last_op is not null and datediff(curdate(),last_op) <90 )THEN
        SIGNAL SQLSTATE '45000'  SET MESSAGE_TEXT = 'Impossible de supprimer un compte avec des opérations récentes (moins de 3 mois).';
    END IF;
end;//
delimiter ;

select * from compte ;
select * from operation;
delete from compte where NumCpt = 2;


-- Q4
delimiter //
create trigger tc4
before update on compte 
for each row 

begin
	    DECLARE operation_count INT;
	if(new.NumCpt != old.NumCpt) then
    signal sqlstate '45000' set message_text = 'Il est interdit de modifier le numéro de compte';
    end if;
    
    select count(*) into operation_count from operation where NumCpt =old.NumCpt ;
    if operation_count>0 and  OLD.SoldeCpt != NEW.SoldeCpt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossible de modifier le solde du compte s''il y a des opérations associées.';
    END IF;
    
    if (old.TypeCpt ='CN' and new.TypeCpt='CC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il est interdit de changer un compte sur carnet en compte courant.';
    END IF;
	
	IF OLD.NumCli != NEW.NumCli AND EXISTS ( select * from compte where numcli = new.numcli and TypeCpt = old.TypeCpt ) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New client already has an account of this type';
	END IF;
        
end;//
delimiter ;









