(define input-prompt ";;; Query input: ")
(define output-prompt ";;; Query results: ")

(define (prompt-for-input string)
  (newline) (newline) (display string) (newline))


(define global-array '())

(define (make-entry k v) (list k v))
(define (key entry) (car entry))
(define (value entry) (cadr entry))

(define (put op type item)
  (define (put-helper k array)
    (cond ((null? array) (list (make-entry k item)))
          ((equal? (key (car array)) k) array)
          (else (cons (car array) (put-helper k (cdr array))))))
  (set! global-array (put-helper (list op type) global-array)))

(define (get op type)
  (define (get-helper k array)
    (cond ((null? array) #f)
          (equal? (key (car array)) k) (value (car array))
          (else (get-helper k (cdr array)))))
  (get-helper (list op type) global-array))


(define (memo-func function)
  (let ((already-run? #f)
        (result #f))
    (lambda ()
      (if (not already-run?)
        (begin (set! result (function))
               (set! already-run? #t)
               result)
        result))))


(define the-empty-stream '())
(define stream-null? null?)

(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (cons-stream a b) (cons a (memo-func (lambda () b))))

(define (stream-map proc s)
  (if (stream-null? s)
    the-empty-stream
    (cons-stream (proc (stream-car s))
                 (stream-map proc (stream-cdr s)))))

(define (stream-for-each proc s)
  (if (stream-null? s)
    'done
    (begin (proc (stream-car s))
           (stream-for-each proc (stream-cdr s)))))

(define (stream-append s1 s2)
  (if (stream-null? s1)
    s2
    (cons-stream (stream-car s1)
                 (stream-append (stream-cdr s1) s2))))


(define (display-line x)
  (newline) (display x))

(define (display-stream s)
  (stream-for-each display-line s))


(define THE-ASSERTIONS the-empty-stream)

(define THE-RULES the-empty-stream)


;; frame

(define (make-binding variable value)
  (cons variable value))


(define (binding-variable binding)
  (car binding))


(define (binding-value binding)
  (cdr binding))


(define (binding-in-frame variable frame)
  (assoc variable frame))


(define (extend variable value frame)
  (cons (make-binding variable value) frame))


;; query syntax

(define (type exp)
  (if (pair? exp)
    (car exp)
    (error "Unknown expression TYPE" exp)))


(define (contents exp)
  (if (pair? exp)
    (cdr exp)
    (error "Unknown expression CONTENTS" exp)))


(define (assertion-to-be-added? exp)
  (eq? (type exp) 'assert!))


(define (add-assertion-body exp)
  (car (contents exp)))


(define (empty-conjunction? exps) (null? exps))
(define (first-conjunct exps) (car exps))
(define (rest-conjuncts exps) (cdr exps))


(define (empty-disjunction? exps) (null? exps))
(define (first-disjunct exps) (car exps))
(define (rest-disjuncts exps) (cdr exps))


(define (negated-query exps) (car exps))


(define (predicate exps) (car exps))
(define (args exps) (cdr exps))


(define (tagged-list? exp tag)
  (if (pair? exp)
    (eq? (car exp) tag)
    #f))


(define (rule? statement)
  (tagged-list? statement 'rule))


(define (conclusion rule) (cadr rule))


(define (rule-body rule)
  (if (null? (cddr rule))
    '(always-true)
    (caddr rule)))


(define (map-over-symbols proc exp)
  (cond ((pair? exp)
         (cons (map-over-symbols proc (car exp))
               (map-over-symbols proc (cdr exp))))
        ((symbol? exp) (proc exp))
        (else exp)))


(define (expand-question-mark symbol)
  (let ((chars (symbol->string symbol)))
    (if (string=? (substring chars 0 1) "?")
      (list '?
            (string->symbol
              (substring chars 1 (string-length chars))))
      symbol)))


(define (query-syntax-process exp)
  (map-over-symbols expand-question-mark exp))


(define (var? exp)
  (tagged-list? exp '?))


(define (constant-symbol? exp) (symbol? exp))


(define rule-counter 0)


(define (new-rule-application-id)
  (set! rule-counter (+ 1 rule-counter))
  rule-counter)


(define (make-new-variable var rule-application-id)
  (cons '? (cons rule-application-id (cdr var))))


(define (contract-question-mark variable)
  (string->symbol
    (string-append "?"
                   (if (number? (cadr variable))
                     (string-append (symbol->string (caddr variable))
                                    "-"
                                    (number->string (cadr variable)))
                     (symbol->string (cadr variable))))))


;; stream

(define (stream-append-delayed s1 delayed-s2)
  (if (stream-null? s1)
    (force delayed-s2)
    (cons-stream
      (stream-car s1)
      (stream-append-delayed (stream-cdr s1) delayed-s2))))


(define (interleave-delayed s1 delayed-s2)
  (if (stream-null? s1)
    (force delayed-s2)
    (cons-stream
      (stream-car s1)
      (interleave-delayed (force delayed-s2)
                          (delay (stream-cdr s1))))))


(define (flatten-stream stream)
  (if (stream-null? stream)
    the-empty-stream
    (interleave-delayed
      (stream-car stream)
      (delay (flatten-stream (stream-cdr stream))))))


(define (stream-flatmap proc s)
  (flatten-stream (stream-map proc s)))


(define (singleton-stream x)
  (cons-stream x the-empty-stream))


;; data base

(define (get-all-assertions) THE-ASSERTIONS)

(define (get-all-rules) THE-RULES)


(define (get-stream key1 key2)
  (let ((s (get key1 key2)))
    (if s s the-empty-stream)))


(define (get-indexed-assertions pattern)
  (get-stream (index-key-of pattern) 'assertion-stream))


(define (fetch-assertions pattern frame)
  (if (use-index? pattern)
    (get-indexed-assertions pattern)
    (get-all-assertions)))


(define (get-indexed-rules pattern)
  (stream-append
    (get-stream (index-key-of pattern) 'rule-stream)
    (get-stream '? 'rule-stream)))


(define (fetch-rules pattern frame)
  (if (use-index? pattern)
    (get-indexed-rules pattern)
    (get-all-rules)))


(define (indexable? pat)
  (or (constant-symbol? (car pat))
      (var? (car pat))))


(define (index-key-of pat)
  (let ((key (car pat)))
    (if (var? key) '? key)))


(define (use-index? pat)
  (constant-symbol? (car pat)))


(define (store-assertion-in-index assertion)
  (if (indexable? assertion)
    (let ((key (index-key-of assertion)))
      (let ((current-assertion-stream
              (get-stream key 'assertion-stream)))
        (put key
             'assertion-stream
             (cons-stream assertion
                          current-assertion-stream))))))


(define (store-rule-in-index rule)
  (let ((pattern (conclusion rule)))
    (if (indexable? pattern)
      (let ((key (index-key-of pattern)))
        (let ((current-rule-stream
                (get-stream key 'rule-stream)))
          (put key
               'rule-stream
               (cons-stream rule
                            current-rule-stream)))))))


(define (add-assertion! assertion)
  (store-assertion-in-index assertion)
  (let ((old-assertions THE-ASSERTIONS))
    (set! THE-ASSERTIONS
      (cons-stream assertion old-assertions))
    'ok))


(define (add-rule! rule)
  (store-rule-in-index rule)
  (let ((old-rules THE-RULES))
    (set! THE-RULES (cons-stream rule old-rules))
    'ok))


(define (add-rule-or-assertion! assertion)
  (if (rule? assertion)
    (add-rule! assertion)
    (add-assertion! assertion)))


;; query system

; !! R5RS
(define user-initial-environment (scheme-report-environment 5))


(define (execute exp)
  (apply (eval (predicate exp) user-initial-environment)
         (args exp)))


(define (instantiate exp frame unbound-var-handler)
  (define (copy exp)
    (cond ((var? exp)
           (let ((binding (binding-in-frame exp frame)))
             (if binding
               (copy (binding-value binding))
               (unbound-var-handler exp frame))))
          ((pair? exp)
           (cons (copy (car exp)) (copy (cdr exp))))
          (else exp)))
  (copy exp))


(define (extend-if-consistent var dat frame)
  (let ((binding (binding-in-frame var frame)))
    (if binding
      (pattern-match (binding-value binding) dat frame)
      (extend var dat frame))))


(define (pattern-match pat dat frame)
  (cond ((eq? frame 'failed) 'failed)
        ((equal? pat dat) frame)
        ((var? pat) (extend-if-consistent pat dat frame))
        ((and (pair? pat) (pair? dat))
         (pattern-match (cdr pat)
                        (cdr dat)
                        (pattern-match (car pat)
                                       (car dat)
                                       frame)))
        (else 'failed)))


(define (check-an-assertion assertion query-pat query-frame)
  (let ((match-result
          (pattern-match query-pat assertion query-frame)))
    (if (eq? match-result 'failed)
      the-empty-stream
      (singleton-stream match-result))))


(define (find-assertions pattern frame)
  (stream-flatmap (lambda (datum)
                    (check-an-assertion datum pattern frame))
                  (fetch-assertions pattern frame)))


(define (rename-variables-in rule)
  (let ((rule-application-id (new-rule-application-id)))
    (define (tree-walk exp)
      (cond ((var? exp)
             (make-new-variable exp rule-application-id))
            ((pair? exp)
             (cons (tree-walk (car exp))
                   (tree-walk (cdr exp))))
            (else exp)))
    (tree-walk rule)))


(define (depends-on? exp var frame)
  (define (tree-walk e)
    (cond ((var? e)
           (if (equal? var e)
             #t
             (let ((b (binding-in-frame e frame)))
               (if b
                 (tree-walk (binding-value b))
                 #f))))
          ((pair? e)
           (or (tree-walk (car e))
               (tree-walk (cdr e))))
          (else #f)))
  (tree-walk exp))


(define (extend-if-possible var val frame)
  (let ((binding (binding-in-frame var frame)))
    (cond (binding
            (unify-match
              (binding-value binding) val frame))
          ((var? val) ; ***
           (let ((binding (binding-in-frame val frame)))
             (if binding
               (unify-match
                 var (binding-value binding) frame)
               (extend var val frame))))
          ((depends-on? val var frame) ; ***
           'failed)
          (else (extend var val frame)))))


(define (unify-match p1 p2 frame)
  (cond ((eq? frame 'failed) 'failed)
        ((equal? p1 p2) frame)
        ((var? p1) (extend-if-possible p1 p2 frame))
        ((var? p2) (extend-if-possible p2 p1 frame)) ; ***
        ((and (pair? p1) (pair? p2))
         (unify-match (cdr p1)
                      (cdr p2)
                      (unify-match (car p1)
                                   (car p2)
                                   frame)))
        (else 'failed)))


(define (apply-a-rule rule query-pattern query-frame)
  (let ((clean-rule (rename-variables-in rule)))
    (let ((unify-result
            (unify-match query-pattern
                         (conclusion clean-rule)
                         query-frame)))
      (if (eq? unify-result 'failed)
        the-empty-stream
        (qeval (rule-body clean-rule)
               (singleton-stream unify-result))))))


(define (apply-rules pattern frame)
  (stream-flatmap (lambda (rule)
                    (apply-a-rule rule pattern frame))
                  (fetch-rules pattern frame)))


(define (simple-query query-pattern frame-stream)
  (stream-flatmap
    (lambda (frame)
      (stream-append-delayed
        (find-assertions query-pattern frame)
        (delay (apply-rules query-pattern frame))))
    frame-stream))


; for debugging
;(define (qeval query frame-stream)
;  (let ((qproc (get (type query) 'qeval)))
;    (simple-query query frame-stream)))

(define (qeval query frame-stream)
  (let ((qproc (get (type query) 'qeval)))
    (if qproc
      (qproc (contents query) frame-stream)
      (simple-query query frame-stream))))


(define (conjoin conjuncts frame-stream)
  (if (empty-conjunction? conjuncts)
    frame-stream
    (conjoin (rest-conjuncts conjuncts)
             (qeval (first-conjunct conjuncts)
                    frame-stream))))

(put 'and 'qeval conjoin)


(define (disjoin disjuncts frame-stream)
  (if (empty-disjunction? disjuncts)
    the-empty-stream
    (interleave-delayed
      (qeval (first-disjunct disjuncts) frame-stream)
      (delay (disjoin (rest-disjuncts disjuncts)
                      frame-stream)))))

(put 'or 'qeval disjoin)


(define (negate operands frame-stream)
  (stream-flatmap
    (lambda (frame)
      (if (stream-null? (qeval (negated-query operands)
                               (singleton-stream frame)))
        (singleton-stream frame)
        the-empty-stream))
    frame-stream))

(put 'not 'qeval negate)


(define (lisp-value call frame-stream)
  (stream-flatmap
    (lambda (frame)
      (if (execute
            (instantiate
              call
              frame
              (lambda (v f)
                (error "Unknown pat var -- LISP-VALUE" v))))
        (singleton-stream frame)
        the-empty-stream))
    frame-stream))

(put 'lisp-value 'qeval lisp-value)


(define (always-true ignore frame-stream) frame-stream)

(put 'always-true 'qeval always-true)


; -- query-driver-loop
; If the expression is a rule or an assertion, then it is added to database [a].
; Otherwise the expression is assumed to be a query and is passed to `qeval`
; with a (empty) frame stream [b].

(define (query-driver-loop)
  (prompt-for-input input-prompt)
  (let ((q (query-syntax-process (read))))
    (cond ((assertion-to-be-added? q)
           (add-rule-or-assertion! (add-assertion-body q)) ;; [a]
           (newline)
           (display "Assertion added to data base.")
           (query-driver-loop))
          (else
            (newline)
            (display output-prompt)
            (display-stream
              (stream-map
                (lambda (frame)
                  (instantiate q
                               frame
                               (lambda (v f)
                                 (contract-question-mark v))))
                (qeval q (singleton-stream '())))) ;; [b]
            (query-driver-loop)))))


; test

(query-driver-loop)

(assert!
  (rule (append-to-form () ?y ?y)))

(assert!
  (rule (append-to-form (?u . ?v) ?y (?u . ?z))
        (append-to-form ?v ?y ?z)))

(append-to-form (a b) (c d) ?z)
