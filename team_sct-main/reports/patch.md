## 1. ExecSummary *(KR + ENG-KR one-liners)*

**재검증 판정: AMBER 유지 / Production 전 P0 4건 필수 패치.**
제공하신 BRIEF의 핵심 판단은 맞습니다. `ShipmentUnit`, `RoutingPattern`, `MilestoneEvent`, `JourneyLeg` 중심의 master spine은 원본 온톨로지와 정합하고, 팀원↔마일스톤 매핑도 실제 업무 흐름과 높게 일치합니다. Master spine은 `ShipmentUnit` 중심으로 Project, Package, PO, Material, CargoUnit, Container, PortCall, CustomsEntry, ReleaseOrder, WarehouseTask, SiteReceipt, Document, MilestoneEvent, Exception, Cost를 연결하도록 정의되어 있습니다. 

**차이점 1건:** `HVDCCodeTag` 등장 횟수는 로컬 원본 `CONSOLIDATED-00` 기준 literal count가 **7.00회**, combined corpus 기준 **8.00회**로 확인됩니다. 다만 graph상 `HVDCCodeTag`가 `deg=0`인 것은 사실이므로 P0 판정은 유지합니다.  

**ENG-KR one-liner:** Keep the AMBER verdict; the ontology spine is production-grade in concept, but graph extraction needs deduplication, noise filtering, and identifier-edge recovery before release.

---

## 2. Schema *(RDF/OWL + SHACL 요약)*

### 2.1 최종 판정표

| 항목                   |                                               재검증 결과 |    조치 등급 |
| -------------------- | ---------------------------------------------------: | -------: |
| Core spine 정합성       |           `ShipmentUnit` / `RoutingPattern` 중심 구조 정상 | **PASS** |
| 업무 role↔milestone 매핑 |                   역할분담 매트릭스와 graph member mapping 일치 | **PASS** |
| 중복 클래스               | SiteReceipt, PortCall, CommunicationEvent 등 중복 노드 확인 |   **P0** |
| 노이즈 오염               |      `.claude/settings.local.json` 3개 노드 graph 혼입 확인 |   **P0** |
| HVDCCodeTag 고립       |                           graph node 존재하나 edge 0.00건 |   **P0** |
| 커뮤니티 라벨              |                   modularity cluster와 비즈니스 라벨 일부 불일치 |   **P1** |
| INFERRED 15건         |                           일부 유용하나 `BL` 약어 충돌 등 검수 필요 |   **P1** |
| relation predicate   |               member→role에 `implements` 사용. 의미론상 부정확 |   **P2** |

### 2.2 Canonical class merge 규칙

중복 클래스는 단순 표시 중복이 아니라 **canonical IRI 지정 실패**로 보는 것이 맞습니다. 단, OWL 관점에서는 클래스에는 `owl:sameAs`보다 `owl:equivalentClass` 또는 canonical IRI merge가 적절합니다. `owl:sameAs`는 개체 instance 동일성에 쓰는 것이 안전합니다.

```turtle
# Class-level canonicalization
hvdc:SiteReceipt a owl:Class .
hvdc06:SiteReceipt owl:equivalentClass hvdc:SiteReceipt .

hvdc:PortCall a owl:Class .
hvdc07:PortCall owl:equivalentClass hvdc:PortCall .

hvdc:CommunicationEvent a owl:Class .
hvdc08:CommunicationEvent owl:equivalentClass hvdc:CommunicationEvent .

hvdc:ApprovalAction a owl:Class .
hvdc08:ApprovalAction owl:equivalentClass hvdc:ApprovalAction .

hvdc:AuditRecord a owl:Class .
hvdc08:AuditRecord owl:equivalentClass hvdc:AuditRecord .
```

Graph materialization 단계에서는 아래처럼 처리합니다.

