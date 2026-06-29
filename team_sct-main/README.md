# HVDC Team — 폴더 인덱스

> Samsung C&T HVDC 프로젝트 · 팀 온톨로지 + 지식그래프 뷰어. 최종 정리: 2026-06-14

## 구조
```
team/
├── 온톨로지 (graphify 입력 — 이동 금지)
│   ├── CONSOLIDATED-00~09-*.md      10개 정식 온톨로지
│   └── HVDC_Logistics_Ontology.combined.md   결합본(파생)
├── 팀 분석 (graphify 입력)
│   ├── {이름}_major_work_analysis.en.md   멤버 8명 분석
│   ├── Team_role_allocation_matrix.en.md   역할분담(EN)
│   └── Team_역할분담_매트릭스.md            역할분담(KO)
├── graphify-out/        지식그래프 + 뷰어
│   ├── graph_pro.html   ★ 최종 인터랙티브 뷰어 (191노드/286엣지, vis는 sibling JS)
│   ├── graph_pro.standalone.html  ★ 단일 파일판 (vis 인라인, 789KB, 외부 의존 0)
│   ├── graph.json       그래프 데이터 (graphify 산출)
│   ├── graph.html       기본 뷰어
│   ├── CHANGES_finalize_20260614.md   FIX-1~9 + 디자인 변경이력
│   ├── vis-network.min.js   오프라인 벤더링
│   └── cache/, GRAPH_REPORT.md, manifest.json …
├── reports/             감사·계획·업그레이드 문서
│   ├── patch.md, FLOWCODE_AUDIT.md
│   ├── CLEANUP_PLAN_20260614.md
│   └── 20260614_*-project-upgrade-report.md ×2
└── _archive/            보관(추후 삭제 검토)
    ├── files/, files.zip            전달 패치 패키지(생성기로 대체됨)
    ├── _backup_flowcode_…/          flowcode 감사 백업(변경 0건)
    └── *.bak                        뷰어 중간 백업
```

## 뷰어 열기
- **배포/공유**: `graph_pro.standalone.html` 파일 1개만 복사 → 더블클릭(오프라인 단독, 외부 의존 0). 이메일·USB 배포용.
- **로컬**: `graph_pro.html` 직접 열기 (단, `vis-network.min.js` 동일 폴더 필요)
- **서버**: `python -m http.server 8765 --directory graphify-out` → `http://localhost:8765/graph_pro.html`
- 단일 파일 재생성: `python ~/.claude/skills/graphify/scripts/make-graph-pro.py graphify-out/graph.json --inline`

## 그래프 갱신
- 온톨로지/분석 `.md` 수정 후: `graphify update .` → `python ~/.claude/skills/graphify/scripts/make-graph-pro.py graphify-out/graph.json --vendor`
- ⚠ 온톨로지/분석 `.md`는 graphify 입력 소스(graph.json src 참조) — 하위 폴더 이동 시 재인덱싱 필요

## 정리 이력 (2026-06-14, 옵션1 보수안)
- 바이트 동일 중복 3개 삭제 · `CONSOLIDATED-07 (1)` → 정식명 rename(graph src 동기화)
- reports/ · _archive/ 신설로 root 정돈 · 전체 백업: `../team_backup_20260614.zip`
