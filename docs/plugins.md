# Plugin System

```mermaid
graph LR
    A[Plugins Directory] -->|Scan| B[Plugin Registry]
    B -->|Register| C[Engine Core]
    C -->|Extend| D[New Model Handler]
    D -->|Apply| E[Multi-Model Index]
```
