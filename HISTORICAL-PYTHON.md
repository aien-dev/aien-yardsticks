# HISTORICAL — NOT PART OF ACTIVE AIEN EXECUTION

The Python files listed below (nine marked on 2026-10-09, eleven added on 2026-10-15) are retained, byte for byte, as frozen historical evidence of outside yardsticks (a Modular MAX Nemotron-H KV-head-expansion adapter, a TinyLlama reference-oracle generator and the MojoLlama accuracy eval runners). They are not part of any active AIEN build, qualification run, CI workflow, or runtime.

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

## Added 2026-10-15: MojoLlama eval runners

On 2026-10-15 AIEN dropped Mojo and MAX and aien-dev/MojoLlama was archived. Its accuracy eval runners are plain standard-library Python with no Mojo or MAX imports, so they were copied here byte for byte from `src/mojollama/eval/` at MojoLlama commit `cb281d1e8d906d5cf616c3116ef3d43eab29d6ba`. They are held under the same terms as the files above: historical evidence, not part of active AIEN execution, and reactivating them needs a separate task.

| Path | SHA-256 | Git blob |
|---|---|---|
| `yardsticks/mojollama-eval-runners/eval/arc.py` | `e95e9664f750c313a3593947d288cdd3787f17ed215cd37ce87b8e0c12230865` | `97d0af16286b16cc473d7d474d0921fd41ed2a57` |
| `yardsticks/mojollama-eval-runners/eval/base.py` | `31a710e7c4307d5bec7df2a0e6643c31f8a460473357ecaac236beb17de104be` | `b08579e6cb4e4d8b129d9c50588916039b5fee96` |
| `yardsticks/mojollama-eval-runners/eval/bbh.py` | `f477e4e56bae6523b83cb41a514460b277efef22032c9c3b138bd14060bcfffb` | `b8093275167ef807a49dfc5e40bd45053d12b619` |
| `yardsticks/mojollama-eval-runners/eval/ceval.py` | `38c1fac7f3e768b739329c48fb89f5c71e67b00e4f6013a9487510652af4473d` | `dbf4cd338b04858c47020c5bfe4c27c5f08bffd6` |
| `yardsticks/mojollama-eval-runners/eval/dataset.py` | `fbca09a9b8f5019d185474894962ec8eafd181ac96b3973410bfd21820e0d1fc` | `28d1270d880ee3a041f549035388d8ad03de0230` |
| `yardsticks/mojollama-eval-runners/eval/gsm8k.py` | `904a0314d3afc72277ecfb3a9ecf1b2615b6a212281ab174cef1621fc3fba9b2` | `f8bea4f89eb55224273c607e027410dc4a49007f` |
| `yardsticks/mojollama-eval-runners/eval/hellaswag.py` | `97672bd091a7a3070a2f77e0fe08c0365dfdf633f2dd795dabe5b6ba1afbef40` | `d01e1bce542903ad74ab2cfbc360049374dafe8c` |
| `yardsticks/mojollama-eval-runners/eval/humaneval.py` | `5cb5be00798595782fc0a814c1c318c52e1c53ed017c9e816dc429bd8251b8ed` | `d4f81ba45e8a7106ea62157aaa30bfd6d04cf3ad` |
| `yardsticks/mojollama-eval-runners/eval/__init__.py` | `358906e04b113df64ff8e25bda8de365d71342b0ad3678fcf788d2e3ccbcf81a` | `8b98a3414bf60c87e224c6aa6731d0f4e0cde1c4` |
| `yardsticks/mojollama-eval-runners/eval/mmlu.py` | `9353bae67fb9255f4256ef000e447d62457e67393ea956b2ac80f695656f5690` | `8d6e5991264e1a85c0429e8334b122808987b2eb` |
| `yardsticks/mojollama-eval-runners/eval/orchestrator.py` | `83ec90920e6868432c300f81ae75e03a1d9c6a4679d494f4b5ea58fe9a940375` | `aab30a01aa7ef4b459f4fdc34ca6621a45fbb785` |

## Rust replacement

aien-yardsticks#2 proposes a Rust replacement. It is not done here. If it goes ahead it is a separate task with new evidence (item 6).
