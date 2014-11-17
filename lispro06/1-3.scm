;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ch 1.3 ���� ���� ���ν���(higher-order procedure)�� ����ϴ� ���
;;; p72

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p72
�Ʒ��� ���� ��� �����ϴٴ� ���� Ȯ���ߴ�.
(define (cube x) (* x x x))

���� �������� �ʰ� �Ʒ��� ���� ����� �� �ִ�.

(* 3 3 3)
(* x x x)
(* y y y)

�׷��� �̴� ��ȿ�����̴�. ���� �̸��� �Ҵ��� ����ϴ°� ����.(�߻�ȭ) �̸� higer-order procedure(���� ���� ���ν���)�� �Ѵ�.

;;;;=================================<ch 1.3.1>=================================
;;; ���ν����� ���ڷ� �޴� ���ν���
;;; p73

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p73
������ ������ �ִ�.
(define (sum-integers a b)
  (if (> a b)
      0
      (+ a (sum-integers (+ a 1) b))))
;a���� b���� ������ ��

(define (sum-cubes a b)
  (if (> a b)
      0
      (+ (cube a) (sum-cubes (+ a 1) b))))
;a���� b�� �������� ��

(define (pi-sum a b)
  (if (> a b)
      0
      (+ (/ 1.0 (* a (+ a 2))) (pi-sum (+ a 4) b))))

pi/8 �� �����ϴ� ���̴�.
���������갡 ����� �Ʒ��Ŀ� ����
(pi/4) = 1 - (1/3) + (1/5) - (1/7) + ...

�Ʒ��� ���� �⺻ ���� ������ �����ϴ�.

;;;->
;; (define (<name> a b)
;;   (if (> a b)
;;       0
;;       (+ (<term> a)
;; 	 (<name> (<next a) b))))

�߻�ȭ(���)�� �̸� �����ش�. �����ڵ��� �ñ׸�(��)�� ����ߴ�.

�����ڿ� ���������� ������ ���� �����ϰ� ������ �����ϴ�.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p75~76

;;;----
(define (cube x) (* x x x))
;;;----

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))
;;sum-cubes�� sum�� �̿��� ������
(define (inc n) (+ n 1))
(define (sum-cubes a b)
  (sum cube a inc b))

(sum-cubes 1 10)
;;->3025

; 1���� 10������ ������ �յ� ���� �̿��� �� �ִ�.
(define (identity x) x)
(define (sum-integers a b)
  (sum identity a inc b))

(sum-integers 1 10)

pi-sum����  pi�� �ٻ簪�� ����� �� �ִ�.

(define (pi-sum a b)
  (define (pi-term x)
    (/ 1.0 (* x (+ x 2))))
  (define (pi-next x)
    (+ x 4))
  (sum pi-term a pi-next b))

(* 8 (pi-sum 1 1000))

������ �Ʒ��� ���� ���� �����ϴ�.
(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))
��Ȯ�� ���� 0�� 1 ������ 1/4�� �������� ���̴�.
(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)

;;;; sine �Լ� ���� �׽�Ʈ
(integral sin 0 (/ 3.14159 2) 0.001)

(integral identity 0 1 0.001)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ����þ� �Լ� ���� �׽�Ʈ

;;;----
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))

(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))
;;;----

(define (gaussian m sigma x)
  (define PI 3.14159)
  (define EXP 2.7183)
  (/ (expt EXP (/ (- (square (- x m)) ) (* 2 (square sigma)))) (sqrt (* 2 PI (square sigma)))))

;;; 1-D Gaussian function generator
(define (gen-gaussian m sigma)
  (let ((PI 3.14159)
	(E 2.7183))
    (lambda (x)
      (/ (expt E 
	       (/ (- (expt (- x m) 2)) (* 2 (expt sigma 2))))
	 (sqrt (* 2 PI (expt sigma 2)))))))

(define gaussian-f (gen-gaussian 0 1))

(integral gaussian-f -100 100 0.01)




;;;--------------------------< ex 1.29 >--------------------------
;;; p77

;;; ���� ������� cube ������
;;;----
(define (cube x) (* x x x))

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))

(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))

(integral cube 0 1 0.01)
;;;----




;;; Simpson ������� cube ������
;; h/3 [ y0 + 4y1 + 2y2 + 4y3 + 2y4 + ... + 2yn-2 + 4yn-1 + yn]
;; => h/3 [ [y0 + yn] +
;;          4[y1 + y3 + ... + yn-3 + yn-1] +
;;          2[y2 + y4 + ... + yn-2 + yn] ]

(define (inc2 n)
  (+ n 2))

(define (integral-simpson f a b n)
  (define h (/ (- b a) n))
  (define (yk k)
    (f (+ a (* k h))))
  (* (/ h 3)
	(+ (yk 0)
	   (yk n)
	   (* 4 (sum yk 1 inc2 (- n 1)))
	   (* 2 (sum yk 2 inc2 n)))))

