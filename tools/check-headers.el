;;; check-headers.el --- Validate .el headers against expected values
;;; (URL then Version) -*- lexical-binding: t; -*-

;; Usage (from any shell or build tool):
;;   EXPECT_FILE="path/to/file.el" \
;;   EXPECT_URL="https://example.com/repo" \
;;   EXPECT_VERSION="1.0.0" \
;;     emacs -Q --batch -l lisp-mnt -l path/to/check-headers.el
;;
;; Notes:
;; - Only the `URL:` and `Version:` headers are considered.
;; - EXPECT_URL and EXPECT_VERSION are optional; when set, their values
;;   must exactly match the corresponding headers in the target file.
;; - String comparisons are exact, after trimming and removing text properties.
;;
;; Exit status:
;; - 0: all requested checks passed.
;; - 1: an error occurred (file or header missing, or header mismatch).

(require 'lisp-mnt)
(require 'subr-x)

(defun check-headers--fatal (fmt &rest args)
  "Print a formatted error and exit Emacs with status 1."
  (princ (apply #'format (concat "ERROR: " fmt "\n") args) t)
  (kill-emacs 1))

(defun check-headers--normalize (s)
  "Trim S and strip text properties; return an empty string for nil."
  (substring-no-properties (string-trim (or s ""))))

(defun check-headers--read-header (name)
  "Read header NAME from current buffer; return empty string if absent."
  (save-excursion
    (goto-char (point-min))
    (or (lm-header name) "")))

(when noninteractive
  (let* ((file (or (getenv "EXPECT_FILE")
                   (check-headers--fatal "EXPECT_FILE not set")))
         (abs-file (expand-file-name file))
         (buf nil)
         (expected-url (or (getenv "EXPECT_URL") ""))
         (expected-version (or (getenv "EXPECT_VERSION") ""))
         found-url
         found-version)

    (unless (file-readable-p abs-file)
      (check-headers--fatal "Unable to read file: %s" abs-file))

    (setq buf (find-file-noselect abs-file))
    (unwind-protect
        (with-current-buffer buf
          (setq found-url (check-headers--read-header "URL")
                found-version (check-headers--read-header "Version")))
      (when (buffer-live-p buf)
        (kill-buffer buf)))

    (setq expected-url (check-headers--normalize expected-url))
    (setq expected-version (check-headers--normalize expected-version))
    (setq found-url (check-headers--normalize found-url))
    (setq found-version (check-headers--normalize found-version))

    (princ (format "Reading: %s\n" abs-file))
    (princ (format "Found headers:\n  URL: %s\n  Version: %s\n"
                   (if (string-empty-p found-url) "<none>" found-url)
                   (if (string-empty-p found-version) "<none>" found-version)))

    (when (not (string-empty-p expected-url))
      (when (string-empty-p found-url)
        (check-headers--fatal
         "URL header missing; expected=%s"
         expected-url))
      (when (not (string= found-url expected-url))
        (check-headers--fatal
         "URL mismatch: expected=%s found=%s"
         expected-url found-url)))

    (when (not (string-empty-p expected-version))
      (when (string-empty-p found-version)
        (check-headers--fatal
         "Version header missing; expected=%s"
         expected-version))
      (when (not (string= found-version expected-version))
        (check-headers--fatal
         "Version mismatch: expected=%s found=%s"
         expected-version found-version)))

    (princ "Header checks passed.\n")
    (kill-emacs 0)))

(provide 'check-headers)

;;; check-headers.el ends here
