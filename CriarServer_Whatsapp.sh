#!/bin/bash

#
# 1_CriarServidor.sh - Busca o nome completo de um usuário no Unix
#
# Autor     : Pabllo Moura <>
# Manutenção: Pabllo Moura <>
#
#  -------------------------------------------------------------

#Recolhendo as variáveis.

read -p "Digite o nome do novo cliente: " name
read -p "Digite o domínio (exp netsupre.com.br): " url
read -p "Digite a url da logo: " logo
read -p "Digite a porta PM2 do backend: " porta_back
read -p "Digite a porta PM2 do frontend: " porta_front
read -p "Digite a senha do banco de dados: " senha_db

#Criar diretório do novo Cliente e mudar o dono do diretório para root.
echo "Criando o diretório do novo Cliente"

mkdir /www/wwwroot/"$name"
chown -R root /www/wwwroot/"$name"
    
mkdir /www/wwwroot/"$name"/frontend
chown -R root /www/wwwroot/"$name"/frontend
mkdir /www/wwwroot/"$name"/backend
chown -R root /www/wwwroot/"$name"/backend

echo "Diretório Criado"

#Copiando os arquivos padrão para para do novo cliente.
echo "Copiando os arquivos primários"

cp -r /www/wwwroot/PROJETOPADRAO/PADRAO/netchat-base/* /www/wwwroot/"$name"/

cd /www/wwwroot/"$name"/ || exit

echo "Cópia Finalizada"

#Executando o script Create.sh

echo "Configurando tudo para você, favor aguarde."

git pull https://netsuprema-dsv-netchat:glpat-yPRFPsUttzFboryv5viz@gitlab.com/net-suprema/net-chat.git

npm ci

echo "Configurando tudo para você, favor aguarde.."

rm -rf backend/dist frontend/build
npm run build -ws

echo "Configurando tudo para você, favor aguarde..."

# Configura o arquivo .env
sudo tee /www/wwwroot/"$name"/backend/.env <<EOF

NODE_ENV=production
BACKEND_URL=https://api"$name".$url
FRONTEND_URL=https://"$name".$url
PROXY_PORT=443
PORT=$porta_back

DB_DIALECT=mysql
DB_HOST=127.0.0.1
DB_USER="$name"
DB_PASS=$senha_db
DB_NAME="$name"

USER_LIMIT=300
CONNECTIONS_LIMIT=3

JWT_SECRET=devsecret
JWT_REFRESH_SECRET=devrefreshsecret

EOF

sudo tee /www/wwwroot/"$name"/frontend/.env <<EOF

REACT_APP_BACKEND_URL=https://api"$name".$url
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=
PORT=$porta_front
REACT_APP_LOGO=$logo

EOF

echo "Configurando o Banco de Dados, favor aguarde."

cd backend || exit
npx sequelize db:migrate
npx sequelize db:seed:all

echo "Criado!"

read -p "Você já configurou as portas no P2M Manager? (y/n): "
read -p "Você já mapeou as portas no P2M Manager? (y/n): "
read -p "Você já configurou o certificado SSL? (y/n): "
read -p "Você deseja atualizar e finalizar a instalação? (y/n): " resposta

if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ] || [ "$resposta" = "sim" ] || [ "$resposta" = "Sim" ]; then
    echo "O processo de atualização será inicializado"

#read -p "Digite o nome do cliente: " name

cd /www/wwwroot/"$name"/ || exit

echo "Atualizando, aguarde..."

git pull https://netsuprema-dsv-netchat:glpat-yPRFPsUttzFboryv5viz@gitlab.com/net-suprema/net-chat.git

npm ci

rm -rf backend/dist frontend/build
npm run build -ws

cd backend || exit
npx sequelize db:migrate

pm2 restart "$name"-backend "$name"-frontend

echo "Atualizado!"


else
    echo "Quando terminar as atualizações execute o script 2_update.sh"
fi

#Link para acesso ao sistema.

echo "Você pode acessar o sistema pelo seguinte link: https://$name.$url"