(integral-simpson cube 0 1.0 100)
(integral-simpson cube 0 1.0 1000)
(integral-simpson cube 0 1.0 10000)
(integral-simpson cube 0 1.0 100000)
(integral-simpson cube 0 1.0 1000000)
;; ���� 0.25 �� 

(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)
;; ���� 0.25 ��.

(integral-simpson gaussian-f -100 100 100)
(integral-simpson gaussian-f -100 100 1000)
(integral-simpson gaussian-f -100 100 10000)
(integral-simpson gaussian-f -100 100 100000)
;; ���� ���� 1��




;;;--------------------------< ex 1.30 >--------------------------
;;; p77
;;; sum�� ����������μ���(linear recursion process) 

;; (define (sum term a next b)
;;   (define (iter a result)
;;     (if <>
;; 	<>
;; 	(iter <> <>)))
;;   (iter <> <>))


(define (sum-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (+ result (term a)))))
  (iter a 0))

;;;----
(define (inc n)
  (+ n 1))
;;;----

(sum-iter identity 1 inc 10)

;;;------
(define (integral-iter f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum-iter f (+ a (/ dx 2.0)) add-dx b)
     dx))


(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)
;; ���� 0.25 ��.


(integral-iter cube 0 1 0.01)
(integral-iter cube 0 1 0.001)
(integral-iter cube 0 1 0.0001)
(integral-iter cube 0 1 0.00001)
(integral-iter cube 0 1 0.000001)
;; ���� 0.25 ��.

;;;------



;;;--------------------------< ex 1.31 >--------------------------
;;; p78

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
	 (product term (next a) next b))))


(define (product-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (* result (term a)))))
  (iter a 1))

;;;-----
(define (inc2 n)
  (+ n 2))
;;;-----

;; pi/4 = 2/3 * 4/3 * 4/5 * 6/5 * 6/7 * 8/7 ...
;;  =>  2/3 * 4/5 * 6/7 * ...
;;    * 4/3 * 6/5 * 8/7 * ...

;;; �ǵ��� product �̿�
(define (find-pi b)
  (define (term1 x)
    (/ x (+ x 1)))
  (define (term2 x)
    (/ (+ x 2) (+ x 1)))
  (* (product term1 2 inc2 b)
     (product term2 2 inc2 b)
     4.0))


(find-pi 10)
(find-pi 100)
(find-pi 1000)
(find-pi 10000)
(find-pi 100000) ; �ð� �ʹ� ���� �ɸ�.

;;;----------------------------
;;; �ݺ� product �̿�
(define (find-pi2 b)
  (define (term1 x)
    (/ x (+ x 1)))
  (define (term2 x)
    (/ (+ x 2) (+ x 1)))
  (* (product-iter term1 2 inc2 b)
     (product-iter term2 2 inc2 b)
     4.0))


(find-pi2 10)
(find-pi2 100)
(find-pi2 1000)
(find-pi2 10000)
(find-pi2 100000)



;;;--------------------------< ex 1.32 >--------------------------
;;; p78

;;;-------
(define (inc n) (+ n 1))

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
	 (product term (next a) next b))))

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))
;;;-------



;;; �ǵ��� accumulate
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
		(accumulate combiner null-value term (next a) next b))))


(define (sum-acc term a next b)
  (accumulate + 0 term a next b))

(sum identity 1 inc 10)
(sum-acc identity 1 inc 10)


(define (product-acc term a next b)
  (accumulate * 1 term a next b))

(product identity 1 inc 10)
(product-acc identity 1 inc 10)



;;; �ݺ� accumulate
(define (accumulate-iter combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) 
	      (combiner result (term a)))))
  (iter a null-value))


(define (sum-acc-iter term a next b)
  (accumulate-iter + 0 term a next b))

(sum identity 1 inc 10)
(sum-acc identity 1 inc 10)
(sum-acc-iter identity 1 inc 10)


(define (product-acc-iter term a next b)
  (accumulate-iter * 1 term a next b))

(product identity 1 inc 10)
(product-acc identity 1 inc 10)
(product-acc-iter identity 1 inc 10)




;;;--------------------------< ex 1.33 >--------------------------
;;; p79

;;; �ǵ��� filtered-accumulate
(define (filtered-accumulate predicator combiner null-value term a next b)
  (if (> a b)
      null-value
      (if (predicator a)
	  (combiner (term a)
		    (filtered-accumulate predicator
					 combiner 
					 null-value term (next a) next b))
	  (combiner null-value
		    (filtered-accumulate predicator
					 combiner 
					 null-value term (next a) next b)))))
;;; �ݺ� filtered-accumulate
(define (filtered-accumulate-iter predicator combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(if (predicator a)
	    (iter (next a) (combiner result (term a)))
	    (iter (next a) result))))
  (iter a null-value))

;;;----
(define (square x)
  (* x x))
;;;----

(define (sum-of-prime a b)
  (filtered-accumulate prime? + 0 identity a inc b))

(sum-of-prime 1 10)  ; 1�� �Ҽ��� �ƴϴ�.
(+ 2 3 5 7)

;;; a------------------------------------------
(define (sum-of-square-prime a b)
  (filtered-accumulate prime? + 0 square a inc b))

