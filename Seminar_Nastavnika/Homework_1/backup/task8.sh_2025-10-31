usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$usage" -ge 80 ]; then
    echo "ПРЕДУПРЕЖДЕНИЕ! Использование диска: ${usage}%"
else
    echo "Диск в норме: ${usage}%"
fi