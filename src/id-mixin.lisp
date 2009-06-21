;;;; http://nostdal.org/ ;;;;

(in-package #:sw)

(declaim #.(optimizations :id-mixin.lisp))


(defclass id-mixin ()
  ((id :reader id-of
       :type string)))


(defmethod initialize-instance :before ((object id-mixin) &key (id nil id-supplied-p))
  (let ((id (if id-supplied-p
                id
                (catstr (string (type-of object)) "-" (generate-id)))))
    (setf (slot-value object 'id) id)
    (when +global-object-access-p+
      (setf (gethash id *id->object*) object))))


;; TODO: Check +global-object-access-p+ and generate code which calls ERROR when NIL .. tho, inlining kinda screws this up.
#.(maybe-inline 'get-obj)
(defun get-obj (id)
  (declare (string id))
  (gethash id *id->object*))


(defmethod print-object ((id-mixin id-mixin) stream)
  (if (slot-boundp id-mixin 'id)
      (print-unreadable-object (id-mixin stream :type nil :identity nil)
        (format stream "~A" (slot-value id-mixin 'id))
        (print-slots id-mixin stream))
      (print-unreadable-object (id-mixin stream :type t :identity t)
        (print-slots id-mixin stream))))
