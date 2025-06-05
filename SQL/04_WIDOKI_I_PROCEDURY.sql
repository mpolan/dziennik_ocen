-- ===================================
--        WIDOKI + PROCEDURY API
-- ===================================

-- Widoki uÅ¼ywane w GET
CREATE OR REPLACE VIEW vw_srednie_ocen AS
SELECT
    s.id AS student_id,
    s.imie AS student_imie,
    s.nazwisko AS student_nazwisko,
    p.id AS przedmiot_id,
    p.nazwa AS przedmiot_nazwa,
    ROUND(AVG(o.wartosc), 2) AS srednia_ocen
FROM OCENA o
JOIN STUDENT s ON s.id = o.student_id
JOIN PRZEDMIOT p ON p.id = o.przedmiot_id
GROUP BY s.id, s.imie, s.nazwisko, p.id, p.nazwa;

CREATE OR REPLACE VIEW vw_oceny_szczegoly AS
SELECT
    o.id AS ocena_id,
    s.id AS student_id,
    s.imie AS student_imie,
    s.nazwisko AS student_nazwisko,
    p.nazwa AS przedmiot_nazwa,
    o.typ,
    o.wartosc,
    TO_CHAR(o.data_wystawienia, 'YYYY-MM-DD') AS data_wystawienia,
    n.imie AS nauczyciel_imie,
    n.nazwisko AS nauczyciel_nazwisko
FROM OCENA o
JOIN STUDENT s ON s.id = o.student_id
JOIN PRZEDMIOT p ON p.id = o.przedmiot_id
JOIN NAUCZYCIEL n ON n.id = o.nauczyciel_id;

CREATE OR REPLACE VIEW vw_zaliczenia AS
SELECT
    s.id AS student_id,
    s.imie || ' ' || s.nazwisko AS student,
    p.id AS przedmiot_id,
    n.imie || ' ' || n.nazwisko AS nauczyciel,
    p.nazwa AS przedmiot,
    ROUND(AVG(o.wartosc), 2) AS srednia,
    CASE
        WHEN AVG(o.wartosc) >= 3.0 THEN 'zaliczony'
        ELSE 'niezaliczony'
    END AS status
FROM OCENA o
JOIN STUDENT s ON s.id = o.student_id
JOIN PRZEDMIOT p ON p.id = o.przedmiot_id
JOIN NAUCZYCIEL n ON n.id = o.nauczyciel_id
GROUP BY s.id, s.imie, s.nazwisko, n.imie, n.nazwisko, p.id, p.nazwa;

CREATE OR REPLACE VIEW vw_ranking AS
SELECT
    s.id AS student_id,
    s.imie AS student_imie,
    s.nazwisko AS student_nazwisko,
    ROUND(AVG(o.wartosc), 2) AS srednia,
    DENSE_RANK() OVER (ORDER BY AVG(o.wartosc) DESC) AS pozycja
FROM STUDENT s
JOIN OCENA o ON s.id = o.student_id
GROUP BY s.id, s.imie, s.nazwisko;


-- Procedura do POST /dodaj-ocene
CREATE OR REPLACE PROCEDURE dodaj_ocene (
    p_user_id       IN NUMBER,
    p_student_id    IN NUMBER,
    p_przedmiot_id  IN NUMBER,
    p_ocena         IN NUMBER,
    p_typ           IN VARCHAR2
) IS
    v_rola          VARCHAR2(20);
    v_nauczyciel_id NUMBER;
    v_ocena_id      NUMBER;
BEGIN
    SELECT rola INTO v_rola FROM UZYTKOWNIK WHERE id = p_user_id;
    IF v_rola != 'NAUCZYCIEL' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Tylko nauczyciel moze wstawiac oceny.');
    END IF;

    SELECT n.id INTO v_nauczyciel_id
    FROM NAUCZYCIEL n
    JOIN UZYTKOWNIK u ON u.login = n.email
    WHERE u.id = p_user_id;

    IF p_ocena not in (2.0, 3.0, 3.5, 4.0, 4.5, 5.0) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ocena musi byc w zakresie 2.0 - 5.0.');
    END IF;

    SELECT NVL(MAX(id), 0) + 1 INTO v_ocena_id FROM OCENA;

    INSERT INTO OCENA (id, student_id, przedmiot_id, nauczyciel_id, wartosc, typ, data_wystawienia)
    VALUES (v_ocena_id, p_student_id, p_przedmiot_id, v_nauczyciel_id, p_ocena, p_typ, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Dodano ocene ID: ' || v_ocena_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono uzytkownika lub nauczyciela.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Blad: ' || SQLERRM);
END;
/

-- =====================================================
--                PRZYKÅ?ADOWE WYWOÅ?ANIA
-- =====================================================

--BEGIN pokaz_ranking_przedmiotu(2); END;
--/
--
--BEGIN pokaz_ranking; END;
--/
--
--BEGIN pokaz_oceny_studenta(1); END;
--/
--
--BEGIN
--  pokaz_oceny_studenta(1);
--  dodaj_ocene(101, 1, 2, 5.0, 'Zaliczenie');
--  pokaz_oceny_studenta(1);
--END;
--/
--
--END;
--/



SELECT 
    przedmiot_id,
    round(COUNT(CASE WHEN status = 'niezaliczony' THEN 1 END) * 100 / COUNT(*), 2) || ' %' AS ratio_niezal,
    round(COUNT(CASE WHEN status = 'zaliczony' THEN 1 END) * 100 / COUNT(*), 2) || ' %' AS "ratio-zaliczony"
FROM 
    vw_zaliczenia
group by przedmiot_id
order by ratio_niezal desc;
--WHERE 
--    przedmiot_id = 4;


explain plan for
select * from vw_ranking;

select * from table(DBMS_XPLAN.DISPLAY);