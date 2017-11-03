
#/bin/bash
echo "--- Instalando pacotes para desenvolvimento [PHP]"

echo "-- definindo senha MySQL e Nome do projeto e senha lapd---"
PASSWORD_MYSQL="123" #senha MySQL
PASSWORD_SLAPD=123 # senha lapd
PROJECTFOLDER='project' # nome do projeto

echo "--- criar pasta do projeto ---"
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

echo "--- criando arquivo index.php ---"
echo "<?php phpinfo(); ?>" > /var/www/html/${PROJECTFOLDER}/index.php

echo "--- Atualizando lista de pacotes ---"
sudo apt-get update
sudo apt-get -y upgrade

echo "--- instalar apache2 ---"
sudo apt-get -y install apache2 

echo "--- Instalando PHP ---"
sudo apt-get -y install php5 libapache2-mod-php5 php5-mcrypt

echo "--- instalar mysql e fornercer senha para o instalador -- "
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD_MYSQL"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD_MYSQL"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

echo "--- instalar mysql e fornecer senha para o instalador"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD_MYSQL"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD_MYSQL"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD_MYSQL"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

echo "--- Configurando apache2 default ---"
VHOST=$(cat <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/${PROJECTFOLDER}
        <Directory />
                Options FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/html/${PROJECTFOLDER}/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride All
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined

    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/default

echo "--- Instalando Git"
sudo apt-get -y install git 
git config --global user.name "seu_nome"  
git config --global user.email seu_nome@seu_email.com.br

echo "--- Instalando mssql no PHP"
sudo apt-get -y install php5-mssql 

echo "--- Definir senha lapd ---"
sudo debconf-set-selections <<EOF
	slapd slapd/password1 password $PASSWORD_SLAPD
	slapd slapd/password2 password $PASSWORD_SLAPD
EOF

echo "---instalando slapd ---"
sudo apt-get -y install slapd ldap-utils 

echo "--- Instalando phpldapadmin ---"
sudo apt-get -y install phpldapadmin 

echo "--- Habilitando mod-rewrite do Apache ---"
sudo a2enmod rewrite

echo "-- instalar composer ---"
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "--- Reiniciando Apache ---"
sudo service apache2 restart

echo "[OK] --- Hora de programar, bom trabalho! ---"
