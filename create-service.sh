#!/usr/bin/bash
. ./validatejson.lib

## This script creates a  System.d service file based on JSON data.
## This script needs python >= 3.6 and GNU bash (bash version used 5.0.3(1)).
## Created by aang with the help of the open source community, on April 2021.

# Sample config JSON file:
# {
#    "service_name": "service-x",
#    "description": "description-x",
#    "package_path": "/home/user/Project-X/.venv/bin/python",
#    "service_path": "main.py arguments",
#    "env_variables": { "one_env_variable": "value-x", "other_env_variable": "value-y" }
# }

## execution example of this script
## $ bash create-service.sh conf-file.json


# get the first argument, the JSON file
args=("$@")
DATA_FILE=${args[0]}

# check if argument is passed
if [ -z "$DATA_FILE" ]; then
    echo "json file should be passed as first argument"
    exit 1
fi

validateJSON DATA_FILE resulted_data # included in the imported lib

if [ $? -ne 0 ]; then
    echo "error validating conf json file"
    exit 1
fi



delimeter=';'
SplitLineByDelimeter resulted_data delimeter conf_params

echo $?


# initializing the central variables
SERVICE_NAME=${conf_params[0]}
DESCRIPTION=${conf_params[1]}
PKG_PATH=${conf_params[2]}
SERVICE_PATH=${conf_params[3]}
WORKING_DIRECTORY=${conf_params[4]}
ENV_VARIABLES=${conf_params[5]}

echo $SERVICE_NAME
echo $DESCRIPTION
echo $PKG_PATH
echo $SERVICE_PATH
echo $WORKING_DIRECTORY
echo $ENV_VARIABLES



# from this point I need to work with sudo
# create ${service_name}.d folder in /etc/systemd/system/ path
SYSTEMD_PATH=/etc/systemd/system/$SERVICE_NAME
sudo mkdir -p $SYSTEMD_PATH.service.d

# create the file override.conf inside the just created folder
# if it doesn't exists.
OVERRIDE_FILE_PATH=$SYSTEMD_PATH.service.d/override.conf
if [ ! -f $OVERRIDE_FILE_PATH ]
then
    echo "creating override.conf file"
    sudo cat > $SYSTEMD_PATH.service.d/override.conf << EOF
$ENV_VARIABLES
EOF
else
    echo "override.conf file already exists."
fi


# check if service is active
IS_ACTIVE=$(sudo systemctl is-active $SERVICE_NAME)
if [ "$IS_ACTIVE" == "active" ]; then
    # restart the service
    echo "Service is running"
    echo "Restarting service"
    sudo systemctl restart $SERVICE_NAME
    echo "Service restarted"
else
    SERVICE_FILE_PATH=/etc/systemd/system/$SERVICE_NAME.service
    echo $SERVICE_FILE_PATH

    # create service file if doesn't exists
    if [ ! -f $SERVICE_FILE_PATH ];
    then
	echo "Creating service file"
	sudo cat > $SERVICE_FILE_PATH << EOF
[Unit]	
Description=$DESCRIPTION
After=network.target
[Service]
PIDFile=/tmp/$SERVICE_NAME-99.pid
WorkingDirectory=$WORKING_DIRECTORY
ExecStart=$PKG_PATH $SERVICE_PATH
Restart=always
[Install]
WantedBy=multi-user.target
EOF
	# restart daemon, enable and start service
	echo "Reloading daemon and enabling service"
	sudo systemctl daemon-reload 
	sudo systemctl enable $SERVICE_NAME
        if [ $? -ne 0 ];
	then
	    exit 1
	fi
	sudo systemctl start $SERVICE_NAME
	echo "Service Started"
    fi
fi

exit 0
