(message "Здравей!")

; C-x C-e => "Здравей!" в минибуфера
; C-x b => смяна на буфера
; M-: => оценяване

; Meta обикновено е ALT, но ако няма, може да се използва ESC-x
; M-x emacs-lisp-mode
; M-x fundamental-mode
; Frame - отделен прозорец
; Window - отделна част в същия прозорец
; Buffer - отворен файл (един и същ файл може да е в няколко буфера)
; C-x 3 - разделяне вертикално
; C-x 2 - разделяне хоризонтално
; C-x 1 - само един буфер
; C-x 0 - връща един сплит назад
; C-x 5 2 - отвори нов frame

; C-h - помощ
;   C-h b - помощ за всички свързвания, активни в момента
;   C-h f - помощ за функциите
;   C-h v - помощ за променливите
;   C-h k - помощ за клавишните комбинации
;   C-h a - apropos - търсене в помощта
;   C-h i - info - цялата документация

; C-x o - сменяш курсора в другия прозорец
; по-добре изолзвайте WindMove: (windmove-default-keybindings) S-left,right,up,down

; за да изпълнявите команди в началото на стартирането ~/.emacs

; C-x C-s - записване на текущия в буфер файл
; C-x C-f - отваряне на файл
; C-x C-c - изход

; C-w - Cut
; M-w = Copy
; C-y = Paste
; C-k = Kill a line
; C-space = слага маркировка
; Cut & Copy се отнасаят за текста от маркировката до курсора

; разлики между Scheme и Lisp
; - no closures
;   set! => setq
;   (define (f x y) ...) => (defun f (x y) ..)
;   (setq f (lambda (x) (message x)))
;   за да извикате f не става само (f "здрасти"), трябва (funcall f "здрасти")
; виж GNU Emacs Lisp Reference

; (defun g (x) (message x))
; (g "abc")
; сега може да се види в C-h f g че има такава функция
; (interactive) - ???
; (defun g2 () (interactive) (message "Help!"))

; C-g - отказ (става също и ESC ESC ESC)

; свързване на команда с клавиш
; (global-set-key [(control j)] 'g2)
; или аналогично
; (define-key global-mode [(control j)] 'g2)

; (define-key emacs-lisp-mode-map [(control i)] 'g2)
; така ще работи само в режима Emacs Lisp

; (load "~/.emacs")
; (require 'minlog-mode) 
; търси файла със същото име, който казва (provide 'minlog-mode)
; (setq load-path (cons "~/.my-emacs-stuff" load-path))

; cua-mode - държи се като Windows редактор
; viper-mode - държи се като Vi
; font-lock-mode - включва цветовете
; column-number-mode
; line-number-mode
; show-paren-mode - показва двойките скоби

; има два вида режими - основни и допълнителни 

(defun basils-thesis ()
  (interactive)
  (end-of-buffer)
  (insert "Basil's Thesis")
)

(defun replace-basils-thesis ()
  (interactive)
  (save-excursion
  (if (search-forward "Basil's")
    (progn 
      (goto-char (match-beginning 0))
      (insert "This is "))
    )
  )
)

; save-match-data
; save-window-excursion
; customize-group
; (add-hook ) - изпълни нещо, след като даден режим е избран
; auto-mode-alist

