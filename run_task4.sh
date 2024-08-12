#!/bin/bash

SF=$1
for i in {1..3}
do
    echo "=============== Task 4a ==============="
    rm ecommerce$SF.db.wal; make
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task4a.sql" | tee -a results/Task4a_SF$SF

    echo "=============== Task 4b ==============="
    rm ecommerce$SF.db.wal; make
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task4b.sql" | tee -a results/Task4b_SF$SF
done
