# Howto build and run shairport-sync on tiny core linux

## The why?

Why would we want to build shairport sync on tiny core linux for raspberry pi? There are a lot of music player solutions on raspberry PI that already integrate and therefore offer shairport-sync capabilities.

For me there are mainly two reasons:
1) I only need shairport sync, the other features offered by many music player solutions are not necessary for me, because I only want to stream music from apple devices to my stereo.
2) I want to power off the raspberry pi without halting the linux system and avoid causing any harm to the internal SD card. Since tiny core linux is completely running in ram, it's the perfect solution.


## What do I need?

- An 64bit capable RPI, I use RPI3
- SDCard
- LAN cable to connect to your network
- Sufficient power supply (best use original RPI power supplys to make sure not to face low voltage situations)
- An Audio DAC supported by the Linux kernel, in my case I use a HifiBerry DAC. You could use the standard audio output of the RPI.
- An Audio cable to connect to your stereo (chinch <-> chinch, or 3,5 mm jack <-> chinch, or whatever meets your setup)
- Some Linux know how (familiar with command line, editing files, ...)

## How?

### Download and install tiny core linux

Download Tiny Core Linux and flash it to your SD Card.
I used piCore 14.1.0 http://tinycorelinux.net/14.x/armv6/releases/RPi/
I use balena etcher for this, you can use whatever üprocess is convenient for you.

### Edit config.txt
In case you use an external DAC, you maybe need to edit the config.txt. Mount the SDCard on your laptop computer and edit the config.txt file.
In my case I needed to deactivate the local audio and activate the HifiBerry DAC according to this manual https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/ by:
```
# Deactivate
#dtparam=audio=on

# Add
dtoverlay=hifiberry-dac
```

### Booting rpi for the first time
Put the sd card in your rpi and boot up your rpi. Make sure it's connected to your network.
Try to find the IP adress it was assigned by your DHCP server in your LAN. Typically somewhere on your router web interface there is also a page where you can see devices in the network and related IP addresses.

### Connect via ssh
Now you should be able to connect to your rpi via ssh from your laptop.
```
ssh tc@<your rpi ip address>
```
You will need to accept ssh fingerprint to be added to your ~/.ssh/known_hosts file during the first connect.
Default password for tc user is `picore`.

After successull login you now need to:


### Extend the second partition of the sdcard
To expand the 2nd partition you first need to delete it, afterwards recreate and resize to the full (definde) extend.

__ATTENETION: Make sure to use the apropriate device to not lose any data! In my case it is mmblk0, might be the same for you. However, please make sure to replace with the proper device name in case required.__

```
sudo fdisk -u /dev/mmcblk0
```

print filesystem layout `p` and note down the StartLBA of the second partition, In my case it is __139264__.

```
Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p1    128,0,1     1023,3,16         8192     139263     131072 64.0M  c Win95 FAT32 (LBA)
/dev/mmcblk0p2    1023,3,16   1023,3,16       139264     172031      32768 16.0M 83 Linux
```
To delete and create the new partition using the whole space left on the SD card, use the following commands within fdisk:
```
d -> 2 -> p -> n -> p -> 2 -> 139264 (replace with your value in case different) -> accept default -> w
```
Reboot the system:
```
sudo reboot
```

Now you need to remove the ssh gfingerprint from you known hosts file on your laptop, becuase it will change during reboot and ssh will therefore refuse connecting.

Remove the relevant entries for the ip address from `~/.ssh/known_hosts" file on your laptop.

Afterwards again connect via ssh:
```
ssh tc@<your rpi ip address>
```
Accept the newly created fingerprint and use the default password `piCore`to login.

Now you need to resize the partition:
```
sudo resize2fs /dev/mmcblk0p2
```

### Change default password & persist new password and ssh keys
To change the password simply use `passwd` command. 

To persist changes in tiny core linux you  need to add the relevant files to the files listed in `/opt/.filetool.lst`.

Since passwd and ssh key files are already included by default, for now there is nothing to do for us.

To persist the files simply do a backup by issuing the following command:
```
filetool.sh -b
```








