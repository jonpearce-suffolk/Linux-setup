# Linux-setup

Copyright under GPL v3 of Multi-project.co.uk Ltd 2023 onwards

BASH script to setup Linux with example config files

default.cfg - config file name/value pairs that control which functions are run
incl_v1.sh - utility script that runs LINUX commands to setup a new server, or install a setup on an existing server.  This has a version number but it could easily be an indentify about the class of server being setup.  As multiple utility scripts can exist but only one will be executed.
setup_script.sh - the main script that can be run "sh setup_script.sh" to setup the server.

This is a very simple setup script that allows you do all the steps to setup a server from scratch.  The advantages of this simple script is that it does not require any install of software, just using bash commands and apt to setup the server.  it is not a replacement for YAML which is more flexible but has a new learning curve and requires cloud software to run it.
At the moment, it has only been tested on Ubuntu, and at the moment it only comes with one utility script to set up PHP and Apache with MySql.

However the aim of this script is to allow agencies and other small companies to create their own utility script and config files.  According to their own standard way of doing things.  For anything more that a single developer I suggest an Architecture Group is formed to discuss the required standard and to implement it.

A config file is created with a list of functions and either Y, N against each function.
The functions sit within a utitlity script incl_v1.sh and these are the Linux commands that do the setup

The Setup script will read the config "default.cfg" file and copy to "installed.cfg" config.

and for each line in the installed file if the function is set to 'Y' then it will execute the function.
At the end of each function it will alter the "installed.cfg" to say that function is DONE.

Again at the moment, it will do this even if the function was unsuccessful.

This means that
1) you can have different config files against the same utility script to have slight different setup depending on circumstances,
2) if you run the script again, it will not repeat all the functions that have run previously.

The output of all the functions is stored in a installed.log file so that this becomes a record of the setup.


EXAMPLE
The example config and utility script contains a setup for Apache, PHP and MySql and although this is not complete gives an starting point and an indication of what can be done with the setup script.

You can contribute different utility scripts and config files by contacting me by email.

Clone with
 git clone https://github.com/jonpearce-suffolk/Linux-setup.git linux_setup


Multi-project.co.uk
