
# 📦 Instrukcja: Eksport i import bazy danych Oracle w Docker + WSL

## 🔹 Krok 1: Uruchom kontener Oracle (Docker)
```bash
# Uruchamiamy nowy kontener Oracle Database (przykład dla Oracle 19c)
docker run -d --name oracle19 -e ORACLE_PWD=mypassword1 -p 1521:1521 oracle/database:19.3.0-ee
# Uwaga: Podaj właściwy obraz Dockera (np. store/oracle/database-enterprise:19.3.0)
```

## 🔹 Krok 2: Utwórz katalog logiczny w Oracle i nadaj prawa (w kontenerze)
```bash
docker exec -it oracle19 bash
sqlplus sys/mypassword1@localhost:1521/ORCLPDB1 as sysdba

-- Tworzymy katalog logiczny, w którym zostaną zapisane pliki eksportu/importu
CREATE OR REPLACE DIRECTORY EXPORT_DIR AS '/tmp';
GRANT READ, WRITE ON DIRECTORY EXPORT_DIR TO STUDENT;
EXIT;
```

## 🔹 Krok 3: Eksport bazy danych (w kontenerze)
```bash
docker exec -it oracle19 bash

# Upewniamy się, że jesteśmy w kontenerze jako oracle
expdp STUDENT/student@localhost:1521/ORCLPDB1 schemas=STUDENT directory=EXPORT_DIR dumpfile=student_export.dmp logfile=export_log.log

# Pliki eksportu powstaną w katalogu /tmp w kontenerze
```

## 🔹 Krok 4: Skopiuj plik eksportu na WSL (z kontenera)
```bash
docker cp oracle19:/tmp/student_export.dmp .
docker cp oracle19:/tmp/export_log.log .
```

## 🔹 Krok 5: Uruchom nowy kontener (np. oracle19-nowy) i przygotuj katalog do importu
```bash
docker run -d --name oracle19-nowy -e ORACLE_PWD=mypassword1 -p 1522:1521 oracle/database:19.3.0-ee
```

## 🔹 Krok 6: Skopiuj plik eksportu do nowego kontenera
```bash
docker cp student_export.dmp oracle19-nowy:/tmp/student_export.dmp
```

## 🔹 Krok 7: Utwórz katalog logiczny w nowym kontenerze i nadaj prawa
```bash
docker exec -it oracle19-nowy bash
sqlplus sys/mypassword1@localhost:1521/ORCLPDB1 as sysdba

CREATE OR REPLACE DIRECTORY IMPORT_DIR AS '/tmp';
GRANT READ, WRITE ON DIRECTORY IMPORT_DIR TO STUDENT;

-- Upewnij się, że użytkownik STUDENT istnieje
CREATE USER STUDENT IDENTIFIED BY student;
GRANT CONNECT, RESOURCE TO STUDENT;
ALTER USER STUDENT QUOTA UNLIMITED ON USERS;

EXIT;
```

## 🔹 Krok 8: Popraw prawa do pliku eksportu (jako root w kontenerze)
```bash
docker exec -u 0 -it oracle19-nowy bash
chown oracle:dba /tmp/student_export.dmp
chmod 644 /tmp/student_export.dmp
exit
```

## 🔹 Krok 9: Import danych (w kontenerze)
```bash
docker exec -it oracle19-nowy bash
impdp STUDENT/student@localhost:1521/ORCLPDB1 schemas=STUDENT directory=IMPORT_DIR dumpfile=student_export.dmp logfile=import_log.log
```
