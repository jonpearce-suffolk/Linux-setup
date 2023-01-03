# Linux-setup
BASH script to setup Linux with example config files

This is a very simple setup script that allows you do all the steps to setup a server from scratch.
At the moment, it has only been tested on Ubuntu, and at the moment it only comes with one utility script to set up PHP and Apache with MySql.

However the aim of this script is to allow agencies and other companies to create their own utility script and config files.

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

Multi-project.co.uk 
