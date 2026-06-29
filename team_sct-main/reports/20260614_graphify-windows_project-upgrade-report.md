# Project Upgrade Report — graphify skill (Windows compatibility focus)

- **Target:** `~/.claude/skills/graphify` (SKILL.md v0.8.35 orchestration + `graphifyy` 0.8.35 pip package)
- **Lens:** Windows / git-bash robustness
- **Date:** 2026-06-14 · **Evidence floor:** 2025-06-14 (rolling 12-month) · **EN-only**
- **Scope:** Suggestions only. No code/skill changes applied (Hard Rule #5).

---

## 0. Surprise Picks (SurpriseScore top 3)

1. **CRLF-safe sidecar reads (`tr -d '\r'`)** — SurpriseScore 9.0. The `.graphify_python` / `.graphify_root` files are read back as raw interpreter paths; a single stray `\r` from any editor or PowerShell `Out-File` silently corrupts every downstream `$(cat ...)` call. One-line fix, prevents a whole class of "interpreter not found" failures. **First action tomorrow:** wrap every sidecar read in `tr -d '\r\n'`.
2. **Capability-probe + graceful-degrade bootstrap (borrowed from `uv`/`rustup` installers)** — SurpriseScore 5.33, Novelty 4. Cross-domain import: installer-grade bootstrap scripts probe the environment, pick the best available tool, and *log what they skipped* instead of hard-failing. graphify's Step 1 currently assumes one shell. **First action:** add a 5-line `detect-shell` preamble that records `uname`/`$OSTYPE` and chooses the POSIX path.
3. **Port Step 1 PowerShell → POSIX sh** — SurpriseScore 5.0. The single highest-leverage fix; see Best 1.

---

## 1. Executive Summary

graphify works on this Windows machine **only because I manually rewrote its PowerShell Step 1 into bash** during the run. The root cause is now externally confirmed: Claude Code's Bash tool on Windows pre-expands shell variables (`$py`, `$LASTEXITCODE`, `$_`) before PowerShell receives them ([Issue #15471](https://github.com/anthropics/claude-code/issues/15471), Dec 2025), so graphify's PowerShell-only Step 1 is structurally broken under the very harness it ships for. Everything from Step 2 onward is already bash, making Step 1 the lone inconsistency.

Secondary issues: bare `python3` calls assume a Linux-style launcher (this box has `python` only, Python 3.14 — [PEP 773](https://peps.python.org/pep-0773/) reshuffles these commands), no CRLF guard on interpreter sidecar files, Windows backslash paths injected into subagent prompts, and no CI coverage on `windows-latest`. None of the heavy deps block 3.14 — tree-sitter ships forward-compatible `abi3` wheels, and graspologic is optional (Louvain fallback already default).

The recommended path is **commit to POSIX sh as the single skill shell**, add a portable interpreter resolver, and add a Windows CI lane. Conservative, low-risk, high-impact.

---

## 2. Current State Snapshot

| Area | Observed state | Evidence (firsthand this session unless noted) |
|---|---|---|
| Step 1 shell | **PowerShell only**; rest of skill is bash | SKILL.md L66 ```powershell``` block; I hand-ported it to run |
| Interpreter calls | bare `python3` in Steps 2–9; box has `python` (3.14) only | `python -c "import graphify"` works, `python3` absent |
| Interpreter sidecar | `.graphify_python` read via `$(cat ...)`, no `\r` strip | SKILL.md Step 1; works but brittle |
| Subagent paths | absolute Windows paths w/ backslashes in CHUNK_PATH | extraction-spec.md; I substituted `C:\Users\...` manually |
| Clustering | graspologic NOT installed → NetworkX Louvain fallback | `pip show graphifyy` deps list (no graspologic) |
| Python deps | tree-sitter-* (abi3), networkx, rapidfuzz, datasketch | `pip show graphifyy` Requires |
| Runtime | Python 3.14.4, graphify 0.8.35 | `python -V`, `.graphify_version` |
| CI | none visible in skill bundle | `find` of skill dir: SKILL.md + references/ only |

**Pain points:** (1) PowerShell Step 1 vs bash harness; (2) `python3` vs `python`; (3) no CRLF guard; (4) backslash path fragility; (5) no Windows CI.
**Quick wins:** CRLF strip on reads; portable interpreter resolver; forward-slash paths.

---

## 3. Upgrade Ideas — Top 10

PriorityScore = (Impact × Confidence) / (Effort × Risk) · SurpriseScore = (Novelty × Impact) / Effort

| # | Idea | Bucket | Imp | Eff | Risk | Conf | Nov | **Prio** | **Surp** | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Port Step 1 PowerShell → POSIX sh interpreter-detect | DX/Tooling | 5 | 2 | 2 | 5 | 2 | **6.25** | 5.0 | #15471; OneUptime POSIX |
| 2 | Portable interpreter resolver (`.graphify_python`→`py -3`→`python3`→`python`) | DX/Tooling | 5 | 2 | 2 | 5 | 2 | **6.25** | 5.0 | PEP 773; MS Learn |
| 3 | CRLF-safe sidecar reads (`tr -d '\r'`) | Reliability | 3 | 1 | 1 | 4 | 3 | **12.0** | 9.0 | FunWithLinux; cross-plat |
| 4 | tree-sitter abi3 / Python 3.14 compat note | Docs | 2 | 1 | 1 | 5 | 2 | **10.0** | 4.0 | py-tree-sitter; lang-pack |
| 5 | Default graspologic ANSI suppression + uninstall doc | Reliability | 2 | 1 | 1 | 4 | 2 | **8.0** | 4.0 | SKILL.md L634 (self) |
| 6 | `graphify doctor` preflight (shell/python/deps/version) | DX/Tooling | 4 | 3 | 1 | 4 | 3 | **5.33** | 4.0 | uv/rustup bootstrap |
| 7 | CI matrix: windows-latest git-bash + ubuntu | Observability | 4 | 3 | 1 | 4 | 3 | **5.33** | 4.0 | jaalto portability; ShellCheck |
| 8 | Forward-slash / `cygpath` path normalization for CHUNK_PATH | Reliability | 3 | 2 | 2 | 4 | 3 | **3.0** | 4.5 | git-bash spaces #;cross-plat |
| 9 | Commit skill to single shell (drop PowerShell duals) | Architecture | 4 | 3 | 2 | 4 | 2 | **2.67** | 2.67 | OneUptime POSIX |
| 10 | ⚠ Cross-domain: capability-probe + graceful-degrade bootstrap | Architecture | 4 | 3 | 2 | 3 | 4 | **2.0** | 5.33 | uv/rustup installer pattern |

---

## 4. Best 3 Deep Report

### Best 1 — Port Step 1 to POSIX sh + portable interpreter resolver (merges #1, #2)
*Bucket: DX/Tooling · Prio 6.25 · Nov 2 — selected as headline: strongest evidence + root cause*

**Goal**
- Step 1 runs unmodified in git-bash (the actual Claude Code shell on Windows) and on Linux/macOS.
- One interpreter-resolution function used by every subsequent step; never assume `python3` exists.
- Zero PowerShell in the default path.

**Non-goals**
- Not dropping Windows-native PowerShell users who run the skill outside Claude Code (keep a documented PS fallback in references/).
- Not changing the `graphifyy` package itself — orchestration-layer only.

**Proposed Design**
- Replace the `powershell` Step 1 block with a POSIX `sh` function `resolve_graphify_python` that tries, in order: existing `graphify-out/.graphify_python` → `command -v graphify` shebang → `py -3` (Windows python.org) → `python3` → `python`, validating each with `import graphify`.
- Persist the resolved path with `printf '%s'` (no trailing newline) and always read it back through `tr -d '\r\n'`.
- Data flow: `resolve → write sidecar → every step reads sidecar`. Interface contract unchanged (`$(cat graphify-out/.graphify_python)` still valid, just CRLF-hardened).

**PR Plan (≥3)**
1. **PR-1 `posix-step1`** — rewrite Step 1 block in `sh`; add `resolve_graphify_python`. Files: `SKILL.md` Step 1. Rollback: revert block; old PowerShell preserved in git history.
2. **PR-2 `py-resolver`** — swap bare `python3` → `"$(graphify_py)"` helper across Steps 2–9 + references. Files: `SKILL.md`, `references/*.md`. Rollback: sed back to `python3`.
3. **PR-3 `ps-fallback-doc`** — move the PowerShell variant into `references/windows-powershell.md` for non-harness users. Files: new ref. Rollback: delete file.

**Tests**
- unit: `resolve_graphify_python` returns a path whose `python -c "import graphify"` exits 0, on git-bash + bash + zsh.
- integration: full `/graphify .` dry-run on a 3-file corpus under git-bash; assert `graph.json` written.
- e2e: same under ubuntu-latest.
- regression: assert no `python3`/`powershell` token remains in the default path (`grep -c`).

**Rollout & Rollback**
- Ship behind a doc note; no flag needed (skill is markdown, instantly revertible).
- Canary: run on this `team/` corpus first.
- Revert path: `git revert` the 3 PRs; PowerShell block restored verbatim.

**Risks & Mitigations (top 5)**
1. `py` launcher absent (MS Store Python) → resolver falls through to `python`. 2. zsh `local` quirks → use POSIX-safe function style. 3. Sidecar from old PowerShell run has CRLF → `tr -d '\r'` on read. 4. Non-harness PS users lose Step 1 → PR-3 fallback doc. 5. Hidden `python3`-only assumption in a reference → PR-2 regression grep.

**KPI Targets**
- Step 1 manual-edit rate on Windows: **100% → 0%**.
- `/graphify` cold-run success on git-bash (no hand-edits): **target ≥ 95%**.
- `python3`/`powershell` tokens in default path: **→ 0**.

**Dependencies / Migration traps**
- PEP 773 transition: on 3.14 python.org installs, `py` and `python` both resolve; on older boxes `py -3` still works. Trap: a stale `.graphify_python` pointing at a removed venv — validate before trusting it.

**Evidence (≥2, dated)**
- [Claude Code Issue #15471 — bash pre-expands PowerShell variables on Windows](https://github.com/anthropics/claude-code/issues/15471) · github · ~2025-12 · comments/regression report · *proves PS-via-Bash-tool is broken*.
- [PEP 773 – Python Installation Manager for Windows](https://peps.python.org/pep-0773/) · official · accepted 2025 · *`python` default, `py`/`python3` shims*.
- [Python 3.14 — Using Python on Windows](https://docs.python.org/3/using/windows.html) · official · 3.14 docs · *new unified `py`/`python3` behavior*.

---

### Best 2 — CRLF-safe reads + path normalization (merges #3, #8)
*Bucket: Reliability · Prio 12.0 (highest) · Nov 3*

**Goal**
- No run ever fails from a `\r` in a sidecar file or a backslash in an injected path.
- Subagent CHUNK_PATH values are unambiguous across shells.

**Non-goals**
- Not converting the whole corpus to forward slashes (only skill-generated paths).

**Proposed Design**
- Read helper: `graphify_py() { tr -d '\r\n' < graphify-out/.graphify_python; }`.
- Path helper: normalize project root to forward slashes for CHUNK_PATH; keep native form only where Python opens files (Python accepts `/` on Windows).
- Data flow: write native → normalize at the prompt-substitution boundary.

**PR Plan (≥3)**
1. **PR-1 `crlf-guard`** — `tr -d '\r\n'` on all sidecar reads. Files: `SKILL.md` Steps 1–9.
2. **PR-2 `fwdslash-paths`** — derive CHUNK_PATH with `/` separators; document `cygpath -m` option. Files: `SKILL.md` Step 3, `references/extraction-spec.md`.
3. **PR-3 `spaces-test`** — add a path-with-spaces fixture (`Program Files`-style) to the test corpus. Files: tests.

**Tests**
- unit: sidecar containing `path\r\n` resolves to clean `path`.
- integration: run with project dir under a spaces-containing path; assert chunk files written.
- regression: assert CHUNK_PATH in dispatched prompt contains no `\`.

**Rollout & Rollback** — pure-additive string hygiene; revert per PR. No flag.

**Risks & Mitigations**
1. Over-stripping legitimate trailing chars → strip only `\r\n`. 2. `cygpath` absent on non-cygwin bash → forward-slash derivation doesn't need it. 3. Python path with `/` on Windows — supported since always. 4. Mixed-separator path confuses Agent → normalize once at boundary. 5. Old sidecars → PR-1 covers reads regardless of writer.

**KPI Targets**
- Sidecar-corruption failures: **→ 0**.
- Runs from spaces-in-path dirs succeeding: **target 100%**.

**Dependencies / Migration traps** — none; orthogonal to Best 1, ship together.

**Evidence (≥2, dated)**
- [How to Write Cross-Platform Compatible Bash Scripts — FunWithLinux](https://www.funwithlinux.net/bash-scripting/how-to-write-cross-platform-compatible-bash-scripts/) · blog · 2025 · *CRLF vs LF breakage on Windows*.
- [Claude Code Issue #11496 / #12022 — git-bash detection & Program Files spaces](https://github.com/anthropics/claude-code/issues/12022) · github · 2025-10..12 · *paths-with-spaces handling on Windows*.

---

### Best 3 — CI matrix on windows-latest (git-bash) + ubuntu (#7)
*Bucket: Observability · Prio 5.33 · Nov 3 — selected for bucket diversity + prevents regressions*

**Goal**
- Every change to SKILL.md's shell blocks is smoke-tested on Windows git-bash and Linux before merge.
- Catch `python3`/PowerShell/CRLF regressions automatically.

**Non-goals**
- Not testing the LLM extraction quality (non-deterministic) — only the deterministic shell/Python plumbing.

**Proposed Design**
- GitHub Actions workflow, `strategy.matrix.os: [windows-latest, ubuntu-latest]`, `shell: bash` (git-bash on Windows).
- Steps: install `graphifyy`, extract the bash code-fences from SKILL.md, run the deterministic ones (detect, AST, build, cluster, export) on a tiny fixture corpus; assert `graph.json` non-empty.
- Add ShellCheck lint over extracted fences.

**PR Plan (≥3)**
1. **PR-1 `ci-fixture`** — add `tests/fixtures/mini/` (3 md files). 
2. **PR-2 `ci-workflow`** — `.github/workflows/skill-smoke.yml` matrix.
3. **PR-3 `ci-shellcheck`** — extract-and-lint step + badge.

**Tests** — the workflow *is* the test: detect→build→export on both OSes; ShellCheck exit 0.

**Rollout & Rollback** — additive CI; disable workflow to roll back. Start `continue-on-error: true`, flip to required once green.

**Risks & Mitigations**
1. git-bash flakiness on hosted runners → pin runner image. 2. graphify install time → cache pip. 3. Non-determinism if LLM steps included → exclude them. 4. ShellCheck false positives on heredocs → `# shellcheck disable` scoped. 5. Maintenance cost → keep fixture tiny.

**KPI Targets**
- Mean-time-to-detect a Windows shell regression: **manual/none → < 1 CI run**.
- Green CI on both OSes before merge: **target 100% of PRs**.

**Dependencies / Migration traps** — requires the skill to live in a git repo with Actions enabled.

**Evidence (≥2, dated)**
- [jaalto/project--shell-script-performance-and-portability](https://github.com/jaalto/project--shell-script-performance-and-portability) · github · 2025 · *portability test methodology, ShellCheck*.
- [Writing POSIX-Compatible Shell Scripts for Maximum Portability — OneUptime](https://oneuptime.com/blog/post/2026-02-13-posix-shell-compatibility/view) · blog · 2026-02-13 · *POSIX baseline + lint/test across envs*.

---

## 5. Options A/B/C

| Option | Scope | Risk | Time |
|---|---|---|---|
| **A — Conservative** | Best 2 only (CRLF + paths) + doc the `python`/`python3` gotcha | Very low | ~0.5 day |
| **B — Balanced (recommended)** | Best 1 + Best 2 (POSIX port + resolver + hygiene) | Low | ~1–2 days |
| **C — Aggressive** | Best 1 + 2 + 3 + `graphify doctor` (#6) + capability-probe (#10) | Medium | ~4–5 days |

---

## 6. 30/60/90-Day Roadmap (PR-sized)

**30 days**
- PR `crlf-guard`, PR `fwdslash-paths` (Best 2).
- PR `posix-step1` (Best 1 core).

**60 days**
- PR `py-resolver`, PR `ps-fallback-doc` (Best 1 complete).
- PR `ci-fixture`, PR `ci-workflow` (Best 3).
- PR `tree-sitter-314-note` (#4).

**90 days**
- PR `ci-shellcheck`, flip CI to required.
- PR `graphify-doctor` preflight (#6).
- Evaluate capability-probe bootstrap (#10) as design spike.

---

## 7. Evidence Table

| Idea(s) | Evidence | Platform | Date | Popularity | Relevance |
|---|---|---|---|---|---|
| 1,2,9 | [Issue #15471](https://github.com/anthropics/claude-code/issues/15471) | github | ~2025-12 | bug/regression report | bash mangles PS vars via Bash tool |
| 1,2 | [PEP 773](https://peps.python.org/pep-0773/) | official | 2025 | accepted PEP | `python`/`py`/`python3` future |
| 1,2 | [Python 3.14 Using Python on Windows](https://docs.python.org/3/using/windows.html) | official | 2025 (3.14) | core docs | launcher behavior |
| 2 | [Python on Windows — MS Learn](https://learn.microsoft.com/en-us/windows/dev-environment/python) | official | 2025 | MS docs | `python3` vs `py` guidance |
| 3,8 | [FunWithLinux cross-platform bash](https://www.funwithlinux.net/bash-scripting/how-to-write-cross-platform-compatible-bash-scripts/) | blog | 2025 | — | CRLF/LF, forward slashes |
| 8 | [Issue #12022 git-bash + Program Files spaces](https://github.com/anthropics/claude-code/issues/12022) | github | 2025-10..12 | bug report | path-with-spaces on Windows |
| 7,9 | [OneUptime POSIX portability](https://oneuptime.com/blog/post/2026-02-13-posix-shell-compatibility/view) | blog | 2026-02-13 | — | POSIX baseline, lint/test |
| 7 | [jaalto shell portability](https://github.com/jaalto/project--shell-script-performance-and-portability) | github | 2025 | repo | portability test method |
| 4 | [py-tree-sitter](https://github.com/tree-sitter/py-tree-sitter) + [language-pack](https://pypi.org/project/tree-sitter-language-pack/) | github/pypi | 2025 | abi3 wheels | 3.14 forward-compat |
| 10 | uv / rustup installer bootstrap pattern | github | 2025 | high-star installers | cross-domain probe+degrade |

---

## 8. AMBER_BUCKET

| Idea | Reason | Action needed |
|---|---|---|
| #10 capability-probe bootstrap | Cross-domain analogy (uv/rustup), no single dated source pinned for graphify's exact case | ⚠ Novelty 4 — kept in Top 10 per rule; confirm with a specific uv/rustup install-script commit before adopting |
| #4 Python 3.14 abi3 wheel for **every** tree-sitter grammar | Search inferred abi3 forward-compat; did not verify each of the 26 grammar wheels has a 3.14-installable tag | Spot-check `pip install` of the grammar set on 3.14 (likely fine; not blocking) |

**AMBER count: 2** — both are *low-impact / non-blocking* (one cross-domain inspiration, one doc spot-check). Neither sits in Best 3. The ZERO gate is **not** triggered: Best 1–3 each carry ≥2 dated, in-window sources from official/github/blog platforms.

---

## 9. Verification Gate

| Check | Result |
|---|---|
| Evidence completeness (Best3 ≥2 + dates) | **PASS** — Best 1: 3, Best 2: 2, Best 3: 2, all in-window |
| Deep Dive completeness (PR≥3, tests, rollout/rollback, KPIs) | **PASS** — all three complete |
| Stack/constraints compatibility | **PASS** — POSIX sh runs in git-bash (the Windows harness shell); no new runtime deps |
| Safety (no secrets/PII/tokens) | **PASS** — none emitted |

**Apply Gates**
- Gate 0 Dry-run: **PASS** (report only, no writes to the skill).
- Gate 1 Change list: SKILL.md Step 1 + Steps 2–9 interpreter calls; `references/extraction-spec.md`; new `references/windows-powershell.md`; new `.github/workflows/skill-smoke.yml` + `tests/fixtures/mini/`.
- Gate 2 Explicit approval: **PENDING** — awaiting your go before any edit.
- Gate 3 Canary: run patched skill on `team/` corpus first.
- Gate 4 Rollback: `git revert` per PR; PowerShell block preserved in history + references/.

**Final judgment: GO (Option B recommended)** — pending Gate 2 approval.

---

## 10. Open Questions
1. Should the PowerShell Step 1 be **deleted** from the default path, or kept as a documented fallback for users running graphify outside Claude Code (native PowerShell)?
2. Does the graphify skill live in a git repo you control (needed for the Best 3 CI lane), or is it a vendored copy under `~/.claude/skills/`?
3. Target floor: support Python **3.9+** (matches tree-sitter abi3 cp310 wheels) or only 3.12+?
