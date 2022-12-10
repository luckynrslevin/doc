# Running wireguard and pi hole in separate lxc cntainers on a raspberry pi


```
 +---------------------+  +------------------------+
 |  container running  |  |  container running     |
 |  alpine +           |  |  debian + pihole       |
 |  wireguard server + |  |  including automatic   |
 |  automatic update   |  |  os & pihole update    |
 +---------------------+  +------------------------+
 +-------------------------------------------------+
 | Raspbian with                                   |
 |   - automatic securiy updates configured        |
 |   - wireguard kernel module loaded during boot  |
 |   - lxd / lxc container host/server             |
 +-------------------------------------------------+
 +-------------------------------------------------+
 |              Raspberry PI hardware              |
 +-------------------------------------------------+
```

#### Table of Contents  

- [Raspbian installation and configration](#raspbian-installation-and-configration)
  * [Raspbian os installation](#raspbian-os-installation)
  * [Raspbian load wireguard kernel modules](#raspbian-load-wireguard-kernel-modules)
  * [Raspbian unattended updates](#raspbian-unattended-updates)
  * [Raspbian lxclxd installation](#raspbian-lxclxd-installation)
  * [Raspbian network bridge configuration](#raspbian-network-bridge-configuration)
- [Wireguard container installation and configuration](#wireguard-container-installation-and-configuration)
  * [Create alpine container](#create-alpine-container)
  * [Install wireguard](#install-wireguard)
  * [Autostart -stop wireguard](#autostart-wireguard-on-boot)
  * [Update alpine daily](#update-alpine-daily)
- [Install PI Hole on debian container](#install-pi-hole-on-debian-container)

- [Other Links](#other-links)


## Raspbian installation and configration

### Raspbian os installation
- Download latest Raspberry PI os https://www.raspberrypi.com/software/operating-systems/
- Flash it to the SD card
- Enable ssh by writing a file named `ssh` on the SD card (do not use .ssh)
- Put SD card in your pi and power on
- login via ssh with default `user:pi pw:raspberry`
- Change hostname according to your needs `sudo raspi-config`
- Add a new user `sudo adduser yournewuser`
- Add the new user to sudo group `sudo usermod -aG sudo yournewuser`
- reboot pi `sudo reboot`
- login with your new user `ssh yournewuser@yourhostname`
- Try if sudo works with your new use e.g. `sudo apt-get update`
- Remove default pi user `sudo deluser -remove-home pi`
- to avoid yournewuser has to always type the password for sudo do:
    - `sudo chmod 640 /ets/sudoers.d/010_yournewuser-nopasswd`
    - replace `pi` with `yournewusername` in the file `/ets/sudoers.d/010_yournewuser-nopasswd`
    - `sudo chmod 440 /ets/sudoers.d/010_yournewuser-nopasswd`

### Raspbian load wireguard kernel modules
- To automatically load wireguard module during boot add one line with `wireguard` to `/etc/modules-load.d/modules.conf`. This is required, since all lxc containers use kernel and kernel modules from the host.

### Raspbian unattended updates
- Install unattended updates (upgrades) `sudo apt-get install unattended-upgrades && sudo apt install apt-listchanges`
- Change the following configuration parameters in `/etc/apt/apt.conf.d/50unattended-upgrades`
    - Change debian upgrade configuration to raspbian update configuration
    ```
    //"origin=Debian,codename=${distro_codename},label=Debian";
    //"origin=Debian,codename=${distro_codename},label=Debian-Security";
    //"origin=Debian,codename=${distro_codename}-security,label=Debian-Security";
    "origin=Raspbian,codename=${distro_codename},label=Raspbian";
    "origin=Raspberry Pi Foundation,codename=${distro_codename},label=Raspberry Pi Foundation";
    ```
    - Enable autotic reboot
    ```
    Unattended-Upgrade::Automatic-Reboot "true";
    ```
    - If you want cange reboot time to a cnvenient time
    ```
    Unattended-Upgrade::Automatic-Reboot-Time "02:00";
    ```
- Change the following configuration parameters in `/etc/apt/apt.conf.d/50unattended-upgrades`
    Add the following two lines to the configuration file (keep the exiisting ones!
    ```
    APT::Periodic::Download-Upgradeable-Packages "1"; 
    APT::Periodic::AutocleanInterval "7";
    ```
- Do a dryrun to see if it works `sudo unattended-upgrades --dry-run --debug`

### Raspbian lxclxd installation
-  Install lxc/lxd:
    - `sudo apt-get install snapd  bridge-utils`
    - `sudo snap install core lxd`
    - `sudo usermod -aG lxd yournewuser`
    - `lxd init` => Answer all questions with default proposal.

### Raspbian network bridge configuration
- configure transparent bridge (see http://www.makikiweb.com/Pi/lxc_on_the_pi.html) ==> setting up an external bridge interface on the Host
    - sudo apt-get install bridge-utils ifupdown
    - Create the file `/etc/network/interfaces.d/br0` with the following content:
      ```
      iface br0 inet dhcp
      bridge_ports eth0
      bridge_stp off
      bridge_fd 0
      bridge_maxwait 0
      iface br0 inet6 dhcp
      ```
    - Create the file `/e/ystemd/network/br0.network` with the following content
      ```
      [Match]
      Name=br0
      
      [Network]
      DHCP=yes
      ```
    - To enable bridge after reboot add the folloing to `/etcrc.local`:
      ```
      # fix for br0 interface
      /sbin/ifup br0
      # kick networkd as well
      /bin/systemctl restart systemd-networkd
      echo "Bridge is up"
      ```
    - Make it executable `sudo chmod 754 /etc/rc.local`
    - Check if evrything worked properly with `ip addr` command and verify output

## Wireguard container installation and configuration
### Create alpine container
- See [Image server for LXC and LXD](https://us.lxd.images.canonical.com/) to identify the latest version of alpine container available for the arm platform of your pi. At the time I am writing this it is version 3.15.
- create an alpine container for wireguard `lxc launch -p default -p extbridge images:alpine/3.15 wg`
- list containers with `lxc ls`
- open a shell on the container `lxc exec wg -- /bin/sh`
- **❗❗❗ Proceed with all following steps from this shell inside the cntainer ❗❗❗**

### Install wireguard
- `apk add wireguard-tools`

### Autostart wireguard on boot
- Create an init script `/etc/init.d/wg` with the following content:
  ```
  #!/sbin/openrc-run
  name="wg"
  
  depend() {
  	need net
  }
  
  start() {
      wg-quick up wg0 
  }
  
  stop() {
      wg-quick down wg0 
  }
  ```
- Test if it works properly with `rc-sevice wg start` and `rc-sevice wg stop`
- Add it to the default runlevel `rc-update add wg default`

### Update alpine daily
- Create the file `/etc/periodic/daily/apkupdate` with the following content:
  ```
  #!/bin/sh
  apk -U update
  ```
 - **❗❗❗ Now you are finished with the wireguard installation and can exit the container ❗❗❗** 

  
## Install PI Hole on debian container

### Create debian container
- See [Image server for LXC and LXD](https://images.canonical.com/) to identify the latest version of debian arm container available for the arm platform of your pi. At the time I am writing this it is version buster.
- create an alpine container for pi hile `lxc launch -p default -p extbridge images:debian/buster pihole`
- list containers with `lxc ls`
- open a shell on the container `lxc exec pihole -- /bin/sh`
- **❗❗❗ Proceed with all following steps from this shell inside the cntainer ❗❗❗**

## Install pi hole
- To update all packages and install curl `sudo apt update && sudo apt upgrade && sudo apt install curl`
- To install pi hole `curl -sSL https://install.pi-hole.net | bash`
- To automatically update pi hole every day at 3 a.m. add update command to cron
  `crontab -e` 
  add the following line
  `0 3 * * * pihole -up`
  Reload cron configuration
  `service cron reload`

## Activate debian unattended security updates
- Install unattended updates (upgrades) `sudo apt-get install unattended-upgrades && sudo apt install apt-listchanges`
- Change the following configuration parameters in `/etc/apt/apt.conf.d/50unattended-upgrades`
  - Enable autotic reboot
    ```
    Unattended-Upgrade::Automatic-Reboot "true";
    ```
  - If you want cange reboot time to a cnvenient time
    ```
    Unattended-Upgrade::Automatic-Reboot-Time "02:00";
    ```
- Do a dryrun to see if it works `sudo unattended-upgrades --dry-run --debug`
- **❗❗❗ Now you are finished with the pi hole installation and can exit the container ❗❗❗**


## Other Links
 
- https://linuxcontainers.org/lxd/docs/master/
- http://www.makikiweb.com/Pi/lxc_on_the_pi.html
- https://nixvsevil.com/posts/wireguard-in-proxmox-lxc/
- https://www.wireguard.com/install/
- https://wiki.alpinelinux.org/wiki/Configure_a_Wireguard_interface_(wg)
- https://ubuntu.com/appliance/lxd/raspberry-pi#windows
- https://gitlab.com/yvelon/pi-hole


