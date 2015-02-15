;이 장은, 컴퓨터로 실제 세계를 흉내내고자 할 때,
;사람이 사물이나 현상을 받아들이는 방식에 따라 물체의 구조를 짜맞춘다는 목표를 가지고 시작되었다.
;우리는, 실세계의 컴퓨터 모형을 시간에 따라 상태가 변하는 여러 물체의 집합으로볼 수도 있고,
;그와 달리 상태도 없고 시간의 영향을 받지도 않는 단일체로 볼수도 있다.
;어떤 관점을 따르든 제각기 큰 장점을 얻을 수 있지만, 어느 한 쪽도 완전히 만족스러운 해법을 안겨 주지는 못한다.
;이 둘을 멋지계 합치는 방법은 아직도나오지 않았다.(책 말미에 나오는 내용입니다. X-FILE 느낌.. ㅎ)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ch 3 모듈, 물체, 상태
;;; Ch 3.5 스트림
;;; p411

;; 셈미룸 계산법(delayed evaluation" 기법을 쓰면 끝없는 차례열도 스트림으로 나타낼 수 있다.




;;;==========================================
;;; 3.5.1 스트림과 (계산을) 미룬 리스트
;;; p412

;; 차례열을 리스트로 표현하면 쉽고도 깔끔하기는 하지만,
;; 시간과 공간 효율이 모두 떨어지는 대가를 치러야 한다.

;413p
;반복방식
(define (sum-primes a b)
  (define (iter count accum)
    (cond ((> count b) accum)
          ((prime? count) (iter (+ count 1) (+ count accum)))
          (else (iter (+ count 1) accum))))
  (iter a 0))
  
;차례열 연산
  (define (sum-primes a b)
  (accumulate +
              0
              (filter prime? (enumerate-interval a b))))

;; p414
;; 스트림은 리스트만큼 커다란 대가를 치르지 않으면서도 차례열 패러다임으로 프로그램을 짤 수 있도록 도와주는 멋진 기법이다.
;; 어떤 프로그램에서 스트림을 인자로 받는 경우.
;; - 스트림을 덜 만든 상태 그대로 넘긴 다음
;; - 스트림 자체가 딱 쓸 만큼만 알아서 원소를 만들어 내게끔 하는 것이다.

;; p415

;(stream-car (cons-stream x y) ) = x
;(stream-cdr (cons-stream x y) ) = y

;(define the-empty-stream '())

;(define (stream-null? s)
;  (null? s))

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

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

(define (display-stream s)
  (stream-for-each display-line s))

(define (display-line x)
  (newline)
  (display x))

;;-----------------------------------------------
;; p417
;; cons-stream 프로시저는 다음처럼 정의된 특별한 형태다.
;; (cons-stream <a> <b>)
;; ->
;; (cons <a> (delay <b>))
;;=> "다음처럼 정의된 특별한 형태다"라는 말은 define으로 정의하는 것이 아니라
;;   언어 해석기 차원에서 변환하도록 정의된다라는 말인 것 같다.
;;   즉 이것은 매크로로 정의하거나 언어 해석기의 구현을 이와 같이 해야한다.
;; (define (cons-stream a b) 
;;   (cons a (delay b)))

(define-syntax cons-stream
  (syntax-rules ()
    ((cons-stream x y)
     (cons x (delay y)))))

(define (stream-car stream) (car stream))

(define (stream-cdr stream) (force (cdr stream)))


;;; 스트림은 어떻게 돌아가는가

;;------------------------------------------------
;;;---
;; p64 ch 1.2.6
(define (square x) (* x x))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))
;;;---

;;; 어떤 범위에 있는 모든 정수를 뽑아내는 연산
(define nil '())

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))

(define (filter predicate sequence)
  (cond ((null? sequence) nil)
	((predicate (car sequence))
	 (cons (car sequence)
	       (filter predicate (cdr sequence))))
	(else (filter predicate (cdr sequence)))))

;; 일반 차례열
;; (filter prime?
;; 	(enumerate-interval 10000 1000000))
 

;;--------------------------------------------------
;; 스트림용 이누머레이터
(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream 
       low 
       (stream-enumerate-interval (+ low 1) high))))

(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
	((pred (stream-car stream))
	 (cons-stream (stream-car stream)
		      (stream-filter pred
				     (stream-cdr stream))))
	(else (stream-filter pred (stream-cdr stream)))))


(cons 10000
      (delay (stream-enumerate-interval 10001 1000000)))

(stream-filter prime?
	       (stream-enumerate-interval 10000 1000000))
;;--------------------------------------------------


;; p420
;; 대개 셈미룸 계산법은 바라는 대로 프로그램이 실행되도록 하는 방식의 한 가지.

;;; delay와 force 프로시저 만들기

;; delay 프로시저는 아래와 같은 특별한 형태로 나타낸다.
;;                          ^^^^^^^^^^^^^^^^^
;;                       -> 'define으로 정의한다'가 아니라 매크로 또는 해석기의 구현을 의미
;; (delay <exp>)
;; ->
;; (lambda () <exp>)

;; (define (force delayed-object)
;;   (delayed-object))


;;; 셈미룬 물체를 처음으로 계산한 다음에 그 값을 어딘가에 적어 두었다가
;;; 나중에 그 물체를 다시 쓸 때 
;;; 같은 것을 계산한다면 적어둔 값을 쓰도록 한다.
;421p

(define (memo-proc proc)
  (let ((already-run? false) (result false))
    (lambda ()
      (if (not already-run?)
	  (begin (set! result (proc))
		 (set! already-run? true)
		 result)
	  result))))

;;


;;;--------------------------< ex 3.50 >--------------------------
;;; p422
;아래는 stream-map 프로시저의 쓰임새를 늘려서, 2.2.1절 주석 12에서 본 map
;처럼 여러 인자를 받을 수 있도록 만든 것이다. 빈 곳을 채워라.

;(define (stream-map proc . argstreams)
;  (if (<??> (car argstreams))
;      the-empty-stream
;      (<??>
;       (apply proc (map <??> argstreams))
;       (apply stream-map
;	      (cons proc (map <??> argstreams))))))


(define (stream-map proc . argstreams)
  (if (null? (car argstreams))
      the-empty-stream
      (cons-stream
       (apply proc (map stream-car argstreams))
       (apply stream-map
	      (cons proc (map stream-cdr argstreams))))))

;;;--------------------------< ex 3.51 >--------------------------
;;; p422
;셈미룸 계산법이 어떻게 돌아가는지 더 꼼꼼히 살펴볼 수 있도록 다음 프로시
;저를 쓰기로 한다. 이 프로시저는 인자를 찍은 다음에 그대로 되돌려 준다.
;다음차례대로 식을 계산하였을 때, 실행기가 찍어내는 결과는 어떠한가?

