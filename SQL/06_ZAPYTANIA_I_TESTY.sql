-- =====================================================
--                ZAPYTANIA I TESTY
-- =====================================================

-- =======================================
-- 🗂 LISTA OBIEKTÓW (tabele, widoki, procedury)
-- =======================================

-- Lista wszystkich tabel w Twoim schemacie:
SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME;

-- Lista wszystkich widoków:
SELECT VIEW_NAME FROM USER_VIEWS ORDER BY VIEW_NAME;

-- Lista wszystkich procedur:
SELECT OBJECT_NAME FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'PROCEDURE'
ORDER BY OBJECT_NAME;

-- Lista wszystkich funkcji:
SELECT OBJECT_NAME FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'FUNCTION'
ORDER BY OBJECT_NAME;

-- Lista wszystkich pakietów:
SELECT OBJECT_NAME FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'PACKAGE'
ORDER BY OBJECT_NAME;
-- Lista wszystkich widoków:
SELECT OBJECT_NAME FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'VIEW'
ORDER BY OBJECT_NAME;
-- Lista wszystkich triggerów:
SELECT TRIGGER_NAME 
FROM USER_TRIGGERS
ORDER BY TRIGGER_NAME;

-- =======================================
-- 📋 DANE W TABELACH (SELECT * FROM ...)
-- =======================================

-- STUDENT
SELECT * FROM STUDENT;

-- NAUCZYCIEL
SELECT * FROM NAUCZYCIEL;

-- PRZEDMIOT
SELECT * FROM PRZEDMIOT;

-- OCENA
SELECT * FROM OCENA;

-- UZYTKOWNIK
SELECT * FROM UZYTKOWNIK;

-- GRUPA
SELECT * FROM GRUPA;

-- ZAPISY
SELECT * FROM ZAPISY;

-- =======================================
-- 👓 DANE Z WIDOKÓW
-- =======================================

-- Średnie ocen
SELECT * FROM VW_SREDNIE_OCEN;

-- Rankingi
SELECT * FROM VW_RANKING_OGOLNY;

SELECT * FROM VW_RANKING_PRZEDMIOTOW;

SELECT * FROM VW_RANKING_GRUP;
-- Szczegóły ocen
SELECT * FROM VW_OCENY_SZCZEGOLY;

-- Zaliczenia
SELECT * FROM VW_ZALICZENIA;

-- =======================================
--              TESTY RECZNE
-- =======================================


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

select * from uzytkownik
where rola = 'NAUCZYCIEL';
select * from nauczyciel;
SELECT PRZEDMIOT_NAZWA, TYP, WARTOSC, DATA_WYSTAWIENIA, NAUCZYCIEL_IMIE, NAUCZYCIEL_NAZWISKO
FROM VW_OCENY_SZCZEGOLY
WHERE STUDENT_ID = 1
AND EXISTS (
SELECT 1 
FROM NAUCZYCIEL N
WHERE N.EMAIL = :EMAIL
)
ORDER BY PRZEDMIOT_NAZWA, DATA_WYSTAWIENIA;


select przedmiot_id, count(*) as ilosc_stud from zapisy
group by przedmiot_id
order by przedmiot_id;

SELECT grupa_id, COUNT(DISTINCT student_id) AS liczba_studentow
FROM zapisy
GROUP BY grupa_id
ORDER BY grupa_id;


SELECT count(*)
FROM OCENA O
JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
JOIN STUDENT S ON S.ID = O.STUDENT_ID
WHERE N.EMAIL = 'nauczyciel201@example.com';
GROUP BY S.ID, PRZEDMIOT_ID, STUDENT, NAUCZYCIEL_DANE, N.EMAIL;

SELECT ID, IMIE, NAZWISKO FROM STUDENT
WHERE ID IN (
SELECT S.ID AS ID_STUD
FROM OCENA O
JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
JOIN STUDENT S ON S.ID = O.STUDENT_ID
WHERE N.EMAIL = 'nauczyciel200@example.com')
ORDER BY ID ASC;
--;

SELECT STUDENT_ID, PRZEDMIOT_ID, NAUCZYCIEL_ID, WARTOSC || ' - ' || TYP AS OCENA, DATA_WYSTAWIENIA, IMIE || ' ' || NAZWISKO AS NAUCZYCIEL FROM OCENA O
JOIN NAUCZYCIEL N
ON N.ID = O.NAUCZYCIEL_ID
WHERE NAUCZYCIEL_ID = 200;

