;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(display " ===== test-pvec =====\n")

(let ((v (pvec 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
               17 18 19 20 21 22 23 24 25 26 27 28 29
               30 31 32 33 34 35 36 37 38 39 40 41 42
               43 44 45 46 47 48 49 50 51 52 53 54 55)))
  (test-equal 55 (pvec-length v))
  (do-ec (:range i 55)
    (test-equal (+ i 1) (pvec-ref v i))))

(let ((v (vector->pvec
          '#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
               17 18 19 20 21 22 23 24 25 26 27 28 29
               30 31 32 33 34 35 36 37 38 39 40 41 42
               43 44 45 46 47 48 49 50 51 52 53 54 55))))
  (test-equal 55 (pvec-length v))
  (do-ec (:range i 55)
    (test-equal (+ i 1) (pvec-ref v i))))

(let ((v (generator->pvec
          (vector->generator
           '#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
                17 18 19 20 21 22 23 24 25 26 27 28 29
                30 31 32 33 34 35 36 37 38 39 40 41 42
                43 44 45 46 47 48 49 50 51 52 53 54 55)))))
  (test-equal 55 (pvec-length v))
  (do-ec (:range i 55)
    (test-equal (+ i 1) (pvec-ref v i))))

(let ((v1 (list->pvec (iota 1000 1))))
  (test-equal 1000 (pvec-length v1))
  (do-ec (:range i 1000)
    (test-equal (+ i 1) (pvec-ref v1 i)))

  (let ((v2 (pvec-pushes v1 (iota 11000 1001))))
    (test-equal 1000 (pvec-length v1))
    (do-ec (:range i 1000)
      (test-equal (+ i 1) (pvec-ref v1 i)))
    (test-equal 12000 (pvec-length v2))
    (do-ec (:range i 12000)
      (test-equal (+ i 1) (pvec-ref v2 i)))
    ))

(display successes)
(display " successes\n")
(display failures)
(display " failures\n")

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
