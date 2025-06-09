# 🧰 Stack PrestaShop avec Monitoring et Backup Automatisé

Ce projet Docker Compose fournit une stack complète pour exécuter une boutique PrestaShop avec :

- Base de données **MySQL 5.7**
- Interface d'administration **PHPMyAdmin**
- Reverse proxy **NGINX** avec SSL
- Monitoring complet avec **Prometheus**, **Grafana**, **cAdvisor**, **Node Exporter** et **MySQL Exporter**
- **Backup automatique** de la base de données MySQL toutes les 6h avec rotation
- **AlertManager** pour la gestion d'alertes Prometheus

---

## 📐 Architecture des services

```
                    ┌─────────────┐
                    │   Grafana   │◄────┐
                    │   :3000     │     │
                    └─────────────┘     │
                           ▲            │
┌─────────────┐    ┌─────────────┐     │
│  cAdvisor   │───►│ Prometheus  │◄────┤
│   :8083     │    │   :9091     │     │
└─────────────┘    └─────────────┘     │
┌─────────────┐    ┌─────────────┐     │
│Node Exporter│───►│AlertManager │     │
│   :9100     │    │   :9093     │     │
└─────────────┘    └─────────────┘     │
┌─────────────┐                        │
│MySQL Export │────────────────────────┘
│   :9104     │
└─────────────┘
                                        
┌─────────────┐    ┌─────────────┐   ┌─────────────┐
│ PrestaShop  │◄──►│   MySQL     │◄─►│ PhpMyAdmin  │
│   :8080     │    │   :3306     │   │     :80     │
└─────────────┘    └─────────────┘   └─────────────┘
       │                   ▲
       ▼                   │
┌─────────────┐    ┌─────────────┐
│    NGINX    │    │   Backup    │
│  :80/:443   │    │ (every 6h)  │
└─────────────┘    └─────────────┘
```

---

## 🚀 Mise en place

### 1. Prérequis

- Docker
- Docker Compose

### 2. Structure des dossiers recommandée

```
.
├── docker-compose.yml
├── Dockerfile
├── restore.sh
├── github/
│   ├── workflows/
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── rules/
│   ├── grafana/
│   │   ├── provisioning/
│   │   └── dashboards/
│   ├── mysql/
│   │   └── .my.cnf
│   └── alertmanager/
│       └── alertmanager.yml
└── nginx/
    ├── nginx.conf
    └── ssl/
```

### 3. Lancement

```bash
docker-compose build backup
docker-compose up -d
```

---

## 🧭 Accès aux services

| Service         | URL                     | Identifiants par défaut       |
|----------------|--------------------------|-------------------------------|
| PrestaShop     | http://localhost:8080    | À configurer à la première visite |
| PhpMyAdmin     | http://localhost:8082    | root / root                   |
| Grafana        | http://localhost:3000    | admin / grafana123            |
| Prometheus     | http://localhost:9091    | -                             |
| AlertManager   | http://localhost:9093    | -                             |
| cAdvisor       | http://localhost:8083    | -                             |
| Node Exporter  | http://localhost:9100    | -                             |
| MySQL Exporter | http://localhost:9104    | -                             |

---

## 💾 Backup MySQL automatique

Le conteneur `prestashop_backup` effectue un `mysqldump` compressé toutes les 6 heures avec :
- Stockage dans un volume Docker `backup_data`
- Rotation automatique : conserve les **20 derniers backups**
- Compression gzip pour économiser l'espace

### 📍 Emplacement des sauvegardes

- Volume : `backup_data`
- Emplacement dans le conteneur : `/backups/`

```bash
docker-compose exec backup ls -la /backups/
docker-compose exec backup du -sh /backups/
```

### ▶️ Lancer un backup manuel

```bash
docker-compose exec backup /backup.sh
docker-compose logs -f backup
```

### 🛠 Restauration manuelle

```bash
# Lister les backups
docker-compose exec backup ls -la /backups/

# Copier un backup vers votre machine
docker cp prestashop_backup:/backups/nom_du_fichier.sql.gz ./

# Restaurer depuis le conteneur
docker-compose exec backup sh -c "gunzip -c /backups/fichier.sql.gz | mysql -hdb -uprestashop -ppsswrd prestashop"

# Depuis un fichier local
gunzip fichier.sql.gz
docker-compose exec -T db mysql -uprestashop -ppsswrd prestashop < fichier.sql
```

⚠️ Attention : la restauration écrasera les données existantes.

---

## 📊 Monitoring

### Métriques collectées

- **Node Exporter** : CPU, RAM, disque, réseau du serveur hôte
- **MySQL Exporter** : Statistiques MySQL
- **cAdvisor** : Utilisation des conteneurs Docker
- **Prometheus** : Agrégation et stockage

### Dashboards Grafana

- Provision automatique depuis `./monitoring/grafana/dashboards/`

### 🔔 Alertes via AlertManager

- Backup trop ancien (> 7 heures)
- Espace disque faible
- Conteneur MySQL down
- Utilisation CPU/RAM élevée

---

## 📎 Volumes Docker utilisés

- `prestashop_data` → /var/www/html
- `mysql_data` → /var/lib/mysql
- `grafana_data` → /var/lib/grafana
- `prometheus_data` → /prometheus
- `alertmanager_data` → /alertmanager

---

## 🔧 Maintenance

```bash
# Voir l'utilisation disque
docker system df -v

# Nettoyer les anciens backups manuellement
docker-compose exec backup find /backups -name "*.sql.gz" -mtime +30 -delete

# Redémarrer tous les services
docker-compose restart

# Mise à jour
docker-compose build --no-cache
docker-compose up -d
```

---

## 🐛 Dépannage

```bash
# Logs du service de backup
docker-compose logs backup

# Tester la connexion MySQL
docker-compose exec backup mysql -hdb -uprestashop -ppsswrd -e "SHOW DATABASES;"

# Targets Prometheus
http://localhost:9091/targets

# Redémarrer Grafana
docker-compose restart grafana
```