```yaml
canonical_node_policy:
  class_merge:
    - SiteReceipt
    - PortCall
    - CommunicationEvent
    - ApprovalAction
    - AuditRecord
  concept_merge:
    - Any-key Resolution Flow
    - Any-key Identity Resolution
  document_concept_split:
    CONSOLIDATED-00 Master Ontology:
      keep_document_node: true
      keep_concept_node: false
      canonical_concept: hvdc:MasterOntologySpine
```

### 2.3 예상 node count

| 정제 항목                               |                        감소 |
| ----------------------------------- | ------------------------: |
| `.claude/settings.local.json` 노드 제거 |                     -3.00 |
| SiteReceipt 중복 merge                |                     -1.00 |
| PortCall 중복 merge                   |                     -1.00 |
| CommunicationEvent 중복 merge         |                     -1.00 |
| ApprovalAction 중복 merge             |                     -1.00 |
| AuditRecord 중복 merge                |                     -1.00 |
| Any-key Resolution 중복 merge         |                     -1.00 |
| Master Ontology 문서/개념 중복 정리         |                     -1.00 |
| **예상 결과**                           | **198.00 → 188.00 nodes** |

---

## 3. Integration *(Foundry↔ERP/WMS/ATLP/Invoice)*

### 3.1 Production 승급 기준

원본 온톨로지는 Foundry object/action 구조로 전환 가능한 수준입니다. Master ontology는 `Any-key in → Identifier resolution → ShipmentUnit → route/document/customs/warehouse/site/cost/exception full trace`를 핵심 설계로 둡니다. 

| Integration point   | 현재 graph 상태                                                      | Production 전 조치                                                    |
| ------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------ |
| ERP / PO / Material | `Package`, `PO`, `MaterialMaster`, `HVDCCodeTag` 개념 있음           | `HVDCCodeTag → Identifier → MaterialMaster/ShipmentUnit` edge 복구   |
| WMS                 | `WarehouseHandlingProfile`, `confirmedFlowCode`, M110/M111 구조 있음 | Flow Code boundary SHACL 강제                                        |
| ATLP / Customs      | BOE, DO, FANR, MOIAT, permit evidence 구조 있음                      | authority status는 RAG/SOP evidence로만 current fact 승격               |
| Port / OFCO         | `PortCall`, `PortServiceEvent`, `TariffRef` 있음                   | 중복 `PortCall` merge                                                |
| Invoice / CostGuard | `InvoiceLine`, `RateRef`, `CostGuardResult`, DEM/DET 있음          | MOSB charge evidence를 direct invoice edge가 아닌 evidence node 경유로 수정 |
| Communication       | `CommunicationEvent`, `ApprovalAction`, `AuditRecord` 있음         | evidence-only node로 고정, operational truth mutation 금지              |

`AGENTS.md`는 repository-wide rule로 `CONSOLIDATED-00`을 canonical semantic spine으로 지정하고, Flow Code를 warehouse handling classification으로 제한합니다. 따라서 graph patch도 이 precedence를 따라야 합니다. 

### 3.2 HVDCCodeTag edge 복구안

현재 P0의 핵심은 `HVDCCodeTag`가 graph에서 orphan이라는 점입니다. 원본 master는 `HVDCCodeTag`를 Master Data layer, Material identifier family, Parent-child hierarchy, Engineering tag register에 반복 배치합니다. 

권장 edge:

```turtle
hvdc:MaterialMaster hvdc:taggedBy hvdc:HVDCCodeTag .
hvdc:HVDCCodeTag hvdc:hasIdentifier hvdc:Identifier .
hvdc:Identifier hvdc:identifierScheme "HVDC_CODE" .
hvdc:Identifier hvdc:resolvesTo hvdc:MaterialMaster .
hvdc:CargoUnit hvdc:hasIdentifier hvdc:Identifier .
hvdc:CargoUnit hvdc:belongsToShipmentUnit hvdc:ShipmentUnit .
```

Graph patch 표현:

```json
[
  {
    "from": "concept_hvdc_code_tag",
    "to": "concept_identifier",
    "rel": "hasIdentifier",
    "conf": "PATCHED"
  },
  {
    "from": "concept_hvdc_code_tag",
    "to": "concept_material_master",
    "rel": "tags",
    "conf": "PATCHED"
  },
  {
    "from": "concept_material_master",
    "to": "concept_shipment_unit",
    "rel": "unitizedAs_or_tracesTo",
    "conf": "PATCHED"
  }
]
```

---

## 4. Validation *(SPARQL/RAG/Human-gate)*

### 4.1 P0 검증 결과

| P0             | 사용자 판정 | 재검증                                           | 최종        |
| -------------- | ------ | --------------------------------------------- | --------- |
| 중복 클래스         | 맞음     | 5개 exact duplicate + 2개 semantic duplicate 확인 | **P0 확정** |
| 노이즈 오염         | 맞음     | `.claude/settings.local.json` 3개 노드 확인        | **P0 확정** |
| HVDCCodeTag 고립 | 맞음     | graph `deg=0`; 원본에서는 핵심 identifier family     | **P0 확정** |
| production 차단  | 맞음     | Any-key resolution chain이 끊김                  | **P0 확정** |

### 4.2 P1/P2 검증 결과

| 항목                     | 재검증                                                           | 조치                                                      |
| ---------------------- | ------------------------------------------------------------- | ------------------------------------------------------- |
| 커뮤니티 라벨 오류             | `Cost & Invoice Allocation`에 port/material handling object 혼입 | 라벨 재계산 또는 business-domain override 필요                   |
| INFERRED 15건           | 15.00건 존재. 일부는 useful, 일부는 unsafe                             | `ACCEPT / REJECT / REWRITE` review table 필요             |
| `implements` predicate | member→role/concept에 사용됨                                      | `performsRole`, `responsibleFor`, `supportsProcess`로 분리 |

### 4.3 SHACL rules

```turtle
hvdc:NoClaudeNoiseShape
  a sh:NodeShape ;
  sh:targetClass hvdc:GraphNode ;
  sh:sparql [
    sh:message "Repository config files must not enter the logistics ontology graph." ;
    sh:select """
      SELECT ?this WHERE {
        ?this hvdc:sourcePath ?p .
        FILTER(CONTAINS(STR(?p), ".claude/"))
      }
    """ ;
  ] .
```

```turtle
hvdc:HVDCCodeTagConnectivityShape
  a sh:NodeShape ;
  sh:targetClass hvdc:HVDCCodeTag ;
  sh:property [
    sh:path hvdc:hasIdentifier ;
    sh:minCount 1 ;
    sh:message "HVDCCodeTag must connect to Identifier."
  ] ;
  sh:property [
    sh:path [ sh:inversePath hvdc:taggedBy ] ;
    sh:minCount 1 ;
    sh:message "HVDCCodeTag must be linked from MaterialMaster or CargoUnit."
  ] .
```

```turtle
hvdc:FlowCodeBoundaryShape
  a sh:NodeShape ;
  sh:targetSubjectsOf hvdc:confirmedFlowCode ;
  sh:class hvdc:WarehouseHandlingProfile ;
  sh:message "confirmedFlowCode is allowed only on WarehouseHandlingProfile." .
```

`CONSOLIDATED-02`도 `confirmedFlowCode`를 M110 WH Received 이후 생성되는 `WarehouseHandlingProfile`의 warehouse-only classification으로 제한합니다. 

### 4.4 SPARQL 검증 쿼리

```sparql
# P0-1: Duplicate class labels
SELECT ?label (COUNT(?node) AS ?cnt) (GROUP_CONCAT(?node; separator=", ") AS ?nodes)
WHERE {
  ?node rdfs:label ?label .
  FILTER(?label IN (
    "SiteReceipt",
    "PortCall",
    "CommunicationEvent",
    "ApprovalAction",
    "AuditRecord"
  ))
}
GROUP BY ?label
HAVING (?cnt > 1)
```

```sparql
# P0-2: Noise source path
SELECT ?node ?src
WHERE {
  ?node hvdc:sourcePath ?src .
  FILTER(CONTAINS(STR(?src), ".claude/"))
}
```

```sparql
# P0-3: HVDCCodeTag orphan
ASK {
  ?tag a hvdc:HVDCCodeTag .
  FILTER NOT EXISTS { ?tag ?p ?o }
  FILTER NOT EXISTS { ?s ?p2 ?tag }
}
```

```sparql
# P2: member implements predicate misuse
SELECT ?member ?target
WHERE {
  ?member a hvdc:TeamMember ;
          hvdc:implements ?target .
}
```

권장 replacement:

```sparql
DELETE { ?member hvdc:implements ?target . }
INSERT { ?member hvdc:performsRole ?target . }
WHERE {
  ?member a hvdc:TeamMember ;
          hvdc:implements ?target .
  ?target a hvdc:ActorRole .
}
```

---

## 5. Compliance *(Incoterms/MOIAT/FANR/DCD/ADNOC)*

Compliance 구조는 production 후보로 적합합니다. 단, graph extraction 결과를 그대로 쓰면 regulatory evidence와 operational truth가 혼동될 수 있으므로 evidence-only boundary를 강제해야 합니다.

| 영역             | 원본 설계                                                                                                  | graph patch 필요                                    |
| -------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| Document/OCR   | 문서는 `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`만 제공하고 operational route truth를 직접 쓰지 않음 | evidence-only edge 유지                             |
| Communication  | email/chat은 `CommunicationEvent`, `ApprovalAction`, `AuditRecord` evidence layer만 담당                   | duplicated communication classes merge            |
| Port/OFCO      | port는 `plannedRoutingPattern`, `declaredDestination` evidence를 기록하되 final route truth는 소유하지 않음         | `PortCall` merge 및 port→route evidence relabel    |
| Marine/MOSB    | MOSB는 `OffshoreStagingNode` / `MarineInterfaceNode`, warehouse 아님                                      | `MOSB Staging Task → InvoiceLine` direct edge 수정  |
| CostGuard      | Cost는 route/WH evidence를 읽고 `CostGuardResult` verdict만 소유                                              | MOSB charge evidence node 경유                      |
| Material chain | AGI/DAS site arrival은 MOSB/LCT chain evidence 없으면 block                                                | M115/M116/M117/M130 continuity 유지                 |

조직도에는 12.00명이 있고, graph member는 9.00명입니다. Eddel, Thushar, Shefeek 3.00명은 raw PII를 노출하지 않는 `ResourceRole` 또는 `SupportRole`로 처리해야 합니다. 조직도 자체도 tel/e-mail이 PII이므로 register write 전 마스킹을 요구합니다. 

---

## 6. Options ≥3 *(Pros/Cons/Cost/Risk/Time)*

### Option A — Minimal production patch

| 항목   | 내용                                                                           |
| ---- | ---------------------------------------------------------------------------- |
| 범위   | P0 4건만 패치: dedup, noise removal, HVDCCodeTag edge, unsafe inferred edge hold |
| Pros | 가장 빠름. 현재 graph asset 유지                                                     |
| Cons | predicate taxonomy와 community label은 일부 잔존                                   |
| Cost | 내부 작업 **8.00–16.00 hrs**, 외부비 **0.00 AED** 가정                                |
| Risk | Low-Medium                                                                   |
| Time | **1.00–2.00 days**                                                           |

### Option B — Semantic hardening patch

