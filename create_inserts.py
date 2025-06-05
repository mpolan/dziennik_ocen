from faker import Faker
import random
fake = Faker()

tytuly = ['Prof', "Dr", "Mgr"]

for i in range(1, 101):
    # INSERT INTO STUDENT VALUES (1, 'Student1', 'Nazwisko1', 'student1@example.com', DATE '1998-06-18');
    date = fake.date_time_between(start_date='-10y', end_date='now')
    # print(date.date())
    print(f"INSERT INTO STUDENT VALUES({i}, 'Student{i}', 'Nazwisko{i}', 'student{i}@example.com', DATE '{date.date()}');")
for i in range(200, 241):
    r = random.randint(0, 2)
    # INSERT INTO NAUCZYCIEL VALUES (200, 'Nauczyciel200', 'Nazwisko200', 'nauczyciel200@example.com', 'Mgr');
    print(f"INSERT INTO NAUCZYCIEL VALUES({i}, 'Nauczyciel{i}', 'Nazwisko{i}', 'nauczyciel{i}@example.com', '{tytuly[r]}');")