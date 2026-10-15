# MojoLlama eval runners (yardstick, frozen copy)

Accuracy test runners from MojoLlama: MMLU, GSM8K, C-Eval, HellaSwag, ARC, BBH and HumanEval, plus the shared harness, dataset downloader and orchestrator.

Source: copied from aien-dev/MojoLlama `src/mojollama/eval/` at commit cb281d1e8d906d5cf616c3116ef3d43eab29d6ba (plain byte-for-byte copy; history stays in that repo, which was archived on 2026-10-15 when AIEN dropped Mojo and MAX).

These files are plain Python using only the standard library. They have no Mojo or MAX imports. They talk to a model server over HTTP (a llama.cpp-style completion endpoint) and keep downloaded datasets under `~/.mojollama/eval_datasets`. Some messages still name the old `mojollama-studio` command, which no longer exists here.

This is a yardstick, not part of AIEN. Nothing here ships in AIEN or runs in AIEN's trusted path. Like the other Python in this repository it is kept as historical evidence (see [`HISTORICAL-PYTHON.md`](../../HISTORICAL-PYTHON.md)).
