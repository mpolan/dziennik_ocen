-- ===================================
--        WIDOKI + PROCEDURY API
-- ===================================
-- Widoki używane w GET
CREATE OR REPLACE VIEW VW_SREDNIE_OCEN AS
SELECT
    S.ID AS STUDENT_ID,
    S.IMIE AS STUDENT_IMIE,
    S.NAZWISKO AS STUDENT_NAZWISKO,
    P.ID AS PRZEDMIOT_ID,
    P.NAZWA AS PRZEDMIOT_NAZWA,
    ROUND(AVG(O.WARTOSC), 2) AS SREDNIA_OCEN
FROM OCENA O
JOIN STUDENT S ON S.ID = O.STUDENT_ID
JOIN PRZEDMIOT P ON P.ID = O.PRZEDMIOT_ID
GROUP BY S.ID, S.IMIE, S.NAZWISKO, P.ID, P.NAZWA;

CREATE OR REPLACE VIEW VW_OCENY_SZCZEGOLY AS
SELECT
    O.ID AS OCENA_ID,
    S.ID AS STUDENT_ID,
    S.IMIE AS STUDENT_IMIE,
    S.NAZWISKO AS STUDENT_NAZWISKO,
    P.NAZWA AS PRZEDMIOT_NAZWA,
    O.TYP,
    O.WARTOSC,
    TO_CHAR(O.DATA_WYSTAWIENIA, 'YYYY-MM-DD') AS DATA_WYSTAWIENIA,
    N.IMIE AS NAUCZYCIEL_IMIE,
    N.NAZWISKO AS NAUCZYCIEL_NAZWISKO,
    N.EMAIL AS NAUCZYCIEL_EMAIL,
    S.EMAIL AS STUDENT_EMAIL
FROM OCENA O
JOIN STUDENT S ON S.ID = O.STUDENT_ID
JOIN PRZEDMIOT P ON P.ID = O.PRZEDMIOT_ID
JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID;

CREATE OR REPLACE VIEW VW_ZALICZENIA AS
SELECT
    S.ID AS STUDENT_ID,
    S.IMIE || ' ' || S.NAZWISKO AS STUDENT,
    P.ID AS PRZEDMIOT_ID,
    N.IMIE || ' ' || N.NAZWISKO AS NAUCZYCIEL,
    P.NAZWA AS PRZEDMIOT,
    N.EMAIL AS NAUCZYCIEL_EMAIL,
    S.EMAIL AS STUDENT_EMAIL,
    ROUND(AVG(O.WARTOSC), 2) AS SREDNIA,
    CASE
        WHEN AVG(O.WARTOSC) >= 3.0 THEN 'zaliczony'
        ELSE 'niezaliczony'
    END AS STATUS
FROM OCENA O
JOIN STUDENT S ON S.ID = O.STUDENT_ID
JOIN PRZEDMIOT P ON P.ID = O.PRZEDMIOT_ID
JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
GROUP BY S.ID, S.IMIE, S.NAZWISKO, N.IMIE, N.NAZWISKO, P.ID, P.NAZWA, N.EMAIL, S.EMAIL;

CREATE OR REPLACE VIEW VW_RANKING_OGOLNY AS
SELECT
    S.ID AS STUDENT_ID,
    S.IMIE AS STUDENT_IMIE,
    S.NAZWISKO AS STUDENT_NAZWISKO,
    ROUND(AVG(O.WARTOSC), 2) AS SREDNIA,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA
FROM STUDENT S
JOIN OCENA O ON S.ID = O.STUDENT_ID
GROUP BY S.ID, S.IMIE, S.NAZWISKO;

create or replace view vw_ranking_przedmiotow as
select 
    round(avg(wartosc),2) as srednia, 
    p.nazwa as przedmiot_nazwa,
    n.imie || ' ' || n.nazwisko as nauczyciel_dane,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA 
