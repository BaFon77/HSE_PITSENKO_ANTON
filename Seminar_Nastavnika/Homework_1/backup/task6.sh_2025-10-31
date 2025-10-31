read -p "Введите название директории: " dir
count=$(find "$dir" -type f -mtime +7 | wc -l)
find "$dir" -type f -mtime +7 -delete
echo "Удалено файлов: $count"