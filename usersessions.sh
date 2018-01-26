#!/bin/bash

function base { #sem args

declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" " #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split
	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos
		rawuser+=("${sp[0]}")
	fi
	#rawuser = todos os users encontrados
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi
done < "$file"

#print
#$2 = -t
#$3 = -n
#$4 = -r

if [[ "$3" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$4" == 1 ]]; then
	sort -n -r -k3 p.txt
	else
	sort -n -k3 p.txt
	fi
elif [[ "$2" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$4" == 1 ]]; then
	sort -n -r -k2 p.txt
	else
	sort -n -k2 p.txt
	fi
elif [[ "$4" == 1 ]]; then

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














function u { #arg = substring user

IFS="." #argumento para split, descobrir se string tem .*
#abc.* = user contém abc
#abc = user é abc

read -a sub <<< "$2"

declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" " #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split

	#se .* (todos)
	if [ "$2" == "." ]; then 

	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos
		rawuser+=("${sp[0]}")
	fi

	#se tem substring
	elif [ "${sub[1]}" = "*" ] && [[ "${sp[0]}" =~ "$sub" ]]; then 

	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos
		rawuser+=("${sp[0]}")
	fi

	#se o nome é igual
	elif [ "${sub[1]}" != "*" ] && [ "${sp[0]}" == "$sub" ]; then

	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos
		rawuser+=("${sp[0]}")
	fi

	fi
	#rawuser = todos os users encontrados
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi
done < "$file"

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










function g { #arg = groupname


declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" " #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split
	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos

	group="$(id -g -n ${sp[0]} 2> /dev/null)"
	#grupo correspondente
	#-g para apenas id do grupo, -n para nome real
	#2> /dev/null = elimina mensagens de erro
	if [ "$group" == "$2" ]; then
		rawuser+=("${sp[0]}")
	fi

	fi
	#rawuser = todos os users encontrados
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi
done < "$file"

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










function s { #arg = data inicio

declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#converter data para um número
#de modo a poder comparar datas
#a formula é min+100*h+2500*d+80000*mês
#converter o mês para letras minúsculas
IFS=" :"
aux="$(tr '[:upper:]' '[:lower:]' <<< "$2")"
read -a sdate <<< "${aux}"
sval=0
smin=${sdate[3]}
sh=${sdate[2]}
sd=${sdate[1]}
smes=${sdate[0]}

let sval+=$(( (${sh#0} + 0) * 100))+${smin#0}+$(( (${sd#0} + 0) * 2500))

case "$smes" in
feb ) let sval+=80000;;
mar ) let sval+=2*80000;;
apr ) let sval+=3*80000;;
may ) let sval+=4*80000;;
jun ) let sval+=5*80000;;
jul ) let sval+=6*80000;;
aug ) let sval+=7*80000;;
sep ) let sval+=8*80000;;
oct ) let sval+=9*80000;;
nov ) let sval+=10*80000;;
dec ) let sval+=11*80000;;
esac

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" :" #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split
	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -gt "$sval" ]]; then

		rawuser+=("${sp[0]}")

	fi

	fi
	#rawuser = todos os users encontrados
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -gt "$sval" ]]; then

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi

	fi
done < "$file"

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









function se { #args = data inicio, data fim

declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#converter data para um número
#de modo a poder comparar datas
#a formula é min+100*h+2500*d+80000*mês
#converter o mês para letras minúsculas
IFS=" :"
eaux="$(tr '[:upper:]' '[:lower:]' <<< "$3")"
read -a edate <<< "${eaux}"
eval=0
emin=${edate[3]}
eh=${edate[2]}
ed=${edate[1]}
emes=${edate[0]}

saux="$(tr '[:upper:]' '[:lower:]' <<< "$2")"
read -a sdate <<< "${saux}"
sval=0
smin=${sdate[3]}
sh=${sdate[2]}
sd=${sdate[1]}
smes=${sdate[0]}

let eval+=$(( (${eh#0} + 0) * 100))+${emin#0}+$(( (${ed#0} + 0) * 2500))

let sval+=$(( (${sh#0} + 0) * 100))+${smin#0}+$(( (${sd#0} + 0) * 2500))

case "$emes" in
feb ) let eval+=80000;;
mar ) let eval+=2*80000;;
apr ) let eval+=3*80000;;
may ) let eval+=4*80000;;
jun ) let eval+=5*80000;;
jul ) let eval+=6*80000;;
aug ) let eval+=7*80000;;
sep ) let eval+=8*80000;;
oct ) let eval+=9*80000;;
nov ) let eval+=10*80000;;
dec ) let eval+=11*80000;;
esac

