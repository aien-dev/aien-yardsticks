# aien-yardsticks

Outside yardsticks AIEN is measured against. Today this repo holds a Modular MAX adapter, a Hugging Face Transformers reference oracle and a CUDA mirror of an AIEN kernel. There is no llama.cpp or vLLM yardstick here. Never part of AIEN. Nothing here ships in AIEN.

| Yardstick | Path |
|---|---|
| Modular MAX, Nemotron-H KV-head expansion | `yardsticks/modular-nemotron-h-kvexp/` |
| TinyLlama reference oracle (HF Transformers, CPU FP32) | `yardsticks/tinyllama-oracle/` |
| CUDA mirror of the AIEN native prime sieve kernel (Prime Drag Race) | `yardsticks/prime-drag-race-cuda/` |

The Python here is retained as frozen historical evidence, not part of active AIEN execution, and is not scheduled for deletion. No Rust replacement has been built or is scheduled (the proposal, aien-yardsticks issue #2, was closed on 2026-10-09 in favour of keeping the Python as historical evidence). See [`HISTORICAL-PYTHON.md`](HISTORICAL-PYTHON.md).
