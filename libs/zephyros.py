import socket
import threading
import json
import Queue
import sys
import time
import atexit
import itertools

def run_in_background(fn):
    t = threading.Thread(target=fn)
    t.daemon = True
    t.start()

class ZephClient(object):
    def start(self):
        try:
            self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self.sock.connect('/tmp/zephyros.sock')
        except:
            print "Can't connect. Is Zephyros running?"
            sys.exit(1)
        self.raw_message_queue = Queue.Queue(10) # read_forever, dispatch_individual_messages_forever
        self.reified_msg_id_gen = itertools.count() # send_message
        self.send_data_queue = Queue.Queue(10) # send_message, send_data_fully
        self.individual_message_queues = {} # send_message, dispatch_individual_messages_forever
        run_in_background(self.read_forever)
        run_in_background(self.send_data_fully)
        run_in_background(self.dispatch_individual_messages_forever)

    def read_forever(self):
        try:
            while True:
                data = ''
                while True:
                    in_str = self.sock.recv(1)
                    if in_str == '\n':
                        break
                    if in_str == '':
                        raise RuntimeError("socket connection broken")
                    data += in_str

                obj = json.loads(data)
                self.raw_message_queue.put(obj)
        except RuntimeError:
            pass

    def send_data_fully(self):
        while True:
            data = self.send_data_queue.get()
            while len(data) > 0:
                num_wrote = self.sock.send(data)
                data = data[num_wrote:]

    def send_message(self, msg, infinite=True, callback=None):
        msg_id = self.reified_msg_id_gen.next()
        temp_send_queue = Queue.Queue(10)
        self.individual_message_queues[msg_id] = temp_send_queue

        msg.insert(0, msg_id)
        msg_str = json.dumps(msg)
        self.send_data_queue.put(msg_str + '\n')

        if callback is not None:
            def temp_fn():
                temp_send_queue.get() # ignore first
                if infinite:
                    while True:
                        obj = temp_send_queue.get()
                        callback(obj[1])
                else:
                    obj = temp_send_queue.get()
                    callback(obj[1])
            run_in_background(temp_fn)
            return None
        else:
            return temp_send_queue.get()[1]

    def dispatch_individual_messages_forever(self):
        while True:
            msg = self.raw_message_queue.get()
            msg_id = msg[0]
            this_queue = self.individual_message_queues[msg_id]
            this_queue.put(msg)


zeph = ZephClient()


def zephyros(fn):
    zeph.start()
    run_in_background(fn)
    try:
        while True: time.sleep(5)
    except KeyboardInterrupt:
        pass


class Rect(object):
    def to_dict(r): return {'x': r.x, 'y': r.y, 'w': r.w, 'h': r.h}
    def __init__(self, x=0, y=0, w=0, h=0):
        self.x = x
        self.y = y
        self.w = w
        self.h = h

    def inset(self, x, y):
        self.x += x
        self.y += y
        self.w -= (x * 2)
        self.h -= (y * 2)

class Point(object):
    def to_dict(r): return {'x': r.x, 'y': r.y}
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

class Size(object):
    def to_dict(r): return {'w': r.w, 'h': r.h}
    def __init__(self, w=0, h=0):
        self.w = w
        self.h = h

class Proxy(object):
    def __init__(self, id): self.id = id
    def _send_sync(self, *args): return zeph.send_message([self.id] + list(args))

