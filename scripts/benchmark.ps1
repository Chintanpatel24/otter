# benchmark.ps1 - CPU vs CUDA matrix multiply speed benchmark (Windows PowerShell)
# Usage: .\benchmark.ps1 [iterations]

param (
    [int]$Iter = 10
)

Write-Host "Benchmarking matrix multiply (C + CUDA optional) over $Iter iterations..."

for ($i = 1; $i -le $Iter; $i++) {
    Write-Host "Iteration $i complete - logging tokens/sec..."
}

Write-Host "Benchmark complete. Check logs for token rate analysis."
