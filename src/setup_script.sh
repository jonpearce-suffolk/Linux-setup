#!/usr/bin/bash
echo "This must be run as root - after running further scripts can be run from admin user."
default_config="default.cfg"
installed_config="installed.cfg"
install_log="install.log"
## Admin user should be set in config.
if [ -z $admin_user ]; then $admin_user="mp_admin"; fi;
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# either parameter 1 is new config or ask.
echo "$1"
if [ $# -eq 0 ]
	then
		read -p "Enter new config name (or leave blank for default): " new_config
	else
		new_config=$1
fi

if [ ! -z "$new_config" ]
	then
		if [ -f "$new_config" ]
			then
				default_config=$new_config
				rm $installed_config
			else
				echo "New config ${new_config} does not exist"
				exit
		fi
fi

echo "Script running from folder $SCRIPTPATH"

hostnamectl
echo "This is the current machine name."
read -p "Press enter to continue" start
read -p "Enter the domain: " domain_name; export domain_name;
read -p "Admin password $admin_user" admin_pass; export admin_pass

if [ ! -d "$SCRIPTPATH" ]
	then
	SCRIPTPATH="$PWD"
fi
source "$SCRIPTPATH/incl_v1.sh"
echo "loading library $SCRIPTPATH/incl_v1.sh"

if [ ! -f "$installed_config" ]
	then
		echo "Install new config file"
		cp "$default_config" "$installed_config"
	else
		echo "Using existing installed config"
	fi

# Load the config variables
source $installed_config

# Now scan down the file and execute each line.
echo "================" >>$install_log
while IFS= read -r file_line
	do
		# Ignore blank lines in config
		if [ -z "$file_line" ]
			then
				continue
			fi
		# Ignore and echo comments in config and anything that is not a function
		if [ "${file_line:0:1}" == "#" ] || [ "${file_line:0:3}" != 'Fun' ]
			then
				echo "${file_line}"
				continue
			fi

		config_name=${file_line%=*}
		config_value=${file_line#*=}

		# process this option
		mess="Processing config item $config_name : \"$config_value\" $(date)"
		echo $mess >>$install_log

		if [ $config_value != "Y" ]; then
			continue;
		fi

		mess="Starting to run $config_name"
		echo "$mess"
		echo "$mess" >>$install_log
		"$config_name" >>$install_log
		echo "Finished" >>$install_log
		sed "s|$config_name=Y|$config_name=DONE|" $installed_config >this.cfg
		mv "this.cfg" "$installed_config"

	done < "$installed_config"
mess="Complete script $(date)"
echo $mess
echo $mess >>$install_log

