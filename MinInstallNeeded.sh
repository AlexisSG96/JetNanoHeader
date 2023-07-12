export current=$PWD

# Make sure you can use apt

if grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
	echo "/etc/resolv.conf is good to go!"
else
	echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null
fi

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

sudo /opt/nvidia/jetson-io/config-by-hardware.py -l

output=$(sudo /opt/nvidia/jetson-io/config-by-hardware.py -l)

regex="User Custom \[[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}\]"

if [[ "$output" =~ $regex ]]; then
	extracted_content=${BASH_REMATCH[0]}
	echo "Extracted content: $extracted_content"
	sudo /opt/nvidia/jetson-io/config-by-hardware.py -n "$extracted_content"
else
	echo "User custom dtb value not found."
fi

# Clone eMMC
cd $current

git clone https://github.com/limengdu/bootFromUSB

cd bootFromUSB/

#./copyRootToUSB.sh -p /dev/mmcblk1p1
# To boot from sd card
# Before reboot Modify "/boot/extlinux/extlinux.conf" 
# After reboot view "/media/seeed/{xxx-xxx}/boot/extlinux/extlinux.conf"
# Change root= under LABEL primary and JetsonIO
#	to /dev/mmcblk1p1 for SD card and /dev/mmcblk0p1 for EMMC 

# Install gstreamer
cd $current

git clone https://github.com/GStreamer/gst-rtsp-server.git

sudo apt-get install -y libgstrtspserver-1.0 libgstreamer1.0-dev

sudo apt-get install -y v4l-utils

sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

# Comment out problem that keeps gstreamer from building
# Using following command: sed -i 's|pattern|replacement|'
# Using pipe character as the delimiter avoids issues with special characters
# ^ represents start of line | .* matches any character | $ represents end of the line
sed -i 's|^.*gst_rtsp_media_factory_set_enable_rtcp (factory, !disable_rtcp);$|  //gst_rtsp_media_factory_set_enable_rtcp (factory, !disable_rtcp);|' gst-rtsp-server/examples/test-launch.c

# Compile gstreamer test-launch
gcc gst-rtsp-server/examples/test-launch.c -o test-launch $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-rtsp-server-1.0)

# Function to run gstreamer

run_gstreamer() 
{

# Check for devices

# Doesn't work as output is stderr - hello
# output=$(v4l2-ctl --list-devices)
# if echo "$output" | grep -Fq "Failed to open /dev/video0: No such file or directory"; then

#'2>&1' redirects the stderr to stdout
output=$(v4l2-ctl --list-devices 2>&1)

if [[ "$output" == "Failed to open /dev/video0: No such file or directory"* ]]; then
# Something else went wrong
	echo "$output"
	exit 0
else
#Run test-launch
	./test-launch "v4l2src device=/dev/video0 io-mode=2 ! image/jpeg,width=1280,height=720 ! nvjpegdec ! video/x-raw ! nvvidconv ! nvv412h264enc ! h264parse ! rtph264pay ! name=pay0 pt=96"
fi

}

# Function to run GST-Launch
run_gst_launch()
{
	gst-launch-1.0 v4l2src device=/dev/video0 io-mode=2 ! image/jpeg,width=1280,height=720 ! nvjpegdec ! video/x-raw ! nvvidconv ! 'video/x-raw(memory=NVVM),format=I420' ! nvoverlaysink
}

# Install Jetson.GPIO (Rasberry PI Alternative for 40 Pin Header)
cd $current

sudo groupadd -f -r gpio

sudo usermod -a -G gpio "$(whoami)"

sudo -H pip3 install Jetson.GPIO

# Install MavLink and MavProxy
cd $current

sudo apt-get install -y python-pip python3-pip

sudo apt-get install -y python3-dev python3-opencv python3-wxgtk4.0 python3-matplotlib python3-lxml libxml2-dev libxslt-dev

sudo -H pip3 install PyYAML mavproxy

# Function to run MavProxy

run_mavproxy()
{
	sudo mavproxy.py --master=/dev/ttyTHS1
}

# Install NVIDIA Jetson Device for the command: jtop
cd $current

sudo -H pip3 install -U jetson-stats

# Get OpenCV Install Script and Examples
cd $current

git clone https://github.com/JetsonHacksNano/buildOpenCV.git

sudo apt-get install -y python3-dev python3-numpy python3-py python3-pytest
