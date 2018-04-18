(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(TeX-check-path
   (quote
    ("." "/usr/share/texmf/tex/" "/home/trifon/doc/tex/" "/home/trifon/doc/tex/packages/" "/home/trifon/fmisync/Courses/mestgen/templates/")))
 '(TeX-command-extra-options
   "-outdir=out -pdflatex=\"pdflatex \"%O\" %%S && ln -sf \"%D\" \"%R\".pdf\"")
 '(TeX-insert-braces nil)
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(TeX-view-program-list (quote (("Evince" ("evince `readlink \"%o\"`") "evince"))))
 '(auctex-latexmk-inherit-TeX-PDF-mode t)
 '(company-ghc-show-info t)
 '(current-language-environment "UTF-8")
 '(default-input-method "TeX")
 '(gdb-many-windows t)
 '(gdb-show-main t)
 '(global-auto-revert-mode t)
 '(global-font-lock-mode t nil (font-lock))
 '(global-magit-file-mode t)
 '(gud-tooltip-mode t)
 '(haskell-mode-hook (quote (turn-on-haskell-indentation)) t)
 '(haskell-process-auto-import-loaded-modules t)
 '(haskell-process-log t)
 '(haskell-process-suggest-remove-import-lines t)
 '(haskell-process-type (quote cabal-repl))
 '(haskell-tags-on-save t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(ispell-personal-dictionary "~/.emacs.d/.aspell.bg.pws")
 '(latex-run-command "pdflatex")
 '(minlog-el-path "~/minlog")
 '(minlog-path "~/minlog")
 '(mouse-wheel-mode t nil (mwheel))
 '(package-selected-packages
   (quote
    (csharp-mode diminish ghc ivy-rtags counsel swiper ivy auctex company company-ghc haskell-mode use-package auctex-latexmk flycheck-ghcmod company-auctex f helm helm-rtags s flycheck-irony flycheck-rtags flycheck company-irony-c-headers company-irony irony company-rtags racket-mode cmake-ide rtags muse multiple-cursors magit json-mode graphviz-dot-mode)))
 '(scheme-program-name "mzscheme")
 '(scroll-bar-mode (quote right))
 '(select-enable-clipboard t)
 '(sentence-end "[.?!][]\"')}]*\\($\\| $\\|	\\| \\)[
]*"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ------------------------------------------------------------
;; Package setup
;; ------------------------------------------------------------

;; load custom packages from here
(add-to-list 'load-path "~/.emacs.d/elisp")

;; configure MELPA repos
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; ------------------------------------------------------------
;; UTF-8
;; ------------------------------------------------------------

;; prefer UTF-8 by default
(set-keyboard-coding-system 'mule-utf-8)
(prefer-coding-system 'utf-8)

;; ------------------------------------------------------------
;; Global key bindings
;; ------------------------------------------------------------

;; one-button testing, tada!
(global-set-key [f12] 'compile)

;; ------------------------------------------------------------
;; Configure non-customizable variables
;; ------------------------------------------------------------

;; this means hitting the compile button always saves the buffer
;; having to separately hit C-x C-s is a waste of time
(setq mode-compile-always-save-buffer-p t)

;; from enberg on #emacs
;; if the compilation has a zero exit code,
;; the windows disappears after two seconds
;; otherwise it stays
(setq compilation-finish-function
      (lambda (buf str)
        (unless (string-match "exited abnormally" str)
          ;;no errors, make the compilation window go away in one second
          (run-at-time
           "1 sec" nil 'delete-windows-on
           (get-buffer-create "*compilation*"))
          (message "No Compilation Errors!"))))

;; ------------------------------------------------------------
;; Custom interactive commands
;; ------------------------------------------------------------

; loading minlog
(defun minlog ()
  (interactive)
  (load-file "~/minlog/util/minlog.el"))

; presentation mode
(defun present ()
  (interactive)
  (set-face-attribute 'default nil :height 160))

;; create new CMakeLists.txt
(defun cmake-create-project (project dir)
  (interactive "sEnter a project name: \nDProject directory: ")
  (let ((project-dir (concat dir project)))
    ;; create the project directory
    (make-directory project-dir t)
    ;; load the 'f package now to ensure that we can use file writing functions
    (require 'f)
    ;; write a template CMakeLists.txt file with the project name, including all .cpp files by default
    ;; and setting build type to debug
    (f-write-text
     (concat "cmake_minimum_required(VERSION 3.7)
project(" project ")
file(GLOB SOURCES \"*.cpp\")
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_STANDARD 11)
add_executable(" project " ${SOURCES})")
     'utf-8
     (concat project-dir "/CMakeLists.txt"))
    ;; open the directory of the new project
    (find-file project-dir))
)

;; clean CMake project
(defun cmake-clean-project ()
  (interactive)
  (delete-directory cmake-ide-build-dir t)
  (message "Deleted %s" cmake-ide-build-dir))

;; resize emacs at startup according to resolution
;; based on http://stackoverflow.com/questions/92971/how-do-i-set-the-size-of-emacs-window
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if (display-graphic-p)
      (progn
	(add-to-list 'default-frame-alist (cons 'top 0))
	(add-to-list 'default-frame-alist (cons 'left 0))
	;; use 100 char wide window for largeish displays
	;; and smaller 80 column windows for smaller displays
	;; pick whatever numbers make sense for you
	(if (> (x-display-pixel-width) 1280)
	    (add-to-list 'default-frame-alist (cons 'width 100))
	  (add-to-list 'default-frame-alist (cons 'width 80)))
	;; for the height, subtract a couple hundred pixels
	;; from the screen height (for panels, menubars and
	;; whatnot), then divide by the height of a char to
	;; get the height we want
	(add-to-list 'default-frame-alist
		     (cons 'height (/ (- (x-display-pixel-height) 50)
				      (frame-char-height)))))))

;; ------------------------------------------------------------
;; Package loading and configuration
;; ------------------------------------------------------------

;; Diminish package for hiding minor modes
(use-package diminish
  :ensure t)

;; Muse: simple personal wiki
(use-package muse-html
  :ensure muse
  :init
  (setq muse-project-alist
        '(("GeneralWiki" ("~/Wiki" :default "index")
           (:base "html" :path "~/WebWiki"))
          ("PhdWiki" ("~/phd/wiki" :default "index")
           (:base "html" :path "~/WebWiki"))))
  :bind ("C-x w" . muse-project-find-file))

