# Функционал Bash

# Список файлов с типами
echo "Список файлов и их типов в текущей директории:"
for item in *; do
    echo "$item — $(file -b "$item")"
done

echo

# Проверка файла
if [ $# -eq 0 ]; then
    echo "Использование: $0 <имя_файла>"
    exit 1
fi

file_to_check="$1"

if [ -e "$file_to_check" ]; then
    echo "Файл '$file_to_check' существует."
else
    echo "Файл '$file_to_check' не найден."
fi

echo

# Информация о файле и их правах доступа
echo "Информация о файлах и их правах доступа:"
for item in *; do
    perms=$(ls -ld "$item" | awk '{print $1}')
    echo "$item — права доступа: $perms"
done