case "$smes" in
feb ) let sval+=80000;;
mar ) let sval+=2*80000;;
apr ) let sval+=3*80000;;
may ) let sval+=4*80000;;
jun ) let sval+=5*80000;;
jul ) let sval+=6*80000;;
aug ) let sval+=7*80000;;
sep ) let sval+=8*80000;;
oct ) let sval+=9*80000;;
nov ) let sval+=10*80000;;
dec ) let sval+=11*80000;;
esac

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" :" #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split
	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -lt "$eval" ]] && [[ "$lval" -gt "$sval" ]]; then
		rawuser+=("${sp[0]}")

	fi

	fi
	#rawuser = users no periodo de tempo definido
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -lt "$eval" ]] && [[ "$lval" -gt "$sval" ]]; then

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi

	fi
done < "$file"

#print
#$4 = -t
#$5 = -n
#$6 = -r

if [[ "$5" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$6" == 1 ]]; then
	sort -n -r -k3 p.txt
	else
	sort -n -k3 p.txt
	fi
elif [[ "$4" == 1 ]]; then

	for key in ${!mins[@]}; do
	echo ${key} ${mins[${key}]} ${user[${key}]} >> p.txt
	done

	if [[ "$6" == 1 ]]; then
	sort -n -r -k2 p.txt
	else
	sort -n -k2 p.txt
	fi
elif [[ "$6" == 1 ]]; then

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








function e { #arg = data fim

declare -a rawuser #array users
declare -A user #array user-nsessoes
declare -A mins #array user-tempo

#converter data para um número
#de modo a poder comparar datas
#a formula é min+100*h+2500*d+80000*mês
#converter o mês para letras minúsculas
IFS=" :"
aux="$(tr '[:upper:]' '[:lower:]' <<< "$2")"
read -a edate <<< "${aux}"
eval=0
emin=${edate[3]}
eh=${edate[2]}
ed=${edate[1]}
emes=${edate[0]}

let eval+=$(( (${eh#0} + 0) * 100))+${emin#0}+$(( (${ed#0} + 0) * 2500))

case "$emes" in
feb ) let eval+=80000;;
mar ) let eval+=2*80000;;
apr ) let eval+=3*80000;;
may ) let eval+=4*80000;;
jun ) let eval+=5*80000;;
jul ) let eval+=6*80000;;
aug ) let eval+=7*80000;;
sep ) let eval+=8*80000;;
oct ) let eval+=9*80000;;
nov ) let eval+=10*80000;;
dec ) let eval+=11*80000;;
esac

#1º leitura - criar lista de users
file=$1
while read -r line; do
	IFS=" :" #argumento para split
	read -a sp <<< "${line}"
	#sp = array com resultado do split
	if [ "${sp[0]}" != "wtmp" ] && [ "${sp[0]}" != "reboot" ]; then #ignorar users falsos

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -lt "$eval" ]]; then

		rawuser+=("${sp[0]}")

	fi

	fi
	#rawuser = users no periodo de tempo definido
done < "$file"

for arg in ${rawuser[@]}; do
	#verificar repetiçao
	rep=0
	for key in ${!user[@]}; do
		if [ "$key" == "$arg" ]; then
			rep=1
		fi
	done

	if [[ "$rep" -eq 0 ]]; then #nova key
		user["$arg"]=1
	else #update do value
		let user["$arg"]+=1
	fi
done


#copiar keys de user para mins
for key in ${!user[@]}; do
	mins["$key"]=0
done


