wdp_1.3.0
=========
03/04/2014
### how to use
Once you have installed Haxe and Openfl and the required library, build a cpp version with this command **lime build cpp** then go to the output bin directory and run the server part for example on OSX:

`** open wonderpad_1.3.0.app/ --args 127.0.0.1 9000** `

this will start the server process on local port 9000.

Then you can run the client part by issuing this command: 

`**lime test neko**.`

If every thing is OK you should see the drawing mirroring on the server screen while you draw on the first screen.

> The actual source code is a little messy for the moment since this code was started at the time of NME. I'm doing some clean up for the moment so don't be surprise (well you can if you want!)

### Made width
This application is made width Haxe Openfl language and framework. It is intended to work on any platform (tested on Linux, Window, OSX, android for the moment).
You can test online the previous version at : [http://www.decatime.org/wp1/wonderpad.html](http://www.decatime.org/wp1/wonderpad.html)

![https://github.com/vicolachips44/wdp_1.3.0/blob/master/wdp_1.3.0.png](https://github.com/vicolachips44/wdp_1.3.0/blob/master/wdp_1.3.0.png)
### How to run
You'll need to install Haxe and than Openfl. to get you up and running go there: [https://github.com/openfl/openfl](openfl github repo)

After that you can either run
- lime test neko
- lime test cpp

### What is this anyway ?
This is a LAB application. It's not finished and it might never be! It has some bugs for sure!

The underlying idea around this application is to make a collaborative drawing application. I've been stuck at the moment to the lack of capabilities related to the TextField component but you'll never now openfl team might fix it someday :)

if you wan't to get in touch you can join me at vga@decatime.org.
