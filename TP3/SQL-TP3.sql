create database work3;
use work3;

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


INSERT INTO Vente (Matricule, Date_Vente, Montant) VALUES
(101, '2023-09-15', 1500.50),
(102, '2023-09-17', 2000.00),
(103, '2023-09-18', 1200.75),
(101, '2023-09-19', 800.90),
(104, '2023-09-20', 1750.00),
(103, '2023-09-21', 2200.00),
(102, '2023-09-22', 1850.40);


delimiter //

create procedure V1(mt int,d date ,mv float)
begin
	declare exit handler for sqlexception 
    begin
		rollback;
		select "transaction echouee" as message;
    end;
if exists(select * from employe where matricule=mt)then
	start transaction;
    set autocommit = OFF;
    insert into Vente (Matricule, Date_Vente, Montant) values (mt,d,mv);
    update Employe set Total_vente=Total_vente+mv where Matricule=mt;
    commit;
    select "vente bien ajouter" as message;
      set autocommit = ON;
else 
	select "matricule invalide " as message;
end if;
end;//
delimiter ;
call V1(102,curdate(),200);

select * from employe;
select * from vente;
delete from vente;
delete from employe;
drop procedure V1;
alter table employe drop column Total_vente;





-- exercice 2
CREATE TABLE evenement (
    ID_evenement INT PRIMARY KEY AUTO_INCREMENT,
    Nom VARCHAR(255) ,
    Places_Disponibles INT 
);

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



select * from evenement;
select * from reservation;


delimiter //
create procedure AjouterRes(id int,n_billets int)
begin
   declare b int;
	declare exit handler for sqlexception
    begin
		rollback;
   		select "transaction echouee" as message;
    end;    
 
    if exists (select * from evenement where ID_evenement=id) then
		set b =(select Places_Disponibles from evenement where ID_evenement=id);
        if(b>0 and b>=n_billets) then
			start transaction;
			set autocommit=off;
			insert into reservation  (ID_evenement, Nombre_Billets) values (id,n_billets);
			update evenement set Places_Disponibles=Places_Disponibles - n_billets where ID_evenement=id;
			commit;
			select "reservation bien ajouter" as message;
			set autocommit=on;
		else 
			select "Nombre de place no disponible" as message;
		end if;
    else 
		select "ID_evenement not exists" as message;
	end if;
    
end;//
delimiter ;
drop procedure AjouterRes;
call AjouterRes(1,1000);
select * from evenement;
select * from reservation;
delete from reservation;








-- exercice 3

CREATE TABLE Produit1 (
    ID_Produit INT PRIMARY KEY,
    Nom VARCHAR(255) ,
    Stock INT 
);


CREATE TABLE Commandes (
    ID_Commande INT PRIMARY KEY auto_increment,
    ID_Produit INT,
    Quantite_Commandee INT ,
    Date_Commande DATE ,
    FOREIGN KEY (ID_Produit) REFERENCES Produit1(ID_Produit)
);
drop table commandes;
drop table produit1;

INSERT INTO Produit1 (ID_Produit, Nom, Stock) VALUES
(1, 'Produit A', 100),
(2, 'Produit B', 50),
(3, 'Produit C', 200),
(4, 'Produit D', 400),
(5, 'Produit E', 500),
(6, 'Produit F', 100);


delimiter //
create procedure passerCommande(id_p int ,qte int, d date)
begin
	declare s int;
	if exists (select * from  Produit1 where ID_Produit=id_p) then
		set s = (select Stock from produit1 where ID_Produit=id_p);
        if(s>0 and s>=qte)then
			set autocommit=off;
			start transaction;
            insert into commandes (ID_Produit, Quantite_Commandee, Date_Commande) values (id_p,qte,d);
            update Produit1 set Stock=Stock-qte where ID_Produit=id_p;
            commit;
            select "commande bien ajouter" as message;
			set autocommit=om;
		else
			signal sqlstate '45000' set message_text='quantite indisponible';
		end if;
	else     
	signal sqlstate '45000' set message_text='produit indisponible';
	end if;
    
end;//
delimiter ;
drop procedure passerCommande;
call passerCommande(1,12,curdate());
select * from commandes;



-- ex2
delimiter //

create procedure supprimerproduit(in produitid int)
begin
     
	if not exists (select * from produit1 where ID_Produit = produitid) then
        signal sqlstate '45000' set message_text = 'produit introuvable';
    else        
		start transaction;  
        set autocommit=off;
        delete from produit1 where ID_Produit = produitid;
        commit;
		set autocommit=on;
        select "produit bien supprimer" as message;
    end if;
end;//

delimiter ;
drop procedure supprimerproduit;
call supprimerproduit(3);


-- ex3










