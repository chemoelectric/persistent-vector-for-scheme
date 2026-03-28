m4_changequote(“,”)m4_changecom“”m4_dnl
#!/usr/bin/env scheme-script
;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT
#!r6rs

(import (except (rnrs base (6)) for-each map)
        (rnrs control (6))
        (rnrs programs (6))
        (rnrs io simple (6))
        (rnrs r5rs (6))
        (srfi :1 lists)
        (pvec pvec-include)
        (pvec)
        (pvec eager-comprehensions))

m4_include(“tests/tests-common.scm”)
m4_include(“tests/test-pvec-implementation.scm”)

;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chez
;;; coding: utf-8
;;; end:
