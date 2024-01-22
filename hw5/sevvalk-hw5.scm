(define get-operator (lambda (op-symbol)
(cond
    ((equal? op-symbol '+) +)
    ((equal? op-symbol '-) -)
    ((equal? op-symbol '*) *)
    ((equal? op-symbol '/) /)
    (else (error "s6-interpret: operator not implemented -->" op-symbol))
)))

(define define-stmt? (lambda (e)
    (cond
        ((and (list? e) (equal? (car e) 'define) (symbol? (cadr e)) (= (length e) 3)) #t)
        ((and (list? e) (equal? (car e) 'define) ) "error")
        (else #f)
    )))

(define if-stmt? (lambda (e)
(cond
    ((and (list? e) (equal? (car e) 'if) (= (length e) 4)) #t)
    ((and (list? e) (equal? (car e) 'if) (< (length e) 4) ) "error")
    ((and (list? e) (equal? (car e) 'if) (>  (length e) 4) ) "error")
    (else #f)
)))

(define check-let-statement-pairs (lambda (e)
    (cond
        ((null? e) #t)
        ((= (length (car e)) 2 ) (check-let-statement-pairs (cdr e)))
        (else #f)        
    )))

(define let-stmt? (lambda (e)
(cond
    ((and (list? e) (equal? (car e) 'let) (= (length e) 3) (list? (cadr e)) (check-let-statement-pairs (cadr e))) #t)
    ((and (list? e) (equal? (car e) 'let)) "error")
    (else #f)
)
))

(define lambda-stmt? (lambda (e)
(and (list? e) (equal? (car e) 'lambda) (= (length e) 3) (list? (cadr e)))
))
(define lambda-stmt-with-value? (lambda (e)
(if (lambda-stmt? (car e)) #t #f )
;(and (list? e) (equal? (car e) 'lambda) (= (length e) 3) (list? (cadr e)))
))
(define predefined-lambda-stmt? (lambda (e env)
  (and (symbol? (car e)) (lambda-stmt? (get-value (car e) env)))))

(define get-value (lambda (var env)
(cond
    ((null? env) var)
    ((equal? (caar env) var) (cdar env))
    (else (get-value var (cdr env)))
)))

(define get-value-check (lambda (var env)
(cond
    ((null? env) #t)
    ((equal? (caar env) var) #f )
    (else (get-value var (cdr env)))
)))


(define extend-env (lambda (var val old-env)  
 (cons (cons var val) old-env)))


(define repl (lambda (env)
(let* (
    (dummy1 (display "cs305> "))
    (expr (read))
    (new-env (if (define-stmt? expr) (extend-env (cadr expr) (hw5-expr (caddr expr) env ) env) env))
    (val (cond
    ((string? (define-stmt? expr)) "ERROR")
    ((define-stmt? expr) (cadr expr))
    ((not(list? expr)) (cond
    ((number? expr) expr)
    ((symbol? expr) (let ((variable (get-value expr env))) (cond
        ((lambda-stmt? variable) "[PROCEDURE]")
        ((if-stmt? variable) "[PROCEDURE]")
        ((let-stmt? variable) "[PROCEDURE]")
        ((eq? '+ variable) "[PROCEDURE]")
        ((eq? '- variable) "[PROCEDURE]")
        ((eq? '% variable) "[PROCEDURE]")
        ((eq? '* variable) "[PROCEDURE]")
        ((get-value-check expr env) "ERROR")
        (else (hw5-expr variable env))
    )))

    ))
    (else (hw5-expr expr env))))
    (dummy2 (display "cs305: "))
    (dummy3 (display val))
    (dummy4 (newline))
    (dummy4 (newline)))
(repl new-env))))

(define var-binding-list
(lambda (e env new-env-for-binding)
  (cond
    ((null? e) new-env-for-binding) 
    ((list? (car e))
     (var-binding-list (car e) env (var-binding-list (cdr e) env new-env-for-binding)))
    ((symbol? (car e)) 
     (extend-env (car e) (hw5-expr (cadr e) env ) new-env-for-binding))
    (else (var-binding-list (cdr e) env new-env-for-binding)))))

(define extend-env-list
(lambda (var val old-env)
  (cons (cons var val) old-env)))

(define formal-list (lambda (var expr env env-for-lambda)
    (cond
        ((null? var) env-for-lambda)   
        ((null? (cdr var)) (extend-env-list (car var) (hw5-expr (car expr) env ) env-for-lambda)) 
        (else (formal-list (cdr var) (cdr expr) env (extend-env-list (car var) (hw5-expr (car expr) env ) env-for-lambda)))
    )
))

(define lambda-val-part (lambda (e)
    (cadr e)
))
(define lambda-calculation-part (lambda (e)
    (caddr e)
))

(define recreate-lambda-stmt (lambda (e env)
    
     (cons (get-value (car e)env) (cdr e))
))
(define combine-env (lambda (envs)
    (apply append envs)
))

(define (valid-operator? op)
(or (equal? op '+)
    (equal? op '-)
    (equal? op '*)
    (equal? op '/)))

(define (valid-number? expr)
(or (number? expr)
    (symbol? expr)))

(define (valid-variable? expr)
(and (symbol? expr) (not (eq? expr '+) (eq? expr '-) (eq? expr '*) (eq? expr '/))))

(define (valid-expression? expr)
(cond
    ((number? expr) #t)
    ((symbol? expr) #t)
    ((pair? expr)
    (let ((operator (car expr))
            (operands (cdr expr)))
        (and (or (equal? operator '+)
            (equal? operator '-)
            (equal? operator '*)
            (equal? operator '/))
            (valid-operand-list? operands))))
    (else #f)))

(define (valid-operand-list? operands)
(cond
  ((null? operands) #t)
  (else (and (valid-expression? (car operands))
             (valid-operand-list? (cdr operands))))))


(define hw5-expr (lambda (e env )
(cond
   
    ((number? e) e)
    ((symbol? e) (get-value e env))
    ((not (list? e)) (error "s6-interpret: cannot evaluate -->" e))
    ((string? (if-stmt? e)) "ERROR")
    ((if-stmt? e) (if (< 0 (hw5-expr(cadr e) env )) (hw5-expr(caddr e) env ) (hw5-expr(cadddr e) env )))
    
    ((string? (let-stmt? e)) "ERROR")
    ((let-stmt? e) (hw5-expr(caddr e) (combine-env(list(var-binding-list(cadr e) env '()) env)) ))
    ((string? (lambda-stmt-with-value? e)) "ERROR")
    ((lambda-stmt-with-value? e) (hw5-expr(lambda-calculation-part (car e))(combine-env(list (formal-list (lambda-val-part (car e)) (cdr e) env '()) env))))
    ((lambda-stmt-with-value? e) (combine-env(list (formal-list (lambda-val-part (car e)) (cdr e) env '()) env)))
    ((lambda-stmt? e)  e)
    ((predefined-lambda-stmt? e env) (let ( (total (recreate-lambda-stmt e env))) 
    (hw5-expr(lambda-calculation-part (car total))(combine-env(list (formal-list (lambda-val-part (car total)) (cdr total) env '()) env)))))
    ((valid-expression? e) (let ((operands (map hw5-expr (cdr e) (make-list (length (cdr e)) env)))
    (operator (get-operator (car e))))
    (apply operator operands)))
    (else "ERROR")
)))

(define cs305-interpreter (lambda () (repl '())))