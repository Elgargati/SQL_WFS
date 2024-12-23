	create database work2;
    use work2;
-- exercice 1
CREATE TABLE Employe (
    Matricule INT PRIMARY KEY,
    Nom_Emp VARCHAR(100),
    Prenom_Emp VARCHAR(100),
    DateNaissance_Emp DATE,
    Salaire_Emp float,
    Num_Dep INT,
    FOREIGN KEY (Num_Dep) REFERENCES Departement(Num_Dep)
);
select * from employe;

CREATE TABLE Departement (
    Num_Dep INT PRIMARY KEY,
    Nom_Dep VARCHAR(100),
    Ville_Dep VARCHAR(100)
);


CREATE TABLE Vente (
    Num_Vente INT PRIMARY KEY,
    Matricule INT,
    Date_Vente DATE,
    Montant float,
    FOREIGN KEY (Matricule) REFERENCES Employe(Matricule)
);

INSERT INTO Departement (Num_Dep, Nom_Dep, Ville_Dep) VALUES
(1, 'Informatique', 'Casablanca'),
(2, 'Finance', 'Rabat'),
(3, 'Ressources Humaines', 'Marrakech'),
(4, 'Ventes', 'Tanger'),
(5, 'Marketing', 'Fès');

INSERT INTO Employe (Matricule, Nom_Emp, Prenom_Emp, DateNaissance_Emp, Salaire_Emp, Num_Dep) VALUES
(101, 'El Arbi', 'Ahmed', '1985-03-12', 15000, 1),
(102, 'Ben Salem', 'Fatima', '1990-07-22', 12000, 2),
(103, 'Touhami', 'Youssef', '1982-11-03', 18000, 1),
(104, 'El Moutawakil', 'Zineb', '1988-04-15', 14000, 3),
(105, 'Jabir', 'Rachid', '1992-09-09', 16000, 4),
(106, 'Mahmoud', 'Samira', '1995-01-23', 13500, 5),
(107, 'El Idrissi', 'Mohamed', '1989-06-18', 12500, 1),
(108, 'Cherkaoui', 'Amina', '1987-08-30', 17000, 3),
(109, 'Ben Ali', 'Omar', '2003-10-10', 15500, 4),
(110, 'Saidi', 'Salma', '2004-12-29', 14500, 5);

select * from employe;
INSERT INTO Vente (Num_Vente, Matricule, Date_Vente, Montant) VALUES
(1001, 105, '2024-01-15', 25000),
(1002, 109, '2024-02-03', 17500),
(1003, 105, '2024-03-10', 22000),
(1004, 102, '2024-04-18', 30000),
(1005, 108, '2024-05-05', 28000);
select * from vente;
INSERT INTO Vente (Num_Vente, Matricule, Date_Vente, Montant) VALUES
(1006, 101, '2020-06-12', 19000),
(1007, 107, '2021-07-22', 15000),
(1008, 109, '2022-08-05', 23000),
(1009, 103, '2023-09-11', 26000),
(1010, 106, '2024-10-02', 18000),
(1011, 104, '2023-10-15', 31000),
(1012, 108, '2022-11-18', 29500),
(1013, 102, '2021-11-25', 22000),
(1014, 105, '2020-12-05', 24500),
(1015, 101, '2023-12-18', 20000);


-- Q1
delimiter //
create procedure AfficherVentesParEmploye(id int)
begin
if exists (select * from Vente inner join Employe using(Matricule) where Matricule=id) then
	select * from Vente inner join Employe using(Matricule) where Matricule=id;
else
	select 'auccun vente effectuees' as 'Message';
end if;
end ;//
delimiter ;
call AfficherVentesParEmploye(101);

-- Q2 
delimiter //
create procedure MettreAjourSalaire(id int,s float)	
begin 
if exists (select * from Employe where Matricule=id) then
update Employe set Salaire_Emp=s where Matricule=id;
	select 'Salaire bien modifier' as 'Message';
else
	select 'auccun employe' as 'Message' ;
end if;
end;//
delimiter ;
drop procedure MettreAjourSalaire;

call MettreAjourSalaire(101,17500);

-- Q3
delimiter //
create procedure CalculerSommeVentesParEmploye()
begin
	if exists ( select  Matricule,Nom_Emp,Prenom_Emp, sum(Montant) as 'somme des vente' from Employe inner join Vente using(Matricule) group by Matricule) then
    select sum(Montant) as 'somme des vente',Matricule,Nom_Emp,Prenom_Emp from Employe inner join Vente using(Matricule) group by Matricule;
    else
	select 'auccun vente employe' as 'Message';
    end if;
