---
title: "HVDC Operations Management & RoutingPattern Analytics Ontology — Consolidated"
type: "ontology-design"
domain: "operations-management"
sub-domains:
  - operations-analytics
  - routing-pattern-kpi
  - warehouse-stock-reporting
  - site-delivery-analytics
  - marine-bulk-vessel-analytics
  - cost-and-sqm-reporting
  - exception-dashboard
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "operations analytics, reporting, KPI, dashboard, and data-mapping extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - GS1-EPCIS-CBV
  - DCSA-Track-and-Trace
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
source_files:
  - 2_EXT-05-hvdc-ops-management.md
  - legacy_operations_excel_mapping_notes
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-08-communication.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
semantic_patch:
  - "Operations consumes canonical ShipmentRoutingPattern, JourneyStage, JourneyLeg, MilestoneEvent, StockSnapshot, SiteReceipt, CostGuardResult, and CommunicationEvent; it does not redefine them."
  - "WarehouseHandlingProfile.confirmedFlowCode remains warehouse-only and is used only as WH evidence or storage analytics dimension."
  - "End-to-end routing KPI uses ShipmentRoutingPattern, not legacy warehouse route-code language."
  - "MOSB is OffshoreStagingNode / MarineInterfaceNode; operations may report MOSB dwell and marine readiness but shall not classify MOSB as Warehouse."
  - "Bulk/vessel/OOG analytics consume CONSOLIDATED-04 marine events and CONSOLIDATED-06 material milestones; execution truth remains in those domains."
  - "Excel/ERP rows become OperationDataset, OperationRecord, MappingRule, AnalyticsRun, KPIObservation, and ReportArtifact."
---

# hvdc-operations · CONSOLIDATED-09

## 1. ExecSummary

`CONSOLIDATED-09`는 HVDC Logistics KG의 **operations analytics / reporting / KPI extension**이다. Excel, ERP, WMS, ATLP, LDG/OCR, Port, Cost, Marine, Communication 데이터를 `OperationDataset`, `OperationRecord`, `AnalyticsRun`, `KPIObservation`, `OperationalSnapshot`, `ReportArtifact`로 정규화하여 운영 가시성을 제공한다.

비즈니스 임팩트는 **RoutingPattern 기반 물류 효율 분석**, **WH/Site/MOSB/Marine stock·dwell·dispatch 현황 통합**, **SQM/PKG/CBM 이중계산 방지**, **월별 보고 자동화**, **exception/action backlog를 통한 지연 비용 감소**이다.

기술 해법은 canonical object를 재정의하지 않고 consume-only로 읽는 것이다. 전체 여정은 `ShipmentRoutingPattern`, 상태 전이는 `MilestoneEvent`, 창고 내부 처리는 `WarehouseHandlingProfile`, 커뮤니케이션 증빙은 `CommunicationEvent`, 비용 verdict는 `CostGuardResult`가 소유한다.

KPI 목표는 `RoutingPatternCoverage ≥ 95.00%`, `StockSnapshotAccuracy ≥ 99.00%`, `DoubleCountLeakage = 0.00건`, `ReportRefreshSLA ≤ 4.00h`, `Validation p95 < 5.00s`이다.

