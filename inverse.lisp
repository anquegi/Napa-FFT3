(defun %dit (vec start n twiddle)
  (declare (type complex-sample-array vec twiddle)
           (type index start)
           (type size n))
  (labels ((rec (start n)
             (declare (type index start)
                      (type size n)
                      (optimize speed (safety 0)))
             (cond ((>= n 4)
                    (let* ((n/2    (truncate n 2))
                           (start2 (+ start n/2))
                           (n/4    (truncate n/2 2))
                           (start3 (+ start2 n/4)))
                      (rec start3 n/4)
                      (rec start2 n/4)
                      (for (n/4 (i start2)
                                (j start3)
                                (k (+ n/2 +twiddle-offset+) 2))
                        (let* ((t1 (conjugate (aref twiddle k)))
                               (t2 (conjugate (aref twiddle (1+ k))))
                               (x  (* (aref vec i) t1))
                               (y  (* (aref vec j) t2)))
                          (setf (aref vec i) (+ x y)
                                (aref vec j) (mul+i (- x y)))))
                      (rec start n/2)
                      (for (n/2 (i start)
                                (j start2))
                        (let ((x (aref vec i))
                              (y (aref vec j)))
                          (setf (aref vec i) (+ x y)
                                (aref vec j) (- x y))))))
                   ((= n 2)
                    (let ((s0 (aref vec start))
                          (s1 (aref vec (1+ start))))
                      (setf (aref vec start)      (+ s0 s1)
                            (aref vec (1+ start)) (- s0 s1)))
                    nil))))
    (rec start n)
    vec))