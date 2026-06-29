# Project Upgrade Report — Team Knowledge-Graph Viewer (`graph_pro.html`)

- **Date:** 2026-06-14  ·  **Skill:** project-upgrade v2.2  ·  **Target:** `graphify-out/graph_pro.html` + generator `~/.claude/skills/graphify/scripts/make-graph-pro.py`
- **Verdict:** **GO (Option B recommended)** · AMBER count = 1 (no ZERO)

---

## 0. Surprise Picks (최우선)

1. **URL deep-link + localStorage 뷰 상태 저장** (Novelty 4 · Surprise 8.0) — 정적 HTML 파일인데도 "Haitham+Ken 선택 + Bridges 켠 상태"를 URL 해시에 인코딩 → 그 링크를 슬랙에 붙이면 팀원이 **똑같은 화면**으로 연다. 정적 파일은 상태가 안 남는다는 통념을 깸. **내일 첫 액션:** `applyMemberFocus()` 끝에 `location.hash = [...memberSel].join(',')` 한 줄 추가 + 로드 시 파싱.
2. **노드 상세 내러티브 패널** (Novelty 3 · Surprise 6.0) — 노드 클릭 시 "이웃 11개 + 관계 타입별 요약 문장"을 사이드에 텍스트로 출력. 시각장애·키보드 사용자도 그래프를 *읽을* 수 있고, 그래프를 모르는 임원도 이해. (emergentmind, Kantz et al. 2025-08-07: KG에 textual summary 동반이 표준화 중) **첫 액션:** 클릭 핸들러에서 `adj[id]`를 관계별로 group → `<ul>` 렌더.
3. **graphify 실행 간 그래프 diff** (Novelty 5 · Cross-domain · ⚠AMBER) — `graphify update` 전/후 `graph.json`을 비교해 추가/삭제된 노드·엣지를 색상 배지로 표시. 코드 diff 개념을 지식그래프에 역수입. **첫 액션:** 두 `graph.json`을 dict로 로드 → 노드 ID set 차집합.

---

## 1. Executive Summary

`graph_pro.html`은 198노드·283엣지·15커뮤니티의 HVDC 온톨로지를 단일 HTML로 보여주는 뷰어로, 팀원 스포트라이트·Bridges·forceAtlas2·검색·파일타입 도형까지 이미 충실하다. 198노드 규모에서 **성능은 병목이 아니다** — 따라서 업그레이드는 (a) 산출물 공유·재현성(PNG export, deep-link, 오프라인 vendoring), (b) 접근성 패리티(`graph.html`엔 enhancer로 a11y가 들어갔지만 `graph_pro.html`엔 없음 — 품질 게이트 불일치), (c) 탐색 심화(커뮤니티 collapse/expand, 노드 내러티브)로 향한다. Best 3는 서로 다른 버킷에서 선정했고 전부 클라이언트사이드·무빌드·무네트워크로 현재 제약과 충돌하지 않는다.

## 2. Current State Snapshot

| 항목 | 현황 | 평가 |
|---|---|---|
| 산출물 | 단일 `graph_pro.html` (100 KB) | ✅ 무빌드·이식성 우수 |
| 라이브러리 | vis-network 9.1.6 (CDN unpkg) | ⚠ `graph_pro`는 CDN의존(오프라인 불가). `graph.html`만 vendored |
| 데이터 | inline `DATA` (graph.json 파생) | ✅ 단일 파일 자급 |
| 인터랙션 | 팀원칩 스포트라이트·Bridges·검색·물리·도형·색상모드 | ✅ 풍부 |
| 접근성 | sr-summary/키보드/데이터테이블 **없음** | ❌ `graph.html` 대비 패리티 미달 |
| 공유/재현 | 상태 비저장·PNG export 없음·deep-link 없음 | ❌ 캡처는 수동 스크린샷뿐 |
| 생성 자동화 | `make-graph-pro.py` 수동 실행 (`export-and-enhance.sh` 미연동) | ⚠ graph.html만 원커맨드 |
| 제약 | Windows/git-bash · no-node · no-build · offline 선호 | (전부 준수) |