(define x '())

(define (show x)
  (display-line x)
  x)

(define x
  (stream-map show
	      (stream-enumerate-interval 0 10)))
;; 0

(stream-ref x 5)
;; 1;2;3;4;5,5

(stream-ref x 7)
;; 6;7,7

;;;--------------------------< ex 3.52 >--------------------------
;;; p423
;아래 식들을 차례대로 계산한다고 하자.
;식을 하나씩 계산할 때마다 Sum 값은 어떻게 되는가?
;stream-ref 식과 display-stream식의 값을 구하면 어떤 값이 찍히는가? memo-proc을 써서 효율을 끌어올
;리지 않고, (delay <exp) 를 그냥 (lambda () <exp>)로 정의해 쓴다면, 답이 어떻게 달라지는가?

(define sum 0)

(define (accum x)
  (set! sum (+ x sum))
  sum)

(define seq
  (stream-map accum
	      (stream-enumerate-interval 1 20)))

(define y (stream-filter even? seq))
;; 
(define z (stream-filter (lambda (x) 
			   (= (remainder x 5) 0))
			 seq))

;; > sum
;; 1
;; > seq
;; (1 . #<promise>)
;; > > y
;; (6 . #<promise>)
;; > > z
;; (10 . #<promise>)

(stream-ref y 7)

(display-stream z)





;;;==========================================
;;; 3.5.2 무한 스트림(infinite stream)
;;; p424
;;끝없이 길게 늘어진 차례열도 표현할 수 있다

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

(define integers (integers-starting-from 1))

integers 

(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
(stream-ref integers 5)

(define (divisible? x y) (= (remainder x y) 0))

(define no-sevens
  (stream-filter (lambda (x) (not (divisible? x 7)))
		 integers))

(stream-ref no-sevens 100)


;; 피보나치 수들의 무한 스트림
(define (fibgen a b)
  (cons-stream a (fibgen b (+ a b))))

(define fibs (fibgen 0 1))

fibs



;;; 에라토스테네스의 체
(define (sieve stream)
  (cons-stream
   (stream-car stream)
   (sieve (stream-filter
	   (lambda (x)
	     (not (divisible? x (stream-car stream))))
	   (stream-cdr stream)))))

(define primes (sieve (integers-starting-from 2)))

primes

(stream-ref primes 0)
(stream-ref primes 1)
(stream-ref primes 2)
(stream-ref primes 3)
(stream-ref primes 4)

(stream-ref primes 50)


;;;;;;;;;;;;;;;;;;;;;;;
;;; 스트림을 드러나지 않게 정의하는 방법
;;; p427

(define ones (cons-stream 1 ones))

ones
;; car는 1이고, cdr는 다시 ones를 계산하겠다는 약속

(define (add-streams s1 s2)
  (stream-map + s1 s2))

(define integers (cons-stream 1 (add-streams ones integers)))

integers

(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
(stream-ref integers 5)


;; 피보나치수열(ones 와 add-streams 응용)
;		1	1	2	3	5	8	13	21	... = (stream-cdr fibs)
;		0	1	1	2	3	5	8	13	... = fibs
;0	1	1	2	3	5	8	13	21	34	... = fibs
;
;

(define fibs
  (cons-stream 0
	       (cons-stream 1
			    (add-streams (stream-cdr fibs)
					 fibs))))

fibs

(stream-ref fibs 0)
(stream-ref fibs 1)
(stream-ref fibs 2)
(stream-ref fibs 3)
(stream-ref fibs 4)
(stream-ref fibs 5)




;; 스트림의 모든 원소에 정해진 상수 값을 곱한다.
(define (scale-stream stream factor)
  (stream-map (lambda (x) (* x factor)) stream))

(define double (cons-stream 1 (scale-stream double 2)))

double


(stream-ref double 0)
(stream-ref double 1)
(stream-ref double 2)
(stream-ref double 3)
(stream-ref double 4)
(stream-ref double 5)



;; 정수의 스트림을 만든 후
;; 소수이면 걸러내는 방식
(define primes
  (cons-stream
   2
   (stream-filter prime?
		  (integers-starting-from 3))))


;; 
;	3	4	5	6	7	8	9	10	11	12	13... = integers-starting-from 3
;	3		5		7				11		13	17	13	21	34... = (stream-filter prime? (integers-starting-from 3))
;2	3		5		7				11		13	17	13	21	34... = primes

;; n이 sqrt(n) 과 같거나 그보다 작은 소수로 나누어지는지 따져봐야한다.
(define (prime? n)
  (define (iter ps)
    (cond ((> (square (stream-car ps)) n) #t) ;true)
	  ((divisible? n (stream-car ps)) #f) ;false)
	  (else (iter (stream-cdr ps)))))
  (iter primes))

primes

(stream-ref primes 0)
(stream-ref primes 1)
(stream-ref primes 2)
(stream-ref primes 3)
(stream-ref primes 4)
(stream-ref primes 5)

;;;--------------------------< ex 3.53 >--------------------------
;;; p430
;프로그램을돌려보지 않고아래처럼 정의한스트림의 원소를 적어 보라.

(define s (cons-stream 1 (add-streams s s)))

;; -> 1 2 4 8 16 ...
;	1	2	4	8	16	32	64	128... = s -> squre
;	1	2	4	8	16	32	64	128... = s -> squre
;1	2	4	8	16	32	64	128	256... = s -> squre

s

(stream-ref s 0)
(stream-ref s 1)
(stream-ref s 2)
(stream-ref s 3)
(stream-ref s 4)
(stream-ref s 5)

;;;--------------------------< ex 3.54 >--------------------------
;;; p430
;add-stre없입와 비슷하게 mul-streams 프로시저를 정의하라. mul-streams
;프로시저는 스트림 두 개를 인자로 받아서 원소끼리 곱한 결과를 내놓는다.
;integers 스트림과nrul-streams로아래 정의의 빈 곳을 채워서 (0부터 헤아렸
;을 때) n번째 원소의 값이 n+l 사다리곱&α01ial이 되는 스트림을 만들어 보라.

;(define factorials (cons-stream 1 (mul-streams <??> <??>)))

(define (mul-streams s1 s2)
  (stream-map * s1 s2))

(define s (cons-stream 2 (mul-streams s s)))

;; -> 4,16,256,65536

;	2	4	16	256... = mul-streams
;	2	4	16	256... = mul-streams
;2	4	16	256	65536... = mul-streams

(stream-ref s 0)
(stream-ref s 1)
(stream-ref s 2)
(stream-ref s 3)
(stream-ref s 4)
(stream-ref s 5)


;1	2	3	4	5	6... = integers(가)
;	1	2	6	24	60... = factorials(나)
;1	2	6	24	60	360... = factorials(가*나->mulstreams)

(define factorials (cons-stream 1 (mul-streams factorials integers)))

factorials

(stream-ref factorials 0)
(stream-ref factorials 1)
(stream-ref factorials 2)
(stream-ref factorials 3)
(stream-ref factorials 4)
(stream-ref factorials 5)


;;;--------------------------< ex 3.55 >--------------------------
;;; p430

;; 스트림 S를 인자로 받아서
;; S0, S0+S1, S0+S1+S2, ... 을 원소로 갖는 스트림을 내놓는 프로시저
;예를 들어, (partial-sums integers)의 결과는 스트림 1, 3, 6, 10, 15, .. -과 같다.

(define (partial-sums stream)
  (define pts
    (cons-stream (stream-car stream)
		 (add-streams (stream-cdr stream)
			     pts)))
  pts)

(define pts (partial-sums integers))


(stream-ref integers 0)
(stream-ref integers 1)
(stream-ref integers 2)
(stream-ref integers 3)
(stream-ref integers 4)
;; 1 2 3 4 5

(stream-ref pts 0)
(stream-ref pts 1)
(stream-ref pts 2)
(stream-ref pts 3)
(stream-ref pts 4)
(stream-ref pts 5)


;;;--------------------------< ex 3.56 >--------------------------
;;; p430

;; 2,3,5 외의 소수 인수를 가지지 않는 양의 정수를 작은 것부터 차례대로 반복하지 않고
;늘어놓는 문제

;; 만족하는 스트림 S
;; - S는 1로 시작한다.
;; - (scale-stream S 2)의 원소는 S의 원소다
;; - (scale-stream S 3)과 (scale-stream 5 6)의 원소도 그러하다.
;; - S의 원소는 이게 다다.

(define (merge s1 s2)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (cond ((< s1car s2car)
		  (cons-stream s1car (merge (stream-cdr s1) s2)))
		 ((> s1car s2car)
		  (cons-stream s2car (merge s1 (stream-cdr s2))))
		 (else
		  (cons-stream s1car
			       (merge (stream-cdr s1)
				      (stream-cdr s2)))))))))

;; (define S (cons-stream 1 (merge <??>)))
(define S (cons-stream 1 (merge (scale-stream S 2)
				(merge (scale-stream S 3)
				       (scale-stream S 5)))))

S


(stream-ref S 0)
(stream-ref S 1)
(stream-ref S 2)
(stream-ref S 3)
(stream-ref S 4)
(stream-ref S 5)
(stream-ref S 6)
(stream-ref S 7)
(stream-ref S 8)
(stream-ref S 9)
(stream-ref S 10)
(stream-ref S 11)
(stream-ref S 12)
(stream-ref S 13)
(stream-ref S 14)
(stream-ref S 15)
(stream-ref S 16)





;;;--------------------------< ex 3.57 >--------------------------
;;; p432

;; n번째 피보나치 수를 구하는데 필요한 덧셈의 수
;; - 지수 비례로 늘어난다는 사실을 밝혀라.

;FIB로의 모든 용어는 이전의 두 측면의 합으로 먼저 계산된다.
;FIB로 각각 이전 용어를 리콜 memoized 때문에 더 추가 할 필요가 없습니다.
;따라서 첫 번째 후 각 용어 하나 추가를 사용합니다. 추가가 만들어집니다
;(N-1, 0), 최대 (N = 0에서 시작) n 번째 기간을 계산합니다.
;우리의 FIB를 memoized하지 않은 경우, 재 계산되는 각 용어를 필요로 FIB로의 이전 조건을 기억합니다.
;지수 1 가산 - 계산하지 유일한 조건 1 및 제로이므로, FIB (N) 적어도 FIB (N)을 필요로한다.


;;;--------------------------< ex 3.58 >--------------------------
;;; p432
;아래 프로시저가 만들어 내는스트림이 어떤 것인지 해석해 보라.

(define (expand num den radix)
  (cons-stream
   (quotient (* num radix) den)
   (expand (remainder (* num radix) den) den radix)))

(define s1 (expand 1 7 10))

(stream-ref s1 0)
(stream-ref s1 1)
(stream-ref s1 2)
(stream-ref s1 3)
(stream-ref s1 4)
(stream-ref s1 5)
(stream-ref s1 6)
(stream-ref s1 7)
(stream-ref s1 8)
(stream-ref s1 9)
(stream-ref s1 10)

(define s2 (expand 3 8 10))

(stream-ref s2 0)
(stream-ref s2 1)
(stream-ref s2 2)
(stream-ref s2 3)
(stream-ref s2 4)
(stream-ref s2 5)
(stream-ref s2 6)
(stream-ref s2 7)
(stream-ref s2 8)
(stream-ref s2 9)
(stream-ref s2 10)


;;;--------------------------< ex 3.59 >--------------------------
;;; p432

;; a) a0 + a1x + a2x^2 + a3x^3 + ...
;; -> c + a0x + 1/2*a1x^2 + 1/3*a2x^3 + ...
;2.5.3절에서 다항식을 리스트로나타내어 다항식 계산시스랩을 어떻게 구현하
;는지 살펴보았다. 그와 비슷하게 아래와 같은 거듭제곱 수열power series을 무한
;스트림으로나타내어 여러 가지 일을할 수 있다.
;식에서 C는 상수다. 거듭제곱 수열을 나타내는 스트림 α。, a1 ' ι, - --를 인
;자로 받아, 그 수열의 적분 값을 나타내는 (상수항을 뺀) 수열의 계수를 뽑아
;내는 integrate-series 프로시 저를 정의해 보라

(define (integrate-series s-before)
  (define series
    (stream-map / s-before 
		(stream-cdr integers)))
  series)


(define s-integrated (cons-stream 1 (integrate-series ones)))

(stream-ref s-integrated 0)
(stream-ref s-integrated 1)
(stream-ref s-integrated 2)
(stream-ref s-integrated 3)
(stream-ref s-integrated 4)
(stream-ref s-integrated 5)

;; b) x |-> e^x 를 미분한 결과는 그 자신과 같다.
;; 이를 표현하면 아래와 같다.
(define exp-series
  (cons-stream 1 (integrate-series exp-series)))


(stream-ref exp-series 0)
(stream-ref exp-series 1)
(stream-ref exp-series 2)
(stream-ref exp-series 3)
(stream-ref exp-series 4)
(stream-ref exp-series 5)

;; sin을 미분하면 cos
;; cos 을 미분하면 -sin
;; 을 바탕으로 사인과 코사인 수열 정의

;(define cosine-series
;  (cons-stream 1 <??>))
;(define sine-series
;  (cons-stream 0 <??>))

(define cosine-series
  (cons-stream 1 (integrate-series (scale-stream sine-series -1.))))

(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))

(stream-ref cosine-series 0)
(stream-ref cosine-series 1)
(stream-ref cosine-series 2)
(stream-ref cosine-series 3)
(stream-ref cosine-series 4)
(stream-ref cosine-series 5)

(stream-ref sine-series 0)
(stream-ref sine-series 1)
(stream-ref sine-series 2)
(stream-ref sine-series 3)
(stream-ref sine-series 4)
(stream-ref sine-series 5)


;;;--------------------------< ex 3.60 >--------------------------
;;; p434

;; ex3.59에서처럼 계수 스트림으로 나타낸 거듭제곱 수열을 가지고 
;;  add-streams를 써서 두 수열을 더하는 프로시저를 구현할 수 있다.
;; ??

;; 두 수열을 곱하는 프로시저

;; (define (mul-series s1 s2)
;;   (cons-stream (* (stream-car s1)
;; 		  (stream-car s2))
;; 	       (add-streams <??>
;; 			    <??>
;; )))


;; longfin 님 방법.
(define (mul-series s1 s2)
  (cons-stream
   (* (stream-car s1) (stream-car s2))
   (add-streams
    (mul-series (stream-cdr s1) s2)
    (scale-stream (stream-cdr s2) (stream-car s1)))))

(define expected
  (add-streams
   (mul-series sine-series sine-series)
   (mul-series cosine-series cosine-series)))

expected

(stream-ref expected 0)
(stream-ref expected 1)
(stream-ref expected 2)
(stream-ref expected 3)
(stream-ref expected 4)
(stream-ref expected 5)

(define ss (partial-sums expected))

 ss

(stream-ref ss 0)
(stream-ref ss 1)
(stream-ref ss 2)
(stream-ref ss 10)
;(display-stream ss)

;;;--------------------------< ex 3.61 >--------------------------
;;; p434

;; 상수항이 1인 거듭제곱 수열을 S
;; S*X = 1 이 되는 수열 X : 1/S 를 찾자.

;; S = 1 + Sr

;;      S * X = 1
;; (1+Sr) * X = 1
;; X + Sr * X = 1
;;          X = 1 - Sr*X

(define (invert-unit-series s)	
  (define s-inv
    (cons-stream 1
		 (scale-stream (mul-streams (stream-cdr s)
					    s-inv)
			       -1)))
  s-inv)

;; 상수항이 1, n차 계수가 n인 거듭제곱 수열 S
(define S integers)

(define X (invert-unit-series S))


(stream-ref X 0)
(stream-ref X 1)
(stream-ref X 2)
(stream-ref X 3)
(stream-ref X 4)
(stream-ref X 5)

(define SS (partial-sums S))

(stream-ref SS 10)

(define SX (partial-sums X))

(stream-ref SX 10)

(* (stream-ref SS 100)
   (stream-ref SX 100)
   1.0)
;; 1에 가까운 값을 기대했으나,,,,

;; 흠,,, 잘못 푼 듯...



;;;--------------------------< ex 3.62 >--------------------------
;;; p435
;연습문제 3.60과 3.61에서 얻은 결과를 써서 , 두 거듭제곱 수열을 나누는
;div-series 프로시저를 정의해 보라.
;연습문제 3.59에서 얻은 결과와 div-series 프로시저를 써서 , 탄젠트tangent를
;위한 거듭제곱 수열을 어떻게 만드는지 밝혀라.

(define (div-series s1 s2)
  (let ((c (stream-car s2)))
    (if (= c 0)
        (error "constant term of s2 can't be 0!")
        (scale-stream (mul-series s1
                                  (reciprocal-series (scale-stream s2 (/ 1 c))))
                      (/ 1 c)))))

(define tane-series (div-series sine-series cosine-series))



;;;==========================================
;;; 3.5.3 스트림 패러다임
;;; p435

;;; 셈미룸 계산법과 스트림 기법은 갇힌 상태와 덮어쓰기에서 얻을 수 있는 좋은 점을 제공

;;; 스트림 방식에서는 순간순간 변하는 상태가 아니라, 전체 시간의 흐름에 초점을 두고 생각할 수 있으며,
;;; 따라서 서로 다른 시점의 상태들을 한데 묶거나 서로 비교하기가 편하다.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 스트림 프로세스로 반복을 표현하는 방법
;;; p435

;;; 여러 변수 값을 바꾸는 방법에 기대지 않아도, 끝없이 펼쳐지는 스트림으로 상태를 나타낼 수 있다.

;;;---------------------------------
(define (display-stream-n s n)
  (define (iter c)
    (if (< c n)
	(begin
	  (display c)
	  (display ":")
	  (display (stream-ref s c))
	  (newline)
	  (iter (+ c 1)))
	(newline)))
  (iter 0))
;;;---------------------------------

;;;-----------------------------
;;; sqrt-stream
(define (average a b)
  (/ (+ a b) 2))

(define (sqrt-improve guess x)
  (average guess (/ x guess)))

(define (sqrt-stream x)
  (define guesses
    (cons-stream 1.0
		 (stream-map (lambda (guess)
			       (sqrt-improve guess x))
			     guesses)))
  guesses)

(define sq2 (sqrt-stream 2.0))

(stream-ref sq2 0)
(stream-ref sq2 1)
(stream-ref sq2 2)
(stream-ref sq2 3)
(stream-ref sq2 4)
(stream-ref sq2 5)
(stream-ref sq2 6)
;;;-----------------------------


;;;-----------------------------
;;; pi-stream
;먼저 덧셈으로 펼쳐진 수열의 (부호가 바뀌면서 나오는 홀수의 역수들로 이루어
;진) 스트렴부터 만든다. 그 다음에는 (연습문제 3.혔에서 만든 partial-sum 프로
;시저를 써서) 점점 더 많은 항(스트림 원소)을 합하는 스트림을 만들고, 다시 거
;기에 4를곱한다.
;; pi/4 = 1 - 1/3 + 1/5 - 1/7 + ....
(define (pi-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (pi-summands (+ n 2)))))

(define ps (pi-summands 1))

(display-stream-n ps 10)

(define pi-stream
  (scale-stream (partial-sums (pi-summands 1)) 4))

;; (display-stream pi-stream)
;; 4.0
;; 2.666666666666667
;; 3.466666666666667
;; 2.8952380952380956
;; 3.3396825396825403
;; 2.9760461760461765
;; 3.2837384837384844
;; 3.017071817071818
;; 3.2523659347188767



;;; 스트림 방식을 쓰면 같은 일을 하더라도 몇 가지 재밌는 재주를 부릴 수 있어서 좋다.
;;; - 차례열 가속기
;;;    : 어떤 값에 가까워지는 차례열을 훨씬 빠르게 다가가도록 바꾸어 줌.

;;; (오일러) 
;;; 부호가 번갈아 바뀌는 수열이 있을 때, 그 부분합을 나타내는 차례열과 잘 맞아떨어지는 가속기가 있다.
;;;                 (S_(n+1) - S_n)^2
;;; S_(n+1) -  --------------------------
;;;             S_(n-1) - 2S_n + S_(n+1)



;; 처음의 차례열 스트림 : s
;; 가속 변환한 차례열 :
(define (euler-transform s)
  (let ((s0 (stream-ref s 0))    ; S_(n-1)
	(s1 (stream-ref s 1))    ; S_n
	(s2 (stream-ref s 2)))   ; S_(n+1)
    (cons-stream (- s2 (/ (square (- s2 s1))
			  (+ s0 (* -2 s1) s2)))
		 (euler-transform (stream-cdr s)))))

(display-stream-n pi-stream 100)
;; (display-stream (euler-transform pi-stream))
;; 3.166666666666667
;; 3.1333333333333337
;; 3.1452380952380956
;; 3.13968253968254
;; 3.1427128427128435
;; 3.1408813408813416
;; 3.142071817071818
;; 3.1412548236077655
;; 3.1418396189294033
(display-stream-n (euler-transform pi-stream) 10)



;;; 가속한 차례열을 다시 가속하는 방법
;;; - 재귀하면서 가속하는 방법

;; S00 S01 S02 ....
;;     S10 S11 ....
;;         S20 S21 ...


;; s         : S00 S01 ....
;; tr(s)     : S10 S11 ....
;; tr(tr(s)) : S20 S21 ...
;; ...

(define (make-tableau transform s)
  (cons-stream s
	       (make-tableau transform
			     (transform s))))

;; 태블로의 행마다 첫 원소를 뽑아 차례열을 만들어 낸다.
(define (accelerated-sequence transform s)
  (stream-map stream-car
	      (make-tableau transform s)))

;; (display-stream (accelerated-sequence euler-transform
;; 				      pi-stream))
;; 4.0
;; 3.166666666666667
;; 3.142105263157895
;; 3.141599357319005
;; 3.1415927140337785
;; 3.1415926539752927
;; 3.1415926535911765
;; 3.141592653589778
;; 3.1415926535897953
;; 3.141592653589795
;; +nan.0
;; +nan.0

;이런 문제를 풀 때에는 스
;트림을 쓰는 편이 더 깔끔하고 편리할 수 있다. 왜냐하면, 계산에 필요한 모든 상
;태를 차례열이라는 한 가지 데이터 구조로 나타내고, 서로 다른 문제를 풀더라도
;한결같은 방법으로 차례열스트림 연산을 적용하여 처리할 수 있기 때문이다.

;;;--------------------------< ex 3.63 >--------------------------
;;; p440

;; guess 변수 없이 sqrt-stream 작성
;; 반복하는 계산이 많아져서 효율이 크게 떨어진다
;; - 왜?
;;  : 기존에는 stream의 다음 인덱스 원소를 계산할 때 만들어진 guess 으로부터 한 단계만 더 계산하면 된다.
;;  : 여기서는 다음 인덱스 원소를 계산할 때 (sqrt-stream x)로 재귀를 하면서 매번 처음부터 n번째까지를 계산해야 한다.
(define (sqrt-stream x)
  (cons-stream 1.0
	       (stream-map (lambda (guess)
			     (sqrt-improve guess x))
			   (sqrt-stream x))))


;; (define (sqrt-stream x)
;;   (define guesses
;;     (cons-stream 1.0
;; 		 (stream-map (lambda (guess)
;; 			       (sqrt-improve guess x))
;; 			     guesses)))
;;   guesses)


(define sq-of-2 (sqrt-stream 2))

(stream-ref sq-of-2 10)


;;;--------------------------< ex 3.64 >--------------------------
;;; p440

;;; 스트림과 수(허용 오차)를 인자로 받는 stream-limit 프로시저 정의
;; - 스트림을 훑어보다가 이어지는 두 원소를 뺀 절대값이 허용 오차보다 작은 경우를 찾아내면
;;   그 두 원소 중 두 번째 원소를 결과로 내놓는다.

(define (stream-limit s tolerance)
  (let ((d1 (stream-car s))
	(d2 (stream-car (stream-cdr s))))
    (if (< (abs (- d1 d2)) tolerance)
	d2
	(stream-limit (stream-cdr s) tolerance))))
	 

(define (new-sqrt x tolerance)
  (stream-limit (sqrt-stream x) tolerance))

(new-sqrt 2 0.01)
(new-sqrt 2 0.001)

;;;--------------------------< ex 3.65 >--------------------------
;;; p441

;; 2의 자연로그에 가까운 값에 다가드는 차례열 세 개
;; ln2 = 1 - 1/2 + 1/3 - 1/4 + ...

;;; 1) 그냥 stream
(define (ln2-summands n)
  (cons-stream (/ 1.0 n)
	       (stream-map - (ln2-summands (+ n 1)))))

