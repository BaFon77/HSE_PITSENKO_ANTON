# Управляющие конструкции (условия и циклы)

read -p "Введите число: " num

if [ "$num" -gt 0 ]; then
    echo "Число положительное."
elif [ "$num" -lt 0 ]; then
    echo "Число отрицательное."
else
    echo "Это ноль."
fi

echo

if [ "$num" -gt 0 ]; then
    i=1
    echo "Считаем от 1 до $num:"
    while [ "$i" -le "$num" ]; do
        echo "$i"
        ((i++))
    done
fi