**ENG-KR one-liner:** Operations consumes the logistics twin for analytics and reporting; it does not own route truth, warehouse handling, marine execution, cost verdicts, or communication evidence.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-09` owns **analytics, reporting, KPI observations, dashboard views, dataset mappings, and report artifacts** only.
3. Operations consumes `ShipmentRoutingPattern`, `JourneyStage`, `JourneyLeg`, `MilestoneEvent`, `StockSnapshot`, `WarehouseTask`, `SiteReceipt`, `MarineEvent`, `PortServiceEvent`, `CostGuardResult`, and `CommunicationEvent`.
4. Operations shall not redefine the route dictionary, milestone dictionary, identity policy, WHP algorithm, CostGuard band, or communication evidence model.
5. `WarehouseHandlingProfile.confirmedFlowCode` is warehouse-only. Operations may use WHP as a warehouse evidence dimension but cannot calculate or assign it.
6. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`. Operations may report MOSB dwell, staging readiness, marine interface backlog, and AGI/DAS route compliance.
7. Excel/DataFrame row status is evidence for analytics. It cannot override operational truth without source-system reconciliation and an approved domain action.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-09 | Delegated / excluded |
|---|---|---|
| Dataset normalization | Header cleanup, date normalization, key extraction, mapping rules | Source-system master ownership |
| KPI observation | Route, stock, dwell, site receipt, exception, cost, SLA metrics | Domain-specific operational decision |
| Dashboard and reports | 5-sheet summary, 27-sheet snapshots, route KPI, stock aging, SQM billing view | Contractual invoice approval |
| WH/Site analytics | WH in/out, stock balance, site arrival, GRN/POD status | WHP algorithm and SiteReceipt transaction creation |
| MOSB/Marine analytics | MOSB dwell, M115/M116/M117/M130 continuity, LCT utilization | Marine execution approval and stability/lashing truth |
| Bulk/vessel analytics | Bulk cargo summary, vessel trip KPI, heavy-lift dashboard | OOG/marine engineering calculation |
| Cost analytics | CostGuard summary, invoice aging, DEM/DET risk view | RateRef ownership and payment approval |
| Communication analytics | Open actions, SLA breach, approval evidence completeness | Message ontology ownership |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with operations | Not allowed in CONSOLIDATED-09 |
|---|---|---|
| Master spine | Consume identity policy, route, stage, milestone, data layer separation | Redefine core classes |
| Infrastructure | Consume `LocationNode`, `Site`, `Warehouse`, `OffshoreStagingNode`, `Port` | Reclassify MOSB as warehouse |
| Warehouse | Consume `WarehouseEvent`, `StockSnapshot`, `WarehouseHandlingProfile` evidence | Assign warehouse handling class |
| Document/OCR | Consume `VerificationResult`, `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` | Treat OCR evidence as final transaction truth |
| Marine/Bulk | Consume M115/M116/M117, `MarineEvent`, LCT utilization | Replace marine execution with dashboard row |
| Cost | Consume `Invoice`, `CostGuardResult`, DEM/DET clock | Own RateRef or CostGuard verdict |
| Material handling | Consume M90→M160 timeline and site receipt | Create site receipt from spreadsheet alone |
| Port | Consume `PortCall`, `ServiceEvent`, `plannedRoutingPattern`, release evidence | Own port service truth |
| Communication | Consume open action/SLA metrics and approval evidence completeness | Redefine communication classes |

### 2.4 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Route KPI by warehouse route code | KPI by `ShipmentRoutingPattern` | Replace in dashboard and SPARQL |
| Pre-arrival represented as warehouse class | `RoutingPattern = PRE_ARRIVAL` or `JourneyStage = PLANNING/PORT_ENTRY` | Use master route/stage |
| MOSB listed as warehouse | `OffshoreStagingNode` / `MarineInterfaceNode` with `OperationalSnapshot` | Report separately from WH stock |
| Spreadsheet status overrides shipment | `OperationRecord` evidence + reconciliation result | Require source-system action |
| Bulk/vessel execution truth in Ops | `MarineEvent` / `BargeOperation` from CONSOLIDATED-04 | Ops reports only |
| Cost center decision in Ops | `CostGuardResult` / `CostAllocation` from CONSOLIDATED-05 | Ops aggregates only |

---

## 3. Schema (RDF/OWL + SHACL 요약)

