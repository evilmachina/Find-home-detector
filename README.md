Find home detector - LilyPad Arduino
---


The Find home detector is a device to show me the way home by indicating the direction with a light. It uses a LilyPad, GPS, compass and some LEDs. Using the GPS to get a position and then calculate the direction to the location of my home. The compass is then used to get my heading so it is possible to indicate the direction I should travel.

http://www.slickstreamer.info/2011/02/find-home-detector-lilypad-arduino.html


Hardware:

* LilyPad Arduino
* GPS Micro-Mini - http://www.sparkfun.com/products/8936
* Compass Module with Tilt Compensation - http://www.sparkfun.com/products/8656
* LEDs to indicate direction
* Conductive thread

Software librarys:

* TinyGPS by Mikal Hart  - http://arduiniana.org/libraries/tinygps/
* NewSoftSerial by Mikal Hart - http://arduiniana.org/libraries/newsoftserial/
* Wire for I2C communication with the compass - http://www.arduino.cc/en/Reference/Wire


Finde home detector by Marcus Olsson is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=macke&url=https://github.com/evilmachina/Find-home-detector&title=Find-home-detector&language=en_GB&tags=github&category=software)