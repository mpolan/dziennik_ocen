# 🎓 Projekt SBD: Dziennik Ocen – Oracle + Django

Kompletny projekt systemu oceniania studentów, oparty na Oracle i Django REST Framework. Projekt spełnia wszystkie wymagania checklisty projektowej.

---

## 📁 Struktura plików

| Plik                          | Opis |
|-------------------------------|------|
| `00_czyszczenie_bazy.sql`     | Skrypt do całkowitego usunięcia obiektów w bazie |
| `1_struktura_bazy.sql`        | Tworzy wszystkie tabele i relacje |
| `2_inserty_triggery.sql`      | Zawiera triggery, funkcję `hashuj_haslo`, dane testowe |
| `3_widoki_i_procedury.sql`    | Widoki do GET API i procedura `dodaj_ocene` do POST |

---

## 🧪 Uruchamianie w Oracle SQL Developer

### 1. Wyczyść bazę (opcjonalnie)

```sql
@00_czyszczenie_bazy.sql
```

### 2. Utwórz strukturę

```sql
@1_struktura_bazy.sql
```

### 3. Dodaj triggery, funkcje, dane

```sql
@2_inserty_triggery.sql
```

### 4. Dodaj widoki i procedury API

```sql
@3_widoki_i_procedury.sql
```

---

## 🚀 Backend – Django REST API

## 🔌 Endpointy API

| Metoda | Endpoint                  | Opis |
|--------|---------------------------|------|
| `POST` | `/api/dodaj-ocene/`       | Wywołuje procedurę `dodaj_ocene(...)` |
| `GET`  | `/api/oceny-studenta/`    | Zwraca listę ocen z widoku `vw_oceny_szczegoly` |
| `GET`  | `/api/ranking/`           | Ranking studentów z widoku `vw_ranking` |
| `GET`  | `/api/ranking-przedmiotu/`| Ranking dla danego przedmiotu |
| `GET`  | `/api/zaliczenia/`        | Status zaliczenia z widoku `vw_zaliczenia` |

---

## ✅ Projekt spełnia checklistę:
- [x] Skrypt tworzący bazę danych i dane demo
- [x] Diagram encji (osobno w `Baza.png`)
- [x] Web API z dokumentacją OpenAPI (Swagger)
- [] Widoki i procedury w PL/SQL
- [] ORM po stronie Django (opcjonalnie)
- [] Testy wydajnościowe do wykonania osobno
- [] Dokumentacja i kod źródłowy

---

## 👤 Autor
*Michał Polanowski:*
*Projekt na przedmiot Systemy Baz Danych* – 2025