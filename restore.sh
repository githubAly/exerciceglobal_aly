#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 /chemin/vers/backup.sql.gz"
  exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Fichier de backup introuvable : $BACKUP_FILE"
  exit 2
fi

CONTAINER_NAME=prestashop_mysql
MYSQL_USER=prestashop
MYSQL_PASSWORD=psswrd
MYSQL_DATABASE=prestashop

echo "Restauration de la base MySQL dans le container $CONTAINER_NAME à partir de $BACKUP_FILE ..."

docker cp "$BACKUP_FILE" "$CONTAINER_NAME":/tmp/backup.sql.gz

docker exec -i $CONTAINER_NAME sh -c "
  gunzip < /tmp/backup.sql.gz | mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE
"

docker exec $CONTAINER_NAME rm -f /tmp/backup.sql.gz

echo "Restauration terminée."
