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

* Current version: **5.0**
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

**Note:** all the languages use the same simple [underlying API](Docs/Protocol.md).

* The [wiki home page](https://github.com/sdegutis/zephyros/wiki) has other people's configs, configs that emulate apps, and useful tricks

#### Frequently Asked Questions

1. **How does Zephyros compare to Slate?**
    - They're both script-oriented and hacker-friendly.
    - It can be scripted in nearly any language. Slate can only be scripted in JavaScript.
    - It was originally a fork of Slate but was rewritten for performance and flexibility.
    - It runs your scripts out-of-process which helps it to be highly stable.
    - It has a few more events and API calls, and lacks a few of Slate's GUI-specific features.
    - It's actively maintained.
2. **How does Zephyros compare to Spectacle/Divvy/SizeUp/Moom/etc?**
    - It's meant to be scripted. It has a very minimal UI, but a full-featured API.
    - It's free and open source. Some of the alternatives are neither.
3. **Isn't it inefficient to have two processes running all the time?**
    - No.
4. **Okay, but isn't it inefficient to have them communicating over unix domain sockets?**
    - No.
5. **Are you sure?**
    - Yes.

### Community

- #zephyros on irc.freenode.org

### Change log

- HEAD
    - Performance improvements
    - Simplifid Zephyros-protocol a little bit
- 5.0
    - Added protocol-level support for Unix sockets, making it the default
    - Converted all built-in APIs (except Clojure) to connect via the unix socket
    - Adds `unlisten` method to all APIs
    - Adds `modifiers_changed` event to all APIs
    - Adds `retain` and `release` methods, to keep a handle on a resource for as long as you want (i.e. between callbacks)
- 4.5.2
    - Added 'focus_changed' event to all APIs
    - Now only keeps (or (get-user-default "MAX_LOGS") 1000) logs
    - Now only pops up log window for error
    - New menubar icon, courtesy of [danielepolencic](https://github.com/danielepolencic/)
    - New app icon based on the new menubar icon
    - Removes that lame meme joke
- 4.5.1
    - More resilient to script errors
    - Added `screen.rotate_to` to all APIs
    - Various fixes and improvements
- 4.5
    - Added `zepl` tool for communicating with Zephyros via plain JSON
        - Use it with `rlwrap` (from homebrew) for best results
    - Several UI improvements
    - Added `show_box(str)` and `hide_box` to all APIs
    - Added `mouse_moved` listenable-event
    - Better API error-reporting
    - Makes sure auto-launched process dies when Zephyros exits
- 4.4.1
    - Ruby API handles UTF-8 strings properly
- 4.4
    - Changed Go API to just use top-level functions for API
    - Ruby API now works with Ruby 1.8
    - Adds `unbind` to all APIs
    - Changed Log window to be always-on-top
    - Log window shows seconds in timestamp
- 4.3
    - Many bug fixes and improvements
    - Added `window.other_windows_on_same_screen` and `window.other_windows_on_all_screens` to all APIs
    - Added `window.windows_to_{south,north,east,west}` to all APIs
    - Added `update_settings` to all APIs
- 4.2
    - Includes new Python API
- 4.1
    - Re-adds JavaScript/CoffeeScript API
    - Adds support for dvorak and other keyboard layouts (thanks jballanc)
    - Only listens for clients on localhost
    - Many improvements and stability fixes
- 4.0
    - Removes JavaScript/CoffeeScript API (re-added in 4.1)
    - Includes new Clojure API
    - Includes new Go API
    - Adds support for any language that can speak JSON over TCP
    - Slight changes to Ruby API
- 3.1
    - Added a fuzzy-matching `choose_from` method to the Ruby API (it's pretty sweet)
- 3.0
    - Added a Ruby 2.0 API
    - Changed JS API:
        - any function that returned a CGRect now returns a hash, keys `'x', 'y', 'w', 'h'`
        - any function that returned a CGPoint now returns a hash, keys `'x', 'y'`
        - any function that returned a CGSize now returns a hash, keys `'w', 'h'`
        - adds functions `SDMinX`, `SDMinY`, `SDMaxX`, `SDMaxY`, `SDRectMake`, `SDInsetRect`, `SDIntegralRect`
- 2.7
    - Broke the Log window's REPL (fixed in 3.0)
    - Less dumb way of choosing configs (uses UI this time)
    - Added a non-functioning Ruby option
- 2.6.1
    - Added 'screens_changed' event
- 2.6
    - First version anyone should care about

### Special Thanks

- To [pd](https://github.com/pd), for all the great ideas and help in the beginning
- To [muescha](https://github.com/muescha), for the constant flow of feature requests, pull requests, and bug reports
- To [danielepolencic](https://github.com/danielepolencic/), for the new menu bar icon
- To [jdiehl](https://github.com/jdiehl/), for [his unix-sockets version of CocoaAsyncSocket](https://github.com/jdiehl/CocoaAsyncSocket/tree/socketUN)
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
