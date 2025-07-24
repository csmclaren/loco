;;; loco.el --- Enter complex key sequences with ease!  -*- lexical-binding: t; -*-

;; Copyright 2024, Chris McLaren
;; Author: Chris McLaren <csmclaren@me.com>
;; Maintainer: Chris McLaren <csmclaren@me.com>
;; Created: 2024-06-14
;; Version: 0.1.0
;; Keywords: abbrev, convenience
;; URL: https://github.com/csmclaren/loco
;; Package-Requires: ((emacs "29.1"))

;; This file is not part of GNU Emacs.

;; This file is part of Loco.

;; Loco is free software: you can redistribute it and/or modify it under the
;; terms of the GNU General Public License as published by the Free Software
;; Foundation, either version 3 of the License, or (at your option) any later
;; version.

;; Loco is distributed in the hope that it will be useful, but WITHOUT ANY
;; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
;; details.

;; You should have received a copy of the GNU General Public License along with
;; Loco. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Loco is a library and minor mode to help you enter complex key sequences
;; with ease. For full details, see the documentation distributed with this
;; file.

;;; Code:

;; Constants

(defconst loco-mode-name
          "loco-mode")

(defconst loco-cp-black-right-pointing-triangle
          ?▶ "Unicode 25B6 BLACK RIGHT-POINTING TRIANGLE.")

(defconst loco-cp-tram-car
          ?🚋 "Unicode 1F68B TRAM CAR.")

;; Customizations

(defgroup loco
          nil
          "Enter complex key sequences with ease!"
          :group 'editing
          :prefix "loco-")

(defcustom loco-lighter
           " Loco"
           "The lighter, shown in the mode line when `loco-mode' is enabled."
           :group 'loco
           :type 'string)

(defcustom loco-show-state-change
           t
           "Show a message when `loco-mode' changes state.

When `loco-mode' is enabled or disabled, this variable determines whether or
not to show the new state in the echo area."
           :group 'loco
           :type 'boolean)

;; Customizations - Logging

(defgroup loco-log
          nil
          "Customizations related to logging."
          :group 'loco
          :prefix "loco-")

(defcustom loco-log-buffer-name
           "*Loco-Log*"
           "The name of the log buffer to where messages are logged."
           :group 'loco-log
           :type 'string)

(defcustom loco-log-max-level
           1
           "Log messages with this level of detail or lower.

Error      Log errors.
Warning    Also log warnings.
Info       Also log general information.
Debug      Also log information for debugging purposes."
           :group 'loco-log
           :type '(choice (const :tag "Error" 0)
                          (const :tag "Warning" 1)
                          (const :tag "Info" 2)
                          (const :tag "Debug" 3)))

(defcustom loco-log-show-buffer
           t
           "Show the log buffer when a new message is logged.

When a new message is logged, this variable determines whether or not to show
the log buffer, if it is not already visible."
           :group 'loco-log
           :type 'boolean)

;; Customizations - Prompting

(defgroup loco-prompt
          nil
          "Customizations related to prompting."
          :group 'loco
          :prefix "loco-")

(defcustom loco-prompt-am-collapsed
           nil
           "The Assist Menu, as shown in its collapsed state.

When Loco is activated, it shows a prompt in the echo area.  When the
Assist Menu is open, it is shown as part of this prompt.  The Assist Menu can
be open in one of two states: collapsed or expanded.  This variable is used for
the representation of the Assist Menu in its collapsed state.  A value of nil
indicates that Loco should generate a default representation."
           :group 'loco-prompt
           :type 'sexp)

(defcustom loco-prompt-am-expanded
           nil
           "The Assist Menu, as shown in its expanded state.

When Loco is activated, it shows a prompt in the echo area.  When the
Assist Menu is open, it is shown as part of this prompt.  The Assist Menu can
be open in one of two states: collapsed or expanded.  This variable is used for
the representation of the Assist Menu in its expanded state.  A value of nil
indicates that Loco should generate a default representation."
           :group 'loco-prompt
           :type 'sexp)

(defcustom loco-prompt-am-open-expanded
           t
           "Open the Assist Menu expanded, showing its full set of items."
           :group 'loco-prompt
           :type 'boolean)

(defcustom loco-prompt-header-describe
           "Describe the following Loco key sequence:"
           "The header, when Loco is activated to describe a command.

When Loco is activated, it shows a prompt in the echo area.  The header is the
first part of this prompt."
           :group 'loco-prompt
           :type 'sexp)

(defcustom loco-prompt-header-execute
           (propertize (char-to-string loco-cp-black-right-pointing-triangle)
                       'face
                       'bold)
           "The header, when Loco is activated to execute a command.

When Loco is activated, it shows a prompt in the echo area.  The header is the
first part of this prompt."
           :group 'loco-prompt
           :type 'sexp)

(defcustom loco-prompt-show-kseq-o
           nil
           "Show the original key sequence (kseq-o) when Loco is activated.

When Loco is activated, it shows a prompt in the echo area.  When this variable
is non-nil, the original key sequence (kseq-o) will be shown as part of this
prompt.  Note that the translated key sequence (kseq-t) is always shown as part
of the prompt."
           :group 'loco-prompt
           :type 'boolean)

(defcustom loco-prompt-show-kseq-p
           nil
           "Show the processed key sequence (kseq-p) when Loco is activated.

When Loco is activated, it shows a prompt in the echo area.  When this variable
is non-nil, the processed key sequence (kseq-p) will be shown as part of this
prompt.  Note that the translated key sequence (kseq-t) is always shown as part
of the prompt."
           :group 'loco-prompt
           :type 'boolean)

;; Logging
;; Private macros
;; High-level (use of global variables declared herein)

(defmacro loco--log (level fmt-str &rest args)
  "Log a message at a given LEVEL.

This macro will only evaluate its arguments and log a message if the LEVEL
is less than or equal to `loco-log-max-level'.

LEVEL is a number where 0 is an error, 1 is a warning,
2 is general information, and 3 is for information for debugging purposes.
Any other value is shown numerically.

FMT-STR is a format string, followed by ARGS as in \"format\"."
  `(when (<= ,level loco-log-max-level)
     (loco--write-message-to-log-buffer ,level ,fmt-str ,@args)))

;; Logging
;; Private macros
;; Low-level (no use of global variables declared herein)

(defmacro loco--format-var (var)
  "Format a variable VAR as its name and value."
  `(let ((key (symbol-name ',var))
         (value (prin1-to-string ,var)))
    (format "%s: %s" key (propertize value 'face 'font-lock-constant-face))))

(defmacro loco--format-vars (&rest vars)
  "Format a list of variables VARS as their names and values."
  `(string-join
    (list ,@(mapcar (lambda (var) `(loco--format-var ,var)) vars))
    ", "))

;; Keymaps

(defvar loco-mode-keymap (make-sparse-keymap)
  "Keymap for `loco-mode'.")

;; Definition of minor mode

