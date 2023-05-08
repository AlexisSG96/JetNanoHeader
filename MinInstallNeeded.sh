export current=$PWD

# Useful packages

sudo apt-get update -y

sudo apt-get autoremove

sudo apt-get install -y apt-utils openssh-server openssh-client net-tools busybox

# Enable SD Card
cd $current

git clone https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git

cd ~/Downloads/seeed-linux-dtoverlays

sed -i '17s#JETSON_COMPATIBLE#\"nvidia,p3449-0000-b00+p3448-0002-b00\"\, \"nvidia\,jetson-nano\"\, \"nvidia\,tegra210\"#' overlays/jetsonnano/jetson-sdmmc-overlay.dts

make overlays/jetsonnano/jetson-sdmmc-overlay.dtbo

sudo cp overlays/jetsonnano/jetson-sdmmc-overlay.dtbo /boot/

sudo /opt/nvidia/jetson-io/config-by-hardware.py -n "reComputer sdmmc"

# Clone eMMC
cd $current

git clone https://github.com/limengdu/bootFromUSB

cd ~/Downloads/bootFromUSB

#./copyRootToUSB.sh -p /dev/mmcblk1p1

# Install gstreamer
cd $current

git clone https://github.com/GStreamer/gst-rtsp-server.git

sudo apt-get install -y libgstrtspserver-1.0 libgstreamer1.0-dev

sudo apt-get install -y vl4-utils

sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

