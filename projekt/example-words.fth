: fib dup 2 < if exit else 1 - dup fib swap 1 - fib + then ; \ (x --- x1) Returns fibonacci number x
: fib-test begin dup dup fib swap . 32 emit . cr inc<? until ; \ (a b --- ) Prints fibonacci numbers from b to a (assuming b <= a )

: ascii 126 32 do i ? i @ 100 < if 32 emit then 58 emit 32 emit i @ emit cr done ;

