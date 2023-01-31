#!/usr/bin/bash
echo "Loading scripts"

cdFunAddAdminUser()
{
	adduser $admin_user
	usermod -a -G sudo $admin_user
	echo -e "$admin_pass\n$admin_pass" | passwd $admin_user

}

FunAddAdminWWW()
{
	usermod -a -G www-data $admin_user
}

# Allow firewall open to port 80 and 443 according to https://letsencrypt.org/docs/allow-port-80/
FunAddFireWallRules()
{

	ufw app list

	ufw allow in "Apache" "ssh"
	ufw app list
}

# This will install a file that will test a file in the /tmp folder and execute a specific root command.
# Only the configured root commands will work.
# But it could for example be used for shutdown a test server from a browser link withouth SUDO.
FunAddIfFileRunRoot()
{
	echo "adding cronjob"
	line="*/2 * * * * /usr/bin/bash $SCRIPTPATH/test_run_files.sh >>/tmp/test_run_files.log 2>&1"
	echo "$line"
	(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
}

FunCreateVirtualHost()
{
	# This will create a virtual host for a domain.

	export config
	echo "<VirtualHost *:80>" >$apache_config
  echo "  ServerName ${domain_name}" >>$apache_config
  echo "  Redirect / https://${domain_name}/" >>$apache_config
	echo "</VirtualHost>" >>$apache_config

	sed  "s|\$domain_name|$domain_name|g" "$SCRIPTPATH/apache_ssl_template.conf" >$apache_ssl_config
	sed -i "s|\$vhost_root|$vhost_root|" $apache_ssl_config
	mkdir ${vhost_root}
	chown -R $admin_user:www-data ${vhost_root}
	chmod 770 ${vhost_root}

	# vi /etc/apache2/sites-available/${domain_name}.conf

	a2ensite $domain_name
	a2ensite ${domain_name}_ssl
	echo "Now reloading apache"
	systemctl reload apache2

}

FunDisableDefaultA2Site()
{
	echo "disable default site"
	a2dissite 000-default
}

FunDisAllowRootSsh()
{
	# using i and suffix as we need a backup.
	sed -i.BAK "s|PermitRootLogin yes|PermitRootLogin no|" /etc/ssh/sshd_config
}

FunInstallApache()
{
	apt-get install apache2
	a2enmod ssl
}

FunInstallMySqlOnly()
{
	apt-get install mysql-server
}


FunInstallMySqlSecure()
{
	apt-get install mysql-server

	# Make admin password same as unix admin password, add another question if different password required.
	# dash removes whitespace in front of lines placed there to make it easier to read.
	mysql -uroot <<-END1
		ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$admin_pass';
		END1

	mysql_secure_installation

}

FunInstallPHP()
{
	apt install php libapache2-mod-php php-mysql
	php --version

}

FunNewHostName()
{
	read -p "Enter new hostname or empty for keeping existing name :" new_host_name
	if [ "$new_host_name" != "" ]
	then
		hostnamectl set-hostname $new_host_name
	fi
}

FunAptAutoRemove()
{
	apt autoremove
}

FunUUpdate()
{
	apt-get update
	echo Has the update worked?
	read -p "Press enter to continue"
}

FunUUpgrade()
{
	apt-get upgrade
	echo Has the upgrade worked?
}

FunInstallNetTools()
{
	apt install net-tools
}

FunInstallPhpImagick()
{
	apt install php-imagick
}

FunInstallCurl()
{
	apt install php-curl
}