from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
JOIN nauczyciel n on o.nauczyciel_ID = n.id
join przedmiot p on o.przedmiot_id = p.id
where n.imie <> 'SYSTEM'
group by przedmiot_id, n.imie, n.nazwisko, p.nazwa;

create or replace view vw_ranking_grup as
select
    round(avg(wartosc),2) as srednia,
    g.nazwa as grupa_dane,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA 
from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
join zapisy z on s.id = z.student_id
join grupa g on z.grupa_id = g.id
group by g.nazwa;

-- Procedura do POST /dodaj-ocene
CREATE OR REPLACE PROCEDURE DODAJ_OCENE (
    P_EMAIL        IN VARCHAR2,
    P_STUDENT_ID   IN NUMBER,
    P_PRZEDMIOT_ID IN NUMBER,
    P_OCENA        IN NUMBER,
    P_TYP          IN VARCHAR2
)IS
    V_ROLA          VARCHAR2(20);
    V_NAUCZYCIEL_ID NUMBER;
    V_OCENA_ID      NUMBER;
    V_STUDENT_LICZNIK NUMBER;
    V_PRZEDMIOT_LICZNIK NUMBER;
BEGIN
    SELECT ROLA INTO V_ROLA FROM UZYTKOWNIK WHERE LOGIN = P_EMAIL;
    IF V_ROLA NOT IN ('NAUCZYCIEL', 'ADMIN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Tylko nauczyciel/admin moze wstawiac oceny.');
    END IF;
    
    SELECT COUNT(*) INTO V_STUDENT_LICZNIK
    FROM OCENA O
    JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
    JOIN STUDENT S ON S.ID = O.STUDENT_ID
    WHERE N.EMAIL = P_EMAIL 
    AND S.ID = P_STUDENT_ID;
    
    SELECT COUNT(*) INTO V_PRZEDMIOT_LICZNIK
    FROM OCENA O
    JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
    JOIN STUDENT S ON S.ID = O.STUDENT_ID
    WHERE N.EMAIL = P_EMAIL 
    AND S.ID = P_STUDENT_ID
    AND O.PRZEDMIOT_ID = P_PRZEDMIOT_ID;
    
    IF V_STUDENT_LICZNIK = 0 AND V_PRZEDMIOT_LICZNIK = 0 AND V_ROLA != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20002, 'NAUCZYCIEL NIE UCZY TEGO STUDENTA ANI TEGO PRZEDMIOTU.');
    ELSIF V_STUDENT_LICZNIK = 0  AND V_ROLA != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20003, 'NAUCZYCIEL NIE UCZY TEGO STUDENTA.');
    ELSIF V_PRZEDMIOT_LICZNIK = 0  AND V_ROLA != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20004, 'NAUCZYCIEL NIE UCZY TEGO PRZEDMIOTU.');
    END IF;
    -- Pobranie ID nauczyciela na podstawie emaila
    IF V_ROLA = 'NAUCZYCIEL' THEN
        SELECT ID INTO V_NAUCZYCIEL_ID
        FROM NAUCZYCIEL
        WHERE EMAIL = P_EMAIL;
    ELSIF V_ROLA = 'ADMIN' THEN
        V_NAUCZYCIEL_ID := 0;
    END IF;
    IF P_OCENA NOT IN (2.0, 3.0, 3.5, 4.0, 4.5, 5.0) THEN
        RAISE_APPLICATION_ERROR(-20005, 'Ocena musi byc w zakresie 2.0 - 5.0.');
    END IF;

    SELECT NVL(MAX(ID), 0) + 1 INTO V_OCENA_ID FROM OCENA;

    INSERT INTO OCENA (ID, STUDENT_ID, PRZEDMIOT_ID, NAUCZYCIEL_ID, WARTOSC, TYP, DATA_WYSTAWIENIA)
    VALUES (V_OCENA_ID, P_STUDENT_ID, P_PRZEDMIOT_ID, V_NAUCZYCIEL_ID, P_OCENA, P_TYP, SYSDATE);
    
    ZALOGUJ_ZMIANE(P_EMAIL, 'OCENA', 'INSERT', V_OCENA_ID);
    
    DBMS_OUTPUT.PUT_LINE('Dodano ocene ID: ' || V_OCENA_ID);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'Nie znaleziono uzytkownika lub nauczyciela.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Blad: ' || SQLERRM);
