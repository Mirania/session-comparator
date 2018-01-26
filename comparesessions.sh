#!/bin/bash

#o programa irá gerar uma lista de users
#e guardar os valores que a cada um correspondem
#os valores do 1º ficheiro serão adicionados
#e os valores do 2º ficheiros serão subtraídos

function compare { #$1 e $2 são ficheiros

declare -A user #array user-nsessoes
declare -A mins #array user-tempo

file1=$1

while read -r line; do
	IFS=" " #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split

	user["${sp[0]}"]=${sp[2]}
	mins["${sp[0]}"]=${sp[1]}

done < "$file1"

file2=$2

while read -r line; do
	IFS=" " #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split

	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "${sp[0]}" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["${sp[0]}"]=$(( 0 - ${sp[2]} ))
		mins["${sp[0]}"]=$(( 0 - ${sp[1]} ))
	else #update do value
		let user["${sp[0]}"]-=${sp[2]}
		let mins["${sp[0]}"]-=${sp[1]}
	fi

done < "$file2"

#print
#$3 = -t
#$4 = -n
#$5 = -r

if [[ "$4" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$5" == 1 ]]; then
	sort -n -r -k3 p.txt
	else
	sort -n -k3 p.txt
	fi
elif [[ "$3" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$5" == 1 ]]; then
	sort -n -r -k2 p.txt
	else
	sort -n -k2 p.txt
	fi
elif [[ "$5" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	sort -n -r p.txt
else
	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	sort -n p.txt
fi

}


#main
#2> /dev/null = elimina mensagens de erro
#ficheiro 1
f1=${@: -2:1}
#ficheiro 2
f2=${@: -1}

if [[ "$#" -gt 4 ]] || [[ "$#" -lt 2 ]]; then
	echo "Erro na quantidade de argumentos."
	echo "Sintaxe: (-op) (-op) ficheiro1 ficheiro2"
	exit 1
fi

function fcheck { #termina script se ficheiros não existem
if [ ! -e "$1" ] || [ ! -e "$2" ]; then
	echo "Ficheiro(s) não reconhecido(s)."
	echo "Os ficheiros devem ser os últimos 2 argumentos."
	exit 1
fi 
}

function sintaxerr { #termina script se sintaxe errada
echo "Sintaxe inválida."
echo "Argumentos possíveis:"
echo "-r"
echo "-t (-r)"
echo "-n (-r)"
exit 1
}

#flags
rf=0
tf=0
nf=0

while getopts ":rtn" opt; do
	case $opt in
	r ) rf=1;;
	t ) tf=1;;
	n ) nf=1;;
	\? ) sintaxerr #op inválida
	exit 1;;
	esac
done

#combinações inválidas de ordenadores
if [[ "$tf" == 1 ]] && [[ "$nf" == 1 ]]; then
	echo "Sintaxe inválida."
	echo "Argumentos possíveis para ordenação:"
	echo "-r; -t (-r); -n (-r)"
	exit 1
fi

#correr script
fcheck $f1 $f2
compare $f1 $f2 $tf $nf $rf 2> /dev/null
rm -f p.txt
exit 0

