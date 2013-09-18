# Zephyros

> As Odysseus climbed onto the shore, he opened up his MBP and began to write an email to a mailing list about how terrible his adventure had been, and how he'd almost been drowned by the sea, and how beautiful yet deadly was the sound of the Sirens.
>
> But, noticing how his windows were all in disarray, overlapping one another and terribly sized, he opened Zephyros. Using a little black-Ruby-magic, he tweaked his configs. Then he swiftly began arranging his windows using only his keyboard.
>
> The subjects of the local kingdom, noticing the elegant gracefulness with which he resized and repositioned his Mac windows, set out to make him their king. Even the mighty king of that land, two hundred years old yet stronger than any other, had decided to abdicate his throne for the sake of Odysseus. For he had learned of this foreigner's magnificent configs.
>
> But before the people could approach him, he sensed in himself their plan, so he set out for his home country to reclaim his dear wife Penelope. Yet even so, not without first pushing his config changes to his github repo for all to benefit from. And, being of such noble blood, he even contributed some of his ideas and configs to the Zephyros wiki for the sake of all.
> - The Odyssey

### About Zephyros

*The OS X window manager for hackers*

* Current version: **5.2**
* Requires: OS X 10.7 and up
* Download: get [.zip file](https://raw.github.com/sdegutis/zephyros/master/Builds/Zephyros-LATEST.app.tar.gz), unzip, right-click app, choose "Open"

#### Basics

At it's core, Zephyros just runs quietly in your menu bar, and listens for your script.

You typically write a script that binds global hot keys to do stuff, like moving or resizing windows.

#### Stuff you can do

- register for callbacks on global hotkeys
- find the focused window
- determine window sizes and positions
- move and resize windows
- change focus to a given window
- listen to global events (window created, app launched/killed, etc)
- transfer focus to the closest window in a given direction
- run shell scripts
- open apps, links, or files
- get free pizza (okay not really)
- and more!

#### Some languages you can use

- [Using Clojure](Docs/Clojure.md)
- [Using Ruby](Docs/Ruby.md)
- [Using Python](Docs/Python.md)
- [Using Go](Docs/Go.md)
- [Using JavaScript](Docs/JavaScript.md)
- [Using CoffeeScript](Docs/CoffeeScript.md)
- [Using Node.js](https://github.com/danielepolencic/zephyros)
- [Using CHICKEN Scheme](Docs/Scheme.md)

**Note:** all the languages use the same simple [underlying protocol](Docs/Protocol.md).

* The [wiki home page](https://github.com/sdegutis/zephyros/wiki) has other people's configs, configs that emulate apps, and useful tricks

#### Frequently Asked Questions

1. How does Zephyros compare to Slate?

   Zephyros was originally a fork of Slate, but was rewritten for
   performance and stability improvements, and flexibility. One
   benefit is that Zephyros can be scripted in many languages, whereas
   Slate can only be scripted in JavaScript. Zephyros has a few more
   API calls and listen-able events, but lacks a few of Slate's
   GUI-specific features.

2. How does Zephyros compare to Spectacle / Divvy / SizeUp / Moom / AppGrid / etc?

   Zephyros just gives you an API which you can use to build up your
   own functionality for managing your windows however you'd
   like. Your script can be as minimal or as complex as you want,
   since it's really just a program written in your favorite language
   that controls Zephyros. Also, Zephyros is free, open source, and
   actively maintained. Some of the alternatives are neither.

3. Isn't it inefficient to have two processes running all the time?

   Nope. Compare
   [Chrome's usage after opening one window](https://raw.github.com/sdegutis/zephyros/master/Graphics/chrome-usage.png)
   and
   [Zephyros's usage after moving some windows around](https://raw.github.com/sdegutis/zephyros/master/Graphics/zephyros-usage.png).

### Change log

[Moved here.](change-log.txt)

### Special Thanks

- To [pd](https://github.com/pd), for all the great ideas and help in the beginning
- To [muescha](https://github.com/muescha), for the constant flow of feature requests, pull requests, and bug reports
- To [danielepolencic](https://github.com/danielepolencic/), for the new menu bar icon
- To [jdiehl](https://github.com/jdiehl/), for [his unix-sockets version of CocoaAsyncSocket](https://github.com/jdiehl/CocoaAsyncSocket/tree/socketUN)
- To [richo](https://github.com/richo/), for the Chicken Scheme API
- To everyone. You're great!

### License

> Released under MIT license.
>
> Copyright (c) 2013 Steven Degutis
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
