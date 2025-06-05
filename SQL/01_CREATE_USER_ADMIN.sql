-- =============================
--   TWORZENIE UŻYTKOWNIKA ADMIN
-- =============================

-- UWAGA: Ten skrypt należy uruchomić jako SYS lub SYSTEM

-- Usuń jeśli istnieje
BEGIN
  EXECUTE IMMEDIATE 'DROP USER admin CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -01918 THEN -- użytkownik nie istnieje
      RAISE;
    END IF;
END;
/

-- Tworzenie użytkownika
CREATE USER ADMIN IDENTIFIED BY ADMIN
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Nadanie podstawowych uprawnień
GRANT CONNECT, RESOURCE TO ADMIN;
GRANT EXECUTE ON DBMS_CRYPTO TO ADMIN;
-- Daje możliwość tworzenia widoków i procedur
GRANT CREATE VIEW, CREATE PROCEDURE TO ADMIN;

-- Daje pełny dostęp do własnych danych i wykonywania kwerend
GRANT SELECT ANY TABLE TO ADMIN;

-- (opcjonalnie – gdyby coś nie działało dalej)
GRANT UNLIMITED TABLESPACE TO ADMIN;

-- Gotowe! Teraz można się logować jako admin/admin