#2º leitura - tempos
file=$1
while read -r line; do
	IFS=" ():+" #argumento para split
	read -a sp <<< "${line}"
	if [ "${sp[0]}" != "reboot" ] && [ "${sp[0]}" != "wtmp" ]; then #validar linha

	#transformar data em número
	lval=0
	lmin=${sp[6]}
	lh=${sp[5]}
	ld=${sp[4]}
	lmes="$(tr '[:upper:]' '[:lower:]' <<< "${sp[3]}")"

	let lval+=$(( (${lh#0} + 0) * 100))+${lmin#0}+$(( (${ld#0} + 0) * 2500))

	case "$lmes" in
	feb ) let lval+=80000;;
	mar ) let lval+=2*80000;;
	apr ) let lval+=3*80000;;
	may ) let lval+=4*80000;;
	jun ) let lval+=5*80000;;
	jul ) let lval+=6*80000;;
	aug ) let lval+=7*80000;;
	sep ) let lval+=8*80000;;
	oct ) let lval+=9*80000;;
	nov ) let lval+=10*80000;;
	dec ) let lval+=11*80000;;
	esac

	if [[ "$lval" -lt "$eval" ]]; then

	for key in ${!mins[@]}; do
	if [ "$key" == "${sp[0]}" ]; then

	case "${#sp[@]}" in 
	13 ) #crash/down
	h=${sp[11]}
	m=${sp[12]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	14 ) #crash/down + days
	d=${sp[11]}
	h=${sp[12]}
	m=${sp[13]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	19 ) #normal
	h=${sp[17]}
	m=${sp[18]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}
	;;
	20 ) #normal + days
	d=${sp[17]}
	h=${sp[18]}
	m=${sp[19]}
	let mins["$key"]+=$(( (${h#0} + 0) * 60))+${m#0}+$(( ($d + 0) * 24 * 60))
	;;
	esac

	fi
	done

	fi

	fi
done < "$file"

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
#causadas pelo sort se não existir resultado

if [[ "$#" -gt 6 ]]; then
	echo "Erro na quantidade de argumentos."
	echo "Sintaxe: (-op) (-op) (-modo) [args]"
	exit 1
fi

function sintaxerr { #termina script se sintaxe errada
echo "Sintaxe inválida."
echo "Modos existentes:"
echo "(nenhum); -u [nome]; -g [grupo]; -s [data]"
echo "-e [data]; -s [data] -e [data]"
echo "Argumentos possíveis para ordenação:"
echo "-r; -t (-r); -n (-r)"
exit 1
}

#flags
rf=0
tf=0
nf=0
sf=0
ef=0
gf=0
uf=0
somaflags=0

#descobrir flags
while getopts ":rtns:e:g:u:" opt; do
	case $opt in
	r ) rf=1;;
	t ) tf=1;;
	n ) nf=1;;

	s ) sf=1
	sarg=$OPTARG;;
	e ) ef=1
	earg=$OPTARG;;
	g ) gf=2
	garg=$OPTARG;;
	u ) uf=2
	uarg=$OPTARG;;

	\? ) sintaxerr #op inválida
	exit 1;;
	: ) sintaxerr #modo não recebeu arg
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

#combinações inválidas de modos
let somaflags+=($sf + $ef + $gf + $uf)
if [ ! "$somaflags" -eq 1 ] && [ ! "$somaflags" -eq 2 ] && [ ! "$somaflags" -eq 0 ]; then
sintaxerr
exit 1
fi

#correr script
$( last -F -R > output.txt )

if [[ "$somaflags" == 0 ]]; then
	base output.txt $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
elif [[ "$uf" == 2 ]]; then
	u output.txt "$uarg" $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
elif [[ "$gf" == 2 ]]; then
	g output.txt "$garg" $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
elif [[ "$sf" == 1 ]] && [[ "$ef" == 0 ]]; then
	s output.txt "$sarg" $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
elif [[ "$ef" == 1 ]] && [[ "$sf" == 0 ]]; then
	e output.txt "$earg" $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
elif [[ "$ef" == 1 ]] && [[ "$sf" == 1 ]]; then
	se output.txt "$sarg" "$earg" $tf $nf $rf 2> /dev/null
	rm -f p.txt
	rm -f output.txt
	exit 0
fi
