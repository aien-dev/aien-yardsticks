# HISTORICAL — NOT PART OF ACTIVE AIEN EXECUTION

The nine Python files listed below are retained, byte for byte, as frozen historical evidence of two outside yardsticks (a Modular MAX Nemotron-H KV-head-expansion adapter and a TinyLlama reference-oracle generator). They are not part of any active AIEN build, qualification run, CI workflow, or runtime.

## Decision

Operator decision, Drake, 2026-10-09 (recorded against aien-dev/aien-yardsticks#2 and aien-dev/aien-architecture#12): Option 1 approved. Preserve legacy Python qualification scripts and yardstick experiments as frozen historical evidence. This does not relax the prohibition on Python in AIEN's active runtime or trusted tooling.

1. The retained files are marked HISTORICAL — NOT PART OF ACTIVE AIEN EXECUTION (this file).
2. Original source bytes, receipts, hashes, and historical test outcomes are preserved. No `.py` file is modified by this marking.
3. No production entry point, active build, CI qualification workflow, or current runtime depends on these files, with no known exception since 2026-10-10 (the former cockpit exception is described below under "Known operational reference" as resolved).
4. Historical evidence is not altered to conform to today's standards. The older notes in the READMEs ("scheduled for replacement by Rust") are kept as written; they are superseded by this decision.
5. Scoped claim: the enforceable claim is that AIEN's **active trusted execution path** is Python-free. This repository is **not** claimed to be Python-free.
6. Reactivating, replacing, or requalifying any of these files (including the Rust replacement proposed in aien-yardsticks#2) needs a separate task and new evidence. No Rust rewrite and no deletion is made or implied here.

## File table

All hashes are of the files at repository commit `765eec0` (default branch `main`). Paths below are relative to the repository root.

| Path | SHA-256 | Git blob | What it was for | Result / receipt it backs |
|---|---|---|---|---|
| `yardsticks/modular-nemotron-h-kvexp/__init__.py` | `05952e288c9d9b30c6a56ed305dc176a88b90abe3f85a6a83d3c5b6c79d5c041` | `f0b4617a99344bf2940f40af205715ba09f13005` | Exports the KV-head-expanded Nemotron-H adapter for MAX | No receipt. Served model `atlas-lightning-omni` (see operational reference) |
| `yardsticks/modular-nemotron-h-kvexp/arch.py` | `847e83099dde0bd3423b395b0ad2b440ea02d1caeaa527cc0b25e72e22c9d9a3` | `4e012b6db809edf1a966136c9636b610955c82c1` | Registers the expanded architecture with MAX | No receipt |
| `yardsticks/modular-nemotron-h-kvexp/config.py` | `2bc8afa5bbae928563d510999b4ec63d5ab2dd5b671a9d10da165aa9fe4f7005` | `5145eaa9289d08bc0b79233e3061e5545ed5d2a5` | Config subclass expanding KV heads so MAX's GQA kernel accepts Nemotron-H | No receipt |
| `yardsticks/modular-nemotron-h-kvexp/model.py` | `ca7169425190fde42fd3a65d2a794f8d711cc1276cb6eb536588d9cd96445373` | `4c5fcc39f71e84f8eac1be93c19d5ee2f63c4582` | Pipeline model subclass using the expanded config | No receipt |
| `yardsticks/modular-nemotron-h-kvexp/weight_adapters.py` | `73a424cee22eac1458f799bba5d2aaa3d921ce21a6e5685dc9af4847540a6e1e` | `cd8a20ce975f2aa89981b5fda5d5efc274c9fdd3` | State-dict conversion, optional PEFT LoRA fold, KV-head replication | No receipt |
| `yardsticks/modular-nemotron-h-kvexp/benchmarks/bench_kv_expansion.py` | `fa48b860a8327db08d310287481d95ead0a497ddbc96cb98cb2ec52cf7008dc0` | `2909c2a019caa4aaecf9f04495658e3130c63cfd` | Times KV-head replication latency and memory throughput on ARM64 | Recorded whisper in `yardsticks/modular-nemotron-h-kvexp/benchmarks/.crumb` (id `bench-results`, 2026-09-18): 5.49 ms per layer, 285.63 ms for the 52-layer model, 12.80 GB/s. No separate receipt file |
| `yardsticks/modular-nemotron-h-kvexp/tests/__init__.py` | `4544a6f2ce7fa2405a38963e240afcec63c75b0a7a920a82e1a7b663d5a7e4d7` | `59d9449d9a4bb8435274df5f9ae72e5c84f898c9` | Test package marker | See `test_kvexp.py` |
| `yardsticks/modular-nemotron-h-kvexp/tests/test_kvexp.py` | `b81573141728bc381886982770171936be9e40ee83b31f511d87bef673de6a2d` | `589b292a6e03c9792a3f3788e9078e1f3ea400f1` | Unit tests for expansion factor, LoRA delta, bfloat16 round trip, tensor replication | Recorded whisper in `yardsticks/modular-nemotron-h-kvexp/tests/.crumb` (id `test-suite-pass`, 2026-09-18): 100% pass across 7 unit tests. No separate receipt file |
| `yardsticks/tinyllama-oracle/generate_tinyllama_oracle.py` | `6247aa9d4bded40fa8756be278eec3c043ec6e65c506ccbc1f579807ae006b0d` | `0c879e5b1486c276b2ef9e627835198ee54b0fde` | Generated the TinyLlama-1.1B-Chat FP32 CPU reference answers (activations, logits, greedy sequences) | Fixture `tinyllama_oracle.safetensors` and `tinyllama_oracle_manifest.json` (SHA-256 manifest) held in aien-dev/aien-sovereign-core `crates/aien-inference-abi/fixtures/`; candidate gates in aien-dev/aien-sovereign-core `docs/release/ORACLE-FIXTURE-CAND4.md` and aien-dev/aien-architecture `qualification/candidates/CAND-4.gates.md`. The script here is a plain copy from sovereign-core commit `8b5caed` |

Other tracked files that mention Python and are left as written: `yardsticks/modular-nemotron-h-kvexp/pyproject.toml`, the two yardstick READMEs. The CUDA yardstick (`yardsticks/prime-drag-race-cuda/`) has no Python.

## Known operational reference (disclosed, not hidden)

Resolved 2026-10-10: aien-sovereign-core#371 (main 885e42f, closes sc#369) removed the launcher script and made the cockpit refuse to start or restart `max-server`; the cockpit only observes or stops an instance started by hand outside AIEN. The paragraph below is kept as the historical description of the former wiring.

`scripts/start_max_lightning_18006.sh` in aien-dev/aien-sovereign-core (and the home-directory copy that `crates/spark-cockpit-rs` launches on a "start"/"restart" of `max-server`) starts the outside Modular MAX server with `--custom-architectures .../aien-yardsticks/yardsticks/modular-nemotron-h-kvexp`. That loads this adapter's Python inside MAX, an outside yardstick server, not an AIEN-built component. This marking does not change that script. Whether the MAX launch is inside the "active trusted execution path" is an operator question and is reported separately.

## Rust replacement

aien-yardsticks#2 proposes a Rust replacement. It is not done here. If it goes ahead it is a separate task with new evidence (item 6).
