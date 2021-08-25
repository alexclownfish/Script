#!/usr/bin/bash
file='/root/work/ip.txt'
while read -r i
do
    expect -f /root/work/test.exp root Apache1! $i
done < $file
