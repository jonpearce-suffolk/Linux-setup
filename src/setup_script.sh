#!/usr/bin/bash
echo "This must be run as root - after running further scripts can be run from admin user."
default_config="default.cfg"
installed_config="installed.cfg"
install_log="install.log"
admin_user="mp_admin"; export admin_user;

hostnamectl
echo "This is the current machine name."
read -p "Press enter to continue" start
read -p "Enter the domain: " domain_name; export domain_name;
read -p "Admin password $admin_user" admin_pass; export admin_pass

DIR="${BASH_SOURCE%/*}"
if [ ! -d "$DIR" ]
	then
	DIR="$PWD"
fi
. "$DIR/incl_v1.sh"


if [ ! -f "$installed_config" ]
	then
	cp "$default_config" "$installed_config"
fi

while IFS= read -r file_line
	do
		config_name=${file_line%=*}
		config_value=${file_line#*=}

		# process this option
		echo "Processing config item $config_name : \"$config_value\"" >>$install_log

		if [ $config_value != "Y" ]; then
			continue;
		fi

		echo "Starting to run $config_name"
		echo "Starting to run $config_name" >>$install_log
		date >>$install_log
		$config_name >>$install_log
		echo "Finished" >>$install_log
		sed "s|$config_name=Y|$config_name=DONE|" $installed_config >this.cfg
		mv "this.cfg" "$installed_config"

	done < "$installed_config"


