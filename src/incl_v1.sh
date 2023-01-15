#!/usr/bin/bash
echo "Loading scripts"

AddAdminUser()
{
	adduser $admin_user
	usermod -a -G sudo $admin_user
	echo -e "$admin_pass\n$admin_pass" | passwd $admin_user

}

AddAdminWWW()
{
	usermod -a -G www-data $admin_user
}

# Allow firewall open to port 80 and 443 according to https://letsencrypt.org/docs/allow-port-80/
AddFireWallRules()
{

	ufw app list

	ufw allow in "Apache" "ssh"
	ufw app list
}

# This will install a file that will test a file in the /tmp folder and execute a specific root command.
# Only the configured root commands will work.
# But it could for example be used for shutdown a test server from a browser link withouth SUDO.
AddIfFileRunRoot()
{
	echo "adding cronjob"
	line="*/2 * * * * /usr/bin/bash $SCRIPTPATH/test_run_files.sh >>/tmp/test_run_files.log 2>&1"
	echo "$line"
	(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
}

CreateVirtualHost()
{
	# This will create a virtual host for a domain.  Put you own standard folder names here.
	# The non secure site should redirect to the secure (HTTPS) site.
	# If you are using Let's Encrypt then you need to install Snap and certBot too.
	config=/etc/apache2/sites-available/${domain_name}.conf; export config;
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

DisableDefaultA2Site()
{
	echo "might want to disable default site"
	a2dissite 000-default
}

DisAllowRootSsh()
{
	# using i and suffix as we need a backup.
	sed -i.BAK "s|PermitRootLogin yes|PermitRootLogin no|" /etc/ssh/sshd_config
}

InstallApache()
{
	apt-get install apache2
}

InstallMySqlOnly()
{
	apt-get install mysql-server
}


InstallMySqlSecure()
{
	apt-get install mysql-server

	# Make admin password same as unix admin password, add another question if different password required.
	# dash removes whitespace in front of lines placed there to make it easier to read.
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

NewHost()
{
	read -p "Enter new hostname or empty for keeping existing name :" new_host_name
	if [ "$new_host_name" != "" ]
	then
		hostnamectl set-hostname host.example.com
	fi
}

UnixAutoRemove()
{
	apt autoremove
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

