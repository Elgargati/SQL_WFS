use tp3;
select * from departement3;
alter table employe modify column paie varchar(30) ;
 delimiter //
 
-- 1
create trigger AnnuleMiseAjour
before update
on employe
for each row
begin
  if(dayname(curdate()) in ("saturday","sunday")) then
    signal sqlstate "45000" set message_text="Les mises a jour ne sont pas autorisees le weekend"; 
  end if; 
end//
update employe set nom_emp="nom11" where num_emp=1//

-- 2
create trigger VerifierDep
before insert
on departement3
for each row
begin
  if(new.nom_dep is null )then
	  signal sqlstate "45000" set message_text="Il faut precise le nom du departement !";
  elseif exists (select * from departement3 where nom_dep=new.nom_dep)then
  	  signal sqlstate "45000" set message_text="Departement deja existe ! ";
  end if;
end// 

insert into departement3 values(11,"dep1",null)//

-- 3
create trigger VerifierPaie
before insert  
on employe
for each row
begin
    if new.Paie = 'Par heure' and new.Salaire < 75 then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le salaire horaire doit être supérieur à 75.';
    elseif new.Paie != 'Par heure' and new.Salaire < 10000 then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le salaire mensuel doit être supérieur à 10000.';
    end if;
END//
create trigger VerifierPaie2
before update  
on employe
for each row
begin
    if new.Paie = 'Par heure' and new.Salaire < 75 then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le salaire horaire doit être supérieur à 75.';
    elseif new.Paie != 'Par heure' and new.Salaire < 10000 then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le salaire mensuel doit être supérieur à 10000.';
    end if;
END//

insert into employe(num_emp,salaire,paie) values(15,80,"par mois")//
insert into employe(num_emp,salaire,paie) values(15,70,"par heure")//
insert into employe(num_emp,salaire,paie) values(15,80,"par heure")//

-- 4
 CREATE TABLE Historique_Salaires (
    matricule INT,
    ancien_salaire DECIMAL(10, 2),
    nouveau_salaire DECIMAL(10, 2),
    date_changement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)//

create trigger TracesUpdateSalaire
BEFORE UPDATE 
ON employe
for each row
begin
    if old.salaire != new.salaire then
        insert into Historique_Salaires (matricule, ancien_salaire, nouveau_salaire) values (OLD.matricule, OLD.salaire, NEW.salaire);
    end if;
end//

INSERT INTO employe
VALUES (83, 'Durand', 'Marie', 15000 ,20,'1990-04-10', 'par heure', '2023/09/06')//
UPDATE employe
SET Salaire = 16000
WHERE Matricule = 83//
SELECT * FROM Historique_Salaires WHERE Matricule = 83//

-- 5
alter table departement3 add column nbrEmployes int default 0//
update departement3 set nbrEmployes=(select count(num_emp) from employe where num_dep=30 )  where num_dep=30//

create trigger update_nbr_employes
AFTER INSERT 
on employe
for each row
begin
    update departement3
    SET NbrEmployes = NbrEmployes + 1
    where Num_dep = new.Num_dep;
END//
select * from departement3//
insert into employe(num_emp,num_dep) values(17,10)//


-- 6
CREATE TRIGGER suppression
before delete
ON departement
FOR EACH ROW
BEGIN

    delete from employe where num_dep = old.num_dep ;
END// 
