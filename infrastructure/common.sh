run_command () {

clear
echo "запуск команды"
echo ""
echo "     [1;36m$1"
echo "[0m"

read
echo "вывод команды"
if [ ! -z "$2" ]; then
    cd $2;
fi

echo $(pwd)
$1

}

