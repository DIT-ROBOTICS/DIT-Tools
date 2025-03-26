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

for i in "${HOSTS[@]}"; do
    HOST_IP="${HOST_IP_PREFIX}.$i"
    SHARE="//${HOST_IP}/dit"
    MOUNT_POINT="$MOUNT_BASE/DIT-2025-$i"

    echo -e "\e[1;34mChecking if $HOST_IP is online...\e[0m"

    if ping -c 1 -W 1 $HOST_IP &> /dev/null; then
        echo -e "\e[1;32m$HOST_IP is online. Mounting...\e[0m"
        mkdir -p "$MOUNT_POINT"
        sudo mount -t cifs "$SHARE" "$MOUNT_POINT" \
                   -o username=$SMB_USER,password=$SMB_PASS,vers=3.0,uid=$(id -u),gid=$(id -g)
        sudo chown -R ros:ros /home/ros/app/groot2/DIT
    else
        echo -e "\e[1;31m$HOST_IP is offline. Skipping...\e[0m"
    fi
done


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
$GROOT_DIR/$GROOT_APPIMAGE &

while true; do
    sleep 60
done

exec "$@"