(define ln2-stream
  (partial-sums (ln2-summands 1)))

;; (display-stream ln2-stream)

(stream-ref ln2-stream 0)
(stream-ref ln2-stream 1)
(stream-ref ln2-stream 2)
(stream-ref ln2-stream 3)
(stream-ref ln2-stream 4)
;; 1.0
;; > 0.5
;; > 0.8333333333333333
;; > 0.5833333333333333
;; > 0.7833333333333332

(stream-ref ln2-stream 10)
(stream-ref ln2-stream 100)


;;; 2) 오일러 기법 가속
(define ln2-stream-euler
  (euler-transform ln2-stream))

(stream-ref ln2-stream-euler 0)
(stream-ref ln2-stream-euler 1)
(stream-ref ln2-stream-euler 2)
(stream-ref ln2-stream-euler 3)
(stream-ref ln2-stream-euler 4)
;; 0.7
;; > 0.6904761904761905
;; > 0.6944444444444444
;; > 0.6924242424242424
;; > 0.6935897435897436

(stream-ref ln2-stream-euler 10)
(stream-ref ln2-stream-euler 100)



;;; 3) 태블로 사용
(define ln2-stream-accel 
  (accelerated-sequence euler-transform ln2-stream))


(stream-ref ln2-stream-accel 0)
(stream-ref ln2-stream-accel 1)
(stream-ref ln2-stream-accel 2)
(stream-ref ln2-stream-accel 3)
(stream-ref ln2-stream-accel 4)
;; 1.0
;; > 0.7
;; > 0.6932773109243697
;; > 0.6931488693329254
;; > 0.6931471960735491

