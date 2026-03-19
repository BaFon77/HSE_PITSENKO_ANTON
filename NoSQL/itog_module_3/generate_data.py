import random
import time
from datetime import datetime, timedelta
from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError

MONGO_URI = "mongodb://localhost:27017"
DB_NAME   = "university_db"
N_STUDENTS = 50_000
BATCH_SIZE = 1_000

FIRST_NAMES = [
    "Александр","Алексей","Андрей","Антон","Артём","Борис","Василий","Виктор",
    "Владимир","Дмитрий","Евгений","Иван","Игорь","Илья","Кирилл","Константин",
    "Максим","Михаил","Никита","Николай","Олег","Павел","Роман","Сергей","Степан",
    "Тимур","Фёдор","Юрий","Яков","Мария","Анна","Елена","Ольга","Наталья",
    "Екатерина","Татьяна","Ирина","Светлана","Юлия","Анастасия","Валерия",
    "Дарья","Кристина","Ксения","Людмила","Надежда","Полина","София","Вера","Зоя",
]

LAST_NAMES = [
    "Иванов","Петров","Сидоров","Козлов","Новиков","Морозов","Лебедев","Попов",
    "Соколов","Волков","Орлов","Павлов","Семёнов","Голубев","Виноградов","Богданов",
    "Воробьёв","Фёдоров","Михайлов","Беляев","Тарасов","Белов","Комаров","Киселёв",
    "Макаров","Андреев","Ковалёв","Ильин","Гусев","Титов","Кузнецов","Смирнов",
    "Васильев","Захаров","Зайцев","Соловьёв","Якушев","Степанов","Никитин","Орлова",
    "Громов","Матвеев","Денисов","Карпов","Осипов","Крылов","Фомин","Щербаков",
]

FACULTIES = [
    "Информатика", "Математика", "Физика",
    "Экономика", "Право", "Химия", "Биология", "История",
]

CITIES = [
    "Москва","Санкт-Петербург","Новосибирск","Екатеринбург","Казань",
    "Нижний Новгород","Челябинск","Самара","Омск","Ростов-на-Дону",
    "Уфа","Красноярск","Пермь","Воронеж","Волгоград",
]

COURSES = [
    ("Базы данных",              "Информатика",  4),
    ("Алгоритмы и структуры",    "Информатика",  5),
    ("Машинное обучение",        "Информатика",  6),
    ("Операционные системы",     "Информатика",  4),
    ("Сети и протоколы",         "Информатика",  4),
    ("Линейная алгебра",         "Математика",   5),
    ("Математический анализ",    "Математика",   6),
    ("Теория вероятностей",      "Математика",   4),
    ("Дискретная математика",    "Математика",   4),
    ("Квантовая механика",       "Физика",       5),
    ("Термодинамика",            "Физика",       4),
    ("Электродинамика",          "Физика",       4),
    ("Микроэкономика",           "Экономика",    4),
    ("Макроэкономика",           "Экономика",    4),
    ("Финансовый анализ",        "Экономика",    5),
    ("Гражданское право",        "Право",        5),
    ("Уголовное право",          "Право",        5),
    ("Органическая химия",       "Химия",        5),
    ("Молекулярная биология",    "Биология",     4),
    ("История России",           "История",      3),
]

def get_db():
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    client.admin.command("ping")
    return client[DB_NAME]

def gen_student(i, course_ids_by_faculty):
    first = random.choice(FIRST_NAMES)
    last  = random.choice(LAST_NAMES)
    faculty = random.choice(FACULTIES)
    year  = random.randint(1, 5)
    gpa   = round(random.uniform(2.0, 5.0), 2)
    enrolled = datetime(2015, 1, 1) + timedelta(days=random.randint(0, 3000))

    student = {
        "student_id":  f"STU{i:06d}",
        "first_name":  first,
        "last_name":   last,
        "email":       f"{last.lower()}{i}@university.ru",
        "faculty":     faculty,
        "year":        year,
        "gpa":         gpa,
        "city":        random.choice(CITIES),
        "enrolled_at": enrolled,
        "is_active":   random.random() > 0.05,  # 95% активны
    }
    return student, faculty

def gen_grades(student_id, faculty, course_ids_by_faculty, all_course_ids):
    faculty_courses = course_ids_by_faculty.get(faculty, [])
    other_courses   = [c for c in all_course_ids if c not in faculty_courses]

    n_faculty = min(len(faculty_courses), random.randint(2, 4))
    n_other   = random.randint(0, 2)

    chosen = random.sample(faculty_courses, n_faculty)
    if other_courses and n_other:
        chosen += random.sample(other_courses, min(n_other, len(other_courses)))

    grades = []
    for cid in chosen:
        grades.append({
            "student_id": student_id,
            "course_id":  cid,
            "grade":      round(random.uniform(2.0, 5.0), 1),
            "date":       datetime(2020, 1, 1) + timedelta(days=random.randint(0, 1500)),
            "attempt":    random.randint(1, 3),
        })
    return grades


def main():
    print(f"=== Генератор данных: {N_STUDENTS} студентов ===\n")

    db = get_db()

    db.students.delete_many({})
    db.courses.delete_many({})
    db.grades.delete_many({})

    course_docs = []
    for name, dept, credits in COURSES:
        course_docs.append({
            "name":       name,
            "department": dept,
            "credits":    credits,
            "semester":   random.randint(1, 8),
        })
    inserted_courses = db.courses.insert_many(course_docs)
    course_ids = inserted_courses.inserted_ids

    course_ids_by_faculty = {}
    for cid, (_, dept, _) in zip(course_ids, COURSES):
        course_ids_by_faculty.setdefault(dept, []).append(cid)
    all_course_ids = list(course_ids)

    total_grades = 0

    for batch_start in range(1, N_STUDENTS + 1, BATCH_SIZE):
        batch_end = min(batch_start + BATCH_SIZE - 1, N_STUDENTS)

        student_batch = []
        faculty_map   = {}
        for i in range(batch_start, batch_end + 1):
            student, faculty = gen_student(i, course_ids_by_faculty)
            student_batch.append(student)
            faculty_map[i] = faculty

        result = db.students.insert_many(student_batch, ordered=False)
        inserted_ids = result.inserted_ids

        grades_batch = []
        for idx, sid in enumerate(inserted_ids):
            i = batch_start + idx
            grades = gen_grades(sid, faculty_map[i],
                                course_ids_by_faculty, all_course_ids)
            grades_batch.extend(grades)

        db.grades.insert_many(grades_batch, ordered=False)
        total_grades += len(grades_batch)

    db.students.create_index("faculty")
    db.students.create_index("last_name")
    db.grades.create_index("course_id")

    print("Данные сгенерированы")

if __name__ == "__main__":
    main()