end;//
delimiter ;
drop procedure CalculerSommeVentesParEmploye;
call CalculerSommeVentesParEmploye();

-- Q4

delimiter //
create procedure GenererStatistiques()
begin
	select year(Date_Vente),month(Date_Vente), count(Num_Vente),sum(Montant),max(Montant) from Vente group by year(Date_Vente),month(Date_Vente);
end;//
delimiter ;
call GenererStatistiques();
drop procedure GenererStatistiques;

-- Q5
delimiter //
create procedure TransfertEmployeService(id int , ids int)
begin
update employe set Num_Dep=ids where Matricule=id;
end;//
delimiter ;
call TransfertEmployeService(101,2);

-- exercice 2
CREATE TABLE Article (
    NumArt INT PRIMARY KEY,          
    DesArt VARCHAR(100),             
    PUArt float,           
    QteEnStock INT,                  
    SeuilMinimum INT,                
    SeuilMaximum INT                 
);
select * from article;
CREATE TABLE LigneCommande (
    NumCom INT ,                      
    NumArt INT,                     
    QteCommandee INT,                
    PRIMARY KEY (NumCom, NumArt),    
    FOREIGN KEY (NumCom) REFERENCES Commande(NumCom),  
    FOREIGN KEY (NumArt) REFERENCES Article(NumArt) 
);

CREATE TABLE Commande (
    NumCom INT PRIMARY KEY ,          
    DatCam DATE                      
);
drop table Commande;
drop table LigneCommande;

INSERT INTO Article (NumArt, DesArt, PUArt, QteEnStock, SeuilMinimum, SeuilMaximum) VALUES
(1, 'Ordinateur Portable HP', 8500.00, 50, 10, 100),
(2, 'Écran Samsung 24"', 1200.00, 75, 20, 150),
(3, 'Clavier Mécanique Logitech', 600.00, 40, 5, 80),
(4, 'Souris Optique Dell', 300.00, 100, 15, 200),
(5, 'Casque Bluetooth Sony', 1800.00, 30, 5, 60);

INSERT INTO Commande (NumCom, DatCam) VALUES
(1001, '2024-09-10'),
(1002, '2024-09-12'),
(1003, '2024-09-15'),
(1004, '2024-09-17'),
(1005, '2024-09-19'),
(1006, '2024-09-20'),
(1007, '2024-09-21'),
(1008, '2024-09-22'),
(1009, '2024-09-23'),
(1010, '2024-09-24'),
(1011, '2024-09-25'),
(1012, '2024-09-26'),
(1013, '2024-09-27'),
(1014, '2024-09-28'),
(1015, '2024-09-29');

INSERT INTO LigneCommande (NumCom, NumArt, QteCommandee) VALUES
(1001, 1, 8),   
(1002, 4, 8),   
(1003, 2, 8),   
(1004, 1, 8),   
(1005, 3, 8),   
(1006, 1, 8),   
(1006, 2, 10),  
(1007, 3, 4),   
(1007, 5, 2),   
(1008, 1, 6),   
(1008, 4, 25),  
(1009, 5, 10),  
(1009, 3, 7),   
(1010, 2, 12),  
(1010, 1, 9),   
(1011, 4, 15),   
(1011, 5, 3),    
(1012, 3, 10),   
(1012, 1, 5),    
(1013, 2, 20),   
(1013, 4, 18),   
(1014, 1, 7),    
(1014, 5, 9),    
(1015, 3, 15),   
(1015, 2, 25);   

select * from Article;
select * from Commande;
select * from LigneCommande;

-- Q1
delimiter //
create procedure SP1()
begin 
	select NumArt,DesArt from article ;
end;//
delimiter ;

call SP1;
drop procedure sp1;
-- Q2

drop procedure SP2;
delimiter //
create procedure SP2 (n_com int)
begin
	select NumCom,NumArt,DesArt from LigneCommande inner join article using(NumArt) where NumCom = n_com;	

end;//
delimiter ;
drop procedure sp2;
call SP2(1008);

-- Q3
drop procedure SP3;

delimiter //
create procedure SP3 (date1 date , date2 date)
begin
	if exists (select NumCom from LigneCommande inner join commande using(NumCom) where DatCam between date1 and date2) then	
	select NumCom from 	Commande where DatCam between date1 and date2;
	else
    select "aucun commande entre cette dates" as Message;
    end if;
end;//
delimiter ;
drop procedure sp3;
call SP3('2024-01-09','2024-09-16');

-- Q4
delimiter //
create procedure sp4 (date1 date , date2 date)
begin 
	declare p int;
	if exists (select NumCom from LigneCommande inner join commande using(NumCom) where DatCam between date1 and date2) then	
		select 'hdhd';
		set p = (select count(NumCom) from LigneCommande inner join commande using(NumCom) where DatCam between date1 and date2);
        call sp3(date1,date2);
			if(p>10)then
				select "periode rouge" as message;
			elseif(p>5 and p<10) then
				select "periode jaune" as message;
			else
				select "periode blanch" as message;
			end if;
	else
		select "aucun commande entre cette dates" as Message;
	end if;
end;//
delimiter ;
call sp4('2024-01-10','2024-09-10');
drop procedure sp4;


-- Q5
delimiter //
create procedure sp5(n_cmd int, n_article int , qte float)
begin 
declare q int;
 if exists (select * from Article where NumArt=n_article) then
	set q =(select QteEnStock from article where NumArt=n_article);
    select q ;
    if(q>0 and q>=qte)then
		if exists (select * from commande where NumCom=n_cmd) then 
			if exists (select * from LigneCommande where NumArt=n_article and NumCom=n_cmd)then 
				update LigneCommande set QteCommandee=qte where NumCom=n_cmd ;
				update article set QteEnStock=QteEnStock-qte where NumArt=n_article;
				select 'quantite cmd bien modifier' as message;
            else
				insert into LigneCommande values (n_cmd,n_article,qte);
				update Article set QteEnStock=QteEnStock-qte where NumArt=n_article;
				select 'Commande bien ajouter' as message;
            end if;
        else
			insert into commande values (n_cmd,curdate());
			insert into LigneCommande values (n_cmd,n_article,qte);
			update Article set QteEnStock=QteEnStock-qte where NumArt=n_article;
			select "Commande bien ajouter" as message;
        end if;
    else
		select "auccun quantite" as message;
	end if;
 else 
	select "auccun article " as message;
 end if;
end;//
delimiter ;
call sp5(1004,2,2);
drop procedure sp5;

select * from Article;
select * from Commande;
select * from LigneCommande;







-- exercice 3

CREATE TABLE EMPLOYE2 (
    Matricule INT PRIMARY KEY auto_increment,
    Nom VARCHAR(100),
    Prenom VARCHAR(100),
    Echelle INT
);


CREATE TABLE SERVICE (
    Numero INT PRIMARY KEY auto_increment,
    Nom VARCHAR(100),
    Adresse VARCHAR(150)
);


CREATE TABLE PROJET (
    Code INT AUTO_INCREMENT PRIMARY KEY,
    Matricule INT,
    Numero INT,
    DateDebut DATE,
    NbreJour INT,
    Comission float,
    FOREIGN KEY (Matricule) REFERENCES EMPLOYE2(Matricule),
    FOREIGN KEY (Numero) REFERENCES SERVICE(Numero)
);

-- Q1


INSERT INTO EMPLOYE2 (Matricule, Nom, Prenom, Echelle)
VALUES
(101, 'EL ALAOUI', 'Ahmed', 7),
(102, 'BOUHROUM', 'Fatima', 8),
(103, 'ESSAKALLI', 'Omar', 6),
(104, 'NAJMI', 'Sara', 9),
(105, 'LACHHAB', 'Yassine', 7),
(106, 'BENJELLOUN', 'Khalid', 7),
(107, 'EL MALKI', 'Hind', 6),
(108, 'KOUTBI', 'Nour', 9),
(109, 'SAHLI', 'Youssef', 8),
(110, 'CHAHBI', 'Leila', 7),
(111, 'MAHFOUDI', 'Rachid', 8),
(112, 'AZIZI', 'Salma', 6),
(113, 'BOUSKRI', 'Imane', 9),
(114, 'AKKAOUI', 'Mounir', 7),
(115, 'RAFIQI', 'Mohamed', 6),
(116, 'OUARZAZI', 'Souad', 8),
(117, 'BENOMAR', 'Ali', 9),
(118, 'SEBTI', 'Lamia', 7),
(119, 'JABRI', 'Karim', 8),
(120, 'ESSAIDI', 'Samira', 6);


