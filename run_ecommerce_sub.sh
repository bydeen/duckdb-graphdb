#!/bin/bash

SF=$1
for i in {1..3}
do
    echo "=============== Task 3a ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task3a.sql" | tee -a results/Task3a_SF$SF

    echo "=============== Task 3b ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task3b.sql" | tee -a results/Task3b_SF$SF

    echo "=============== Task 5a ==============="
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task5a.sql" | tee -a results/Task5a_SF$SF
done
