---
title: "HVDC Material Handling Ontology — Consolidated"
type: "ontology-design"
domain: "material-handling"
sub-domains:
  - customs-release
  - inland-haulage
  - warehouse-interface
  - mosb-offshore-staging
  - marine-heavy-lift-interface
  - site-receiving
  - inspection-claims
  - material-issue
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "customs → release → WH → MOSB → site material-chain extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - GS1-EPCIS
  - DCSA-T&T
  - UN/CEFACT-BSP-RDM
  - WCO-DM
  - ICC-Incoterms-2020
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
source_files:
  - 2_EXT-08A-hvdc-material-handling-overview.md
  - 2_EXT-08B-hvdc-material-handling-customs.md
  - 2_EXT-08C-hvdc-material-handling-storage.md
  - 2_EXT-08D-hvdc-material-handling-offshore.md
  - 2_EXT-08E-hvdc-material-handling-site-receiving.md
  - 2_EXT-08F-hvdc-material-handling-transformer.md
  - 2_EXT-08G-hvdc-material-handling-bulk-integrated.md
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
semantic_patch:
  - "Material Handling owns milestone continuity and material-chain transactions; it does not own RoutingPattern dictionary or warehouse Flow Code."
  - "Program route truth uses ShipmentRoutingPattern + JourneyStage + JourneyLeg + MilestoneEvent."
  - "WarehouseHandlingProfile.confirmedFlowCode remains warehouse-only and is created/confirmed under CONSOLIDATED-02."
  - "MOSB is OffshoreStagingNode / MarineInterfaceNode, not Warehouse."
  - "AGI/DAS site arrival is blocked unless MOSB/LCT chain evidence exists or a human-gated exception is approved."
---

# hvdc-material-handling · CONSOLIDATED-06

## 1. ExecSummary

`CONSOLIDATED-06`는 HVDC Logistics KG의 **customs release → inland haulage → warehouse interface → MOSB/offshore staging → site receiving → inspection/issue/claim** material-chain extension이다. 본 문서는 `ShipmentUnit`의 물류 여정에서 자재 취급 상태를 `JourneyStage`, `JourneyLeg`, `MilestoneEvent`, `MaterialHandlingCase`, `SiteReceipt`, `InspectionEvent`, `Exception`, `Claim`으로 연결한다.

비즈니스 임팩트는 **통관 후 반출 지연 차단**, **AGI/DAS MOSB 누락 방지**, **M130 현장 입고·검수·GRN 정합성 확보**, **OSD/NCR/Claim 자동 증빙 패키지 생성**, **자재 traceability와 비용/재고 결산 정확도 향상**이다.

기술 해법은 `RoutingPattern`을 end-to-end route classifier로 유지하고, warehouse 내부 처리 등급은 `WarehouseHandlingProfile.confirmedFlowCode`로만 제한하며, 문서/OCR/Port/Cost/Marine 도메인은 material handling에 **evidence**만 제공하도록 분리하는 것이다.

KPI 목표는 `MaterialTraceCoverage ≥ 95.00%`, `AGIDASGateCompliance = 100.00%`, `SiteReceiptDocCompleteness ≥ 98.00%`, `QuantityReconciliationAccuracy = 100.00%`, `Validation p95 < 5.00s`, `HumanGate leakage = 0.00건`이다.

**ENG-KR one-liner:** Material Handling owns custody and milestone continuity; route truth remains `RoutingPattern`, warehouse handling remains `WarehouseHandlingProfile`, and documents remain evidence.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-06` owns **material-chain execution continuity** between customs release, warehouse handoff, MOSB staging, site receipt, inspection, issue, and claim.
3. Program-wide shipment visibility uses `ShipmentRoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
4. `confirmedFlowCode` may exist only on `WarehouseHandlingProfile`; material handling may read `wh_handling_cnt`, `storageClass`, and WH event evidence but shall not assign warehouse Flow Code.
5. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; it is not a top-level `Warehouse` and shall not be used as warehouse class evidence.
6. Port, document/OCR, cost, marine, and operations domains provide evidence or downstream analytics; they do not override material-handling transaction truth without an approved Foundry Action.
7. Extension-local legacy route-code language is migration debt. This document uses only canonical route, stage, milestone, and evidence terms.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-06 | Delegated / excluded |
|---|---|---|
| Customs release handoff | M90/M91/M92, BOE/DO evidence, permit blocker, release gate | Detailed customs declaration schema in `CONSOLIDATED-00` / document extraction in `CONSOLIDATED-03` |
| Inland haulage | M92→M100, gate-out, truck dispatch, custody handover, DEM/DET risk event | Carrier freight commercial audit in `CONSOLIDATED-05` |
| Warehouse interface | M110/M111/M120/M121 continuity and evidence handoff | WHP algorithm, zone/bin, storage classification in `CONSOLIDATED-02` |
| MOSB staging | M115 staging readiness, laydown handoff, AGI/DAS route gate | Marine stowage/stability/lashing execution in `CONSOLIDATED-04` |
| LCT/offshore interface | M116/M117 continuity requirement and exception handling | Vessel stability, deck pressure, weather/tide final approval in `CONSOLIDATED-04` |
| Site receiving | M130 arrival, M131 good inspection, M132 OSD inspection, M140 POD/GRN/MIS/MRS | Site construction work-pack execution outside logistics KG |
| Exception / claim | M150 claim opened, NCR/OSDR proof pack, M160 closeout | Legal claim settlement and commercial negotiation |
| Cost handoff | material event evidence for warehouse/marine/trucking/DEM-DET charges | RateRef, CostGuard verdict, invoice approval in `CONSOLIDATED-05` |
| Communication evidence | approval, escalation, exception note as evidence | Communication ontology ownership in `CONSOLIDATED-08` |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with material handling | Not allowed in CONSOLIDATED-06 |
|---|---|---|
| Master spine | Read/write links to `ShipmentUnit`, `JourneyLeg`, `MilestoneEvent`, `SiteReceipt`, `Exception` | Redefine route dictionary, milestone dictionary, or identity policy |
| Infrastructure | Read `LocationNode`, `Port`, `Warehouse`, `OffshoreStagingNode`, `Site`, `TransportCorridor` | Reclassify MOSB into warehouse semantics |
| Warehouse | Read M110/M111/M120/M121 and `WarehouseHandlingProfile` evidence | Assign `confirmedFlowCode` or alter WHP algorithm |
| Document/OCR | Consume `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, permit/doc extraction | Treat OCR extraction as transaction mutation |
| Port | Consume `plannedRoutingPattern`, `declaredDestination`, DO/gate/release evidence | Treat `plannedRoutingPattern` as final route truth without action review |
| Marine/Bulk | Consume M115/M116/M117, `MarineRoutingPattern`, lashing/stability readiness | Approve engineering/marine execution inside material handling |
| Cost | Provide material event evidence to invoice audit | Own `RateRef`, `CostGuardResult`, or FX override |
| Operations | Export timeline, inventory issue, exception, and route analytics | Replace material event state with Excel-only row status |
| Communication | Attach `CommunicationEvent`, `ApprovalAction`, `AuditRecord` | Redefine material transaction classes |

### 2.4 Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Flow Code 0~5 as customs→WH→MOSB→site route | `ShipmentRoutingPattern` + `JourneyStage` + `MilestoneEvent` | Replace in all route, KPI, and status sections |
| Pre-arrival Flow Code | `ShipmentStatus = PLANNED/READY` or `RoutingPattern = PRE_ARRIVAL` | Remove from material-chain logic |
| Port-provided warehouse route code | `PortCall.plannedRoutingPattern` and `declaredDestination` as evidence | Do not promote to WHP |
| Document-derived warehouse route code | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` | Attach confidence and provenance only |
| Cost grouped by warehouse route code | `costByRoutingPattern` + `wh_handling_cnt` evidence | Cost layer computes audit result |
| MOSB collapsed into warehouse semantics | `OffshoreStagingNode` / `MarineInterfaceNode` | Optional storage capability only |

