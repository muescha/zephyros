## Zephyros - CHICKEN Scheme API

#### Setup

```bash
$ brew install chicken
$ chicken-install unix-sockets
$ chicken-install medea
```

#### Sample Script

* Save `zeph.scm` somewhere:

```scheme

(require "/Applications/Zephyros.app/Contents/Resources/libs/zephyros.scm")

(bind "A" '(cmd) (lambda ()
  (alert "butts lol" 4)))

(bind "N" '(ctrl shift) (lambda ()
  (call/focused-window (lambda (win)
  (call/screen win (lambda (screen)
  (call/next-screen screen (lambda (target)
  (call/frame-including-dock-and-menu target (lambda (dim)
    (let ((x (cdr (assoc 'x dim)))
          (y (cdr (assoc 'y dim))))
      (set-top-left win `((x . ,x) (y . ,y))))))))))))))

; Or using the sync API

(bind "P" '(ctrl shift) (lambda ()
  (let* ((win (focused-window))
         (scr (screen win))
         (tar (next-screen scr))
         (fra (frame-including-doc-and-menu tar))
         (x (cdr (assoc 'x dim)))
         (y (cdr (assoc 'y dim))))
    (set-top-left win `((x . ,x) (y . ,y))))))

; If you're not running in a repl (eg, csi -s zeph.scm)
; You must join the handler thread to avoid exiting
(join-handler!)

```

#### API

```scheme

(define-getter foo call/foo)
; Expands to
(define foo (lambda ()
  ; Return foo
  )
(define call/foo (lambda (thunk)
  ; Call thunk with foo
  )

(define-getter foo call/foo thing)
; Expands to
(define foo (lambda (thing)
  ; return foo for thing
  )
(define call/foo (lambda (thing thunk)
  ; Call thunk with foo for thing
  )
```

```scheme
(define-getter focused-window call/focused-window)
(define-getter visible-windows call/visible-windows)
(define-getter clipboard-contents call/clipboard-contents)
(define-getter all-windows call/all-windows)
(define-getter main-screen call/main-screen)
(define-getter all-screens call/all-screens)
(define-getter running-apps call/running-apps)

(define maximize
  (lambda (window) ...))

(define un-minimize
  (lambda (window) ...))

(define minimize
  (lambda (window) ...))

(define set-frame
  (lambda (window dim) ...))

(define set-top-left
  (lambda (window dim) ...))

(define-getter title call/title window)
(define-getter frame call/frame window)
(define-getter top-left call/top-left window)
(define-getter size call/size window)
(define-getter app call/app window)
(define-getter screen call/screen window)
(define-getter hidden? call/hidden? app)

(define show
  (lambda (app) ...))

(define hide
  (lambda (app) ...))

(define kill
  (lambda (app) ...))

(define kill9
  (lambda (app) ...))

(define-getter previous-screen call/previous-screen screen)
(define-getter next-screen call/next-screen screen)
(define-getter frame-including-dock-and-menu call/frame-including-dock-and-menu screen)
(define-getter frame-including-dock-and-menu call/frame-including-dock-and-menu screen)
(define-getter frame-without-dock-or-menu call/frame-without-dock-or-menu screen)
```
