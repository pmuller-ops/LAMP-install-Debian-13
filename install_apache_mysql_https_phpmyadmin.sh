#!/bin/bash

# ============================================================================
# Script d'installation complète LAMP + phpMyAdmin sur Debian 13
# ============================================================================
# Avec configuration VirtualHost, HTTPS via Let's Encrypt (Certbot)
# Et renouvellement automatique avec gestion temporaire de UFW
# 
# Auteur: Philippe Muller 
# Date: 09/01/2026
# Licence: Libre
# 
# À exécuter en root
# ============================================================================

set -e  # Arrêt en cas d'erreur

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fichier de log
LOG_FILE="/tmp/lamp_install_$(date +%Y%m%d_%H%M%S).log"

# Fonction pour afficher un titre de section
print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Fonction pour afficher une étape
print_step() {
    echo -e "${BLUE}▶${NC} ${BOLD}$1${NC}"
}

# Fonction pour afficher un succès
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Fonction pour afficher une erreur
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Fonction pour afficher un avertissement
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Fonction pour afficher une question
print_question() {
    echo -e "${CYAN}?${NC} ${BOLD}$1${NC}"
}

# Fonction pour exécuter une commande avec gestion des logs
execute_silent() {
    local description="$1"
    shift
    
    if "$@" >> "$LOG_FILE" 2>&1; then
        print_success "$description"
        return 0
    else
        print_error "$description"
        echo -e "${RED}Erreur détectée. Consultez le fichier de log: $LOG_FILE${NC}"
        tail -n 20 "$LOG_FILE"
        exit 1
    fi
}

