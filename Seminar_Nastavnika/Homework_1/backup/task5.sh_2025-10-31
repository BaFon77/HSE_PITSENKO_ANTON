read -p "Укажите желаемую директорию: " dir
for file in ${dir}/*; do
    if [ -f "$file" ]; then
        mv "$file" "$dir/backup_$(basename "$file")"
    fi
done