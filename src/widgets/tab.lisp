;;;; http://nostdal.org/ ;;;;

(in-package sw)
(in-readtable symbolicweb)

#| TODO:
Update ACTIVE-ITEM slot when user selects a tab on the client end.
Update tab on the client end when ACTIVE-ITEM slot is changed.

LABEL (in TAB-PANE) needs to do the dataflow thing.
|#


(defclass tab-pane (container)
  ((label :reader label-of :initarg :label
          :initform (error ":LABEL needed."))))



(defclass tab (abstract-container)
  ()
  (:default-initargs
   :element-type "div"
   :model (make-instance 'sw-mvc:container-with-1-active-item
                         :model (make-instance 'sw-mvc:dlist))))


(defmethod view-constructor ((tab tab) (pair pair))
  (make-instance 'tab-pane
                 :label ~(sw-mvc:left-of pair)
                 :model (with1 (sw-mvc:right-of pair)
                          (check-type it multiple-value-model))))


(defmethod render ((tab tab))
  (with (id-of tab)
    (run (js-iappend "<ul></ul>" it) tab)
    (run (fmtn "$('#~A').tabs();~%" it) tab)
    (dolist (child (children-of tab))
      (check-type child tab-pane)
      (run (fmtn "$(\"#~A\").tabs(\"add\", \"#~A\", decodeURIComponent(\"~A\"));~%"
                 it (id-of child) (url-encode (label-of child)))
           tab)
      (render child))))


(defmethod set-model nconc ((tab tab) (model container-with-1-active-item))
  )


(defmethod container-insert ((tab tab) tab-pane &key before after)
  #| NOTE: So we don't dispatch to (CONTAINER-INSERT CONTAINER WIDGET ..) where the operation/event will succeed. |#
  (check-type tab-pane tab-pane)
  (when-let (it (or before after))
    (check-type it tab-pane))
  (when-commit ()
    ;; TODO: I can probably merge some of this together..
    (cond
      (after
       (amx:insert tab-pane ↺(slot-value tab 'children) :after after)
       (when (visible-p-of tab)
         (propagate-for-add tab-pane tab)
         (run (fmtn "$(\"#~A\").tabs(\"add\", \"#~A\", decodeURIComponent(\"~A\"), ~A);~%"
                    (id-of tab) (id-of tab-pane) (url-encode (label-of tab-pane))
                    (position tab-pane (slot-value tab 'children)))
              tab)
         (render tab-pane)))

      (before
       (amx:insert tab-pane ↺(slot-value tab 'children) :before before)
       (when (visible-p-of tab)
         (propagate-for-add tab-pane tab)
         (run (fmtn "$(\"#~A\").tabs(\"add\", \"#~A\", decodeURIComponent(\"~A\"), ~A);~%"
                    (id-of tab) (id-of tab-pane) (url-encode (label-of tab-pane))
                    (position tab-pane (slot-value tab 'children)))
              tab)
         (render tab-pane)))

      (t
       (amx:insert tab-pane ↺(slot-value tab 'children) :last-p t)
       (when (visible-p-of tab)
         (propagate-for-add tab-pane tab)
         (run (fmtn "$(\"#~A\").tabs(\"add\", \"#~A\", decodeURIComponent(\"~A\"));~%"
                    (id-of tab) (id-of tab-pane) (url-encode (label-of tab-pane)))
              tab)
         (render tab-pane))))))


(defmethod container-remove ((tab tab) (tab-pane tab-pane))
  (when-commit ()
    (let ((pos (position tab-pane (slot-value tab 'children))))
      (deletef (slot-value tab 'children) tab-pane)
      (when (visible-p-of tab)
        (run (fmtn "$(\"#~A\").tabs(\"remove\", ~A);~%"
                   (id-of tab) pos)
             tab)
        (propagate-for-remove tab-pane)))))




#|(remove-all (root))|#

#|(with (make-instance 'tab)
  (insert it :in (root))
  (insert (mk-pair λv"label-1" (dlist λv"content-1")) :in it)
  (insert (mk-pair λv"label-2" (dlist λv"content-2")) :in it)
  (let ((tab-pane-m (mk-pair λv"label-3" (dlist))))
    (insert tab-pane-m :in it)
    (insert (div "Hello World!") :in (view-in-context-of it tab-pane-m))))|#