;; open .rkt files in Scheme mode
(use-package scheme
  :defer t
  :mode ("\\.rkt\\'" . scheme-mode))

;; package for ediff-ing directories recursively
;; this package is available locally, not installed via elpa
(use-package ediff-trees
  :commands ediff-trees)

;; multiple cursors
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))

;; configure Magit
(use-package magit
  :ensure t
  :bind (("C-x g"   . magit-status)
         ("C-x M-g" . magit-dispatch-popup)))

;; load company
;; always load on start, no deferred loading
(use-package company
  :ensure t
  :diminish company-mode)

;; Haskell definitions reused from:
;; https://github.com/serras/emacs-haskell-tutorial/blob/master/dot-emacs.el
;; based on
;; https://github.com/serras/emacs-haskell-tutorial/blob/master/tutorial.md

(use-package haskell-mode
  :ensure t
  :mode "\\.hs\\'"
  :bind (:map haskell-mode-map
              ;; Add F8 key combination for going to imports block
              ([f8] . haskell-navigate-imports)
              ;; Add key combinations for interactive haskell-mode
              ("C-c C-l" . haskell-process-load-file)
              ("C-c C-z" . haskell-interactive-switch)
              ("C-c C-k" . haskell-interactive-mode-clear)))

(use-package ghc
  :ensure t
  :after haskell-mode
  :init
  ;; fix faulty ghc-mod Ubuntu package: point ghc-mod to search for cabal-helper-wrapper in /usr/lib
  (setenv "cabal_helper_libexecdir" "/usr/lib")
  :config
  (add-hook 'haskell-mode-hook (lambda () (ghc-init))))

(use-package company-ghc
  :ensure t
  ;; load immediately after GHC
  :after ghc
  :init
  ;; Use company in Haskell buffers
  (add-hook 'haskell-mode-hook 'company-mode)
  :config
  ;; make sure that company-ghc is loaded before adding to company backends
  (add-to-list 'company-backends 'company-ghc))

(use-package csharp-mode
  :ensure t
  :mode ("\\.cs\\'" . csharp-mode)
  :interpreter ("csharp" . csharp-mode))

(use-package prolog
  :ensure t
  :mode ("\\.pro\\'" . prolog-mode))

;; ==================
;; Emacs as a C++ IDE
;; ==================
;; Source: http://syamajala.github.io/c-ide.html

;; configure cc-mode
(use-package cc-mode
  ;; package loading deferred, will be loaded automatically upon opening a .{c,cpp,h,hpp} file
  :defer t
  :config
  ;; setup Company for C/C++ files
  (add-hook 'c-mode-common-hook 'company-mode)
  ;; open .h files in C++ mode by default
  :mode ("\\.h\\'" . c++-mode))


;; -----------
;; setup RTags
;; -----------

(use-package rtags
  :ensure t
  ;; defer loading after 1 second to speed startup
  :defer 1
  :config
  (message "Loaded rtags")
  (setq rtags-autostart-diagnostics t)
  ;; use standard C-c r <key> keybindings
  (rtags-enable-standard-keybindings))

(use-package company-rtags
  :ensure t
  ;; load immediately after rtags
  :after rtags
  :init
  (setq rtags-completions-enabled t)
  :config
  ;; add to company backends only after package is loaded
  (add-to-list 'company-backends 'company-rtags))

(use-package ivy-rtags
  :ensure t
  ;; package is loaded automatically by rtags, no need to load manually
  :defer t
  :init
  ;; use ivy autocompletion interface for displaying rtags suggestions
  (setq rtags-display-result-backend 'ivy))

;; -----------
;; setup Irony
;; -----------

(use-package irony
  :ensure t
  :diminish irony-mode
  ;; automatically load package when irony mode is triggerred
  :commands irony-mode
  :init
  (add-hook 'c-mode-common-hook 'irony-mode)
  ;; add Irony hooks for completion
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  :config
  ;; enable C++11 suppot for Irony
  (setq irony-additional-clang-options '("-std=c++11"
                                         "-I/usr/include/c++/"))
  ;; automatically compile and install irony server if not already installed
  (unless (condition-case nil
              (irony--find-server-executable)
            (error nil))
    (call-interactively #'irony-install-server)))

(use-package company-irony
  :ensure t
  ;; load immediatley after irony
  :after irony
  :init
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
  :config
  ;; remove company-semantic from backends due to conflicts
  (setq company-backends (delete 'company-semantic company-backends))
  ;; add company backend after the package is loaded
  (add-to-list 'company-backends 'company-irony))

(use-package company-irony-c-headers
  :ensure t
  ;; load immediatley after irony
  :after irony
  :config
  ;; add company backend after the package is loaded
  (add-to-list 'company-backends 'company-irony-c-headers))

;; -----------------------------------------------
;; Setup automatic error highlighting via Flycheck
;; -----------------------------------------------

;; Disabling flycheck wiht Irony, preferring rtags
(use-package flycheck-irony
  :ensure t
  :disabled
  ;; defer loading, will be loaded automatically via the flycheck hooks
  :defer t
  ;; setup flycheck
  :init
  (add-hook 'c-mode-common-hook 'flycheck-mode)
  (add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(use-package flycheck-rtags
  :ensure t
  :after flycheck
  :init
  (defun my-flycheck-rtags-setup ()
    (flycheck-select-checker 'rtags)
    (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
    (setq-local flycheck-check-syntax-automatically nil))
  ;; setup flycheck
  (add-hook 'c-mode-common-hook 'flycheck-mode)
  (add-hook 'flycheck-mode-hook #'my-flycheck-rtags-setup))

;; required for cmake-create-project interactive command
(use-package f
  :ensure t
  :defer t)

;; ---------------
;; setup CMake IDE
;; ---------------

;; setup last to make sure that cmake-ide-build-dir is set as early as possible
(use-package cmake-ide
  :ensure t
  ;; defer loading after 2 seconds to speed up Emacs start
  :defer 2
  ;; replace compile keybinding for CMake projects
  :bind ([f12] . cmake-ide-compile)
  :init
  ;; by default always set the cmake-ide-build-dir variable to <default-directory>/build
  (defun set-cmake-ide-build-dir ()
    ;; only if this is a CMake project, i.e., a CMakeLists.txt file exists
    (when (file-exists-p (expand-file-name "CMakeLists.txt"))
      (set (make-local-variable 'cmake-ide-build-dir)
           (expand-file-name "build/"))))
  (add-hook 'c-mode-common-hook 'set-cmake-ide-build-dir)
  :config
  ;; setup CMake IDE
  (message "Setting up cmake-ide")
  (cmake-ide-setup))

;; confivigure ivy
(use-package ivy
  :ensure t
  :diminish ivy-mode
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  :bind ("C-c C-r" . ivy-resume))

;; configure counsel
(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

;; configure counsel
(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("<f1> f" . counsel-describe-function)
         ("<f1> v" . counsel-describe-variable)
         ("<f1> l" . counsel-find-library)
         ("<f2> i" . counsel-info-lookup-symbol)
         ("<f2> u" . counsel-unicode-char)))

;; configure AucTeX
(use-package tex-site
  ;; will be loaded automatically by a TeX mode hook
  :defer t
  ;; package name is tex-site, which is different from feature name: auctex
  :ensure auctex
  :config
  ;; Load support for different style files in AucTeX
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  ;; avoid prompting for the TeX master file
  (setq-default TeX-master t)
  ;; enable flyspell for TeX files
  (add-hook 'TeX-mode-hook 'turn-on-flyspell))

;; enable autocompletion in AucTeX
;; needs to be done *after* all other company backends ar loaded
(use-package company-auctex
  :ensure t
  ;; and also after AucTex is loaded
  :after auctex
  :init
  (add-hook 'TeX-mode-hook 'company-mode)
  :config
  (company-auctex-init))

;; enable AucTeX compilation with latexmk
(use-package auctex-latexmk
  :ensure t
  ;; will be loaded automatically by a TeX mode hook
  :defer t
  :init
  (add-hook 'TeX-mode-hook (lambda () (auctex-latexmk-setup)))
  ;; compile with latexmk by default
  (add-hook 'TeX-mode-hook
            '(lambda () (setq TeX-command-default "latexmk"))))

;; DOT mode for displaying graphs via GraphViz
(use-package graphviz-dot-mode
  :ensure t
  :mode "\\.dot\\'")

;; ------------------------------------------------------------
;; End of package loading and configuration
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; Setup emacs layout
;; ------------------------------------------------------------
(set-frame-size-according-to-resolution)
