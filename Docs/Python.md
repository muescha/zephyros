## Zephyros - Python API

#### Setup Script

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

class Window(Proxy):
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

class Screen(Proxy):
    def frame_including_dock_and_menu(self)
    def frame_without_dock_or_menu(self)
    def previous_screen(self)
    def next_screen(self)

class App(Proxy):
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
    def bind(self, key, mods, fn)
    def unbind(self, key, mods)
    def choose_from(self, lst, title, lines, chars, fn)
    def update_settings(self, s) # dict with key 'alert_should_animate' (bool) and/or 'alert_default_delay' (number)
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
            elif event == "mouse_moved":        fn(movement)
        zeph.send_message([0, 'listen', event], callback=tmp_fn)

api = Api(0)
```
