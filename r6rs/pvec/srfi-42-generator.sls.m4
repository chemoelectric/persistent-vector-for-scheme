m4_changequote(“,”)m4_changecom“”m4_dnl
#!r6rs
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(library (pvec srfi-42-generator)

  (export :generator)

  (import (except (rnrs (6)) error)
          (pvec srfi-42)
          (pvec pvec-include))

  m4_include(“common/pvec/srfi-42-generator-implementation.scm”)

  )

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
