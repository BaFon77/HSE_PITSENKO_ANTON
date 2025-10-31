read -p "Введите название директории: " dir
if [ -d "$dir" ]; then
	dirname=$(basename "$dir")
	archive_name="${dirname}_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
	tar -czf "$archive_name" -C "$(dirname "$dir")" "$dirname"
	echo "Архив успешно создан: $archive_name"
else
	echo "Ошибка директории не существует"
fi
