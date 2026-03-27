;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(define-library (pvec srfi-42-generator)

  (export :generator)

  (import (scheme base)
          (pvec srfi-42))

  (begin

    (include "common/pvec/srfi-42-generator-implementation.scm")

    ))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
