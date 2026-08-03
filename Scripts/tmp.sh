sqr () {
    echo $(($1*$1))
}

pow2 () {
    if [ $1 -eq 0 ]; then
        echo 1
    else if [ $1 -eq 1 ]; then
        echo 2
    else 
        qot=$(($1/2))
        rem=$(($1%2))
        S=$(sqr $(pow2 $qot))
        R=$(pow2 $rem)
        echo $((S*R))
    fi fi
}

pow2m1 () {
    res=$(pow2 $1)
    echo $((res-1)) 
}
