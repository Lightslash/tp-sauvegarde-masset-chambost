# TP de sauvegarde

Pol CHAMBOST

## Rendu

Deux scripts .sh à déposer sur la VM de backup

## How to

Cloner le git sur la machine de backup ou y déposer les fichiers.

Générer une paire de clé ssh depuis le serveur backup et l'envoyer sur le serveur NextCloud

```bash
ssh-keygen

ssh-copy-id user@adress_nextcloud
``` 

Donner les droits aux scripts

```bash
chmod +x restore_from_backup.sh save_from_backup.sh
``` 

Utilisation de save_from_backup.sh:

```bash
./save_from_backup.sh port user@hostname
``` 

Utilisation de restore_from_backup.sh:

```bash
./save_from_backup.sh port user@hostname snapshot_name
``` 

user@hostname -> Adresse machine NextCloud
port -> Port SSH de la machine NextCloud
snapshot -> Nom d'un des snapshots, optionnel