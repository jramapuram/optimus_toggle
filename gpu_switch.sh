#!/bin/sh
# user=$(who | awk {'print "'$0'" '})
# echo "user is $user"
# exit 1

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
    cp ./compton.conf.glx /home/.config/compton.conf
    chown jramapuram:jramapuram ~/.config/compton.conf
    systemctl stop lightdm.service
    rmmod nvidia_drm nvidia_uvm nvidia_modeset nvidia
    modprobe bbswitch
    echo "OFF" >> /proc/acpi/bbswitch
else
    echo "trying to load nvidia"
    cp ./90-mhwd.conf.nvidia /etc/X11/mhwd.d/nvidia.conf
    cp ./lightdm.conf.nvidia /etc/lightdm/lightdm.conf
    cp ./.xinitrc.nvidia /home/jramapuram/.xinitrc
    chown jramapuram:jramapuram ~/.xinitrc
    cp ./compton.conf.noglx /home/.config/compton.conf
    chown jramapuram:jramapuram ~/.config/compton.conf
    modprobe bbswitch
    echo "ON" > /proc/acpi/bbswitch
    modprobe nvidia_drm nvidia_uvm nvidia_modeset nvidia
    systemctl stop lightdm.service
fi

pkill X
sleep 2
systemctl restart lightdm.service