SELECT 
    PRZEDMIOT_ID,
    ROUND(COUNT(CASE WHEN STATUS = 'niezaliczony' THEN 1 END) * 100 / COUNT(*), 2) || ' %' AS RATIO_NIEZAL,
    ROUND(COUNT(CASE WHEN STATUS = 'zaliczony' THEN 1 END) * 100 / COUNT(*), 2) || ' %' AS "RATIO-ZALICZONY"
FROM 
    VW_ZALICZENIA
GROUP BY PRZEDMIOT_ID
ORDER BY RATIO_NIEZAL DESC;
--WHERE 
--    przedmiot_id = 4;


SELECT MAX(PRZEDMIOT_ID)
    FROM OCENA O
    JOIN NAUCZYCIEL N ON N.ID = O.NAUCZYCIEL_ID
    JOIN STUDENT S ON S.ID = O.STUDENT_ID
    WHERE N.EMAIL = 'nauczyciel200@example.com' 
    AND S.ID = 1;

EXPLAIN PLAN FOR
SELECT * FROM VW_RANKING;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT count(distinct(student_id)) FROM OCENA
group by nauczyciel_id;
WHERE STUDENT_ID = 33;

SELECT * FROM VW_ZALICZENIA WHERE STUDENT_ID = 70;

select * from zaliczenie
where student_id = 1;

select nauczyciel_id, count(distinct(student_id)) as ilosc_stud from ocena
group by nauczyciel_id
order by nauczyciel_id;

EXPLAIN PLAN FOR
SELECT * FROM OCENA WHERE STUDENT_ID = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

update ocena set
wartosc = 2.0
where id = 2;
select * from log_zmian
order by id desc;
/


SELECT
    S.ID AS STUDENT_ID,
    S.IMIE AS STUDENT_IMIE,
    S.NAZWISKO AS STUDENT_NAZWISKO,
    ROUND(AVG(O.WARTOSC), 2) AS SREDNIA,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA
FROM STUDENT S
JOIN OCENA O ON S.ID = O.STUDENT_ID
GROUP BY S.ID, S.IMIE, S.NAZWISKO;

select
    round(avg(wartosc),2) as srednia,
    z.grupa_id
from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
JOIN nauczyciel n on o.nauczyciel_ID = n.id
join zapisy z on s.id = z.student_id
group by grupa_id;

select sum(wartosc), count(*) from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
JOIN nauczyciel n on o.nauczyciel_ID = n.id
join zapisy z on s.id = z.student_id
where grupa_id = 6;
-- 3.671
-- 4.015
select 
    round(avg(wartosc),2) as srednia, 
    p.nazwa,
    n.imie || ' ' || n.nazwisko as nauczyciel_dane,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA 
from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
JOIN nauczyciel n on o.nauczyciel_ID = n.id
join przedmiot p on o.przedmiot_id = p.id
group by przedmiot_id, n.imie, n.nazwisko, p.nazwa;

select
    round(avg(wartosc),2) as srednia,
    z.grupa_id,
    n.imie, n.nazwisko,
    DENSE_RANK() OVER (ORDER BY AVG(O.WARTOSC) DESC) AS POZYCJA 
from student s
JOIN OCENA O ON S.ID = O.STUDENT_ID
JOIN nauczyciel n on o.nauczyciel_ID = n.id
join zapisy z on s.id = z.student_id
group by grupa_id, n.imie, n.nazwisko;


SELECT DISTINCT
    n.id AS nauczyciel_id,
    n.imie || ' ' || n.nazwisko AS nauczyciel,
    g.id AS grupa_id,
    g.nazwa AS grupa_nazwa,
    p.nazwa AS przedmiot
FROM
    NAUCZYCIEL n
JOIN OCENA o ON o.nauczyciel_id = n.id
JOIN STUDENT s ON s.id = o.student_id
JOIN ZAPISY z ON z.student_id = s.id AND z.przedmiot_id = o.przedmiot_id
JOIN GRUPA g ON g.id = z.grupa_id
JOIN PRZEDMIOT p ON p.id = o.przedmiot_id
ORDER BY nauczyciel_id;

SELECT
    n.id AS nauczyciel_id,
    n.imie || ' ' || n.nazwisko AS nauczyciel,
    COUNT(DISTINCT g.id) AS liczba_grup
FROM
    NAUCZYCIEL n
JOIN OCENA o ON o.nauczyciel_id = n.id
JOIN STUDENT s ON s.id = o.student_id
JOIN ZAPISY z ON z.student_id = s.id AND z.przedmiot_id = o.przedmiot_id
JOIN GRUPA g ON g.id = z.grupa_id
GROUP BY n.id, n.imie, n.nazwisko
ORDER BY liczba_grup DESC;
