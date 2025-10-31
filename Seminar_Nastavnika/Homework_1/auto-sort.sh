# Автоматическая сортировка

if [ -z "$1" ]; then
    echo "Использование: $0 <директория для сортировки>"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Ошибка: Директория $TARGET_DIR не существует."
    exit 1
fi

IMG_DIR="$TARGET_DIR/Images"
DOC_DIR="$TARGET_DIR/Documents"
LOG_FILE="$TARGET_DIR/sort_log.txt"

mkdir -p "$IMG_DIR"
mkdir -p "$DOC_DIR"

echo "=== $(date): Начало сортировки файлов в $TARGET_DIR ===" >> "$LOG_FILE"

for file in "$TARGET_DIR"/*.{jpg,JPG,jpeg,JPEG,png,PNG,gif,GIF}; do
    [ -e "$file" ] || continue
    mv "$file" "$IMG_DIR"
    echo "$(date): Перемещен файл $file -> $IMG_DIR" >> "$LOG_FILE"
done

for file in "$TARGET_DIR"/*.{txt,TXT,pdf,PDF,docx,DOCX}; do
    [ -e "$file" ] || continue
    mv "$file" "$DOC_DIR"
    echo "$(date): Перемещен файл $file -> $DOC_DIR" >> "$LOG_FILE"
done

echo "=== $(date): Сортировка завершена ===" >> "$LOG_FILE"