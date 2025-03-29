#!/bin/bash -e

# ==============================
# ===== ROS Installation =======
# ==============================
if [ -z "$ROS_WS" ]; then
    echo "ROS_WS is not set. Setting to default"
    ROS_WS=/home/ros/app
fi
cd $ROS_WS

# . /opt/ros/humble/setup.sh && colcon build --symlink-install
# source $ROS_WS/install/setup.bash


# ==============================
# ===== SMB Configuration ======
# ==============================

# List of host suffixes (dit-2025-11 ~ dit-2025-14)
HOSTS=("11" "12" "13" "14")

# Credentials for Samba
SMB_USER="dit"
SMB_PASS="robotics"

# Base path for mount points
MOUNT_BASE="$HOME/app/groot2/DIT"

# Loop through each host and mount if reachable
# Get the first 9 digits of the IP from the host network
HOST_IP_PREFIX=$(hostname -I | awk '{print $1}' | cut -d. -f1-3)

# Print styled table header
echo ""
echo "┌──────────────────────────────┐"
echo "│      DIT-2025 Connection     │"
echo "├───────────────┬──────────────┤"
printf "│ %-13s │ %-12s │\n" "Host" "Status"
echo "├───────────────┼──────────────┤"

# Create backup directory
BACKUP_DIR="$MOUNT_BASE/Backups"
mkdir -p "$BACKUP_DIR"

# Loop through each host and mount if reachable
for i in "${HOSTS[@]}"; do
    HOST_IP="${HOST_IP_PREFIX}.$i"
    SHARE="//${HOST_IP}/dit"
    MOUNT_POINT="$MOUNT_BASE/DIT-2025-$i"

    if ping -c 1 -W 1 $HOST_IP &> /dev/null; then
        STATUS_TEXT="Connected"
        STATUS_COLOR="\033[0;32m"  # Green
        mkdir -p "$MOUNT_POINT"
        if sudo mount -t cifs "$SHARE" "$MOUNT_POINT" \
                      -o username=$SMB_USER,password=$SMB_PASS,vers=3.0,uid=$(id -u),gid=$(id -g) 2>/dev/null; then
            sudo chown -R ros:ros "$MOUNT_BASE"

            # Backup the mounted folder (overwrite the latest version)
            BACKUP_TARGET="$BACKUP_DIR/DIT-2025-$i"
            rm -rf "$BACKUP_TARGET"
            cp -r "$MOUNT_POINT" "$BACKUP_TARGET"
        else
            STATUS_TEXT="Mount Fail"
            STATUS_COLOR="\033[0;33m"  # Yellow
        fi
    else
        STATUS_TEXT="Disconnected"
        STATUS_COLOR="\033[0;31m"  # Red
    fi

    # Print the status in the table
    printf "│ %-13s │ " "DIT-2025-$i"
    echo -e "${STATUS_COLOR}$(printf '%-12s' "$STATUS_TEXT")\033[0m │"
done

echo "└───────────────┴──────────────┘"


# ==============================
# ===== Groot Installation =====
# ==============================

WEB_URL="https://s3.us-west-1.amazonaws.com/download.behaviortree.dev/groot2_linux_installer"
GROOT_VERSION="1.6.1"
GROOT_DIR=$HOME/app/groot2
GROOT_FILE="Groot2-v${GROOT_VERSION}-x86_64.AppImage"
GROOT_APPIMAGE=./Groot2.AppImage

# Create the Groot directory
if [ ! -d $GROOT_DIR ]; then
    mkdir -p $GROOT_DIR
fi
cd $GROOT_DIR
# Check if the AppImage is exist
if [ ! -f $GROOT_APPIMAGE ]; then
    echo "Downloading Groot AppImage: $GROOT_FILE"

    # Install the Groot AppImage
    wget -O "$GROOT_APPIMAGE" "$WEB_URL/$GROOT_FILE"
else
    echo "Groot AppImage already exist: $GROOT_APPIMAGE"
fi
# Make the AppImage executable
sudo chmod +x $GROOT_DIR/$GROOT_APPIMAGE

# Run the Groot AppImage
$GROOT_DIR/$GROOT_APPIMAGE

# # Wait for the AppImage to start
# sleep 5
# while pgrep -f "AppRun.wrapped" > /dev/null; do
#     sleep 1
# done

# exec "$@"