class Window(Proxy):
    def title(self): return self._send_sync('title')
    def frame(self): return Rect(**self._send_sync('frame'))
    def top_left(self): return Point(**self._send_sync('top_left'))
    def size(self): return Size(**self._send_sync('size'))
    def set_frame(self, f): self._send_sync('set_frame', f.to_dict())
    def set_top_left(self, tl): return self._send_sync('set_top_left', tl.to_dict())
    def set_size(self, s): return self._send_sync('set_size', s.to_dict())
    def maximize(self): return self._send_sync('maximize')
    def minimize(self): return self._send_sync('minimize')
    def un_minimize(self): return self._send_sync('un_minimize')
    def app(self): return App(self._send_sync('app'))
    def screen(self): return Screen(self._send_sync('screen'))
    def focus_window(self): return self._send_sync('focus_window')
    def focus_window_left(self): return self._send_sync('focus_window_left')
    def focus_window_right(self): return self._send_sync('focus_window_right')
    def focus_window_up(self): return self._send_sync('focus_window_up')
    def focus_window_down(self): return self._send_sync('focus_window_down')
    def windows_to_north(self): return self._send_sync('windows_to_north')
    def windows_to_south(self): return self._send_sync('windows_to_south')
    def windows_to_east(self): return self._send_sync('windows_to_east')
    def windows_to_west(self): return self._send_sync('windows_to_west')
    def normal_window(self): return self._send_sync('normal_window?')
    def minimized(self): return self._send_sync('minimized?')
    def other_windows_on_same_screen(self): return [Window(x) for x in  self._send_sync('other_windows_on_same_screen')]
    def other_windows_on_all_screens(self): return [Window(x) for x in  self._send_sync('other_windows_on_all_screens')]

class Screen(Proxy):
    def frame_including_dock_and_menu(self): return Rect(**self._send_sync("frame_including_dock_and_menu"))
    def frame_without_dock_or_menu(self): return Rect(**self._send_sync("frame_without_dock_or_menu"))
    def previous_screen(self): return Screen(self._send_sync("previous_screen"))
    def next_screen(self): return Screen(self._send_sync("next_screen"))
    def rotate_to(self, degrees): return self._send_sync("rotate_to", degrees)

class App(Proxy):
    def visible_windows(self): return [Window(x) for x in  self._send_sync("visible_windows")]
    def all_windows(self): return [Window(x) for x in  self._send_sync("all_windows")]
    def title(self): return self._send_sync("title")
    def hidden(self): return self._send_sync("hidden?")
    def show(self): return self._send_sync("show")
    def hide(self): return self._send_sync("hide")
    def kill(self): return self._send_sync("kill")
    def kill9(self): return self._send_sync("kill9")

class Api(Proxy):
    def alert(self, msg, duration=None): self._send_sync('alert', msg, duration)
    def log(self, msg): self._send_sync('log', msg)
    def show_box(self, msg): self._send_sync('show_box', msg)
    def hide_box(self): self._send_sync('hide_box')
    def unbind(self, key, mods): self._send_sync('unbind', key, mods)
    def update_settings(self, new_settings): self._send_sync('update_settings', new_settings)
    def relaunch_config(self): self._send_sync('relaunch_config')
    def clipboard_contents(self): return self._send_sync('clipboard_contents')
    def focused_window(self): return Window(self._send_sync('focused_window'))
    def visible_windows(self): return [Window(x) for x in  self._send_sync('visible_windows')]
    def all_windows(self): return [Window(x) for x in  self._send_sync('all_windows')]
    def main_screen(self): return Screen(self._send_sync('main_screen'))
    def all_screens(self): return [Screen(x) for x in  self._send_sync('all_screens')]
    def running_apps(self): return [App(x) for x in  self._send_sync('running_apps')]
    def bind(self, key, mods, fn):
        def tmp_fn(obj): fn()
        zeph.send_message([self.id, 'bind', key, mods], callback=tmp_fn)
    def choose_from(self, lst, title, lines, chars, fn):
        zeph.send_message([self.id, 'choose_from', lst, title, lines, chars], callback=fn, infinite=False)
    def unlisten(self, event): self._send_sync('unlisten', event)
    def listen(self, event, fn):
        def tmp_fn(obj):
            if event == "window_created":       fn(Window(obj))
            elif event == "window_minimized":   fn(Window(obj))
            elif event == "window_unminimized": fn(Window(obj))
            elif event == "window_moved":       fn(Window(obj))
            elif event == "window_resized":     fn(Window(obj))
            elif event == "focus_changed":      fn(Window(obj))
            elif event == "app_launched":       fn(App(obj))
            elif event == "app_died":           fn(App(obj))
            elif event == "app_hidden":         fn(App(obj))
            elif event == "app_shown":          fn(App(obj))
            elif event == "screens_changed":    fn()
            elif event == "mouse_moved":        fn(obj)
            elif event == "modifiers_changed":  fn(obj)
        zeph.send_message([self.id, 'listen', event], callback=tmp_fn)

api = Api(None)
