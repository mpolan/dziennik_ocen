from faker import Faker
import random
from collections import defaultdict

fake = Faker()
tytuly = ['Prof', 'Dr', 'Mgr']
OCENY = [2.0, 3.0, 3.5, 4.0, 4.5, 5.0]
TYPY_OCEN = ['Kolokwium', 'Egzamin', 'Prezentacja', 'Wejściówka']

liczba_studentow = 160
liczba_nauczycieli = 12
liczba_przedmiotow = 6
liczba_grup = 10
studenci_na_grupe = 16

# Przypisanie przedmiotów do grup (równomiernie)
grupa_przedmioty = defaultdict(list)
przedmiot_grupy = {pid: [] for pid in range(1, liczba_przedmiotow + 1)}
grupy = list(range(1, liczba_grup + 1))
docelowy_rozklad = [4, 4, 4, 3, 3, 2]  # suma = 20

idx = 0
for przedmiot_id, ilosc_grup in zip(range(1, liczba_przedmiotow + 1), docelowy_rozklad):
    przydzielono = 0
    while przydzielono < ilosc_grup:
        grupa_id = grupy[idx % len(grupy)]
        if len(grupa_przedmioty[grupa_id]) < 2 and przedmiot_id not in grupa_przedmioty[grupa_id]:
            grupa_przedmioty[grupa_id].append(przedmiot_id)
            przedmiot_grupy[przedmiot_id].append(grupa_id)
            przydzielono += 1
        idx += 1

# Nauczyciele per przedmiot (2)
nauczyciele_na_przedmiot = {}
nauczyciel_counter = 201
for pid in range(1, liczba_przedmiotow + 1):
    nauczyciele_na_przedmiot[pid] = [nauczyciel_counter, nauczyciel_counter + 1]
    nauczyciel_counter += 2

output_lines = []

# STUDENCI
output_lines.append("-- STUDENT")
for i in range(1, liczba_studentow + 1):
    date = fake.date_between(start_date='-25y', end_date='-18y')
    output_lines.append(f"INSERT INTO STUDENT VALUES({i}, 'Student{i}', 'Nazwisko{i}', 'student{i}@example.com', DATE '{date}');")

# NAUCZYCIELE
output_lines.append("\n-- NAUCZYCIEL")
for i in range(200, liczba_nauczycieli + 201):
    r = random.randint(0, 2)
    output_lines.append(f"INSERT INTO NAUCZYCIEL VALUES({i}, 'Nauczyciel{i}', 'Nazwisko{i}', 'nauczyciel{i}@example.com', '{tytuly[r]}');")

# PRZEDMIOTY
output_lines.append("\n-- PRZEDMIOT")
for i in range(1, liczba_przedmiotow + 1):
    sem = random.randint(1, 7)
    ects = random.randint(1, 6)
    kod = f"KOD{i:03d}"
    output_lines.append(f"INSERT INTO PRZEDMIOT VALUES({i}, 'Przedmiot{i}', '{kod}', {sem}, {ects});")

# GRUPY
output_lines.append("\n-- GRUPA")
for i in range(1, liczba_grup + 1):
    output_lines.append(f"INSERT INTO GRUPA VALUES({i}, 'Grupa{i}', '2024/2025');")

# ZAPISY
output_lines.append("\n-- ZAPISY")
zapisy_id = 1
student_to_grupa = {}
for i in range(1, liczba_studentow + 1):
    grupa_id = ((i - 1) // studenci_na_grupe) + 1
    student_to_grupa[i] = grupa_id
    przedmioty = grupa_przedmioty[grupa_id]
    for przedmiot_id in przedmioty:
        output_lines.append(f"INSERT INTO ZAPISY VALUES({zapisy_id}, {i}, {grupa_id}, {przedmiot_id});")
        zapisy_id += 1

# OCENY
output_lines.append("\n-- OCENA")
ocena_id = 1
for i in range(1, liczba_studentow + 1):
    grupa_id = student_to_grupa[i]
    przedmioty = grupa_przedmioty[grupa_id]
    for przedmiot_id in przedmioty:
        nauczyciele = nauczyciele_na_przedmiot[przedmiot_id]
        nauczyciel_id = nauczyciele[0] if grupa_id % 2 == 1 else nauczyciele[1]
        typy = random.sample(TYPY_OCEN, 2)
        wartosci = random.sample(OCENY, 2)
        for typ, wartosc in zip(typy, wartosci):
            data = fake.date_between(start_date='-1y', end_date='today')
            output_lines.append(f"INSERT INTO OCENA VALUES({ocena_id}, {i}, {przedmiot_id}, {nauczyciel_id}, {wartosc}, '{typ}', DATE '{data}');")
            ocena_id += 1

# Zapis do pliku
with open("inserty.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output_lines))
