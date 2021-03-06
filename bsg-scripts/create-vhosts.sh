#/!bin/bash
echo "create-sites-available"
sitesfolder="vhosts"

conffile="/bin/bsg.conf"

if [ -f "$conffile" ]
then
	source $conffile
else
	echo "$conffile not found."
	echo "You must create a $conffile file before install, please check README"
fi

echo "cleaning $LOCAL_DOCKER_FOLDER/$sitesfolder"
sudo rm -rf $LOCAL_DOCKER_FOLDER/$sitesfolder
mkdir $LOCAL_DOCKER_FOLDER/$sitesfolder
echo "Creating vhosts"

for i in "${domains[@]}"
do
	:	
	echo "<VirtualHost $LOCAL_IP:$LOCAL_PORT $PROD_IP:$PROD_PORT>
	ServerName $i
	ServerAdmin $SERVERADMINEMAIL
	DocumentRoot $LOCAL_SERVER_ROOT_PATH

	#ErrorLog /var/log/dockervhost/apache-$i.error.log
    #CustomLog /var/log/dockervhost/apache-$i.access.log common
    php_flag log_errors on
    php_flag display_errors on
    php_value error_reporting 2147483647
    php_value error_log /var/log/dockervhost/php-$i.error.log
</VirtualHost>
" > "$LOCAL_DOCKER_FOLDER/$sitesfolder/$i.conf"
	echo "$LOCAL_DOCKER_FOLDER/$sitesfolder/$i.conf"
done

echo "Creating SSL vhosts"

for i in "${domains[@]}"
do
	:	
	echo "<IfModule mod_ssl.c>
<VirtualHost $LOCAL_IP:443 $PROD_IP:443>
	ServerName $i
	ServerAdmin $SERVERADMINEMAIL
	#ServerAlias $i
	DocumentRoot $LOCAL_SERVER_ROOT_PATH

	#ErrorLog /var/log/dockervhost/apache-$i.error.log
    #CustomLog /var/log/dockervhost/apache-$i.access.log common
    php_flag log_errors on
    php_flag display_errors on
    php_value error_reporting 2147483647
    php_value error_log /var/log/dockervhost/php-$i.error.log
    
Include /etc/letsencrypt/options-ssl-apache.conf
SSLCertificateFile /etc/letsencrypt/live/cursowp.com.br/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/cursowp.com.br/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/cursowp.com.br/chain.pem
</VirtualHost>
</IfModule>
" > "$LOCAL_DOCKER_FOLDER/$sitesfolder/$i-le-ssl.conf"
	echo "$LOCAL_DOCKER_FOLDER/$sitesfolder/$i-le-ssl.conf"
done