(define (sum-of-square-prime-iter a b)
  (filtered-accumulate-iter prime? + 0 square a inc b))

(sum-of-square-prime 2 10)
(sum-of-square-prime-iter 2 10)
(+ (* 2 2) (* 3 3) (* 5 5) (* 7 7)) 


;;; b------------------------------------------
(define (product-of-relative-prime a b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (filtered-accumulate relative-prime? * 1 identity a inc b))

(define (product-of-relative-prime-iter a b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (filtered-accumulate-iter relative-prime? * 1 identity a inc b))

(product-of-relative-prime 1 15)
(product-of-relative-prime-iter 1 15)
;;; relative primes to 15.
;;; 2 4 7 8 11 13 14
(* 2 4 7 8 11 13 14)

;;; for test
(define (test-relative-prime? i b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (relative-prime? i))

(test-relative-prime? 2 15) ;t
(test-relative-prime? 3 15)
(test-relative-prime? 4 15) ;t
(test-relative-prime? 5 15)
(test-relative-prime? 6 15)
(test-relative-prime? 7 15) ;t
(test-relative-prime? 8 15) ;t
(test-relative-prime? 9 15)
(test-relative-prime? 10 15)
(test-relative-prime? 11 15) ;t
(test-relative-prime? 12 15)
(test-relative-prime? 13 15) ;t
(test-relative-prime? 14 15) ;t


;;;-----------
(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))
;----
(define (square x)
  (* x x))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (if (<= n 1)
      #f      ; 1�� �Ҽ��� �ƴϴ�.
      (= n (smallest-divisor n))))
;;;------------





;;;;=================================<ch 1.3.2>=================================
;;; lambda�� ��Ÿ���� ���ν���
;;; p79

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p80
���ٸ� ����Ͽ� �� ���ϰ� ������ �� �ִ�.

(lambda (x) (+ x 4))

(lambda (x) (/ 1.0 (* x (+ x 2))))

���� �̿��� �Ʒ��� ���� ���� ����

(define (pi-sum a b)
  (sum (lambda (x) (/ 1.0 (* x (+ x 2))))
       a
       (lambda (x) (+ x 4))
       b))

(pi-sum 1 10)

���ν����� �̸��� �ʿ����� �ʴ�.
(lambda (<formal-parameters>) <body>)

(define (integral f a b dx)
  (* (sum f
	  (+ a (/ dx 2.0))
	  (lambda (x) (+ x dx))
	  b)
     dx))

(integral (lambda (x) x) 0 1 0.01)

;;; �Ʒ� ���� ���� ���̴�.
(define (plus4 x) (+ x 4))

(define plus4 (lambda (x) (+ x 4)))

(lambda             (x)             (+    x     4))  the procedure   of an argument x  that adds  x and 4
x�� 4�� ���� ���� x�� ���ν����� ǥ���� �� �ִ�.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p81

;; ���ν��� �̸��� �� �� �ִ� ��� �ڸ��� lambda ���� �ᵵ ����

((lambda (x y z) (+ x y (square z))) 1 2 3)




;;;;------------------------------------------------------------------
;;; let���� ���� ���� �����
���� ������ ����� ���� let�� �������

x�Ӹ� �ƴ϶� y�� a�� b�� ���� ������ ��� �̸��� �����Ѵ�. ���������� ���ε��ϴ� ���� ���ν����� ����� �޼��� �� �ִ�. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p82
(define (f x y)
  (define (f-helper a b)
    (+ (* x (square a))
       (* y b)
       (* a b)))
  (f-helper (+ 1 (* x y))
	    (- 1 y)))

(f 3 4)
���ε��� ���� ������ ���� �͸� ���ν����� ������ ���� ǥ������ ��밡���ϴ�.
f�� �ٵ�� ���ν����� ȣ���ϴ� ���� ���̴�.
;;=> lambda ������
(define (f x y)
  ((lambda (a b)
    (+ (* x (square a))
       (* y b)
       (* a b)))
   (+ 1 (* x y))
   (- 1 y)))

(f 3 4)

�� ������ �� ȿ�������� let�� ȣ���ϴ� ����� ���� �����ϴ�.

;;=> let�� �Ἥ
(define (f x y)
  (let ((a (+ 1 (* x y)))
	(b (- 1 y)))
    (+ (* x (square a))
       (* y b)
       (* a b))))

(f 3 4)

let�� �Ϲ���
(let ((<var1> <exp1>)       (<var2> <exp2>)       (<varn> <expn>))    <body>)

let ǥ���� ù��° �κ��� �̸� ǥ������ ����Ʈ�̴�. let�� �ٵ�� ���� ������ ���ε�� �̸���� �򰡵ȴ�.

((lambda (<var1> ...<varn>)     <body>)  <exp1>  <expn>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p83

;;; let���� lambda ���� �� ���ϰ� ������ ���� ������ ������ ���̴�.

let�� �׵��� ���Ǵ� ������ ���������� ������ ���ε� �Ѵ�.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p84

x�� �ش� ǥ�������� 5�̴�.

(let ((x 5))
  (+ (let ((x 3))
       (+ x (* x 10)))
     x))

let�� �ٵ𿡼� x�� ���̰�, let ǥ���� 33�̴�. �ݸ� x�� �ι�°���� ������ 5�̴�.

(let ((x 3)
	(y (+ x 2)))
	(* x y))

;;; define���� ���ʿ��� �̸��� �����Ͽ� letó�� �� �� �ִ�.
;;; ������ �� å������ ������ define�� ���ʿ��� ���ν����� ������ ������ ����� �Ѵ�.

(define (f x y)
  (define a (+ 1 (* x y)))
  (define b (- 1 y))
  (+ (* x (square a))
     (* y b)
     (* a b)))

(f 3 4)



;;;--------------------------< ex 1.34 >--------------------------
;;; p85

;;;---
(define (square x)
  (* x x))
;;;---

(define (f g)
  (g 2))

(f square)

(f (lambda (z) (* z (+ z 1))))

;;; ������ ��� �Ǵ°�? �� �׷���?
(f f)
;;-> (f 2)
;;->Error: 2 is not a function
;; f�� ���� 2�� �����ϴ� ����� ���ǵǾ� ���� �ʴ�.




;;;;=================================<ch 1.3.3>=================================
;;; �Ϲ����� ����� ǥ���ϴ� ���ν���
;;; p85
;;;������ ���ν����� ���� �� �Ϲ�ȭ ��Ű�� �߻�ȭ�ϴ� ���
;;;;------------------------------------------------------------------
;;; �̺й����� �������� �� ã��

;;; p86

(define (average a b)
  (/ (+ a b) 2))

(define (search f neg-point pos-point)
  (let ((midpoint (average neg-point pos-point)))
    (if (close-enough? neg-point pos-point)
	midpoint
	(let ((test-value (f midpoint)))
	  (cond ((positive? test-value)
		 (search f neg-point midpoint))
		((negative? test-value)
		 (search f midpoint pos-point))
		(else midpoint))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p86
(define (close-enough? x y)
  (< (abs (- x y)) 0.001))

(define (half-interval-method f a b)
  (let ((a-value (f a))
	(b-value (f b)))
    (cond ((and (negative? a-value) (positive? b-value))
	   (search f a b))
	  ((and (negative? b-value) (positive? a-value))
	   (search f b a))
	  (else
	   (error "Values are not of opposite" a b)))))

;;; sin(x) =0 �� �� ã��
(half-interval-method sin 2.0 4.0)

;;; x^3 - 2x - 3 = 0 �� �Ǳ�
(half-interval-method (lambda (x) (- (* x x x) (* 2 x) 3))
		      1.0
		      2.0)



;;;;------------------------------------------------------------------
;;; �Լ��� ������ ã��
;;; p88
;;; f(x) = x �� ���̸� x�� f�� ������(fixed point)�� �Ѵ�.
;;; Ư�� �Լ����� f�� f�� �ݺ������� �����ϰ� �ʱ� ��밪���� �����Ͽ� �������� �̸� �� �ִ�.

;;; �� ���̵��� �Լ��� �������� �ٻ��ϴ� ���� ����� ��밪�� �ʱ�ȭ �Ͽ� �Լ��� �Է� ���� ���� �� �ִ�.
 ;;; ������������ �۰� ������ ���� �ݺ��� �Լ��� ������ ã�� �� ������ ���� �ɸ��� �ʴ´�.
(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

�� �޼ҵ带  �̿��� �ڻ��� �Լ��� �ʱ� �ٻ縦 1�� ������ ã�� �� �ִ�.

(fixed-point cos 1.0)

;;;'��57; �������� ���� ������ ���� ��忡�� �ݺ��� cos�� ������. ������ �� �غ�����.
;;; 0.73908513321516064165531208767387
;;; p88

;;; ���������� y=siny+ cosy�� ���� ã�� �� �ִ�.

(fixed-point (lambda (y) (+ (sin y) (cos y)))
	     1.0)


;;; x�� �������� y^2=x ��� ���ǿ� �´� y�� ã�� �����̴�.
;;; -> y=x/y => y |-> x/y �Լ��� �������� ã�� ������ ����

(define (sqrt x)
  (fixed-point (lambda (y) (/ x y))
	       1.0))

(sqrt 2)
;;<- ���� �ȳ���.

;;; ��� ���� ������(average damping)
(define (sqrt x)
  (fixed-point (lambda (y) (average y (/ x y)))
	       1.0))

(sqrt 2)


;;;--------------------------< ex 1.35 >--------------------------
;;; p90

;;; in p50
;;; phi = (1+sqrt(5))/2 =~ 1.6180

;;; phi^2 = phi + 1
;;; => phi = 1 + 1/phi
;;; => x |-> 1 + 1/x

(fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0)
;;-> 1.6180327868852458



;;;--------------------------< ex 1.36 >--------------------------
;;; p90

;;;---
(define tolerance 0.00001)
;;;---

(define (fixed-point-display f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (print guess)
      (newline)
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

(fixed-point-display (lambda (x) (/ (log 1000) (log x)))
		     1.5)
;;;-> 4.555539351985717



;;;--------------------------< ex 1.37 >--------------------------
;;; p90,91

;;; �ǵ��� ���μ���(recursive process)
(define (cont-frac n d k)
  (define (jth-frac j)
    (if (= j k)
	(/ (n j) (d j))
	(/ (n j) (+ (d j) (jth-frac (+ j 1))))))
  (jth-frac 1))

;;; phi =~ (1 + (sqrt 5)) / 2 =~ 1.618033988749989
;;; 1/phi =~ 0.6180339887498588

(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 1)  ; 1.0
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 2)  ; 0.5
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 3)  ; 0.6666666666666666
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 4)  ; 0.6000000000000001
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 5)  ; 0.625
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 10)  ; 0.6179775280898876
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 15)  ; 0.6180344478216819
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 20)  ; 0.6180339850173578
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 30)  ; 0.6180339887496482
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 50)  ; 0.6180339887498948

