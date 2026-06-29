# graph_pro.html 최종 패치 (FIX-7/8) — 2026-06-14

생성기 `make-graph-pro.py`의 `refine_ontology()`에 흡수(영구 적용, 재생성에도 유지).
백업: `make-graph-pro.py.bak3-20260614` · `graph_pro.html.bak-final-20260614`

## FIX-7 — INFERRED 강화 (patch.md §8.2, relabel-only·노드 무생성·가역)
6개 unsafe 엣지를 교정 술어로 relabel + `conf=REVIEWED` → raw-INFERRED 풀에서 제외.

| from → to | 기존 | §8.2 | 교정 술어 |
|---|---|---|---|
| confirmed_flow_code → routing_pattern | semantically_similar_to | REJECT | `boundary_constrained_by` |
| mosb_staging → invoice_line | shares_data_with | REWRITE | `marine_charge_evidence_for` |
| exit_gate_pass → backload | semantically_similar_to | REWRITE | `supports_process` |
| audit_record → proof_artifact | semantically_similar_to | REWRITE | `records_proof_artifact` |
| human_gate → evidence_only_rule | semantically_similar_to | REJECT | `distinct_governance_principle` |
| wh_receipt → lpo | semantically_similar_to | REWRITE | `executes_against` |
| shipment_tracking → vessel_tracking | semantically_similar_to | ACCEPT(scope) | 유지(REVIEWED) |

## FIX-8 — 라벨 충돌 해소
`concept_backload` 라벨 `Backload (BL) Management` → `Backload (BKL) Management` (BL=Bill of Lading 충돌 회피)

## 결과 (regenerate --vendor)
- 188 nodes / 283 edges / 14 communities / **INFERRED 15→8** / 16 strong bridges
- dangling 0 · orphan 0
- 멤버 9명 색상 9개 distinct (lead 우선) · performs 39 · PII residue 0 · hvdc_code_tag deg 3
- 기능 토큰 전부 유지: PNG·공유링크·deep-link(syncState/restoreState)·data-table·vendored vis·sr-summary

## patch.md 수용기준
| # | 기준 | 결과 |
|---|---|---|
| #4 | confirmedFlowCode→RoutingPattern similarity = 0 | ✅ 0 (boundary_constrained_by) |
| #5 | MOSB Staging→InvoiceLine 직접 cost-similarity 제거 | ✅ relabel(marine_charge_evidence_for). ⚠ 중간 evidence-node 삽입은 deferred |
| #6 | unsafe INFERRED = 0 | ✅ 0 |

## FIX-9 — 누락 조직원 ResourceRole 추가 (patch.md §5)
조직도 12명 vs graph 9명 → 누락 3명을 `ResourceRole` 노드로 추가 (이름 유지·PII 0).
- 노드: `role_eddel` · `role_thushar` · `role_shefeek` — label `"<이름> (Resource Role)"`, ft `resourcerole`(#9C755F), comm 1(팀과 클러스터링), src/loc 공란(tel/email 없음)
- 엣지: 각 `role_X -[supports]-> member_sanguk` (lead, conf EXTRACTED — org 사실, INFERRED 미증가)
- 결과: **188→191 nodes / 283→286 edges**, INFERRED 8 유지, dangling 0 · orphan 0
- 멤버 칩 9개 유지(ResourceRole은 문서 보유 멤버가 아니므로 칩 제외 — 의도) · 파일타입 범례에 resourcerole=3 표기 · lead 스포트라이트 시 1-hop 이웃으로 점등
- 조직 정합: 9 멤버 + 3 ResourceRole = **12명** ✅

## DESIGN — 다크 테마 폴리시 (`/design`, CSS-only·기능 무변)
생성기 TEMPLATE CSS에 흡수. 백업 `make-graph-pro.py.bak5-20260614`.
- **vis 네비게이션 버튼**: 기본 형광 아이콘 중화 → `filter:grayscale(1) brightness(1.35) contrast(.85)` + panel 배경/`radius:10px`/`opacity .5`(hover 시 accent 테두리·full). 7개 버튼 팔레트 일치 확인.
- **모바일 ☰ 겹침 해소**: `@media(max-width:768px) #topbar{padding-right:64px}` → 375px에서 겹치는 pill **0개**(이전 INFERRED 겹침).
- **캔버스 깊이**: `#graph` radial-gradient 비네트(#16162c→#0c0c16)로 노드 가독성↑.
- **액티브 pill 글로우**: `.pill.on{box-shadow:0 2px 10px rgba(110,168,224,.30)}` 위계 강조.
- **다크 커스텀 스크롤바**: sidebar/legend/neighbors/results/bridges/data-table — thumb=line, hover=accent.
- 검증: console error 0 · 컴퓨티드 스타일 전 항목 라이브 · 191/286/INFERRED 8 불변.

## DESIGN-2 — 개인별 노드 색상 (`/design`, 칩↔노드 색 일치)
요청: "개인별로 색상을 다르게 하여 표시가 나도록". 기존엔 칩만 9색·노드는 전부 document색 → 그래프에서 사람 구분 불가.
- build_data: 각 멤버의 칩색(MEMBER_PALETTE)을 노드에 `mcolor`로 역매핑.
- JS `nodeColor(n)= n.mcolor || (type?cType:cComm)` → 멤버 노드는 색상모드 무관 **항상 개인색**, 그 외는 기존 모드 유지.
- 검증(라이브): 멤버 9노드 = **9색 distinct**, 실제 vis 배경색 = mcolor = 칩색 **0 불일치**, community 모드서도 개인색 유지, concept는 모드 따라감, console error 0.
- ResourceRole 3노드는 role 타입 단일색 유지(요청 시 개인색 확장 가능).

## DESIGN-3 — 전체 명암비 밸런스 (`/design`, WCAG 실측 기반)
WCAG 명암비 전수 측정 → 텍스트/노드는 전부 AA 통과(본문 15.68·muted 5.36+·멤버 노드 ≥3:1). 유일 약점은 테두리.
- `--line` #2a2a4e → **#4a4a7e**: vs bg **1.43→2.38**, vs panel **1.31→2.19** (+67%). 구분선·pill·사이드바·navBtn 경계 가시성 확보(엄격 3:1은 hairline harsh → 밸런스 최적점 채택).
- `#search` 하드코딩 #3a3a5e(더 어두웠음) → `var(--line)` 통일.
- 검증(라이브): 토큰·.sec·사이드바·search 테두리 전부 #4a4a7e, 활성 pill만 accent 테두리 유지, console error 0, 데이터 불변.

## Deferred (별도 승인)
- §3.2 richer HVDCCodeTag 엣지 (concept_material_master 노드 부재)
- CI gate `fail_on_flow_code_route_edge`
- ResourceRole 3인 개인색 분리(현재 role 단일색)