---

## 3. Schema (RDF/OWL + SHACL 요약)

### 3.1 Ontology Layer Map

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Core custody | `MaterialHandlingCase`, `CustodyTransfer`, `MaterialMove`, `HandlingInstruction` | Customs-to-site custody chain |
| Shipment link | `ShipmentUnit`, `CargoUnit`, `Container`, `Package`, `MaterialMaster` | Identity and physical material anchor |
| Route/stage | `ShipmentRoutingPattern`, `JourneyStage`, `JourneyLeg`, `MilestoneEvent` | End-to-end visibility and timeline |
| Customs/release | `CustomsReleaseGate`, `CustomsEntry`, `ReleaseOrder`, `BOEDocument`, `DeliveryOrderDocument` | Import release and gate-out readiness |
| Inland transport | `InlandHaulageTask`, `GateOutEvent`, `TruckDispatch`, `TransportManifest` | M92→M100 transport execution |
| Warehouse interface | `WarehouseTask`, `WarehouseEvent`, `WarehouseHandlingProfile`, `StockSnapshot` | M110~M121 handoff without WHP ownership |
| MOSB/marine interface | `MOSBStagingTask`, `MarineReadinessGate`, `MarineEvent`, `MarineRoutingPattern` | M115/M116/M117 continuity for offshore delivery |
| Site receiving | `SiteReceipt`, `InspectionEvent`, `MaterialAcceptanceRecord`, `MaterialIssueTransaction` | M130~M140 site material control |
| Documents | `MRR`, `MRI`, `ITP`, `MAR`, `MRS`, `MIS`, `POD`, `GRN`, `OSDR`, `PermitDocument` | Documentary evidence |
| Exception/claim | `Exception`, `Shortage`, `Damage`, `Overage`, `WrongItem`, `NCR`, `Claim` | OSD, claim, and closeout lifecycle |
| Evidence/provenance | `VerificationResult`, `AuditRecord`, `ApprovalAction`, `ProofArtifact` | Human-gated proof trail |
| KPI | `MaterialHandlingKPI`, `GateDelayMetric`, `AGIDASComplianceMetric`, `GRNClosureMetric` | Operations and SLA monitoring |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `MaterialHandlingCase` | `caseId`, `caseStatus`, `currentStage`, `declaredDestination`, `routingPattern`, `openedAt` | `forShipmentUnit`, `hasCustodyTransfer`, `hasHandlingInstruction`, `hasMilestone` | One operational case per material/shipment control unit |
| `CustodyTransfer` | `transferId`, `fromParty`, `toParty`, `transferTime`, `transferCondition`, `qtyPkg` | `forShipmentUnit`, `evidencedByDocument`, `generatesMilestone` | Handover record between broker/port/WMS/marine/site |
| `CustomsReleaseGate` | `gateId`, `releaseStatus`, `boeRef`, `doRef`, `permitStatus`, `releasedAt` | `validatesCustomsEntry`, `requiresPermit`, `blocksMilestone` | M92 precondition for M100 |
| `InlandHaulageTask` | `haulageTaskId`, `truckId`, `driverRefMasked`, `originNode`, `destinationNode`, `plannedPickup`, `actualGateOut` | `forJourneyLeg`, `evidencedByTransportManifest` | PII must be masked or role-tokenized |
| `WarehouseInterfaceHandoff` | `handoffId`, `warehouseNode`, `handoffStatus`, `m110Ref`, `m121Ref` | `linksWarehouseEvent`, `readsWarehouseHandlingProfile` | Does not assign `confirmedFlowCode` |
| `MOSBStagingTask` | `stagingTaskId`, `mosbNode`, `laydownArea`, `stagingStatus`, `readyForMarineLoad` | `generatesMilestone M115`, `requiresMarineReadinessGate` | MOSB is offshore staging, not warehouse |
| `MarineReadinessGate` | `gateId`, `stowageReady`, `lashingReady`, `stabilityReady`, `weatherReady`, `approvalStatus` | `validatedByMarineOperation`, `blocksMilestone M117` | Final engineering approval remains human-gated |
| `SiteReceipt` | `receiptId`, `siteCode`, `receiptType`, `arrivalTime`, `inspectionResult`, `mrrRef`, `osdrRef`, `podRef`, `grnRef` | `forShipmentUnit`, `generatesSiteDocuments`, `opensException` | Transaction object; documents are evidence |
| `InspectionEvent` | `inspectionId`, `inspectionTime`, `inspectionResult`, `inspectorRole`, `qtyAccepted`, `qtyRejected` | `forSiteReceipt`, `evidencedByMRI`, `createsMARorOSDR` | M131/M132 driver |
| `MaterialIssueTransaction` | `issueId`, `requestNo`, `issueNo`, `issuedQty`, `issuedTo`, `issueTime` | `evidencedByMRS`, `evidencedByMIS`, `reducesSiteStock` | M140 material issue handoff |
| `MaterialException` | `exceptionId`, `exceptionType`, `severity`, `detectedAt`, `rootCauseStatus` | `evidencedByOSDR`, `mayOpenClaim`, `blocksCloseout` | Shortage/damage/overage/wrong item |
| `Claim` | `claimId`, `claimType`, `claimAmount`, `claimCurrency`, `claimStatus`, `openedAt`, `closedAt` | `supportedByNCR`, `supportedByOSDR`, `linkedToInvoice` | M150/M160 chain |

### 3.3 Core Properties