### 3.1 Operations Ontology Layer

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Dataset | `OperationDataset`, `OperationRecord`, `SourceRow`, `DataMappingRule`, `HeaderNormalizationRule` | Ingested spreadsheet/API rows and mapping logic |
| Analytics | `AnalyticsRun`, `KPIObservation`, `MetricDefinition`, `DashboardView`, `ReportArtifact` | Analytical outputs and dashboards |
| Snapshot | `OperationalSnapshot`, `StockSnapshotView`, `RouteSnapshot`, `AgingSnapshot`, `CostSnapshot` | Periodic state view |
| Route analytics | `RoutingPatternKPI`, `JourneyStageKPI`, `MilestoneCoverageMetric` | End-to-end visibility metrics |
| Warehouse analytics | `WarehouseStockKPI`, `DwellMetric`, `CapacityMetric`, `DispatchMetric` | WH inventory and movement reporting |
| Site analytics | `SiteReceiptKPI`, `GRNCompletenessMetric`, `OSDMetric`, `IssueMetric` | Site delivery and closeout reporting |
| Marine analytics | `MOSBDwellMetric`, `LCTUtilizationMetric`, `MarineReadinessMetric` | Offshore staging and LCT reporting |
| Cost analytics | `CostGuardSummary`, `InvoiceAgingMetric`, `DEMDETExposureMetric`, `SQMBillingMetric` | Cost and billing analytics |
| Exception analytics | `ExceptionBacklogMetric`, `NCRMetric`, `ClaimAgingMetric`, `SLAActionMetric` | Risk and unresolved action reporting |
| Evidence | `OperationEvidenceLink`, `ReconciliationResult`, `DataQualityFinding`, `AuditRecord` | Quality and lineage |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `OperationDataset` | `datasetId`, `sourceSystem`, `datasetType`, `extractDate`, `rowCount` | `hasSourceRow`, `usesMappingRule`, `producesAnalyticsRun` | Excel/API input container |
| `OperationRecord` | `recordId`, `sourceRowId`, `recordType`, `eventDate`, `quantityPkg`, `volumeCbm`, `areaSqm` | `resolvesToShipmentUnit`, `referencesLocation`, `evidencesMilestone` | Row-level normalized record |
| `DataMappingRule` | `ruleId`, `sourceColumn`, `targetProperty`, `transformType`, `version` | `appliesToDataset`, `mapsToClass` | Column mapping and normalization |
| `AnalyticsRun` | `runId`, `runAt`, `runType`, `sourceDatasetHash`, `validationStatus` | `usesDataset`, `generatesKPI`, `generatesReport` | Reproducible analytics execution |
| `KPIObservation` | `kpiId`, `metricCode`, `metricValue`, `metricUnit`, `observedAt`, `periodStart`, `periodEnd` | `computedFrom`, `forDomain`, `forLocation` | DQV-style metric |
| `OperationalSnapshot` | `snapshotId`, `snapshotDate`, `snapshotType`, `cutoffAt` | `summarizesShipmentUnit`, `summarizesLocation`, `derivedFromRun` | Monthly/daily state |
| `ReportArtifact` | `reportId`, `reportType`, `generatedAt`, `artifactHash`, `sheetCount` | `derivedFromRun`, `includesKPI` | Excel/PDF/dashboard output |
| `ReconciliationResult` | `resultId`, `checkCode`, `status`, `deltaPct`, `findingCount` | `checksRecord`, `checksTargetObject`, `opensFinding` | Data quality validation |
| `DataQualityFinding` | `findingId`, `severity`, `findingType`, `detectedAt`, `ownerDomain` | `aboutRecord`, `aboutTargetObject`, `requiresAction` | Exception list |
| `OperationEvidenceLink` | `linkId`, `evidenceType`, `confidence`, `sourceRef` | `linksRecordToObject`, `derivedFromDocument`, `derivedFromCommunication` | Evidence bridge |

### 3.3 Object Properties

| Property | Domain → Range | Cardinality | Purpose |
|---|---|---:|---|
| `resolvesToShipmentUnit` | `OperationRecord → ShipmentUnit` | 0..1 | Any-key identity join |
| `evidencesMilestone` | `OperationRecord → MilestoneEvent` | 0..n | Row evidence for status transition |
| `referencesLocation` | `OperationRecord → LocationNode` | 0..n | Port/WH/MOSB/site reference |
| `usesMappingRule` | `OperationDataset → DataMappingRule` | 1..n | Mapping reproducibility |
| `computedFrom` | `KPIObservation → AnalyticsRun/OperationalSnapshot` | 1..n | KPI provenance |
| `generatesReport` | `AnalyticsRun → ReportArtifact` | 0..n | Report lineage |
| `opensFinding` | `ReconciliationResult → DataQualityFinding` | 0..n | Quality exception |
| `requiresAction` | `DataQualityFinding → ActionRequest` | 0..1 | Communication action hook |

### 3.4 Data Properties

| Property | Range | Rule |
|---|---|---|
| `hasRoutingPattern` | SKOS enum | Values match master `ShipmentRoutingPattern` only |
| `eventDate` | `xsd:dateTime` | ISO-8601; no ambiguous local dates |
| `quantityPkg` | decimal | `>= 0.00`; integer package count when package unit applies |
| `volumeCbm` | decimal | `>= 0.00`; preserve original unit evidence |
| `areaSqm` | decimal | `>= 0.00`; mandatory for SQM billing rows |
| `deltaPct` | decimal | Store as percentage with 2.00 decimal precision |
| `validationStatus` | SKOS enum | `PASS`, `WARN`, `HIGH`, `CRITICAL`, `BLOCKED` |
| `snapshotDate` | `xsd:date` | Monthly snapshot uses cutoff date, not generation date |

