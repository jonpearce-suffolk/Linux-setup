
AddAdminUser()
{
	adduser $admin_user
	usermod -a -G sudo $admin_user
	echo -e "$admin_pass\n$admin_pass" | passwd $admin_user

}

NewHost()
{
	read -p "Enter new hostname or empty for keeping existing name :" new_host_name
	if [ "$new_host_name" != "" ]
	then
		hostnamectl set-hostname host.example.com
	fi
}

UUpdate()
{
	apt-get update
	echo Has the update worked?
	read -p "Press enter to continue"
}

UUpgrade()
{
	apt-get upgrade
	echo Has the upgrade worked?
}

InstallApache()
{
	apt-get install apache2
}

AddAdminWWW()
{
	usermod -a -G www-data $admin_user
}

AddFireWallRules()
{
	ufw app list

	ufw allow in "Apache" "ssh"
	ufw app list
}

InstallMySqlOnly()
{
	apt-get install mysql-server
}


InstallMySqlSecure()
{
	apt-get install mysql-server

	# Make admin password same as unix admin password, add another question if different password required.
	mysql -uroot <<-END1
		ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$admin_pass';
		END1

	mysql_secure_installation

}

InstallPHP()
{
	apt install php libapache2-mod-php php-mysql
	php --version

}

DisableDefaultA2Site()
{
	echo "might want to disable default site"
	a2dissite 000-default
}

CreateVirtualHost()
{
	config=/etc/apache2/sites-available/${domain_name}.conf
	export config
	echo "<VirtualHost *:80>" >$config
  echo "  ServerName ${domain_name}" >>$config
  echo "  Redirect / https://${domain_name}/" >>$config
	echo "</VirtualHost>" >>$config

	#echo "<VirtualHost *:443>" >$config
	#echo "    ServerName $domain_name" >>$config
	#echo "    ServerAlias www.$domain_name" >>$config
	#echo "    ServerAdmin webmaster@localhost" >>$config
	#echo "    DocumentRoot /var/www/$domain_name" >>$config
	#echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" >>$config
	#echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" >>$config
	#echo "    <Directory /var/www/$domain_name>" >>$config
	#echo "      Options FollowSymLinks" >>$config
	#echo "      AllowOverride All" >>$config
	#echo "      Require all denied" >>$config
	#echo "    </Directory>" >>$config
	#echo "</VirtualHost>" >>$config
	mkdir /var/www/$domain_name
	chown -R $admin_user:www-data /var/www/$domain_name
	chmod 770 /var/www/$domain_name

	# vi /etc/apache2/sites-available/${domain_name}.conf

	a2ensite $domain_name
	echo "Now reloading apache"
	systemctl reload apache2

}

UnixAutoRemove()
{
	apt autoremove
}