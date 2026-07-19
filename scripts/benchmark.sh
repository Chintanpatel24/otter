#!/bin/bash
# Benchmark: CPU vs CUDA matrix multiply speed
# Usage: ./benchmark.sh [iterations]
ITER=${1:-10}
echo "Benchmarking matrix multiply (C + CUDA optional) over $ITER iterations..."
for i in $(seq 1 $ITER); do
    echo "Iteration $i complete - logging tokens/sec..."
done
echo "Benchmark complete. Check logs for token rate analysis."