| Property | Domain → Range | Cardinality | Rule |
|---|---|---:|---|
| `forShipmentUnit` | `MaterialHandlingCase → ShipmentUnit` | 1..1 | Case must resolve to one shipment unit |
| `hasCurrentStage` | `MaterialHandlingCase → JourneyStage` | 1..1 | Must follow canonical stage vocabulary |
| `hasRoutingPattern` | `MaterialHandlingCase → ShipmentRoutingPattern` | 1..1 | Mirrors approved `ShipmentUnit.hasRoutingPattern`; no integer route code |
| `hasMilestone` | `ShipmentUnit/MaterialHandlingCase → MilestoneEvent` | 1..N | Key events must have actual/planned timestamp |
| `requiresReleaseGate` | `MaterialHandlingCase → CustomsReleaseGate` | 0..1 | Required before M100 for import flows |
| `hasWarehouseHandoff` | `MaterialHandlingCase → WarehouseInterfaceHandoff` | 0..N | Required for `WH_ONLY` / `WH_MOSB` |
| `hasMOSBStagingTask` | `MaterialHandlingCase → MOSBStagingTask` | 0..N | Required for `MOSB_DIRECT` / `WH_MOSB` / AGI/DAS |
| `hasSiteReceipt` | `MaterialHandlingCase → SiteReceipt` | 0..N | Required at M130 |
| `evidencedByDocument` | `CustodyTransfer/SiteReceipt/Exception → Document` | 1..N | Documents provide proof, not ownership |
| `createdByAction` | Transaction → `ApprovalAction` | 1..N for manual override | Action must carry reviewer and reason |
| `readsWarehouseHandlingProfile` | `WarehouseInterfaceHandoff → WarehouseHandlingProfile` | 0..1 | Read-only evidence |
| `hasCostEvidence` | `MaterialHandlingCase → InvoiceLine/CostTransaction` | 0..N | Cost layer owns verdict |

### 3.4 Canonical Route and Stage Matrix

| Material category | Allowed `ShipmentRoutingPattern` | Mandatory stages | Blocking rule |
|---|---|---|---|
| Container cargo | `DIRECT`, `WH_ONLY`, `WH_MOSB`, `MIXED` | M92→M100→M110/M130 | DO evidence required before gate-out |
| Bulk cargo | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | M92/M100→M115→M116→M117→M130 | Marine readiness gate before M117 |
| Transformer / OOG | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | M100/M121→M115→M116→M117→M130 | Lift/stability/lashing evidence required |
| MIR / SHU onshore | `DIRECT`, `WH_ONLY`, `MIXED` | M92→M100→M130 or M110→M121→M130 | MOSB not required unless routing evidence says otherwise |
| AGI / DAS offshore | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | M115→M116→M117→M130 | M130 blocked without MOSB/LCT chain or approved exception |
| Dangerous Goods | Any allowed route with DG control | Permit/DCD/FANR/DG storage checks | Permit or segregation failure blocks M100/M110/M115 |

### 3.5 Milestone Chain

| Milestone | Name | Stage | Material-handling meaning | Required evidence |
|---|---|---|---|---|
| M40 | Export Cleared | `ORIGIN_DISPATCH` | Origin export release | Export permit / export clearance |
| M50 | Terminal Received | `TERMINAL_HANDLING` | Port/terminal received cargo | terminal receipt / gate-in |
| M61 | Vessel ATD / Loaded | `TERMINAL_HANDLING` | Carrier departure / load confirmation | carrier event / BL update |
| M80 | Vessel ATA | `PORT_ENTRY` | Arrival at UAE port | carrier/port event |
| M90 | BOE Submitted | `CUSTOMS_CLEARANCE` | Import declaration submitted | BOE document |
| M91 | BOE Cleared | `CUSTOMS_CLEARANCE` | Customs clearance approved | customs clearance proof |
| M92 | DO Released | `CUSTOMS_CLEARANCE` | Delivery order ready | DO / release order |
| M100 | Gate-out | `INLAND_HAULAGE` | Port/terminal exit | gate pass / transport manifest |
| M110 | WH Received | `WH_RECEIPT` | Physical receipt by warehouse | WMS receipt / warehouse event |
| M111 | Put-away | `WH_STORAGE` | Zone/bin confirmed | put-away task / WHP confirmation |
| M120 | Picked/Staged | `WH_DISPATCH` | Ready for dispatch | pick list / staging record |
| M121 | WH Dispatched | `WH_DISPATCH` | Leaves warehouse | dispatch note / WMS event |
| M115 | MOSB Staged | `MOSB_STAGING` | Offshore staging ready | MOSB staging record |
| M116 | LCT/Barge Loaded | `OFFSHORE_TRANSIT` | Loaded for offshore transit | load confirmation / stowage evidence |
| M117 | Sail-away Approved | `OFFSHORE_TRANSIT` | Marine release approved | sail-away approval / weather gate |
| M130 | Site Arrived | `SITE_RECEIVING` | Material arrived at site | delivery note / MRR |
| M131 | Site Inspected — Good | `SITE_RECEIVING` | Accepted as good | MRI / MAR |
| M132 | Site Inspected — OSD | `SITE_RECEIVING` | Shortage, damage, overage, or wrong item | OSDR / photos / NCR evidence |
| M140 | POD / GRN / Material Issue | `MATERIAL_ISSUE` | Receipt closed or issued | POD / GRN / MRS / MIS |
| M150 | Claim Opened | `CLOSEOUT` | Claim/NCR case opened | claim file / NCR / OSDR |
| M160 | Closed | `CLOSEOUT` | Claim/cost/material case closed | closure approval |

### 3.6 RDF/OWL Skeleton

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

hvdc:MaterialHandlingCase a owl:Class ;
  rdfs:label "Material Handling Case" ;
  rdfs:comment "Customs-to-site material custody case linked to one ShipmentUnit." .

hvdc:CustomsReleaseGate a owl:Class ;
  rdfs:label "Customs Release Gate" ;
  rdfs:comment "BOE/DO/permit-controlled gate before port gate-out." .

hvdc:MOSBStagingTask a owl:Class ;
  rdfs:label "MOSB Staging Task" ;
  rdfs:comment "Offshore staging task at MOSB; not a Warehouse task." .

hvdc:SiteReceipt a owl:Class ;
  rdfs:label "Site Receipt" ;
  rdfs:comment "Site arrival/inspection transaction evidenced by MRR/MRI/POD/GRN/OSDR." .

hvdc:hasRoutingPattern a owl:ObjectProperty ;
  rdfs:domain hvdc:MaterialHandlingCase ;
  rdfs:range hvdc:ShipmentRoutingPattern .

hvdc:evidencedByDocument a owl:ObjectProperty ;
  rdfs:domain owl:Thing ;
  rdfs:range hvdc:Document .
