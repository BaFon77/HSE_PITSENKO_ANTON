add () {
    local a=$1
    local b=$2
    local sum=$((a + b))
    echo "$sum"
}

read -p "Введите первое число: " num1
read -p "Введите второе число: " num2

echo "Сумма: $(add $num1 $num2)"