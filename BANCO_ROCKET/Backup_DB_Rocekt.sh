!# /bin/bash

#Metodo de restaurar o BKP:
#Após subir o Docker o Docker composer e iniciar um container do Rocket.
#Copie o BKP para o mesmo local onde está o "docker-compose.yml"
#Copiei o nome do container e execute o segunte comando:
#docker exec -i <database_name> sh -c 'mongorestore --archive' < db.dump
#Site onde tem as instruções: https://docs.rocket.chat/deploy/prepare-for-your-deployment/rapid-deployment-methods/docker-and-docker-compose/docker-mongo-backup-and-restore

# Cria o backup "db.dumb' na pasta onde está o "docker-compose.yml"
docker exec docker-compose-mongodb-1 sh -c 'mongodump --archive' > db.dump

# Copia o Backup para um local na minha maquina.
scp /home/pabllogomez/Documentos/Scripts/docker-compose/db.dump /home/pabllogomez/Documentos/Scripts/docker-compose/BKP_DB/ 

# Copia o Backup para um local no 7.11 /infraestrutura/zPABLLO/BKP/
scp /home/pabllogomez/Documentos/Scripts/docker-compose/db.dump /run/user/1000/gvfs/smb-share:server=192.168.7.11,share=infraestrutura/zPABLLO/BKP/