### 3.5 Canonical KPI Dictionary

| KPI code | Formula | Target |
|---|---|---:|
| `OPS_ROUTE_COVERAGE` | ShipmentUnits with valid `hasRoutingPattern` / total ShipmentUnits | ≥ 95.00% |
| `OPS_MILESTONE_COVERAGE` | ShipmentUnits with required milestones / total ShipmentUnits | ≥ 90.00% |
| `OPS_STOCK_ACCURACY` | matched stock records / total stock records | ≥ 99.00% |
| `OPS_DOUBLECOUNT_LEAKAGE` | duplicate counted records after reconciliation | 0.00건 |
| `OPS_AGIDAS_GATE_PASS` | AGI/DAS site arrivals with M115/M116/M117 evidence / total AGI/DAS arrivals | 100.00% |
| `OPS_REPORT_REFRESH_SLA` | report generation age | ≤ 4.00 hrs |
| `OPS_DEMDET_RISK` | release-to-gateout breaches / total release events | ≤ 10.00% |
| `OPS_ACTION_CLOSURE` | closed action requests / total action requests | ≥ 90.00% |
| `OPS_VALIDATION_LATENCY` | validation p95 | < 5.00s |

---

## 4. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 4.1 Source-to-Object Mapping

| Source | Consumed data | Operations object | Target domain owner |
|---|---|---|---|
| ERP / Procurement | PO, package, material, vendor, delivery plan | `OperationDataset`, `OperationRecord` | Master / procurement source |
| WMS | M110/M111/M120/M121, stock, zone/bin, WHP evidence | `WarehouseStockKPI`, `StockSnapshotView` | CONSOLIDATED-02 |
| ATLP / Customs | BOE, DO, release, gate-out, M90/M92/M100 | `MilestoneCoverageMetric`, `DEMDETExposureMetric` | Master / Material / Port |
| LDG/OCR | VerificationResult, document discrepancy, route/destination evidence | `DataQualityFinding`, `OperationEvidenceLink` | CONSOLIDATED-03 |
| Marine / Barge | M115/M116/M117, LCT trip, lashing/stability readiness | `MOSBDwellMetric`, `LCTUtilizationMetric` | CONSOLIDATED-04 |
| Invoice / CostGuard | Invoice aging, cost bands, DEM/DET, SQM charges | `CostGuardSummary`, `SQMBillingMetric` | CONSOLIDATED-05 |
| Material Handling | M90→M160 custody chain, site receipt, OSD/NCR/Claim | `SiteReceiptKPI`, `ExceptionBacklogMetric` | CONSOLIDATED-06 |
| Port / OFCO | PortCall, ServiceEvent, TariffRef, release evidence | `PortServiceKPI`, `ReleaseDelayMetric` | CONSOLIDATED-07 |
| Communication | Open actions, approval evidence, SLA breach | `SLAActionMetric`, `ApprovalCompletenessMetric` | CONSOLIDATED-08 |

### 4.2 Data Pipeline

```text
1. Ingest
   - Read Excel/API rows.
   - Preserve source file hash, sheet name, row number, extraction date.

2. Normalize
   - Trim whitespace, normalize date formats, resolve column aliases.
   - Convert quantities to canonical unit while preserving original value.

3. Map
   - Apply DataMappingRule version.
   - Create OperationRecord and candidate target object links.

4. Resolve
   - Run Any-key identity resolution.
   - Link records to ShipmentUnit, Document, WarehouseTask, SiteReceipt, Invoice, Exception.

5. Validate
   - Run SHACL/SPARQL rules.
   - Create ReconciliationResult and DataQualityFinding.

6. Compute
   - Generate OperationalSnapshot and KPIObservation.

7. Publish
   - Create ReportArtifact or dashboard view.
   - Push open findings to Communication ActionRequest when needed.
```

### 4.3 Two-track Date Model

Operations supports a two-track date model but does not overwrite the canonical event timeline.

