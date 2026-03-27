;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

;;; This source code is based in part on the SRFI-42 reference
;;; implementation, which is licensed as follows:
;;;
;;; Copyright (C) Sebastian Egner (2003). All Rights Reserved.
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;; 
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

(define-syntax :pvec
  ;; This implementation is based closely on the reference
  ;; implementation of ‘:vector’.
  (syntax-rules (index)
    ((:pvec cc var arg)
     (:pvec cc var (index i) arg))
    ((:pvec cc var (index i) arg)
     (:do cc
          (let ((vec arg)
                (len 0)) 
            (set! len (pvec-length vec)))
          ((i 0))
          (fx<? i len)
          (let ((var (pvec-ref vec i))))
          #t
          ((fx+ i 1)) ))

    ((:pvec cc var (index i) arg1 arg2 arg ...)
     (:do cc
          (let ((vec #f)
                (len 0)
                (vecs (ec-:pvec-filter
                       (list arg1 arg2 arg ...))) ))
          ((k 0)
           (i 0))
          (if (fx<? k len)
            #t
            (if (null? vecs)
              #f
              (begin (set! vec (car vecs))
                     (set! vecs (cdr vecs))
                     (set! len (pvec-length vec))
                     (set! k 0)
                     #t)))
          (let ((var (pvec-ref vec k))))
          #t
          ((fx+ k 1)
           (fx+ i 1)) ))

    ((:pvec cc var arg1 arg2 arg ...)
     (:do cc
          (let ((vec #f)
                (len 0)
                (vecs (ec-:pvec-filter
                       (list arg1 arg2 arg ...))) ))
          ((k 0))
          (if (fx<? k len)
            #t
            (if (null? vecs)
              #f
              (begin (set! vec (car vecs))
                     (set! vecs (cdr vecs))
                     (set! len (pvec-length vec))
                     (set! k 0)
                     #t)))
          (let ((var (pvec-ref vec k))))
          #t
          ((fx+ k 1)) ))))

(define (ec-:pvec-filter vecs)
  (if (null? vecs)
    '()
    (if (zero? (pvec-length (car vecs)))
      (ec-:pvec-filter (cdr vecs))
      (cons (car vecs)
            (ec-:pvec-filter (cdr vecs))) )))

(define-syntax pvec-ec
  ;; This implementation uses a buffer and pvec-pushes. A simpler but
  ;; generally slower implementation could use fold-ec and pvec-push.
  (syntax-rules (nested)
    ((pvec-ec (nested q1 ...) q etc1 etc2 etc ...)
     (pvec-ec (nested q1 ... q) etc1 etc2 etc ...) )
    ((pvec-ec q1 q2 etc1 etc2 etc ...)
     (pvec-ec (nested q1 q2) etc1 etc2 etc ...) )
    ((pvec-ec expression)
     (pvec-ec (nested) expression) )
    ((pvec-ec qualifier expression)
     (let-syntax ((n (syntax-rules () ((n) 128))))
       (let ((result (pvec)))
         (let* ((buffer (make-vector (n)))
                (make-generator
                 (lambda (m)
                   (let ((j 0))
                     (lambda ()
                       (if (fx=? j m)
                         (eof-object)
                         (let ((result (vector-ref buffer j)))
                           (set! j (fx+ j 1))
                           result))))))
                (i 0))
           (do-ec qualifier
             (begin
               (when (fx=? i (n))
                 (let ((gen! (make-generator (n))))
                   (set! result (pvec-pushes result gen!)))
                 (set! i 0))
               (vector-set! buffer i expression)
               (set! i (fx+ i 1))))
           (let ((gen! (make-generator i)))
             (set! result (pvec-pushes result gen!))))
         result)))))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
