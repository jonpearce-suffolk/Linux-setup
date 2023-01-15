#!/usr/bin/bash

shutdown_sig="/tmp/set_shutdown.sig"
if [ -f "$shutdown_sig" ]
then
	if grep -Fxq "WH90-$%RF-KILL" "$shutdown_sig"
	then
		# code if found
		shutdown -g0
	else
		# code if not found perhaps notify administrator
		echo "not a valid secret"
	fi

fi
