--  ex03

-- Create tables
CREATE TABLE CLIENT (
    Codeclt VARCHAR(10) PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    tel VARCHAR(15)
);
CREATE TABLE PRODUIT (
    Codeprd VARCHAR(10) PRIMARY KEY,
    designation VARCHAR(100),
    prix DECIMAL(10,2),
    qte_dispo INT
);

CREATE TABLE COMMANDE (
    numero INT PRIMARY KEY,
    Codeclt VARCHAR(10),
    datecmd DATE,
    Montant DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (Codeclt) REFERENCES CLIENT(Codeclt)
);

CREATE TABLE DETAIL (
    numero INT,
    Codeprd VARCHAR(10),
    qte_cmd INT,
    PRIMARY KEY (numero, Codeprd),
    FOREIGN KEY (numero) REFERENCES COMMANDE(numero),
    FOREIGN KEY (Codeprd) REFERENCES PRODUIT(Codeprd)
);

CREATE TABLE Historique_Client (
    numero INT AUTO_INCREMENT PRIMARY KEY,
    Codeclt VARCHAR(10),
    ancien_tel VARCHAR(15),
    nouv_tel VARCHAR(15),
    date_changement DATE
);
select * from detail;
-- Insert test data
INSERT INTO CLIENT VALUES 
('C1', 'Hamidi', 'said', '0611223344'),
('C2', 'chraibi', 'ouadie', '0622334455'),
('C3', 'el hrou', 'mohamed', '0633445566');

INSERT INTO PRODUIT VALUES 
('P1', 'Laptop', 1000.00, 10),
('P2', 'Mouse', 20.00, 50),
('P3', 'Keyboard', 50.00, 30);

INSERT INTO COMMANDE (numero, Codeclt, datecmd) VALUES 
(1, 'C1', '2024-01-01'),
(2, 'C2', '2024-01-02'),
(3, 'C3', '2024-01-03');
delete from detail;
INSERT INTO DETAIL VALUES 
(1, 'P1', 2),
(1, 'P2', 3),
(2, 'P3', 1);
select * from client;
select * from Produit;
select * from detail;
select * from commande;
-- QU02: 
drop trigger check_qte_dispo;
DELIMITER //
CREATE TRIGGER check_qte_dispo
BEFORE insert ON PRODUIT
FOR EACH ROW
BEGIN
    IF NEW.qte_dispo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantite non acceptee!';
    END IF;
END//
DELIMITER ;

insert into produit values ('P4', "webcam", 4000, -400);
UPDATE PRODUIT SET qte_dispo = -5 WHERE Codeprd = 'P1';
select * from produit;

-- QU03: Prevent DETAIL modification
drop trigger prevent_detail_modification;
DELIMITER //
CREATE TRIGGER prevent_detail_modification
BEFORE UPDATE ON DETAIL
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La table DETAIL ne peut etre modifie!';
END//
DELIMITER ;

UPDATE DETAIL SET qte_cmd = 5 WHERE numero = 1 AND Codeprd = 'P1';
select * from detail;

-- QU04: 
DELIMITER //
CREATE TRIGGER increment_commande_number
BEFORE INSERT ON COMMANDE
FOR EACH ROW
BEGIN
    DECLARE new_num INT;
    SET new_num = NEW.numero;
    
    WHILE EXISTS (SELECT 1 FROM COMMANDE WHERE numero = new_num) DO
        SET new_num = new_num + 1;
    END WHILE;
    
    SET NEW.numero = new_num;
END//
DELIMITER ;
--  alternative : use max(num) and add 1 then check  if max==null
select * from client;
select * from commande;

INSERT INTO COMMANDE (numero, Codeclt, datecmd) VALUES 
(1, 'C5', '2024-01-04');


-- QU05: Update command amount and product quantity
select * from commande;
drop trigger update_commande_amount;
DELIMITER //
CREATE TRIGGER update_commande_amount
AFTER INSERT ON DETAIL
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE prod_price DECIMAL(10,2);
    DECLARE current_qte INT;
    
    -- produit prix et quantiteeee
    SELECT prix, qte_dispo INTO prod_price, current_qte
    FROM PRODUIT
    WHERE Codeprd = NEW.Codeprd;
    
    -- Check quantity available
    IF current_qte < NEW.qte_cmd THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantitee disponible insuffisante!';
    END IF;
    
    -- Update quantite
    UPDATE PRODUIT SET qte_dispo = qte_dispo - NEW.qte_cmd WHERE Codeprd = NEW.Codeprd;
    
    -- update total
    update commande set Montant = Montant + (prod_price * new.qte_cmd) where numero = new.numero;
END//
DELIMITER ;
select * from produit;
select * from commande;
select * from detail;
insert into detail values (20, "p1", 10);
INSERT INTO PRODUIT VALUES 
('P4', 'Printer', 300.00, 5),
('P5', 'Scanner', 200.00, 8);

INSERT INTO DETAIL VALUES (3, 'P2', 2);
SELECT * FROM COMMANDE;
SELECT * FROM PRODUIT;
select * from detail;

INSERT INTO DETAIL VALUES (16, 'P2', 10);

-- QU06: 

select * from Historique_Client;
DELIMITER //
CREATE TRIGGER track_tel
AFTER UPDATE ON CLIENT
FOR EACH ROW
BEGIN
    IF NEW.tel != OLD.tel THEN
        INSERT INTO Historique_Client (Codeclt, ancien_tel, nouv_tel, date_changement)
        VALUES (NEW.Codeclt, OLD.tel, NEW.tel, CURRENT_DATE());
    END IF;
END//
DELIMITER ;
UPDATE CLIENT SET tel = '0611223344' WHERE Codeclt = 'C1';
SELECT * FROM Historique_Client;

