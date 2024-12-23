DELIMITER //
use tp1//
select * from client//
select * from produit//
select * from commande//
select * from detail//
alter table produit add column qte_dispo int default 10 //
alter table client add column tel varchar(12) //
CREATE TABLE commande (
    numero INT AUTO_INCREMENT PRIMARY KEY,
    codeclt INT,
    datecmd DATE,
    FOREIGN KEY (codeclt) REFERENCES client(codeclt)
)//

CREATE TABLE detail (
    numero INT,
    codeprd INT,
    qte_cmd INT,
    PRIMARY KEY (numero, codeprd),
    FOREIGN KEY (numero) REFERENCES commande(numero),
    FOREIGN KEY (codeprd) REFERENCES produit(ref)
)//


-- 2

CREATE TRIGGER ajouter_produit
before INSERT
ON produit
for each row
begin
    if (new.qte_dispo < 0) then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= "Quantite non acceptee" ;
    end if;
end//

select * from produit //
insert into produit  values (5,"produit5", 700 , -6)//

-- 3
create trigger miseajoure_detail
before update
ON detail
for each row
begin
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= "la table detail ne peut pas etre modifie" ;
end//
select * from detail //
update detail set qte_cmd=6 where numero=1 //

-- 4

CREATE TRIGGER n_Commande
BEFORE INSERT ON commande
FOR EACH ROW
BEGIN
    DECLARE n INT;

    SET n = NEW.numero;

    WHILE EXISTS (SELECT 1 FROM commande WHERE numero = n) DO
        SET n = n + 1;
    END WHILE;

    SET NEW.numero = n;
END //
drop trigger new_cmd//
select * from commande //
insert into commande values (1,1,"2023-10-12")//


-- 5 
alter table commande add column montant float default 0 //

CREATE TRIGGER miseajour_detail
AFTER INSERT 
ON detail
FOR EACH ROW
BEGIN
    declare total_montant float;
    declare qte int;
    
    select (prix*new.qte_cmd) , qte_dispo into total_montant , qte from produit where  ref=new.codeprd;

    SET qte = qte - new.qte_cmd ;

    if (qte < 0) then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantité de produit insuffisante. Opération annulée.';
	else
		update commande set montant = total_montant where numero = new.numero;
		update produit set qte_dispo = qte where ref=new.codeprd;
    end if;
end//
select * from commande//
select * from detail//
select * from produit//
insert into detail values(4,3,2)//

-- 6
CREATE TABLE historique_client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codeclt INT,
    ancien_tel VARCHAR(20),
    nouv_tel VARCHAR(20),
    date_changement DATE
)//

CREATE TRIGGER historique_client
AFTER UPDATE
ON client
FOR EACH ROW
BEGIN
    insert into historique_client (codeclt  ,ancien_tel  , nouv_tel  , date_changement) values (old.codeclt,old.tel,new.tel,now()) ;
END//
select * from client//
select * from historique_client//
update client set tel = "06754321" where codeclt =2//

-- 7
 CREATE TRIGGER suppression
before delete
ON detail
FOR EACH ROW
BEGIN
    update commande set montant = 0 where numero=old.numero ;
	update produit set qte_dispo = qte_dispo + old.qte_cmd where ref = old.codeprd;
END//