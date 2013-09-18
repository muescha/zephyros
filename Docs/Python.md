## Zephyros - Python API

#### Sample Script

```python
import sys
sys.path.insert(0, '/Applications/Zephyros.app/Contents/Resources/libs/')
import zephyros

@zephyros.zephyros
def myscript():
    def nudge_window():
        win = zephyros.api.focused_window()
        f = win.frame()
        f.x += 3
        win.set_frame(f)

    def show_window_title():
        zephyros.api.alert(zephyros.api.focused_window().title())

    zephyros.api.bind('D', ['Cmd', 'Shift'], show_window_title)
    zephyros.api.bind('F', ['Cmd', 'Shift'], nudge_window)
```

#### Run

```bash
python path/to/my-script.py
```

#### API

```python
class Resource(Proxy):
    # These methods must be used when you want to keep a refernce around longer than a single callback.
    # Retain increments the retain-count and release decrements it. When it reaches 0, it will be garbage-collected after 5 seconds.
    # When you first get a resource back, it starts with a retain-count of 0.
    def retain(self)
    def release(self)

class Rect(object):
    def __init__(self, x=0, y=0, w=0, h=0):
        self.x = x
        self.y = y
        self.w = w
        self.h = h

class Point(object):
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

class Size(object):
    def __init__(self, w=0, h=0):
        self.w = w
        self.h = h

class Window(Resource):
    def title(self)
    def frame(self)
    def top_left(self)
    def size(self)
    def set_frame(self, f)
    def set_top_left(self, tl)
    def set_size(self, s)
    def maximize(self)
    def minimize(self)
    def un_minimize(self)
    def app(self)
    def screen(self)
    def focus_window(self)
    def focus_window_left(self)
    def focus_window_right(self)
    def focus_window_up(self)
    def focus_window_down(self)
    def windows_to_north(self)
    def windows_to_south(self)
    def windows_to_east(self)
    def windows_to_west(self)
    def normal_window(self)
    def minimized(self)
    def other_windows_on_same_screen(self)
    def other_windows_on_all_screens(self)

class Screen(Resource):
    def frame_including_dock_and_menu(self)
    def frame_without_dock_or_menu(self)
    def previous_screen(self)
    def next_screen(self)
    def rotate_to(self, degrees)  # degree only: 0,90,180, or 270

class App(Resource):
    def visible_windows(self)
    def all_windows(self)
    def title(self)
    def hidden(self)
    def show(self)
    def hide(self)
    def kill(self)
    def kill9(self)

class Api(Proxy):
    def alert(self, msg, duration=1)
    def log(self, msg)
    def show_box(self, msg)
    def hide_box(self)
    def relaunch_config(self)
    def clipboard_contents(self)
    def focused_window(self)
    def visible_windows(self)
    def all_windows(self)
    def main_screen(self)
    def all_screens(self)
    def running_apps(self)
    def bind(self, key, mods, fn)  # see note below
    def unbind(self, key, mods)    # see note below
    def choose_from(self, lst, title, lines, chars, fn)
    def update_settings(self, s) # dict with key 'alert_should_animate' (bool) and/or 'alert_default_delay' (number)
    def unlisten(self, event)
    def undo(self)
    def redo(self)
    def listen(self, event, fn):
        def tmp_fn(obj):
            if event == "window_created":       fn(Window(obj))
            elif event == "window_minimized":   fn(Window(obj))
            elif event == "window_unminimized": fn(Window(obj))
            elif event == "window_moved":       fn(Window(obj))
            elif event == "window_resized":     fn(Window(obj))
            elif event == "app_launched":       fn(App(obj))
            elif event == "app_died":           fn(App(obj))
            elif event == "app_hidden":         fn(App(obj))
            elif event == "app_shown":          fn(App(obj))
            elif event == "screens_changed":    fn()
            elif event == "mouse_moved":        fn(movement)  # see Protocol.md for details
            elif event == "modifiers_changed":  fn(movement)  # see Protocol.md for details
        zeph.send_message([0, 'listen', event], callback=tmp_fn)

api = Api(0)
```

The function `bind` and `unbind` uses this [key strings and modifiers](https://github.com/sdegutis/zephyros/blob/master/Zephyros/SDKeyBindingTranslator.m#L148).
