;;;; http://nostdal.org/ ;;;;

(in-package sw)
(in-readtable symbolicweb)


(defmacro with-each-widget-in-tree ((&key (root (error ":ROOT required."))
                                          (widget-sym 'widget)) &body body)
  `(for-each-widget-in-tree ,root
                            (lambda (,widget-sym)
                              (declare (type widget ,widget-sym))
                              ,@body)))


(defmacro with-each-viewport-in-app ((&key (viewport-sym 'viewport) (app '*app*)) &body body)
    "BODY is executed with VIEWPORT-SYM bound to each viewport in WIDGET.
Also see WITH-EACH-VIEWPORT-OF-WIDGET."
    `(for-each-viewport-in-app (lambda (,viewport-sym)
                             (declare (type viewport ,viewport-sym))
                             ,@body)
                           ,app))


(defmacro with-each-viewport-in-server ((&key (viewport-sym '*viewport*) (server '*server*) (app '*app*))
                                        &body body)
  `(maphash (lambda (id ,app)
              (declare (ignore id))
              (with-each-viewport-in-app (:viewport-sym ,viewport-sym :app ,app)
                ,@body))
            (id->app-of ,server)))



;;; code.lisp
;;;;;;;;;;;;;

(defmacro js-code-of (form)
  "Returns the JS code of a single form instead of sending it to the client and
executing it there."
  `(let ((*js-code-only-p* t))
     ,form))


(defmacro with-js-code-from (&body body)
  "All forms within BODY must return JS code.
\(setf (on-click-of button
                    :js-after
                    (with-js-code-from
                      (setf (background-color-of button) \"blue\")
                      (alert \"A button was clicked, it is now blue.\")))
       (iambda (write-line \"A button was clicked on the client, it is now blue.\")))"
  `(let ((*js-code-only-p* t))
     (catstr ,@body)))


(defmacro with-js-code-only (&body body)
  `(let ((*js-code-only-p* t))
     ,@body))


;; The "other end" of this is implemented in APPEND-TO-RESPONSE-DATA-OF in viewport.lisp.
(defmacro with-bulk-update (&body body)
  "This is useful for \"outside\" threads manipulating state.
See examples/comet-test.lisp for usage."
  `(let ((*bulk-update-p* (list t)))
     (unwind-protect
         (progn ,@body)
       (dolist (viewport (cdr *bulk-update-p*))
         (do-comet-response viewport)))))
