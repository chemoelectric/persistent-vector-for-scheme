;; Copyright © 2026 Barry Schwartz
;; SPDX-License-Identifier: MIT
;;--------------------------------------------------------------------
;;
;; Bit-partitioned vector tries with tails.
;;
;; Reference:
;;
;;   @mastersthesis{lorange2014rrb,
;;     author = {L'orange, Jean Niklas},
;;     title  = {{Improving RRB-Tree Performance through Transience}},
;;     school = {Norwegian University of Science and Technology},
;;     year   = {2014},
;;     month  = {June}}
;;
;;   <http://hypirion.com/thesis>
;;
;;;-------------------------------------------------------------------

(define-syntax bits ;; The shift increment.
  (syntax-rules ()
    ((¶) 5)))

(define-syntax node-size ;; = (expt 2 bits)
  (syntax-rules ()
    ((¶) 32)))

(define-syntax mask ;; = (- (expt 2 bits) 1)
  (syntax-rules ()
    ((¶) 31)))

(define-syntax one-shifted
  (syntax-rules ()
    ((¶ shift) (fxarithmetic-shift-left 1 shift))))

(define-syntax tail-length0
  ;; Return the length of tail, or zero if the tail is full.
  (syntax-rules ()
    ((¶ length) (fxand length (mask)))))

(define-syntax tail-length
  ;; Return the length of tail (node-size, if the tail is full).
  (syntax-rules ()
    ((¶ length)
     (let ((n (tail-length0 length)))
       (if (fxzero? n) (node-size) n)))))

(define-syntax make-internal-node
  (syntax-rules ()
    ((¶) (make-vector (node-size) #f))))

(define-syntax make-leaf-node
  (syntax-rules ()
    ((¶) (make-vector (node-size)))))

(define-syntax new-leaf
  (syntax-rules ()
    ((¶ x)
     (let ((leaf (make-leaf-node)))
       (vector-set! leaf 0 x)
       leaf))))

(define-syntax leaf-copy-set
  (syntax-rules ()
    ((¶ leaf j x)
     (let ((leaf (vector-copy leaf)))
       (vector-set! leaf j x)
       leaf))))

(define-syntax copy-to-leaf! ;;;;;;;; FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
  (syntax-rules ()
    ((¶ leaf k0 k1 w j)
     (let ()
       (let loop ((k k0)
                  (j j))
         (unless (fx=? k k1)
           (vector-set! leaf k (vector-ref w j))
           (loop (fx+ k 1) (fx+ j 1))))))))

(define-syntax new-leaf-copied-to ;;;;;;;; FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
  (syntax-rules ()
    ((¶ w j n)
     (let ((leaf (make-leaf-node)))
       (copy-to-leaf! leaf 0 n w j)
       leaf))
    ((¶ w j)
     (new-leaf-copied-to w j (node-size)))))

(define-syntax leaf-copy-copied-to ;;;;;;;; FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
  (syntax-rules ()
    ((¶ leaf k0 k1 w j)
     (let ((leaf (vector-copy leaf)))
       (copy-to-leaf! leaf k0 k1 w j)
       leaf))))

(define-syntax node-index
  (syntax-rules ()
    ((¶ shift i)
     (fxand (fxarithmetic-shift-right i shift) (mask)))))

(define-syntax masked
  (syntax-rules ()
    ((¶ i) (fxand i (mask)))))

(define-record-factory <pvec>
  (constructor> construct-pvec)
  (constructor>
   pvec
   (lambda (construct)
     (case-lambda
       (() (construct 0 0 #f #f))
       (elem* (list->pvec elem*)))))
  (predicate> pvec?)
  (getter> 1 pvec-length)
  (getter> 2 pvec-shift)
  (getter> 3 pvec-node)
  (getter> 4 pvec-tail))

(define (free-unused-objects tail length-of-tail)
  (if (fx=? length-of-tail (node-size))
    tail
    (let ((tail (vector-copy tail)))
      (vector-fill! tail #f length-of-tail)
      tail)))

(define pvec-push
  (case-lambda
    ((v x)
     (let ((len (pvec-length v)))
       (if (fxzero? len)
         ;; The vector is empty; create a tail for it.
         (construct-pvec 1 0 #f (new-leaf x))
         (let ((shift (pvec-shift v))
               (node (pvec-node v))
               (tail (pvec-tail v))
               (new-length (fx+ len 1))
               (n-tail (tail-length0 len)))
           (if (fxzero? n-tail)
             ;; The tail is full. Move it into the trie, and start a
             ;; new tail.
             (let-values (((new-shift new-node)
                           (move-leaf-into-trie (fx- len (node-size))
                                                shift node tail)))
               (construct-pvec new-length new-shift new-node
                               (new-leaf x)))
             ;; The tail has room to grow; extend it.
             (let ((new-tail (leaf-copy-set tail n-tail x)))
               (construct-pvec new-length shift node new-tail)))))))
    ((v . x*)
     (pvec-push-from-list v x*))))

(define (pvec-push-from-list v x*)
  ;; NOTE: This implementation pushes nodes into the trie one at a
  ;; time, producing a complete trie again and again, until the data
  ;; to be pushed is used up. It might be better to write something
  ;; that reduces the number of intermediate allocations.
  (cond
    ((null-list? x*)
     ;; Push zero entries. Just return the persistent vector,
     ;; unchanged.
     v)
    ((fxzero? (pvec-length v))
     ;; If the original persistent vector is empty, then simply start
     ;; a new one.
     (list->pvec x*))
    (else
     (let* ((len (pvec-length v))
            (shift (pvec-shift v))
            (node (pvec-node v))
            (tail (pvec-tail v))
            (n (length x*))
            (n-tail (tail-length len))
            (n-fill (fx- (node-size) n-tail)))
       (cond
         ((<= n n-fill)
          ;; There is room in the tail for all the objects to be
          ;; pushed.
          (let ((tail (vector-copy tail))
                (i len))
            (do-ec (:list x x*)
              (begin
                (vector-set! tail i x)
                (set! i (fx+ i 1))))
            (construct-pvec (fx+ len n) shift node tail)))
         (else
          (pvec-pushes-into-the-trie v x* n len shift node tail
                                     n-tail n-fill)))))))

(define (pvec-pushes-into-the-trie v x* n len shift node tail
                                   n-tail n-fill)
  (let*-values (((n-past-fill) (fx- n n-fill))
                ((n-new-tail) (tail-length n-past-fill))
                ((n-middle) (fx- n-past-fill n-new-tail))
                ;;
                ;; Fill the old tail with initial regular-vector
                ;; entries, and move the filled node to the trie.
                ((shift node)
                 (copy-leaf-into-trie (fx- len n-tail) shift node
                                      tail n-tail x*))
                ((x*) (drop (fx- (node-size) n-tail) x*))
                ;;
                ;; Push the middle regular-vector entries to the trie.
                ((trie-size) (fx+ (fx- len n-tail) (node-size)))
                ((shift node x*)
                 (let loop ((j 0)
                            (shift shift)
                            (node node)
                            (x* x*))
                   (if (fx=? j n-middle)
                     (values shift node x*)
                     (let*-values
                         (((shift node)
                           (new-leaf-into-trie (fx+ trie-size j)
                                               shift node x*))
                          ((x*) (drop (node-size) x*)))
                       (loop (fx+ j (node-size)) shift node x*)))))
                ;;
                ;; Fill in the new tail from the final
                ;; regular-vector entries.
                ((tail)
                 (let ((tail (make-vector (node-size) #f))
                       (i 0))
                   (do-ec (:list x x*)
                     (begin
                       (vector-set! tail i x)
                       (set! i (fx+ i 1))))
                   tail)))
    ;;
    ;; And return the new persistent vector.
    (construct-pvec (fx+ len n) shift node tail)))

(define (copy-leaf-into-trie trie-length shift node tail n-tail x*)
  (let ((leaf (vector-copy tail))
        (i n-tail))
    (do-ec (:list x x*)
      (begin
        (vector-set! leaf i x)
        (set! i (fx+ i 1))))
    (move-leaf-into-trie trie-length shift node leaf)))

(define (new-leaf-into-trie trie-length shift node x*)
  (let ((leaf (make-new-leaf))
        (i 0))
    (do-ec (:list x x*)
      (begin
        (vector-set! leaf i x)
        (set! i (fx+ i 1))))
    (move-leaf-into-trie trie-length shift node leaf)))

(define (move-leaf-into-trie trie-length shift node leaf)
  (cond
    ((fxzero? trie-length)
     ;; There is no trie yet. Start one that contains only the new
     ;; leaf.
     (values 0 leaf))
    ((fx=? trie-length (one-shifted (fx+ shift (bits))))
     ;; The trie is fully dense. Raise its height.
     (let* ((path (list-ec (:range s shift 0 (fxneg (bits))) #f))
            (new-child (make-new-internal-nodes path leaf))
            (new-node (make-internal-node)))
       (vector-set! new-node 0 node)
       (vector-set! new-node 1 new-child)
       (values (fx+ shift (bits)) new-node)))
    (else
     ;; There is room in the trie without raising its height.
     (let-values (((path not-a-leaf)
                   (make-path-to-leaf shift node trie-length)))
       (values shift (make-new-internal-nodes path leaf))))))

(define (make-new-internal-nodes path path-ending)
  ;; Construct a new trie by going through ‘path’, which is a
  ;; backwards list of a path through the trie. Make copies of the
  ;; internal nodes, along the way. The initial ‘path-ending’ may be a
  ;; leaf node to be inserted.
  (if (null? path)
    path-ending
    (let-values (((head path) (car+cdr path)))
      (if head
        (let-values (((node j) (car+cdr head)))
          (let ((new-node (vector-copy node)))
            (vector-set! new-node j path-ending)
            (make-new-internal-nodes path new-node)))
        (let ((new-node (make-internal-node)))
          (vector-set! new-node 0 path-ending)
          (make-new-internal-nodes path new-node))))))

(define pvec-pop
  (case-lambda
    ((v) (pvec-pop v 1))
    ((v n)
     (cond
       ((fxzero? n)
        ;; Pop nothing.
        v)
       ((fx=? n (pvec-length v))
        ;; The new vector is empty.
        (pvec))
       ((fxnegative? n)
        (error "one cannot pop a negative number of entries" v n))
       ((fx<? (pvec-length v) n)
        (error "one cannot pop more entries than are stored" v n))
       (else
        (pvec-pop-no-check v n))))))

(define (pvec-pop-no-check v n)
  (let* ((len (pvec-length v))
         (shift (pvec-shift v))
         (node (pvec-node v))
         (tail (pvec-tail v))
         (n-tail (tail-length len)))
    (if (fx<? n n-tail)
      (construct-pvec (fx- len n) shift node
                      ;; Simply shorten the current tail.
                      (free-unused-objects tail (fx- len n)))
      (pvec-pop-requiring-a-new-tail v n len shift node tail))))

(define (pvec-pop-requiring-a-new-tail v n len shift node tail)
  (let* ((new-length (fx- len n))
         (n-new-tail (tail-length new-length))
         (n-new-trie (fx- new-length n-new-tail))
         (new-tail (free-unused-objects (find-entry v n-new-trie)
                                        n-new-tail)))
    (if (fx=? new-length n-new-tail)
      (construct-pvec new-length 0 #f new-tail) ;; No trie.
      (let ((i (fx- n-new-trie 1)))
        (let*-values
            (((shift node) (reduce-trie-height shift node i))
             ((path leaf) (make-pruned-path shift node i '())))
          (let ((new-node (make-new-internal-nodes path leaf)))
            (construct-pvec new-length shift new-node new-tail)))))))

(define (reduce-trie-height shift node i)
  ;; Remove leading internal nodes whose index is zero. They are not
  ;; needed.
  (if (fxzero? shift)
    (values shift node)
    (let ((j (node-index shift i)))
      (if (fxzero? j)
        (reduce-trie-height (fx- shift (bits)) (vector-ref node j) i)
        (values shift node)))))

(define (make-pruned-path shift node i path)
  (if (fxzero? shift)
    (values path node)
    (let ((j (node-index shift i))
          (new-node (vector-copy node)))
      ;;
      ;; Prune discarded entries.
      (vector-fill! new-node #f (fx+ j 1))
      ;;
      (make-pruned-path (fx- shift (bits))
                        (vector-ref node j) i
                        (cons (cons new-node j) path)))))

(define (pvec-ref v i)
  (let-values (((node j) (find-entry v i)))
    (vector-ref node j)))

(define (find-entry v i)
  (let ((len (pvec-length v)))
    (when (or (fxnegative? i) (fx<=? len i))
      (error "index out of range" v i))
    (let* ((tail (pvec-tail v))
           (n-tail (tail-length len))
           (n-body (fx- len n-tail)))
      (if (fx<=? n-body i)
        ;; The entry is in the tail.
        (values tail (fx- i n-body))
        (let ((shift (pvec-shift v))
              (node (pvec-node v)))
          (values (follow-path shift node i) (masked i)))))))

(define (follow-path shift node i)
  (if (fxzero? shift)
    node
    (let ((j (node-index shift i)))
      (follow-path (fx- shift (bits)) (vector-ref node j) i))))

(define (pvec-set v i x)
  (let ((len (pvec-length v)))
    (when (or (fxnegative? i) (fx<=? len i))
      (error "index out of range" v i))
    (let* ((shift (pvec-shift v))
           (node (pvec-node v))
           (tail (pvec-tail v))
           (n-tail (tail-length len))
           (n-body (fx- len n-tail)))
      (if (<= n-body i)
        (let ((new-tail (leaf-copy-set tail (fx- i n-body) x)))
          (construct-pvec len shift node new-tail))
        (let* ((make-new-leaf (lambda (leaf)
                                (leaf-copy-set leaf (masked i) x)))
               (new-leaf (replace-leaf shift node i make-new-leaf)))
          (construct-pvec len shift new-leaf tail))))))

(define (replace-leaf shift node i make-new-leaf)
  (let-values (((path leaf) (make-path-to-leaf shift node i)))
    (make-new-internal-nodes path (make-new-leaf leaf))))

(define (make-path-to-leaf shift node i)
  ;; Construct the path through the trie to the leaf node that
  ;; contains the ith element (zero-indexed). If the leaf does not
  ;; exist yet, pad the path with ‘#f’ entries, and return ‘#f’ as the
  ;; leaf node.
  (cons-path-to-leaf shift node i '()))

(define (cons-path-to-leaf shift node i path)
  ;; Construct the path through the trie to the leaf node that
  ;; contains the ith element (zero-indexed). If the leaf does not
  ;; exist yet, pad the path with ‘#f’ entries, and return ‘#f’ as the
  ;; leaf node.
  (cond
    ((fxzero? shift)
     ;; Return the path and the leaf node (or #f).
     (values path node))
    (node
     (let ((j (node-index shift i)))
       (cons-path-to-leaf
        (fx- shift (bits)) (vector-ref node j) i
        (cons (cons node j) path))))
    (else
     (cons-path-to-leaf (fx- shift (bits)) #f i (cons #f path)))))

(define (list->pvec lst)
  (let ((n (length lst)))
    (cond
      ((fxzero? n) (pvec))
      ((fx<=? n (node-size))
       ;; Use just the first value returned by create-leaves.
       (construct-pvec n 0 #f (create-leaves lst)))
      (else
       (let*-values (((tail leaves) (create-leaves lst))
                     ((shift trie) (build-trie leaves)))
         (construct-pvec n shift trie tail))))))

(define (create-leaves lst)
  (let loop ((p lst)
             (leaves '()))
    (if (not-pair? p)
      ;; Other code depends on (car leaves) being the first value
      ;; returned.
      (values (car leaves) ; The tail-to-be.
              (reverse! (cdr leaves)))
      (let-values (((p leaf) (create-leaf p)))
        (loop p (cons leaf leaves))))))

(define (create-leaf lst)
  (let ((leaf (make-leaf-node)))
    (let loop ((p lst)
               (i 0))
      (if (or (not-pair? p) (fx=? i (node-size)))
        (values p leaf)
        (begin
          (vector-set! leaf i (car p))
          (loop (cdr p) (fx+ i 1)))))))

(define (create-parents children)
  (let loop ((k children)
             (parents '()))
    (if (not-pair? k)
      (reverse! parents)
      (let-values (((k parent) (create-parent k)))
        (loop k (cons parent parents))))))

(define (create-parent children)
  (let ((parent (make-internal-node)))
    (let loop ((k children)
               (i 0))
      (if (or (not-pair? k) (fx=? i (node-size)))
        (values k parent)
        (begin
          (vector-set! parent i (car k))
          (loop (cdr k) (fx+ i 1)))))))

(define (build-trie leaves)
  (let loop ((nodes leaves)
             (shift 0))
    (if (not-pair? (cdr nodes))
      (values shift (car nodes))
      (loop (create-parents nodes) (fx+ shift (bits))))))

;;;-------------------------------------------------------------------
;;; local variables:
;;; mode: scheme
;;; geiser-scheme-implementation: chibi
;;; coding: utf-8
;;; end:
