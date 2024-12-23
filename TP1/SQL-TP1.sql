-- excerece1
create database work;
use work;
create table departement(
		num_dep int primary key,
        nom_dep varchar(30),
        ville_dep varchar(30)
);
insert into departement values
(1,'informatique','marrakech'),
(2,'finance','casa'),
(3,'commerce','marrakech'),
(4,'sport','rabat');

create table employe(
		matricule int primary key ,
        nom_emp varchar(30),
        prenom_emp varchar(30),
        datenaissance_emp date,
        salaire_emp float,
        num_dep int,
        foreign key(num_dep) references departement(num_dep)
);
insert into employe values
(1,'nom1','prenom1','2001/01/1',1000,1),
(2,'nom2','prenom2','2002/02/2',2000,3),
(3,'nom3','prenom3','2003/03/3',3000,1),
(4,'nom4','prenom4','2004/04/4',4000,2),
(5,'nom5','prenom5','2005/05/5',5000,3),
(6,'nom6','prenom6','2001/06/6',6000,4),
(7,'nom7','prenom7','2007/07/7',7000,3),
(8,'nom8','prenom8','2008/08/8',7000,3);
create table vente (
	num_vente int primary key ,
    matricule int ,
    date_vente date ,
    montant float,
    foreign key(matricule) references employe(matricule) 
);
insert into vente values 
('101','1','2021/01/10',1700),
('102','2','2022/03/19',1200),
('103','3','2024/04/18',600),
('104','1','2020/08/04',500),
('105','4','2022/09/03',599),
('106','5','2019/05/16',850),
('107','1','2016/04/12',360),
('108','4','2024/03/18',1200),
('109','3','2023/07/24',2400),
('110','7','2024/04/30',1300),
('111','2','2024/08/31',780),
('112','6','2024/03/15',2399);

select * from vente;
select * from employe;
select * from departement;

-- Q1
delimiter //
create function salaire_moyen (dep int)
returns float
reads sql data
begin
	declare somme float;
    set somme = (select avg(salaire_emp) from employe where num_dep = dep);
    return somme;
end;//
delimiter ;
select salaire_moyen(1);

-- Q2
delimiter //
create function diff_salaire (emp1 int ,emp2 int)
returns float
reads sql data
begin
	declare s1 float;
	declare s2 float;
	declare somme float;
    set s1 =(select salaire_emp from employe where matricule=emp1);
    set s2 =(select salaire_emp from employe where matricule=emp2);
    set somme = (abs( s1-s2));
    return somme;
end;//
delimiter ;
select diff_salaire(1,2);


delimiter //
create function ville_donnee(ville varchar(100))
returns int
reads sql data
begin 
	declare res int;
    set res=(select count(matricule) from employe inner join departement using(num_dep) where ville_dep =ville);
    return res;
end ;//
delimiter ;
select ville_donnee('marrakech');
-- Q4
delimiter //
create function nom_complete ()
returns varchar(100)
reads sql data
begin 
	declare res varchar(100);
    set res=( select max(concat(prenom_emp ," ", nom_emp)) from employe where salaire_emp =(select max(salaire_emp) from employe));
    return res;
end;//
delimiter ;

select nom_complete();
select * from employe;

-- Q5
delimiter //
create function nom_age()
returns varchar(100)
reads sql data
begin 
	declare res varchar(100);
    set res=( select max(concat(prenom_emp ," ", nom_emp)) from employe where datenaissance_emp =(select min(datenaissance_emp) from employe));
    return res;
end ;//
delimiter ;
select nom_age();

-- Q6
delimiter //
create function total_vente(mt int, annee int)
returns float
reads sql data
begin
	declare nb float;
    set nb=(select sum(montant) from vente where matricule=mt and year(date_vente)=annee);
    return nb;
end;//
delimiter ;
select total_vente(2,2021);
select * from vente;


-- excerce 2
create table client (
		codeclt int primary key,
		nomclt varchar(100),
		prenomclt varchar(100),
		adresseclt varchar(100),
		cpclt int,
		villeclt varchar(100)
);
create table representant(
	coderep int primary key,
    nomrep varchar(100),
    prenomrep varchar(100)
);
create table appartement (
		ref int primary key ,
        superficie float,
        pxvente float,
        secteur varchar(200),
        coderep int,
        codeclt int,
        foreign key (coderep) references representant(coderep),
        foreign key (codeclt) references client(codeclt)
);
select * from client;
select * from representant;
select * from appartement;

-- Q1
delimiter //
create function nb_appartement(code_rep int)
returns int
reads sql data
begin
	declare nb int;
    set nb=(select count(ref) from appartement where coderep = code_rep);
    return nb;
end;//
delimiter ;
select nb_appartement(4);

-- Q2
delimiter //
create function sm_superficies(nom varchar(100))
returns float
reads sql data
begin 
	declare somme float;
    set somme=(select sum(superficie) from appartement inner join representant using(coderep) where nomrep=nom );
    return somme;
end;//
delimiter ;
select sm_superficies('rachid');

-- Q3
delimiter //
create function sm_pxvente(code int)
returns float
reads sql data
begin 
	return (select sum(pxvente) from appartement inner join representant using(coderep) where coderep=code);
end;//
delimiter ;
select sm_pxvente(12);

-- Q4
delimiter //
create function nb_client(nom varchar(100),prenom varchar(100))
returns int
reads sql data
begin
	declare res int;
    set res = (select count(codeclt)
    from appartement inner join representant using(coderep)
    inner join client using(codeclt) where nomrep = nom and prenomrep=prenom);
    return res;
end;//
delimiter ;
select nb_client('ayoub','immoayoub');
    
    
    
    
    
    
-- excercice 3
    
CREATE TABLE CLIENTS (
    codeclt INT PRIMARY KEY AUTO_INCREMENT, 
    nomclt VARCHAR(100) ,           
    prenomclt  VARCHAR(100) ,  
    adresse VARCHAR(100) ,  
    CP  VARCHAR(100) ,   
    ville  VARCHAR(100)
);

CREATE TABLE PRODUIT (
    reference INT PRIMARY KEY AUTO_INCREMENT,
    designation VARCHAR(100) ,        
    prix float            
    );

CREATE TABLE TECHNICIEN (
    codetec INT PRIMARY KEY AUTO_INCREMENT, 
    nomtec  VARCHAR(100) ,           
    prenomtec  VARCHAR(100) ,        
    tauxhoraire float   
);

CREATE TABLE INTERVENTION (
    numero INT PRIMARY KEY AUTO_INCREMENT,   
    date DATE ,                      
    raison VARCHAR(100) ,  
    codeclt INT,                             
    reference INT,                           
    codetec INT,                             
    FOREIGN KEY (codeclt) REFERENCES CLIENT(codeclt) ON DELETE CASCADE,
    FOREIGN KEY (reference) REFERENCES PRODUIT(reference) ON DELETE CASCADE,
    FOREIGN KEY (codetec) REFERENCES TECHNICIEN(codetec) ON DELETE CASCADE
);

INSERT INTO CLIENTS (nomclt, prenomclt, adresse, CP, ville)
VALUES
    ('El Mansouri', 'Ahmed', '15 Rue Hassan II', '10000', 'Rabat'),
    ('Bouzid', 'Fatima', '32 Avenue Mohammed V', '20000', 'Casablanca'),
    ('Chakir', 'Youssef', '10 Boulevard Moulay Idriss', '30000', 'Fès');

INSERT INTO PRODUIT (designation, prix)
VALUES
    ('Ordinateur Portable', 1200.00),
    ('Imprimante', 250.00),
    ('Clavier Sans Fil', 35.00);
    
INSERT INTO TECHNICIEN (nomtec, prenomtec, tauxhoraire)
VALUES
    ('Naji', 'Rachid', 150.00),
    ('Haddad', 'Khadija', 140.00),
    ('El Fassi', 'Mohamed', 160.00);

INSERT INTO INTERVENTION (date, raison, codeclt, reference, codetec)
VALUES
    ('2024-09-23', 'Reparation de l\'imprimante', 1, 2, 1),
    ('2024-09-20', 'Installation d\'un ordinateur', 2, 1, 2),
    ('2024-09-21', 'Remplacement du clavier sans fil', 3, 3, 3);
 select * from CLIENTS;
 select * from PRODUIT;
 select * from TECHNICIEN;
 select * from INTERVENTION;
 
-- Q1
delimiter //
create function nb_client_ville(vl varchar(100))
returns int
reads sql data
begin
	declare sm int;
    set sm=(select count(codeclt) from CLIENTS where ville=vl );
    return sm;
end;//
delimiter ;
select * from CLIENTS;
select nb_client_ville('Marrakech');

-- Q2
delimiter //
create function nb_interventions(nom varchar(100))
returns int
reads sql data
begin
	declare sm int;
    set sm=(select count(numero) from INTERVENTION inner join TECHNICIEN using(codetec) where nomtec=nom);
    return sm;
end;//
delimiter ;
select nb_interventions('Haddad');


-- Q3
delimiter //
create function sm_prix_vente(nom varchar(100), dateDebut date, dateFin date)
returns float
reads sql data
begin 
 declare sm float;
 set sm = (select sum(prix) from clients inner join intervention using(codeclt) inner join produit using(reference) where nomclt=nom and date between dateDebut and dateFin );
 return sm;
end;//
delimiter ;
select sm_prix_vente('Bouzid','2020-01-01','2024-12-12') as 'somme des prix';
select nomclt, sum(prix) from client inner join intervention using(codeclt) inner join produit using(reference) where nomclt='Naji' and date between '2024-01-01' and '2020-01-01';
drop function sm_prix_vente;



-- Q4
delimiter //
create function sm_ville(nom varchar(100))
returns int
reads sql data
begin
	declare sm int;
    set sm=(select count(distinct ville) from INTERVENTION inner join CLIENTS using(codeclt) inner join TECHNICIEN using(codetec) where nomtec=nom);
    return sm;
end;//
delimiter ;
select sm_ville('Haddad');

-- Q5
delimiter //
create function nbr_clt_inter(date1 date , date2 date)
 returns int
 reads sql data
 begin
 return (select count(codeclt) from  CLIENTS where codeclt not in (select codeclt from INTERVENTION where date between date1 and date2));
 end;//
 
 delimiter ;
select nbr_clt_inter("2025-02-02","2026-12-12");








