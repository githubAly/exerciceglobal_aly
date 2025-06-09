#!/bin/bash
set -e

# Attendre que la base de données soit prête
echo "🔄 Attente de la base de données..."
while ! mysqladmin ping -h"$DB_SERVER" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "⏳ En attente de MySQL..."
    sleep 2
done
echo "✅ Base de données prête !"

# Vérifier et corriger les permissions
echo "🔧 Configuration des permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Vérifier si PrestaShop est déjà installé
if [ -f "/var/www/html/config/settings.inc.php" ]; then
    echo "✅ PrestaShop déjà installé"
    
    # SEULEMENT maintenant, supprimer le dossier install pour la sécurité
    if [ -d "/var/www/html/install" ]; then
        echo "🗑️ Suppression du dossier /install pour la sécurité..."
        rm -rf /var/www/html/install
    fi
else
    echo "🚀 PrestaShop pas encore installé - conservation du dossier /install"
    echo "👉 Rendez-vous sur http://localhost:8080 pour installer PrestaShop"
fi

# Lancer Apache
echo "🌐 Démarrage d'Apache..."
exec "$@"