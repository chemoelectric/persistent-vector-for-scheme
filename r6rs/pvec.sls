#!r6rs
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(library (pvec)

  (export pvec
          pvec?
          pvec-length
          pvec-push
          pvec-pushes ;; elements from list or generator.
          pvec-pop
          pvec-ref
          pvec-set
          list->pvec
          pvec->list
          pvec->generator)

  (import (except (rnrs base (6))
                  error
                  for-each map
                  vector-fill! vector->list list->vector)
          (rnrs io simple (6))
          (rnrs control (6))
          (rnrs exceptions (6))
          (rnrs mutable-pairs (6))
          (srfi :1 lists)
          (srfi :23 error)
          (srfi :133 vectors)
          (srfi :143 fixnums)
          (pvec define-record-factory)
          (pvec srfi-42)
          (pvec srfi-42-generator)
          (pvec pvec-include))

  (include "common/pvec/pvec-implementation.scm")

  )

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
