#!/bin/bash
# Print Prime Numbers from 1 to 15
# Author: Raj
# Date: 27th
# Version: V1

for i in {2..15}  # start from 2 (1 is not prime)
do
    prime=1   # assume number is prime
    for ((j=2; j<i; j++))
    do
        if (( i % j == 0 )); then
            prime=0   # not prime
            break
        fi
    done

    if (( prime == 1 )); then
        echo "$i"
    fi
done