;;;###autoload
(define-minor-mode loco-mode
  "Toggle `loco-mode'.

A minor mode to help you enter complex key sequences with ease."
  :group 'loco
  :init-value nil
  :keymap loco-mode-keymap
  :lighter loco-lighter
  (let* ((state-str (if loco-mode "enabled" "disabled"))
         (message-str (format "%s %s" loco-mode-name state-str))
         (buffer-name (buffer-name)))
    (loco--log 2 "%s (%s)" message-str (loco--format-var buffer-name))
    (when loco-show-state-change
      (message message-str))))

;;;###autoload
(define-globalized-minor-mode global-loco-mode
  loco-mode
  (lambda ()
    (loco-mode 1))
  :group 'loco)

;; Public functions

;;;###autoload
(defun loco-default-describe-kseq (&rest args)
  "Read and describe a key sequence with default parameters.

This function prompts the user to enter a key sequence and then describes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco-default-execute-kseq :d t args))

;;;###autoload
(defun loco-default-execute-kseq (&rest args)
  "Read and execute a key sequence with default parameters.

This function prompts the user to enter a key sequence and then executes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco-read-kseq :key-mod-c ?j :key-mod-m ?k args))

;;;###autoload
(defun loco-read-kseq (&rest args)
  "Read a key sequence.

ARGS              Keyword arguments, as described below:

D                 If non-nil, if a key sequence is bound to a command,
                  that command should be described instead of executed.
                  Default: nil

DT                If non-nil, pressing one of the modifier keys starting with
                  KEY-MOD- will clear all modifiers and insert the key
                  literally if its modifier (and only that modifier) was
                  already in effect.  (This enables the double-tap rule,
                  described fully in the manual).
                  Default: nil

KEY-AM-MOD-A-CL   If non-nil, when the Assist Menu is open,
                  this key will toggle A-, then close the Assist Menu.
                  Default: `a'

KEY-AM-MOD-A-OP   If non-nil, when the Assist Menu is open,
                  this key will toggle A-, but keep the Assist Menu open.
                  Default: `A'

KEY-AM-MOD-C-CL   If non-nil, when the Assist Menu is open,
                  this key will toggle C-, then close the Assist Menu.
                  Default: `c'

KEY-AM-MOD-C-OP   If non-nil, when the Assist Menu is open,
                  this key will toggle C-, but keep the Assist Menu open.
                  Default: `C'

KEY-AM-MOD-H-CL   If non-nil, when the Assist Menu is open,
                  this key will toggle H-, then close the Assist Menu.
                  Default: `h'

KEY-AM-MOD-H-OP   If non-nil, when the Assist Menu is open,
                  this key will toggle H-, but keep the Assist Menu open.
                  Default: `H'

KEY-AM-MOD-M-CL   If non-nil, when the Assist Menu is open,
                  this key will toggle M-, then close the Assist Menu.
                  Default: `m'

KEY-AM-MOD-M-OP   If non-nil, when the Assist Menu is open,
                  this key will toggle M-, but keep the Assist Menu open.
                  Default: `M'

KEY-AM-MOD-S-CL   If non-nil, when the Assist Menu is open,
                  this key will toggle s-, then close the Assist Menu.
                  Default: `s'

KEY-AM-MOD-S-OP   If non-nil, when the Assist Menu is open,
                  this key will toggle s-, but keep the Assist Menu open.
                  Default: `S'

KEY-AM-QUIT       If non-nil, when the Assist Menu is open,
                  this key will quit.
                  Default: `q'

KEY-AM-S-CL       If non-nil, when the Assist Menu is open,
                  this key will close the Assist Menu.
                  Default: `x'

KEY-AM-S-CO       If non-nil, when the Assist Menu is open and expanded,
                  this key will collapse the Assist Menu.
                  Default: `;'

KEY-AM-S-EX       If non-nil, when the Assist Menu is open and collapsed,
                  this key will expand the Assist Menu.
                  Default: `;'

KEY-AM-S-OP       If non-nil, when the Assist Menu is closed,
                  this key will open the Assist Menu.
                  Default: `l'

KEY-MOD-A         If non-nil, when the Assist Menu is closed,
                  this key will be interpreted as `A-'.
                  Default: nil

KEY-MOD-C         If non-nil, when the Assist Menu is closed,
                  this key will be interpreted as `C-'.
                  Default: nil

KEY-MOD-H         If non-nil, when the Assist Menu is closed,
                  this key will be interpreted as `H-'.
                  Default: nil

KEY-MOD-M         If non-nil, when the Assist Menu is closed,
                  this key will be interpreted as `M-'.
                  Default: nil

KEY-MOD-S         If non-nil, when the Assist Menu is closed,
                  this key will be interpreted as `s-'.
                  Default: nil

KSEQ              If non-nil, key events will be taken from this vector
                  before `read-event` is called.
                  Default: nil

STRIP             If non-nil, this function should strip all modifiers
                  (except Shift) from keys.  This can improve flow and help
                  prevent key entry errors due to a modifier key being
                  accidentially held down longer than necessary.  If nil,
                  modifiers are maintained.  In this case, Loco will (properly)
                  merge any modifiers on a key with the set of pending
                  modifiers.
                  Default: nil

VALIDATE          If non-nil, validate all keys used by this function
                  (That is, the keyword arguments beginning with `KEY-') to
                  check for duplicates or unreachable keys.  A key is
                  unreachable if it includes modifiers and STRIP is non-nil.
                  Default: nil"
  (interactive)
  (let (;; keyword arguments
        (d (plist-get args :d))
        (dt (plist-get args :dt))
        (key-am-mod-a-cl (loco--plist-get-d args :key-am-mod-a-cl ?a))
        (key-am-mod-a-op (loco--plist-get-d args :key-am-mod-a-op ?A))
        (key-am-mod-c-cl (loco--plist-get-d args :key-am-mod-c-cl ?c))
        (key-am-mod-c-op (loco--plist-get-d args :key-am-mod-c-op ?C))
        (key-am-mod-h-cl (loco--plist-get-d args :key-am-mod-h-cl ?h))
        (key-am-mod-h-op (loco--plist-get-d args :key-am-mod-h-op ?H))
        (key-am-mod-m-cl (loco--plist-get-d args :key-am-mod-m-cl ?m))
        (key-am-mod-m-op (loco--plist-get-d args :key-am-mod-m-op ?M))
        (key-am-mod-s-cl (loco--plist-get-d args :key-am-mod-s-cl ?s))
        (key-am-mod-s-op (loco--plist-get-d args :key-am-mod-s-op ?S))
        (key-am-quit (loco--plist-get-d args :key-am-quit ?q))
        (key-am-s-cl (loco--plist-get-d args :key-am-s-cl ?x))
        ;; NOTE ASCII 59 is ?\;
        ;; (the literal form breaks syntax colouring in some non-emacs editors)
        (key-am-s-co (loco--plist-get-d args :key-am-s-co 59))
        (key-am-s-ex (loco--plist-get-d args :key-am-s-ex 59))
        (key-am-s-op (loco--plist-get-d args :key-am-s-op ?l))
        (key-mod-a (plist-get args :key-mod-a))
        (key-mod-c (plist-get args :key-mod-c))
        (key-mod-h (plist-get args :key-mod-h))
        (key-mod-m (plist-get args :key-mod-m))
        (key-mod-s (plist-get args :key-mod-s))
        (kseq (plist-get args :kseq))
        (strip (plist-get args :strip))
        (validate (plist-get args :validate))
        ;; local variables
        (am-expanded loco-prompt-am-open-expanded) ; is assist menu expanded?
        (am-open nil) ; is assist menu open?
        (fn-name "loco-read-kseq") ; function name used in log messages
        (keys-am-l nil) ; the literal keys on the assist menu
        (keys-am-mod-cl nil) ; the modifier keys that close the assist menu
        (keys-am-mod-op nil) ; the modifier keys that keep the assist menu open
        (kseq-o []) ; the original key sequence
        (kseq-p []) ; the processed key sequence
        (kseq-t []) ; the translated key sequence
        (mod-a nil) ; is A- pending?
        (mod-c nil) ; is C- pending?
        (mod-h nil) ; is H- pending?
        (mod-m nil) ; is M- pending?
        (mod-s nil) ; is s- pending?
        (should-loop t))

    ;; prologue

    (setq keys-am-l (list key-mod-a key-mod-c key-mod-h key-mod-m key-mod-s)
          keys-am-mod-cl (list key-am-mod-a-cl key-am-mod-c-cl key-am-mod-h-cl
                               key-am-mod-m-cl key-am-mod-s-cl)
          keys-am-mod-op (list key-am-mod-a-op key-am-mod-c-op key-am-mod-h-op
                               key-am-mod-m-op key-am-mod-s-op))

    (when validate
      (let* ((keys-am-collapsed (append keys-am-l keys-am-mod-cl keys-am-mod-op
                                        (list key-am-quit key-am-s-cl
                                              key-am-s-ex key-am-s-op)))
             (nn-keys-am-collapsed (seq-filter #'identity keys-am-collapsed))
             (dup-keys-am-collapsed (loco--seq-all-dups nn-keys-am-collapsed))
             (keys-am-expanded (append keys-am-l keys-am-mod-cl keys-am-mod-op
                                       (list key-am-quit key-am-s-cl
                                             key-am-s-co key-am-s-op)))
             (nn-keys-am-expanded (seq-filter #'identity keys-am-expanded))
             (dup-keys-am-expanded (loco--seq-all-dups nn-keys-am-expanded))
             (dup-keys (seq-uniq (append dup-keys-am-collapsed
                                         dup-keys-am-expanded))))
        (when dup-keys
          (let* ((sorted (sort dup-keys #'loco--sortp))
                 (message-str (format "duplicate keys found: %s" sorted)))
            (loco--log 0 "[%s.validate] %s" fn-name message-str))))
      (when strip
        (let* ((all-keys (append keys-am-l keys-am-mod-cl keys-am-mod-op
                                 (list key-am-quit key-am-s-cl key-am-s-co
                                       key-am-s-ex key-am-s-op)))
               (fn (lambda (key)
                     (let ((modifiers (delq 'shift (event-modifiers key))))
                       (not (seq-empty-p modifiers)))))
               (modified-keys (seq-filter fn all-keys)))
            (when modified-keys
              (let* ((sorted (sort modified-keys #'loco--sortp))
                     (message-str (format "modified keys found: %s" sorted)))
                (loco--log 0 "[%s.validate] %s" fn-name message-str))))))

    ;; loop

    (while should-loop

      ;; before read event

      (loco--log 3 "[%s.before-read-event] %s" fn-name
                 (loco--format-vars kseq am-expanded am-open kseq-o kseq-p
                                    kseq-t mod-a mod-c mod-h mod-m mod-s))

      ;; read event

      (let* ((header (if d
                         loco-prompt-header-describe
                       loco-prompt-header-execute))
             (header-str (if (stringp header)
                             header
                           (format "%s" header)))
             (am (if am-open
                         (cond
                           ((and am-expanded loco-prompt-am-expanded)
                             loco-prompt-am-expanded)
                           ((and (not am-expanded) loco-prompt-am-collapsed)
                             loco-prompt-am-collapsed)
                           (t
                             (loco--format-am am-expanded keys-am-l
                                              keys-am-mod-cl keys-am-mod-op
                                              key-am-quit key-am-s-cl
                                              key-am-s-co key-am-s-ex
                                              key-am-s-op)))
                       ""))
             (am-str (if (stringp am)
                         am
                       (format "%s" am)))
             (prompt-str (loco--format-prompt header-str
                                              (if loco-prompt-show-kseq-o
                                                  kseq-o
                                                nil)
                                              (if loco-prompt-show-kseq-p
                                                  kseq-p
                                                nil)
                                              kseq-t
                                              mod-a mod-c mod-h mod-m mod-s
                                              am-str))
             (e-o ; the original event
                  (if (and kseq (not (seq-empty-p kseq)))
                      (prog1
                        (seq-elt kseq 0)
                        (setq kseq (seq-drop kseq 1)))
                    (read-event prompt-str)))
             (e-p ; the processed event
                  nil))

        ;; after read event

        (loco--log 3 "[%s.loop.after-read-event] %s" fn-name
                   (loco--format-vars kseq am-expanded am-open kseq-o kseq-p
                                      kseq-t mod-a mod-c mod-h mod-m mod-s))

        ;; process event

        (when e-o
          (when strip
            (setq e-o (loco--remove-modifiers e-o t t t t t nil)))
          (let ((action nil))
            (if am-open
                (cond
                  ;; quit
                  ((eq e-o key-am-quit)
                    (loco--invoke-kseq-str "C-g"))
                  ;; close the assist menu
                  ((eq e-o key-am-s-cl)
                    (setq action 'accept am-open nil))
                  ;; collapse the assist menu
                  ((and (eq e-o key-am-s-co) am-expanded)
                    (setq am-expanded nil))
                  ;; expand the assist menu
                  ((and (eq e-o key-am-s-ex) (not am-expanded))
                    (setq am-expanded t))
                  ;; treat literally and close the assist menu
                  ((or (eq e-o key-am-s-op) (memq e-o keys-am-l))
                    (setq action 'literal am-open nil))
                  ;; toggle A- and close the assist menu
                  ((eq e-o key-am-mod-a-cl)
                    (setq action 'accept am-open nil mod-a (not mod-a)))
                  ;; toggle A-
                  ((eq e-o key-am-mod-a-op)
                    (setq action 'accept mod-a (not mod-a)))
                  ;; toggle C- and close the assist menu
                  ((eq e-o key-am-mod-c-cl)
                    (setq action 'accept am-open nil) mod-c (not mod-c))
                  ;; toggle C-
                  ((eq e-o key-am-mod-c-op)
                    (setq action 'accept mod-c (not mod-c)))
                  ;; toggle H- and close the assist menu
                  ((eq e-o key-am-mod-h-cl)
                    (setq action 'accept am-open nil mod-h (not mod-h)))
                  ;; toggle H-
                  ((eq e-o key-am-mod-h-op)
                    (setq action 'accept mod-h (not mod-h)))
                  ;; toggle M- and close the assist menu
                  ((eq e-o key-am-mod-m-cl)
                    (setq action 'accept am-open nil mod-m (not mod-m)))
                  ;; toggle M-
                  ((eq e-o key-am-mod-m-op)
                    (setq action 'accept mod-m (not mod-m)))
                  ;; toggle s- and close the assist menu
                  ((eq e-o key-am-mod-s-cl)
                    (setq action 'accept am-open nil mod-s (not mod-s)))
                  ;; toggle s-
                  ((eq e-o key-am-mod-s-op)
                    (setq action 'accept mod-s (not mod-s)))
                  ;; expand the assist menu and ding
                  (t
                    (setq am-expanded t)
                    (ding)))
              (cond
                ;; open the assist menu
                ((eq e-o key-am-s-op)
                  (setq action 'accept am-open t))
                ;; A-
                ((eq e-o key-mod-a)
                  (if mod-a
                      (if (and dt (not (or mod-c mod-h mod-m mod-s)))
                          (setq action 'double-tap)
                        (setq action 'literal))
                    (setq action 'accept mod-a t)))
                ;; C-
                ((eq e-o key-mod-c)
                  (if mod-c
                      (if (and dt (not (or mod-a mod-h mod-m mod-s)))
                          (setq action 'double-tap)
                        (setq action 'literal))
                    (setq action 'accept mod-c t)))
                ;; H-
                ((eq e-o key-mod-h)
                  (if mod-h
                      (if (and dt (not (or mod-a mod-c mod-m mod-s)))
                          (setq action 'double-tap)
                        (setq action 'literal))
                    (setq action 'accept mod-h t)))
                ;; M-
                ((eq e-o key-mod-m)
                  (if mod-m
                      (if (and dt (not (or mod-a mod-c mod-h mod-s)))
                          (setq action 'double-tap)
                        (setq action 'literal))
                    (setq action 'accept mod-m t)))
                ;; s-
                ((eq e-o key-mod-s)
                  (if mod-s
                      (if (and dt (not (or mod-a mod-c mod-h mod-m)))
                          (setq action 'double-tap)
                        (setq action 'literal))
                    (setq action 'accept mod-s t)))
                ;; treat literally
                (t
                  (setq action 'literal))))

          (when (memq action '(accept double-tap literal))
            (setq kseq-o (if (and (equal e-o key-am-s-cl)
                                  (not (seq-empty-p kseq-o))
                                  (equal (seq-elt kseq-o
                                                  (1- (seq-length kseq-o)))
                                         key-am-s-op))
                               (seq-take kseq-o (1- (seq-length kseq-o)))
                             (vconcat kseq-o (vector e-o)))))

          (pcase action
            ('double-tap
              (setq e-p e-o))
            ('literal
              (setq e-p (loco--add-modifiers e-o mod-a mod-c mod-h mod-m mod-s
                         nil))))

          (when (memq action '(double-tap literal))
            (setq mod-a nil mod-c nil mod-h nil mod-m nil mod-s nil
                  kseq-p (vconcat kseq-p (vector e-p))))))

        ;; after process event

        (loco--log 3 "[%s.loop.after-process-event] %s" fn-name
                   (loco--format-vars kseq am-expanded am-open kseq-o kseq-p
                                      kseq-t mod-a mod-c mod-h mod-m mod-s))

        ;; lookup kseq

        (when e-p
          (let* ((keymaps (if d
                              (current-active-maps)
                            (remove loco-mode-keymap (current-active-maps))))
                 (result (loco--lookup-kseq kseq-p keymaps))
                 (kseq-t3 (seq-elt result 0))
                 (kseq-t3-str (loco--format-kseq kseq-t3))
                 (binding (seq-elt result 1))
                 (kseq-last (loco--seq-last kseq-t3))
                 (kseq-last-str (loco--format-kseq (vector kseq-last)))
                 (kseq-not-last (loco--seq-not-last kseq-t3))
                 (kseq-not-last-str (loco--format-kseq kseq-not-last)))

            (setq kseq-t kseq-t3)

            ;; after lookup kseq

            (loco--log 3 "[%s.loop.after-lookup-kseq] %s" fn-name
                       (loco--format-vars kseq am-expanded am-open kseq-o
                                          kseq-p kseq-t
                                          mod-a mod-c mod-h mod-m mod-s))

            (cond
              ((commandp binding)
                (loco--log 2 "complete binding (%s)"
                           (loco--format-vars kseq-t3-str binding))
                (setq should-loop nil)
                (if d
                    (describe-key kseq-t)
                  (progn
                    (setq last-command-event e-p
                          real-this-command binding
                          this-command binding)
                    (unwind-protect
                      (call-interactively binding)
                      (loco--log 3 "[%s.unwind]" fn-name)))))
              ((or (keymapp binding) (eq binding t))
                (loco--log 2 "incomplete binding (%s)"
                           (loco--format-vars kseq-t3-str)))
              ((and (or (eq kseq-last 8) (eq kseq-last 'f1))
                    (>= (seq-length kseq-not-last) 1)
                    (let* ((result (loco--lookup-kseq kseq-not-last keymaps))
                           (binding (seq-elt result 1)))
                      (keymapp binding)))
                (loco--log 2 "describe bindings (%s)"
                           (loco--format-vars kseq-not-last-str kseq-last-str))
                (setq should-loop nil)
                (describe-bindings kseq-not-last))
              (t
                (loco--log 2 "unbound key sequence (%s)"
                           (loco--format-vars kseq-t3-str))
                (setq should-loop nil)
                (message "%s is undefined" kseq-t3-str)))))))))

;;;###autoload
(defun loco-set-default-configuration ()
  "Set the default configuration."
  (interactive)
  (keymap-global-set "C-c ," #'loco-mode)
  (keymap-global-set "C-c ." #'global-loco-mode)
  (keymap-set loco-mode-keymap "C-h S-<return>" #'loco-default-describe-kseq)
  (keymap-set loco-mode-keymap "S-<return>" #'loco-default-execute-kseq))

;;;###autoload
(defun loco-unset-default-configuration ()
  "Unset the default configuration."
  (interactive)
  (keymap-global-unset "C-c ,")
  (keymap-global-unset "C-c .")
  (keymap-unset loco-mode-keymap "C-h S-<return>")
  (keymap-unset loco-mode-keymap "S-<return>"))

;; Standard configurations
;; Public functions
;; High-level (use of global variables declared herein)

;;;###autoload
(defun loco-set-standard-configuration (config &rest args)
  "Set the standard configuration based on CONFIG.

Valid options for CONFIG and their meanings:

shift-return-jk     `S-return' to activate then
                    `j' to apply `C-' or `k' to apply `M-'.

control-return-jk   `C-return' to activate then
                    `j' to apply `C-' or `k' to apply `M-'.

super-return-jk     `s-return' to activate then
                    `j' to apply `C-' or `k' to apply `M-'.

shift-return-cp     `S-return' to activate then
                    `,' to apply `C-' or `.' to apply `M-'.

control-return-cp   `C-return' to activate then
                    `,' to apply `C-' or `.' to apply `M-'.

super-return-cp     `s-return' to activate then
                    `,' to apply `C-' or `.' to apply `M-'.

control-jk          `C-j' to activate and apply `C-' or
                    `C-k' to activate and apply `M-' then
                    `j' to apply `C-' or `k' to apply `M-'
                    (this option passes `:strip t' to `loco-read-kseq').

super-jk            `s-j' to activate and apply `C-' or
                    `s-k' to activate and apply `M-' then
                    `j' to apply `C-' or `k' to apply `M-'
                    (this option passes `:strip t' to `loco-read-kseq').

