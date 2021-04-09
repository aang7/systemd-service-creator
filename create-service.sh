#!/usr/bin/bash
. ./validatejson.lib

##
## Creates Service file based on JSON data
## to run this program you need bash and python installed
##

# Sample JSON file:
# {
#    "service_name": "test_service",
#    "description": "Netcore dev server",
#    "package_path": "dotnet",
#    "service_path": "/home/muhib/DevOps/loopdatetime/Output/BuildApp.dll",
#    "service_url": "localhost:6000"
# }

# get the first argument, the JSON file
args=("$@")
DATA_FILE=${args[0]}

# check if argument is passed
if [ -z "$DATA_FILE" ]; then
    echo "JSON Data file should be passed as first argument"
    exit 1
fi

# validate if the file is a valid JSON
#result=$(bash validatejson.sh ${DATA_FILE})
# if [ $? -eq 0 ]; then
#    echo "result: ${result}"
# else
#    echo exit 1
# fi

validateJSON DATA_FILE resulted_data # included in the imported lib

if [ $? -ne 0 ]; then
    exit 1
fi



delimeter='$'
SplitLineByDelimeter resulted_data delimeter split_result
echo ${result}
echo ${split_result[0]}
echo ${split_result[1]}
echo ${split_result[2]}

echo $?
exit 1



# parse the json file
SERVICE_NAME=$(cat $DATA_FILE | jq '.service_name')
DESCRIPTION=$(cat $DATA_FILE | jq '.description')
PKG_PATH=$(cat $DATA_FILE | jq '.package_path')
SERVICE_PATH=$(cat $DATA_FILE | jq '.service_path')
# SERVICE_URL=$(cat $DATA_FILE | jq '.service_url')

# remove the double quotes
DESCRIPTION=${DESCRIPTION//'"'/}
SERVICE_NAME=${SERVICE_NAME//'"'/}
PKG_PATH=${PKG_PATH//'"'/}
SERVICE_PATH=${SERVICE_PATH//'"'/}
# SERVICE_URL=${SERVICE_URL//'"'/}

# check if service is active
IS_ACTIVE=$(sudo systemctl is-active $SERVICE_NAME)
if [ "$IS_ACTIVE" == "active" ]; then
    # restart the service
    echo "Service is running"
    echo "Restarting service"
    sudo systemctl restart $SERVICE_NAME
    echo "Service restarted"
else
    # create service file
    echo "Creating service file"
    sudo cat > /etc/systemd/system/${SERVICE_NAME//'"'/}.service << EOF
[Unit]
Description=$DESCRIPTION
After=network.target
[Service]
ExecStart=$PKG_PATH $SERVICE_PATH
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
    # restart daemon, enable and start service
    echo "Reloading daemon and enabling service"
    # sudo systemctl daemon-reload 
    # sudo systemctl enable ${SERVICE_NAME//'.service'/} # remove the extension
    # sudo systemctl start ${SERVICE_NAME//'.service'/}
    echo "Service Started"
fi

exit 0
