# University DB
 
База данных студентов университета на MongoDB с горизонтальным шардингом.
 
## Структура проекта
 
```
itog_module_3/
├── docker-compose.yml      # Конфигурация кластера MongoDB
├── app.py                  # Консольный интерфейс
├── generate_data.py        # Генератор тестовых данных
├── requirements.txt        # Зависимости Python
├── README.md
└── ycsb-mongodb-binding-0.17.0/
    ├── workload.dat         # Параметры теста (шардинг)
    └── workload_single.dat  # Параметры теста (одиночный)
```
 
## Запуск
 
### 1. Установить зависимости
 
```
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```
 
### 2. Запустить кластер
 
```
docker-compose up -d
```
 
### 3. Инициализировать шардинг
 
```
docker exec configsvr mongosh --port 27019 --eval "rs.initiate({_id:'configReplSet',configsvr:true,members:[{_id:0,host:'configsvr:27019'}]})"
  
docker exec shard1 mongosh --port 27018 --eval "rs.initiate({_id:'shard1ReplSet',members:[{_id:0,host:'shard1:27018'}]})"
docker exec shard2 mongosh --port 27017 --eval "rs.initiate({_id:'shard2ReplSet',members:[{_id:0,host:'shard2:27017'}]})"
  
docker exec mongos mongosh --eval "sh.addShard('shard1ReplSet/shard1:27018')"
docker exec mongos mongosh --eval "sh.addShard('shard2ReplSet/shard2:27017')"
docker exec mongos mongosh --eval "sh.enableSharding('university_db')"
 
docker exec mongos mongosh university_db --eval "db.createCollection('students'); db.students.createIndex({student_id:'hashed'})"
docker exec mongos mongosh --eval "db.adminCommand({shardCollection:'university_db.students',key:{student_id:'hashed'}})"
docker exec mongos mongosh university_db --eval "db.createCollection('grades'); db.grades.createIndex({student_id:'hashed'})"
docker exec mongos mongosh --eval "db.adminCommand({shardCollection:'university_db.grades',key:{student_id:'hashed'}})"
docker exec mongos mongosh university_db --eval "db.createCollection('courses'); db.courses.createIndex({department:'hashed'})"
docker exec mongos mongosh --eval "db.adminCommand({shardCollection:'university_db.courses',key:{department:'hashed'}})"
```
 
### 4. Сгенерировать данные
 
```
python generate_data.py
```
 
### 5. Запустить интерфейс
 
```
python app.py
```