control-cp          `C-,' to activate and apply `C-' or
                    `C-.' to activate and apply `M-' then
                    `,' to apply `C-' or `.' to apply `M-'
                    (this option passes `:strip t' to `loco-read-kseq').

super-cp            `s-,' to activate and apply `C-' or
                    `s-.' to activate and apply `M-' then
                    `,' to apply `C-' or `.' to apply `M-'
                    (this option passes `:strip t' to `loco-read-kseq').

double-tap-cp       `,' to activate and apply `C-' or
                    `.' to activate and apply `M-' then
                    `,' to apply `C-' or `.' to apply `M-'
                    (this option passes `:dt t' and `:strip t' to
                    `loco-read-kseq').

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (cond
    ;; shift-return-jk
    ((eq config 'shift-return-jk)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h S-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq args)))
      (keymap-set loco-mode-keymap "S-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq args))))
    ;; control-return-jk
    ((eq config 'control-return-jk)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h C-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq args)))
      (keymap-set loco-mode-keymap "C-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq args))))
    ;; super-return-jk
    ((eq config 'super-return-jk)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h s-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq args)))
      (keymap-set loco-mode-keymap "s-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq args))))
    ;; shift-return-cp
    ((eq config 'shift-return-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h S-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq args)))
      (keymap-set loco-mode-keymap "S-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq args))))
    ;; control-return-cp
    ((eq config 'control-return-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h C-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq args)))
      (keymap-set loco-mode-keymap "C-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq args))))
    ;; super-return-cp
    ((eq config 'super-return-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h s-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq args)))
      (keymap-set loco-mode-keymap "s-<return>"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq args))))
    ;; control-jk
    ((eq config 'control-jk)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h C-j"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq :kseq [?j] :strip t args)))
      (keymap-set loco-mode-keymap "C-h C-k"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq :kseq [?k] :strip t args)))
      (keymap-set loco-mode-keymap "C-j"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq :kseq [?j] :strip t args)))
      (keymap-set loco-mode-keymap "C-k"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq :kseq [?k] :strip t args))))
    ;; super-jk
    ((eq config 'super-jk)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h s-j"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq :kseq [?j] :strip t args)))
      (keymap-set loco-mode-keymap "C-h s-k"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-describe-kseq :kseq [?k] :strip t args)))
      (keymap-set loco-mode-keymap "s-j"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq :kseq [?j] :strip t args)))
      (keymap-set loco-mode-keymap "s-k"
                  (lambda ()
                    (interactive)
                    (apply #'loco--jk-execute-kseq :kseq [?k] :strip t args))))
    ;; control-cp
    ((eq config 'control-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h C-,"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :kseq [?,] :strip t args)))
      (keymap-set loco-mode-keymap "C-h C-."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :kseq [?.] :strip t args)))
      (keymap-set loco-mode-keymap "C-,"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq :kseq [?,] :strip t args)))
      (keymap-set loco-mode-keymap "C-."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq :kseq [?.] :strip t args))))
    ;; super-cp
    ((eq config 'super-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h s-,"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :kseq [?,] :strip t args)))
      (keymap-set loco-mode-keymap "C-h s-."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :kseq [?.] :strip t args)))
      (keymap-set loco-mode-keymap "s-,"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq :kseq [?,] :strip t args)))
      (keymap-set loco-mode-keymap "s-."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq :kseq [?.] :strip t args))))
    ;; double-tap-cp
    ((eq config 'double-tap-cp)
      (loco--default-keymap-global-set)
      (keymap-set loco-mode-keymap "C-h ,"
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :dt t :kseq [?,] :strip t
                           args)))
      (keymap-set loco-mode-keymap "C-h ."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-describe-kseq :dt t :kseq [?.] :strip t
                           args)))
      (keymap-set loco-mode-keymap ","
                  (lambda ()
                    (interactive)
                     (apply #'loco--cp-execute-kseq :dt t :kseq [?,] :strip t
                           args)))
      (keymap-set loco-mode-keymap "."
                  (lambda ()
                    (interactive)
                    (apply #'loco--cp-execute-kseq :dt t :kseq [?.] :strip t
                           args))))
    ;; invalid configuration
    (t
      (let* ((fn-name "loco-set-standard-configuration")
             (message-str (format "invalid configuration: %s" config)))
        (loco--log 0 "[%s] %s" fn-name message-str)))))

;;;###autoload
(defun loco-unset-standard-configuration (config)
  "Unset the standard configuration based on CONFIG.

Valid options for CONFIG:

shift-return-jk
control‑return‑jk
super‑return‑jk
shift-return-cp
control‑return‑cp
super‑return‑cp
control‑jk
super‑jk
control‑cp
super‑cp
double-tap-cp"
  (cond
    ((or (eq config 'shift-return-jk) (eq config 'shift-return-cp))
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h S-<return>")
      (keymap-unset loco-mode-keymap "S-<return>"))
    ((or (eq config 'control-return-jk) (eq config 'control-return-cp))
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h C-<return>")
      (keymap-unset loco-mode-keymap "C-<return>"))
    ((or (eq config 'super-return-jk) (eq config 'super-return-cp))
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h s-<return>")
      (keymap-unset loco-mode-keymap "s-<return>"))
    ((eq config 'control-jk)
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h C-j")
      (keymap-unset loco-mode-keymap "C-h C-k")
      (keymap-unset loco-mode-keymap "C-j")
      (keymap-unset loco-mode-keymap "C-k"))
    ((eq config 'super-jk)
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h s-j")
      (keymap-unset loco-mode-keymap "C-h s-k")
      (keymap-unset loco-mode-keymap "s-j")
      (keymap-unset loco-mode-keymap "s-k"))
    ((eq config 'control-cp)
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h C-,")
      (keymap-unset loco-mode-keymap "C-h C-.")
      (keymap-unset loco-mode-keymap "C-,")
      (keymap-unset loco-mode-keymap "C-."))
    ((eq config 'super-cp)
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h s-,")
      (keymap-unset loco-mode-keymap "C-h s-.")
      (keymap-unset loco-mode-keymap "s-,")
      (keymap-unset loco-mode-keymap "s-."))
    ((eq config 'double-tap-cp)
      (loco--default-keymap-global-unset)
      (keymap-unset loco-mode-keymap "C-h ,")
      (keymap-unset loco-mode-keymap "C-h .")
      (keymap-unset loco-mode-keymap ",")
      (keymap-unset loco-mode-keymap "."))
    (t
      (let* ((fn-name "loco-unset-standard-configuration")
             (message-str (format "invalid configuration: %s" config)))
        (loco--log 0 "[%s] %s" fn-name message-str)))))

;; Standard configurations
;; Private functions
;; High-level (use of global variables declared herein)

(defun loco--default-keymap-global-set ()
  "Set default key sequences for `loco-mode' and `global-loco-mode'."
  (keymap-global-set "C-c ," #'loco-mode)
  (keymap-global-set "C-c ." #'global-loco-mode))

(defun loco--default-keymap-global-unset ()
  "Set default key sequences for `loco-mode' and `global-loco-mode'."
  (keymap-global-unset "C-c ,")
  (keymap-global-unset "C-c ."))

;; Standard configurations
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--cp-describe-kseq (&rest args)
  "Read and describe a key sequence with parameters focused on `,' and `.'.

This function prompts the user to enter a key sequence and then describes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco--cp-execute-kseq :d t args))