-- QU07 
drop trigger delete_commande_amount;
DELIMITER //
CREATE TRIGGER delete_commande_amount
AFTER delete ON DETAIL
FOR EACH ROW
BEGIN
   
    DECLARE prod_price DECIMAL(10,2);
    
    -- produit prix et quantiteeee
    SELECT prix INTO prod_price
    FROM PRODUIT
    WHERE Codeprd = old.Codeprd;
    
    
    -- Update quantite
    UPDATE PRODUIT 
    SET qte_dispo = qte_dispo + old.qte_cmd
    WHERE Codeprd = old.Codeprd;
    
    -- update total
    update commande set Montant = Montant - (prod_price * old.qte_cmd) where numero = old.numero;
END//
DELIMITER ;


select * from detail;
select * from produit;
select * from commande;
delete from detail where numero = 16;





# -------------------- EX4 ------------------------

select * from operation ;
CREATE TABLE Operation (
  NumOp INT PRIMARY KEY AUTO_INCREMENT,
  TypeOp VARCHAR(50),
  MtOp DECIMAL(10,2),
  NumCpt INT,
  Dateop DATE,
  FOREIGN KEY (NumCpt) REFERENCES Compte(NumCpt)
);

CREATE TABLE Compte (
  NumCpt INT PRIMARY KEY AUTO_INCREMENT,
  SoldeCpt DECIMAL(10,2),
  TypeCpt VARCHAR(50),
  NumCli INT,
  FOREIGN KEY (NumCli) REFERENCES Client3(NumCli)
);

CREATE TABLE Client3 (
  NumCli INT PRIMARY KEY AUTO_INCREMENT,
  CINCli VARCHAR(20),
  NomCli VARCHAR(50),
  AdrCli VARCHAR(100),
  TelCli VARCHAR(20)
);

alter table client3 modify column cincli varchar(30);

select * from client3;
select * from operation ;
select * from compte ;


-- 1. 
select * from client3;
DELIMITER //
CREATE TRIGGER check_unique_cin
BEFORE INSERT 
ON Client3
FOR EACH ROW
BEGIN
    DECLARE existing_cin int;
    SELECT COUNT(*) INTO existing_cin FROM Client WHERE  CINCli = NEW.CINCli;    
    IF existing_cin > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CIN already exists for another client';
    END IF;
END; //
DELIMITER ;
drop trigger check_unique_cin ;

insert into Client3  values (4,"CIN123456","nom4","adresse4","0345678902");



DELIMITER //
CREATE TRIGGER check_unique_cin_update
BEFORE UPDATE ON Client3
FOR EACH ROW
BEGIN
    DECLARE existing_cin int;
    SELECT COUNT(*) INTO existing_cin FROM Client WHERE CINCli = NEW.CINCli ;
    
    IF existing_cin > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CIN already exists for another client';
    END IF;
END ; //
DELIMITER ;
drop trigger check_unique_cin_update ;

update client3 set cincli = "CIN234567" where numcli = 1 ;

select * from client3 ;


-- 2. 
DELIMITER //
CREATE TRIGGER validate_account_creation
BEFORE INSERT ON Compte
FOR EACH ROW
BEGIN
    DECLARE account_type_count INT;
        SELECT COUNT(*) INTO account_type_count  FROM Compte  WHERE NumCli = NEW.NumCli AND TypeCpt = NEW.TypeCpt;
    IF account_type_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client already has an account of this type';
    END IF;

    IF NEW.SoldeCpt <= 1500 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balance must be greater than 1500 DH';
    END IF;

    IF NEW.TypeCpt NOT IN ('CC', 'CN') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account type must be CC or CN';
    END IF;
END; //
DELIMITER ;

select * from compte;

-- 3. 
DELIMITER //
CREATE TRIGGER prevent_account_deletion
BEFORE DELETE ON Compte
FOR EACH ROW
BEGIN
    DECLARE account_balance DECIMAL(10, 2);
    DECLARE last_operation_date DATE;
    
	SELECT SoldeCpt INTO account_balance FROM Compte WHERE NumCpt = OLD.NumCpt;
    IF account_balance > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete account with balance greater than 0';
	Else 
     SELECT MAX(Dateop) INTO last_operation_date  FROM Operation WHERE NumCpt = OLD.NumCpt;
    IF last_operation_date IS NOT NULL AND last_operation_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
       THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete account with operations in the last 3 months';
    END IF;
    END IF;
    
END; //
DELIMITER ;
drop trigger prevent_account_deletion;

select * from compte;
select * from operation ;

-- 4.
DELIMITER //
CREATE TRIGGER restrict_account_modifications
BEFORE UPDATE ON Compte
FOR EACH ROW
BEGIN
    DECLARE operation_count INT;
	DECLARE client_account_count INT;


    IF OLD.NumCpt != NEW.NumCpt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Modification of account numbers is not allowed';
    END IF;
	
    IF OLD.soldecpt != NEW.soldecpt THEN
    SELECT COUNT(*) INTO operation_count FROM Operation WHERE NumCpt = OLD.NumCpt;
    IF operation_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot modify balance for accounts with associated operations';
    END IF;
     END IF;
    

    IF OLD.TypeCpt = 'CN' AND NEW.TypeCpt = 'CC' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change account type from CN to CC';
    END IF;

    IF OLD.NumCli != NEW.NumCli AND EXISTS ( select * from compte where numcli = new.numcli and TypeCpt = old.TypeCpt 
    ) then
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New client already has an account of this type';
        END IF;
    -- END IF;
END; //
DELIMITER ;

drop trigger restrict_account_modifications ;

select * from compte ;