;;; test 
(cont-frac (lambda (i) 1.0) (lambda (i) 2.0) 3)  ; (/ 1. (+ 2 (/ 1 (+ 2 (/ 1 2)))))



;;; �ݺ� ���μ���(iterative process)
(define (cont-frac-iter n d k)
  (define (frac-inner j acc-frac)
    (if (> j 2)
	(frac-inner (- j 1)
		     (/ (n (- j 1))
			(+ (d (- j 1)) acc-frac)))
	(/ (n 1) (+ (d 1) acc-frac))))
  (if (= k 1)
      (/ (n 1) (d 1))
      (frac-inner k (/ (n k) (d k)))))

(/ 1. (+ 1 (/ 1 (+ 1 (/ 1 1)))))  ; k:3
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 1)   ; 1.0
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 2)   ; 0.5
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 3)   ; 0.6666666666666666
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 4)   ; 0.6000000000000001
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 5)   ; 0.625
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 10)  ; 0.6179775280898876
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 15)  ; 0.6180344478216819
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 20)  ; 0.6180339850173578
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 30)  ; 0.6180339887496482
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 50)  ; 0.6180339887498948



;;;--------------------------< ex 1.38 >--------------------------
;;; p91,92

;; 1/
;;   (1 + 1/
;;     (2 + 1/
;;       (1 + 1/
;;         (1 + 1/
;;           (4 + 1/
;;             (1 + 1/
;;                ...
;;                       ))))))

