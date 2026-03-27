;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(define-library (pvec)

  (export pvec
          list->pvec
          vector->pvec

          pvec->list
          pvec->vector
          pvec->generator

          pvec?
          pvec-length

          pvec-push
          pvec-pushes ;; elements from list or generator.

          pvec-pop

          pvec-ref
          pvec-set

          pvec-refs ;; Return elements as vector.
          pvec-sets ;; Set elements from vector.
          )

  (import (scheme base)
          (scheme case-lambda)
          (scheme write) ;; For debugging.
          (pvec define-record-factory)
          (pvec srfi-42)
          (pvec srfi-42-generator))

  (cond-expand
    (chicken-5 (import (srfi 1)))
    ((library (scheme list)) (import (scheme list)))
    ((library (srfi 1)) (import (srfi 1)))
    (loko (import (except (srfi :1 lists)
                           map for-each
                           assoc assv assq
                           member memv memq
                           list-copy list cons make-list)))
    (else (import (srfi srfi-1))))
  (cond-expand
    (chicken-5 (import (srfi 143)))
    ((library (scheme fixnum)) (import (scheme fixnum)))
    ((library (srfi 143)) (import (srfi 143)))
    (loko (import (srfi :143 fixnums)))
    (else (import (srfi srfi-143))))

 (begin

    (include "common/pvec/pvec-implementation.scm")

    ))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