```

### 3.7 Key Rules

1. `MaterialHandlingCase` must resolve to exactly one `ShipmentUnit` through Any-key identity.
2. `MaterialHandlingCase.hasRoutingPattern` must use `PRE_ARRIVAL`, `DIRECT`, `WH_ONLY`, `MOSB_DIRECT`, `WH_MOSB`, or `MIXED` only.
3. `confirmedFlowCode` must not appear on `MaterialHandlingCase`, `SiteReceipt`, `CustomsReleaseGate`, `MOSBStagingTask`, `PortCall`, `Document`, `Invoice`, or `MarineOperation`.
4. AGI/DAS material cannot reach M130 unless M115 exists, and M116/M117 are required unless direct exception approval is attached.
5. `SiteReceipt` is the transaction owner; `MRR`, `MRI`, `POD`, `GRN`, and `OSDR` are evidence documents.

---

## 4. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 4.1 Object Type Mapping

| Foundry Object Type | Source system / dataset | Key fields | Links |
|---|---|---|---|
| `ShipmentUnit` | ERP, freight forwarder, carrier feed, LDG | `shipmentId`, `blNo`, `containerNo`, `caseNo`, `hvdcCode` | `hasMaterialHandlingCase`, `hasDocument`, `hasMilestone` |
| `MaterialHandlingCase` | Gold material flow dataset | `caseId`, `currentStage`, `routingPattern`, `declaredDestination` | `forShipmentUnit`, `hasSiteReceipt`, `hasException` |
| `CustomsReleaseGate` | ATLP/eDAS/customs broker/LDG | `boeNo`, `doNo`, `releaseStatus`, `permitStatus` | `validatesCustomsEntry`, `blocksMilestone M100` |
| `InlandHaulageTask` | TMS / forwarder / port gate feed | `truckRef`, `origin`, `destination`, `gateOutAt` | `forJourneyLeg`, `generates M100` |
| `WarehouseInterfaceHandoff` | WMS / WH Gold dataset | `warehouseNode`, `m110At`, `m121At`, `whpRef` | `readsWarehouseHandlingProfile` |
| `MOSBStagingTask` | ALS / marine planner / MOSB register | `mosbNode`, `stagingAt`, `laydownArea`, `readinessStatus` | `generates M115`, `requiresMarineReadinessGate` |
| `MarineReadinessGate` | Marine extension / planning register | `stowageReady`, `lashingReady`, `stabilityReady`, `weatherReady` | `blocks M117`, `evidencedByMarineDocument` |
| `SiteReceipt` | Site logistics / FMC / ERP | `receiptId`, `siteCode`, `arrivalAt`, `inspectionResult` | `forShipmentUnit`, `generatesSiteDocuments` |
| `MaterialException` | Site QA/QC / OSDR / claims register | `exceptionType`, `severity`, `detectedAt`, `claimRef` | `linkedToOSDR`, `linkedToClaim`, `blocksCloseout` |
| `CostEvidenceLink` | Invoice/CostGuard | `invoiceNo`, `invoiceLineNo`, `chargeType`, `evidenceEvent` | `supportsInvoiceLine`, `doesNotOwnVerdict` |

### 4.2 Link Type Mapping

| Link Type | From → To | Purpose |
|---|---|---|
| `resolvesToShipmentUnit` | `Identifier → ShipmentUnit` | Any-key search entry |
| `opensMaterialCase` | `ShipmentUnit → MaterialHandlingCase` | Creates operational custody case |
| `evidencedByDocument` | `MaterialHandlingCase/CustodyTransfer/SiteReceipt → Document` | Evidence lineage |
| `generatesMilestone` | `Task/Event → MilestoneEvent` | Timeline closure |
| `requiresGate` | `MaterialHandlingCase → CustomsReleaseGate/MarineReadinessGate` | Blocker visibility |
| `readsWarehouseEvidence` | `WarehouseInterfaceHandoff → WarehouseHandlingProfile` | Read-only WHP evidence |
| `createsSiteReceipt` | `MilestoneEvent M130 → SiteReceipt` | Site transaction creation |
| `opensException` | `InspectionEvent M132 → MaterialException` | OSD/NCR trigger |
| `supportsCostAudit` | `MilestoneEvent/Task → InvoiceLine` | Cost evidence handoff |

### 4.3 Action Workflow

| Action | Trigger | Writes | Hard gate |
|---|---|---|---|
| `CreateMaterialHandlingCase` | `ShipmentUnit` ready or M80 arrival | `MaterialHandlingCase` | ≥1 identifier and route evidence |
| `SubmitCustomsReleaseGate` | BOE/DO/permit evidence received | `CustomsReleaseGate`, M90/M91/M92 | BOE/DO/permit document completeness |
| `RecordGateOut` | Port gate-out event | M100, `InlandHaulageTask` | M92 exists and permit blockers cleared |
| `RecordWHReceipt` | WMS receipt | M110, `WarehouseInterfaceHandoff` | WH route or warehouse appointment evidence |
| `RecordMOSBStaging` | MOSB laydown confirmation | M115, `MOSBStagingTask` | AGI/DAS or MOSB-inclusive route |
| `ApproveSailAway` | marine readiness approval | M117, `MarineReadinessGate` | M115/M116 + stowage/lashing/stability/weather readiness |
| `RecordSiteArrival` | site receipt event | M130, `SiteReceipt` | AGI/DAS requires M115 and usually M116/M117 |
| `RecordInspectionGood` | QA/QC good inspection | M131, MAR | MRR/MRI evidence |
| `RecordInspectionOSD` | shortage/damage/overage/wrong item | M132, OSDR, `MaterialException` | photo/MRI/OSDR proof pack |
| `CloseMaterialIssue` | POD/GRN/MRS/MIS posted | M140 | quantity reconciliation |
| `OpenClaim` | OSD/NCR requires commercial action | M150, `Claim` | OSDR/NCR evidence |
| `CloseClaimAndCase` | claim or discrepancy closed | M160 | approval + proof artifact |

### 4.4 Source System Crosswalk

| Source | Consumed fields | Output in KG | Validation |
|---|---|---|---|
| ERP / PO / Package | PO, package, material code, incoterm, site code | `MaterialMaster`, `Package`, `ShipmentUnit` | PO/package/material link completeness |
| LDG/OCR | CI/PL/BL/BOE/DO/MRR/POD/GRN/OSDR fields | `DocumentEntity`, evidence assertions | `MeanConf ≥ 0.92`, `TableAcc ≥ 0.98`, `NumericIntegrity = 1.00` |
| Port / OFCO | `plannedRoutingPattern`, `declaredDestination`, gate pass, port service evidence | route evidence, service evidence, M50/M80/M92/M100 candidates | evidence-only route update |
| ATLP/eDAS/customs broker | BOE status, HS, permit, DO release | `CustomsReleaseGate`, `CustomsEntry`, `ReleaseOrder` | BOE document not collapsed into CustomsEntry |
| WMS | M110/M111/M120/M121, stock snapshot, WHP reference | `WarehouseInterfaceHandoff`, `StockSnapshot`, WH event links | `confirmedFlowCode` remains WHP-only |
| ALS / Marine / MOSB | M115/M116/M117, staging, LCT, marine approval | `MOSBStagingTask`, `MarineReadinessGate`, `MarineEvent` | AGI/DAS chain gate |
| Site / FMC / QA/QC | MRR/MRI/MAR/MRS/MIS/POD/GRN/OSDR | `SiteReceipt`, `InspectionEvent`, `MaterialIssueTransaction`, `Exception` | M130/M131/M132/M140 document gate |
| Invoice / Cost | invoice lines, charge type, DEM/DET, trucking, WH, marine charges | `CostEvidenceLink` | CostGuard verdict remains Cost domain |
| Communication evidence | approval emails/chat/actions | `CommunicationEvent`, `ApprovalAction`, `AuditRecord` | evidence-only, PII masked |

### 4.5 Foundry Pipeline

```text
Bronze  : raw ERP/WMS/ATLP/LDG/Port/MOSB/Site/Invoice records + immutable source lineage
Silver  : normalized identifiers, dates, units, site codes, route evidence, document entities
Gold    : ShipmentUnit, MaterialHandlingCase, MilestoneEvent, SiteReceipt, Exception, CostEvidenceLink
Actions : controlled writes for M100/M110/M115/M117/M130/M132/M140/M150/M160
Views   : Any-key trace, route gate board, AGI/DAS blocker, site GRN closure, OSD/NCR dashboard
```

---

## 5. Validation (SPARQL/RAG/Human-gate)

### 5.1 SHACL Control Matrix

| Rule ID | Target | Logic | Severity |
|---|---|---|---|
| `MH-IDENT-001` | `MaterialHandlingCase` | exactly one `forShipmentUnit` and ≥1 identifier | BLOCK |
| `MH-ROUTE-001` | `MaterialHandlingCase` | valid `ShipmentRoutingPattern` enum only | BLOCK |
| `MH-FLOW-001` | any subject with `confirmedFlowCode` | subject must be `WarehouseHandlingProfile` | BLOCK |
| `MH-CUSTOMS-001` | `CustomsReleaseGate` | BOE and DO evidence required before M100 | BLOCK |
| `MH-PERMIT-001` | regulated material | permit/certificate not expired at gate event | BLOCK |
| `MH-DEMDET-001` | M92→M100 | alert if gate-out not completed within 72.00 hrs after DO release | WARN/HIGH |
| `MH-WH-001` | `WH_ONLY` / `WH_MOSB` | M110 required before WH stock appears | BLOCK |
| `MH-MOSB-001` | AGI/DAS | M130 requires M115; M116/M117 required unless approved exception | BLOCK |
| `MH-MARINE-001` | M117 | marine readiness gate must pass or carry approved exception | BLOCK |
| `MH-SITE-001` | `SiteReceipt` | M130 must link site code and delivery evidence | BLOCK |
| `MH-OSD-001` | M132 | OSDR + photo/inspection evidence required | BLOCK |
| `MH-GRN-001` | M140 | POD/GRN/MIS/MRS must reconcile quantities | BLOCK |
| `MH-COST-001` | `CostEvidenceLink` | material event evidence may support InvoiceLine, not CostGuard verdict ownership | WARN/BLOCK |
| `MH-EVID-001` | evidence records | document/communication evidence cannot mutate transaction without approved Action | BLOCK |

### 5.2 SHACL — MaterialHandlingCase Required Shape

```turtle
hvdc:MaterialHandlingCaseRequiredShape a sh:NodeShape ;
  sh:targetClass hvdc:MaterialHandlingCase ;
  sh:property [
    sh:path hvdc:forShipmentUnit ;
    sh:minCount 1 ; sh:maxCount 1 ;
    sh:message "MaterialHandlingCase must resolve to exactly one ShipmentUnit." ;
  ] ;
  sh:property [
    sh:path hvdc:hasRoutingPattern ;
    sh:minCount 1 ;
    sh:in (hvdc:PRE_ARRIVAL hvdc:DIRECT hvdc:WH_ONLY hvdc:MOSB_DIRECT hvdc:WH_MOSB hvdc:MIXED) ;
    sh:message "MaterialHandlingCase must use ShipmentRoutingPattern enum only." ;
  ] ;
  sh:property [
    sh:path hvdc:hasCurrentStage ;
    sh:minCount 1 ;
    sh:message "MaterialHandlingCase must have a current JourneyStage." ;
  ] .
