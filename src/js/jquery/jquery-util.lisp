;;;; http://nostdal.org/ ;;;;

(in-package :sw-jquery)

(declaim #.(optimizations))


(let ((counter 0))
  (declare (integer counter))
  (defun js-genid (&optional str)
    (declare (optimize (speed 3) (debug 0) (safety 0) (space 0))
             (sb-ext:muffle-conditions sb-ext:compiler-note))
    (if str
        (catstr str "-" (princ-to-string (incf counter)))
        (princ-to-string (incf counter)))))
(export 'js-genid)


#|(declaim (inline js-callback-data))|#
(defun js-callback-data (callback-data)
  "Convert from Lisp ((\"key\" . \"value\"))
to URL type string; \"key=value&other-key=other-value\""
  (declare (list callback-data))
  (unless callback-data (return-from js-callback-data ""))
  ;; TODO: Try to make this faster/nicer.
  (subseq (with-output-to-string (s)
            (dolist (name-value-pair callback-data)
              (princ "&" s)
              (princ (url-encode (let ((name (car name-value-pair)))
                                   (if (keywordp name)
                                       (string-downcase name)
                                       name)))
                     s)
              (princ "=" s)
              ;; The values must really be JS expressions like "return 42;" because this allows us to also return
              ;; results of evaluating JS code on the client-side.
              (princ (catstr "\" + encodeURIComponent((function(){ "
                             (let ((value (cdr name-value-pair)))
                               (etypecase value
                                 (string value)
                                 (list (ps:ps* value))))
                             " })()) + \"")
                     s)))
          1))
(export 'js-callback-data)


(defun js-msg (widget-id callback-id &key
               (js-before '(lambda () (return t)))
               (callback-data nil)
               (js-after '(lambda (data text-status)))
               (browser-default-action-p t)
               (context-sym 'context))
  (declare (string widget-id callback-id))
  (ps:ps* `(lambda (,context-sym)
             (sw-msg ,widget-id ,callback-id
                     ,js-before
                     ,(js-callback-data callback-data)
                     ,js-after)
             (return ,browser-default-action-p))))
(export 'js-msg)


(declaim (inline js-focus))
(defun js-focus (selector)
  (declare (string selector))
  ;; TODO: Firefox has a bug that requires one to add a silly delay like this in some cases. I need to research this further.
  ;; https://bugzilla.mozilla.org/show_bug.cgi?id=53579
  ;; https://bugzilla.mozilla.org/show_bug.cgi?id=297134
  ;; TODO: Ok, seems Firefox-3.x has fixed this but, uh, IE6.x still requires this in some cases ...
  (catstr "setTimeout(function(){ $(\"#" selector "\").focus(); }, 100);"))
(export 'js-focus)


(declaim (inline js-scroll-to-bottom))
(defun js-scroll-to-bottom (selector)
  (declare (string selector))
  (catstr "$(\"#" selector "\").get(0).scrollTop = $(\"" selector "\").get(0).scrollHeight + 1000;"))
(export 'js-scroll-to-bottom)