;;;; http://nostdal.org/ ;;;;

(in-package sw)
(in-readtable symbolicweb)
(declaim #.(optimizations :widgets/combo-box.lisp))


(defclass combo-box (container)
  ((selected-option :reader selected-option-of
                    :initform nil))

  (:default-initargs
   :element-type "select"
   :model (make-instance 'sw-mvc:container-with-1-active-item)))
(export 'combo-box)



(defclass combo-box-option (html-element)
  ((combo-box :reader combo-box-of :initarg :combo-box
              :initform (error ":COMBO-BOX needed.")))

  (:default-initargs
   :element-type "option"
   :model λV""))
(export 'combo-box-option)


(defmethod render :after ((combo-box-option combo-box-option))
  (setf (value-of combo-box-option)
        (id-of combo-box-option)))


(defmethod view-constructor ((combo-box combo-box) (model cell))
  (make-instance 'combo-box-option :combo-box combo-box :model model))


(defmethod set-model nconc ((combo-box combo-box) (model container-with-1-active-item))
  (list λI(let* ((active-item (active-item-of model))
                 (item-model active-item)
                 (item-view (when item-model (view-in-context-of combo-box item-model))))
            ;; Model → View.
            (when-commit ()
              (let ((old-item-view (selected-option-of combo-box)))
                (unless (eq item-view old-item-view)
                  (when item-view
                    (tf (selected-p-of item-view)))
                  (when old-item-view
                    (nilf (selected-p-of old-item-view :server-only-p t)))
                  (setf (slot-value combo-box 'selected-option) item-view)))))

        λI(when-let* ((item-view (on-combo-box-change-of combo-box))
                      (item-model (model-of item-view)))
            ;; View → Model.
            (when-commit ()
              (let ((old-item-view (selected-option-of combo-box)))
                (unless (eq item-view old-item-view)
                  (tf (selected-p-of item-view :server-only-p t))
                  (when old-item-view
                    (nilf (selected-p-of (selected-option-of combo-box) :server-only-p t)))
                  (setf (slot-value combo-box 'selected-option) item-view))))
            (setf (active-item-of model) item-model))))



(define-event-property
    (on-combo-box-change-of "change" :callback-data (list (cons "value" (js-code-of (value-of widget))))))


(defmethod initialize-callback-box ((combo-box combo-box) (lisp-accessor-name (eql 'on-combo-box-change-of))
                                    (callback-box callback-box))
  (setf (argument-parser-of callback-box)
        (lambda (args)
          (get-widget (cdr (assoc "value" args :test #'string=))))))




#|(progn
  (remove-all (root))
  (with (make-instance 'combo-box :id "blah")
    (let ((b λV"b"))
      (insert λV"a" :in it)
      (insert b :in it)
      (insert λV"c" :in it)
      (setf (active-item-of ~it) b))
    (insert it :in (root))))|#

#|(define-symbol-macro =blah=  ~(get-widget "blah"))|#