;; j mod 3
;; ->   1 2 0
;; -----------
;; dj : 1 2 1     (j: 1  2  3)
;;      1 4 1     (   4  5  6)
;;      1 6 1     (   7  8  9)
;;      1 8 1 ... (  10 11 12)
;;        ^
;;        | : (j + 1) / 3 * 2

(define (cont-frac-euler k)
  (define (d-euler j)
    (let ((rem (remainder j 3)))
      (cond ((= rem 0) 1.0)
	    ((= rem 1) 1.0)
	    (else (* (/ (+ j 1.) 3.) 2.0)))))
  (cont-frac-iter (lambda (i) 1.0) d-euler k))


;; e =~ 2.718281828459045
;; <- (exp 1)
;; e-2 =~ 0.718281828459045
(cont-frac-euler 1) ; 1.0                  ; (/ 1. 1)
(cont-frac-euler 2) ; 0.6666666666666666   ; (/ 1. (+ 1 (/ 1 2)))
(cont-frac-euler 3) ; 0.75                 ; (/ 1. (+ 1 (/ 1 (+ 2 (/ 1 1)))))
(cont-frac-euler 4) ; 0.7142857142857143
(cont-frac-euler 5) ; 0.71875 ; (/ 1. (+ 1 (/ 1 (+ 2 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 4)))))))))
(cont-frac-euler 6) ; 0.717948717948718
(cont-frac-euler 10)
(cont-frac-euler 20) ; 0.7182818284590452
(cont-frac-euler 30) ; 0.7182818284590453
(cont-frac-euler 40) ; 0.7182818284590453
(cont-frac-euler 50) ; 0.7182818284590453

;(/ 1. (+ 1 (/ 1 (+ 2 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 4 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 6 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 8 (/ 1 1)))))))))))))))))))))))
;-> 0.7182818229439497


;;;--------------------------< ex 1.39 >--------------------------
;;; p92

;;; �ǵ��� ���μ���(recursive process)
(define (tan-cf x k)
  (define (n i)
    (square i))
  (define (d i)
    (+ (* (- i 1) 2) 1))
  (define (tan-cf-rec n d k)
    (define (jth-frac j)
      (if (= j k)
	  (/ (n x) (d j))
	  (/ (n x) (- (d j) (jth-frac (+ j 1))))))
    (jth-frac 2))
  (if (= k 1)
      (/ x (d 1))
      (/ x (- (d 1) (tan-cf-rec n d k)))))