INSERT INTO SERVICE (Numero, Nom, Adresse)
VALUES
(1, 'Informatique', 'Boulevard Mohammed V, Casablanca'),
(2, 'Ressources Humaines', 'Avenue Hassan II, Rabat'),
(3, 'Marketing', 'Route de Fès, Marrakech'),
(4, 'Finance', 'Avenue des FAR, Casablanca'),
(5, 'Logistique', 'Avenue Allal El Fassi, Fès'),
(6, 'Développement', 'Technopark, Casablanca'),
(7, 'Support Technique', 'Avenue Zerktouni, Rabat'),
(8, 'Ventes', 'Boulevard Al Massira, Tanger'),
(9, 'Achats', 'Rue de la Liberté, Agadir'),
(10, 'Relations Publiques', 'Avenue Moulay Youssef, Oujda'),
(11, 'Gestion de Projet', 'Rue des Fleurs, Meknès'),
(12, 'Recherche & Développement', 'Boulevard Hassan II, Kénitra'),
(13, 'Service Client', 'Route de Casablanca, Essaouira'),
(14, 'Gestion des Stocks', 'Avenue des FAR, Laâyoune'),
(15, 'Administration', 'Boulevard Moulay Slimane, El Jadida');



INSERT INTO PROJET (Matricule, Numero, DateDebut, NbreJour, Comission)
VALUES
(106, 6, '2024-06-01', 20, 13000.00),
(107, 7, '2024-06-15', 25, 17000.00),
(108, 8, '2024-07-01', 30, 20000.00),
(109, 9, '2024-07-10', 15, 11000.00),
(110, 10, '2024-07-20', 20, 9000.00),
(111, 11, '2024-08-01', 25, 15000.00),
(112, 12, '2024-08-15', 10, 7000.00),
(113, 13, '2024-09-01', 20, 12000.00),
(114, 14, '2024-09-10', 30, 18000.00),
(115, 15, '2024-09-20', 25, 16000.00);

select * from projet;

-- Q2

delimiter //
create procedure p2(mt int ,n varchar(100),p varchar(100),echel int)
begin
	if exists(select * from EMPLOYE2 where Matricule=mt) then
    select "employe deja exists " as message;
    else
		insert into employe2 values (mt,n,p,echel);
        select "employe bien ajouter" as message;
	end if;
end;//
delimiter ;

call p2(130,'el gargati','mohammed',1);
drop procedure p2;
    
delimiter //
create procedure p3(numero_s int ,nom_s varchar(100), adresse_s varchar(150))
begin
	if exists(select * from service where Numero=numero_s)then
		select "service deja exists" as message;
	else
    insert into service values(numero_s,nom_s,adresse_s);
		select "service bien ajouter"as message;
	end if;
end;//
delimiter ;
call p3(18,'service 18','marrakech');

-- Q4
delimiter //
create procedure p4(code_p int , mt int , num_s int,date_d date ,nbj int,comission float)
begin 
	if exists (select * from projet where Code=code_p) then
			select "projet deja exists" as message;
	elseif not exists (select * from employe2 where matricule=mt) then
		select "employe not exists" as message;
	elseif not exists (select * from service where numero=num_s) then
			select "service not exists" as message;
	elseif exists (select * from projet where Matricule=mt and date_add(DateDebut,interval NbreJour day)>curdate())then
			select "employe not free" as message;
	else
		insert into projet values (code_p,mt,num_s,date_d,nbj,comission);
        select "projet bien ajouter" as message;
	end if;
end;//
delimiter ;

call p4(303,108,100,'2024-01-28',12,700.00);
select * from projet;
delimiter //

-- Q5
create procedure p5(code_p int)
begin
	if not exists (select * from projet where code = code_p) then
		select "code not exists" as message;
	elseif exists (select * from projet where code = code_p and date_add(DateDebut,interval NbreJour day) > curdate() ) then 
		select "projet en cours de realisation" as message;
	else
		delete from projet where code=code_p;
        select "projet bien supprimer" as message;
	end if;
end;//
delimiter ;
drop procedure p5;
call p5(1);

-- Q6
delimiter //
create procedure p6(mt int)
begin
	if not exists (select * from employe2 where matricule = mt) then
		select "employe not exists" as message;
	elseif not exists (select * from projet where matricule = mt and date_add(DateDebut,interval NbreJour day) > curdate() ) then 
		select "employe en cours de realises un projet" as message;
	else
		delete from employe2 where matricule=mt;
        select "employe bien supprimer" as message;
	end if;
end;//
delimiter ;
drop procedure p6;
call p6(112);
delete from employe2 where matricule=111;
select *from employe2

    
        



