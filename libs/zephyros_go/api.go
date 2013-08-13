package zephyros_go

import (
	"encoding/json"
	"reflect"
)


func Bind(key string, mods []string, fn func()) {
	wrapFn := func(bytes []byte) { fn() }
	send(0, wrapFn, true, "bind", key, mods)
}

func ChooseFrom(list []string, title string, linesTall int, charsWide int, fn func(i int)) {
	wrapFn := func(bytes []byte) {
		var obj *float64
		json.Unmarshal(bytes, &obj)
		if obj == nil {
			fn(-1)
		} else {
			fn(int(*obj))
		}
	}
	send(0, wrapFn, false, "choose_from", list, title, linesTall, charsWide)
}

// Function 'fn' will be called with the proper arg and
// type (or no args) depending on the event type.
//
// Valid events and their callback arguments:
//     'window_created' args: [win]
//     'window_minimized' args: [win]
//     'window_unminimized' args: [win]
//     'window_moved' args: [win]
//     'window_resized' args: [win]
//     'app_launched' args: [app]
//     'app_died' args: [app]
//     'app_hidden' args: [app]
//     'app_shown' args: [app]
//     'screens_changed' args: []
//     'mouse_moved' args: [mouseMovement]
func Listen(event string, fn interface{}) {
	fnValue := reflect.ValueOf(fn)
	fnType := fnValue.Type()

	numIn := fnType.NumIn()

	wrapFn := func(bytes []byte) {
		if numIn == 0 {
			fnValue.Call(nil)
		} else {
			inType := fnType.In(0)

			var obj float64
			json.Unmarshal(bytes, &obj)

			objValue := reflect.ValueOf(obj)
			convertedObj := objValue.Convert(inType)

			fnValue.Call([]reflect.Value{convertedObj})
		}
	}
	send(0, wrapFn, true, "listen", event)
}

func Alert(msg string, dur int) {
	send(0, nil, false, "alert", msg, dur)
}

func Unbind(key string, mods []string) {
	send(0, nil, false, "unbind", key, mods)
}

func Log(msg string) {
	send(0, nil, false, "log", msg)
}

func ShowBox(msg string) {
	send(0, nil, false, "show_box", msg)
}

func HideBox() {
	send(0, nil, false, "hide_box")
}

// Value keys are "alert_should_animate" (bool) and/or "alert_default_delay" (number)
func UpdateSettings(msg map[string]interface{}) {
	send(0, nil, false, "update_settings", msg)
}

func RelaunchConfig() {
	send(0, nil, false, "relaunch_config")
}

func ClipboardContents() string {
	var buf string
	bytes := send(0, nil, false, "clipboard_contents")
	json.Unmarshal(bytes, &buf)
	return buf
}

func FocusedWindow() Window {
	var buf Window
	bytes := send(0, nil, false, "focused_window")
	json.Unmarshal(bytes, &buf)
	return buf
}

func VisibleWindows() []Window {
	var buf []Window
	bytes := send(0, nil, false, "visible_windows")
	json.Unmarshal(bytes, &buf)
	return buf
}

func AllWindows() []Window {
	var buf []Window
	bytes := send(0, nil, false, "all_windows")
	json.Unmarshal(bytes, &buf)
	return buf
}

func MainScreen() Screen {
	var buf Screen
	bytes := send(0, nil, false, "main_screen")
	json.Unmarshal(bytes, &buf)
	return buf
}

func AllScreens() []Screen {
	var buf []Screen
	bytes := send(0, nil, false, "all_screens")
	json.Unmarshal(bytes, &buf)
	return buf
}

func RunningApps() []App {
	var buf []App
	bytes := send(0, nil, false, "running_apps")
	json.Unmarshal(bytes, &buf)
	return buf
}
