# SCT Graph AI-Ready Metadata Patch Summary

- Generated: `2026-06-14T17:35:31+04:00`
- Source: `sct.html`
- Output HTML: `sct_ai_ready.html`
- Verdict: `PASS`

## 1. ExecSummary *(KR + ENG-KR one-liners)*

기존 SCT 그래프는 사람용 vis-network 관계도였으나, 이번 패치로 AI가 업무 의미를 읽을 수 있도록 `node_type`, `edge_type`, `status`, `evidence`, `business_rule`, `last_updated`, `next_action`을 전 노드/엣지에 추가했다.

비즈니스 임팩트는 그래프 해석 오류 감소, 문서·통관·창고·MOSB·비용·보고 객체의 owner boundary 명확화, Foundry Ontology/Action 연계 전 검증 가능성 확보다. KPI 기준으로 Node Metadata Coverage = `100.00%`, Edge Metadata Coverage = `100.00%`, Validation p95 target < `5.00s`로 설계했다.

**ENG-KR one-liner:** The graph is now AI-readable: visual nodes remain for humans, while JSON-LD/Graph JSON carries operational semantics for machines.

## 2. Schema (RDF/OWL + SHACL 요약)

### Required node fields

```json
{
  "id": "concept_boe",
  "label": "BOE (Bill of Entry)",
  "node_type": "BOEDocument",
  "status": "PASS|AMBER|FAIL|ZERO",
  "evidence": ["source:..."],
  "business_rule": "Document/OCR evidence only...",
  "last_updated": "2026-06-14T17:35:31+04:00",
  "next_action": "Check BOE number..."
}
```

### Required edge fields

```json
{
  "from": "concept_boe",
  "to": "concept_customs_clearance",
  "edge_type": "references",
  "status": "PASS|AMBER",
  "evidence": ["source_node:...", "target_node:..."],
  "business_rule": "Edge relationship must state edge_type and confidence..."
}
```

### Core rules

1. Route truth = `ShipmentRoutingPattern + JourneyStage + JourneyLeg + MilestoneEvent`.
2. `confirmedFlowCode` = `WarehouseHandlingProfile` only.
3. MOSB = `OffshoreStagingNode / MarineInterfaceNode`, not Warehouse.
4. Documents/Port/Cost/Communication = evidence/provider layer, not owner of operational truth.
5. Inferred edges = `AMBER` until reviewed.

## 3. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

| Source | Foundry object/link target | Write-back rule |
|---|---|---|
| `graph_data.json` | Ontology Object import staging | Read-only semantic load |
| `graph_data.jsonld` | RDF/KG loader | Preserve `@id`, `@type`, provenance |
| `audit_log.json` | AuditRecord / ProofArtifact | Append-only |
| `sct_ai_ready.html` | Dashboard / graph app | Human view + AI metadata panel |
| `sct_ai_report.xlsx` | Ops QA workbook | Report-only |

## 4. Validation (SPARQL/RAG/Human-gate)

### SPARQL-style checks

```sparql
ASK { ?n hvdc:nodeType ?t ; hvdc:status ?s ; hvdc:evidence ?ev ; hvdc:businessRule ?r . }
ASK { ?e hvdc:edgeType ?et ; hvdc:fromNode ?from ; hvdc:toNode ?to ; hvdc:status ?s . }
```

### Coverage

| Node status | Count |
|---|---:|
| AMBER | 27.00 |
| PASS | 164.00 |

| Edge status | Count |
|---|---:|
| AMBER | 8.00 |
| PASS | 278.00 |

Human-gate remains required for AMBER nodes/edges, regulated documents, high-value cost cases, and operational mutation.

## 5. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

- Incoterms, MOIAT/FANR/DCD/ADNOC nodes are modeled as regulatory/compliance evidence anchors.
- BOE/DO/BL/CI/PL remain document evidence unless a validated domain transaction exists.
- Gate/permit/compliance nodes are marked AMBER when they represent controls requiring evidence before write-back.

## 6. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Pros | Cons | Cost | Risk | Time |
|---|---|---|---:|---|---:|
| A. HTML-only metadata | Quick deployment | External KG loader still parses JS | 0.00 AED | Low | 1.00h |
| B. HTML + JSON/JSON-LD bundle | Best balance; AI and systems can parse | Requires file governance | 0.00 AED | Low | 2.00h |
| C. Foundry Ontology import | Full operationalization | Requires Object/Link schema approval | TBD | Medium | 3.00d |
| D. SHACL validation service | Automated guard | Needs CI/CD runner | TBD | Low | 2.00d |

## 7. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Output | KPI |
|---|---|---|
| Prepare | Graph JSON/JSON-LD/schema | Metadata coverage `100.00%` |
| Pilot | Foundry staging Object/Link mapping | Key resolution ≥ `95.00%` |
| Build | SHACL/SPARQL validation action | Validation p95 < `5.00s` |
| Operate | Dashboard + AMBER queue | Human-gate leakage `0.00건` |
| Scale | ERP/WMS/ATLP/Invoice connectors | Link coverage ≥ `95.00%` |

## 8. Automation notes (RPA/LLM/Sheets/TG hooks)

- RPA: `graph_data.json` → Foundry staging dataset upload.
- LLM: parse `business_rule` + `evidence` + `next_action` for node-level explanation.
- Sheets/XLSX: `sct_ai_report.xlsx` provides node/edge audit tables.
- Telegram/Teams hook: trigger alerts on AMBER/FAIL/ZERO status.

## 9. QA checklist & Assumptions(가정:)

| Check | Result |
|---|---|
| Nodes carry required AI metadata | PASS |
| Edges carry required AI metadata | PASS |
| JSON-LD export generated | PASS |
| Graph JSON export generated | PASS |
| Audit log generated | PASS |
| HTML tooltip evidence added | PASS |
| Operational truth not invented from graph | PASS |

가정: 현 그래프는 ontology/team-role/evidence graph이며, 특정 선적의 live BOE/DO/Invoice 상태를 확정하는 source-of-truth가 아니다.

## 10. CmdRec (1–3)

```text
/switch_mode LATTICE + /logi-master report --deep --KRsummary
/logi-master cert-chk --deep --KRsummary
/logi-master invoice-audit --AEDonly
```
