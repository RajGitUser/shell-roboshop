#!/bin/bash
# To print Prime Numbers
# Author is Raj
# Date-27th
# Version = V1

for i in {1..15}
do

    if [ `expr $i % 1` == $i ]; then 
	echo "$i"

    fi

done