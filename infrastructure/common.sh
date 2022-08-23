run_command () {

clear
if [ ! -z "$2" ]; then
    cd $2;
fi
echo ""
echo $(pwd)

echo "запуск команды"
echo ""
echo "     [1;36m$1"
echo "[0m"

read
echo "вывод команды"
eval $1

}

