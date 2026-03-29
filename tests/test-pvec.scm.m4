m4_changequote(“,”)m4_changecom“”m4_dnl
#!/usr/bin/env scheme-r7rs
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT

(import (scheme base)
        (scheme case-lambda)
        (scheme process-context)
        (scheme write)
        (pvec)
        (pvec eager-comprehensions))
(cond-expand
  (chicken-5 (import (srfi 1)))
  ((library (scheme list)) (import (scheme list)))
  ((library (srfi 1)) (import (srfi 1)))
  (loko (import (srfi :1 lists)))
  (else (import (srfi srfi-1))))
(cond-expand
  (chicken-5 (import (srfi 143)))
  ((library (scheme fixnum)) (import (scheme fixnum)))
  ((library (srfi 143)) (import (srfi 143)))
  (loko (import (srfi :143 fixnums)))
  (else (import (srfi srfi-143))))

m4_include(“tests/tests-common.scm”)
m4_include(“tests/test-pvec-implementation.scm”)

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
