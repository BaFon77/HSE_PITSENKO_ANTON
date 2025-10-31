# Работа с функциями

say_hello() {
    name="$1"
    echo "Hello, $name"
}

add_numbers() {
    a="$1"
    b="$2"
    sum=$((a + b))
    echo "$sum"
}

read -p "Введите строку: " str
say_hello "$str"

echo
read -p "Введите первое число: " num1
read -p "Введите второе число: " num2

result=$(add_numbers "$num1" "$num2")
echo "$num1 + $num2 = $result"