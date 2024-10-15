Howto build and run shairport-sync on tiny core linux

# The why?

Why would we want to build shairport sync on tiny core linux for raspberry pi? There are a lot of music player solutions on raspberry PI that already integrate and therefore offer shairport-sync capabilities.

For me there are mainly two reasons:
1) I only need shairport sync, the other features offered by many music player solutions are not necessary for me, because I only want to stream music from apple devices to my stereo.
2) I want to power off the raspberry pi without halting the linux system and avoid causing any harm to the internal SD card. Since tiny core linux is completely running in ram, it's the perfect solution.


# What do I need?

- An 64bit capable RPI, I use RPI3
- SDCard
- LAN cable to connect to your network
- Sufficient power supply (best use original RPI power supplys to make sure not to face low voltage situations)
- An Audio DAC supported by the Linux kernel, in my case I use a HifiBerry DAC. You could use the standard audio output of the RPI.
- An Audio cable to connect to your stereo (chinch <-> chinch, or 3,5 mm jack <-> chinch, or whatever meets your setup)
- Some Linux know how (familiar with command line, editing files, ...)

# How?

## Download and install tiny core linux

Download Tiny Core Linux and flash it to your SD Card.
I used piCore 14.1.0 http://tinycorelinux.net/14.x/armv6/releases/RPi/
I use balena etcher for this, you can use whatever üprocess is convenient for you.

## Edit config.txt
In case you use an external DAC, you maybe need to edit the config.txt. Mount the SDCard on your laptop computer and edit the config.txt file.
In my case I needed to deactivate the local audio and activate the HifiBerry DAC according to this manual https://www.hifiberry.com/docs/software/configuring-linux-3-18-x/ by:
removing/commenting out "dtparam=audio=on"
adding: dtoverlay=hifiberry-dac

## Booting rpi for the first time
Put the sd card in your rpi and boot up your rpi. Make sure it's connected to your network.
Try to find the IP adress it was assigned by your DHCP server in your LAN. Typically somewhere on your router web interface there is also a page where you can see devices in the network and related IP addresses.

## Connect via ssh
Now you should be able to connect to your rpi via ssh from your laptop.
<code>ssh tc@your ip address</code>.
You will need to accept ssh fingerprint to be added to your ~/.ssh/known_hosts file during the first connect





