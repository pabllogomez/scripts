#!/bin/bash

read -p "Digite o nome seu domínio: " seudominio
read -p "Digite o ip do servidor: " ip
read -p "Digite a senha do administrator: " senhaadmin
read -p "Digite o nome do servidor: " suamaquina

dominio_realm=$seudominio".local"
dominio=$seudominio
ip=$ip
adminpass=$senhaadmin
nomedamaquina=$suamaquina"_dc"

echo $dominio_realm $dominio $ip $adminpass $nomedamaquina
