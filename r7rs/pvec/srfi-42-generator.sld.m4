m4_changequote(“,”)m4_changecom“”m4_dnl
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(define-library (pvec srfi-42-generator)

  (export :generator)

  (import (scheme base)
          (pvec srfi-42))

  (begin

    m4_include(“common/pvec/srfi-42-generator-implementation.scm”)

    ))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
