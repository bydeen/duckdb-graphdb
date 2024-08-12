#!/bin/bash

for i in {1..5}
do
    echo "=============== Task 7 ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb healthcare.db -c ".read m2bench/healthcare/Task7.sql" | tee -a results/Task7
done
