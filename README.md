# 🎓 Projekt SBD: Dziennik Ocen – Oracle + Django

Kompletny projekt systemu oceniania studentów, oparty na Oracle i Django REST Framework. Projekt spełnia wszystkie wymagania checklisty projektowej.

---

## 📁 Struktura plików

| Plik                          | Opis |
|-------------------------------|------|
| `00_CZYSTKA_BAZY.sql`         | Skrypt do całkowitego usunięcia obiektów w bazie |
| `01_CREATE_USER_ADMIN.sql`    | Tworzy potrzebnego user'a admina |
| `02_STRUKTURA_BAZY.sql`       | Tworzy wszystkie tabele i relacje |
| `03_INSERTY_I_TRIGGERY.sql`   | Zawiera triggery, funkcję `hashuj_haslo`, dane testowe |
| `04_WIDOKI_I_PROCEDURY.sql`   | Widoki do GET API i procedura `dodaj_ocene` do POST |

---

## 🧪 Uruchamianie w Oracle SQL Developer

#### Przypomnienie
```powershell
python -m venv venv
```

```powershell
./venv/scripts/activate.ps1
```
> 💡 **Uwaga:** Jeśli pojawi się błąd dotyczący polityki uruchamiania skryptów, możesz tymczasowo zmienić ustawienia za pomocą:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```
```powershell
pip install -r requirements.txt
```

### 📦 Wymagania:
- Skopiowany/sforkowany projekt github'a
- SQL Developer (GUI do uruchamiania plików SQL)
- Python 3.10+
- Django + django-rest-framework + drf-yasg (pip install -r requirements.txt)
- Pliki SQL:  
  - `00_CZYSTKA_BAZY.sql`  
  - `01_CREATE_USER_ADMIN.sql`  
  - `02_STRUKTURA_BAZY.sql`  
  - `03_INSERTY_I_TRIGGERY.sql`  
  - `04_WIDOKI_I_PROCEDURY.sql`

---

### 1. Otwórz SQL Developer i połącz się jako `SYS as SYSDBA`

**Dane połączenia:**
```
Username: SYS
Password: mypassword1
Connect As: SYSDBA
Host: localhost
Port: 1521
Service Name: ORCLPDB1
```

---

### 2. [Opcjonalnie] Wyczyść starą bazę

W SQL Developerze otwórz i uruchom (F5):

```sql
00_CZYSTKA_BAZY.sql
```

---

### 3. Utwórz użytkownika `admin`

Jako SYS, uruchom:

```sql
01_CREATE_USER_ADMIN.sql
```

---

### 4. Zaloguj się ponownie jako `admin`

**Nowe połączenie w SQL Developerze:**
```
Username: admin
Password: admin
Host: localhost
Port: 1521
Service Name: ORCLPDB1
```

---

### 5. Utwórz strukturę bazy:

Zalogowany jako `admin`, uruchom kolejno:

```sql
02_STRUKTURA_BAZY.sql
```

---

### 6. Dodaj triggery i dane testowe:

```sql
03_INSERTY_I_TRIGGERY.sql
```

---

### 7. Dodaj widoki i procedury:

```sql
04_WIDOKI_I_PROCEDURY.sql
```

---

### 8. Uruchom serwer:

```bash
python manage.py runserver
```

---

### 9. Otwórz Swagger

Wejdź w przeglądarce na:

```
http://localhost:8000/swagger/
```

I gotowe ✅


## 🚀 Backend – Django REST API

## 🔌 Endpointy API

| Metoda | Endpoint                  | Opis                                             | Status |
|--------|---------------------------|--------------------------------------------------|--------|
| `POST` | `/api/dodaj-ocene/`       | Wywołuje procedurę `dodaj_ocene(...)`           | ✅ Zrealizowano |
| `GET`  | `/api/oceny-studenta/`    | Zwraca listę ocen z widoku `vw_oceny_szczegoly` | ✅ Zrealizowano |
| `GET`  | `/api/ogolny-ranking/`    | Ranking studentów z widoku `vw_ranking`         | ✅ Zrealizowano |
| `GET`  | `/api/ranking-przedmiotu/`| Ranking dla danego przedmiotu                   | ❌ W planie |
| `GET`  | `/api/zaliczenia/`        | Status zaliczenia z widoku `vw_zaliczenia`      | ❌ W planie |

---

## ✅ Projekt spełnia checklistę:
- [x] Skrypt tworzący bazę danych i dane demo
- [x] Diagram encji (osobno w `Baza.png`)
- [x] Web API z dokumentacją OpenAPI (Swagger)
- [ ] Widoki i procedury w PL/SQL
- [ ] ORM po stronie Django (opcjonalnie)
- [ ] Testy wydajnościowe do wykonania osobno
- [ ] Dokumentacja i kod źródłowy

---

## 👤 Autor
*Michał Polanowski:*
*Projekt na przedmiot Systemy Baz Danych* – 2025