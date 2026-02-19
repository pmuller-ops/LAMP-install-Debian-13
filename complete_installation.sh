#!/bin/bash

# ============================================================================
# Script de complétion d'installation LAMP
# ============================================================================
# Ce script complète une installation interrompue à l'étape du certificat SSL
# ============================================================================

set -e  # Arrêt en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fichier de log
LOG_FILE="/tmp/lamp_complete_$(date +%Y%m%d_%H%M%S).log"

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

clear
echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║              COMPLÉTION DE L'INSTALLATION LAMP                        ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# ============================================================================
# COLLECTE DES INFORMATIONS
# ============================================================================

print_section "📋 COLLECTE DES INFORMATIONS"

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
# VÉRIFICATIONS PRÉALABLES
# ============================================================================

print_section "🔍 VÉRIFICATIONS PRÉALABLES"

# Vérifier si Apache est installé et actif
if systemctl is-active --quiet apache2; then
    print_success "Apache est actif"
else
    print_error "Apache n'est pas actif"
    exit 1
fi

# Vérifier si le répertoire du site existe
if [ -d "$site_dir" ]; then
    print_success "Répertoire du site existe: $site_dir"
else
    print_error "Répertoire du site n'existe pas: $site_dir"
    exit 1
fi

# Vérifier si le VirtualHost HTTP existe
if [ -f "/etc/apache2/sites-available/${domain}.conf" ]; then
    print_success "VirtualHost existe"
else
    print_warning "VirtualHost n'existe pas, il sera créé"
    
    # Créer le VirtualHost HTTP temporaire
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
fi

# ============================================================================
# OBTENTION DU CERTIFICAT SSL
# ============================================================================

print_section "🔒 OBTENTION DU CERTIFICAT SSL"

print_step "Demande du certificat Let's Encrypt..."
if certbot certonly --webroot -w "$site_dir" -d "$domain" --email "$certbot_email" --agree-tos --non-interactive >> "$LOG_FILE" 2>&1; then
    print_success "Certificat SSL obtenu avec succès"
else
    print_error "Erreur lors de l'obtention du certificat SSL"
    echo ""
    echo -e "${YELLOW}Vérifiez que :${NC}"
    echo -e "  1. Le domaine $domain pointe bien vers cette machine"
    echo -e "  2. Les ports 80 et 443 sont ouverts"
    echo -e "  3. Apache est bien démarré"
    echo ""
    exit 1
fi

# ============================================================================
# CONFIGURATION VIRTUALHOST HTTPS
# ============================================================================

print_section "🌐 CONFIGURATION DU VIRTUALHOST HTTPS"

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

# ============================================================================
# CONFIGURATION DU RENOUVELLEMENT AUTOMATIQUE
# ============================================================================

print_section "🔄 CONFIGURATION DU RENOUVELLEMENT AUTOMATIQUE"

execute_silent "Création du répertoire de scripts" mkdir -p /usr/local/lamp_install

cat > "/usr/local/lamp_install/certauto_$domain.sh" <<'EOFSCRIPT'
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
EOFSCRIPT

execute_silent "Configuration des permissions du script" chmod +x "/usr/local/lamp_install/certauto_$domain.sh"

# ============================================================================
# CRÉATION UTILISATEUR MYSQL POUR PHPMYADMIN (OPTIONNEL)
# ============================================================================

print_section "👤 CRÉATION D'UN UTILISATEUR MYSQL POUR PHPMYADMIN (OPTIONNEL)"

print_question "Voulez-vous créer un utilisateur MySQL pour phpMyAdmin ? (o/n) [o]:"
read create_user
create_user=${create_user:-o}

if [[ "$create_user" =~ ^[oO]$ ]]; then
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

    mysql -u root >> "$LOG_FILE" 2>&1 <<EOFSQL
-- Création de l'utilisateur (si il n'existe pas déjà)
CREATE USER IF NOT EXISTS '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_pass';

-- Attribution de tous les privilèges sur toutes les bases
GRANT ALL PRIVILEGES ON *.* TO '$mysql_user'@'localhost' WITH GRANT OPTION;

-- Application immédiate des changements
FLUSH PRIVILEGES;
EOFSQL

    if [ $? -eq 0 ]; then
        print_success "Utilisateur '$mysql_user' créé avec succès"
    else
        print_error "Erreur lors de la création de l'utilisateur"
        exit 1
    fi
else
    print_warning "Création d'utilisateur MySQL ignorée"
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
if [[ "$create_user" =~ ^[oO]$ ]]; then
    echo -e "   Utilisateur: ${CYAN}$mysql_user${NC}"
fi
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