(stream-ref ln2-stream-accel 10)
(stream-ref ln2-stream-accel 100)

  



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 쌍으로 이루어진 무한 스트림
;;; p441



;;; 차례열 패러다임을 스트림으로 확장..
;;; ch2.2.3 prime-sum-pairs (p161)
;;; 의 쓰임새를 늘여보자.

;;; int-pairs 스트림에서 pair의 합이 소수인 것 만 골라내기
;; (stream-filter (lambda (pair)
;; 		 (prime? (+ (car pair) (cadr pair))))
;; 	       int-pairs)


;;; 여기서 int-pairs를 만드는 방법을 알아보자

;; 두 스트림 
;; S = (S_i)
;; T = (T_j)
;; 가 있을 때

;; 네모 배열을 펴쳐내면 
;; ->
;; (S0, T0)  (S0, T1)  (S0, T2) ...
;; (S1, T0)  (S1, T1)  (S1, T2) ...
;; (S2, T0)  (S2, T1)  (S2, T2) ...
;; ...
;; 대각선과 그 위쪽에 있는 모든 쌍을 모아 스트림으로 뽑아내면 
;; ->
;; (S0, T0)  (S0, T1)  (S0, T2) ...
;;           (S1, T1)  (S1, T2) ...
;;                     (S2, T2) ...
;;                              ...
;; 세부분으로 나눠서 생각하면
;; ->
;;   (1)    |      (2)
;; (S0, T0) | (S0, T1)  (S0, T2) ...
;; ---------+-----------------------
;;          | (S1, T1)  (S1, T2) ...
;;          |           (S2, T2) ...
;;          |      (3)           ...

;; (i,j) ....
;; i<=j

;; (2)는 다음과 같이 뽑아낼 수 있다.
;; (stream-map (lambda (x) (list (stream-car s) x))
;; 	    (stream-cdr t))

