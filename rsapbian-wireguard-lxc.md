# Running wireguard in an alpine lxc cntainer on a raspberry pi with automatic security updates



```
 +--------------------+
 |  container running |
 |  Alpine and        |
 |  wireguard server  |
 +--------------------+
 +------------------------------------------------------+
 | Raspbian with                                        |
 |   - automatic securiy updates configured             |
 |   - wireguard kernel module loaded during boot       |
 |   - lxd / lxc container host/server                  |
 +------------------------------------------------------+
 +------------------------------------------------------+
 |              Raspberry PI hardware                   |
 +------------------------------------------------------+
```

#### Table of Contents  
- [Running wireguard in an alpine lxc cntainer on a raspberry pi with automatic security updates](#running-wireguard-in-an-alpine-lxc-cntainer-on-a-raspberry-pi-with-automatic-security-updates)
  * [Raspbian installation and configration](#raspbian-installation-and-configration)
    + [Raspbian os installation](#raspbian-os-installation)
    + [Raspbian load wireguard kernel modules](#raspbian-load-wireguard-kernel-modules)
    + [Raspbian unattended updates](#raspbian-unattended-updates)
    + [Raspbian lxclxd installation](#raspbian-lxclxd-installation)
    + [Raspbian network bridge configuration](#raspbian-network-bridge-configuration)
  * [Alpine container installation and configuration](#alpine-container-installation-and-configuration)
- [Other Links](#other-links)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


## Raspbian installation and configration

### Raspbian os installation
- Download latest raspbian https://www.raspberrypi.com/software/operating-systems/
- Flash it to the SD card
- Enable ssh by writing a file named <code>ssh</code> on the SD card (do not use .ssh)
- Put SD card in your pi and power on
- login via ssh with default <code>user:pi pw:raspberry</code>
- Change hostname according to your needs <code>sudo raspi-config</code>
- Add a new user <code>sudo adduser yournewuser</code>
- Add the new user to sudo group <code>sudo usermod -aG sudo yournewuser</code>
- reboot pi <code>sudo reboot</code>
- login with your new user <code>ssh yournewuser@yourhostname</code>
- Try if sudo works with your new use e.g. <code>sudo apt-get update</code>
- Remove default pi user <code>sudo deluser -remove-home pi</code>
- to avoid yournewuser has to always type the password for sudo do:
    - <code>sudo chmod 640 /ets/sudoers.d/010_yournewuser-nopasswd</code>
    - replace <code>pi</code> with <code>yournewusername</code> in the file <code>/ets/sudoers.d/010_yournewuser-nopasswd</code>
    - <code>sudo chmod 440 /ets/sudoers.d/010_yournewuser-nopasswd</code>

### Raspbian load wireguard kernel modules
- To automatically load wireguard module during boot add one line with <code>wireguard</code> to <code>/etc/modules-load.d/modules.conf</code>. This is required, since all lxc containers use kernel and kernel modules from the host.

### Raspbian unattended updates
- Install unattended updates (upgrades) <code>sudo apt-get install unattended-upgrades && sudo apt install apt-listchanges</code>
- Change the following configuration parameters in <code>/etc/apt/apt.conf.d/50unattended-upgrades</code>
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
- Change the following configuration parameters in <code>/etc/apt/apt.conf.d/50unattended-upgrades</code>
    Add the following two lines to the configuration file (keep the exiisting ones!
    ```
    APT::Periodic::Download-Upgradeable-Packages "1"; 
    APT::Periodic::AutocleanInterval "7";
    ```
- Do a dryrun to see if it works <code>sudo unattended-upgrades --dry-run --debug</code>

### Raspbian lxclxd installation
-  Install lxc/lxd:
    - <code>sudo apt-get install snapd  bridge-utils</code>
    - <code>sudo snap install core lxd</code>
    - <code>sudo usermod -aG lxd yournewuser</code>
    - <code>lxd init</code>

### Raspbian network bridge configuration
- configure transparent bridge (see http://www.makikiweb.com/Pi/lxc_on_the_pi.html) ==> setting up an external bridge interface on the Host
    - sudo apt-get install bridge-utils ifupdown
    - ...

Create a profile for the external transparent bridge (br0)


## Alpine container installation and configuration

dsatfasdfasdf

# Other Links
 
https://linuxcontainers.org/lxd/docs/master/

https://nixvsevil.com/posts/wireguard-in-proxmox-lxc/

https://www.wireguard.com/install/

https://wiki.alpinelinux.org/wiki/Configure_a_Wireguard_interface_(wg)

https://ubuntu.com/appliance/lxd/raspberry-pi#windows


