How to install wireguard on raspbian with lxc container
=======================================================
https://linuxcontainers.org/lxd/docs/master/
https://nixvsevil.com/posts/wireguard-in-proxmox-lxc/
https://www.wireguard.com/install/
https://wiki.alpinelinux.org/wiki/Configure_a_Wireguard_interface_(wg)

- Download latest raspbian https://www.raspberrypi.com/software/operating-systems/
- Flash it to the SD card
- Enable ssh by writing a file named <code>ssh</code> on the SD card (do not use .ssh)
- Put SD card in your pi and power on
- login via ssh with default <code>user:pi pw:raspberry</code>
- Update system <code>sudo apt-get update && sudo apt-get upgrade</code>
- Add a new user <code>sudo adduser yournewuser</code>
- Add the new user to sudo group <code>sudo usermod -aG sudo yournewuser</code>
- reboot pi <code>sudo reboot</code>
- login with your new user <code>ssh yournewuser@pi</code>
- Try if sudo works with your new usre e.g. <code>sudo apt-get update</code>
- Remove default pi user <code>sudo deluser -remove-home pi</code>
- to avoid yournewuser has to always type the password for sudo do:
    - <code>sudo chmod 640 /ets/sudoers.d/010_yournewuser-nopasswd</code>
    - replace pi with yournewusername in the file /ets/sudoers.d/010_yournewuser-nopasswd
    - <code>sudo chmod 440 /ets/sudoers.d/010_yournewuser-nopasswd</code>
-  Install lxc/lxd:
    - <code>sudo apt-get install snapd  bridge-utils</code>
    - <code>sudo snap install core lxd</code>
    - <code>sudo usermod -aG lxd yournewuser</code>
    - <code>lxd init</code>
- configure transparent bridge (see http://www.makikiweb.com/Pi/lxc_on_the_pi.html) ==> setting up an external bridge interface on the Host
    - sudo apt-get install bridge-utils ifupdown
    - ...

Create a profile for the external transparent bridge (br0)
 
  