**Pain points:** ① 스크린샷 외 공유 수단 없음 ② 오프라인 미보장 ③ a11y 품질 게이트 불일치 ④ pro 생성이 파이프라인 밖.
**Quick wins:** PNG export(반나절), vendoring(10분), pipeline 연동(15분).

## 3. Upgrade Ideas Top 10

| # | 아이디어 | 버킷 | I | E | R | C | Nov | Priority | Surprise | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | PNG/SVG export 버튼 (canvas.toBlob) | DX | 4 | 1 | 1 | 5 | 2 | **20.0** | 8.0 | SO·RedStapler·gist |
| 7 | vis-network를 graph_pro에 vendoring(오프라인) | Reliability | 3 | 1 | 1 | 5 | 1 | **15.0** | 3.0 | 기존 enhancer `--vendor` |
| 8 | `make-graph-pro.py`를 export-and-enhance.sh에 연동 | DX | 3 | 1 | 1 | 5 | 2 | **15.0** | 6.0 | 기존 스크립트 |
| 2 | a11y 패리티(sr-summary·키보드·data-table fallback) | Docs/Process | 4 | 2 | 1 | 5 | 2 | **10.0** | 4.0 | CambridgeIntel·A11YCollective·AEL |
| 5 | 노드 상세 내러티브 패널(이웃+관계요약) | Architecture | 4 | 2 | 1 | 4 | 3 | 8.0 | 6.0 | emergentmind 2025-08 |
| 4 | URL deep-link + localStorage 뷰 상태 | DX | 4 | 2 | 2 | 4 | 4 | 4.0 | **8.0** | yFiles·datavid |
| 3 | 커뮤니티 collapse/expand 클러스터링 | Architecture | 5 | 3 | 2 | 4 | 3 | 3.33 | 5.0 | vis.js docs·DeepWiki·yFiles |
| 6 | stabilize 후 물리 freeze + 좌표 캐시 | Performance | 3 | 2 | 2 | 4 | 2 | 3.0 | 3.0 | vis.js docs |
| 9 | 뷰어 내 path-finding(A→B 연결 강조) | Architecture | 4 | 4 | 2 | 3 | 4 | 1.5 | 4.0 | yFiles "draw attention to paths" |
| 10 | ⚠지도/지오 오버레이(포트·MOSB 좌표) | Architecture | 3 | 5 | 3 | 2 | 5 | 0.4 | 3.0 | Neo4j NODES 2025 (maritime) |

## 4. Best 3 Deep Report

