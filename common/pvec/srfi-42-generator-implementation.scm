
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(define-syntax :generator
  (syntax-rules (index)
    ((¶ cc var (index i) arg)
     (:do cc
          (let ((gen! arg)))
          ((var (gen!)) (i 0))
          (not (eof-object? var))
          (let ())
          #t
          ((gen!) (+ i 1))))
    ((¶ cc var (index i) arg1 arg2 ...)
     (:do cc
          (let ()
            (define gen* (list arg1 arg2 ...))
            (define (gen!)
              (let loop1 ((v ((car gen*))))
                (if (eof-object? v)
                  (begin
                    (set! gen* (cdr gen*))
                    (if (null? gen*)
                      (eof-object)
                      (loop1 ((car gen*)))))
                  v))))
          ((var (gen!)) (i 0))
          (not (eof-object? var))
          (let ())
          #t
          ((gen!) (+ i 1))))
    ((¶ cc var arg)
     (:do cc
          (let ((gen! arg)))
          ((var (gen!)))
          (not (eof-object? var))
          (let ())
          #t
          ((gen!))))
    ((¶ cc var arg1 arg2 ...)
     (:do cc
          (let ()
            (define gen* (list arg1 arg2 ...))
            (define (gen!)
              (let loop1 ((v ((car gen*))))
                (if (eof-object? v)
                  (begin
                    (set! gen* (cdr gen*))
                    (if (null? gen*)
                      (eof-object)
                      (loop1 ((car gen*)))))
                  v))))
          ((var (gen!)))
          (not (eof-object? var))
          (let ())
          #t
          ((gen!))))))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
