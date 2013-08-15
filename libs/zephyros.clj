(require '[clojure.data.json :as json])
(import '[java.net Socket]
        '[java.util.concurrent ArrayBlockingQueue]
        '[java.io PrintWriter InputStreamReader BufferedReader])

(def chans (ref {}))

(defmacro safely-do-in-background [& body]
  `(future
     (try
       ~@body
       (catch Exception e#
         (.printStackTrace e#)))))

(defn own-rolled-readline [in bytes-so-far]
  (let [b (.read in)]
    (if (= \newline (char b))
      (String. (byte-array (map byte bytes-so-far)) "UTF-8")
      (recur in (concat bytes-so-far [b])))))

(defn conn-handler [conn]
  (while (nil? (:exit @conn))
    (let [msg-size (Integer/parseInt (own-rolled-readline (:in @conn) []))
          msg-bytes (take msg-size (repeatedly #(let [buf (byte-array [(byte 0)])
                                                      num-read (.read (:in @conn) buf)]
                                                  ((vec buf) 0))))
          msg-str (String. (byte-array msg-bytes) "UTF-8")
          json (json/read-str msg-str)
          ;; _ (println "GOT" json)
          msg-id (json 0)
          chan (get @chans msg-id)]
      (.put chan json))))

(defn connect [server]
  (let [socket (try
                 (Socket. (:name server) (:port server))
                 (catch Exception e
                   (println "Can't connect. Is Zephyros running?")
                   (System/exit 1)))
        in (.getInputStream socket)
        out (PrintWriter. (.getOutputStream socket))
        conn (ref {:in in :out out :socket socket})]
    [(safely-do-in-background (conn-handler conn))
     conn]))

(defn write [conn msg]
  (doto (:out @conn)
    (.print msg)
    (.flush)))

(def zephyros-server {:name "localhost" :port 1235})
(def max-msg-id (atom 0))
(let [[listener tmp-conn] (connect zephyros-server)]
  (def conn tmp-conn)
  (def listen-for-callbacks listener))

(defn send-msg [args]
  (let [msg-id (swap! max-msg-id inc)
        json-str (json/write-str (concat [msg-id] args))
        ;; _ (println "SENDING" json-str)
        json-str-size (count json-str)
        chan (ArrayBlockingQueue. 10)]
    (dosync
     (alter chans assoc msg-id chan))
    (write conn (format "%s\n%s", json-str-size, json-str))
    {:kill #(dosync (alter chans dissoc msg-id))
     :get #(second (.take chan))}))

(defn get-one-value [& args]
  (let [resp (send-msg args)
        val ((:get resp))]
    ((:kill resp))
    val))

(defn do-callback-once [f & args]
  (safely-do-in-background
   (let [resp (send-msg args)
         num-times ((:get resp))
         val ((:get resp))]
     ((:kill resp))
     (f val))))

(defn do-callback-indefinitely [f & args]
  (safely-do-in-background
   (let [resp (send-msg args)]
     ((:get resp))
     (doseq [val (repeatedly (:get resp))]
       (f val)))))








(defn keywordize [m]
  (into {} (for [[k v] m]
             [(keyword k) v])))


;; top level

(def top-level-obj nil)

(defn bind [key mods f] (do-callback-indefinitely (fn [_] (f)) top-level-obj "bind" key mods))
(defn listen [event f] (do-callback-indefinitely #(f %) top-level-obj "listen" event))

(defn get-focused-window [] (get-one-value top-level-obj "focused_window"))
(defn get-visible-windows [] (get-one-value top-level-obj "visible_windows"))
(defn get-all-windows [] (get-one-value top-level-obj "all_windows"))

(defn get-main-screen [] (get-one-value top-level-obj "main_screen"))
(defn get-all-screens [] (get-one-value top-level-obj "all_screens"))

(defn get-running-apps [] (get-one-value top-level-obj "running_apps"))

(defn update-settings [s] (get-one-value top-level-obj "update_settings" s))

(defn alert
  ([msg] (alert msg nil))
  ([msg duration] (get-one-value top-level-obj "alert" msg duration)))

(defn log [msg] (get-one-value top-level-obj "log" msg))

(defn show-box [msg] (get-one-value top-level-obj "show_box" msg))
(defn hide-box [] (get-one-value top-level-obj "hide_box"))

(defn choose-from [list title f] (do-callback-once f top-level-obj "choose_from" list title 20 10))

(defn relaunch-config [] (get-one-value top-level-obj "relaunch_config"))
(defn get-clipboard-contents [] (get-one-value top-level-obj "clipboard_contents"))

(defn unbind [key mods] (get-one-value top-level-obj "unbind" key mods))


;; window

(defn get-window-title [window] (get-one-value window "title"))

(defn get-frame [window] (keywordize (get-one-value window "frame")))
(defn get-size [window] (keywordize (get-one-value window "size")))
(defn get-top-left [window] (keywordize (get-one-value window "top_left")))

(defn set-frame [window f] (get-one-value window "set_frame" f))
(defn set-size [window s] (get-one-value window "set_size" s))
(defn set-top-left [window tl] (get-one-value window "set_top_left" tl))

(defn other-windows-on-same-screen [window] (get-one-value window "other_windows_on_same_screen"))
(defn other-windows-on-all-screens [window] (get-one-value window "other_windows_on_all_screens"))

(defn windows-to-north [window] (get-one-value window "windows_to_north"))
(defn windows-to-south [window] (get-one-value window "windows_to_south"))
(defn windows-to-east [window] (get-one-value window "windows_to_east"))
(defn windows-to-west [window] (get-one-value window "windows_to_west"))

(defn minimize [window] (get-one-value window "minimize"))
(defn maximize [window] (get-one-value window "maximize"))
(defn un-minimize [window] (get-one-value window "un_minimize"))

(defn get-app-for-window [window] (get-one-value window "app"))
(defn get-screen-for-window [window] (get-one-value window "screen"))

(defn focus-window [window] (get-one-value window "focus_window"))
(defn focus-window-left [window] (get-one-value window "focus_window_left"))
(defn focus-window-right [window] (get-one-value window "focus_window_right"))
(defn focus-window-up [window] (get-one-value window "focus_window_up"))
(defn focus-window-down [window] (get-one-value window "focus_window_down"))

(defn normal-window? [window] (get-one-value window "normal_window?"))
(defn minimized? [window] (get-one-value window "minimized?"))


;; app

(defn visible-windows-for-app [app] (get-one-value app "visible_windows"))
(defn all-windows-for-app [app] (get-one-value app "all_windows"))

(defn get-app-title [app] (get-one-value app "title"))
(defn app-hidden? [app] (get-one-value app "hidden?"))

(defn show-app [app] (get-one-value app "show"))
(defn hide-app [app] (get-one-value app "hide"))

(defn kill-app [app] (get-one-value app "kill"))
(defn kill9-app [app] (get-one-value app "kill9"))


;; screen

(defn screen-frame-including-dock-and-menu [screen] (keywordize (get-one-value screen "frame_including_dock_and_menu")))
(defn screen-frame-without-dock-or-menu [screen] (keywordize (get-one-value screen "frame_without_dock_or_menu")))

(defn next-screen [screen] (get-one-value screen "next_screen"))
(defn previous-screen [screen] (get-one-value screen "previous_screen"))

(defn rotate-to [screen degrees] (get-one-value screen "rotate_to" degrees))
