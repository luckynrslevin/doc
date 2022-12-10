# Apple iPhone/iPad (iOS) shortcut to start your portafilter coffee machine and set your alarm in 15 minutes when it's heated up
It took me quite some time to figure out how I could setup an alarm via siri in 15 minutes from now, therefore I am going to document this here.
Switching on and off the coffee machine was quite easy to realize.

## Prerequisites
 - A portafilter coffee machine :smirk:
 - A smart plug supporting apple homekit (I use [Eve Enegry plug](https://www.evehome.com/en/eve-energy))
 - An iphone
 - Smart plug is configured and already works to switch on and off your coffee machine from your iPhone

## Apple shortcuts user documentation
- Maybe helpful to figure out some stuff: https://support.apple.com/en-en/guide/shortcuts/welcome/ios

## Install shortcut
- open apple shortcut app on your iphone
- Type`homekit`in the search field, will show your configured home locations, choose the apropriate and navigate to the smart plug of your coffee machine. Switch it on and add this step to your shortcuts.
- Type `date`in the search field and add the __Date__ item sowing up in the list, should be the first item. It should be automatically aded with the current date (and time).
- Type `date`in the search field again and now ad the __Adjust Date__ item from the list. Within the item configure the delay from now (in my case my portafilter machine needs roughly 15 minutes to heat up) and add the item.
- Type `alarm` in the search field and now add the __Crete Alarm Clock__ item from the list. You can choose a name fot the alarm, e.g. coffee. An it should automatically use the date you prepared before.
- Now it should already work as expected. However, if you want a spoken reply you can add
-  A `Text` item with the message you want to provide, e.g. __The coffee machine is switched on and your alarm in 15 minutes is set__
-  To output this text you need to add a __speak text__ item. I assume by now you know how to find it and do it.