선정: 버킷 다양성(DX / Accessibility / Architecture) + evidence≥2 + 무빌드·무네트워크 적합성. 순수 plumbing(#7,#8)은 Option A 묶음으로 분리.

### Best 1 — PNG/SVG Export 버튼 (DX · Priority 20.0)
- **Goal:** 뷰어 우상단 버튼으로 현재 화면을 PNG(필수)·SVG(선택) 다운로드. 보고서·이메일에 바로 첨부.
- **Non-goals:** 서버 업로드 없음. 인쇄 레이아웃 별도 없음. 워터마크 없음.
- **Design:** vis-network는 `<canvas>`를 노출 → `canvas.toBlob(b=>download(b,'graph.png'))`. 고해상도는 `network.setOptions`로 일시 `pixelRatio` 2배 후 복원. 파일명 `YYYYMMDD_hvdc-graph.png`(CLAUDE.md 명명규칙).
- **PR Plan (3):** ① 템플릿에 export 버튼+핸들러 추가(make-graph-pro.py 문자열) — rollback: 버튼 블록 제거 ② 2x 해상도 옵션 토글 — rollback: 기본 1x 고정 ③ SVG export(노드/엣지를 SVG로 직렬화, 실패 시 PNG fallback) — rollback: SVG 버튼 숨김.
- **Tests:** `node --check` 생성물 · Claude_Preview에서 클릭→다운로드 네트워크 0건(클라이언트사이드 확인) · 빈 그래프/선택상태 양쪽 캡처 · 콘솔 에러 0.
- **Rollout/Rollback:** 기능 토글 불필요(가산 기능). revert = 해당 PR diff 되돌리기.
- **Risks:** SVG 직렬화 미지원(R: PNG fallback) · 대형 캔버스 메모리(R: 198노드 무관) · 브라우저 toBlob 미지원(R: Chrome/FF만 타깃, 폴리필 불요).
- **KPI:** 스크린샷 수작업 0 · export 클릭→파일 ≤1s · 출력 해상도 ≥2x.
- **Deps:** 없음(vis-network 내장 canvas).
- **Evidence:** SO `toDataURL`/`toBlob`(evergreen API) · Red Stapler "Export canvas as image"(toBlob+download) · GitHub gist 자동 다운로드 스니펫.

### Best 2 — a11y 패리티 for `graph_pro.html` (Accessibility · Priority 10.0)
- **Goal:** `graph.html` enhancer가 준 접근성(sr-only 요약·키보드 네비·hover-only 금지·prefers-reduced-motion)을 `graph_pro.html`에도 적용 + 복잡 시각화용 **데이터테이블 fallback**.
- **Non-goals:** 완전 WCAG AAA 아님(AA 타깃). 음성 출력 없음.
- **Design:** make-graph-pro 템플릿에 (a) `role=region` sr-summary("198 nodes, 15 communities, god nodes: …"), (b) vis `interaction:{keyboard:true,navigationButtons:true}`, (c) 검색결과 화살표/Enter 네비, (d) `<details>` 안에 노드 리스트 `<table>`(라벨·커뮤니티·degree) — 키보드·스크린리더·모바일에서 그래프 없이도 데이터 접근, (e) reduced-motion 시 forceAtlas2 애니 off.
- **PR Plan (3):** ① sr-summary + reduced-motion CSS/JS — rollback: 블록 제거 ② 키보드 네비(vis 옵션+검색결과 roving) — rollback: 옵션 false ③ `<details><table>` data fallback(DATA.nodes에서 생성) — rollback: details 숨김.
- **Tests:** axe/Lighthouse a11y 점수 전후 비교 · 키보드만으로 검색→선택 가능 · 스크린리더로 요약 읽힘 · `prefers-reduced-motion` 에뮬레이션(preview_resize colorScheme/reduced) 확인.
- **Rollout/Rollback:** 가산 기능. revert = PR diff.
- **Risks:** vis 키보드와 페이지 단축키 충돌(R: 입력 포커스 시 핸들러 가드) · data-table가 198행→길어짐(R: details 기본 닫힘) · 색대비 회귀(R: WCAG 4.5:1 검증, 기존 enhancer 값 재사용).
- **KPI:** Lighthouse a11y ≥90 · 키보드 단독 전기능 도달 · hover-only 정보 0건.
- **Deps:** 없음.
- **Evidence:** Cambridge Intelligence "build accessible graph visualization tools"(WCAG+508, KeyLines 예시) · A11Y Collective "Ultimate Checklist for Accessible Data Visualisations" · AEL Data "charts need text alternatives + data table".

### Best 3 — 커뮤니티 Collapse/Expand 클러스터링 (Architecture · Priority 3.33, Impact 5)
- **Goal:** 15개 커뮤니티를 각각 1개 클러스터 노드로 접어 큰 그림을 먼저 보이고, 클릭 시 펼침(drill-down). KG 탐색 베스트프랙티스.
- **Non-goals:** 자동 재클러스터링 없음(198노드는 성능 불요). 계층 3단계 이상 없음.
- **Design:** vis-network `network.cluster()`/`openCluster()`를 커뮤니티 id별 호출. 툴바에 "커뮤니티 접기/펼치기" 토글 + 클러스터 노드 라벨=커뮤니티명(`.graphify_labels.json`), 색=대표 커뮤니티색, 크기=구성원 수. 팀원 스포트라이트/Bridges와 상태 상호배타 처리.
- **PR Plan (3):** ① 커뮤니티별 cluster 함수 + 전체 접기/펼치기 토글 — rollback: 토글 숨김 ② 클러스터 노드 클릭→openCluster, 더블클릭→재접기 — rollback: 클릭 핸들러 제거 ③ 기존 필터(member/bridge/inferred)와 상태머신 정리 — rollback: 클러스터 모드 진입 시 타 필터 reset.
- **Tests:** 15클러스터 접기→15노드 표시 검증 · 펼치기→원본 노드 복원(198) · member 스포트라이트와 동시 조작 시 충돌 0 · 콘솔 에러 0 · `node --check`.
- **Rollout/Rollback:** 토글 기본 OFF(기존 동작 보존). revert = PR diff.
- **Risks:** 클러스터/스포트라이트 상태 충돌(R: 진입 시 상호 reset) · 엣지 집계 라벨 혼란(R: 클러스터간 엣지 두께=합산) · 펼침 후 좌표 튐(R: stabilize 짧게 재실행).
- **KPI:** 초기 화면 노드 ≤15(인지부하↓) · 펼침 왕복 무손실 · 조작 1클릭.
- **Deps:** vis-network clustering(내장, 추가 의존 없음).
- **Evidence:** vis.js Network 공식 docs(dynamic clustering >50k) · DeepWiki visjs/vis-network Performance Optimization(cluster 노드 자동 생성) · yFiles "Guide to Visualizing Knowledge Graphs"(expand/collapse, draw attention).

## 5. Options A / B / C

| 옵션 | 범위 | 리스크 | 시간 |
|---|---|---|---|
| **A 보수** | #1 PNG export + #7 vendoring + #8 pipeline 연동 | 거의 0 (전부 가산·무네트워크) | ~1 세션 |
| **B 중간 (추천)** | A + #2 a11y 패리티 + #4 deep-link/persist | 낮음 (상태머신만 주의) | ~2 세션 |
| **C 공격** | B + #3 커뮤니티 클러스터링 + #5 내러티브 패널 + #9 path-finding | 중 (필터 상태 충돌 관리) | ~4 세션 |

## 6. 30 / 60 / 90-day Roadmap (PR 단위)

- **30일:** PR-1 PNG export · PR-2 graph_pro vendoring(`--vendor` 경로 재사용) · PR-3 `make-graph-pro.py`→`export-and-enhance.sh` 연동(graph.html+graph_pro 동시 재생성) · PR-4 a11y sr-summary+키보드.
- **60일:** PR-5 data-table fallback · PR-6 URL deep-link + localStorage 뷰 상태 · PR-7 노드 내러티브 패널.
- **90일:** PR-8 커뮤니티 collapse/expand · PR-9 path-finding(A→B) · (stretch) PR-10 graph diff / 지오 오버레이 PoC.

## 7. Evidence Table

| 아이디어 | platform | title | date | popularity | url |
|---|---|---|---|---|---|
| #1 export | stackoverflow | How to save canvas as png | evergreen API | 누적 high | stackoverflow.com/q/11112321 |
| #1 export | blog | Export canvas as image (Red Stapler) | evergreen | — | redstapler.co/export-canvas-as-image-with-javascript |
| #1 export | github | JS auto-download canvas as png (gist) | evergreen | — | gist.github.com/Kaundur/2aca9a9... |
| #2 a11y | official-ish | Build accessible graph visualization tools (Cambridge Intelligence) | maintained | — | cambridge-intelligence.com/build-accessible-data-visualization-apps-with-keylines/ |
| #2 a11y | blog | Ultimate Checklist for Accessible Data Visualisations (A11Y Collective) | 2025 | — | a11y-collective.com/blog/accessible-charts/ |
| #2 a11y | blog | Guide to Making Charts/Graphs Accessible (AEL Data) | 2025 | — | aeldata.com/guide-to-making-charts-graphs-and-data-accessible/ |
| #3 cluster | official | vis.js Network docs — dynamic clustering | evergreen | — | visjs.github.io/vis-network/docs/ |
| #3 cluster | official-ish | DeepWiki visjs/vis-network Performance Optimization | maintained | — | deepwiki.com/visjs/vis-network/6.4-performance-optimization |
| #3 cluster | vendor | yFiles Guide to Visualizing Knowledge Graphs | maintained | — | yfiles.com/resources/how-to/guide-to-visualizing-knowledge-graphs |
| #5 narrative | research | Interactive Visual Knowledge Graphs (Kantz et al.) | 2025-08-07 | — | emergentmind.com/topics/interactive-visual-knowledge-graphs |
| #4 deeplink | vendor | KG visualization comprehensive guide (datavid) | 2025 | — | datavid.com/blog/knowledge-graph-visualization |
| #10 geo | conf | Graphs on the High Seas — maritime KG+map (Neo4j NODES 2025) | 2025 | — | neo4j.com/nodes-2025/agenda/graphs-on-the-high-seas... |

## 8. AMBER_BUCKET

- **#10 지도/지오 오버레이** ⚠ — Neo4j NODES 2025 근거는 날짜 확실하나, vis-network 단일파일에 지도 타일을 무네트워크로 얹는 것은 **적합성·effort 불확실**(타일은 보통 온라인). HVDC 포트/MOSB/사이트가 실좌표를 가지므로 가치는 높음 → PoC로만 90일 stretch. (AMBER 1건 → ZERO 미발동.)

## 9. Verification Gate

| 검증 항목 | 결과 |
|---|---|
| Best3 evidence ≥2 + 날짜 | ✅ (각 3 근거; vis.js/Cambridge는 maintained·evergreen) |
| Deep Dive 완성도(PR≥3·tests·rollout/rollback·KPI) | ✅ 3개 모두 충족 |
| 스택/제약 적합성(무빌드·무node·offline·Windows) | ✅ 전부 클라이언트사이드, 추가 의존 0 |
| 안전(secrets/PII 없음) | ✅ |
| **Apply Gate 0** dry-run(no writes) | ✅ 코드 변경 없음, 제안만 |
| **Gate 1** change list | ✅ 변경 대상=`make-graph-pro.py` 템플릿 + `export-and-enhance.sh` |
| **Gate 2** explicit approval | ⏸ **대기** — A/B/C 선택 필요 |
| **Gate 3** canary/flag | ✅ 모든 기능 토글 기본 OFF로 가산 |
| **Gate 4** rollback | ✅ PR별 diff revert |

**최종 판정: GO** (Gate 2 승인 시 구현 착수). 추천 = **Option B**.

## 10. Open Questions (≤3)

1. **공유 방식** — PNG export로 충분한가, 아니면 deep-link(URL 복붙으로 동일 화면)까지 필요한가? (Option A vs B 분기)
2. **a11y 우선순위** — 외부 제출(ADNOC/DSV)에 이 뷰어가 들어가면 a11y는 필수, 내부용이면 후순위. 어느 쪽인가?
3. **graph.html과 graph_pro.html 이원화** — 둘 다 유지할지, graph_pro로 일원화할지? (일원화 시 enhancer 로직을 make-graph-pro에 흡수)

---

## SESSION_HANDOFF
skill: project-upgrade v2.2.0 | date: 2026-06-14
key_findings:
  - 198노드 규모는 성능 병목 아님 → 업그레이드 축은 공유·재현성·접근성·탐색심화
  - graph_pro.html은 graph.html 대비 a11y/offline 패리티 미달 (품질 게이트 불일치)
surprise_picks:
  - idea: "URL deep-link + localStorage 뷰 상태" | Novelty: 4 | SurpriseScore: 8.0 | status: PASS
  - idea: "노드 내러티브 패널" | Novelty: 3 | SurpriseScore: 6.0 | status: PASS
  - idea: "graphify 실행 간 그래프 diff" | Novelty: 5 | SurpriseScore: 3.75 | status: ⚠ AMBER(effort)
amber_count: 1
next_suggested: project-plan --focus="best3"
