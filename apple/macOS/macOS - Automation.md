
# Mount network drives after boot
[Automatically Connect to a Network Drive on Mac OS X Start Up & Login](https://osxdaily.com/2012/05/04/automatically-connect-to-network-drive-mac-os-x/)

# Update homebrew automatically
[Auto Update Brew: OS X Launchd job and script to automatically update homebrew](https://gist.github.com/ErnHem/0db5c6d3f372166715b26331865df93a)

# Script to automatically connect and disconnect to wireguard depending on wifi connection
If you use a MacOS computer to connect to the wireguard server, you can use the [following script](wg_auto.sh) to automate connecting and disconnecting to wireguard based on your current network connection. The script will disable the wireguard connection within your home network and enable wireguard in any other network.

You can use crontab to run this automatically every 5 seconds:
`crontab -e`
```
# autostart/-stop wireguard
* * * * *     /foo/bar/bin/autostartwg.sh
 ```

