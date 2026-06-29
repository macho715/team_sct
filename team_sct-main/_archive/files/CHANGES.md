# graph_pro.html 온톨로지 정제 — 변경 로그 (CHANGES)

**대상**: `graph_pro.html` (HVDC Team Ontology, vis-network)
**판정 전환**: AMBER → PASS(예상, 검수 후)
**적용 방법**: `git apply ontology_fix.patch` 또는 `python3 fix_graph_ontology.py graph_pro.html graph_pro.fixed.html`
**무결성 검증**: dangling edge 0 · orphan(deg0) 0 · 모든 엣지 endpoint 존재 ✓

| 지표 | 수정 전 | 수정 후 | Δ |
|------|--------:|--------:|---|
| nodes | 198 | **188** | −10 |
| edges | 283 | **283** | −2 noise −1 dup +3 신규 (순0) |
| communities | 15 | **14** | −1 (config 커뮤니티 소멸) |
| concept | 163 | **156** | −7 (머지) |
| code | 3 | **0** | −3 (노이즈 제거) |
| inferred | 15 | 15 | 0 |

---

## FIX-1 · 노이즈 노드 제거 (O3, P0)
물류와 무관한 Claude 설정파일 노드가 온톨로지에 혼입되어 고립 커뮤니티를 형성 → 제거.
- 제거 노드(3): `claude_settings_local`, `claude_settings_local_permissions`, `claude_settings_local_permissions_allow`
- 제거 엣지(2): 위 노드 간 `contains`

## FIX-2 · 중복 클래스 머지 (O2, P0)
동일 클래스가 출처 문서별로 별도 노드화된 7건을 canonical(00 마스터 우선)로 병합. 엣지는 리다이렉트 후 디둡(EXTRACTED 우선).

| 제거된 복제 노드 | → Canonical |
|---|---|
| `consolidated_06_site_receipt` | `concept_site_receipt` |
| `consolidated_07_port_call` | `concept_port_call` |
| `consolidated_08_communication_event` | `concept_communication_event` |
| `consolidated_08_approval_action` | `concept_approval_action` |
| `consolidated_08_audit_record` | `concept_audit_record` |
| `concept_anykey_resolution` | `concept_any_key_resolution` |
| `concept_master_ontology` (05 spine) | `consolidated_00_master_ontology` (00 문서) |

- 중복 엣지 1건 제거. 05~09의 `cites`가 이제 00 마스터 노드로 정확히 수렴.

## FIX-3 · HVDCCodeTag 연결 (O4, P0)
원본 00에 8회 등장하는 핵심 식별자가 graph상 `deg:0` 고립 → 식별 체인에 결선. (deg 0 → **3**)
- `concept_shipment_unit --references--> concept_hvdc_code_tag`
- `concept_hvdc_code_tag --conceptually_related_to--> concept_identifier`
- `concept_any_key_resolution --references--> concept_hvdc_code_tag`

## FIX-4 · 커뮤니티 라벨 정정 (O5, P1)
comm0 라벨 `"Cost & Invoice Allocation"`이 실제로는 05·06·07 노드를 포함 → `"Cost/Material/Port (05–07)"`로 정정(24개 노드). *주: 정식 재군집(Louvain 재실행)은 후속 권장.*

## FIX-5 · 술어 의미론 (O6, P2)
행위자–역할 관계를 코드 의미의 `implements` → `performs`로 교정(39건). `relations` 어휘에 `performs` 추가. (member→role/concept 만 대상; member↔member, role→concept 등은 보존.)

## FIX-6 · PII 경로 마스킹 (B5, P2)
공유 링크 기능 탑재로 외부 유출 대비 → `src`의 `C:/Users/jichu/Downloads/team/` → `team/` (58건). 담당자 실명은 NDA 규칙상 유지.

---

## 후속(이번 패치 범위 외)
- **재군집**: comm0 라벨 정정은 임시 — Louvain/Leiden 재실행으로 05/06/07 정식 분리 권장.
- **INFERRED 15건 검수**: 특히 `Backload (BL)` 라벨이 Bill of Lading(BL)과 약어 충돌 — 라벨 명확화(`Backload (BKL)` 등) 검토.
- **hyperedges=9**: 본 DATA에 표현되지 않아 원값 유지(재계산 불가) — 별도 소스 확인 필요.
