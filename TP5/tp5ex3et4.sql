use dbgestion;

CREATE TABLE Client2 (
    Codeclt INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    tel VARCHAR(20)
);

CREATE TABLE Produit2 (
    Codeprd INT PRIMARY KEY,
    designation VARCHAR(50),
    prix DECIMAL(10,2),
    qte_dispo INT
);

CREATE TABLE Commande2 (
    numero INT PRIMARY KEY,
    Codeclt INT ,
    datecmd DATE,
    Montant DECIMAL(10,2),
    FOREIGN KEY (codeclt) REFERENCES Client2(Codeclt)
);

CREATE TABLE Detail (
    numero INT,
    Codeprd INT,
    qte_cmd INT,
    PRIMARY KEY (numero, Codeprd),
    FOREIGN KEY (numero) REFERENCES Commande2(numero),
    FOREIGN KEY (Codeprd) REFERENCES Produit2(Codeprd)
);

# 1 ---
DELIMITER //
CREATE TRIGGER TR_Produit_QuantiteNegative
BEFORE INSERT ON Produit2
FOR EACH ROW
BEGIN
    IF NEW.qte_dispo < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantité non acceptée !';
    END IF;
END;//
DELIMITER ;


# 2 ---
DELIMITER //
CREATE TRIGGER TR_Detail_NoUpdate
BEFORE UPDATE ON Detail
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La table DETAIL ne peut être modifiée !';
END;//
DELIMITER ;

# 3 ---
DELIMITER //
CREATE TRIGGER TR_Commande_NumeroUnique
BEFORE INSERT ON Commande2
FOR EACH ROW
BEGIN
    DECLARE newNumero INT;
    SELECT COALESCE(MAX(numero), 0) + 1 INTO newNumero FROM Commande;
    SET NEW.numero = newNumero;
END;
//
DELIMITER ;

# 4 ---
DELIMITER //
CREATE TRIGGER TR_Detail_UpdateCommande
AFTER INSERT ON Detail
FOR EACH ROW
BEGIN
    UPDATE Commande2 C
    SET Montant = (
        SELECT SUM(D.qte_cmd * P.prix) 
        FROM Detail D 
        INNER JOIN Produit2 P ON D.Codeprd = P.Codeprd 
        WHERE D.numero = C.numero
    )
    WHERE C.numero = NEW.numero;

    UPDATE Produit2 P
    SET P.qte_dispo = P.qte_dispo - NEW.qte_cmd
    WHERE P.Codeprd = NEW.Codeprd;

    IF (SELECT P.qte_dispo FROM Produit2 P WHERE P.Codeprd = NEW.Codeprd) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantité disponible insuffisante pour un ou plusieurs produits.';
    END IF;
END //
DELIMITER ;

# 5 ----
DELIMITER //
CREATE TRIGGER TR_Client_UpdateTel
AFTER UPDATE ON Client2
FOR EACH ROW
BEGIN
    IF OLD.tel != NEW.tel THEN
        INSERT INTO Historique_Client (Codeclt, ancien_tel, nouv_tel, date_changement)
        VALUES (NEW.Codeclt, OLD.tel, NEW.tel, NOW());
    END IF;
END //
DELIMITER ;

# 6 ----
DELIMITER //
CREATE TRIGGER TR_Detail_Delete
AFTER DELETE ON Detail
FOR EACH ROW
BEGIN
    UPDATE Produit2 P
    SET P.qte_dispo = P.qte_dispo + OLD.qte_cmd
    WHERE P.Codeprd = OLD.Codeprd;

    -- Update Montant in Commande table
    UPDATE Commande2 C
    SET Montant = (
        SELECT SUM(D.qte_cmd * P.prix) 
        FROM Detail D 
        INNER JOIN Produit2 P ON D.Codeprd = P.Codeprd 
        WHERE D.numero = C.numero
    )
    WHERE C.numero = OLD.numero;
END //
DELIMITER ;



-- Inserting data into Client2
INSERT INTO Client2 (Codeclt, nom, prenom, tel) VALUES
(1, 'Dupont', 'Jean', '0123456789'),
(2, 'Martin', 'Alice', '0987654321'),
(3, 'Bernard', 'Paul', '0112233445'),
(4, 'Leroy', 'Sophie', '0778899000'),
(5, 'Durand', 'Luc', '0666778899');

-- Inserting data into Produit2
INSERT INTO Produit2 (Codeprd, designation, prix, qte_dispo) VALUES
(1, 'Produit A', 15.50, 100),
(2, 'Produit B', 25.00, 200),
(3, 'Produit C', 10.75, 150),
(4, 'Produit D', 30.00, 80),
(5, 'Produit E', 45.25, 50);

-- Inserting data into Commande2
INSERT INTO Commande2 (numero, Codeclt, datecmd, Montant) VALUES
(1, 1, '2024-10-01', 155.50),
(2, 2, '2024-10-02', 200.00),
(3, 3, '2024-10-03', 120.75),
(4, 4, '2024-10-04', 90.00),
(5, 5, '2024-10-05', 45.25);

