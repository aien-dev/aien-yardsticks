# TinyLlama oracle (yardstick)

Generates the reference answers from TinyLlama-1.1B-Chat-v1.0 (CPU, FP32, Hugging Face Transformers) that AIEN's own numbers are compared against: activations, logits and greedy generation sequences, written to `tinyllama_oracle.safetensors` plus a JSON manifest with SHA-256 hashes.

This is a yardstick, not part of AIEN. It is Python and is scheduled to be replaced by Rust (see aien-dev/aien-yardsticks issue #2).

Moved from aien-dev/aien-sovereign-core `scripts/generate_tinyllama_oracle.py` at commit 8b5caedcba164997bc49a35993282a099a80e452 (plain copy; history stays in that repo).
Note: the script pins a local Hugging Face snapshot path on the Spark (`PINNED_SNAPSHOT`).