| Track | Source columns | Canonical target | Reporting output |
|---|---|---|---|
| WH track | DSV Indoor, Outdoor, AAA, MZP, WH Received, WH Dispatch | `WarehouseEvent`, `StockSnapshot`, `WarehouseTask` | WH in/out, dwell, stock aging |
| Site track | AGI, DAS, MIR, SHU, site receipt date, POD/GRN | `SiteReceipt`, `MilestoneEvent` | Site arrival, receipt compliance |
| MOSB track | MOSB staging date, LCT load/sail-away, offshore handover | `OffshoreStagingNode`, `MarineEvent`, `MilestoneEvent` | MOSB dwell, AGI/DAS gate |
| Cost track | invoice date, draft/approved amount, DEM/DET clock | `Invoice`, `CostGuardResult`, `DEMDETClock` | Cost aging and risk |
| Communication track | request date, approval date, escalation due date | `ActionRequest`, `ApprovalAction`, `SLAClock` | Open action and SLA report |

### 4.4 5-Sheet Standard Report

| Sheet | Grain | Metrics | Source objects |
|---|---|---|---|
| `01_RoutingPattern` | ShipmentUnit | route pattern, stage, current location, exception status | ShipmentUnit, JourneyStage, MilestoneEvent |
| `02_WH_Monthly` | Warehouse x month | inbound, outbound, stock, dwell, capacity | WarehouseEvent, StockSnapshot |
| `03_Site_Monthly` | Site x month | arrivals, POD, GRN, OSD, NCR | SiteReceipt, InspectionEvent |
| `04_PreArrival` | ShipmentUnit | ETA, doc readiness, release blockers | PortCall, Document, CustomsEntry |
| `05_All_Transactions` | OperationRecord | source row, target object, validation status | OperationDataset, OperationRecord |

### 4.5 27-Sheet Snapshot Pattern

`OperationalSnapshot` can generate detailed monthly snapshots by location group and domain. The B5 date or equivalent cutoff cell is treated as `snapshotDate`, while actual generation timestamp is `generatedAt`.

| Snapshot group | Example sheets | Control |
|---|---|---|
| WH stock | Indoor, Outdoor, AAA, MZP, DG, OOG | WHP evidence only |
| Site | AGI, DAS, MIR, SHU | SiteReceipt evidence |
| MOSB / marine | MOSB staging, LCT trips, offshore pending | OffshoreStagingNode / MarineEvent |
| Cost | Invoice aging, DEM/DET, SQM billing | CostGuard evidence |
| Exception | OSD, NCR, claim, open communication actions | Exception + CommunicationEvent |

---

## 5. Validation (SPARQL/RAG/Human-gate)

### 5.1 SHACL — OperationRecord identity and date

```turtle
ops:OperationRecordShape a sh:NodeShape ;
  sh:targetClass ops:OperationRecord ;
  sh:property [ sh:path ops:recordId ; sh:minCount 1 ; sh:maxCount 1 ] ;
  sh:property [ sh:path ops:sourceRowId ; sh:minCount 1 ; sh:maxCount 1 ] ;
  sh:property [ sh:path ops:eventDate ; sh:datatype xsd:dateTime ; sh:minCount 1 ] ;
  sh:property [ sh:path ops:quantityPkg ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ] .
```

### 5.2 SHACL — RoutingPattern controlled vocabulary

```turtle
ops:RoutingPatternObservationShape a sh:NodeShape ;
  sh:targetClass ops:OperationRecord ;
  sh:property [
    sh:path ops:hasRoutingPattern ;
    sh:in ( "PRE_ARRIVAL" "DIRECT" "WH_ONLY" "MOSB_DIRECT" "WH_MOSB" "MIXED" ) ;
  ] .
```

### 5.3 SPARQL — Operations must not redefine core truth

```sparql
SELECT ?opsObj ?badPredicate WHERE {
  ?opsObj a ?opsClass .
  FILTER(?opsClass IN (ops:OperationRecord ops:KPIObservation ops:OperationalSnapshot))
  ?opsObj ?badPredicate ?value .
  FILTER(?badPredicate IN (
    wh:confirmedFlowCode,
    cost:costGuardVerdict,
    marine:stabilityApprovalStatus,
    comm:decision
  ))
}
```

Expected result: **0.00 rows**. Operations reads those fields from owners.

### 5.4 SPARQL — Missing route pattern coverage

