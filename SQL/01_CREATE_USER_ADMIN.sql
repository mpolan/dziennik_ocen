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
CREATE USER admin IDENTIFIED BY admin
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

-- Nadanie podstawowych uprawnień
GRANT CONNECT, RESOURCE TO admin;
GRANT EXECUTE ON DBMS_CRYPTO TO admin;
-- Daje możliwość tworzenia widoków i procedur
GRANT CREATE VIEW, CREATE PROCEDURE TO admin;

-- Daje pełny dostęp do własnych danych i wykonywania kwerend
GRANT SELECT ANY TABLE TO admin;

-- (opcjonalnie – gdyby coś nie działało dalej)
GRANT UNLIMITED TABLESPACE TO admin;

-- Gotowe! Teraz można się logować jako admin/admin
