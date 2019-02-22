#!/bin/bash

DATABASE_HOST='localhost'
DATABASE_USER='root'
DATABASE_PASSWORD='root'
DATABASE_DBNAME='nextcloud'

port=$0
host=$1

how_to_use() {

    echo "how to use: port user@hostname \n"
    exit 1
}

save_from_backup() {
    echo "Mise en maintenance du serveur NextCloud \n"
    ssh -p $port $host "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on"

    echo "Sauvegarde des fichiers du serveur NextCloud \n"
    rsync -Aavx -e "ssh -p $port" $host:/var/www/html/nextcloud/ /data/backup/nextcloud-dirbackup/

    echo "Dump de la base de données NextCloud \n"
    ssh -p $port $host "mysqldump --single-transaction -h $DATABASE_HOST -u $DATABASE_USER --password=$DATABASE_PASSWORD $DATABASE_DBNAME" > /data/backup/nextcloud-dbbackup.bak

    echo "Archivage du dossier backup \n"
    zfs snapshot data/backup@nextcloud_`date +"%Y%m%d%H%M"`

    # Retention du nombre de snapshot (limité à 30 jours)
    limit="data/backup@nextcloud_`date --date='-30 day' +"%Y%m%d%H%M"`"
    for snap in `zfs list -H -t snapshot -o name` ; do
        if [[ $snap < $limit ]]; then
            zfs destroy $snap
        fi
    done

    ssh -p $port $host "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
    echo "Le serveur NextCloud est de nouveau opérationnel \n"

    exit 0
}


if [[ $# != 2 ]]; then
    how_to_use
elif [[ $# -eq 2 ]]; then
    save_from_backup
fi