```sparql
SELECT ?su WHERE {
  ?su a hvdc:ShipmentUnit .
  FILTER NOT EXISTS { ?su hvdc:hasRoutingPattern ?pattern }
}
```

Metric: `OPS_ROUTE_COVERAGE`. Target: **≥ 95.00%**.

### 5.5 SPARQL — AGI/DAS offshore gate

```sparql
SELECT ?su ?site WHERE {
  ?su hvdc:finalDestination ?site ;
      hvdc:hasMilestone hvdc:M130 .
  FILTER(?site IN ("AGI", "DAS"))
  FILTER NOT EXISTS { ?su hvdc:hasMilestone hvdc:M115 }
  FILTER NOT EXISTS { ?su hvdc:hasHumanGatedException ?ex }
}
```

Expected result: **0.00 rows** unless approved exception exists.

### 5.6 SPARQL — WH stock double-count candidate

```sparql
SELECT ?su ?location ?date (COUNT(?record) AS ?cnt) WHERE {
  ?record a ops:OperationRecord ;
          ops:resolvesToShipmentUnit ?su ;
          ops:referencesLocation ?location ;
          ops:eventDate ?date ;
          ops:recordType "STOCK_IN" .
}
GROUP BY ?su ?location ?date
HAVING (COUNT(?record) > 1)
```

Expected result: **0.00 rows** after deduplication.

### 5.7 SPARQL — M92 to M100 DEM/DET risk

```sparql
SELECT ?su ?releasedAt ?gateOutAt WHERE {
  ?su hvdc:hasMilestoneEvent ?m92 .
  ?m92 hvdc:milestoneCode "M92" ;
       hvdc:actualDt ?releasedAt .
  OPTIONAL {
    ?su hvdc:hasMilestoneEvent ?m100 .
    ?m100 hvdc:milestoneCode "M100" ;
          hvdc:actualDt ?gateOutAt .
  }
  FILTER(!BOUND(?gateOutAt) || (?gateOutAt > ?releasedAt + "PT72H"^^xsd:duration))
}
```

Creates DEM/DET risk KPI only; Cost domain owns charge audit.

### 5.8 SPARQL — Communication open action effect on operations

```sparql
SELECT ?target (COUNT(?request) AS ?openActions) WHERE {
  ?request a comm:ActionRequest ;
           comm:requestStatus "OPEN" ;
           comm:targetObjectRef ?target .
}
GROUP BY ?target
```

Used for dashboard backlog. Communication domain owns the action object.

### 5.9 RAG Check Rules

| RAG item | Trigger | Required action |
|---|---|---|
| Regulation / permit status appears in Ops data | customs, FANR, DCD, ADNOC, CICPA, GatePass fields | Re-check current evidence in document/compliance owner |
| Cost value changes | invoice, DEM/DET, SQM billing, overage | Reconcile with CostGuard before dashboard approval |
| Marine readiness status appears | M115/M116/M117, stability, lashing, weather | Link to CONSOLIDATED-04 evidence |
| PII appears in source report | phone/e-mail or raw contact details | Mask or exclude before report artifact |
| Spreadsheet row conflicts with system event | date/status discrepancy | Create `DataQualityFinding` and action request |

### 5.10 Human-gate

Human-gate is required when:

| Condition | Owner |
|---|---|
| KPI output would trigger operational state change | Target domain owner |
| Cost exposure > 100,000.00 AED | Cost owner |
| AGI/DAS M130 lacks MOSB/LCT evidence | Material + Marine owner |
| Document evidence contradicts ERP/WMS event | LDG + target domain owner |
| Report contains PII or restricted site access info | Data governance owner |
| Dashboard suggests compliance decision | Compliance owner |

---

## 6. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 6.1 Compliance Role

`CONSOLIDATED-09` provides analytics views and exception lists. It does not create compliance truth. Current authority status must remain with compliance/document owners and be refreshed through RAG and Human-gate when action date matters.

| Area | Ops metric | Owner |
|---|---|---|
| Incoterms 2020 | Cost/risk responsibility summary by lane | Cost / Contract |
| MOIAT / Customs | BOE readiness, M92 release, M100 gate-out risk | Customs / Document / Material |
| FANR | certificate evidence completeness | Compliance / Document |
| DCD / DG | DG storage/reporting risk | Warehouse / HSE / Document |
| ADNOC / CICPA | GatePass, offshore/site access readiness | Material / Site / Port |
| Port authority | PortCall / ServiceEvent delay and release blockers | Port operations |
| Privacy | report artifact PII leakage | Communication / Data governance |