```

### 5.3 SHACL — Flow Code Boundary

```turtle
hvdc:MaterialHandlingFlowCodeBoundaryShape a sh:NodeShape ;
  sh:targetSubjectsOf hvdc:confirmedFlowCode ;
  sh:sparql [
    sh:message "VIOLATION-1: confirmedFlowCode found outside WarehouseHandlingProfile." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:confirmedFlowCode ?code .
        FILTER NOT EXISTS { $this a hvdc:WarehouseHandlingProfile }
      }
    """ ;
  ] .
```

### 5.4 SHACL — Customs Release Before Gate-out

```turtle
hvdc:GateOutRequiresReleaseShape a sh:NodeShape ;
  sh:targetClass hvdc:MaterialHandlingCase ;
  sh:sparql [
    sh:message "M100 Gate-out requires M92 DO Released and cleared permit blockers." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:hasMilestone ?m100 .
        ?m100 hvdc:milestoneCode "M100" ; hvdc:actualDt ?gateOut .
        FILTER NOT EXISTS {
          $this hvdc:hasMilestone ?m92 .
          ?m92 hvdc:milestoneCode "M92" ; hvdc:actualDt ?doReleased .
        }
      }
    """ ;
  ] .
```

### 5.5 SHACL — AGI/DAS MOSB + LCT Chain

```turtle
hvdc:AGIDASMaterialChainShape a sh:NodeShape ;
  sh:targetClass hvdc:MaterialHandlingCase ;
  sh:sparql [
    sh:message "VIOLATION-2: AGI/DAS Site Arrival requires MOSB/LCT chain evidence or approved exception." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:declaredDestination ?dest ;
              hvdc:hasRoutingPattern ?rp ;
              hvdc:hasMilestone ?m130 .
        FILTER(?dest IN ("AGI", "DAS"))
        FILTER(?rp IN (hvdc:MOSB_DIRECT, hvdc:WH_MOSB, hvdc:MIXED))
        ?m130 hvdc:milestoneCode "M130" ; hvdc:actualDt ?siteArrived .
        FILTER NOT EXISTS {
          $this hvdc:hasMilestone ?m115 .
          ?m115 hvdc:milestoneCode "M115" ; hvdc:actualDt ?mosbStaged .
        }
        FILTER NOT EXISTS {
          $this hvdc:hasApprovedException ?ex .
          ?ex hvdc:exceptionType "AGIDAS_MOSB_BYPASS" ; hvdc:approvalStatus "APPROVED" .
        }
      }
    """ ;
  ] .
```

### 5.6 SHACL — OSD Requires OSDR

```turtle
hvdc:OSDRequiresOSDRShape a sh:NodeShape ;
  sh:targetClass hvdc:SiteReceipt ;
  sh:sparql [
    sh:message "M132 OSD inspection requires OSDR evidence and exception record." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:inspectionResult "OSD" .
        FILTER NOT EXISTS { $this hvdc:osdrRef ?osdr . }
      }
    """ ;
  ] .
