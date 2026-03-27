;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(define-library (pvec eager-comprehensions)

  (export do-ec #;pvec-ec

          ;; Support for SRFI-158 generators.
          :generator

          ;; Symbols documented in SRFI-42.
          do-ec
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
          ;; unnecessary, anyway. They are a lot of code to maintain,
          ;; they impact performance and documentation, and we can use
          ;; SRFI-158 generators instead.
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

  (import (scheme base))
  (import (scheme cxr))
  (import (scheme read))
  (import (scheme r5rs))
  (import (pvec))
  (import (pvec srfi-42))
  (import (pvec srfi-42-generator))

  (begin

    (include "common/pvec/eager-comprehensions-implementation.scm")

    ))

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
