#!r6rs
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(library (pvec eager-comprehensions)

  (export do-ec
          list-ec
          append-ec
          string-ec
          string-append-ec
          vector-ec
          vector-of-length-ec
          sum-ec
          product-ec
          min-ec
          max-ec
          any?-ec
          every?-ec
          first-ec
          last-ec
          fold-ec
          fold3-ec

          ;; We do not export dispatched generators. They have to be
          ;; made to work with a Scheme’s module system, and making
          ;; dispatched generators work with a module system
          ;; introduces breakage. Dispatched generators are
          ;; unnecessary, anyway, they are a lot of code to maintain,
          ;; and they impact performance and documentation.
          :list
          :string
          :vector
          :integers
          :range
          :real-range
          :char-range
          :port
          :do
          :let
          :parallel
          :while
          :until)

  ;; Some Schemes have SRFI-42 implementations that work with
  ;; extensions. Some other Schemes, have SRFI-42 implementations that
  ;; do not work or work only partially. So, instead of importing
  ;; SRFI-42, we include the SRFI-42 reference sources.
  (import (except (rnrs (6)) error)
          (srfi :23 error)
          (pvec)
          (pvec srfi-42)
          (pvec pvec-include))          

  (include "common/pvec/eager-comprehensions-implementation.scm")

  )

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
