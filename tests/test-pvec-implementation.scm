;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(display " ===== test-pvec =====\n")

(define vector->generator
  (case-lambda
    ((vec start end)
     (let ((i start))
       (lambda ()
         (if (fx=? i end)
           (eof-object)
           (let ((elem (vector-ref vec i)))
             (set! i (fx+ i 1))
             elem)))))
    ((vec start)
     (vector->generator vec start (vector-length vec)))
    ((vec)
     (vector->generator vec 0 (vector-length vec)))))

(define (shuffle vec)
  (let ((n (vector-length vec)))
    (do-ec (nested (:range i+1 n 1 -1)
                   (:let i (- i+1 1))
                   (:let j (random-integer i+1)))
      (let ((temp (vector-ref vec i)))
        (vector-set! vec i (vector-ref vec j))
        (vector-set! vec j temp)))))
      
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

(test-equal 0 (pvec-length (pvec)))
(test-equal 0 (pvec-length (list->pvec '())))
(test-equal 0 (pvec-length (vector->pvec '#())))
(test-equal 0 (pvec-length (generator->pvec (lambda () (eof-object)))))
(test-equal 0 (pvec-length (pvec-pop (pvec) 0)))
(test-equal 0 (pvec-length (pvec-push (pvec))))
(test-equal 0 (pvec-length (pvec-pop (pvec) 0)))
(test-equal 0 (pvec-length (pvec-pushes (pvec) '#())))
(test-equal 0 (pvec-length (pvec-pushes (pvec) '#(1 2 3) 3)))
(test-equal 0 (pvec-length (pvec-pushes (pvec) '#(1 2 3) 2 2)))
(test-equal 0 (pvec-length (pvec-pop (list->pvec (iota 1000)) 1000)))
(test-equal 0 (pvec-length (pvec-pop (pvec-pushes (list->pvec (iota 1000))
                                                  '#(1 2 3 4 5))
                                     1005)))
(test-equal 0 (pvec-length (generator->pvec (lambda () 1) 0)))

(test-equal 5 (pvec-length (pvec 1 2 3 4 5)))
(test-equal 1000 (pvec-length (list->pvec (iota 1000))))
(test-equal 5 (pvec-length (pvec-pop (list->pvec (iota 1005)) 1000)))

(test-equal 5 (pvec-length (vector->pvec '#(1 2 3 4 5))))
(test-equal 1000 (pvec-length (vector->pvec (list->vector (iota 1000)))))
(test-equal 5 (pvec-length (vector->pvec (list->vector (iota 1000)) 995)))
(test-equal 5 (pvec-length (vector->pvec (list->vector (iota 1000)) 900 905)))

(test-equal 5 (pvec-length (generator->pvec (lambda () 1) 5)))
(test-equal '#(1 1 1 1 1) (pvec-refs (generator->pvec (lambda () 1) 5)))
(test-equal '#(1 1 1 1 1) (pvec->vector (generator->pvec (lambda () 1) 5)))
(test-equal 1000 (pvec-length (generator->pvec
                               (vector->generator
                                (vector-ec (:range i 1000) i)))))
(test-equal (vector-ec (:range i 1000) i)
  (pvec-refs (generator->pvec (vector->generator
                               (vector-ec (:range i 1000) i)))))

(test-equal (iota 300) (pvec->list (pvec-ec (:range i 300) i)))
(test-equal (iota 200 100) (pvec->list (pvec-ec (:range i 100 300) i)))
(test-equal (iota 100 100 2) (pvec->list (pvec-ec (:range i 100 300 2) i)))
(test-equal (list->vector (iota 300)) (pvec->vector (pvec-ec (:range i 300) i)))
(test-equal (list->vector (iota 200 100)) (pvec->vector (pvec-ec (:range i 100 300) i)))
(test-equal (list->vector (iota 100 100 2)) (pvec->vector (pvec-ec (:range i 100 300 2) i)))
(test-equal (list->vector (iota 300)) (pvec-refs (pvec-ec (:range i 300) i)))
(test-equal (list->vector (iota 200 100)) (pvec-refs (pvec-ec (:range i 100 300) i)))
(test-equal (list->vector (iota 100 100 2)) (pvec-refs (pvec-ec (:range i 100 300 2) i)))
(test-equal (iota 300) (list-ec (:generator j (pvec->generator (pvec-ec (:range i 300) i))) j))
(test-equal (iota 200 100) (list-ec (:generator j (pvec->generator (pvec-ec (:range i 100 300) i))) j))
(test-equal (iota 100 100 2) (list-ec (:generator j (pvec->generator (pvec-ec (:range i 100 300 2) i))) j))

(test-assert (pvec? (pvec)))
(test-assert (not (pvec? 1)))
(test-assert (not (pvec? #f)))
(test-assert (not (pvec? "pvec")))

(let ((pv (pvec-ec (:range i 10000) (number->string i 16))))
  (do-ec (:range i 10000) (test-equal (number->string i 16) (pvec-ref pv i)))
  (test-equal (vector-ec (:range i 10000) (number->string i 16)) (pvec-refs pv))
  (test-equal (vector-ec (:range i 5000) (number->string i 16)) (pvec-refs pv 0 5000))
  (test-equal (vector-ec (:range i 5000 10000) (number->string i 16)) (pvec-refs pv 5000 10000)))

(let ((pv (pvec-ec (:range i 10000) (number->string i 16))))
  (do-ec (:range i 10000) (set! pv (pvec-set pv i (number->string i 8))))
  (do-ec (:range i 10000) (test-equal (number->string i 8) (pvec-ref pv i))))

(let ((pv (pvec-ec (:range i 10000) (number->string i 16))))
  (do-ec (:range i 10000) (set! pv (pvec-set pv (fx- 9999 i) (number->string i 8))))
  (do-ec (:range i 10000) (test-equal (number->string i 8) (pvec-ref pv (fx- 9999 i)))))

(let ((pv (pvec-ec (:range i 10000) (number->string i 16)))
      (vec (vector-ec (:range i 10000) i)))
  (shuffle vec)
  (do-ec (:range i 10000) (set! pv (pvec-set pv (vector-ref vec i) (number->string i 8))))
  (do-ec (:range i 10000) (test-equal (number->string i 8) (pvec-ref pv (vector-ref vec i)))))

(let ((pv (pvec-ec (:range i 10000) (number->string i 16)))
      (vec (vector-ec (:range i 10000) i)))
  (set! pv (pvec-sets pv 0 vec))
  (do-ec (:range i 10000)
    (test-assert (= (vector-ref vec i) (pvec-ref pv i))))
  (test-equal vec (pvec-refs pv))
  (test-equal vec (pvec->vector pv)))

(do ((n 1 (+ n 1)))
    ((= n 31))
  (let ((pv (pvec-ec (:range i 10000) (number->string i 16)))
        (vec (vector-ec (:range i 10000) i)))
    (let ((j (random-integer 10000)))
      (set! pv (pvec-sets pv j vec j))
      (do-ec (:range i 10000)
        (test-assert (if (< i j)
                       (string=? (number->string i 16) (pvec-ref pv i))
                       (= (vector-ref vec i) (pvec-ref pv i)))))
      (test-equal (vector-ec (:range i j) (number->string i 16))
        (pvec-refs pv 0 j))
      (test-equal (vector-ec (:range i j) (number->string i 16))
        (pvec->vector pv 0 j))
      (test-equal (vector-ec (:range i j 10000) (vector-ref vec i))
        (pvec-refs pv j))
      (test-equal (vector-ec (:range i j 10000) (vector-ref vec i))
        (pvec->vector pv j))
      )))

(do ((n 1 (+ n 1)))
    ((= n 31))
  (let ((pv (pvec-ec (:range i 10000) (number->string i 16)))
        (vec (vector-ec (:range i 10000) i)))
    (let ((j (random-integer 10000)))
      (set! pv (pvec-sets pv j vec 0 (- 10000 j)))
      (do-ec (:range i 10000)
        (test-assert (if (< i j)
                         (string=? (number->string i 16) (pvec-ref pv i))
                         (= (vector-ref vec (- i j)) (pvec-ref pv i)))))
      (test-equal (vector-ec (:range i j) (number->string i 16))
        (pvec-refs pv 0 j))
      (test-equal (vector-ec (:range i j) (number->string i 16))
        (pvec->vector pv 0 j))
      (test-equal (vector-ec (:range i (- 10000 j)) (vector-ref vec i))
        (pvec-refs pv j))
      (test-equal (vector-ec (:range i (- 10000 j)) (vector-ref vec i))
        (pvec->vector pv j))
      )))


(let ((pv (pvec-ec (:range i 10000) (number->string i 16)))
      (vec (vector-ec (:range i 10000) i)))
  (let ((j (- 10000 10))) ;; Tail only.
    (set! pv (pvec-sets pv j vec j))
    (do-ec (:range i 10000)
      (test-assert (if (< i j)
                     (string=? (number->string i 16) (pvec-ref pv i))
                     (= (vector-ref vec i) (pvec-ref pv i)))))
    (test-equal (vector-ec (:range i j) (number->string i 16))
      (pvec-refs pv 0 j))
    (test-equal (vector-ec (:range i j) (number->string i 16))
      (pvec->vector pv 0 j))
    (test-equal (vector-ec (:range i 10) (+ i j))
      (pvec-refs pv j))
    (test-equal (vector-ec (:range i 10) (+ i j))
      (pvec->vector pv j))
    ))

(let ((pv (pvec))
      (lst (iota 10000)))
  (do-ec (:range i 10000) (set! pv (pvec-push pv i)))
  (test-equal lst (pvec->list pv))
  (set! pv (pvec-push pv 1 2 3 4 5 6 7 8 9 10))
  (set! lst (append! lst (list 1 2 3 4 5 6 7 8 9 10)))
  (test-equal lst (pvec->list pv)))

(let ((pv (pvec-push (pvec) 1 2 3 4 5 6 7 8 9 10))
      (lst (list 1 2 3 4 5 6 7 8 9 10))
      (iota1000 (iota 1000)))
  (test-equal lst (pvec->list pv))
  (set! pv (pvec-pushes pv iota1000))
  (set! lst (append! lst iota1000))
  (test-equal lst (pvec->list pv)))

(let ((pv (pvec-push (pvec) 1 2 3 4 5 6 7 8 9 10))
      (lst (list 1 2 3 4 5 6 7 8 9 10))
      (iota1000 (iota 1000)))
  (test-equal lst (pvec->list pv))
  (set! pv (pvec-pushes pv (list->vector iota1000)))
  (set! lst (append! lst iota1000))
  (test-equal lst (pvec->list pv)))

(let ((pv (pvec-push (pvec) 1 2 3 4 5 6 7 8 9 10))
      (lst (list 1 2 3 4 5 6 7 8 9 10))
      (iota1000 (iota 1000)))
  (test-equal lst (pvec->list pv))
  (set! pv (pvec-pushes pv (list->vector iota1000) 500))
  (set! lst (append! lst (drop iota1000 500)))
  (test-equal lst (pvec->list pv)))

(let ((pv (pvec-push (pvec) 1 2 3 4 5 6 7 8 9 10))
      (lst (list 1 2 3 4 5 6 7 8 9 10))
      (iota1000 (iota 1000)))
  (test-equal lst (pvec->list pv))
  (set! pv (pvec-pushes pv (list->vector iota1000) 5 500))
  (set! lst (append! lst (drop (take iota1000 500) 5)))
  (test-equal lst (pvec->list pv)))

(let ((pv (pvec-ec (:range i 10000) i)))
  (do-ec
   (:range i 10000)
   (begin
     (when (fxzero? (random-integer 10))
       (test-equal (iota (- 10000 i)) (pvec->list pv)))
     (set! pv (pvec-pop pv)))))

(let ((pv (pvec-ec (:range i 10000) i)))
  (do-ec
   (:range i 0 10000 10)
   (begin
     (test-equal (iota (- 10000 i)) (pvec->list pv)))
     (set! pv (pvec-pop pv 10))))

(let ((pv (pvec-ec (:range i 10000) i)))
  (do-ec
   (:range i 0 10000 100)
   (begin
     (test-equal (iota (- 10000 i)) (pvec->list pv)))
     (set! pv (pvec-pop pv 100))))

(test-equal '(5 4 3 2 1 0) (pvec-fold cons '(0) (pvec 1 2 3 4 5)))
(test-equal '(c 3 b 2 a 1) (pvec-fold cons* '() (pvec 'a 'b 'c) (pvec 1 2 3 4 5)))
(test-equal '(1 2 3 4 5 6) (pvec-fold-right cons '(6) (pvec 1 2 3 4 5)))
(test-equal '(a 1 b 2 c 3) (pvec-fold-right cons* '() (pvec 'a 'b 'c) (pvec 1 2 3 4 5)))

(test-equal (iota 1000) (list-ec (:pvec i (list->pvec (iota 1000))) i))
(test-equal (iota 1000) (list-ec (:pvec i (list->pvec (iota 250))
                                        (list->pvec (iota 250 250))
                                        (list->pvec (iota 250 500))
                                        (list->pvec (iota 250 750))) i))

(test-equal (iota 1000) (list-ec (:generator i (vector->generator (list->vector (iota 250)))
                                             (vector->generator (list->vector (iota 250 250)))
                                             (vector->generator (list->vector (iota 250 500)))
                                             (vector->generator (list->vector (iota 250 750)))) i))

(test-equal (iota 1000) (pvec->list (pvec-ec (:pvec i (list->pvec (iota 1000))) i)))

(display successes)
(display " successes\n")
(display failures)
(display " failures\n")

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
