#!/bin/bash
# Ce script installe openssh-server et configure le dossier .ssh et le fichier authorized_keys dans /home/ubuntu
# Il est destiné à être exécuté sur Ubuntu et doit être lancé avec des privilèges root (via sudo par exemple).

set -e  # Arrête le script en cas d'erreur

# Vérifier si le script est exécuté en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "Erreur : veuillez exécuter ce script en tant que root (par exemple via sudo)." >&2
  exit 1
fi

# Mise à jour des dépôts et installation d'openssh-server
echo "Mise à jour des dépôts et installation d'openssh-server..."
apt-get update
apt-get install -y openssh-server

# Définir la variable contenant votre clé publique SSH
# Remplacez "votre_clé_publique_ici" par la clé publique que vous souhaitez ajouter.
PUBLIC_SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwtR2lzhl4a/aS5Akik508a7DPOlOlqiT+qVx9QFvzFGqYbZb5zJY+Dm8SRCMNY3P3YmXLisMBv+rhPYfcQiCzEOtJqN5nSRLtZyj/Ab0Qir7HBIrMX5jdHaPRBoykhlEU6Sicz3EXqNjCZp2Eph3SIe0pGmro8yu3MWcs7b8A6IBBbSBlDl3y44xlBcbh+e6GB2cdHrXs/i95OkX9Sbmma0mtgq1FPYAw7RrKsiO76eXqkeb6iCFBbEuonAkF0S/oXpa0IcStPTYTysO6swZFC0SLyzxFDVIcJ8VDxOg/4NDPNr02rlUSeXu/6/YMsZYE2ZmtjWpT+XgyqRKYlqu0I0na9VIac4G0JD4CEOmdHwLFp6YmDXvadnLddb7ArKsjdkqgWpowdw95PJnilYgHiZJ+edypiCn5+UEHGlLWfvTXNdS3ck2qgtlXkwacaUmjBY/CUC5NkYOaj+2h0i75Y888g52usZdeM8CvyfD6+CjGSstY3b7PVLaZhgjRSMM= wglint@MacPro-WGlint"

# Définir le chemin du répertoire .ssh pour l'utilisateur ubuntu
SSH_DIR="/home/ubuntu/.ssh"

# Création du répertoire .ssh s'il n'existe pas
if [ ! -d "$SSH_DIR" ]; then
  mkdir -p "$SSH_DIR"
  echo "Création du répertoire $SSH_DIR..."
fi

# Attribution des permissions et du propriétaire sur le répertoire .ssh
chmod 700 "$SSH_DIR"
chown ubuntu:ubuntu "$SSH_DIR"

# Définition du chemin du fichier authorized_keys
AUTH_KEYS="$SSH_DIR/authorized_keys"

# Création du fichier authorized_keys s'il n'existe pas
if [ ! -f "$AUTH_KEYS" ]; then
  touch "$AUTH_KEYS"
  echo "Création du fichier $AUTH_KEYS..."
fi

# Attribution des permissions et du propriétaire sur le fichier authorized_keys
chmod 600 "$AUTH_KEYS"
chown ubuntu:ubuntu "$AUTH_KEYS"

# Ajout de la clé publique dans le fichier authorized_keys si elle n'est pas déjà présente
if ! grep -qF "$PUBLIC_SSH_KEY" "$AUTH_KEYS"; then
  echo "$PUBLIC_SSH_KEY" >> "$AUTH_KEYS"
  echo "La clé publique a été ajoutée à $AUTH_KEYS."
else
  echo "La clé publique est déjà présente dans $AUTH_KEYS."
fi

echo "Configuration SSH terminée avec succès."


service ssh start