| 항목   | 내용                                                                           |
| ---- | ---------------------------------------------------------------------------- |
| 범위   | P0 + P1 + P2. class canonicalization, predicate migration, community relabel |
| Pros | ontology 품질 기준 충족. SPARQL/SHACL 운영 가능                                        |
| Cons | graph visual layout 재계산 필요                                                   |
| Cost | 내부 작업 **24.00–40.00 hrs**, 외부비 **0.00 AED** 가정                               |
| Risk | Low                                                                          |
| Time | **3.00–5.00 days**                                                           |

### Option C — Foundry-ready graph compiler

| 항목   | 내용                                                                                        |
| ---- | ----------------------------------------------------------------------------------------- |
| 범위   | extractor rule, canonical IRI resolver, source allowlist, SHACL CI gate, export bundle 생성 |
| Pros | 재발 방지. repository 변경 시 자동 품질검사 가능                                                         |
| Cons | 초기 compiler 작성 필요                                                                         |
| Cost | 내부 작업 **80.00–120.00 hrs**, 외부비 **0.00 AED** 가정                                           |
| Risk | Medium                                                                                    |
| Time | **2.00–3.00 weeks**                                                                       |

### Option D — Full operational pilot

| 항목   | 내용                                                        |
| ---- | --------------------------------------------------------- |
| 범위   | 실제 shipment 30.00~50.00건으로 ERP/WMS/Port/OCR/Invoice 연결 검증 |
| Pros | 업무 효율 KPI 산출 가능                                           |
| Cons | source-system field mapping과 data owner 승인 필요             |
| Cost | 내부/파트너 작업 **160.00–240.00 hrs**                           |
| Risk | Medium                                                    |
| Time | **4.00–6.00 weeks**                                       |

---

## 7. Roadmap *(Prepare→Pilot→Build→Operate→Scale + KPI)*

| Phase   |                   기간 | 실행 항목                                        |                               KPI |
| ------- | -------------------: | -------------------------------------------- | --------------------------------: |
| Prepare |   **1.00–2.00 days** | P0 patch 적용, graph 재생성                       |               P0 open = **0.00건** |
| Pilot   |   **3.00–5.00 days** | P1/P2 정리, inferred review, community relabel |       unsafe inferred = **0.00건** |
| Build   |  **2.00–3.00 weeks** | graph compiler + SHACL CI gate               |        validation p95 < **5.00s** |
| Operate |  **4.00–6.00 weeks** | live shipment 30.00~50.00건 연결                |   Any-key resolution ≥ **95.00%** |
| Scale   | **8.00–12.00 weeks** | ERP/WMS/ATLP/Invoice/Communication 연동        | manual reconciliation -**30.00%** |

역할분담 매트릭스는 Arvin M80~M92, Karthik M10~M30, Ken M100~M121, Haitham M115~M117, Roldan M130~M140, 차민규 M50~M130/M160, 정상욱 전체 overlay로 구간을 정의합니다. 이 구조는 graph member mapping의 업무 정합성을 뒷받침합니다. 

---

## 8. Automation notes *(RPA/LLM/Sheets/TG hooks)*

### 8.1 Graph compiler rule

```yaml
extractor_guard:
  source_allowlist:
    - "CONSOLIDATED-*.md"
    - "Team_역할분담_매트릭스.md"
    - "*_주요업무_분석.md"
    - "FMC_OrgChart_Data.json"
  source_denylist:
    - ".claude/**"
    - "*.local.json"
    - "node_modules/**"
    - ".git/**"

canonicalization:
  normalize_label: true
  normalize_source_path: true
  class_merge_strategy: "canonical_iri"
  instance_same_as_strategy: "owl:sameAs_only_for_instances"
  concept_match_strategy: "skos:exactMatch"

quality_gate:
  fail_on_orphan_core_identifier: true
  fail_on_duplicate_canonical_class: true
  fail_on_source_path_pii: true
  fail_on_flow_code_route_edge: true
```

### 8.2 INFERRED 15건 review matrix

