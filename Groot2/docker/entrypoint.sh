#!/bin/bash -e

# Set the ROS workspace
if [ -z "$ROS_WS" ]; then
    echo "ROS_WS is not set. Setting to default"
    ROS_WS=/home/ros/app
fi
cd $ROS_WS

# . /opt/ros/humble/setup.sh && colcon build --symlink-install
# source $ROS_WS/install/setup.bash



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