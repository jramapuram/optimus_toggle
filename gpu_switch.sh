#!/bin/sh
if ! [ $(id -u) = 0 ]; then
    echo "The script need to be run as root / sudo." >&2
    exit 1
fi

if lsmod | grep -q nvidia ; then
    echo "trying to unload nvidia module"
    # /etc/X11/xorg.conf.d/90-mhwd.conf symlinks to below
    cp ./90-mhwd.conf.intel /etc/X11/mhwd.d/nvidia.conf
    cp ./lightdm.conf.intel /etc/lightdm/lightdm.conf
    cp ./.xinitrc.intel /home/jramapuram/.xinitrc
    chown jramapuram:jramapuram ~/.xinitrc
    systemctl stop lightdm.service
    rmmod nvidia_drm nvidia_uvm nvidia_modeset nvidia
    modprobe bbswitch
    echo "OFF" >> /proc/acpi/bbswitch
    cp ./disable_nvidia.conf /etc/modprobe.d
    cp ./display_setup.sh.nvidia /etc/lightdm/display_setup.sh
    cp ./mhwd-gpu.conf.intel /etc/modules-load.d/mhwd-gpu.conf
else
    echo "trying to load nvidia"
    cp ./90-mhwd.conf.nvidia /etc/X11/mhwd.d/nvidia.conf
    cp ./lightdm.conf.nvidia /etc/lightdm/lightdm.conf
    cp ./.xinitrc.nvidia /home/jramapuram/.xinitrc
    cp ./display_setup.sh.nvidia /etc/lightdm/display_setup.sh
    chown jramapuram:jramapuram ~/.xinitrc
    modprobe bbswitch
    echo "ON" > /proc/acpi/bbswitch
    modprobe nvidia_drm nvidia_uvm nvidia_modeset nvidia
    systemctl stop lightdm.service
    rm /etc/modprobe.d/disable_nvidia.conf
    cp ./mhwd-gpu.conf.nvidia /etc/modules-load.d/mhwd-gpu.conf
fi

pkill X
sleep 2
systemctl restart lightdm.service
