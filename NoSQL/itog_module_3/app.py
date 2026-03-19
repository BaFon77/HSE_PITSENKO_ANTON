import sys
from datetime import datetime
from pymongo import MongoClient

MONGO_URI = "mongodb://localhost:27017"
DB_NAME   = "university_db"
FACULTIES = ["Информатика","Математика","Физика","Экономика","Право","Химия","Биология","История"]

def get_db():
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=3000)
    client.admin.command("ping")
    return client[DB_NAME]

def cmd_list(db):
    fac  = input("Факультет (Enter — все): ").strip() or None
    rows = list(db.students.find({"faculty": fac} if fac else {}).limit(20))
    for s in rows:
        print(f"{s['student_id']}  {s['first_name']} {s['last_name']}  {s['faculty']}  курс {s['year']}  GPA {s['gpa']}")
    if not rows:
        print("Не найдено.")

def cmd_search(db):
    q    = input("Фамилия или ID: ").strip()
    rows = list(db.students.find({
        "$or": [{"last_name":  {"$regex": q, "$options": "i"}},
                {"student_id": {"$regex": q, "$options": "i"}}]
    }).limit(20))
    for s in rows:
        print(f"{s['student_id']}  {s['first_name']} {s['last_name']}  {s['faculty']}  GPA {s['gpa']}")
    if not rows:
        print("Не найдено.")

def cmd_add(db):
    sid  = input("Student ID: ").strip()
    name = input("Имя Фамилия: ").strip().split()
    fac  = input("Факультет: ").strip()
    year = int(input("Курс (1-5): ").strip())
    db.students.insert_one({
        "student_id": sid,
        "first_name": name[0] if name else "",
        "last_name":  name[1] if len(name) > 1 else "",
        "faculty": fac, "year": year, "gpa": 0.0,
        "enrolled_at": datetime.now(),
    })
    print(f"Добавлен: {sid}")

def cmd_delete(db):
    sid = input("Student ID: ").strip()
    res = db.students.delete_one({"student_id": sid})
    print("Удалён." if res.deleted_count else "Не найден.")

def cmd_grades(db):
    sid = input("Student ID: ").strip()
    s   = db.students.find_one({"student_id": sid})
    if not s:
        print("Не найден.")
        return
    grades = list(db.grades.find({"student_id": s["_id"]}))
    if not grades:
        print("Оценок нет.")
        return
    for g in grades:
        c = db.courses.find_one({"_id": g["course_id"]})
        print(f"{(c['name'] if c else '—'):<30} {g['grade']}  {g['date'].strftime('%d.%m.%Y')}")

def cmd_add_grade(db):
    sid = input("Student ID: ").strip()
    s   = db.students.find_one({"student_id": sid})
    if not s:
        print("Студент не найден.")
        return

    courses = list(db.courses.find())
    if not courses:
        print("Курсы не найдены.")
        return

    print("Доступные курсы:")
    for i, c in enumerate(courses):
        print(f"  {i+1}. {c['name']}  ({c['department']})")

    idx   = int(input("Номер курса: ").strip()) - 1
    grade = float(input("Оценка (2.0-5.0): ").strip())

    if not (0 <= idx < len(courses)):
        print("Неверный номер.")
        return
    if not (2.0 <= grade <= 5.0):
        print("Оценка должна быть от 2.0 до 5.0.")
        return

    db.grades.insert_one({
        "student_id": s["_id"],
        "course_id":  courses[idx]["_id"],
        "grade":      grade,
        "date":       datetime.now(),
        "attempt":    1,
    })
    print(f"Оценка {grade} по курсу «{courses[idx]['name']}» добавлена.")

def cmd_stats(db):
    print(f"Студентов: {db.students.count_documents({})}  Оценок: {db.grades.count_documents({})}\n")
    for r in sorted(db.students.aggregate([
        {"$group": {"_id": "$faculty", "n": {"$sum": 1}, "gpa": {"$avg": "$gpa"}}}
    ]), key=lambda x: -x["n"]):
        print(f"{r['_id']:<20} {r['n']} студ.  GPA {r['gpa']:.2f}")

def cmd_shards(db):
    shards = list(db.client.config.shards.find())
    print(f"Шардов: {len(shards)}  Чанков: {db.client.config.chunks.count_documents({})}")
    for s in shards:
        print(f"  {s['_id']}: {s['host']}")

COMMANDS = {
    "1": ("Список",         cmd_list),
    "2": ("Поиск",          cmd_search),
    "3": ("Добавить студ.", cmd_add),
    "4": ("Удалить студ.",  cmd_delete),
    "5": ("Оценки студ.",   cmd_grades),
    "6": ("Добавить оценку",cmd_add_grade),
    "7": ("Статистика",     cmd_stats),
    "8": ("Шардинг",        cmd_shards),
    "0": ("Выход",          None),
}

def main():
    try:
        db = get_db()
    except Exception as e:
        print(f"Ошибка подключения: {e}")
        sys.exit(1)

    while True:
        print("\n" + "  ".join(f"{k}.{v[0]}" for k, v in COMMANDS.items()))
        choice = input("> ").strip()
        if choice == "0":
            break
        elif choice in COMMANDS:
            print()
            COMMANDS[choice][1](db)
        else:
            print("?")
        input("[Enter]")

if __name__ == "__main__":
    main()
