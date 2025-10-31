# Менеджер резервного копирования

SOURCE_DIR="$1"
BACKUP_DIR="$2"
LOG_FILE="$BACKUP_DIR/backup.log"
DATE=$(date +%Y-%m-%d)

if [[ -z "$SOURCE_DIR" || -z "$BACKUP_DIR" ]]; then
    echo "Использование: $0 <исходная_директория> <директория_резервного_копирования>"
    exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Ошибка: исходная директория '$SOURCE_DIR' не существует."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

count=0
for file in "$SOURCE_DIR"/*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        backup_file="$BACKUP_DIR/${filename}_${DATE}"
        cp "$file" "$backup_file"
        if [[ $? -eq 0 ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Скопирован: $filename -> $backup_file" >> "$LOG_FILE"
            ((count++))
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Ошибка копирования: $filename" >> "$LOG_FILE"
        fi
    fi
done

echo "Резервное копирование завершено. Скопировано файлов: $count"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Резервное копирование завершено. Скопировано файлов: $count" >> "$LOG_FILE"