### 6.2 Report Publication Guard

1. Every report artifact stores `generatedAt`, `sourceDatasetHash`, `mappingVersion`, and `validationStatus`.
2. Any report containing unresolved high-risk findings is marked `BLOCKED`.
3. PII-bearing source columns are excluded or masked before dashboard publication.
4. Cost dashboards show CostGuard result as consumed evidence; they do not change verdict.
5. Regulatory dashboards show evidence completeness, not authority approval as a fact unless a valid `ApprovalAction` exists.

---

## 7. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Scope | Pros | Cons | Est. cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A | Lite Ops Mapping | Fast Excel-to-KPI mapping; preserves current reporting | Limited semantic validation | 40,000.00 AED | MEDIUM | 2.00 weeks |
| B | Full Ops KG Validation | RDF/SHACL/SPARQL validation, reproducible analytics | Requires mapping governance | 95,000.00 AED | MEDIUM | 5.00 weeks |
| C | Ops Twin Dashboard | Route/stock/site/MOSB/cost/action integrated dashboard | More integrations and owner review | 150,000.00 AED | HIGH | 7.00 weeks |
| D | Predictive Ops Control | ETA MAPE, DEM/DET prediction, exception forecasting | Needs historical data quality and model governance | 230,000.00 AED | HIGH | 10.00 weeks |

Recommended baseline: **Option B** for stable validation and monthly reporting. Use **Option C** when operations needs daily cross-domain control.

---

## 8. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Duration | Work package | KPI |
|---|---:|---|---|
| Prepare | 1.00 week | Confirm dataset inventory, header dictionary, owner matrix, mapping version | Dataset registry coverage ≥ 95.00% |
| Pilot | 2.00 weeks | Build 5-sheet report and route/stock/site KPI with sample data | RoutingPattern calculation consistency = 100.00% |
| Build | 3.00 weeks | Add RDF mapping, SHACL/SPARQL validation, snapshot generation | Validation pass rate ≥ 98.00% |
| Operate | Ongoing | Daily dashboard, weekly exception review, monthly closeout report | ReportRefreshSLA ≤ 4.00 hrs |
| Scale | 4.00 weeks | Add predictive ETA, DEM/DET risk, action closure automation | ETA MAPE ≤ 12.00% |

---

## 9. Automation notes (RPA/LLM/Sheets/TG hooks)

### 9.1 Foundry Functions

| Function | Input | Output | Guard |
|---|---|---|---|
| `ingestOperationDataset` | Excel/API payload | `OperationDataset` | Hash and schema check |
| `normalizeOperationRecord` | source row | `OperationRecord` | Header and date normalization |
| `resolveOperationAnyKey` | OperationRecord keys | target object links | Identity confidence threshold |
| `computeRoutingPatternKPI` | ShipmentUnit + milestone events | `RoutingPatternKPI` | Master route dictionary only |
| `buildStockSnapshotView` | Warehouse events + stock records | `StockSnapshotView` | Double-count check |
| `computeMOSBDwellMetric` | M115/M116/M117 events | `MOSBDwellMetric` | MOSB offshore-staging model |
| `computeCostGuardSummary` | CostGuardResult + invoice aging | `CostGuardSummary` | Cost domain verdict read-only |
| `publishReportArtifact` | AnalyticsRun + validations | `ReportArtifact` | Block if high-risk finding |
| `openOpsFindingAction` | DataQualityFinding | Communication `ActionRequest` | Target owner assigned |

### 9.2 RPA / Command Hooks

```text
/logi-master kpi-dash --deep --KRsummary
/logi-master report --deep --AEDonly
/logi-master weather-tie --routing-pattern-analysis
/visualize_data --type=heatmap operations-validation.json
```

### 9.3 LLM Guardrail

| LLM output | Allowed use | Not allowed |
|---|---|---|
| KPI explanation | Narrative summary for dashboard | Changing KPI values |
| Anomaly summary | Create review queue | Closing exception without owner |
| Header mapping suggestion | Draft DataMappingRule | Publishing without validation |
| ETA risk summary | Analyst alert | Replacing ETA source of truth |
| Report note | Management summary | Regulatory decision |

