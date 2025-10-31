# Система мониторинга

echo "Загрузка процессора:"
top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " 100 - $8 "%"}'

mem_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
echo "Использование памяти: $mem_usage%"

echo "Использование диска:"
df -h | awk '$NF=="/"{printf "Диск /: %s/%s (%s)\n", $3,$2,$5}'
df -h --output=source,pcent,target | grep -v 'tmpfs' | grep -v 'udev'

if [ "$mem_usage" -gt 80 ]; then
    echo "Внимание! Использование памяти выше 80%."
    echo "Топ процессов по использованию памяти:"
    ps aux --sort=-%mem | head -n 10
fi