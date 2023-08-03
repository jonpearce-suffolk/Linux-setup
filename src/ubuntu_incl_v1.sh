#!/usr/bin/bash
echo "Loading scripts"

FunAddAdminUser()
{
	adduser $admin_user
	usermod -a -G sudo $admin_user
	echo -e "$admin_pass\n$admin_pass" | passwd $admin_user

}

FunAddSudo()
{
	read -p "Admin user needing sudo" sudo_user; export sudo_user
	usermod -a -G sudo $sudo_user
}

FunAddAdminWWW()
{
	usermod -a -G www-data $admin_user
}

# Allow firewall open to port 80 and 443 according to https://letsencrypt.org/docs/allow-port-80/
FunAddFireWallRules()
{

	ufw app list

	ufw allow Apache
	ufw allow ssh

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
	echo "<?php echo 'this is working';" > ${vhost_root}/index.php

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
	apt-get -y install apache2
	a2enmod ssl
}

FunInstallMySqlOnly()
{
	apt-get -y install mysql-server
}


FunInstallMySqlSecure()
{
	apt-get -y install mysql-server

	# Make admin password same as unix admin password, add another question if different password required.
	# dash removes whitespace in front of lines placed there to make it easier to read.
	mysql -uroot <<-END1
		ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$admin_pass';
		END1

	mysql_secure_installation

}

FunInstallPHP()
{
	apt-get -y install php libapache2-mod-php php-mysql
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
	apt-get -y update
	apt-get -y autoremove
}

FunUUpdate()
{
	apt-get -y update
	echo Has the update worked?
	read -p "Press enter to continue"
}

FunUUpgrade()
{
	apt-get -y upgrade
	echo Has the upgrade worked?
}

FunInstallNetTools()
{
	apt-get -y install net-tools
}

FunInstallPhpImagick()
{
	apt-get -y install php-imagick
}

FunInstallCurl()
{
	apt-get -y install php-curl
}

FunInstallKey()
{
	echo 'This will install your public key into authorized_keys'
	read -p "Enter Public key :" pub_key; export pub_key
	echo $pub_key >>.ssh/authorized_keys
}

FunRootLimitLogin()
{
	set sshd_config=/etc/ssh/sshd_config
	sed -i "s|PermitRootLogin yes|PermitRootLogin prohibit-password|" $sshd_config
	systemctl reload sshd
}

FunAptAutoUpgrade()
{
	apt-get -y update
	apt-get -y upgrade
}

FunAddWeeklyReboot()
{
	rem "/usr/sbin/shutdown -r now"
	echo "adding cronjob must be run as root"
	line="30 3  *    *    Tue /sbin/shutdown -r now >/tmp/reboot.log 2>&1"
	echo "$line"
	(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
}

FunAddAdminGroupApache()
{
	usermod -a -G sudo www-data
}