END;
/
-- Procedura aktualizowania oceny:
CREATE OR REPLACE PROCEDURE AKTUALIZUJ_OCENE (
    p_email     IN VARCHAR2,
    p_ocena_id  IN NUMBER,
    p_nowa      IN NUMBER
) IS
    v_user_rola      VARCHAR2(20);
    v_nauczyciel_id  NUMBER;
    v_autor_oceny_id NUMBER;
    v_stara          NUMBER;
BEGIN
    -- Pobranie roli użytkownika
    SELECT rola INTO v_user_rola FROM uzytkownik WHERE login = p_email;

    -- Jeśli użytkownik to nauczyciel, pobierz jego ID
    IF v_user_rola = 'NAUCZYCIEL' THEN
        SELECT id INTO v_nauczyciel_id FROM nauczyciel WHERE email = p_email;
    END IF;

    -- Pobierz dane z oceny
    SELECT nauczyciel_id, wartosc INTO v_autor_oceny_id, v_stara FROM ocena WHERE id = p_ocena_id;

    -- Walidacja dostępu
    IF v_user_rola != 'ADMIN' AND v_autor_oceny_id != v_nauczyciel_id THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nie masz uprawnień do edycji tej oceny.');
    END IF;

    -- Walidacja wartości
    IF p_nowa NOT IN (2.0, 3.0, 3.5, 4.0, 4.5, 5.0) THEN
        RAISE_APPLICATION_ERROR(-20011, 'Niepoprawna wartość oceny.');
    END IF;

    -- Aktualizacja
    UPDATE ocena SET wartosc = p_nowa WHERE id = p_ocena_id;

    -- Historia zmian
    INSERT INTO historia_ocen (
        id, ocena_id, stara_wartosc, nowa_wartosc, zmienil_user_id, data_zmiany
    ) VALUES (
        historia_ocen_seq.NEXTVAL,
        p_ocena_id,
        v_stara,
        p_nowa,
        (SELECT id FROM uzytkownik WHERE login = p_email),
        SYSTIMESTAMP
    );

    -- Log
    ZALOGUJ_ZMIANE(p_email, 'OCENA', 'UPDATE', p_ocena_id);
END;
/


-- Proceudra usuwania oceny:

CREATE OR REPLACE PROCEDURE USUN_OCENE (
    p_email     IN VARCHAR2,
    p_ocena_id  IN NUMBER
) IS
    v_user_rola     VARCHAR2(20);
    v_nauczyciel_id NUMBER;
    v_autor_oceny_id NUMBER;
BEGIN
    -- Rola użytkownika
    SELECT rola INTO v_user_rola FROM uzytkownik WHERE login = p_email;

    -- Jeśli nauczyciel, znajdź jego ID
    IF v_user_rola = 'NAUCZYCIEL' THEN
        SELECT id INTO v_nauczyciel_id FROM nauczyciel WHERE email = p_email;
    END IF;

    -- Pobierz autora oceny
    SELECT nauczyciel_id INTO v_autor_oceny_id FROM ocena WHERE id = p_ocena_id;

    -- Walidacja dostępu
    IF v_user_rola != 'ADMIN' AND v_autor_oceny_id != v_nauczyciel_id THEN
        RAISE_APPLICATION_ERROR(-20012, 'Nie masz uprawnień do usunięcia tej oceny.');
    END IF;

    -- Usuwanie
    DELETE FROM ocena WHERE id = p_ocena_id;

    -- Log
    ZALOGUJ_ZMIANE(p_email, 'OCENA', 'DELETE', p_ocena_id);
END;
/

