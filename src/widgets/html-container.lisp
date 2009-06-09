;;;; http://nostdal.org/ ;;;;

(in-package #:sw)

(declaim #.(optimizations))


(defclass html-container (container)
  ((html-content :initarg :html-content
                 :type function
                 :initform (error ":HTML-CONTENT needed. Hint: Use the MK-HTMLC macro.")))

  (:default-initargs
   :model nil))
(export 'html-container)


(defmethod generate-html :around ((html-container html-container))
  (let ((*creating-html-container-p* html-container)
        (*html-container-children* nil))
    (prog1 (call-next-method)
      (when-let ((additional-children (set-difference *html-container-children* (children-of html-container)
                                                      :test #'eq)))
        (apply #'add-to html-container additional-children))
      (when-let ((removed-children (set-difference (children-of html-container) *html-container-children*
                                                   :test #'eq)))
        (dolist (child removed-children)
          (remove child html-container))))))
(export 'generate-html)


(defmethod generate-html ((html-container html-container))
  (funcall (slot-value html-container 'html-content)))
(export 'generate-html)


(defmethod update-client ((html-container html-container))
  (run (setf (js-html-of (id-of html-container))
             (html<- (generate-html html-container) html-container))
       html-container)
  (dolist (child (children-of html-container))
    (render child)))
(export 'update-client)


(defmethod render ((html-container html-container))
  (update-client html-container))
(export 'render)


(defmacro mk-htmlc (args &body html)
  (if (listp args)
      `(make-instance 'html-container
                      :html-content (lambda () (who ,@html))
                      ,@args)
      `(make-instance 'html-container
                      :element-type (princ-to-string ,args)
                      :html-content (lambda () (who ,@html)))))
(export 'mk-htmlc)