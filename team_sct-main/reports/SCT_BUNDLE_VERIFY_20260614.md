# sct_ai_ready_bundle 정합성 검증 리포트

- date: 2026-06-14 · target: `team/sct_ai_ready_bundle/` (8파일) · 방식: 번들 내부 교차검증 + 우리 graph_pro.html 대조
- **최종 판정: ✅ PASS — 번들은 내부 정합·우리 패치 그래프와 100% 일치. 데이터 변경 없음(검증 only).**

## 결론 (conclusion-first)
이 번들은 **우리가 정리·패치한 graph_pro.html(FIX-1~9 + 개인색 mcolor)의 다운스트림 "AI 연계용" 산출물**이다. 노드/엣지 카운트·ID 집합·INFERRED 처리·관계 술어가 우리 그래프와 정확히 일치하며, 번들 내부 6개 파일(json/jsonld/schema/audit/xlsx/summary)이 서로 모순 없다.

## 검증 결과 (10개 게이트)
| # | 항목 | 결과 |
|---|---|---|
| 1 | 카운트: bundle 191/286 = our viewer 191/286, jsonld @graph 477=191+286 | ✅ PASS |
| 2 | 노드 ID 집합 bundle == our viewer (차집합 0) | ✅ PASS |
| 3 | 상태 커버리지: 노드 PASS164/AMBER27, 엣지 PASS278/AMBER8 (summary 주장과 실제 일치) | ✅ PASS |
| 4 | 메타데이터 100%: 전 노드 6필드·전 엣지 4필드 누락 0 | ✅ PASS |
| 5 | **AMBER 엣지 8개 == 우리 INFERRED 8개** (완전 일치) | ✅ PASS |
| 6 | schema 정합: top-level(metadata/nodes/edges) + node-item 8필드 + edge-item 8필드 전부 충족 | ✅ PASS |
| 7 | audit_log validation_summary가 실제 카운트와 일치, field_coverage 100%/100% | ✅ PASS |
| 8 | mcolor 9노드 9색 = 우리 DESIGN-2 멤버 개인색 흔적 (다운스트림 증거) | ✅ PASS |
| 9 | JSON-LD: @graph 477 전부 @id 보유, 중복 0 | ✅ PASS |
| 10 | xlsx: Nodes 192행(191+헤더)·Edges 287행(286+헤더) | ✅ PASS |

## 우리 패치와의 정합 증거 (audit top_edge_types)
번들 audit에 우리 **FIX-7 relabel 6종이 그대로** 나타남 → 같은 그래프 기반 확정:
- `boundary_constrained_by`(1), `distinct_governance_principle`(1), `marine_charge_evidence_for`(1), `records_proof_artifact`(1), `supports_process`(1), `executes_against`(1)
- `performs_role`(39) = 우리 `performs` 39 · `semantically_similar_to`(2) = ACCEPT-scope 잔존

## 주의/메모 (결함 아님)
- 번들 core rules가 우리 원칙과 동일: `confirmedFlowCode=WarehouseHandlingProfile`, `MOSB=OffshoreStagingNode`, `Inferred=AMBER until reviewed`.
- `human_gate_required: true` — AMBER 노드/엣지·규제문서·고액비용·운영 mutation은 사람 검토 필수(설계대로).
- operational_truth_note: 이 그래프는 **AI-ready 의미/근거 그래프**이지 live BOE/DO/Invoice source-of-truth 아님(가정 일치).

## 권고 (후속, 이번 범위 외)
1. 번들을 team 구조로 편입(`ai-bundle/` 또는 graphify-out 옆) + README 인덱스 등록.
2. AMBER 27노드/8엣지 = Human-gate 큐 → 검토 후 PASS 승격 시 재-export.
3. Foundry 연계 시 jsonld `@id`/provenance 보존(summary §3 write-back rule 준수).
