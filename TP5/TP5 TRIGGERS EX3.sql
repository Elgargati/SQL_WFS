CREATE DATABASE db2_trigger;
USE db2_trigger;

CREATE TABLE CLIENT (
    Codeclt INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    tel VARCHAR(15)
);

CREATE TABLE PRODUIT (
    Codeprd INT PRIMARY KEY,
    designation VARCHAR(100),
    prix DECIMAL(10, 2),
    qte_dispo INT CHECK(qte_dispo >= 0)
);

CREATE TABLE COMMANDE (
    numero INT PRIMARY KEY,
    Codeclt INT,
    datecmd DATE,
    FOREIGN KEY (Codeclt) REFERENCES CLIENT(Codeclt)
);

CREATE TABLE DETAIL (
    numero INT,
    Codeprd INT,
    qte_cmd INT,
    PRIMARY KEY (numero, Codeprd),
    FOREIGN KEY (numero) REFERENCES COMMANDE(numero),
    FOREIGN KEY (Codeprd) REFERENCES PRODUIT(Codeprd)
);

INSERT INTO CLIENT (Codeclt, nom, prenom, tel) VALUES
(1, 'Dupont', 'Jean', '0612345678'),
(2, 'Martin', 'Sophie', '0623456789'),
(3, 'Bernard', 'Luc', '0634567890'),
(4, 'Durand', 'Marie', '0645678901');

INSERT INTO PRODUIT (Codeprd, designation, prix, qte_dispo) VALUES
(101, 'Laptop Lenovo', 899.99, 50),
(102, 'iPhone 12', 1099.50, 30),
(103, 'Samsung Galaxy Tab', 699.99, 40),
(104, 'Monitor LG 27"', 249.99, 25),
(105, 'Wireless Mouse', 19.99, 200);

INSERT INTO COMMANDE (numero, Codeclt, datecmd) VALUES
(1001, 1, '2024-10-21'),
(1002, 2, '2024-10-20'),
(1003, 3, '2024-10-19'),
(1004, 4, '2024-10-18');

INSERT INTO DETAIL (numero, Codeprd, qte_cmd) VALUES
(1001, 101, 2),
(1001, 105, 5),
(1002, 102, 1),
(1002, 104, 2),
(1003, 103, 1),
(1004, 105, 10);







-- 2
delimiter //
CREATE TRIGGER trg_check_quantity
BEFORE INSERT ON PRODUIT
FOR EACH ROW
BEGIN
    IF NEW.qte_dispo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantité non acceptée !';
    END IF;
END;//
delimiter ;







-- 3
delimiter //
CREATE TRIGGER trg_no_update_detail
BEFORE UPDATE ON DETAIL
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La table DETAIL ne peut être modifiée !';
END;
//
delimiter ;










-- 4
delimiter //
CREATE TRIGGER trg_unique_commande_num
BEFORE INSERT ON COMMANDE
FOR EACH ROW
BEGIN
    DECLARE next_num INT;
    SELECT COALESCE(MAX(numero), 0) + 1 INTO next_num FROM COMMANDE;
    IF NEW.numero IN (SELECT numero FROM COMMANDE) THEN
        SET NEW.numero = next_num;
    END IF;
END;
//
delimiter ;










-- 5
delimiter //
ALTER TABLE COMMANDE ADD Montant DECIMAL(10, 2);

CREATE TRIGGER trg_update_montant
AFTER INSERT ON DETAIL
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10, 2);
    DECLARE qte_dispo INT;

    -- Update the total of the order
    SELECT SUM(D.qte_cmd * P.prix) INTO total
    FROM DETAIL D
    JOIN PRODUIT P ON D.Codeprd = P.Codeprd
    WHERE D.numero = NEW.numero;
    
    UPDATE COMMANDE SET Montant = total WHERE numero = NEW.numero;

    -- Update the quantity of the product
    SELECT qte_dispo INTO qte_dispo FROM PRODUIT WHERE Codeprd = NEW.Codeprd;
    
    IF qte_dispo >= NEW.qte_cmd THEN
        UPDATE PRODUIT SET qte_dispo = qte_dispo - NEW.qte_cmd WHERE Codeprd = NEW.Codeprd;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantité insuffisante, opération annulée !';
    END IF;
END;
//
delimiter ;










-- 6
delimiter //
CREATE TABLE Historique_Client (
    numero INT AUTO_INCREMENT PRIMARY KEY,
    Codeclt INT,
    ancien_tel VARCHAR(15),
    nouv_tel VARCHAR(15),
    date_changement DATE,
    FOREIGN KEY (Codeclt) REFERENCES CLIENT(Codeclt)
);

CREATE TRIGGER trg_update_phone_history
AFTER UPDATE ON CLIENT
FOR EACH ROW
BEGIN
    IF OLD.tel <> NEW.tel THEN
        INSERT INTO Historique_Client (Codeclt, ancien_tel, nouv_tel, date_changement)
        VALUES (OLD.Codeclt, OLD.tel, NEW.tel, CURDATE());
    END IF;
END;
//
delimiter ;








-- 7
delimiter //
CREATE TRIGGER trg_restore_quantity
AFTER DELETE ON DETAIL
FOR EACH ROW
BEGIN
    -- Add back the deleted quantity to the product's available stock
    UPDATE PRODUIT
    SET qte_dispo = qte_dispo + OLD.qte_cmd
    WHERE Codeprd = OLD.Codeprd;
END; //
delimiter ;