(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902

;;; �ݺ� ���μ���
(define (tan-cf x k)
  (define (tan-cf-iter n1 n d k)
    (define (jth-tan-cf-inner j acc-frac)
      (if (> j 2)
	  (jth-tan-cf-inner (- j 1)
			    (/ (n x)
			       (- (d (- j 1)) acc-frac)))
	  (/ (n1 x) (- (d 1) acc-frac))))
    (if (= k 1)
	(/ (n x) (d 1))
	(jth-tan-cf-inner k (/ (n x) (d k)))))
  (tan-cf-iter (lambda (i) i) 
	       (lambda (i) (square i))
	       (lambda (i) (+ (* (- i 1) 2) 1))
	       k))

(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; �Ʒ��� ���� ���¸� ���� ���Ӻм� ����Լ��� ������ �Լ�
; n1(x) /
;        C( d(1) , n(x) /
;                         C( d(2) , n(x) / 
;                                         ...
;                                         C( d(k-1) , n(x) / d(k)

;;; �ݺ� ���μ���(iterative process)
(define (cf-general-iter combiner n1 n d)
  (lambda (x k)
    (define (frac-inner j acc-frac)
      (if (> j 2)
	  (frac-inner (- j 1)
		      (/ (n x)
			 (combiner (d (- j 1)) acc-frac)))
	  (/ (n1 x) (combiner (d (- j 1)) acc-frac))))
    (if (= k 1)
	(/ (n x) (d 1))
	(frac-inner k (/ (n x) (d k))))))

(define tan-cf
  (cf-general-iter -
		   (lambda (i) i) 
		   (lambda (i) (square i))
		   (lambda (i) (+ (* (- i 1) 2) 1))))


(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902





;;;;=================================<ch 1.3.4>=================================
;;; ���ν����� ����� ���ν���
;;; p92

;;; ���ν����κ��� ������ ������ ���ν����� ����� �Ŀ�Ǯ�� ǥ���� ���� �� �ִ�.fixed-point �������� ���̵� ���� �� �ִ�. �ٻ� ������ �ϱ� ���� average damping�� ����Ѵ�. �Լ� f�� �츮�� x�� ��հ� f(x)�� �������� x���� ���� ���� �Լ��� ������ �� �� �ִ�.
;;; �Ʒ� ���ν����� ��հ��� ���� average damping�� ���̵� ǥ���� �� �ִ�.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p92

(define (average-damp f)
  (lambda (x) (average x (f x))))

;;; ��� ����� ���ν��� f�� ���ڷ� ����� ���ν����̴�. �� ���� ���ν����� ���� ���ϵǰ�. (���ٿ� ���� ����)x�� ����� ��, x�� fx�� ����� �����Ѵ�. ���� ��� ��հ��Ⱑ ����� square ���ν����� x�� x^2�� ��� �� x �� ������ ������. 10�� ����� 10�� 100�� ����� 55�̴�.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p93

;;;---
(define (square x)
  (* x x))
;;;---

((average-damp square) 10)
;;55

(define (sqrt x)
  (fixed-point (average-damp (lambda (y) (/ x y)))
	       1.0))
;; ������ ã��,  ��� ��Ƶ��, y|-> x/y  ������ �״�� �巯��

(sqrt 2)

;; ���α׷��Ӵ� ���� �������� ������ ���� �����Ͽ� ������ �� �־�� �Ѵ�.
;;;;;;;;;;;;;;;;;;;;;;;
;;; p94

;;; y^3 = x
;;; y |-> x / y^2
(define (cube-root x)
  (fixed-point (average-damp (lambda (y) (/ x (square y))))
	       1.0))

(cube-root 8)



;;;;------------------------------------------------------------------
;;; ��ư���
;;; p94

;;; x |-> g(x) �� �̺еǴ� �Լ��̸�,
;;; g(x) = 0 �� ���� �Լ� x |-> f(x) �� ������ ����.
;;; �� ��, f(x) = x - g(x)/Dg(x)

;;; Dg(x) = (g(x + dx) - g(x)) / dx

;;;;;;;;;;;;;;;;;;;;;
;;; p95
(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x))
       dx)))

(define dx 0.00001)

(define (cube x) (* x x x))

((deriv cube) 5)



;;;---
(define (square x)
  (* x x))
;;;---

(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x))
       dx)))

(define dx 0.00001)

(define (cube x) (* x x x))
((deriv cube) 5)
75.00014999664018

;;;; deriv�� �Ἥ ���� ����� ������ ã�� ������� ǥ��
;;; f(x) = x - g(x)/Dg(x) �� �ش�
(define (newton-transform g)
  (lambda (x)
    (- x (/ (g x) ((deriv g) x)))))

(define (newtons-method g guess)
  (fixed-point (newton-transform g) guess))

;;; ������ : y |-> y^2 - x       <-- ???
;;; y^2 = x   =>  y^2 - x = 0   <-- g(x) = 0 �̶�?

(define (sqrt x)
  (newtons-method (lambda (y) (- (square y) x))
		  1.0))

(sqrt 2)


;;; ���������� ��ư ����� ������ ã�� �������
;;; y^3 = x  =>  y^3 - x = 0    <-- g(x) = 0   
(define (cube-root x)
  (newtons-method (lambda (y) (- (cube y) x))
		  1.0))

