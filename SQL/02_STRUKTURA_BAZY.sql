-- ===================================
--      STRUKTURA BAZY DANYCH
-- ===================================

-- UWAGA: zawiera wszystkie CREATE TABLE, PK, FK itp.

-- =========================
--      TWORZENIE TABEL
-- =========================

-- STUDENT
CREATE TABLE STUDENT (
    id NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    data_urodzenia DATE
);

-- NAUCZYCIEL
CREATE TABLE NAUCZYCIEL (
    id NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    tytul_naukowy VARCHAR2(100)
);

-- PRZEDMIOT
CREATE TABLE PRZEDMIOT (
    id NUMBER PRIMARY KEY,
    nazwa VARCHAR2(100),
    kod VARCHAR2(20) UNIQUE,
    semestr NUMBER,
    ects NUMBER
);

-- GRUPA
CREATE TABLE GRUPA (
    id NUMBER PRIMARY KEY,
    nazwa VARCHAR2(100),
    rok_akademicki VARCHAR2(20)
);

-- UZYTKOWNIK
CREATE TABLE UZYTKOWNIK (
    id NUMBER PRIMARY KEY,
    login VARCHAR2(50) UNIQUE,
    haslo VARCHAR2(100),
    rola VARCHAR2(20)
);

-- ZAPISY
CREATE TABLE ZAPISY (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    grupa_id NUMBER NOT NULL,
    przedmiot_id NUMBER NOT NULL,
    CONSTRAINT fk_zapisy_student FOREIGN KEY (student_id) REFERENCES STUDENT(id),
    CONSTRAINT fk_zapisy_grupa FOREIGN KEY (grupa_id) REFERENCES GRUPA(id),
    CONSTRAINT fk_zapisy_przedmiot FOREIGN KEY (przedmiot_id) REFERENCES PRZEDMIOT(id)
);

-- OCENA
CREATE TABLE OCENA (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    przedmiot_id NUMBER NOT NULL,
    nauczyciel_id NUMBER NOT NULL,
    wartosc NUMBER(4,2),
    typ VARCHAR2(50),
    data_wystawienia DATE,
    CONSTRAINT fk_ocena_student FOREIGN KEY (student_id) REFERENCES STUDENT(id),
    CONSTRAINT fk_ocena_przedmiot FOREIGN KEY (przedmiot_id) REFERENCES PRZEDMIOT(id),
    CONSTRAINT fk_ocena_nauczyciel FOREIGN KEY (nauczyciel_id) REFERENCES NAUCZYCIEL(id)
);

-- ZALICZENIE
CREATE TABLE ZALICZENIE (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    przedmiot_id NUMBER NOT NULL,
    status VARCHAR2(20),
    data_zaliczenia DATE,
    CONSTRAINT fk_zaliczenie_student FOREIGN KEY (student_id) REFERENCES STUDENT(id),
    CONSTRAINT fk_zaliczenie_przedmiot FOREIGN KEY (przedmiot_id) REFERENCES PRZEDMIOT(id)
);

-- RANKING
CREATE TABLE RANKING (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    srednia NUMBER(4,2),
    pozycja NUMBER,
    semestr NUMBER,
    CONSTRAINT fk_ranking_student FOREIGN KEY (student_id) REFERENCES STUDENT(id)
);

-- HISTORIA_OCEN
CREATE TABLE HISTORIA_OCEN (
    id NUMBER PRIMARY KEY,
    ocena_id NUMBER NOT NULL,
    stara_wartosc NUMBER(4,2),
    nowa_wartosc NUMBER(4,2),
    zmienil_user_id NUMBER,
    data_zmiany TIMESTAMP,
    CONSTRAINT fk_historia_ocena FOREIGN KEY (ocena_id) REFERENCES OCENA(id),
    CONSTRAINT fk_historia_user FOREIGN KEY (zmienil_user_id) REFERENCES UZYTKOWNIK(id)
);

-- LOG_ZMIAN
CREATE TABLE LOG_ZMIAN (
    id NUMBER PRIMARY KEY,
    uzytkownik_id NUMBER,
    akcja VARCHAR2(100),
    tabela VARCHAR2(50),
    rekord_id NUMBER,
    data TIMESTAMP,
    CONSTRAINT fk_log_user FOREIGN KEY (uzytkownik_id) REFERENCES UZYTKOWNIK(id)
);

-- Komentarze (Oracle)
COMMENT ON COLUMN OCENA.typ IS 'np. kolokwium, egzamin, projekt';
COMMENT ON COLUMN ZALICZENIE.status IS 'zaliczony, niezaliczony';
COMMENT ON COLUMN UZYTKOWNIK.rola IS 'ADMIN, NAUCZYCIEL, STUDENT';

COMMIT;
