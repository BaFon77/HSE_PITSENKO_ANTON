# Ввод/вывод и перенаправление

echo "Содержимое файла input.txt:"
cat input.txt
echo

wc -l < input.txt > output.txt
echo "Количество строк записано в файл output.txt."
echo

ls notexist.txt 2> error.log
echo "Ошибки выполнения команды ls записаны в error.log."