#!/bin/bash

# Pon los host a escanear en hosts
#ejemplo: hosts=("192.168.19" "192.168.20") 

hosts=("192.168.214")

function ctrl_c(){
	echo -e "\n\e[1;31m[!] Saliendo...\n\e[1;37m"
	exit 1
}
trap ctrl_c INT

tput civis
for host in ${hosts[@]};do
	echo -e "\n\e[1;32m[+] Enumerando $host.0/24\n"
	for i in $(seq 1 254);do
		timeout 1 bash -c "ping -c 1 $host.$i" &> /dev/null && echo -e "\t\e[0;36m[+] Host $host.$i - ACTIVO" &
		timeout 1 bash -c "ping -c 1 $host.$i" &> /dev/null && echo -e "\t[+] Host $host.$i - ACTIVO" | grep "Host" | awk '{print $3}' >> ips &
	done; wait
done

for ip in $(cat ips);do
	echo -e "\n\t\e[1;32m[+] Escaneando puertos en $ip\n"
	for port in $(seq 1 10000);do
		timeout 1 bash -c "echo '' > /dev/tcp/$ip/$port" 2> /dev/null && echo -e "\t\t\e[0;31m[!] Puerto $port - ABIERTO" &
	done; wait
done 
tput cnorm
rm ips

