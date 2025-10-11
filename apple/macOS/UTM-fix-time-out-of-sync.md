# UTM: Fix time out of sync issue when using Apple virtualization

## Issue
When running a ARM64 Linux guest using UTM and Apple virtualization on a ARM based macbook (M1, ...) closing your macbook and opening it after some time,
the time on the guest OS gets completely out of sync (continues at the time when you were closing your macbook and).

I did not yet try, but this also seems the case for running a MacOS guest.

## Solution
There are various workarounds described. However the easiest and most likely most reliable workaround is described at the bottom of this issue:
https://github.com/utmapp/UTM/issues/4644

## How to implement

Edit your /etc/chrony.conf and apply the following changes:
```
...

# Enable kernel synchronization of the real-time clock (RTC).
## Disabled due to refclock config to sync time with rtc on Apple Virtualization
##rtcsync

...

# Fix time out of sync bug running in a VM on AppleVirtualization
refclock RTC /dev/rtc0:utc poll -2
makestep 1 -1
```

Restart chronyd
```
sudo systemctl restart chronyd
```