```

### 5.7 SHACL — Quantity Reconciliation

```turtle
hvdc:SiteQuantityReconciliationShape a sh:NodeShape ;
  sh:targetClass hvdc:SiteReceipt ;
  sh:sparql [
    sh:message "Received + OSD quantity must reconcile with dispatched quantity within 0.00 tolerance unless approved variance exists." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:dispatchedQty ?dq ; hvdc:acceptedQty ?aq ; hvdc:osdQty ?oq .
        BIND(ABS(?dq - (?aq + ?oq)) AS ?delta)
        FILTER(?delta > 0.00)
        FILTER NOT EXISTS { $this hvdc:hasApprovedVariance ?variance . }
      }
    """ ;
  ] .
```

### 5.8 SPARQL — Gate-out Delay After DO Release

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>

SELECT ?case ?shipment ?doReleased ?gateOut
WHERE {
  ?case a hvdc:MaterialHandlingCase ; hvdc:forShipmentUnit ?shipment ; hvdc:hasMilestone ?m92 .
  ?m92 hvdc:milestoneCode "M92" ; hvdc:actualDt ?doReleased .
  OPTIONAL { ?case hvdc:hasMilestone ?m100 . ?m100 hvdc:milestoneCode "M100" ; hvdc:actualDt ?gateOut . }
  FILTER(!BOUND(?gateOut) || (?gateOut > ?doReleased + "PT72H"^^xsd:dayTimeDuration))
}
```

### 5.9 SPARQL — M140 Missing POD/GRN

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?receipt ?shipment
WHERE {
  ?case a hvdc:MaterialHandlingCase ; hvdc:forShipmentUnit ?shipment ; hvdc:hasSiteReceipt ?receipt .
  ?receipt hvdc:hasMilestone ?m140 .
  ?m140 hvdc:milestoneCode "M140" ; hvdc:actualDt ?closed .
  FILTER NOT EXISTS { ?receipt hvdc:podRef ?pod . }
  FILTER NOT EXISTS { ?receipt hvdc:grnRef ?grn . }
}
```

### 5.10 SPARQL — Legacy Term Detection

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?s ?p ?o
WHERE {
  ?s ?p ?o .
  FILTER(REGEX(LCASE(STR(?p)), "(assigned|extracted).*flow.*code") ||
         REGEX(LCASE(STR(?p)), "cost.*flow.*code") ||
         REGEX(LCASE(STR(?p)), "logistics.*flow.*code"))
}
```

### 5.11 RAG Check

| Trigger | RAG / latest-evidence action | Human gate |
|---|---|---|
| MOIAT/FANR/DCD/ADNOC rule or permit mismatch | Re-check approved SOP / authority source on action date | Compliance Lead |
| HS/BOE classification confidence < 0.95 | Review BOE/CI/PL/COO and broker note | Customs Lead |
| AGI/DAS M130 without M115/M116/M117 | Require marine exception pack | Marine Lead + Site Logistics |
| OOG/heavy cargo missing weight, dimension, COG, lift point | Request engineering document pack | Heavy Lift Engineer |
| M132 OSD with high-value material | Require photo/MRI/OSDR/NCR pack | QA/QC + Claims |
| Invoice/DEM/DET charge linked to delayed gate-out | Reconcile M92/M100 timestamps and rate master | Cost Control Lead |
| OCR confidence below threshold | Re-extract or manual document validation | Data Steward |

### 5.12 Human-gate Matrix

| Gate | Trigger | Approver | Required proof |
|---|---|---|---|
| Customs gate | BOE/DO/permit missing or expired | Customs / Compliance Lead | BOE, DO, permit/certificate |
| Warehouse gate | WHP override or special storage | Warehouse Manager | M110/M111 evidence, storage note |
| Marine gate | M117 approval or OOG/heavy lift | Marine Lead / Engineer / HSE | stowage, lashing, stability, weather, PTW |
| AGI/DAS gate | M130 attempt without complete MOSB chain | Marine Lead + Site Logistics | approved bypass exception |
| Site OSD gate | M132 OSD | QA/QC + Claims | OSDR, photos, MRI, NCR |
| Cost gate | high DEM/DET, WH, marine, trucking dispute | Cost Control Lead | milestone evidence + invoice line |
| Privacy gate | personnel contact evidence | Data Steward | masked contact/token only |

---

## 6. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 6.1 Compliance Object Model

| Object | Required properties | Links |
|---|---|---|
| `RegulatoryRequirement` | `authority`, `requirementType`, `triggerCondition`, `effectiveDate`, `status` | applies to `MaterialMaster`, `ShipmentUnit`, `LocationNode`, `Site` |
| `PermitDocument` | `permitNo`, `authority`, `permitType`, `issueDate`, `expiryDate` | evidences requirement |
| `ComplianceCheck` | `checkId`, `ruleId`, `result`, `checkedAt`, `checkedByRole` | validates gate/action |
| `AccessPermit` | `permitNo`, `siteCode`, `validFrom`, `validTo`, `holderToken` | controls ADNOC/CICPA/site access |
| `ApprovalAction` | `approvalRef`, `approverRole`, `approvedAt`, `decision`, `reason` | authorizes exception or override |

### 6.2 Incoterms 2020 Controls

| Control | Logic | Material-handling impact |
|---|---|---|
| `IncotermPresence` | PO/shipment must carry incoterm and named place | Owner of transport risk is clear at each `JourneyLeg` |
| `RiskTransferPoint` | Risk transfer must match incoterm-defined point | Damage/shortage liability is linked to correct custody transfer |
| `CostResponsibility` | InvoiceLine charge owner must match PO/incoterm | DEM/DET, trucking, marine, WH charge dispute evidence is traceable |
| `DeliveryObligation` | Site delivery / named place must match `declaredDestination` | Route exception and M130 mismatch become review items |

### 6.3 UAE Regulatory Controls

| Authority / topic | Ontology handling | Blocking point |
|---|---|---|
| MOIAT | `requiresMOIATCoC`, `certificateRef`, `certificateExpiryDate`, `productCategory` | M91/M92 or M100 if certificate missing/expired |
| FANR | `requiresFANRPermit`, `radiationSourceFlag`, `permitRef`, `permitExpiryDate` | M90/M91/M100 and DG/controlled storage |
| DCD / Dangerous Goods | `dgClass`, `UNNumber`, `segregationGroup`, `dangerousCargoWarehouseRequired` | M100/M110/M115 staging |
| ADNOC / CICPA / Site Access | `AccessPermit`, `GatePass`, `SecurityApproval`, `LocationNode.governedBy` | M100, M115, M130 |
| WCO / HS | `hsCode`, `classificationConfidence`, `customsRiskScore`, `CustomsEntry` | BOE submission and clearance |
| Port / Marine / HSE | PTW, JSA/TRA, lifting permit, working-over-water permit | M115/M116/M117 |

### 6.4 Compliance Blockers

```text
IF regulated material AND permit missing/expired           → BLOCK M90/M91/M100
IF DG cargo AND DCD/DG segregation evidence missing        → BLOCK M110/M115
IF AGI/DAS AND MOSB/LCT evidence missing                   → BLOCK M130
IF OOG/heavy cargo AND lift/stability/lashing pack missing → BLOCK M116/M117
IF Site access permit missing                              → BLOCK M130
IF OCR/confidence evidence below threshold                 → HUMAN-GATE before action write
```

### 6.5 Privacy and NDA Guard

1. Personnel names may be retained when operationally required, but phone/e-mail fields must be masked before register write.
2. Driver and site access holders should be represented by `holderToken` or role reference unless explicit operational approval exists.
3. Communication evidence should link to `CommunicationEvent` and `AuditRecord`; it must not expose raw PII in dashboard extracts.

---

## 7. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Description | Pros | Cons | Est. cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A. Baseline Material Gate | M92/M100/M110/M130/M140 milestone and document gate only | 빠른 적용, 기존 Excel/WMS/LDG 연동 용이 | Marine/OOG gate는 수동 검토 의존 | 35,000.00 AED | Medium | 2.00 weeks |
| B. Operational Material Twin | MaterialHandlingCase + CustodyTransfer + SiteReceipt + OSD/NCR graph | Any-key traceability, AGI/DAS/MOSB 차단 자동화, site GRN 정합성 강화 | 객체/링크 설계와 Actions 필요 | 95,000.00 AED | Medium | 6.00 weeks |
| C. Marine-linked Material Twin | B + MOSB/LCT/stowage/lashing/stability/weather gates | AGI/DAS offshore delivery 리스크 감소, M115→M117→M130 완전성 강화 | Marine engineering evidence 품질 의존 | 165,000.00 AED | High | 8.00 weeks |
| D. CostGuard-linked Control | B + invoice/DEM-DET/WH/marine charge evidence link | Cost dispute 대응력 향상, DEM/DET 조기경보 | RateRef/CostGuard 도메인과 동기화 필요 | 120,000.00 AED | Medium | 7.00 weeks |

**Recommended path:** Option B를 base로 적용하고, AGI/DAS·OOG 물량은 Option C gate를 우선 붙인다. DEM/DET와 WH/marine charge dispute가 많은 월에는 Option D를 병행한다.

---

## 8. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Duration | Work package | KPI / Exit criterion | Owner |
|---|---:|---|---|---|
| Prepare | 1.00 week | source inventory, identifier dictionary, route/stage/milestone alignment, legacy term scan | Required source coverage ≥ 95.00%; forbidden route-code leakage = 0.00 | Data Steward / Ontology Lead |
| Pilot | 2.00 weeks | 1 port, 1 warehouse, 1 AGI/DAS route, 1 MIR/SHU route, 1 OSD case replay | M92→M100→M130 trace completeness ≥ 95.00%; AGI/DAS gate = 100.00% | Logistics Ops |
| Build | 4.00 weeks | Foundry Object/Link Types, Actions, SHACL/SPARQL gates, site documents and claim workflow | Validation p95 < 5.00s; SiteReceiptDocCompleteness ≥ 98.00% | Digital / Foundry Team |
| Operate | ongoing | daily blocker board, DEM/DET alert, OSD/NCR pack, GRN closure, human-gate review | DEM/DET alert lead time ≥ 72.00 hrs; HumanGate leakage = 0.00건 | Logistics Control Tower |
| Scale | 6.00 weeks | marine-linked gates, CostGuard evidence, route risk analytics, site issue dashboard | MaterialTraceCoverage ≥ 98.00%; QuantityReconciliationAccuracy = 100.00% | PMO / Cost / Marine |

---

## 9. Automation notes (RPA/LLM/Sheets/TG hooks)

### 9.1 Foundry Functions

| Function | Input | Output | Gate |
|---|---|---|---|
| `resolveAnyKey` | BL/container/DO/invoice/case/HVDC code | `ShipmentUnit` + confidence | confidence < 0.95 → review |
| `computeCurrentStage` | milestone events | `JourneyStage` | missing predecessor → blocker |
| `validateMaterialGate` | case + docs + permits + milestones | pass/warn/block | action submit gate |
| `validateAGIDASGate` | destination + route + M115/M116/M117/M130 | pass/block | M130 gate |
| `openOSDRClaimPack` | M132 + inspection evidence | OSDR/NCR/Claim draft | QA/QC approval |
| `linkCostEvidence` | M92/M100/M110/M115/M130 events + invoice lines | cost evidence link | CostGuard remains cost domain |

### 9.2 RPA Hooks

| Hook | Trigger | Action |
|---|---|---|
| `ATLPReleaseSync` | BOE/DO status change | update `CustomsReleaseGate`, create M90/M91/M92 candidate |
| `GateOutBot` | port gate-out feed | create M100 candidate; alert if M92 missing |
| `WMSReceiptBot` | WMS receipt | create M110 candidate; open WHP handoff reference |
| `MOSBStagingBot` | M121 or direct M100 for AGI/DAS | open M115 staging checklist |
| `MarineReadinessBot` | M115 completed | request stowage/lashing/stability/weather proof before M117 |
| `SiteReceiptBot` | site delivery note / MRR | create M130/SiteReceipt candidate |
| `OSDRClaimBot` | M132 / OSDR upload | create exception, NCR/claim draft, proof artifact |
| `GRNClosureBot` | POD/GRN posted | close M140 if quantities reconcile |

### 9.3 LLM Guardrail

1. LLM may summarize CI/PL/BL/BOE/DO/MRR/MRI/POD/GRN/OSDR and propose evidence links.
2. LLM shall not write M100/M110/M115/M117/M130/M140 directly without an approved Action.
3. LLM must preserve original unit/currency/date strings and normalized values separately.
4. LLM output must include confidence, source document, page/field reference, and reviewer requirement when confidence < 0.92.
5. Any regulated material, high-value material, OOG/heavy lift, or AGI/DAS exception requires human-gate.

### 9.4 Sheets / Excel Mapping

| Sheet / dataset | Required normalized columns |
|---|---|
| Shipment tracker | `shipmentUnitId`, `caseNo`, `blNo`, `containerNo`, `routingPattern`, `declaredDestination`, `currentStage` |
| Port/customs | `boeNo`, `doNo`, `m92Actual`, `m100Actual`, `permitStatus`, `gatePassStatus` |
| Warehouse | `m110Actual`, `m111Actual`, `m120Actual`, `m121Actual`, `whpRef`, `stockStatus` |
| MOSB/marine | `m115Actual`, `m116Actual`, `m117Actual`, `marineGateStatus`, `lctVoyageNo` |
| Site | `m130Actual`, `m131Actual`, `m132Actual`, `m140Actual`, `mrrNo`, `mriNo`, `podNo`, `grnNo`, `osdrNo` |
| Cost evidence | `invoiceNo`, `invoiceLineNo`, `chargeType`, `evidenceMilestone`, `costGuardRef` |

### 9.5 TG / Alert Hooks

| Alert | Condition | Recipient role |
|---|---|---|
| `DO_RELEASE_NO_GATEOUT` | M92 actual + 72.00 hrs and no M100 | Port / Customs / Transport Lead |
| `AGIDAS_MISSING_MOSB` | AGI/DAS M130 candidate without M115 | Marine Lead + Site Logistics |
| `M117_BLOCKED` | marine readiness gate incomplete | Marine / HSE / Heavy Lift Engineer |
| `OSD_OPEN` | M132 or OSDR uploaded | QA/QC + Claims |
| `GRN_OVERDUE` | M130 + 48.00 hrs without M140 | Site Logistics |
| `COST_EVIDENCE_MISMATCH` | invoice line lacks matching material event | Cost Control Lead |

---

## 10. QA checklist & Assumptions(가정:)

### 10.1 QA Checklist

| No. | Check | Pass criterion |
|---:|---|---|
| 1.00 | Master spine alignment | Uses `ShipmentUnit`, `JourneyStage`, `JourneyLeg`, `MilestoneEvent` |
| 2.00 | Route dictionary | Uses `PRE_ARRIVAL`, `DIRECT`, `WH_ONLY`, `MOSB_DIRECT`, `WH_MOSB`, `MIXED` only |
| 3.00 | Flow Code boundary | `confirmedFlowCode` appears only as WHP read-only reference or boundary rule |
| 4.00 | MOSB classification | MOSB is `OffshoreStagingNode` / `MarineInterfaceNode`, not Warehouse |
| 5.00 | Document boundary | CI/PL/BL/BOE/DO/MRR/MRI/POD/GRN/OSDR are evidence, not transaction owner |
| 6.00 | Customs release | M100 requires M92 and blocker-free permit status |
| 7.00 | DEM/DET alert | M92→M100 delay > 72.00 hrs creates alert |
| 8.00 | WH interface | M110/M111/M120/M121 linked without assigning `confirmedFlowCode` |
| 9.00 | AGI/DAS gate | M130 blocked without M115 and marine chain evidence/exception |
| 10.00 | Marine gate | M117 requires stowage/lashing/stability/weather approval or exception |
| 11.00 | Site receipt | M130 creates/links `SiteReceipt` and MRR evidence |
| 12.00 | Inspection outcome | M131 creates MAR; M132 creates OSDR/Exception |
| 13.00 | Quantity reconciliation | dispatched = accepted + OSD ± 0.00 unless approved variance |
| 14.00 | GRN closure | M140 requires POD/GRN and, where applicable, MRS/MIS |
| 15.00 | Claim lifecycle | M150/M160 require OSDR/NCR/approval trail |
| 16.00 | Cost handoff | material events support InvoiceLine evidence only; CostGuard verdict stays in cost domain |
| 17.00 | PII masking | phone/e-mail/driver contact data masked or tokenized |
| 18.00 | Validation latency | p95 < 5.00s for gate query |
| 19.00 | Audit trail | blocked/overridden actions carry `ApprovalAction` + `AuditRecord` |
| 20.00 | Legacy term scan | no invalid route-code terms in schema/prose |

### 10.2 Assumptions(가정:)

1. `CONSOLIDATED-00` remains canonical; this extension does not override master spine definitions.
2. Authority requirements and permit logic must be refreshed through RAG/current SOP before operational approval on the action date.
3. WMS owns warehouse storage/handling detail; `CONSOLIDATED-06` only links warehouse events and WHP evidence.
4. Marine engineering approvals are external human-gated approvals; ontology validation checks readiness and evidence consistency only.
5. Cost rates, FX, invoice line verdicts, and CostGuard bands are owned by `CONSOLIDATED-05`.
6. All PII in FMC/personnel/driver/contact sources is masked before dashboard or KG write.
7. Numeric calculations use source unit and source currency unless a downstream approved policy explicitly normalizes them.

### 10.3 ZERO / Fail-safe Table

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Customs gate | BOE/DO/permit evidence missing | illegal release / port hold / DEM-DET | BOE, DO, permit, clearance timestamp | block M100 and request customs evidence |
| WH gate | M110 event missing for WH route | phantom stock / cost mismatch | WMS receipt, WH appointment, warehouse event | block WH stock creation |
| MOSB gate | AGI/DAS lacks M115/M116/M117 | offshore delivery trace break | MOSB staging, LCT load, sail-away approval | block M130 unless approved exception |
| Site gate | MRR/MRI/POD/GRN missing | receipt/issue mismatch | MRR, MRI, POD, GRN, MRS/MIS | block M140 closure |
| OSD gate | OSD without OSDR/NCR proof | claim leakage | OSDR, photos, inspection report, NCR | open exception/claim and block closeout |
| Cost gate | invoice line lacks material event evidence | overbilling / dispute | invoice line, milestone, task, rate evidence | route to CostGuard review |

### 10.4 Compatibility Patch Register — 5.00 Parallel Lanes

| Lane | Review focus | Patch applied | Status |
|---:|---|---|---|
| 1.00 | Master spine / AGENTS | Route status normalized to `RoutingPattern + JourneyStage + MilestoneEvent + JourneyLeg`; Flow Code route semantics removed | PASS |
| 2.00 | Warehouse boundary | `WarehouseHandlingProfile.confirmedFlowCode` retained only as WHP read-only evidence; material handling cannot assign it | PASS |
| 3.00 | Document/OCR evidence | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, and document proof artifacts treated as evidence-only | PASS |
| 4.00 | Marine/MOSB/site chain | MOSB kept as offshore staging; AGI/DAS M115→M116→M117→M130 gate strengthened | PASS |
| 5.00 | Port/cost/ops integration | Port planned route, CostGuard evidence handoff, and operations analytics linked without ownership collision | PASS |

---

## 11. CmdRec

```text
/switch_mode LATTICE + /logi-master cert-chk --deep --KRsummary
/logi-master report --deep --AEDonly
/visualize_data --type=heatmap CONSOLIDATED-06-validation-report.json
```
