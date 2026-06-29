# team 폴더 정리 계획 (CLEANUP PLAN)

- date: 2026-06-14 · target: `C:\Users\jichu\Downloads\team` (총 4.0M, 28 root 파일 + 4 디렉터리)
- **상태: 계획 only. 실행 안 함.** (CLAUDE.md: 삭제/덮어쓰기 전 확인 필수 · 대량작업 전 백업)
- 핵심 제약: **graphify가 root의 `CONSOLIDATED-*.md` + `*_major_work_analysis.en.md`를 입력으로, `graphify-out/`을 산출로 사용** (graph.json src가 root 절대경로 참조). → 이 파일들을 하위 폴더로 이동하면 `graphify update .` 재인덱싱 필요.

## 현재 상태 스냅샷
| 구분 | 개수/크기 | 비고 |
|---|--:|---|
| CONSOLIDATED-00~09 | 10 | 온톨로지 정식본 (graphify 입력) |
| HVDC_Logistics_Ontology.combined.md | 449K | 위 10개 파생 결합본 |
| 멤버 분석 *_major_work_analysis.en | 10 파일 | 실제 8명 (Karthik·Ronnel 중복 1쌍씩) |
| Team 매트릭스 | 3 | EN(+중복1), KO |
| 리포트 | 4 | patch.md, FLOWCODE_AUDIT.md, project-upgrade×2 |
| graphify-out/ | 1.6M | 뷰어 산출 + 백업 2 + cache |
| _backup_flowcode_…/ | 880K | flowcode 감사 백업 (변경 0건 확인됨) |
| files/ + files.zip | 324K+56K | 전달받은 패치 패키지 (생성기 방식으로 대체됨) |

## A. 즉시 정리 — 검증된 중복/오류 (저위험)

### A-1. 동일 바이트 중복 삭제 (cmp 검증 IDENTICAL)
- `Karthik_major_work_analysis.en (1).md`  ← `Karthik_major_work_analysis.en.md`와 동일
- `Ronnel_major_work_analysis.en (1).md`   ← 동일
- `Team_role_allocation_matrix.en (1).md`  ← 동일
- → **3개 삭제** (정식본 유지)

### A-2. 다운로드 "(1)" 라벨 정정 (rename, 짝 없음 = 정식본)
- `CONSOLIDATED-07-port-operations (1).md` → `CONSOLIDATED-07-port-operations.md`
- ⚠ graphify 입력 파일명 변경 → rename 후 `graphify update .` 1회 권장

### A-3. 중복 아카이브
- `files.zip` = `files/` 내용과 100% 동일(5파일) → zip 삭제 또는 `_archive/`

## B. 아카이브 이동 — 역할 끝난 산출물 (중위험, 삭제 아님)

`_archive/` 폴더 신설 후 이동 (즉시 삭제 대신 보관 → 추후 일괄 삭제 승인):
- `_backup_flowcode_20260614_154346/` (880K) — flowcode 감사 결과 **변경 0건**이라 사실상 불필요. 보관 후 삭제 권장.
- `files/` (324K) — 전달 패치 패키지(`graph_pro.fixed.html`, `fix_graph_ontology.py`, `ontology_fix.patch`). **생성기 흡수 방식(FIX-1~9)으로 대체됨.** 참조용 보관.
- `graphify-out/graph.html.pre-enhance.bak` (167K) — enhance 전 중간 백업.
- `graphify-out/graph_pro.html.bak-final-20260614` (102K) — FIX-7/8 전 백업. (생성기 백업 bak3~7은 `~/.claude`에 별도 보관 중)

## C. 폴더 구조화 — 2가지 옵션

### 옵션 1 — 보수안 (권장, graphify 무영향)
root 입력 파일은 **그대로 두고**, 흩어진 리포트만 묶는다:
```
team/
├── CONSOLIDATED-00~09.md, HVDC_…combined.md   (유지 — graphify 입력)
├── *_major_work_analysis.en.md (8), Team_*.md (2)  (유지 — graphify 입력)
├── reports/        ← patch.md, FLOWCODE_AUDIT.md, project-upgrade×2, CLEANUP_PLAN
├── graphify-out/   (유지 — 뷰어/그래프 산출, 백업은 _archive로)
├── _archive/       ← files/, files.zip, _backup_flowcode/, *.bak
└── README.md       ← (신설) 폴더 인덱스 1장
```
- 영향: graphify 재인덱싱 **불필요**. A-2 rename만 예외.
- 작업량: 소(小). 위험: 저(低).

### 옵션 2 — 전면 재구성 (깔끔하나 재인덱싱 필요)
```
team/
├── ontology/        ← CONSOLIDATED×10 + combined
├── team-analysis/   ← 멤버 8 + 매트릭스 2
├── reports/         ← 리포트 전체
├── viewer/          → graphify-out/  (또는 root 유지)
├── _archive/
└── README.md
```
- 영향: graphify 입력 경로 변경 → `graphify update .` 재실행 + graph.json src 갱신 필수. PII 마스킹 규칙(`team/` prefix)은 유지됨.
- 작업량: 중(中). 위험: 중(中) — 그래프 재생성 후 뷰어 검증 필요.

## 실행 순서 (승인 시)
1. **백업 먼저**: `team/` 전체 → `team_backup_20260614.zip` (대량작업 규칙)
2. A-1 중복 3개 삭제 → A-2 rename → A-3 zip 처리
3. `_archive/` 생성 후 B 항목 이동
4. (옵션 1 or 2) 폴더 구조화
5. 옵션 2 또는 A-2 시 → `graphify update .` 후 `make-graph-pro.py … --vendor` 재생성 + 뷰어 검증
6. `README.md` 인덱스 작성

## 결정 필요 (Go/No-Go)
- [ ] 옵션 1(보수, 권장) vs 옵션 2(전면)?
- [ ] `_backup_flowcode_*`(880K) 보관 후 삭제 OK? (변경 0건이라 불필요)
- [ ] `files/` + `files.zip` 삭제 vs `_archive/` 보관?
- [ ] 중복 3개 즉시 삭제 OK? (바이트 동일 검증됨)
