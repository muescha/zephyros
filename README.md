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

* Current version: **4.5.1**
* Requires: OS X 10.8 and up
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

#### API

All languages use the same [API](Docs/Protocol.md).

#### Some languages you can use

- [Using Clojure](Docs/Clojure.md)
- [Using Ruby](Docs/Ruby.md)
- [Using Python](Docs/Python.md)
- [Using Go](Docs/Go.md)
- [Using JavaScript](Docs/JavaScript.md)
- [Using CoffeeScript](Docs/CoffeeScript.md)

Don't see your favorite language here? See the [using other languages](#using-other-languages) section.

### Example Configs

#### Ruby [(docs)](Docs/Ruby.md)

```ruby
require '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.rb'

# push to top half of screen
API.bind "K", ["cmd", "alt", "ctrl"] do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.h /= 2
  win.frame = frame
end

wait_on_callbacks
```

#### Clojure [(docs)](Docs/Clojure.md)

```clojure
(use '[leiningen.exec :only (deps)])
(deps '[[org.clojure/data.json "0.2.2"]])

(load-file "/Applications/Zephyros.app/Contents/Resources/libs/zephyros.clj")

(bind "D" ["Cmd" "Shift"]
      (fn []
        (alert "hello world" 1)
        (let [win (get-focused-window)
              f (get-frame win)
              f (update-in f [:x] + 10)]
          (set-frame win f))))

@listen-for-callbacks ;; necessary when you use (bind) or (listen)
```

#### Python [(docs)](Docs/Python.md)

```python
import sys
sys.path.insert(0, '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.py')
import zephyros

@zephyros.zephyros
def myscript():
    def nudge_window():
        win = zephyros.api.focused_window()
        f = win.frame()
        f.x += 10
        win.set_frame(f)

    def show_window_title():
        zephyros.api.alert(zephyros.api.focused_window().title())

    zephyros.api.bind('D', ['Cmd', 'Shift'], show_window_title)
    zephyros.api.bind('F', ['Cmd', 'Shift'], nudge_window)
```

#### Go [(docs)](Docs/Go.md)

```go
package main

import (
	. "../../Applications/Zephyros.app/Contents/Resources/libs/zephyros_go"
)

func main() {
    Bind("D", []string{"Cmd", "Shift"}, func() {
        Alert("hello world", 1)
        win := FocusedWindow()
        frame := win.Frame()
        frame.X += 10
        win.SetFrame(frame)
    })

    ListenForCallbacks()
}
```

#### JavaScript / CoffeeScript [(docs)](Docs/JavaScript.md)

```ruby
bind("D", ["cmd", "shift"], function() {
  var win = api.focusedWindow()
  frame = win.frame()
  frame.x += 10
  win.setFrame(frame)
})
```

#### Using other languages

You can script Zephyros from nearly any language. Just write a client that talks to Zephyros using [this simple protocol](#api).

Here's what people are working on:

- node.js (see [issue 17](../../issues/17))

If you want to do one, please [open an issue](https://github.com/sdegutis/zephyros/issues/new) so we can coordinate. That way nobody does extra work.

#### More configs

* [The author's config](https://github.com/sdegutis/dotfiles/blob/master/stuff/zeph.rb)
* Look in the [wiki home page](https://github.com/sdegutis/zephyros/wiki) for other people's configs (including a SizeUp emulator)

### Community

- #zephyros on irc.freenode.org

### Change log

**NOTE:** This auto-updater won't work if you're on version 3.x or 2.x due to [this securty fix](https://github.com/sdegutis/zephyros/pull/21).<br>[Download Zephyros-4.5.zip](https://raw.github.com/sdegutis/zephyros/master/Builds/Zephyros-LATEST.app.tar.gz) directly instead.

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

### Help Needed

Are you good at stuff? We could use these things:

* Better app icon
* Better menu bar icon

### Special Thanks

- To everyone.
    - You're great!

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
