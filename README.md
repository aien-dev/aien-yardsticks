# aien-yardsticks

Outside yardsticks AIEN is measured against (MAX, llama.cpp, vLLM). Never part of AIEN. Nothing here ships in AIEN.

| Yardstick | Path |
|---|---|
| Modular MAX, Nemotron-H KV-head expansion | `yardsticks/modular-nemotron-h-kvexp/` |
| TinyLlama reference oracle (HF Transformers, CPU FP32) | `yardsticks/tinyllama-oracle/` |
| CUDA mirror of the AIEN native prime sieve kernel (Prime Drag Race) | `yardsticks/prime-drag-race-cuda/` |

Python is tolerated here only until it is replaced by Rust.

> Superseded 2026-10-09: the Python here is retained as frozen historical evidence, not part of active AIEN execution, and is not scheduled for deletion. See [`HISTORICAL-PYTHON.md`](HISTORICAL-PYTHON.md).
