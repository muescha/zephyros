## Zephyros - Ruby API

#### Sample Script

```ruby
require '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.rb'

# push to top half of screen
API.bind "K", ["cmd", "alt", "ctrl"] do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.h /= 2
  win.frame = frame
end

# alert hello world
API.bind "D", ["Cmd", "Shift"] do
  API.alert 'hello world'
end

wait_on_callbacks
```

#### Run

```bash
ruby path/to/my-script.rb
```

#### API

The function `bind` and `unbind` uses this [key strings and modifiers](https://github.com/sdegutis/zephyros/blob/master/Zephyros/SDKeyBindingTranslator.m#L148).

```ruby
class API

  class << self

    def reload_config; end

    def bind(key, mods, &blk); end
    def unbind(key, mods); end

    def log(str); end
    def alert(msg, duration=2); end

    def show_box(str); end
    def hide_box; end

    def update_settings(s); # hash with key 'alert_should_animate' (bool) and/or 'alert_default_delay' (number)

    def clipboard_contents; end

    def choose_from(list, title, lines_tall, chars_wide, &blk); end
        # takes list of strings
        # blk gets index of chosen string, or nil of canceled

    def focused_window; end
    def visible_windows; end
    def all_windows; end

    def main_screen; end
    def all_screens; end

    def running_apps; end

    def undo; end
    def redo; end

    def unlisten(event); end
    def listen(event, &blk); end
        # 'window_created', callback args: (win)
        # 'window_minimized', callback args: (win)
        # 'window_unminimized', callback args: (win)
        # 'window_moved', callback args: (win)
        # 'window_resized', callback args: (win)
        # 'app_launched', callback args: (app)
        # 'app_died', callback args: (app)
        # 'app_hidden', callback args: (app)
        # 'app_shown', callback args: (app)
        # 'screens_changed', callback args: ()
        # 'mouse_moved', callback args: (movement) # see Protocol.md for details
        # 'modifiers_changed'', callback args: (movement) # see Protocol.md for details

  end

end

class Resource
  # These methods must be used when you want to keep a refernce around longer than a single callback.
  # Retain increments the retain-count and release decrements it. When it reaches 0, it will be garbage-collected after 5 seconds.
  # When you first get a resource back, it starts with a retain-count of 0.

  def retain; end
  def release; end
end

class Screen < Resource

  def frame_including_dock_and_menu; end
  def frame_without_dock_or_menu; end
  def next_screen; end
  def previous_screen; end

end

class App < Resource

  def all_windows; end
  def visible_windows; end

  def title; end
  def hidden?; end

  def show; end
  def hide; end

  def kill; end
  def kill9; end

end

$window_grid_width = 3
$window_grid_height = 2
$window_grid_margin_x = 5
$window_grid_margin_y = 5

class Window < Resource

  def other_windows_on_same_screen; end

  def frame; end # => returns a Rect
  def top_left; end # => returns a Point
  def size; end # => returns a Size

  def frame=(x); end # => takes a Rect
  def top_left=(x); end # => takes a Point
  def size=(x); end # => takes a Size

  def maximize; end
  def minimize; end
  def un_minimize; end

  def screen; end
  def app; end

  def title; end

  def focus_window; end
  def focus_window_left; end
  def focus_window_right; end
  def focus_window_up; end
  def focus_window_down; end

  def windows_to_north; end
  def windows_to_south; end
  def windows_to_west; end
  def windows_to_east; end

  def normal_window?; end
  def minimized?; end

  def get_grid; end
  def set_grid(g, screen); end

end

class Point < Struct.new(:x, :y); end

class Size < Struct.new(:w, :h); end

class Rect < Struct.new(:x, :y, :w, :h)

    def integral!; end
    def inset!; end

end
```
