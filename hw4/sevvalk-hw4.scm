
(define twoOperatorCalculator
    (lambda (listOfExpressions)
       (if (number? (car listOfExpressions) ) (let (
        (firstNum (car listOfExpressions))
        )
        (cond
        ((if(null? (cdr listOfExpressions)) firstNum 
        (cond 
        ((eq? '+ (cadr listOfExpressions)) (  + firstNum (twoOperatorCalculator (cddr listOfExpressions )) )) 
        ((eq? '- (cadr listOfExpressions)) ( if(null? (cdddr listOfExpressions )) (+ firstNum (* -1 (caddr listOfExpressions))) 
            (+ ( + firstNum (* -1 (caddr listOfExpressions )) )(twoOperatorCalculator (cdddr listOfExpressions )))  )) 
        )
        
        ) )
        )) 
        (if (eq? '+ (car listOfExpressions)) (+ 0 (twoOperatorCalculator (cdr listOfExpressions )) ) 
        ( if(null? (cddr listOfExpressions )) (+ 0 (* -1 (cadr listOfExpressions))) 
        (+ ( + 0 (* -1 (cadr listOfExpressions )) )(twoOperatorCalculator (cddr listOfExpressions )))  ))
    ) 
    )
)

(define fourOperatorCalculator
    (lambda (expressionList)
        (if (null? (cdr expressionList)) expressionList 
        (cond
        ((number? (car expressionList))(cond
            ((eq? '+ (cadr expressionList)) (cons (car expressionList) (fourOperatorCalculator ( cdr expressionList))))
            ((eq? '- (cadr expressionList)) (cons (car expressionList) (fourOperatorCalculator ( cdr expressionList))))
            ((eq? '* (cadr expressionList)) (cond 
                ((null? (cdddr expressionList)) (list(* (car expressionList) (caddr expressionList))))
                ((fourOperatorCalculator(cons (* (car expressionList) (caddr expressionList)) (cdddr expressionList))))
            ) )
            ((eq? '/ (cadr expressionList)) (cond 
            ((null? (cdddr expressionList)) (list(/ (car expressionList) (caddr expressionList))))
            ((fourOperatorCalculator(cons (/ (car expressionList) (caddr expressionList)) (cdddr expressionList))))
            ) )
        ))
        ((eq? '+ (car expressionList)) (cons (car expressionList) (fourOperatorCalculator ( cdr expressionList)) ))
        ((eq? '- (car expressionList)) (cons (car expressionList) (fourOperatorCalculator ( cdr expressionList)) ))
        
        
        ))
    )
)

(define calculatorNested
    (lambda (listsOfList)
    (cond
    ((list? (car listsOfList)) (if (null? (cdr listsOfList) ) (cons  (twoOperatorCalculator (fourOperatorCalculator (calculatorNested(car listsOfList)))) '())
    (calculatorNested (cons  (twoOperatorCalculator (fourOperatorCalculator (calculatorNested(car listsOfList)))) (cdr listsOfList)))
     ) )
    ((number? (car listsOfList)) (cond 
        ((null? (cdr listsOfList))listsOfList)
        ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    ((eq? '+ (car listsOfList)) (cond 
    ((null? (cdr listsOfList))listsOfList)
    ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    ((eq? '+ (car listsOfList)) (cond 
    ((null? (cdr listsOfList))listsOfList)
    ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    ((eq? '- (car listsOfList)) (cond 
    ((null? (cdr listsOfList))listsOfList)
    ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    ((eq? '* (car listsOfList)) (cond 
    ((null? (cdr listsOfList))listsOfList)
    ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    ((eq? '/ (car listsOfList)) (cond 
    ((null? (cdr listsOfList))listsOfList)
    ((cons (car listsOfList) (calculatorNested(cdr listsOfList))))
    ))
    )
)
)

(define checkOperators
    (lambda (operatorList)
    (if (list? operatorList) 
    (cond
    ((list? (car operatorList)) (cond 
    ((null? (cdr operatorList)) (checkOperators (car operatorList)))
    ((number? (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))
    ((number? (car operatorList)) (cond 
    ((null? (cdr operatorList)) #t)
    ((number? (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))
    ((eq? '+ (car operatorList)) (cond 
    ((null? (cdr operatorList)) #f)
    ((eq? '+ (cadr operatorList)) #f)
    ((eq? '- (cadr operatorList)) #f)
    ((eq? '* (cadr operatorList)) #f)
    ((eq? '/ (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))

    ((eq? '- (car operatorList)) (cond 
    ((null? (cdr operatorList)) #f)
    ((eq? '+ (cadr operatorList)) #f)
    ((eq? '- (cadr operatorList)) #f)
    ((eq? '* (cadr operatorList)) #f)
    ((eq? '/ (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))

    ((eq? '* (car operatorList)) (cond 
    ((null? (cdr operatorList)) #f)
    ((eq? '+ (cadr operatorList)) #f)
    ((eq? '- (cadr operatorList)) #f)
    ((eq? '* (cadr operatorList)) #f)
    ((eq? '/ (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))

    ((eq? '/ (car operatorList)) (cond 
    ((null? (cdr operatorList)) #f)
    ((eq? '+ (cadr operatorList)) #f)
    ((eq? '- (cadr operatorList)) #f)
    ((eq? '* (cadr operatorList)) #f)
    ((eq? '/ (cadr operatorList)) #f)
    (else ( if(eq? #t (checkOperators(cdr operatorList))) #t #f) )
    ))
    (else #f)
    
    ) #f ) 
)
)

(define calculator
    (lambda (expression)
    (if (boolean? (checkOperators expression)) (if (eq? #t (checkOperators expression)) (twoOperatorCalculator(fourOperatorCalculator(calculatorNested expression) )) #f)
    )
)
)
