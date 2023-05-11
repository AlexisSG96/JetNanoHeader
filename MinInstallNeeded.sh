export current=$PWD

# Useful packages

sudo apt-get update -y

sudo apt-get autoremove

sudo apt-get install -y apt-utils openssh-server openssh-client net-tools busybox python3-setuptools python3-pip

# Enable SD Card
cd $current

git clone https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git

cd seeed-linux-dtoverlays/

sed -i '17s#JETSON_COMPATIBLE#\"nvidia,p3449-0000-b00+p3448-0002-b00\"\, \"nvidia\,jetson-nano\"\, \"nvidia\,tegra210\"#' overlays/jetsonnano/jetson-sdmmc-overlay.dts

make overlays/jetsonnano/jetson-sdmmc-overlay.dtbo

sudo cp overlays/jetsonnano/jetson-sdmmc-overlay.dtbo /boot/

sudo /opt/nvidia/jetson-io/config-by-hardware.py -n "reComputer sdmmc"

# Enable 40 Pin Header

sudo cp /boot/tegra210-p3448-0000-p3449-0000-a02-hdr40.dtbo overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-a02-hdr40.dtbo

dtc -I dtb -O dts -o overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-b00-hdr40.dtsi overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-a02-hdr40.dtbo

sed -i '5s/.*/	compatible = "nvidia,p3449-0000-b00+p3448-0002-b00", "nvidia,jetson-nano", "nvidia-tegra210";/' overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-b00-hdr40.dtsi

dtc -@ -I dts -O dtb -o overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-b00-hdr40.dtbo overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-b00-hdr40.dtsi

sudo cp overlays/jetsonnano/tegra210-p3448-0000-p3449-0000-b00-hdr40.dtbo /boot/

sudo /opt/nvidia/jetson-io/config-by-hardware.py -n "Jetson 40pin Header"

sudo /opt/nvidia/jetson-io/config-by-hardware.py -l

# Clone eMMC
cd $current

git clone https://github.com/limengdu/bootFromUSB

cd bootFromUSB/

#./copyRootToUSB.sh -p /dev/mmcblk1p1

# Install gstreamer
cd $current

git clone https://github.com/GStreamer/gst-rtsp-server.git

sudo apt-get install -y libgstrtspserver-1.0 libgstreamer1.0-dev

sudo apt-get install -y v4l-utils

sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

# Install Jetson.GPIO (Rasberry PI Alternative for 40 Pin Header)
sudo groupadd -f -r gpio

sudo usermod -a -G gpio "$(whoami)"

sudo -H pip3 install Jetson.GPIO

# Install MavLink and MavProxy
sudo apt-get install -y python-pip python3-pip

sudo apt-get install -y python3-dev python3-opencv python3-wxgtk4.0 python3-matplotlib python3-lxml libxml2-dev libxslt-dev

sudo pip3 install PyYAML mavproxy

#sudo mavproxy.py --master=/dev/ttyTHS1