(cube-root 8)




;;;;------------------------------------------------------------------
;;; ���� �ϵ�� ���ν���
;;; p96

(define (fixed-point-of-transform g transform guess)
  (fixed-point (transform g) guess))

(define (sqrt x)
  (fixed-point-of-transform (lambda (y) (/ x y))
			    average-damp
			    1.0))

(sqrt 2)
;-> 1.4142135623746899

(define (sqrt x)
  (fixed-point-of-transform (lambda (y) (- (square y) x))
			    newton-transform
			    1.0))

(sqrt 2)
;-> 1.4142135623822438

;;; �Ǹ��� ������ �ϱް�ü ��Ҵ� �Ʒ��� ����.

;;; ���� �ð� �߿� �����ǰ� �����ƾ�� ������ ���·� ��ȯ�ϴ� ��ƼƼ�� ����Ų��.

;;; They may be named by variables.

;;; ������ ���� ���Ǿ�� �Ѵ�.

;;; They may be passed as arguments to procedures.

;;; ���ν����� ���ڷ� ���޵Ǿ�� �Ѵ�.

;;; They may be returned as the results of procedures.

;;; ���ν����� ����� ���� ��ȯ�ȴ�.

;;; They may be included in data structures
;;; ������ ������ ���� ���Եȴ�.
;;; LISP�� �ϱ� ��ü ���¸� ���´�.
;;; ȿ������ ������ ���� ������ ������, ����� ����.


;;;--------------------------< ex 1.40 >--------------------------
;;; p98
(define (cubic a b c)
  (lambda (x)
    (+ (expt x 3)
       (* a (expt x 2))
       (* b x)
       c)))

;;; x^3 - 3x^2 + 3x -1 = (x - 1)^3 =0 
;;; => x = 1
(newtons-method (cubic -3 3 -1) 1)
;; => 1

;;; x^3 - 3x^2 + 2x + 0 = x(x - 1)(x - 2) = 0
;;; => x = 0, 1, 2
(newtons-method (cubic -3 2 0) 0.1) ;-> 6.373186586624513e-12
(newtons-method (cubic -3 2 0) 0.9) ;-> 0.9999999999999999
(newtons-method (cubic -3 2 0) 1.7) ;-> 2.000000000023838


;;;--------------------------< ex 1.41 >--------------------------
;;; p98
(define (double f)
  (lambda (x)
    (f (f x))))

;;;---
(define (inc x)
  (+ x 1))
;;;---

((double inc) 3) ;-> 5

(((double (double double)) inc) 5)  ;-> 21
;; double -> 2 ��
;; (double double) -> 2 * 2 -> 4 ��
;; (double (double double)) -> 4 * 4 -> 16 ��
;; => inc�� 16 �� ���� : +16


;;;--------------------------< ex 1.42 >--------------------------
;;; p99
(define (compose f g)
  (lambda (x)
    (f (g x))))

;;;---
(define (square x)
  (* x x))
;;;---

((compose square inc) 6)
;; (square (inc 6)) -> (square 7) -> 49

;;;--------------------------< ex 1.43 >--------------------------
;;; p99
(define (repeated f n)
  (if (= n 1)
      f
      (repeated (compose f f) (- n 1))))

((repeated square 2) 5)
;;; -> 625


;;;--------------------------< ex 1.44 >--------------------------
;;; p99
(define dx 0.1)

(define (smooth f)
  (lambda (x)
    (/ (+ (f (- x dx))
	  (f x)
	  (f (+ x dx)))
       3)))

;;; f :
;;;  ^
;;;1 | -----
;;;  | |   |
;;;---------------> x
;;;  0 1 2 3
(define (f x)
  (cond ((< x 1) 0)
	((> x 3) 0)
	(else 1)))
(f 0)   ; 0
(f 0.9) ; 0
(f 1)   ; 1
(f 1.1) ; 1
(f 2)   ; 1
(f 3)   ; 1

((smooth (lambda (x) (* x x))) 1)
;;; smooth f :
;;;  ^
;;;1 |  ---
;;;  | /   \
;;;---------------> x
;;;  0 1 2 3

;;; dx=0.1 �϶�
((smooth f) 0)   ; 0
((smooth f) 0.9) ; 1/3
((smooth f) 1)   ; 2/3
((smooth f) 1.1) ; 1
((smooth f) 2)   ; 1
((smooth f) 3)   ; 2/3


;;; n�� �ٵ�� �Լ�
(define (n-fold-smooth n)
  (repeated smooth n))

(((n-fold-smooth 3) f ) 0)   ; 0
(((n-fold-smooth 3) f ) 0.9) ; 31/81
(((n-fold-smooth 3) f ) 1)   ; 50/81
(((n-fold-smooth 3) f ) 1.1) ; 22/27
(((n-fold-smooth 3) f ) 2)   ; 1
(((n-fold-smooth 3) f ) 3)   ; 50/81


;;;--------------------------< ex 1.45 >--------------------------
;;; p100

