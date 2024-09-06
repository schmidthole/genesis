#!/bin/bash

function usage() {
    echo "Usage: $0 -b <binary_path> -c <config_path> -a <app_name> -e <exec_command> -t <target_ip>"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--binary) BINARY_PATH="$2"; shift ;;
        -c|--config) CONFIG_PATH="$2"; shift ;;
        -a|--app) APP_NAME="$2"; shift ;;
        -e|--exec) APP_EXEC="$2"; shift ;;
        -t|--target) TARGET_IP="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

if [ -z "$BINARY_PATH" ] || [ -z "$CONFIG_PATH" ] || [ -z "$APP_NAME" ] || [ -z "$APP_EXEC" ] || [ -z "$TARGET_IP" ]; then
    usage
fi

SYSTEMD_FILE="/tmp/${APP_NAME}.service"
cat <<EOF > "$SYSTEMD_FILE"
[Unit]
Description=$APP_NAME
After=network.target

[Service]
ExecStart=$APP_EXEC
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "creating directories and copying files to $TARGET_IP"
ssh -o StrictHostKeyChecking=no "$TARGET_IP" "sudo mkdir -p /etc/$APP_NAME /opt/$APP_NAME /var/$APP_NAME"
scp -o StrictHostKeyChecking=no "$BINARY_PATH" "$TARGET_IP:/opt/$APP_NAME/"
scp -o StrictHostKeyChecking=no "$CONFIG_PATH" "$TARGET_IP:/etc/$APP_NAME/"
scp -o StrictHostKeyChecking=no "$SYSTEMD_FILE" "$TARGET_IP:/tmp/"

echo "setting up systemd service: ${APP_NAME}.service"
ssh -o StrictHostKeyChecking=no "$TARGET_IP" << EOF
    sudo mv /tmp/${APP_NAME}.service /etc/systemd/system/${APP_NAME}.service
    sudo systemctl daemon-reload
    sudo systemctl stop ${APP_NAME}.service
    sudo systemctl enable ${APP_NAME}.service
    sudo systemctl restart ${APP_NAME}.service
EOF

# Clean up the local temporary systemd file
rm "$SYSTEMD_FILE"

echo "Service $APP_NAME installed and started successfully on $TARGET_IP."

