#!/bin/bash

for i in {1..3}
do
    echo "=============== Task 7a ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb healthcare.db -c ".read m2bench/healthcare/Task7a.sql" | tee -a results/Task7a

    echo "=============== Task 7b ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb healthcare.db -c ".read m2bench/healthcare/Task7b.sql" | tee -a results/Task7b
done
