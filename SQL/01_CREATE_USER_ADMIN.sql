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

-- (opcjonalnie) dodatkowe uprawnienia, jeśli potrzebne:
-- GRANT CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER TO admin;
-- GRANT UNLIMITED TABLESPACE TO admin;

-- Gotowe! Teraz można się logować jako admin/admin
