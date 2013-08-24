## Zephyros - JavaScript API

### To run:

```bash
/Applications/Zephyros.app/Contents/MacOS/zephjs myscript.js

# or

/Applications/Zephyros.app/Contents/MacOS/zephjs myscript.coffee
```

### API

* [Top Level](#top-level)
* [Type "API"](#type-api)
* [Type "Window"](#type-window)
* [Type "Screen"](#type-screen)
* [Type "App"](#type-app)
* [Other Type](#other-types)
* [Events](#events)

For your convenience, [underscore.js 1.4.4](http://underscorejs.org/) is pre-loaded.

#### Top Level


The function `bind()` and `unbind()` uses this [key strings and modifiers](https://github.com/sdegutis/zephyros/blob/master/Zephyros/SDKeyBindingTranslator.m#L148).

```coffeescript
property (API) api

- (Number) SDMinX(r) # => r.x
- (Number) SDMinY(r) # => r.y
- (Number) SDMaxX(r) # => r.x + r.w
- (Number) SDMaxY(r) # => r.y + r.h

- (Rect) SDRectMake(x, y, w, h)   # => returns new rect
- (Rect) SDInsetRect(r, byX, byY) # => modifies and returns r
- (Rect) SDIntegralRect(r)        # => modifies and returns r

- (void) showBox(String str)
- (void) hideBox()

- (void) log(String str)                   # shows up in the log window
- (void) alert(String str[, Number delay]) # shows in a fancy alert; optional delay is seconds

- (void) bind(String key,              # case-insensitive single-character string; see link below
              Array<String> modifiers, # may contain any number of: "cmd", "ctrl", "alt", "shift"
              Function fn)             # javascript fn that takes no args; return val is ignored

- (void) unbind(String key, Array<String> modifiers)

- (void) listen(String eventName, Function callback) # see Events section below
- (void) unlisten(String eventName)

- (void) chooseFrom(Array<String> list, String title, Number linesTall, Number charsWide, Function callback) # fn called with chosen idx or null if canceled

- (void) reloadConfig()

- (void) require(String path) # looks at extension to know which language to use
                              # if relative path, looks in `~/.zephyros/`

- (Hash) shell(String path, Array<String> args[, String stdin]) # returns {"stdout": string,
                                                                #          "stderr": string,
                                                                #          "status": int}

- (void) open(String thing) # can be path or URL

- (void) doAfter(Number sec, Function fn)
```


#### Type: `API`

```coffeescript
- (Array<Window>) allWindows()
- (Array<Window>) visibleWindows()
- (Window) focusedWindow()

- (Screen) mainScreen()
- (Array<Screen>) allScreens()

- (Array<App>) runningApps()

- (String) clipboardContents()
```

#### Type: `Window`

```coffeescript
- (Grid) getGrid()
- (void) setGrid(Grid g[, Screen optionalScreen])
# grids are just JS objects with keys {x,y,w,h} as numbers, 0-based index

class-property (number) Window.gridWidth # default: 4
class-property (number) Window.gridMarginX # default: 5
class-property (number) Window.gridMarginY # default: 5
# these margins are for giving window-shadows some breathing room

- (Point) topLeft()
- (Size) size()
- (Rect) frame()

- (void) setTopLeft(Point thePoint)
- (void) setSize(Size theSize)
- (void) setFrame(Rect frame)
- (void) maximize()

- (Screen) screen()
- (Array<Window>) otherWindowsOnSameScreen()
- (Array<Window>) otherWindowsOnAllScreens()

- (String) title()
- (Boolean) isWindowMinimized()

- (Boolean) isNormalWindow() # you probably want to avoid resizing/moving ones that aren't

- (App) app()

- (Boolean) focusWindow()

- (void) focusWindowLeft()
- (void) focusWindowRight()
- (void) focusWindowUp()
- (void) focusWindowDown()

- (void) windowToNorth()
- (void) windowToSouth()
- (void) windowToEast()
- (void) windowToWest()
```

#### Type: `Screen`

```coffeescript
- (Rect) frameIncludingDockAndMenu()
- (Rect) frameWithoutDockOrMenu()

- (Screen) nextScreen()
- (Screen) previousScreen()
- rotateTo (Number) degree         # only: 0,90,180, or 270
```

#### Type: `App`

```coffeescript
- (Array<Window>) allWindows()
- (Array<Window>) visibleWindows()

- (String) title()
- (Boolean) isHidden()

- (void) kill()
- (void) kill9()
```

#### Type: `Rect`

```coffeescript
property (Point) origin # top-left
property (Size) size
```

#### Type: `Size`

```coffeescript
property (Number) width
property (Number) height
```

#### Type: `Point`

```coffeescript
property (Number) x
property (Number) y
```

The rest you'll have to look up for yourself.

#### Events

```coffeescript
'window_created', callback args: (win)
'window_minimized', callback args: (win)
'window_unminimized', callback args: (win)
'window_moved', callback args: (win)
'window_resized', callback args: (win)
'app_launched', callback args: (app)
'app_died', callback args: (app)
'app_hidden', callback args: (app)
'app_shown', callback args: (app)
'screens_changed', callback args: ()
'mouse_moved', callback args: (movement) ... see Protocol.md for details
'modifiers_changed', callback args: (mods) ... see Protocol.md for details
```
