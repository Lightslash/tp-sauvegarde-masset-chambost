#!/bin/bash

DATABASE_HOST='localhost'
DATABASE_USER='root'
DATABASE_PASSWORD='root'
DATABASE_DBNAME='nextcloud'

port=$0
host=$1
snapshot_name=$2

how_to_use() {
    echo "how to use: port user@hostname snapshot_name \n"
    exit 1
}

restore_from_backup() {
    echo "Mise en maintenance du serveur NextCloud \n"
    ssh -p $port $host "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on"

    echo "Verrouillage snapshot \n"
    zfs hold keep host

    echo "Clonage snapshot \n"
    zfs clone host data/restore

    echo "Restauration des fichiers, veuillez patienter \n"
    rsync -Aavx /data/restore/nextcloud-dirbackup/ -e "ssh -p $port" $host:/var/www/html/nextcloud/

    echo "Nettoyage de la base de données \n"
    ssh -p $port $host  "mysql -h $DATABASE_HOST -u $DATABASE_USER --password=$DATABASE_PASSWORD -e \"DROP DATABASE $DATABASE_DBNAME\""
    ssh -p $port $host  "mysql -h $DATABASE_HOST -u $DATABASE_USER --password=$DATABASE_PASSWORD -e \"CREATE DATABASE $DATABASE_DBNAME\""

    echo "Restauration de la base de données, veuillez patienter \n"
    ssh -p $port $host  "mysql -h $DATABASE_HOST -u $DATABASE_USER --password=$DATABASE_PASSWORD $MYSQL_DBNAME" < /data/restore/nextcloud-dbbackup.bak

    echo "Suppression du snapshot clone \n"
    zfs destroy data/restore

    echo "Déverrouillage du snapshot \n"
    zfs release keep host

    ssh -p $port $host "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
    echo "Le serveur NextCloud est de nouveau opérationnel \n"

    exit 0
}


if [[ $# != 1 ]] && [[ $# != 2 ]];
then
    how_to_use
elif [[ $# -eq 1 ]];
    then
    snapshot_name=`zfs list -H -t snapshot -o name -S creation | head -1`
    echo "Restauration du dernier snapshot $snapshot_name \n"
    restore_from_backup $snapshot_name
elif [[ $# -eq 2 ]];
    then
    echo "Restauration du snapshot $snapshot_name \n"
    restore_from_backup $snapshot_name
fi