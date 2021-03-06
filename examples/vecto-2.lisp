(in-package sw)
(in-readtable symbolicweb)


(defclass vecto-widget-2 (vecto)
  ((vc-font :reader vc-font-of
            :initform (zpb-ttf:open-font-loader
                       (catstr (princ-to-string (user-homedir-pathname))
                               "sw/data/fonts/truetype/mstcorefonts/times.ttf"))))

  (:default-initargs
   :filename "vecto-widget-2"))


(defmethod redraw ((vc vecto-widget-2))
  (vecto:set-rgb-stroke 0 1 0)
  (vecto:set-line-width 10)
  (vecto:rectangle 0 0 (inner-width-of vc) (inner-height-of vc))
  (vecto:stroke)
  (vecto-simple-draw-string "Hello Lisp World!"
                            (vc-font-of vc)
                            (inner-width-of vc)
                            (inner-height-of vc)
                            t))



(defclass vecto-2-app (application)
  ())

(set-uri 'vecto-2-app "vecto-2")


(defmethod render-viewport ((viewport viewport) (app vecto-2-app))
  (insert (with1 (make-instance 'vecto-widget-2)
            (setf (position-of it) "absolute"
                  (width-of it) "50%"
                  (height-of it) "50%"
                  (border-of it) "1px solid black"))
          :in (root)))