;;; 따라서 (pairs s t)는
;; (define (pairs s t)
;;   (cons-stream
;;    (list (stream-car s) (stream-car t))              ; <- (1)
;;    (<combine-in-some-way>
;;     (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
;; 		(stream-cdr t))
;;     (pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)

;; 두 스트림을 엮어내는 방법 1)
;; (define (stream-append s1 s2)
;;   (if (stream-null? s1)
;;       s2
;;       (cons-stream (stream-car s1)
;; 		   (stream-append (stream-cdr s1) s2))))
;; - 무한 스트림은 이 방법식으로 처리할 수 없다.
;;   두 번째 스트림을 한데 묶기도 전에 
;;   첫 번째 스트림의 원소를 모두 가져올 수 있어야 하기 때문이다.

;; 문제 해결 방법
;;
(define (interleave s1 s2)
  (if (stream-null? s1)
      s2
      (cons-stream (stream-car s1)
		   (interleave s2 (stream-cdr s1)))))
;; 두 스트림에서 번갈아 원소를 꺼내 쓰기 때문에,
;; 첫 번째 스트림이 끝없이 펼쳐지더라도 
;; 결국에는 두 번째 스트림의 모든 원소가 결과 스트림 속에 들어간다고 믿을 수 있다.
;; (하지만 나타나는 순서는 다르다)

(define (pairs s t)
  (cons-stream
   (list (stream-car s) (stream-car t))              ; <- (1)
   (interleave
    (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
		(stream-cdr t))
    (pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)



;;;--------------------------< ex 3.66 >--------------------------
;;; p444

(pairs integers integers) 
;;; 스트림에 들어가는 쌍이 어떤 차례를 따르는지 설명해보라


(define int-pair-stream (pairs integers integers))

(display-stream-n int-pair-stream 13)

;; > (1 1)  ;1,1
;; > (1 2)  ;1,
;; > (2 2)       ;2,2
;; > (1 3)  ;1,                        
;; > (2 3)       ;2,                  
;; > (1 4)  ;1,                      
;; > (3 3)            ;3,3             
;; > (1 5)  ;1,                           
;; > (2 4)       ;2,                 
;; > (1 6)  ;1,                          
;; > (3 4)            ;3,               
;; > (1 7)  ;1,                         
;; > (2 5)       ;2,                       
;;          ;1,                         
;;                          ;4,4                     
;;          ;1,                       
;;               ;2                           
;;          ;1,                     
;;               ;3
;;          ;1


;;           합
;; > (1 1)  ;2
;; > (1 2)  ;3
;; > (2 2)       ;4
;; > (1 3)  ;4
;; > (2 3)       ;5
;; > (1 4)  ;5
;; > (3 3)             ;6
;; > (1 5)  ;6
;; > (2 4)       ;6
;; > (1 6)  ;7
;; > (3 4)             ;7
;; > (1 7)  ;8
;; > (2 5)       ;7
;;



; 1; (1 1)
; 2; (1 2)
; 3;         (2 2)
; 4; (1 3)
; 5;         (2 3)
; 6; (1 4) 
; 7;                (3 3)
; 8; (1 5)
; 9;         (2 4)
;10; (1 6)
;11;                (3 4)
;12; (1 7)
;13;         (2 5)
;14; (1 8)
;15;                       (4 4)
;16; (1 9)
;17;         (2 6)
;18; (1 10)
;19;                (3 5)
;20; (1 11)
;21;         (2 7)
;22; (1 12)
;23;                       (4 5)
;24; (1 13)
;25;         (2 8)
;26; (1 14)
;27;                (3 6)
;28; (1 15)
;29;         (2 9)
;30; (1 16)
;31;                               (5 5)
;32; (1 17)
;33;         (2 10)
;34; (1 18)
;35;                (3 7)
;36; (1 19)
;37;         (2 11)
;38; (1 20)
;39;                       (4 6)
;40; (1 21)
;41;         (2 12)
;42; (1 22)
;43;                (3 8)
;44; (1 23)
;45;         (2 13)
;46; (1 24)
;47;                               (5 6)


;;;--------------------------< ex 3.67 >--------------------------
;;; p445

;; (i <= j) 조건없이 모든 정수 쌍(i,j)의 스트림을 만들어내는 pairs

;;  (1) | (2)
;; -----+-----
;;  (4) |\ (3)
;;      |\

;; (S0, T0)  (S0, T1)  (S0, T2) ...
;; (S1, T0)  (S1, T1)  (S1, T2) ...
;; (S2, T0)  (S2, T1)  (S2, T2) ...

(define (all-pairs s t)
   (cons-stream
    (list (stream-car s) (stream-car t))              ; <- (1)

    (interleave
     (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
		 (stream-cdr t))

;;     (cons-stream
     (interleave 
      (stream-map (lambda (x) (list x (stream-car t)))   ; <- (4)
		  (stream-cdr s))

       (all-pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)
)

(define all-int-pair-stream (all-pairs integers integers))

(display-stream-n all-int-pair-stream 30)


;;;--------------------------< ex 3.68 >--------------------------
;;; p445

;;; 기존에 쌍의 스트림을 세 조각으로 나누어 붙임
;; (S0, T0)를 나머지와 분리하지 않고 통째로 쓰면...?


;; (define (pairs s t)
;;   (cons-stream
;;    (list (stream-car s) (stream-car t))              ; <- (1)
;;    (interleave
;;     (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
;; 		(stream-cdr t))
;;     (pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)


;; ;; ;; 문제의 코드
;; (define (pairs s t)
;;   (begin 
;;     (display (stream-car s))
;;     (newline)
;;   (interleave 
;;    (stream-map (lambda (x) (list (stream-car s) x))
;; 	       t)
;;    (pairs (stream-cdr s) (stream-cdr t))))
;; )					


(define int-pair-stream (pairs integers integers))

;; (stream-ref int-pair-stream 0)
;; (stream-ref int-pair-stream 1)
;; (stream-ref int-pair-stream 2)
;; 무한 루프

;; 스트림은 지연 평가를 한다.
;; 스트림의 지연 평가는 cons-stream 에 의해서 발생된다.
;; 여기서는 cons-stream으로 stream을 묶지 않았기 때문에
;; 평가를 지연하지 않는다.
;; 따라서 무한 스트림에 대해서 pair를 만드므로
;; 무한히 평가를 하게 된다.



;;;--------------------------< ex 3.69 >--------------------------
;;; p445
;무한 스트렴 S, T, U를 인자로 받아 (S_i, T_j, U_k) 스트렴을 찍어내는 triples 프
;로시저를 정의하여라.
;triples를 가지고 피타고라스의 성질을 만족하는 i^2 + j^2 = k^2를만족하는 세 정수들의 묶음
;(i,j, k)를 모두 담아내는 스트림을 만들어보라.
;; (stream-filter (lambda (pair)
;; 		 (prime? (+ (car pair) (cadr pair))))
;; 	       int-pairs)


(define (pairs s t)
  (cons-stream
   (list (stream-car s) (stream-car t))              ; <- (1)
   (interleave
    (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
		(stream-cdr t))
    (pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)

;; (define (triples s t u)
;;    (pairs s 
;; 	  (pairs t u)))

;; (1 (2 3))
;;  ^ ^^^^
;; (cons 1 '(2 3))
;; -> (1 2 3)

(define (triples s t u)
  (define t-pairs (pairs t u))

  (define (iter-triples s1 s2)
    (cons-stream 
     (cons (stream-car s1) (stream-car s2))      ;; <--- 1)

     (interleave
      (stream-map (lambda (x) (cons (stream-car s1) x))  ;; <-- (a b c)
		  (stream-cdr s2))                           ;; <--- 2)

      (iter-triples (stream-cdr s1) (stream-cdr s2)))))      ;; <---- 3_
  (iter-triples s t-pairs))

(define triple-stream (triples integers integers integers))

(display-stream-n triple-stream 10)



  
(define pytha-stream
  (stream-filter (lambda (x)
		   (let ((i (car x))
			 (j (cadr x))
			 (k (caddr x)))
		     (if (= (+ (square i) (square j))
			    (square k))
			 #t
			 #f)))
		 (triples integers
			  integers
			  integers)))


(stream-ref pytha-stream 0)
(stream-ref pytha-stream 1)
(stream-ref pytha-stream 2)
(stream-ref pytha-stream 3)
(stream-ref pytha-stream 4)
;; (stream-ref pytha-stream 5)
;; <- (12 5 13) 시간 많이 걸림




;;;--------------------------< ex 3.70 >--------------------------

;;; p445,6
(define (merge-weighted s1 s2 weight)
        (cond ((stream-null? s1) s2)
                  ((stream-null? s2) s1)
                  (else
                        (let ((cars1 (stream-car s1))
                                  (cars2 (stream-car s2)))
                          (cond ((< (weight cars1) (weight cars2))
                                 (cons-stream cars1 
                                                       (merge-weighted (stream-cdr s1) s2 weight)))
                            ((= (weight cars1) (weight cars2)) 
                                     (cons-stream cars1 
                                                            (merge-weighted (stream-cdr s1) s2 weight)))
                                (else (cons-stream cars2
                                                        (merge-weighted s1 (stream-cdr s2) weight))))))))

(define (weighted-pairs s1 s2 weight)
        (cons-stream (list (stream-car s1) (stream-car s2))
                        (merge-weighted (stream-map (lambda (x) (list (stream-car s1) x))
                                                                           (stream-cdr s2))
                                                 (weighted-pairs (stream-cdr s1) (stream-cdr s2) weight)
                                                                 weight)))
        

(define weight1 (lambda (x) (+ (car x) (cadr x))))
(define pairs1 (weighted-pairs integers integers weight1))
        
(define weight2 (lambda (x) (+ (* 2 (car x)) (* 3 (cadr x)) (* 5 (car x) (cadr x)))))   
(define (divide? x y) (= (remainder y x) 0))
(define stream235
        (stream-filter (lambda (x) (not (or (divide? 2 x) (divide? 3 x) (divide? 5 x))))
                                   integers))
(define pairs2 (weighted-pairs stream235 stream235 weight2))

;;;---------------------------------
(define (display-stream-n-weight s n weight)
  (define (iter c)
    (if (< c n)
	(begin
	  (display c)
	  (display ":")
	  (display (stream-ref s c))
	  (display ":")
	  (display (weight (stream-ref s c)))
	  (newline)
	  (iter (+ c 1)))
	(newline)))
  (iter 0))
;;;---------------------------------


;;; 두 스트림의 원소를 번갈아 끼워넣는 프로세스에서
;; 특별히 정한 차례를 따르기보다
;; 어떤 쓸모 있는 차례에 따라 원소를 늘어놓도록.
;; 무게함수를 정의
;; W(i,j) 

;; merge를 확장하여 merge-weighted 를 짜라
;; - 쌍의 무제를 재는 weight프로시저를 인자로 받을 수 있다.
;; - 무게는 같더라도 원래 쌍은 다를 수 있다는데에 주의!
(define (merge-weighted cmp-weight s1 s2)
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (cond ((cmp-weight s1car s2car)
		  (cons-stream s1car (merge-weighted cmp-weight (stream-cdr s1) s2)))
		 ((cmp-weight s2car s1car)
		  (cons-stream s2car (merge-weighted cmp-weight s1 (stream-cdr s2))))
		 (else
		  (if (cmp-pair s1car s2car)
		      (cons-stream s1car
				   (merge-weighted cmp-weight (stream-cdr s2) 
						   (stream-cdr s1)))
		      (cons-stream s1car
				   (cons-stream s2car
						(merge-weighted cmp-weight
								(stream-cdr s2)
								(stream-cdr s1)))))))))))
;; ;<- interleave를 위해서 else 부분의 merge시에 s2,s1 순서로 바꿈

(define (cmp-pair p1 p2)
  (let ((i1 (car p1))
	(j1 (cadr p1))
	(i2 (car p2))
	(j2 (cadr p2)))
    (and (= i1 i2) (= j1 j2))))



;;;;
(define (pairs s t)
  (cons-stream
   (list (stream-car s) (stream-car t))              ; <- (1)
   (interleave
    (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
		(stream-cdr t))
    (pairs (stream-cdr s) (stream-cdr t)))))         ; <- (3)
;;;;

;; pairs보다 쓰임새가 넓은 weighted-pairs 프로시저
(define (weighted-pairs cmp-weight s t)
  (cons-stream
   (list (stream-car s) (stream-car t))              ; <- (1)
   (merge-weighted
    cmp-weight
    (stream-map (lambda (x) (list (stream-car s) x)) ; <- (2)
		(stream-cdr t))
    (weighted-pairs cmp-weight (stream-cdr s) (stream-cdr t)))))         ; <- (3)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; a. i <= j  인 모든 양의 정수 쌍을 늘어놓는 스트림.
;;     쌍의 차례는 i+j 값에 따른다.

;; (define (weight-a pair1 pair2)
;;   (let ((i1 (car pair1))
;; 	(j1 (cadr pair1))
;; 	(i2 (car pair2))
;; 	(j2 (cadr pair2)))
;;     (let ((w1 (+ i1 j1))
;; 	  (w2 (+ i2 j2)))
;;       (if (< w1 w2)
;; 	  #t
;; 	  #f))))

;; (define a-pair-stream (weighted-pairs weight-a integers integers))
;; (display-stream-n a-pair-stream 13)

(define (weight-a pair1)
  (let ((i (car pair1))
	(j (cadr pair1)))
    (+ i j)))

(define (comp-weight weight pair1 pair2)
  (< (weight pair1) (weight pair2)))

;;;----------------------------
(define a-pair-stream (weighted-pairs (lambda (p1 p2)
					(comp-weight weight-a
						     p1 
						     p2))
					integers integers))

(display-stream-n-weight a-pair-stream 20 weight-a)
;;;----------------------------



;;; b. i<=j 인 모든 양의 정수 쌍 가운데 i,j 모두 2,3,5로 나누어떨어지지 않는 (i,j)들의 스트림
;;     차례는 2i+3j+5ij를 따른다.


;; (define (weight-b pair1 pair2)
;;   (let ((i1 (car pair1))
;; 	(j1 (cadr pair1))
;; 	(i2 (car pair2))
;; 	(j2 (cadr pair2)))
;;     (let ((w1 (+ (* 2 i1) (* 3 j1) (* 5 i1 j1)))
;; 	  (w2 (+ (* 2 i2) (* 3 j2) (* 5 i2 j2))))
;;       (if (< w1 w2)
;; 	  #t
;; 	  #f))))

;; (define b-pair-stream
;;   (stream-filter (lambda (x)
;; 		   (let ((i (car x))
;; 			 (j (cadr x)))
;; 		     (and (predicate-b i) (predicate-b j))))
;; 		 (weighted-pairs weight-b integers integers)))

;; (display-stream-n b-pair-stream 30)

(define (weight-b pair1)
  (let ((i (car pair1))
	(j (cadr pair1)))
    (+ (* 2 i) (* 3 j) (* 5 i j))))

(define (predicate-b x)
  (and (not (= (remainder x 2) 0))
       (not (= (remainder x 3) 0))
       (not (= (remainder x 5) 0))))

(define b-pair-stream
  (stream-filter (lambda (x)
		   (let ((i (car x))
			 (j (cadr x)))
		     (and (predicate-b i) (predicate-b j))))
		 (weighted-pairs (lambda (p1 p2)
				   (comp-weight weight-b
						p1 
						p2))
				 integers integers)))

;; (define b-pair-stream
;; 		 (weighted-pairs weight-b integers integers))

(display-stream-n-weight b-pair-stream 30 weight-b)
	    
;;;--------------------------< ex 3.71 >--------------------------
;;; p446

;; 라마누잔 수 
;; - 어떤 수가 두 수의 세제곱을 더한 값이라고 할 때 ( x = i^3 + j^3 )
;;   그렇게 셈할 수 있는 방법이 하나보다 많으면 그 수를 라마누잔 수라고 한다.

;; 스트림 패러다임 해법 :
;;  i^3 + j^3 으로 무게를 정의한 정수 쌍들의 스트림을 만들어 낸 다음
;;  이어진 두 쌍의 무게가 같은 것을 찾아내면 된다.

;; 라마누잔 수를 뽑아내는 프로시저를 만들어라.


(define (weight-ramanujan pair1)
  (let ((i (car pair1))
	(j (cadr pair1)))
    (+ (* i i i) (* j j j))))

;; 1) i^3 + j^3 값의 크기 순으로 나타나는 스트림을 만든다
(define s1 (weighted-pairs (lambda (p1 p2)
			     (comp-weight weight-ramanujan 
					  p1
					  p2))
			   integers integers))

(display-stream-n-weight s1 62 weight-ramanujan) 

;; 2) 이어진 두 쌍 (a b), (c d)의 무게가 같으면 그 무게는 라마누잔 수이다.
(define (merge-ramanujan s1 s2)
;;  (display (stream-car s1))
  (cond ((stream-null? s1) s2)
	((stream-null? s2) s1)
	(else
	 (let ((s1car (stream-car s1))
	       (s2car (stream-car s2)))
	   (if (= (weight-ramanujan s1car)
		  (weight-ramanujan s2car))   ; 라마누잔수 확인
	       (cons-stream (weight-ramanujan s1car)
			    (merge-ramanujan (stream-cdr s1) (stream-cdr s2)))
	       (merge-ramanujan (stream-cdr s1) (stream-cdr s2)))))))

;; 흠 맞게 한 것 같은데 답이 안나오네,,?
(define ramanujan-nums (merge-ramanujan s1 (stream-cdr s1)))

(display-stream-n ramanujan-nums 6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;solution
(define (Ramanujan s)
         (define (stream-cadr s) (stream-car (stream-cdr s)))
         (define (stream-cddr s) (stream-cdr (stream-cdr s)))
         (let ((scar (stream-car s))
                   (scadr (stream-cadr s)))
                (if (= (sum-triple scar) (sum-triple scadr)) 
                        (cons-stream (list (sum-triple scar) scar scadr)
                                                 (Ramanujan (stream-cddr s)))
                        (Ramanujan (stream-cdr s)))))
(define (triple x) (* x x x))
(define (sum-triple x) (+ (triple (car x)) (triple (cadr x))))
(define Ramanujan-numbers
        (Ramanujan (weighted-pairs integers integers sum-triple)))

;the next five numbers are:
;(4104 (2 16) (9 15))
;(13832 (2 24) (18 20))
;(20683 (10 27) (19 24))
;(32832 (4 32) (18 30))
;(39312 (2 34) (15 33))
;;;--------------------------< ex 3.72 >--------------------------
;;; p447
;연습문제 3. 71과 비슷하게, 세 가지 방법으로 두 수를 제곱하여 합한 값으로 나
;타낼 수 있는 모든 수의 스트렴을 만들어 보라. 단, 세 가지 방법이 무엇인지도
;보여줄수 있도록 하자.

(define (weight-sq pair1)
  (let ((i (car pair1))
	(j (cadr pair1)))
    (+ (* i i) (* j j))))

(define s1 (weighted-pairs (lambda (p1 p2)
			     (comp-weight weight-sq  ;<- weight 함수만 바뀜
					  p1
					  p2))
			   integers integers))

(define (merge-3sq s1 s2 s3)
  (let ((s1car (stream-car s1))
	(s2car (stream-car s2))
	(s3car (stream-car s3)))
    (if (and (= (weight-sq s1car)
		(weight-sq s2car))
	     (= (weight-sq s2car)
		(weight-sq s3car)))
	(cons-stream (cons s1car (weight-sq s1car))
		     (merge-3sq (stream-cdr s1) (stream-cdr s2) (stream-cdr s3)))
	(merge-3sq (stream-cdr s1) (stream-cdr s2) (stream-cdr s3)))))

(display-stream-n-weight s1 100 weight-sq) 

(define triple-sq-nums (merge-3sq s1 (stream-cdr s1) (stream-cdr (stream-cdr s1))))

(display-stream-n triple-sq-nums 4)





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 신호를 표현하는 스트림
;;; p447

;; 신호 처리 시스템의 '신호'를 컴퓨터 계산 방식으로 흉내낸 것이 스트림
;; - 연속하는 시간 간격의 신호 값들을 줄줄이 이어진 스트림의 원소로 나타냄.

;; 적분기의 구현
;; 덧셈기
;; S_i = C + SUM{j=1,i} X_j dt
(define (integral integrand initial-value dt)
  (define int
    (cons-stream initial-value
		 (add-streams (scale-stream integrand dt)
			      int)))
  int)


;;(define test-integral (integral integers 1 0.1))
(define test-integral (integral ones 1 0.1))

(display-stream-n test-integral 12)
;;; 해석,,,



;;;--------------------------< ex 3.73 >--------------------------
;;; p448 

;; RC 프로시저는 R,C,dt값을 받아서 그 결과로 프로시저를 내놓는다.
;; 나온 프로시저는 전류 스트림 i, 처음 전압 v0를 받아서 전압 스트림 v를 내놓는다.

(define (RC R C dt)
  (lambda (i v0)
    (define v
      (add-streams (scale-stream i R)
		  (integral (scale-stream i (/ 1 C))
			    v0
			    dt)))
    v))

(define RC1 (RC 5 1 0.5))

(define v1-s (RC1 ones 1.0))

(display-stream-n v1-s 30)


;;;--------------------------< ex 3.74 >--------------------------
;;; p449

;; 제로 크로싱
;; 음->양 : +1
;; 양->음 : -1
;; 해당없음 : 0

;; 센서에서 오는 신호 : sense-data 스트림
;; 제로-크로싱 스트림 : zero-crossings 스트림

(define (make-stream-from-list lst1)
  (cons-stream (if (null? lst1) '() (car lst1))
	       (make-stream-from-list (cdr lst1))))

(define sense-data (make-stream-from-list '(1 2 1.5 1 0.5 -0.1 -2 -3 -2 -0.5 0.2 3 4)))

(define (sign-change-detector cur last)
  (cond ((< last 0) (if (> cur 0) +1 0))
	((> last 0) (if (< cur 0) -1 0))
	(else 0)))

;;-----
;; Alyssa가 만든 것
(define (make-zero-crossings input-stream last-value)
  (cons-stream
   (sign-change-detector (stream-car input-stream) last-value)
   (make-zero-crossings (stream-cdr input-stream)
			(stream-car input-stream))))

(define zero-crossings (make-zero-crossings sense-data 0))

;;-----

(display-stream-n sense-data 13)

(display-stream-n zero-crossings 13)


;;; Eva의 조언
;; stream-map을 쓴다면
(define zero-crossings
  (stream-map sign-change-detector sense-data (stream-cdr sense-data)))
;;                                            ^^^^^^^^^^^^^^^^^^^^^^^

(display-stream-n zero-crossings 12)


;;;--------------------------< ex 3.75 >--------------------------
;;; p450

;; 문제점 : 잡음에 민감하다
;; 신호를 다듬는 과정을 거쳐서 잡신호 걸러내기(LPF)Low Pass Filter
;; 옛 값과 평균하여 만든 신호에서 제로 크로싱 신호를 뽑아내도록

;; Alyssa가 짜고 Louis가 고침
(define (make-zero-crossings input-stream last-value)
  (let ((avpt (/ (+ (stream-car input-stream) last-value) 2)))
    (cons-stream (sign-change-detector avpt last-value)
		 (make-zero-crossings (stream-cdr input-stream)
				      avpt))))


(define zero-crossings (make-zero-crossings sense-data 0))

(display-stream-n zero-crossings 12)

;; 구조는 그대로 두고 오류를 찾아서 바로 잡아라
;; 귀띔 : make-zero-crossings의 인자 수를 늘려야 한다.

(define (make-zero-crossings input-stream last-value last-avpt) 
         (let ((avpt (/ (+ (stream-car input-stream) last-value) 2))) 
                 (cons-stream (sign-change-detetor avpt last-avpt) 
                                        (make-zero-crossings (stream-cdr input-stream) 
                                                                            (stream-car input-stream) 
                                                                             avpt)))) 


;;;--------------------------< ex 3.76 >--------------------------
;;; p451
;Alyssa가 입 력 신호를 다듬는 더
;좋은 방법을 찾아내어 이를 적용하고 싶을 때, 제로 크로싱 프로시저를 고칠 필
;요가 없어야 바람직하다.
;Louis를 도와주기 위해 스트림 하나를 인자로 받아서
;그 연속하는 두 원소의 평균 값들을 스트림으로 찍는 smooth 프로시저를 만들
;어 보자. 그런 다음에 smooth를 가지고, 제로 크로싱 검출기가 모률 방식을 갖
;추도록고쳐 보자.

(define (smooth s)
  (scale-stream (add-streams s
			     (stream-cdr s))
		(/ 1 2)))

(display-stream-n sense-data 12)
(display-stream-n (smooth sense-data) 12)

;; 기존 ex 3.74 의 make-zero-crossings
(define (make-zero-crossings input-stream last-value)
  (cons-stream
   (sign-change-detector (stream-car input-stream) last-value)
   (make-zero-crossings (stream-cdr input-stream)
			(stream-car input-stream))))

(define o-zero-crossings (make-zero-crossings sense-data 0))
(define smoothed-zero-crossings (make-zero-crossings (smooth sense-data) 0))

(display-stream-n o-zero-crossings 12)
(display-stream-n smoothed-zero-crossings 12)




;;;==========================================
;;; 3.5.4 스트림과 셈미룸 계산법(stream and delayed evaluation)
;;; p451

;;;
;; 스트림을 이용한 프로시저로 신호처리방식을 정의할 때
;; 피드백 루프는 프로시저 속에서 스트림 자신을 불러쓰는 것으로 정의된다.
;; (define int
;;   (cons-stream initial-value
;; 	       (add-streams (scale-stream integrand dt)
;; 			    int)))
;; : int

;; <- 이와 같은 정의는 cons-stream 속에 있는 delay 연산 덕분이다.
;; 이 연산이 없다면 cons-stream 에 넘겨줄 인자 값을 구할 때
;; int의 정의부터 처리해야 하기 때문에 실행기는 int를 결코 만들어 내지 못한다.

;; delay가 없다면 피드백 루프를 표현할 수단이 없다.


;;;
;; 루프가 있는 시스템을 스트림으로 흉내내다 보면
;; cons-stream에 숨어있는 delay 연산 말고도 delay 연산을 따로 써야할 때가 있다.
(define (solve f y0 dt)
  (define y (integral dy y0 dt))
  (define dy (stream-map f y))
  y)
;; <- dy를 정의하기 전에 dy를 사용한다.




;;;
;; 사실 integral의 경우
;; 출력 스트림의 첫째 원소는 인자로 받아온 initial-value이다.
;; 따라서 dy를 구하지 않더라도 출력 스트림(y)의 첫째 원소를 정할 수 있다.
;; 일단 y의 첫 원소가 무엇인지 알수 있다면 문제없이 다음으로 진행할 수 있다.


;;;-------------------------------------------------------------------
;;;
;; 위 생각을 반영하여
;; 피적분 값들의 스트림이 셈미룬 인자가 되게끔 integral을 다시 정의해 보자.
(define (integral delayed-integrand initial-value dt)
  (define int
    (cons-stream initial-value
		 (let ((integrand (force delayed-integrand)))
		   (add-streams (scale-stream integrand dt)
				int))))
  int)


(define test-delayed-integral (integral (delay integers) 1 0.1))
;;                                      ^^^^^^^^^^^^^^^^		   

(display-stream-n test-delayed-integral 12)


;; dy/dt = f(y)
;; 이제 y의 정의에서 dy값 계산을 뒤로 미룸으로써 solve 프로시저의 구현을 마무리할 수 있다.
(define (solve f y0 dt)
  (define y (integral (delay dy) y0 dt))
  (define dy (stream-map f y))
  y)

(stream-ref (solve (lambda (y) y) 1 0.001) 1000)

;;;
;;;-------------------------------------------------------------------


;;;--------------------------< ex 3.77 >--------------------------
;;; p454

;;; 제시된 코드
;; (define (integral integrand initial-value dt)
;;   (cons-stream initial-value
;; 	       (if (stream-null? integrand)
;; 		   the-empty-stream
;; 		   (integral (stream-cdr integrand)
;; 			     (+ (* dt (stream-car integrand))
;; 				initial-value)
;; 			     dt))))
;이 프로시저를 가지고 루프가 있는 시스햄을 흉내내 보면, 처음 짠 integral과
;같은 문제가 생긴다. integrand를 셈미룬 인자가 되도록 만들어서 solve 프로
;시저에서 이 프로시저를쓸수 있도록고쳐 보라.

;;---------------
(define (integral delayed-integrand initial-value dt)
  (cons-stream initial-value
	       (let ((integrand (force delayed-integrand)))  ;; <- 지연된 인자 평가하기
		 (if (stream-null? integrand)
		     the-empty-stream
		     (integral (delay (stream-cdr integrand))  ;; <- 되돌기 인자 delay 시키기
			       (+ (* dt (stream-car integrand))
				  initial-value)
			       dt)))))

(define (solve f y0 dt)
  (define y (integral (delay dy) y0 dt))
  (define dy (stream-map f y))
  y)

(define res-int1 (solve (lambda (y) y) 1 0.001))

(display-stream-n res-int1 10)
(stream-ref res-int1 1000)

;;;--------------------------< ex 3.78 >--------------------------
;;; p455

;; d^2 y      dy
;; ----- - a*---- - by = 0
;; d t^2      dt
;상수 값a, b, dt와y의
;초기값 y。와 dy。, dy/dt를 인자로 받아, 연속하는 y 값들을 스트림으로 뽑아 낼
;수 있도록 solve-2nd 프로시 저를 정의하라.

(define (solve-2nd a b dy0 y0 dt)
  (define y (integral (delay dy) y0 dt))
  (define dy (integral (delay ddy) dy0 dt))
  (define ddy (add-streams (scale-stream dy a)
			   (scale-stream y b)))
  y)

(define res-int2 (solve-2nd 2 3 1 2 0.001))

(display-stream-n res-int2 10)
(stream-ref res-int2 1000)


;;;--------------------------< ex 3.79 >--------------------------
;;; p456
;연습문제 3.78의 solve-2nd 의 쓰임새를 늘려서 d^2y/dt^2 = f (dy/dt, y) 꼴의 2
;차미분방정식을 풀 수 있도록 만들어 보라.
;; d^2 y      dy
;; ----- = f(----, y)
;; d f^2      dt

 (define(general-solve-2nd f y0 dy0 dt) 
         (define y (integral (delay dy) y0 dt)) 
         (define dy (integral (delay ddy) dy0 dt)) 
         (define ddy (stream-map f dy y)) 
         y) 

;;;--------------------------< ex 3.80 >--------------------------
;;; p456


;; v_R = i_R * R
;;
;;            d i_L
;; v_L = L * -------
;;             d t
;;
;;            d v_C 
;; i_C = C * -------
;;             d t
;;
;; ->
;; i_R = i_L = -i_C
;; v_C = v_L + v_R
;;
;; ->
;; ;; 최종식
;;  d i_L       i_L
;; ------- = - -----
;;   d t         C 
;;
;;  d v_C     1         R
;; ------- = ---*v_C - ---*i_L
;;   d t      L         L
;RLC 프로시 저를 가지고 R=
; C = 0.2 farad, L = 1 henry, dt = 0.1 second, and initial values iL0 = 0 amps and vC0 = 10 volts 인 직
;렬 RLC 회로를 흉내내는 스트림 쌍을 뽑아내 보라

(define (RLC R L C dt)
  (lambda (v_C0 i_L0)
    (define v_C  (integral (delay dv_C) v_C0 dt))
    (define dv_C (scale-stream (delay i_L) (/ -1 C)))
    (define i_L  (integral (delay di_L) i_L0 dt))
    (define di_L (add-streams (scale-stream v_C (/ 1 L))
			      (scale-stream i_L (/ -R L))))
    (list v_C i_L))
)

 
;; (define RLC1 ((RLC 1 1 0.2 0.1) 10 0))
;; 에러
;; 뭔가 수정 필요

(define (RLC R L C dt) 
         (define (rcl vc0 il0) 
                 (define vc (integral (delay dvc) vc0  dt)) 
                 (define il (integral (delay dil) il0 dt)) 
                 (define dvc (scale-stream il (- (/ 1 C)))) 
                 (define dil (add-streams (scale-stream vc (/ 1 L)) 
                                                                 (scale-stream il (- (/ R L))))) 
                 (define (merge-stream s1 s2) 
                         (cons-stream (cons (stream-car s1) (stream-car s2)) 
                                                  (merge-stream (stream-cdr s1) (stream-cdr s2)))) 
                 (merge-stream vc il)) 
         rcl) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 정의대로 계산하기(normal-order evaluation)
;;; p458

;; 3.5.4에서는
;; delay와 force가 프로그램의 표현력을 얼마나 크게 끌어올릴 수 있는지 알아보았다.
;; 하지만, 프로그램 짜는 게 복잡해질 수 있다는 사실도 보았다.
;; - 피적분 인자 값의 계산을 미뤄야 한다는 점을 기억해야함.
;;   모든 프로시저가 그런 규칙을 반드시 따라야 함.

;;-> 두 가지 계산 방식을 가진 프로시저가 생기는 셈
;;   1. 보통 프로시저
;;   2. 셈미룸 인자를 받는 프로시저
;;-> 차수 높은 프로시저도 프로시저 종류마다 따로따로 만들어줄 수 밖에 없다.
;; 그러지 않으려면
;; 모든 프로시저가 인자 값 계산을 미루도록 하는 수밖에 없다.
;;-> 언어가 정의대로 계산법에 따라 식을 계산하도록 만들어야 한다.


;;;
;; 프로시저를 불러쓸 때 delay가 들어가면,
;; 덮어쓰기와 변형 가능한 데이터 
;; 또는 입출력을 처리하는 프로그램처럼
;; 사건이 일어나는 차례를 바탕으로 하는 프로그램을 설계할 때
;; 모든 것이 뒤죽박죽된다는 사실을 알아두어야 한다!!!

;;;
;; 변형 가능성과 셈미룸 계산법은 한 프로그래밍 언어 속에서 서로 잘 섞이지 않는다.
 











;;;==========================================
;;; 3.5.5 모듈로 바라본 함수와 물체
;;; p459




;;;--------------------------< ex 3.81 >--------------------------
;;; p461
 (define (random-update x) 
         (remainder (+ (* 13 x) 5) 24)) 
 (define random-init (random-update (expt 2 32))) 
  
;스트림 방식의
;마구잡이 수 만들개는 새 마구잡이 수를 뽑아내거나 마구잡이 수열을 지정된
;값으로 되돌려 달라는 부탁을 입력 스트림으로 받아서, 그 바람대로 마구잡이
;수 스트림을 뽑아낸다. 이 문제를 풀 때에는 덮어쓰기 연산을 쓰지 마라.

 (define (random-number-generator command-stream) 
         (define random-number 
                 (cons-stream random-init 
                                 (stream-map (lambda (number command)  
                                                                 (cond ((null? command) the-empty-stream) 
                                                                           ((eq? command 'generator) 
                                                                            (random-update number)) 
                                                                           ((and (pair? command)  
                                                                                    (eq? (car command) 'reset)) 
                                                                            (cdr command)) 
                                                                           (else  
                                                                              (error "bad command -- " commmand)))) 
                                                          random-number 
                                                          command-stream))) 
         random-number)

;;;--------------------------< ex 3.82 >--------------------------
;;; p461
;연습문제 3. 5의 몬테 카를로 적분 Monte Carlo integrdtion을 스트림 방식으로 다시 풀어
;보라. 스트림 판 estimate-integral 프로시저에는 실험 횟수를 받는 인자
;가 없다. 그 대신, 계속되는 실험에서 어림잡은값들의 스트림을 뽑아낼 수 있다.
 (define (random-in-range low high) 
         (let ((range (- high low))) 
                 (+ low (* (random) range)))) 
 (define (random-number-pairs low1 high1 low2 high2) 
         (cons-stream (cons (random-in-range low1 high1) (random-in-range low2 high2)) 
                                 (random-number-pairs low1 high1 low2 high2))) 
  
 (define (monte-carlo experiment-stream passed failed) 
         (define (next passed failed) 
                 (cons-stream (/ passed (+ passed failed)) 
                                          (monte-carlo (stream-cdr experiment-stream) 
                                                                   passed 
                                                                   failed))) 
         (if (stream-car experiment-stream) 
                 (next (+ passed 1) failed) 
                 (next passed (+ failed 1)))) 
  
 (define (estimate-integral p x1 x2 y1 y2) 
         (let ((area (* (- x2 x1) (- y2 y1))) 
               (randoms (random-number-pairs x1 x2 y1 y2))) 
                 (scale-stream (monte-carlo (stream-map p randoms) 0 0) area))) 
  
 ;; test. get the value of pi 
 (define (sum-of-square x y) (+ (* x x) (* y y))) 
 (define f (lambda (x) (not (> (sum-of-square (- (car x) 1) (- (cdr x) 1)) 1)))) 
 (define pi-stream (estimate-integral f 0 2 0 2)) 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 함수형 프로그래밍에서 시간의 문제
;;; p461

;상태가 있는 진짜 시스댐을 컴퓨터 프로그램으로 흉내내고자
;할 때 이를 모률 방식에 따라 잘 짜맞출 방법이 필요

;스트림이란, 시간에 따른 모든 상태 변회를 연속하는 값으로 나타
;내어 어떤 물체의 상태와 같이 자꾸 달라지는 양을 차례열로 흉내낸 것이다
;3. 1.3절에서 다음과 같이 간단한 인출 프로세서를 만든 바 있다.

(define (make-simplified-withdraw balance)
  (lambda (amount)
    (set! balance (- balance amount))
    balance))
    
;이 프로시저는 balance와 함께 찾을 돈(amount)의 스트림을 인자로 받아서
;남은 돈(balance)의 스트렴을 내놓는다.

(define (stream-withdraw balance amount-stream)
  (cons-stream
   balance
   (stream-withdraw (- balance (stream-car amount-stream))
                    (stream-cdr amount-stream))))
                    
;그 시스웹과 주고받는 행동transaction 하나하나를 따로
;살피지 않고, 시스템 전체를 balance들의 스트림으로 바라본다면, 그 사람의 눈
;에는 이 시스렘에 상태가 없는 것처럼 비칠 수 있다.
;->물리학에서도 이와 비슷하게 입자의 움직임을 살펴볼 때에는, 입자 위치(곧, 상태)가 변한다고 한다. 하지
;만, 시간과 공간으로 입자의 세계선(particle’s world line)을 바라보면, 아무런 변화가 없다.

;물체 상태는 상태변수로 흉내내고, 달라지눈 상태는 상태변수 값을 덮어쓰는 것으로 흉내낸다.
;그렇게 하여, 실세계의 시간을 컴퓨터의 실행 시간으로 흉내낼 수 있게 되고, 그
;에 따라 컴퓨터에서 ‘물체’를 가지게 되는 것이다

;컴퓨터 계산을 물체로 표현하는 방식modeling with objects, 즉 물체 방식이 효과가
;뛰어나면서도 받아들이기 쉬운 까닭은, 실제 사물이 서로 힘을 미치는 현상을 우
;리가 이해하는 방식과 잘 맞아떨어지기 때문이다. 하지만, 이 장에서 여러 번 살
;펴보았다시피 , 이 방식은 사건이 일어나는 차례에 제약을 건다거나 여러 프로세
;스의 동기를 맞춘다거나 하는 껄끄러운 문셋거리를 끌어들인다. 바로 이런 문셋
;거리를 피해갈 수 있어서 함수형 프로그래밍 언어functional program1ning language를
;만드는 일이 활기를 띠게 되었다.

;따라서 함수 방식 functional style 에 따라 이 문제를 풀기로 하였다면, 
;어쩔 수 없이 서로 다른 에이전트agents에서 들어오는 입력을 한데
;섞어야 하고 그 때문에 함수 방식을 지킴으로써 사라질 것이라 믿은 문제점들을
;다시 끌어들이제 된다