;; y^3 = x
;; => y |-> x / y^2
((lambda (x)
  (fixed-point (average-damp (lambda (y) (/ x (square y)))) 0.1))
 1)
; 0.9999979647655368

;; y^4 = x
;; => y |-> x / y^3
((lambda (x)
  (fixed-point (average-damp (lambda (y) (/ x (cube y)))) 0.1))
 1) ; ��ճ��������� 1�� -> �� �ȳ���

((lambda (x)
  (fixed-point ((repeated average-damp 2) (lambda (y) (/ x (cube y)))) 0.1))
 1) ; ��ճ��������� 2�� 
; 1.0000000000394822

;; y^5 = x
((lambda (x)
  (fixed-point ((repeated average-damp 2) (lambda (y) (/ x (* y y y y)))) 0.1))
 1) 
 ; ��ճ��������� 2�� -> 1.0000000000394822

;;;-----------------------------
;; n sqrt�� m�� ���������� ���ϴ� �Լ��� ����� �Լ�
(define (gen-fp-nsqrt m-damp n-pow)
  (lambda (x)
    (fixed-point ((repeated average-damp m-damp) (lambda (y) 
						   (/ x (expt y (- n-pow 1)))))
		 0.1)))

;; y^3 = x
((gen-fp-nsqrt 1 3) 1) ; 0.9999979647655368

;; y^4 = x
((gen-fp-nsqrt 1 4) 1) ; x
((gen-fp-nsqrt 2 4) 1) ; 1.0000000000394822

;; y^5 = x
((gen-fp-nsqrt 1 5) 1) ; x
((gen-fp-nsqrt 2 5) 1) ; 1.0000005231525688

;; y^6 = x
((gen-fp-nsqrt 1 6) 1) ; x
((gen-fp-nsqrt 2 6) 1) ; 1.0000025135159185

;; y^7 = x
((gen-fp-nsqrt 1 7) 1) ; 0.9999982817926396
((gen-fp-nsqrt 2 7) 1) ; 0.9999964281410385

;; y^8 = x
((gen-fp-nsqrt 2 8) 1) ; x
((gen-fp-nsqrt 3 8) 1) ; 1.0000070713124947

;; y^9 = x
((gen-fp-nsqrt 2 9) 1) ; x
((gen-fp-nsqrt 3 9) 1) ; 1.0000039048439704

;; y^10 = x
((gen-fp-nsqrt 2 10) 1) ; x
((gen-fp-nsqrt 3 10) 1) ; 1.0000000000394822

;; y^11 = x
((gen-fp-nsqrt 2 11) 1) ; x
((gen-fp-nsqrt 3 11) 1) ; 1.000002632280844

;; y^12 = x
((gen-fp-nsqrt 2 12) 1) ; 1.0000006655983138
((gen-fp-nsqrt 3 12) 1) ; 1.0000008866907955

;; y^15 = x
((gen-fp-nsqrt 2 15) 1) ; 1.0000065559266993
((gen-fp-nsqrt 3 15) 1) ; 1.000000079561101

;; y^16 = x
((gen-fp-nsqrt 2 16) 1) ; 1.0000053925024897
((gen-fp-nsqrt 3 16) 1) ; 1.0000000000954519


;;;---
(define (cube x)
  (* x x x))

(define (square x)
  (* x x))

(define (average-damp f)
  (lambda (x) (average x (f x))))

(define (average x y)
  (/ (+ x y) 2))     
;;;---

;;;--------------------------< ex 1.46 >--------------------------
;;; p100

(define (iterative-improve1 f-improve f-good-enough? guess)
  (define (iter guess x)
    (if (f-good-enough? guess x)
	guess
	(iter (f-improve guess) x)))
  (lambda (x)
    (iter 1.0 x)))



;;; p40�� sqrt�� �Ʒ��� ���� ��ħ
;; sqrt -> iterative-improve
(define (sqrt-new x)
  (define (improve guess)
    (average guess (/ x guess)))
  (define (good-enough? guess x)
    (< (abs (- (square guess) x)) 0.001))
  ((iterative-improve1 improve good-enough? 1.0) x))

(sqrt-new 9) ; 3.00009155413138

;-------------------------------------------------------------


(define (iterative-improve2 f-improve f-good-enough?)
  (define (iter guess)
    (let ((next (f-improve guess)))
      (if (f-good-enough? guess next)
	  next 
	  (iter next))))
  (lambda (first-guess)
    (iter first-guess)))


;;; p88�� fixed-point�� �Ʒ��� ���� ��ħ
(define tolerance 0.00001)

(define (fixed-point-new f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  ((iterative-improve2 f close-enough?) first-guess))

(fixed-point-new cos 1.0)
(fixed-point-new (lambda (y) (+ (sin y) (cos y))) 1.0)

;;; p89�� sqrt�� ������ ���� ��ħ
;; sqrt -> fixed-point-new -> iterative-improve
(define (sqrt-new2 x)
  (fixed-point-new (lambda (y) (average y (/ x y)))
		   1.0))

(sqrt-new2 9)