select * from commande2;

-- Inserting data into Detail
INSERT INTO Detail (numero, Codeprd, qte_cmd) VALUES
(1, 1, 3),  -- Commande 1: 3 of Produit A
(1, 2, 2),  -- Commande 1: 2 of Produit B
(2, 3, 1),  -- Commande 2: 1 of Produit C
(3, 4, 4),  -- Commande 3: 4 of Produit D
(4, 5, 1),  -- Commande 4: 1 of Produit E
(5, 1, 2);  -- Commande 5: 2 of Produit A

CREATE TABLE Historique_Client (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each record
    Codeclt INT NOT NULL,                -- Code of the client
    ancien_tel VARCHAR(15) NOT NULL,     -- Old telephone number
    nouv_tel VARCHAR(15) NOT NULL,       -- New telephone number
    date_changement DATETIME NOT NULL,    -- Date and time of the change
    FOREIGN KEY (Codeclt) REFERENCES Client(Codeclt)  -- Assuming there's a Codeclt in Client table
);







# -------------------- EX4
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

select * from client3;
select * from operation ;
select * from compte ;


DELIMITER //

-- 1. Trigger to check unique CIN for clients (INSERT)
CREATE TRIGGER check_unique_cin
BEFORE INSERT ON Client
FOR EACH ROW
BEGIN
    DECLARE existing_cin INT;

    SELECT COUNT(*) INTO existing_cin FROM Client WHERE CINCli = NEW.CINCli;
    
    IF existing_cin > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CIN already exists for another client';
    END IF;
END; //

-- 1. Trigger to check unique CIN for clients (UPDATE)
CREATE TRIGGER check_unique_cin_update
BEFORE UPDATE ON Client
FOR EACH ROW
BEGIN
    DECLARE existing_cin INT;

    SELECT COUNT(*) INTO existing_cin FROM Client WHERE CINCli = NEW.CINCli AND NumCli != OLD.NumCli;
    
    IF existing_cin > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CIN already exists for another client';
    END IF;
END; //

-- 2. Trigger to validate account creation
CREATE TRIGGER validate_account_creation
BEFORE INSERT ON Compte
FOR EACH ROW
BEGIN
    DECLARE account_type_count INT;

    -- Check if the balance is greater than 1500
    IF NEW.SoldeCpt <= 1500 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balance must be greater than 1500 DH';
    END IF;

    -- Check if the account type is CC or CN
    IF NEW.TypeCpt NOT IN ('CC', 'CN') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account type must be CC or CN';
    END IF;

    -- Check if the client already has the same account type
    SELECT COUNT(*) INTO account_type_count 
    FROM Compte 
    WHERE NumCli = NEW.NumCli AND TypeCpt = NEW.TypeCpt;

    IF account_type_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Client already has an account of this type';
    END IF;
END; //

-- 3. Trigger to prevent deletion of accounts
CREATE TRIGGER prevent_account_deletion
BEFORE DELETE ON Compte
FOR EACH ROW
BEGIN
    DECLARE account_balance DECIMAL(10, 2);
    DECLARE last_operation_date DATE;

    SELECT SoldeCpt INTO account_balance FROM Compte WHERE NumCpt = OLD.NumCpt;
    
    -- Check if the balance is greater than 0
    IF account_balance > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete account with balance greater than 0';
    END IF;

    -- Check the date of the last operation
    SELECT MAX(Dateop) INTO last_operation_date 
    FROM Operation WHERE NumCpt = OLD.NumCpt;

    IF last_operation_date IS NOT NULL AND last_operation_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete account with operations in the last 3 months';
    END IF;
END; //

-- 4. Trigger to restrict modifications
CREATE TRIGGER restrict_account_modifications
BEFORE UPDATE ON Compte
FOR EACH ROW
BEGIN
    DECLARE operation_count INT;

    -- Prevent changes to account numbers
    IF OLD.NumCpt != NEW.NumCpt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Modification of account numbers is not allowed';
    END IF;

    -- Prevent changes to the balance if there are operations
    SELECT COUNT(*) INTO operation_count 
    FROM Operation WHERE NumCpt = OLD.NumCpt;

    IF operation_count > 0 AND OLD.SoldeCpt != NEW.SoldeCpt THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot modify balance for accounts with associated operations';
    END IF;

    -- Prevent changing a savings account (CN) to a checking account (CC)
    IF OLD.TypeCpt = 'CN' AND NEW.TypeCpt = 'CC' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change account type from CN to CC';
    END IF;

    -- Validate client number change
    IF OLD.NumCli != NEW.NumCli THEN
        DECLARE client_account_count INT;

        SELECT COUNT(*) INTO client_account_count 
        FROM Compte WHERE NumCli = NEW.NumCli AND TypeCpt = OLD.TypeCpt;

        IF client_account_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New client already has an account of this type';
        END IF;
    END IF;
END; //

DELIMITER ;

