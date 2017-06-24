: fib dup 2 < if exit else 1 - dup fib swap 1 - fib + then ; \ (x --- x1) Returns fibonacci number x
: fib-test begin dup dup fib swap . 32 emit . cr inc<? until ; \ (a b --- ) Prints fibonacci numbers from b to a (assuming b <= a )

: ascii 32 126 for do i ? i @ 100 < if 32 emit then 58 emit 32 emit i @ emit cr done ; \ (---) Prints visible ASCII chars with corresponding codes

variable linijka
: cat begin dup linijka swap read-line nip dup if linijka .type cr then not until close-file ; \ (handle --- ) Prints contents of file determined by handle

variable wiktor
6 wiktor !
87 wiktor 1 + !
105 wiktor 2 + !
107 wiktor 3 + !
116 wiktor 4 + !
111 wiktor 5 + !
114 wiktor 6 + !

: compare dup2 @ swap @ = \ (addr1 addr2 --- x) Compares 2 strings at given adresses
    if
        dup @ 1 swap for do
            -rot dup2 i @ + @ swap i @ + @ <> if drop drop2 0 exit then rot
        done drop2 1
    else drop2 0 then ;

: find-word \ (addr u --- u) 
    swap dup @ \ (u addr len)
    -rot \ (len u addr)
    over + begin \ (len u addr+u)
        1 + swap 1 + swap
        dup @ 32 = >r
        -rot dup2 \ (addr+u len u len u)
        < r> or >r rot r> \ (len u addr+u)
    until drop nip 1 - ;