(defun loco--cp-execute-kseq (&rest args)
  "Read and execute a key sequence with parameters focused on `,' and `.'.

This function prompts the user to enter a key sequence and then executes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco-read-kseq :key-am-mod-c-cl nil :key-am-mod-m-cl nil
                          :key-am-s-co ?/ :key-am-s-ex ?/ :key-am-s-op ?m
                          :key-mod-c ?, :key-mod-m ?. args))

(defun loco--jk-describe-kseq (&rest args)
  "Read and describe a key sequence with parameters focused on `j' and `k'.

This function prompts the user to enter a key sequence and then describes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco--jk-execute-kseq :d t args))

(defun loco--jk-execute-kseq (&rest args)
  "Read and execute a key sequence with parameters focused on `j' and `k'.

This function prompts the user to enter a key sequence and then executes the
command to which the key sequence is bound, if any.

ARGS  Additional arguments to be passed to `loco-read-kseq'."
  (interactive)
  (apply #'loco-read-kseq :key-mod-c ?j :key-mod-m ?k args))

;; Keys
;; Private functions
;; High-level (use of global variables declared herein)

(defun loco--invoke-kseq-str (kseq-str)
  "Invoke the command bound to KSEQ-STR in the current context."
  (let* ((keymap (current-active-maps))
         (binding (keymap-lookup keymap kseq-str)))
    (if binding
        (if (commandp binding)
            (let ((command binding))
              (setq real-this-command command
                    this-command command)
              (call-interactively command))))))

;; Keys: Formatting and parsing
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--format-key (key)
  "Format KEY to a string."
  (loco--format-kseq (vector key)))

(defun loco--format-kseq (kseq)
  "Format KSEQ to a string."
  (key-description kseq))

(defun loco--parse-key-str (key-str)
  "Parse KEY-STR to a key."
  (loco--seq-first (loco--parse-kseq-str key-str)))

(defun loco--parse-kseq-str (kseq-str)
  "Parse KSEQ-STR to a kseq."
  (read-kbd-macro kseq-str t))

;; Keys: Lookup and translation
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--lookup-kseq (kseq keymap)
  "Lookup a KSEQ in a KEYMAP.

KSEQ is a sequence of key events.

If KEYMAP is nil, look up in the current keymaps.  If non-nil, it should either
be a keymap or a list of keymaps, and only these keymap(s) will be consulted.

During the lookup process, KSEQ may be translated up to three times through
`input-decode-map', `local-function-key-map', and `key-translation-map',
respectively.  This translation follows the algorithm described in \\[info]
in the section \"Translation Keymaps\".

Returns the pair of the translated KSEQ and a binding; where a binding is a
command, a keymap, t (if reading should continue due to an incomplete
translation), or nil."
  (let ((binding nil)
        (kseq-t1 nil)
        (kseq-t2 nil)
        (kseq-t3 nil)
        (should-continue nil))

    ;; input-decode-map

    (let* ((result (loco--translate-kseq kseq input-decode-map))
           (kseq-t (seq-elt result 0))
           (incomplete (seq-elt result 1)))
      (setq kseq-t1 kseq-t)
      (when incomplete
        (setq should-continue t)))

    ;; lookup kseq-1

    (setq binding (keymap-lookup keymap (key-description kseq-t1)))

    ;; local-function-key-map

    (if (commandp binding)
        (setq kseq-t2 kseq-t1)
      (let* ((result (loco--translate-kseq kseq-t1 local-function-key-map))
             (kseq-t (seq-elt result 0))
             (incomplete (seq-elt result 1)))
        (setq kseq-t2 kseq-t)
        (when incomplete
          (setq should-continue t))))

    ;; key-translation-map

    (let* ((result (loco--translate-kseq kseq-t2 key-translation-map))
           (kseq-t (seq-elt result 0))
           (incomplete (seq-elt result 1)))
      (setq kseq-t3 kseq-t)
      (when incomplete
        (setq should-continue t)))

    ;; lookup kseq-3 (if different from kseq-1)

    (unless (equal kseq-t1 kseq-t3)
      (setq binding (keymap-lookup keymap (key-description kseq-t3))))

    ;; restrict binding to (command, keymap, or should-continue)

    (unless (or (commandp binding) (keymapp binding))
      (setq binding should-continue))

    ;; return kseq-t3 and binding

    (list kseq-t3 binding)))

(defun loco--translate-kseq (kseq translation-keymap)
  "Translate a KSEQ using a TRANSLATION-KEYMAP."
  (let ((incomplete nil)
        (kseq-t (vector)))
    (when (and kseq (sequencep kseq) (keymapp translation-keymap))
      (while (not (seq-empty-p kseq))
        (let ((found nil)
              (sub-kseq-len (seq-length kseq)))
          (while (and (not found) (> sub-kseq-len 0))
            (let* ((sub-kseq (seq-subseq kseq 0 sub-kseq-len))
                   (sub-kseq-str (key-description sub-kseq))
                   (binding (keymap-lookup translation-keymap sub-kseq-str)))
              (cond
                ((and binding (sequencep binding) (not (keymapp binding)))
                  (setq found t
                        kseq (seq-subseq kseq sub-kseq-len)
                        kseq-t (vconcat kseq-t binding)))
                ((and (keymapp binding) (eq sub-kseq-len (seq-length kseq)))
                  (setq found t
                        incomplete t
                        kseq nil
                        kseq-t (vconcat kseq-t sub-kseq)))
                (t
                  (setq sub-kseq-len (1- sub-kseq-len))))))
          (unless found
            (setq kseq-t (vconcat kseq-t (vector (seq-elt kseq 0)))
                  kseq (seq-subseq kseq 1))))))
    (list kseq-t incomplete)))

;; Keys: Modifiers: Adding and removing
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--add-modifiers (e a c h m s sh)
  "Add the specified modifiers to an event.

E   The event to which the modifiers are applied.
A   If non-nil, add the Alt (A-) modifier to the event.
C   If non-nil, add the Control (C-) modifier to the event.
H   If non-nil, add the Hyper (H-) modifier to the event.
M   If non-nil, add the Meta (M-) modifier to the event.
S   If non-nil, add the Super (s-) modifier to the event.
SH  If non-nil, add the Shift (S-) modifier to the event."
  (apply #'loco--set-modifiers e (append (if a '(:a t) nil)
                                         (if c '(:c t) nil)
                                         (if h '(:h t) nil)
                                         (if m '(:m t) nil)
                                         (if s '(:s t) nil)
                                         (if sh '(:sh t) nil))))

(defun loco--remove-modifiers (e a c h m s sh)
  "Remove the specified modifiers from an event.

E   The event to which the modifiers are applied.
A   If non-nil, remove the Alt (A-) modifier from the event.
C   If non-nil, remove the Control (C-) modifier from the event.
H   If non-nil, remove the Hyper (H-) modifier from the event.
M   If non-nil, remove the Meta (M-) modifier from the event.
S   If non-nil, remove the Super (s-) modifier from the event.
SH  If non-nil, remove the Shift (S-) modifier from the event."
  (apply #'loco--set-modifiers e (append (if a '(:a nil) nil)
                                         (if c '(:c nil) nil)
                                         (if h '(:h nil) nil)
                                         (if m '(:m nil) nil)
                                         (if s '(:s nil) nil)
                                         (if sh '(:sh nil) nil))))

(defun loco--set-modifiers (e &rest args)
  "Set the specified modifiers for an event.

E     The event to which the modifiers are applied.

ARGS  Keyword arguments, as described below:

A     If unspecified, do not change the Alt (A-) modifier;
      If non-nil, add the Alt (A-) modifier to the event;
      If nil, remove the Alt (A-) modifier from the event.

C     If unspecified, do not change the Control (C-) modifier;
      If non-nil, add the Control (C-) modifier to the event;
      If nil, remove the Control (C-) modifier from the event.

H     If unspecified, do not change the Hyper (H-) modifier;
      If non-nil, add the Hyper (H-) modifier to the event;
      If nil, remove the Hyper (H-) modifier from the event.

M     If unspecified, do not change the Meta (M-) modifier;
      If non-nil, add the Meta (M-) modifier to the event;
      If nil, remove the Meta (M-) modifier from the event.

S     If unspecified, do not change the Super (s-) modifier;
      If non-nil, add the Super (s-) modifier to the event;
      If nil, remove the Super (s-) modifier from the event.

SH    If unspecified, do not change the Shift (S-) modifier;
      If non-nil, add the Shift (S-) modifier to the event;
      If nil, remove the Shift (S-) modifier from the event."
  (let* ((e-bt (event-basic-type e))
         (e-m (event-modifiers e))
         (a (if (plist-member args :a)
                (not (null (plist-get args :a)))
              (memq 'alt e-m)))
         (c (if (plist-member args :c)
                (not (null (plist-get args :c)))
              (memq 'control e-m)))
         (h (if (plist-member args :h)
                (not (null (plist-get args :h)))
              (memq 'hyper e-m)))
         (m (if (plist-member args :m)
                (not (null (plist-get args :m)))
              (memq 'meta e-m)))
         (s (if (plist-member args :s)
                (not (null (plist-get args :s)))
               (memq 'super e-m)))
         (sh (if (plist-member args :sh)
                 (not (null (plist-get args :sh)))
               (memq 'shift e-m))))
    (if (numberp e)
        (let ((meta-bit (ash 1 27))
              (control-bit (ash 1 26))
              (shift-bit (ash 1 25))
              (hyper-bit (ash 1 24))
              (super-bit (ash 1 23))
              (alt-bit (ash 1 22)))
          (when a
            (setq e-bt (logior e-bt alt-bit)))
          (when c
            (setq e-bt (cond
                         ((<= ?a e-bt ?z)
                           (- e-bt 96))
                         ((<= 64 e-bt 95)
                           (- e-bt 64))
                         (t
                           (logior e-bt control-bit)))))
          (when h
            (setq e-bt (logior e-bt hyper-bit)))
          (when m
            (setq e-bt (logior e-bt meta-bit)))
          (when s
            (setq e-bt (logior e-bt super-bit)))
          (when sh
            (setq e-bt (if (<= ?a e-bt ?z)
                           (- e-bt 32)
                         (logior e-bt shift-bit))))
          e-bt)
      (let ((prefixes (list (cons a "A-")
                            (cons c "C-")
                            (cons h "H-")
                            (cons m "M-")
                            (cons s "s-")
                            (cons sh "S-")))
            (result ""))
        (dolist (prefix prefixes)
          (when (car prefix)
            (setq result (concat result (cdr prefix)))))
        (intern (concat result (symbol-name e-bt)))))))

;; Keys: Modifiers: Formatting
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--format-modifiers (a c h m s sh)
  "Format a string representing the specified modifiers.

A   If non-nil, include the Alt (A-) modifier in the string.
C   If non-nil, include the Control (C-) modifier in the string.
H   If non-nil, include the Hyper (H-) modifier in the string.
M   If non-nil, include the Meta (M-) modifier in the string.
S   If non-nil, include the Super (s-) modifier in the string.
SH  If non-nil, include the Shift (S-) modifier in the string."
  (concat (if a "A-" "")
          (if c "C-" "")
          (if h "H-" "")
          (if m "M-" "")
          (if s "s-" "")
          (if sh "S-" "")))

;; Logging
;; Private functions
;; High-level (use of global variables declared herein)

(defun loco--erase-log-buffer ()
  "Erase the log buffer."
  (let ((log-buffer (get-buffer-create loco-log-buffer-name)))
    (with-current-buffer log-buffer
      (erase-buffer))))

(defun loco--write-message-to-log-buffer (level fmt-str &rest args)
  "Write a message to the log buffer.

LEVEL is a number where 0 is an error, 1 is a warning,
2 is general information, and 3 is for information for debugging purposes.
Any other value is shown numerically.

FMT-STR is a format string, followed by ARGS as in \"format\"."
  (when (<= level loco-log-max-level)
    (let* ((datetime-str (loco--log-datetime-as-styled-string))
           (level-str (loco--log-level-as-styled-string level))
           (message-str (format "[%s] %s %s\n"
                                datetime-str
                                level-str
                                (apply #'format fmt-str args)))
           (log-buffer (get-buffer-create loco-log-buffer-name)))
      (when (and loco-log-show-buffer
                 (null (get-buffer-window log-buffer 'visible)))
        (display-buffer log-buffer))
      (with-current-buffer log-buffer
        (goto-char (point-max))
        (insert message-str)
        (when (get-buffer-window log-buffer 'visible)
          (with-selected-window (get-buffer-window log-buffer)
            (goto-char (point-max))))))))

;; Logging
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--log-datetime-as-styled-string ()
  "Format the current log time as a styled string."
  (let ((str (format-time-string "%FT%T.%3N%z"))
        (style 'italic))
    (propertize str 'face style)))

(defun loco--log-level-as-string (level)
  "Return a string representation for the given LEVEL."
  (pcase level
    (0 "ERROR")
    (1 "WARN ")
    (2 "INFO ")
    (3 "DEBUG")
    (_ (number-to-string level))))

(defun loco--log-level-as-style (level)
  "Return a style for the given LEVEL."
  (pcase level
    (0 '(error bold))
    (1 '(warning bold))
    (_ 'bold)))

(defun loco--log-level-as-styled-string (level)
  "Format the given LEVEL as a styled string."
  (let ((str (loco--log-level-as-string level))
        (style (loco--log-level-as-style level)))
    (propertize str 'face style)))

;; Plists
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--plist-get-d (plist prop default)
  "Get the value of PROP in PLIST, or set it to DEFAULT if not present."
  (if (plist-member plist prop)
      (plist-get plist prop)
    default))

;; Prompting
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--format-am (expanded keys-l keys-mod-cl keys-mod-op key-quit
                        key-s-cl key-s-co key-s-ex key-s-op)
  "Return a formatted string representing the Assist Menu.

EXPANDED      If non-nil, the Assist Menu should show all commands.
KEYS-L        If non-nil, these keys will be treated literally,
              then close the Assist Menu.
KEYS-MOD-CL   If non-nil, these keys will toggle modifiers,
              then close the Assist Menu.
KEYS-MOD-OP   If non-nil, these keys will toggle modifiers,
              but keep the Assist Menu open.
KEY-QUIT      If non-nil, this key will quit.
KEY-S-CL      If non-nil, this key will close the Assist Menu.
KEY-S-CO      If non-nil, this key will collapse the Assist Menu.
KEY-S-EX      If non-nil, this key will expand the Assist Menu.
KEY-S-OP      If non-nil, this key will open the Assist Menu."
  (ignore keys-mod-op)
  (let ((sections (if expanded
                      (list keys-mod-cl
                            (append keys-l (list key-s-op))
                            (list key-quit)
                            (list key-s-cl)
                            (list key-s-co))
                    (list (list key-s-ex)))))
    (concat "[" (loco--format-am-sections sections) "]")))

(defun loco--format-am-key (key)
  "Return a string representation of a KEY.

Given a KEY, this function returns a string representation of the KEY suitable
for display in the Assist Menu.

KEY A key single key."
  (propertize (loco--format-key key) 'face 'help-key-binding))

(defun loco--format-am-section (section)
  "Return a string representation of a SECTION of keys.

Given a SECTION of keys, this function returns a string representation of the
SECTION suitable for display in the Assist Menu.

SECTION A sequence of keys."
  (let* ((non-nil-section (seq-filter #'identity section))
         (strs (mapcar #'loco--format-am-key non-nil-section))
         (compact (seq-every-p #'loco--string-length-one-p strs))
         (delimiter (if compact "" " ")))
    (string-join strs delimiter)))

(defun loco--format-am-sections (sections)
  "Return a string representation of a sequence of SECTIONS of keys.

Given a sequence of SECTIONS of keys, this function returns a string
representation of the SECTIONS suitable for display in the Assist Menu.

SECTIONS A sequence of sections of keys."
  (let* ((strs (mapcar #'loco--format-am-section sections))
         (fn (lambda (str)
               (not (string-empty-p str))))
         (non-empty-strs (seq-filter fn strs)))
    (string-join non-empty-strs " ")))

(defun loco--format-prompt (header-str kseq-o kseq-p kseq-t
                            mod-a mod-c mod-h mod-m mod-s am-str)
  "Return a prompt string with non-empty components joined by spaces.

HEADER-STR  The header string.
KSEQ-O      The original key sequence.
KSEQ-P      The processed key sequence.
KSEQ-T      The translated key sequence.
MOD-A       If non-nil, treat A- as pending.
MOD-C       If non-nil, treat C- as pending.
MOD-H       If non-nil, treat H- as pending.
MOD-M       If non-nil, treat M- as pending.
MOD-S       If non-nil, treat s- as pending.
AM-STR      The Assist Menu as a string."
  (let* ((kseq-o-str (if (vectorp kseq-o)
                         (propertize (loco--format-kseq kseq-o)
                                     'face 'shadow)
                       ""))
         (kseq-p-str (if (vectorp kseq-p)
                         (propertize (loco--format-kseq kseq-o)
                                     'face 'font-lock-constant-face)
                       ""))
         (kseq-t-str (if (vectorp kseq-t) (loco--format-kseq kseq-t) ""))
         (mod-str (loco--format-modifiers mod-a mod-c mod-h mod-m mod-s nil))
         (pending-str (concat mod-str am-str))
         (strs (list header-str kseq-o-str kseq-p-str kseq-t-str pending-str))
         (fn (lambda (str)
               (not (string-empty-p str))))
         (non-empty-strs (seq-filter fn strs)))
    (string-join non-empty-strs " ")))

;; Sequences
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--seq-all-dups (seq)
  "Return the unique set of elements that occurred more than once in SEQ.

Duplicates are returned in the order they were first found in SEQ."
  (when (and seq (sequencep seq) (> (seq-length seq) 0))
    (let ((counts (make-hash-table :test 'equal))
          (dups nil))
      (seq-do (lambda (element)
                (puthash element (1+ (gethash element counts 0)) counts))
              seq)
      (seq-do (lambda (element)
                (when (and (> (gethash element counts) 1)
                           (null (member element dups)))
                  (push element dups)))
              seq)
      (nreverse dups))))

(defun loco--seq-first (seq)
  "Return the first element of SEQ.

If SEQ is a sequence with one or more element, return the first element,
otherwise return nil."
  (when (and seq (sequencep seq) (> (seq-length seq) 0))
    (seq-elt seq 0)))

(defun loco--seq-last (seq)
  "Return the last element of SEQ.

If SEQ is a sequence with one or more elements, return the last element,
otherwise return nil."
  (when (and seq (sequencep seq) (> (seq-length seq) 0))
    (seq-elt seq (1- (seq-length seq)))))

(defun loco--seq-not-first (seq)
  "Return all but the first element of SEQ.

If SEQ is a sequence with one or more element, return all but the first
element, otherwise return nil."
  (when (and seq (sequencep seq) (> (seq-length seq) 0))
    (seq-subseq seq 1)))

(defun loco--seq-not-last (seq)
  "Return all but the last element of SEQ.

If SEQ is a sequence with one or more elements, return all but the last
element, otherwise return nil."
  (when (and seq (sequencep seq) (> (seq-length seq) 0))
    (seq-subseq seq 0 (1- (seq-length seq)))))

;; Sorting
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--sortp (x y)
  "Compare elements X and Y for sorting.

* Elements can be numbers, characters, or symbols.
* Numbers are compared directly.
* Characters are compared directly.
* Symbols are compared lexicographically by their names.
* Numbers are always sorted before characters and symbols.
* Characters are sorted before symbols."
  (cond
    ((and (numberp x) (numberp y))
      (< x y))
    ((and (characterp x) (characterp y))
      (string< (char-to-string x) (char-to-string y)))
    ((and (symbolp x) (symbolp y))
      (string< (symbol-name x) (symbol-name y)))
    ((numberp x)
      t)
    ((numberp y)
      nil)
    ((characterp x)
      t)
    ((characterp y)
      nil)
    (t
      (string< (symbol-name x) (symbol-name y)))))

;; Strings
;; Private functions
;; Low-level (no use of global variables declared herein)

(defun loco--string-length-one-p (str)
  "Return t if STR is a string of length 1."

  (and (stringp str) (eq (length str) 1)))

;; Provision this feature

(provide 'loco)

;;; loco.el ends here
