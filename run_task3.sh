#!/bin/bash

SF=$1
for i in {1..3}
do
    echo "=============== Task 3 ==============="
    rm ecommerce$SF.db.wal; make
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    time ./build/release/duckdb ecommerce$SF.db -c ".read m2bench/ecommerce/Task3.sql" | tee -a results/Task3_SF$SF
done
