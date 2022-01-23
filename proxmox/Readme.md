# Goal: Install Proxmox 7.1 server to run Linux lxc containers including Nvidia GPU support.
I found various tutorials on this topic, but nothing that worked 1:1 for me, especially with Proxmox Version 7.1. Therefore I created this howto.

## WARNING :exclamation:
1. __THE INSTALLATION OF PROXMOX WILL WIPE YOUR DISK AND ALL DATA ON IT__
2. __DO NOT JUST EXECUTE THE CODE BLOCKS BELOW, MAKE SURE TO DOUBLE CHECK WITH YOUR SYSTEM__

## Install Proxmox 7.1

[Good Proxmox course on youtube](https://www.youtube.com/playlist?list=PLT98CRl2KxKHnlbYhtABg6cF50bYa8Ulo)

- Install Proxmox 7.1
  - installation is pretty straigt forward
  - [download ISO image](https://www.proxmox.com/en/downloads)
  - flash iso to USB stick - use your favorite tool depending on your os (e.g. [usbimager](https://bztsrc.gitlab.io/usbimager/)
  - boot from USB stick - make sure to change you BIOS settings in case required
  - follow installation procedure -- __!!! BE CAREFUL YOUR COMPLETE HARDDISK WILL BE WIPED !!!__
  - `reboot`
  - login and update the distribution `apt update && apt dist-upgrade`
  - `reboot`


## Install latest Proxmox edge kernel
I assume not officially supported. However in my case this was needed to properly get the nvidia driver installed.

- install [Proxmox edge Kernel](https://github.com/fabianishere/pve-edge-kernel) - see procedure on their page.
- `reboot`
- install kernel headers according to your kernel `apt install pve-headers-$(uname -r)`
- install build-essential and pkg-config `apt install build-essential pkg-config`

## Install NVidia driver
__:hammer: TODO__ Since the Proxmox server has no X server, I think we need to tweak the environment variables accordingly before installing the dirver.
see: https://github.com/NVIDIA/nvidia-container-runtime#nvidia_driver_capabilities

- Blacklist nouvea open source nvidia driver to avoid it gets loaded during boot.
```
cat << EOF > /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF
```
- `reboot`


.
- [Download apropriate NVidia linux driver](https://www.nvidia.com/Download/index.aspx?lang=en-us) (Make sure to choose the apropriate driver for __YOUR__ NVidia card, click download, on the next page copy the link of the _Download_ button)
- In my case it was the following link and I use wget to directly load it to the proxmox server `wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.94/NVIDIA-Linux-x86_64-470.94.run` - 
- Make the file executable `chmod 755 NVIDIA-Linux-x86_64-470.94.run`
- Install the driver `./NVIDIA-Linux-x86_64-470.94.run`
- Follow the installation procedure
- `reboot`
- Apply the following changes of [this tutorial](https://passbe.com/2020/02/19/gpu-nvidia-passthrough-on-proxmox-lxc-container/) to get the nvidia driver loaded properly:
  - Configure NVidia modules to get loaded
´´´
cat << EOF > /etc/modules-load.d/nvidia.conf
nvidia-drm
nvidia
nvidia_uvm
EOF
´´´
  - Setup udev rules
```
cat << EOF > /etc/udev/rules.d/70-nvidia.rules
# Create /nvidia0, /dev/nvidia1 … and /nvidiactl when nvidia module is loaded
KERNEL=="nvidia", RUN+="/bin/bash -c '/usr/bin/nvidia-smi -L && /bin/chmod 666 /dev/nvidia*'"
# Create the CUDA node when nvidia_uvm CUDA module is loaded
KERNEL=="nvidia_uvm", RUN+="/bin/bash -c '/usr/bin/nvidia-modprobe -c0 -u && /bin/chmod 0666 /dev/nvidia-uvm*'"
EOF
```
  - `reboot`
  - Take a look at the tutorial linked above to verify if all required files exist
  - Run `nvidia-smi` to see if the driver was properly loaded and detected your card, the output should look similar to this
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.94       Driver Version: 470.94       CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
| 23%   33C    P0    22W /  75W |      0MiB /  3911MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

# Install official lxc conatiners from https://linuxcontainers.org/

Since I had issues with the container images provided by proxmox I used the "officail" containers from https://linuxcontainers.org/. I successfully used the following procedure:
- Login to your Proxmox server
- Identify the apropriate image on the image server https://us.lxd.images.canonical.com/images/
- What you will need is the link to the __rootfs.tar.xz__ file of the container you want to use
- E.g. for debian 11(bullseye) default image, this is: https://us.lxd.images.canonical.com/images/debian/bullseye/amd64/default/20220122_05:25/rootfs.tar.xz
- This image needs to be downloaded to the __/var/lib/vz/template/cache__ directory on the Proxmox server and renamed to a meaningful name. I use wget to do this.
```
cd /var/lib/vz/template/cache
wget https://us.lxd.images.canonical.com/images/debian/bullseye/amd64/default/20220122_05:25/rootfs.tar.xz -O debian-11-bullseye.tar.xz
```
- Afterwards the container image is available in the Proxmox web interface as a template for creating new containers.

# Create Debian 11 bullseye container, Install NVidia Drivers and activate GPU passthrough
- Create a new container in Proxmox based on the debian bullseye tempalte. See youtube course above.
- Login to the container and update `apt update && apt dist-upgrade`
- Install wget `apt install wget`
- download the invidia driver to the conatiner (__NEED TO BE EXACT SAME VERSION AS INSTALLED ON THE HOST__)
- In my case I do `wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.94/NVIDIA-Linux-x86_64-470.94.run`
- Make executable `chmod 755 NVIDIA-Linux-x86_64-470.94.run`
- Install NVidia driver in the container without the modules `./NVIDIA-Linux-x86_64-470.94.run --no-kernel-module`
- Shutdown the container ´shutdown -P now`
- Now change the configuration of the container on the Proxmox server as described [in this tutorial (section lxc container)](https://passbe.com/2020/02/19/gpu-nvidia-passthrough-on-proxmox-lxc-container/)
- Restart the container and verify if the passthrough works properly (see same tutorial)
- 
