# 🚀 Script d'Installation LAMP + phpMyAdmin avec HTTPS

Script d'installation automatisée d'un serveur LAMP complet (Linux, Apache, MariaDB, PHP) avec phpMyAdmin et certificat SSL Let's Encrypt sur Debian 13.

## 📋 Table des matières

- [Présentation](#-présentation)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Configuration](#-configuration)
- [Sécurité](#-sécurité)
- [Dépannage](#-dépannage)
- [Licence](#-licence)
- [Auteur](#-auteur)

## 🎯 Présentation

Ce script automatise l'installation et la configuration complète d'un serveur web LAMP avec les composants suivants :

- **Apache 2** - Serveur web avec modules SSL et Rewrite
- **MariaDB** - Système de gestion de base de données
- **PHP** - Langage de script côté serveur avec modules essentiels
- **phpMyAdmin** - Interface web de gestion MySQL/MariaDB
- **Let's Encrypt** - Certificat SSL gratuit avec renouvellement automatique
- **UFW** - Configuration du pare-feu

Le script offre une interface utilisateur améliorée avec :
- ✨ Bannière ASCII artistique
- 📊 Barres de progression en temps réel
- 🎨 Affichage coloré et structuré
- ✅ Indicateurs visuels de succès/erreur
- 📝 Logs détaillés (affichés uniquement en cas d'erreur)
- 🔧 Configuration interactive et personnalisable

## ✨ Fonctionnalités

### Installation automatisée
- ✅ Mise à jour complète du système
- ✅ Installation et configuration d'Apache avec SSL
- ✅ Installation et sécurisation de MariaDB
- ✅ Installation de PHP avec tous les modules nécessaires
- ✅ Installation de phpMyAdmin (dernière version stable)
- ✅ Configuration de VirtualHost avec redirection HTTP → HTTPS
- ✅ Obtention automatique du certificat SSL Let's Encrypt
- ✅ Configuration du renouvellement automatique du certificat
- ✅ Configuration optionnelle et interactive du pare-feu UFW
- ✅ Installation de Git
- ✅ Configuration optionnelle et interactive des clés SSH

### Interface utilisateur améliorée
- 🎨 Affichage coloré avec codes couleur sémantiques
- 📊 Barre de progression pour suivre l'avancement
- 📋 Sections clairement délimitées
- ✓ Indicateurs visuels de succès (✓), erreur (✗), avertissement (⚠)
- 📝 Logs masqués par défaut, affichés uniquement en cas d'erreur
- 📄 Résumé complet à la fin de l'installation
- 🔧 Questions interactives avec valeurs par défaut
- 🛡️ Configuration optionnelle du pare-feu et des clés SSH

### Sécurité
- 🔒 Sécurisation automatique de MariaDB
- 🔐 Configuration du blowfish secret pour phpMyAdmin
- 🛡️ Configuration du pare-feu UFW
- 🔑 Gestion des clés SSH
- 🚫 Désactivation des utilisateurs anonymes MySQL
- 🌐 Redirection automatique HTTP vers HTTPS

## 📦 Prérequis

### Système d'exploitation
- **Debian 13** (Trixie) ou version compatible
- Accès **root** au système

### Réseau
- Nom de domaine configuré pointant vers votre serveur
- Ports **80** (HTTP) et **443** (HTTPS) accessibles depuis Internet
- Connexion Internet stable

### Ressources minimales recommandées
- **RAM** : 1 Go minimum (2 Go recommandé)
- **Disque** : 10 Go d'espace libre minimum
- **CPU** : 1 cœur minimum

## 🔧 Installation

### 1. Télécharger le script

```bash
# Télécharger le script
wget https://votre-repo.com/install_apache_mysql_https_phpmyadmin.sh

# Ou cloner le dépôt
git clone https://votre-repo.com/lamp-installer.git
cd lamp-installer
```

### 2. Rendre le script exécutable

```bash
chmod +x install_apache_mysql_https_phpmyadmin.sh
```

### 3. Exécuter le script en tant que root

```bash
sudo ./install_apache_mysql_https_phpmyadmin.sh
```

## 🎮 Utilisation

### Lancement du script

Le script vous guidera à travers plusieurs étapes interactives :

#### 1. Bannière de bienvenue
```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║   ██╗      █████╗ ███╗   ███╗██████╗     ██╗███╗   ██╗███████╗████████╗ ║
║   ██║     ██╔══██╗████╗ ████║██╔══██╗    ██║████╗  ██║██╔════╝╚══██╔══╝ ║
║   ██║     ███████║██╔████╔██║██████╔╝    ██║██╔██╗ ██║███████╗   ██║    ║
║   ██║     ██╔══██║██║╚██╔╝██║██╔═══╝     ██║██║╚██╗██║╚════██║   ██║    ║
║   ███████╗██║  ██║██║ ╚═╝ ██║██║         ██║██║ ╚████║███████║   ██║    ║
║   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝    ║
║                                                                       ║
║              Installation Apache + MariaDB + PHP + phpMyAdmin        ║
║                     avec HTTPS (Let's Encrypt)                       ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

#### 2. Collecte des informations

Le script vous demandera les informations suivantes :

```bash
? Entrez le mot de passe root pour MariaDB:
? Nom de domaine (ex: monsite.domaine.com):
? Emplacement du site web [/var/www/monsite.domaine.com]:
? Emplacement pour phpMyAdmin [/var/www/html/sql]:
? Email pour Let's Encrypt (ex: admin@monsite.domaine.com):
```

#### 3. Installation avec barre de progression

```
Progression: [████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░] 50% - Installation de PHP
```

#### 4. Configuration du pare-feu UFW (optionnel)

```bash
? Voulez-vous configurer le pare-feu UFW ? (o/n) [n]:
? Voulez-vous autoriser des adresses IP spécifiques ? (o/n) [o]:

Entrez les adresses IP à autoriser (une par ligne).
Format: IP COMMENTAIRE (ex: 192.168.1.100 Mon serveur)
Appuyez sur Entrée avec une ligne vide pour terminer.

IP et commentaire (ou Entrée pour terminer): 192.168.1.100 Serveur principal
✓ IP 192.168.1.100 autorisée (Serveur principal)
IP et commentaire (ou Entrée pour terminer): 10.0.0.50 VPN
✓ IP 10.0.0.50 autorisée (VPN)
IP et commentaire (ou Entrée pour terminer):
```

#### 5. Configuration des clés SSH (optionnel)

```bash
? Voulez-vous ajouter des clés SSH autorisées ? (o/n) [n]:

Entrez les clés SSH publiques à autoriser (une par ligne).
Format: ssh-rsa AAAAB3... commentaire
Appuyez sur Entrée avec une ligne vide pour terminer.

Clé SSH publique (ou Entrée pour terminer): ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB... user@host
✓ Clé SSH #1 ajoutée
Clé SSH publique (ou Entrée pour terminer):
```

#### 6. Création de l'utilisateur MySQL

```bash
? Nom d'utilisateur MySQL (ex: pma_admin) [pma_admin]:
? Mot de passe pour cet utilisateur:
? Confirmez le mot de passe:
```

#### 7. Résumé final

```
╔═══════════════════════════════════════════════════════════════════════╗
║                    RÉSUMÉ DE L'INSTALLATION                           ║
╚═══════════════════════════════════════════════════════════════════════╝

🌐 Site web:
   URL: https://monsite.domaine.com
   Répertoire: /var/www/monsite.domaine.com

🗄️  phpMyAdmin:
   URL: https://monsite.domaine.com/sql
   Utilisateur: pma_admin
   Répertoire: /var/www/html/sql

🔒 Certificat SSL:
   Émetteur: Let's Encrypt
   Renouvellement: Automatique

📝 Fichier de log:
   /tmp/lamp_install_20260218_195730.log
```

## ⚙️ Configuration

### Structure des fichiers installés

```
/var/www/
├── monsite.domaine.com/          # Répertoire du site web
│   └── index.php                 # Page de test PHP
└── html/
    └── sql/                      # phpMyAdmin
        └── config.inc.php        # Configuration phpMyAdmin

/etc/apache2/
└── sites-available/
    └── monsite.domaine.com.conf  # Configuration VirtualHost

/etc/letsencrypt/
└── live/
    └── monsite.domaine.com/      # Certificats SSL
        ├── fullchain.pem
        └── privkey.pem

/usr/local/lamp_install/
└── certauto_monsite.domaine.com.sh  # Script de renouvellement SSL
```

### Configuration Apache

Le VirtualHost est configuré avec :
- Redirection automatique HTTP (port 80) → HTTPS (port 443)
- SSL activé avec certificat Let's Encrypt
- Alias `/sql` pour phpMyAdmin
- Options de sécurité (désactivation de l'indexation des répertoires)

### Configuration MariaDB

- Utilisateur root sécurisé avec mot de passe
- Utilisateurs anonymes supprimés
- Connexion root distante désactivée
- Base de données de test supprimée
- Utilisateur dédié pour phpMyAdmin avec tous les privilèges

### Configuration PHP

Modules installés :
- `php` - Interpréteur PHP
- `libapache2-mod-php` - Module Apache pour PHP
- `php-mysql` - Support MySQL/MariaDB
- `php-mbstring` - Support multi-octets
- `php-zip` - Support des archives ZIP
- `php-gd` - Bibliothèque graphique
- `php-curl` - Support cURL
- `php-xml` - Support XML

### Configuration UFW (Pare-feu)

La configuration du pare-feu UFW est **optionnelle** et interactive :
- L'utilisateur choisit s'il souhaite configurer UFW
- Possibilité d'ajouter des IPs autorisées avec commentaires personnalisés
- Format : `IP COMMENTAIRE` (ex: `192.168.1.100 Mon serveur`)
- Validation basique du format IP
- Politique par défaut : refus des connexions entrantes, autorisation des sortantes
- Gestion temporaire lors du renouvellement SSL

### Configuration des clés SSH

La configuration des clés SSH est **optionnelle** et interactive :
- L'utilisateur choisit s'il souhaite ajouter des clés SSH
- Possibilité d'ajouter plusieurs clés SSH publiques
- Formats supportés : `ssh-rsa`, `ssh-ed25519`, `ssh-dss`, `ecdsa-sha2-*`
- Validation du format de clé
- Création automatique du répertoire `.ssh` avec permissions appropriées
- Les clés sont ajoutées à `/root/.ssh/authorized_keys`

## 🔒 Sécurité

### Bonnes pratiques implémentées

1. **Mots de passe forts** : Le script demande des mots de passe sécurisés
2. **HTTPS obligatoire** : Redirection automatique HTTP → HTTPS
3. **Certificat SSL** : Let's Encrypt avec renouvellement automatique
4. **Pare-feu** : Configuration UFW optionnelle et personnalisable
5. **MariaDB sécurisée** : Suppression des comptes par défaut
6. **phpMyAdmin** : Blowfish secret généré aléatoirement
7. **Permissions** : Fichiers appartenant à www-data
8. **Indexation désactivée** : Protection contre la liste des fichiers

### Recommandations supplémentaires

- 🔐 Changez régulièrement les mots de passe
- 🔄 Maintenez le système à jour : `apt update && apt upgrade`
- 🛡️ Configurez fail2ban pour protéger contre les attaques par force brute
- 📊 Surveillez les logs : `/var/log/apache2/` et `/var/log/mysql/`
- 🔒 Limitez l'accès à phpMyAdmin par IP via UFW si configuré
- 🚫 Désactivez phpMyAdmin si non utilisé
- 🔑 Utilisez des clés SSH plutôt que des mots de passe pour l'authentification

## 🐛 Dépannage

### Consulter les logs

Le script génère un fichier de log détaillé :

```bash
# Afficher le dernier log
ls -lt /tmp/lamp_install_*.log | head -1

# Consulter le contenu
cat /tmp/lamp_install_YYYYMMDD_HHMMSS.log
```

### Problèmes courants

#### Le certificat SSL ne peut pas être obtenu

**Symptôme** : Erreur lors de l'obtention du certificat Let's Encrypt

**Solutions** :
1. Vérifiez que votre domaine pointe bien vers votre serveur
2. Vérifiez que les ports 80 et 443 sont ouverts
3. Vérifiez les logs Certbot : `/var/log/letsencrypt/letsencrypt.log`

```bash
# Tester manuellement
certbot certonly --webroot -w /var/www/votre-domaine.com -d votre-domaine.com --dry-run
```

#### Apache ne démarre pas

**Symptôme** : Erreur lors du démarrage d'Apache

**Solutions** :
1. Vérifiez la configuration Apache
```bash
apache2ctl configtest
```

2. Consultez les logs Apache
```bash
tail -f /var/log/apache2/error.log
```

3. Vérifiez que le port 80 n'est pas déjà utilisé
```bash
netstat -tulpn | grep :80
```

#### Impossible de se connecter à phpMyAdmin

**Symptôme** : Erreur de connexion à phpMyAdmin

**Solutions** :
1. Vérifiez que MariaDB est démarré
```bash
systemctl status mariadb
```

2. Testez la connexion MySQL
```bash
mysql -u pma_admin -p
```

3. Vérifiez les permissions du répertoire phpMyAdmin
```bash
ls -la /var/www/html/sql/
```

#### Erreur de permissions

**Symptôme** : Erreur 403 Forbidden

**Solutions** :
```bash
# Corriger les permissions
chown -R www-data:www-data /var/www/votre-domaine.com
chmod -R 755 /var/www/votre-domaine.com
```

### Commandes utiles

```bash
# Vérifier le statut des services
systemctl status apache2
systemctl status mariadb

# Redémarrer les services
systemctl restart apache2
systemctl restart mariadb

# Vérifier la configuration Apache
apache2ctl configtest

# Lister les sites activés
ls -la /etc/apache2/sites-enabled/

# Vérifier les certificats SSL
certbot certificates

# Tester le renouvellement SSL
certbot renew --dry-run

# Vérifier les règles UFW
ufw status verbose
```

## 📄 Licence

Ce projet est sous **licence libre**.

Vous êtes libre de :
- ✅ Utiliser ce script à des fins personnelles ou commerciales
- ✅ Modifier le script selon vos besoins
- ✅ Distribuer le script original ou modifié
- ✅ Contribuer au projet

**Aucune garantie** : Ce script est fourni "tel quel", sans garantie d'aucune sorte.

## 👤 Auteur

**Philippe Muller**

- 📅 Date de création : 09/01/2026

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. 🍴 Fork le projet
2. 🔧 Créer une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. 📤 Push vers la branche (`git push origin feature/AmazingFeature`)
5. 🔀 Ouvrir une Pull Request

## 📝 Changelog

### Version 1.0 (09/01/2026)
- ✨ Version initiale
- 🎨 Interface utilisateur améliorée avec barres de progression
- 📊 Affichage coloré et structuré
- 📝 Logs masqués par défaut (affichés uniquement en cas d'erreur)
- ✅ Installation complète LAMP + phpMyAdmin + HTTPS
- 🔒 Configuration sécurisée par défaut
- 🔄 Renouvellement automatique SSL

## 🙏 Remerciements

- [Apache Software Foundation](https://www.apache.org/)
- [MariaDB Foundation](https://mariadb.org/)
- [PHP Group](https://www.php.net/)
- [phpMyAdmin Team](https://www.phpmyadmin.net/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Debian Project](https://www.debian.org/)

## 📞 Support

Pour toute question ou problème :

1. 📖 Consultez d'abord la section [Dépannage](#-dépannage)
2. 📝 Vérifiez les logs d'installation

---

<div align="center">

**Fait avec ❤️ par Philippe Muller**

⭐ Si ce script vous a été utile, n'hésitez pas à le partager !

</div>