### 9.4 Dashboard Alert Rules

| Alert | Condition | Severity |
|---|---|---|
| Route missing | `hasRoutingPattern` absent | WARN |
| AGI/DAS gate missing | M130 without M115/M116/M117 or approved exception | HIGH |
| DEM/DET risk | M92 to M100 > 72.00 hrs | HIGH |
| Duplicate stock | duplicate stock-in rows for same shipment/location/date | HIGH |
| PII leakage | raw contact fields appear in report artifact | CRITICAL |
| Cost overage | consumed CostGuardResult = HIGH/CRITICAL | HIGH/CRITICAL |
| Open action breach | communication SLA breached | WARN/HIGH |

---

## 10. QA checklist & Assumptions

### 10.1 QA Checklist

| # | Check | Expected |
|---:|---|---|
| 1.00 | Operations does not redefine core classes | PASS |
| 2.00 | `ShipmentRoutingPattern` values match master dictionary | PASS |
| 3.00 | WHP is consumed as warehouse evidence only | PASS |
| 4.00 | MOSB is reported as offshore staging / marine interface | PASS |
| 5.00 | Excel row status does not override source-system truth | PASS |
| 6.00 | OperationDataset has hash, source, row count, mapping version | PASS |
| 7.00 | OperationRecord has source row and event date | PASS |
| 8.00 | Any-key resolution supports HVDC_CODE, BL, BOE, DO, invoice, package, container | PASS |
| 9.00 | Two-track WH/site date model keeps WH and site metrics separate | PASS |
| 10.00 | Stock double-count query returns 0.00 critical rows | PASS |
| 11.00 | AGI/DAS M130 requires MOSB/LCT evidence or human-gated exception | PASS |
| 12.00 | Report artifact includes validation status and source hash | PASS |
| 13.00 | CostGuard result is read-only consumed evidence | PASS |
| 14.00 | Communication SLA action metrics come from CONSOLIDATED-08 | PASS |
| 15.00 | PII is masked before report publication | PASS |
| 16.00 | Bulk/vessel analytics consume marine events from CONSOLIDATED-04 | PASS |
| 17.00 | Regulatory status views are evidence completeness, not legal interpretation | PASS |
| 18.00 | KPI decimal formatting uses 2.00 precision where numeric anchors are shown | PASS |
| 19.00 | Validation p95 target remains < 5.00s | PASS |
| 20.00 | ZERO/Failsafe is used when evidence or owner is missing | PASS |

### 10.2 Assumptions

| Assumption | Impact | Mitigation |
|---|---|---|
| Source Excel headers vary across reports | Mapping instability | Versioned `DataMappingRule` and header alias table |
| Some shipment rows lack direct HVDC_CODE | Any-key resolution coverage risk | Resolve through BL, DO, BOE, invoice, PO, package, container |
| SQM may be estimated for some cargo | Billing metric uncertainty | Mark estimated values and require cost owner review |
| Site dates may be manually entered | Site KPI uncertainty | Reconcile against SiteReceipt/POD/GRN |
| Marine events may be delayed in source systems | MOSB/LCT KPI lag | Flag stale data and request update through communication action |
| Report users may expect spreadsheet-style status override | Semantic drift risk | Keep status evidence separate from operational truth |

### 10.3 ZERO / Fail-safe

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Report publish paused | Source hash or mapping version missing | Non-reproducible KPI | Dataset hash, mapping rule version | Re-run ingest and mapping |
| KPI publish paused | Target object unresolved | False aggregation | HVDC key / BL / DO / invoice / package key | Run Any-key resolver |
| Site receipt metric paused | Spreadsheet date conflicts with SiteReceipt | Wrong site status | POD/GRN/MRS/MIS evidence | Material handling owner review |
| Cost metric paused | CostGuard verdict missing | Misleading financial view | Invoice and CostGuardResult | Cost owner review |
| Compliance view paused | Current evidence missing | Wrong regulatory implication | Permit/SOP/current source evidence | RAG + compliance human-gate |
| Report artifact paused | PII detected | Privacy leakage | Redaction policy and masked extract | Redact and revalidate |

---

## 11. CmdRec

```text
/switch_mode RHYTHM + /logi-master kpi-dash --deep --KRsummary
/logi-master report --deep --AEDonly
/visualize_data --type=heatmap CONSOLIDATED-09-validation-report.json
```