| Inferred relation                     | 판정                    | 조치                                      |
| ------------------------------------- | --------------------- | --------------------------------------- |
| `confirmedFlowCode ≈ RoutingPattern`  | **REJECT**            | `boundary_constrained_by`로 변경           |
| `MOSB Staging Task → InvoiceLine`     | **REWRITE**           | `MarineChargeEvidence` 경유               |
| `Exit Pass / Gate Pass ≈ Backload`    | **REWRITE**           | `supportsProcess` 또는 `requiresExitPass` |
| `Shipment tracking ≈ Vessel tracking` | **ACCEPT with scope** | vessel leg에 한정                          |
| `AuditRecord ≈ ProofArtifact`         | **REWRITE**           | `recordsProofArtifact`                  |
| `Human-gate ≈ Evidence-only`          | **REJECT**            | governance principle 간 동일성 아님           |
| `WH Receipt/LPO ≈ LPO`                | **REWRITE**           | document/process distinction 필요         |

### 8.3 PII/source path masking

```python
def mask_source_path(path: str) -> str:
    path = path.replace("\\", "/")
    if "/Downloads/team/" in path:
        return path.split("/Downloads/team/")[-1]
    if path.startswith("C:/Users/"):
        return path.split("/")[-1]
    return path
```

---

## 9. QA checklist & Assumptions *(가정:)*

### 9.1 QA checklist

| Check                                     | 기준                                     |                             결과 |
| ----------------------------------------- | -------------------------------------- | -----------------------------: |
| Canonical spine follows `CONSOLIDATED-00` | required                               |                       **PASS** |
| Flow Code warehouse-only                  | required                               | **PASS in docs / PATCH graph** |
| MOSB non-warehouse                        | required                               |                       **PASS** |
| Evidence-only document/communication      | required                               | **PASS in docs / MERGE graph** |
| Duplicate canonical class count           | target 0.00                            |                  **FAIL → P0** |
| Noise node count                          | target 0.00                            |                  **FAIL → P0** |
| HVDCCodeTag degree                        | target ≥2.00                           |                  **FAIL → P0** |
| INFERRED unsafe count                     | target 0.00                            |                  **WARN → P1** |
| local path leakage                        | target 0.00                            |                  **WARN → P2** |
| org coverage                              | target 12.00/12.00 or scoped exception |           **WARN: 9.00/12.00** |

### 9.2 Patch acceptance criteria

Production 승급 조건은 아래 8.00개입니다.

1. `.claude/settings.local.json` 노드 **0.00건**.
2. duplicate canonical class **0.00건**.
3. `HVDCCodeTag` degree **≥2.00**.
4. `confirmedFlowCode → RoutingPattern` similarity edge **0.00건**.
5. `MOSB Staging Task → InvoiceLine` direct edge **0.00건**.
6. unsafe INFERRED relation **0.00건**.
7. `C:/Users/...` source path **0.00건**.
8. PII raw tel/e-mail graph exposure **0.00건**.

### 9.3 Assumptions

* 가정: 본 검증은 업로드된 `graph_pro.html`과 프로젝트 원본 markdown/json/pdf 기준입니다.
* 가정: 실제 ERP/WMS/ATLP/OFCO transaction dump는 제공되지 않았습니다.
* 가정: `HVDCCodeTag` count 차이는 단일 master file 기준과 combined corpus 기준의 차이로 봅니다.
* 가정: 담당자 이름은 업무 식별을 위해 유지하고, 전화/이메일은 PII로 graph write 금지합니다.
* 가정: Production은 Foundry object/action 또는 RDF triplestore 배포 전 상태를 의미합니다.

---

## 10. CmdRec *(1–3)*

```bash
/logi-meta dedup-nodes --canonical=CONSOLIDATED-00 --remove-noise --mask-paths
```

```bash
/logi-master customs hvdc-tag --repair-edge HVDCCodeTag:Identifier:MaterialMaster:ShipmentUnit
```

```bash
/visualize_data --type=flow --before=graph_pro.html --after=graph_pro_patched.html
```
