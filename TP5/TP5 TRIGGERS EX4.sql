CREATE DATABASE DB3_TRIGGER;
USE DB3_TRIGGER;


CREATE TABLE Client (
    NumCli INT PRIMARY KEY,
    NomCli VARCHAR(100),
    CIN VARCHAR(20) UNIQUE
);


CREATE TABLE Compte (
    NumCpt INT PRIMARY KEY,
    TypeCpt VARCHAR(2) CHECK (TypeCpt IN ('CC', 'CN')),
    SoldeCpt DECIMAL(10, 2),
    NumCli INT,
    FOREIGN KEY (NumCli) REFERENCES Client(NumCli)
);


CREATE TABLE Opération (
    NumOp INT PRIMARY KEY,
    TypeOp CHAR(1) CHECK (TypeOp IN ('D', 'R')),
    DateOp DATE,
    Montant DECIMAL(10, 2),
    NumCpt INT,
    FOREIGN KEY (NumCpt) REFERENCES Compte(NumCpt)
);



INSERT INTO Client (NumCli, NomCli, CIN) VALUES
(1, 'Alice Dupont', 'CIN123456'),
(2, 'Bob Martin', 'CIN654321'),
(3, 'Charlie Durand', 'CIN789012');

INSERT INTO Compte (NumCpt, TypeCpt, SoldeCpt, NumCli) VALUES
(101, 'CC', 2000.00, 1),
(102, 'CN', 1500.00, 1),
(103, 'CC', 3000.00, 2),
(104, 'CN', 1000.00, 2),
(105, 'CN', 500.00, 3);

INSERT INTO Opération (NumOp, TypeOp, DateOp, Montant, NumCpt) VALUES
(1, 'D', '2024-01-01', 500.00, 101),
(2, 'R', '2024-01-02', 200.00, 101),
(3, 'D', '2024-01-03', 1000.00, 102),
(4, 'R', '2024-01-04', 300.00, 103),
(5, 'D', '2024-01-05', 700.00, 104),
(6, 'R', '2024-01-06', 100.00, 105);








-- 1
DELIMITER //
CREATE TRIGGER verif_num_cin
BEFORE INSERT 
ON Client
FOR EACH ROW
BEGIN
    DECLARE num_cin_count INT;
    SELECT COUNT(*) INTO num_cin_count
    FROM Client
    WHERE NumCli = NEW.NumCli;
    
    IF num_cin_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le numéro de CIN existe déjà pour un autre client.';
    END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER verif_num_cin
BEFORE UPDATE 
ON Client
FOR EACH ROW
BEGIN
    DECLARE num_cin_count INT;
    SELECT COUNT(*) INTO num_cin_count
    FROM Client
    WHERE NumCli = NEW.NumCli;
    
    IF num_cin_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le numéro de CIN existe déjà pour un autre client.';
    END IF;
END;
//
DELIMITER ;







-- 2
DELIMITER //
CREATE TRIGGER verif_creation_compte
BEFORE INSERT ON Compte
FOR EACH ROW
BEGIN
	DECLARE compte_count INT;
    IF NEW.SoldeCpt <= 1500 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le solde doit être supérieur à 1500 DH.';
    END IF;
    
    IF NEW.TypeCpt NOT IN ('CC', 'CN') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le type de compte doit être CC ou CN.';
    END IF;

    SELECT COUNT(*) INTO compte_count
    FROM Compte
    WHERE NumCli = NEW.NumCli AND TypeCpt = NEW.TypeCpt;
    
    IF compte_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le client a déjà un compte de ce type.';
    END IF;
END;
//
DELIMITER ;








-- 3
DELIMITER //
CREATE TRIGGER interdiction_suppression_compte
BEFORE DELETE ON Compte
FOR EACH ROW
BEGIN
	DECLARE date_diff INT;
    IF OLD.SoldeCpt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer un compte avec un solde positif.';
    END IF;
    
    SELECT DATEDIFF(CURDATE(), (SELECT MAX(DateOp) FROM Opération WHERE NumCpt = OLD.NumCpt)) INTO date_diff;
    
    IF date_diff < 90 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible de supprimer un compte avec des opérations récentes.';
    END IF;
END;
//
DELIMITER ;









-- 4
delimiter //
CREATE TRIGGER interdiction_modification_compte
BEFORE UPDATE ON Compte
FOR EACH ROW
BEGIN
	DECLARE compte_count INT;
    IF OLD.NumCpt != NEW.NumCpt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Modification du numéro de compte interdite.';
    END IF;
    
    IF OLD.SoldeCpt != NEW.SoldeCpt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Modification du solde interdite pour les comptes avec des opérations associées.';
    END IF;
    
    IF OLD.TypeCpt = 'CN' AND NEW.TypeCpt = 'CC' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Conversion de compte sur carnet en compte courant interdite.';
    END IF;

    SELECT COUNT(*) INTO compte_count
    FROM Compte
    WHERE NumCli = NEW.NumCli AND TypeCpt = NEW.TypeCpt;
    
    IF compte_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le client a déjà un compte de ce type.';
    END IF;
END;

//
delimiter ;