# Fonction pour afficher une barre de progression
show_progress() {
    local current=$1
    local total=$2
    local description="$3"
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${BOLD}Progression:${NC} ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${BOLD}%3d%%${NC} - %s" "$percent" "$description"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# ============================================================================
# BANNIÈRE DE BIENVENUE
# ============================================================================

clear
echo -e "${BOLD}${CYAN}"
cat << "EOF"
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
EOF
echo -e "${NC}"
echo -e "${BOLD}Auteur:${NC} Philippe Muller"
echo -e "${BOLD}Version:${NC} 1.0"
echo -e "${BOLD}Licence:${NC} Libre"
echo ""
echo -e "${YELLOW}Ce script va installer et configurer un serveur LAMP complet.${NC}"
echo -e "${YELLOW}Fichier de log: ${LOG_FILE}${NC}"
echo ""
read -p "Appuyez sur Entrée pour continuer..."

# ============================================================================
# COLLECTE DES INFORMATIONS
# ============================================================================

print_section "📋 COLLECTE DES INFORMATIONS"

# Mot de passe root MariaDB
print_question "Entrez le mot de passe root pour MariaDB:"
read -s db_root_pass
echo ""

# Nom de domaine
print_question "Nom de domaine (ex: monsite.domaine.com):"
read domain

# Emplacement du site
print_question "Emplacement du site web [/var/www/$domain]:"
read site_dir
site_dir=${site_dir:-/var/www/$domain}

# Emplacement phpMyAdmin
print_question "Emplacement pour phpMyAdmin [/var/www/html/sql]:"
read phpmyadmin_dir
phpmyadmin_dir=${phpmyadmin_dir:-/var/www/html/sql}

# Email Let's Encrypt
print_question "Email pour Let's Encrypt (ex: admin@$domain):"
read certbot_email

echo ""
print_success "Informations collectées avec succès"

# ============================================================================
# INSTALLATION DES COMPOSANTS
# ============================================================================

TOTAL_STEPS=15
CURRENT_STEP=0

print_section "🚀 INSTALLATION DES COMPOSANTS"

# Étape 1: Mise à jour du système
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Mise à jour du système"
execute_silent "Mise à jour du système" apt update
execute_silent "Mise à niveau du système" apt upgrade -y

# Étape 2: Installation Apache
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation d'Apache"
execute_silent "Installation d'Apache" apt install apache2 apache2-utils -y
execute_silent "Activation des modules Apache" /usr/sbin/a2enmod rewrite ssl
execute_silent "Activation du service Apache" systemctl enable apache2
execute_silent "Démarrage d'Apache" systemctl start apache2

# Étape 3: Installation MariaDB
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation de MariaDB"
execute_silent "Installation de MariaDB" apt install mariadb-server -y
execute_silent "Activation du service MariaDB" systemctl enable mariadb
execute_silent "Démarrage de MariaDB" systemctl start mariadb

# Étape 4: Installation Expect
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation des outils"
execute_silent "Installation d'Expect" apt install expect -y

# Étape 5: Sécurisation MariaDB
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Sécurisation de MariaDB"
print_step "Configuration sécurisée de MariaDB..."

/usr/bin/expect >> "$LOG_FILE" 2>&1 <<EOF
spawn mariadb-secure-installation

expect "Enter current password for root (enter for none):"
send "\r"

expect "Switch to unix_socket authentication"
send "n\r"

expect "Change the root password?"
send "y\r"

expect "New password:"
send "$db_root_pass\r"

expect "Re-enter new password:"
send "$db_root_pass\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"

expect eof
EOF

if [ $? -eq 0 ]; then
    print_success "MariaDB sécurisée avec succès"
else
    print_error "Erreur lors de la sécurisation de MariaDB"
    exit 1
fi

# Étape 6: Installation PHP
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation de PHP"
execute_silent "Installation de PHP et modules" apt install php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-curl php-xml -y
execute_silent "Redémarrage d'Apache" systemctl restart apache2

# Étape 7: Installation Certbot
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation de Certbot"
execute_silent "Installation de Certbot" apt install certbot python3-certbot-apache -y

# Étape 8: Outils supplémentaires
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation des outils supplémentaires"
execute_silent "Installation de wget, tar, openssl" apt install wget tar openssl -y
execute_silent "Installation de Git" apt install git -y

# Étape 9: Création du répertoire du site
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuration du site web"
execute_silent "Création du répertoire du site" mkdir -p "$site_dir"
execute_silent "Configuration des permissions" chown -R www-data:www-data "$site_dir"
echo "<?php phpinfo(); ?>" > "$site_dir/index.php"
print_success "Page de test PHP créée"

# Étape 10: Installation phpMyAdmin
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation de phpMyAdmin"
print_step "Téléchargement de phpMyAdmin..."

cd /tmp
if wget https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.tar.gz >> "$LOG_FILE" 2>&1; then
    print_success "phpMyAdmin téléchargé"
else
    print_error "Erreur lors du téléchargement de phpMyAdmin"
    exit 1
fi

execute_silent "Extraction de phpMyAdmin" tar xzf phpMyAdmin-5.2.3-all-languages.tar.gz
execute_silent "Création du répertoire phpMyAdmin" mkdir -p "$phpmyadmin_dir"
execute_silent "Installation de phpMyAdmin" mv phpMyAdmin-5.2.3-all-languages/* "$phpmyadmin_dir/"
execute_silent "Nettoyage des fichiers temporaires" rm -rf phpMyAdmin-5.2.3-all-languages phpMyAdmin-5.2.3-all-languages.tar.gz
execute_silent "Configuration des permissions phpMyAdmin" chown -R www-data:www-data "$phpmyadmin_dir"

# Étape 11: Configuration phpMyAdmin
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuration de phpMyAdmin"
cd "$phpmyadmin_dir"
execute_silent "Copie du fichier de configuration" cp config.sample.inc.php config.inc.php
blowfish_secret=$(openssl rand -base64 32)
sed -i "s|^\$cfg\['blowfish_secret'\] = '';|\\\$cfg['blowfish_secret'] = '$blowfish_secret';|" config.inc.php
print_success "Configuration de phpMyAdmin terminée"

# Étape 12: Configuration VirtualHost HTTP temporaire
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuration du VirtualHost HTTP"

cat > /etc/apache2/sites-available/${domain}.conf <<EOF
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot $site_dir

    <Directory $site_dir>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

execute_silent "Activation du site" /usr/sbin/a2ensite ${domain}
execute_silent "Rechargement d'Apache" systemctl reload apache2

# Étape 13: Obtention du certificat SSL
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Obtention du certificat SSL"

# Vérifier si UFW est installé
UFW_INSTALLED=false
if command -v ufw &> /dev/null; then
    UFW_INSTALLED=true
    print_step "Désactivation temporaire du pare-feu UFW..."
    /usr/sbin/ufw disable >> "$LOG_FILE" 2>&1
fi

print_step "Demande du certificat Let's Encrypt..."
if certbot certonly --webroot -w "$site_dir" -d "$domain" --email "$certbot_email" --agree-tos --non-interactive >> "$LOG_FILE" 2>&1; then
    print_success "Certificat SSL obtenu avec succès"
else
    print_error "Erreur lors de l'obtention du certificat SSL"
    if [ "$UFW_INSTALLED" = true ]; then
        /usr/sbin/ufw enable >> "$LOG_FILE" 2>&1
    fi
    exit 1
fi

if [ "$UFW_INSTALLED" = true ]; then
    execute_silent "Réactivation du pare-feu UFW" /usr/sbin/ufw enable
fi

# Étape 14: Configuration VirtualHost HTTPS final
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuration du VirtualHost HTTPS"

execute_silent "Désactivation du VirtualHost temporaire" /usr/sbin/a2dissite ${domain}
rm /etc/apache2/sites-available/${domain}.conf

cat > /etc/apache2/sites-available/${domain}.conf <<EOF
<VirtualHost *:80>
    ServerName $domain
    Redirect permanent / https://$domain/
</VirtualHost>

<VirtualHost *:443>
    ServerName $domain
    DocumentRoot $site_dir

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$domain/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem

    <Directory $site_dir>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    Alias /sql $phpmyadmin_dir
    <Directory $phpmyadmin_dir>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

execute_silent "Activation du VirtualHost HTTPS" /usr/sbin/a2ensite ${domain}
execute_silent "Rechargement d'Apache" systemctl reload apache2

# Étape 15: Configuration du renouvellement automatique
CURRENT_STEP=$((CURRENT_STEP + 1))
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuration du renouvellement automatique"

execute_silent "Création du répertoire de scripts" mkdir -p /usr/local/lamp_install

cat > "/usr/local/lamp_install/certauto_$domain.sh" <<'EOF'
#!/bin/bash

# Vérifier si UFW est installé
if command -v ufw &> /dev/null; then
    /usr/sbin/ufw disable
fi

# renew certificat
certbot certonly --standalone -d $domaine --force-renewal

# Réactiver UFW si installé
if command -v ufw &> /dev/null; then
    /usr/sbin/ufw enable
fi

systemctl reload apache2
EOF

execute_silent "Configuration des permissions du script" chmod +x "/usr/local/lamp_install/certauto_$domain.sh"

# ============================================================================
# CONFIGURATION DU PARE-FEU UFW (OPTIONNEL)
# ============================================================================

print_section "🛡️  CONFIGURATION DU PARE-FEU UFW (OPTIONNEL)"

# Vérifier si UFW est installé
if ! command -v ufw &> /dev/null; then
    print_warning "UFW n'est pas installé sur ce système. Configuration du pare-feu ignorée."
else
    print_question "Voulez-vous configurer le pare-feu UFW ? (o/n) [n]:"
    read configure_ufw
    configure_ufw=${configure_ufw:-n}

    if [[ "$configure_ufw" =~ ^[oO]$ ]]; then
        print_step "Configuration du pare-feu UFW..."
        
        # Demander si l'utilisateur veut ajouter des IPs autorisées
        print_question "Voulez-vous autoriser des adresses IP spécifiques ? (o/n) [o]:"
        read add_ips
        add_ips=${add_ips:-o}
        
        if [[ "$add_ips" =~ ^[oO]$ ]]; then
            echo ""
            print_step "Ajout d'adresses IP autorisées"
            echo -e "${YELLOW}Entrez les adresses IP à autoriser (une par ligne).${NC}"
            echo -e "${YELLOW}Format: IP COMMENTAIRE (ex: 192.168.1.100 Mon serveur)${NC}"
            echo -e "${YELLOW}Appuyez sur Entrée avec une ligne vide pour terminer.${NC}"
            echo ""
            
            while true; do
                read -p "IP et commentaire (ou Entrée pour terminer): " ip_entry
                
                if [ -z "$ip_entry" ]; then
                    break
                fi
                
                # Extraire l'IP et le commentaire
                ip_addr=$(echo "$ip_entry" | awk '{print $1}')
                ip_comment=$(echo "$ip_entry" | cut -d' ' -f2-)
                
                if [ -z "$ip_comment" ]; then
                    ip_comment="Authorized IP"
                fi
                
                # Valider l'IP (basique)
                if [[ $ip_addr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    if /usr/sbin/ufw allow from "$ip_addr" comment "$ip_comment" >> "$LOG_FILE" 2>&1; then
                        print_success "IP $ip_addr autorisée ($ip_comment)"
                    else
                        print_error "Erreur lors de l'ajout de l'IP $ip_addr"
                    fi
                else
                    print_warning "Format d'IP invalide: $ip_addr"
                fi
            done
        fi
        
        # Configuration de la politique par défaut
        print_step "Configuration de la politique par défaut..."
        /usr/sbin/ufw default deny incoming >> "$LOG_FILE" 2>&1
        /usr/sbin/ufw default allow outgoing >> "$LOG_FILE" 2>&1
        print_success "Politique par défaut configurée (deny incoming, allow outgoing)"
        
        print_success "Pare-feu UFW configuré avec succès"
    else
        print_warning "Configuration du pare-feu UFW ignorée"
    fi
fi

# ============================================================================
# CONFIGURATION DES CLÉS SSH (OPTIONNEL)
# ============================================================================

print_section "🔑 CONFIGURATION DES CLÉS SSH (OPTIONNEL)"

print_question "Voulez-vous ajouter des clés SSH autorisées ? (o/n) [n]:"
read configure_ssh
configure_ssh=${configure_ssh:-n}

if [[ "$configure_ssh" =~ ^[oO]$ ]]; then
    print_step "Configuration des clés SSH..."
    
    # Créer le répertoire .ssh si nécessaire
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    
    echo ""
    print_step "Ajout de clés SSH publiques"
    echo -e "${YELLOW}Entrez les clés SSH publiques à autoriser (une par ligne).${NC}"
    echo -e "${YELLOW}Format: ssh-rsa AAAAB3... commentaire${NC}"
    echo -e "${YELLOW}Appuyez sur Entrée avec une ligne vide pour terminer.${NC}"
    echo ""
    
    ssh_key_count=0
    while true; do
        read -p "Clé SSH publique (ou Entrée pour terminer): " ssh_key
        
        if [ -z "$ssh_key" ]; then
            break
        fi
        
        # Valider que la clé commence par ssh-rsa, ssh-ed25519, etc.
        if [[ $ssh_key =~ ^(ssh-rsa|ssh-ed25519|ssh-dss|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ]]; then
            echo "$ssh_key" >> /root/.ssh/authorized_keys
            ssh_key_count=$((ssh_key_count + 1))
            print_success "Clé SSH #$ssh_key_count ajoutée"
        else
            print_warning "Format de clé SSH invalide (doit commencer par ssh-rsa, ssh-ed25519, etc.)"
        fi
    done
    
    if [ $ssh_key_count -gt 0 ]; then
        print_success "$ssh_key_count clé(s) SSH configurée(s) avec succès"
    else
        print_warning "Aucune clé SSH ajoutée"
    fi
else
    print_warning "Configuration des clés SSH ignorée"
fi

# ============================================================================
# CRÉATION UTILISATEUR MYSQL POUR PHPMYADMIN
# ============================================================================

print_section "👤 CRÉATION D'UN UTILISATEUR MYSQL POUR PHPMYADMIN"

# Nom d'utilisateur
print_question "Nom d'utilisateur MySQL (ex: pma_admin) [pma_admin]:"
read mysql_user
mysql_user=${mysql_user:-pma_admin}

# Mot de passe
print_question "Mot de passe pour cet utilisateur:"
read -s mysql_pass
echo ""

print_question "Confirmez le mot de passe:"
read -s mysql_pass_confirm
echo ""

# Vérification des mots de passe
if [ "$mysql_pass" != "$mysql_pass_confirm" ]; then
    print_error "Les mots de passe ne correspondent pas"
    exit 1
fi

if [ -z "$mysql_pass" ]; then
    print_error "Le mot de passe ne peut pas être vide"
    exit 1
fi

print_step "Création de l'utilisateur '$mysql_user'..."

mysql -u root >> "$LOG_FILE" 2>&1 <<EOF
-- Création de l'utilisateur (si il n'existe pas déjà)
CREATE USER IF NOT EXISTS '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_pass';

-- Attribution de tous les privilèges sur toutes les bases
GRANT ALL PRIVILEGES ON *.* TO '$mysql_user'@'localhost' WITH GRANT OPTION;

-- Application immédiate des changements
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    print_success "Utilisateur '$mysql_user' créé avec succès"
else
    print_error "Erreur lors de la création de l'utilisateur"
    exit 1
fi

# ============================================================================
# RÉSUMÉ DE L'INSTALLATION
# ============================================================================

print_section "✅ INSTALLATION TERMINÉE AVEC SUCCÈS"

echo ""
echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                    RÉSUMÉ DE L'INSTALLATION                           ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}🌐 Site web:${NC}"
echo -e "   URL: ${CYAN}https://$domain${NC}"
echo -e "   Répertoire: ${CYAN}$site_dir${NC}"
echo ""
echo -e "${BOLD}🗄️  phpMyAdmin:${NC}"
echo -e "   URL: ${CYAN}https://$domain/sql${NC}"
echo -e "   Utilisateur: ${CYAN}$mysql_user${NC}"
echo -e "   Répertoire: ${CYAN}$phpmyadmin_dir${NC}"
echo ""
echo -e "${BOLD}🔒 Certificat SSL:${NC}"
echo -e "   Émetteur: ${CYAN}Let's Encrypt${NC}"
echo -e "   Renouvellement: ${CYAN}Automatique${NC}"
echo ""
echo -e "${BOLD}📝 Fichier de log:${NC}"
echo -e "   ${CYAN}$LOG_FILE${NC}"
echo ""
echo -e "${BOLD}${GREEN}Votre serveur LAMP est maintenant opérationnel !${NC}"
echo ""
