---
title: "HVDC Port Operations & OFCO Service Ontology — Consolidated"
type: "ontology-design"
domain: "port-operations"
sub-domains:
  - port-call-control
  - ofco-system
  - port-agency
  - terminal-services
  - service-event-evidence
  - tariff-reference
  - routing-evidence
  - release-and-gate-control
  - dem-det-evidence
  - bilingual-service-mapping
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "OFCO, PortCall, ServiceEvent, TariffRef, port-release evidence, and port-routing evidence hub"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - GS1-EPCIS
  - DCSA-T&T
  - UN-CEFACT-BSP-RDM
  - WCO-DM
  - ICC-Incoterms-2020
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
source_files:
  - 2_EXT-01-hvdc-ofco-port-ops-en.md
  - 2_EXT-02-hvdc-ofco-port-ops-ko.md
  - legacy_OFCO_subject_mapping_notes
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-08-communication.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
semantic_patch:
  - "Port domain owns PortCall, PortServiceEvent, Rotation, OFCO service evidence, and port-release evidence only."
  - "Port records plannedRoutingPattern and declaredDestination as evidence; it does not own ShipmentRoutingPattern final truth or WarehouseHandlingProfile.confirmedFlowCode."
  - "MOSB is OffshoreStagingNode / MarineInterfaceNode, not Warehouse."
  - "OFCO/SAFEEN/ADP invoice/service mapping is evidence for CostGuard; final cost verdict remains in CONSOLIDATED-05."
  - "M90/M91/M92/M100 release and gate evidence is exposed to material handling, DEM/DET, and operations layers without redefining their transaction truth."
---

# hvdc-port-operations · CONSOLIDATED-07

## 1. ExecSummary *(KR + ENG-KR one-liners)*

`CONSOLIDATED-07`은 HVDC Logistics KG의 **PortCall + OFCO ServiceEvent + TariffRef + port-release evidence extension**이다. 본 문서는 항만 입항, berth/channel/pilot/tug/PHC/port dues, OFCO/SAFEEN/ADP invoice evidence, Rotation 기반 identity, port clearance handoff, gate-out evidence를 `ShipmentUnit`에 연결한다.

비즈니스 임팩트는 **Rotation/Invoice/Samsung Ref/HVDC Code Any-key traceability**, **항만 서비스·요율·청구 증빙 일치**, **M90→M92→M100 release delay 및 DEM/DET exposure 조기 감지**, **AGI/DAS MOSB 필요 경로의 port evidence 누락 차단**이다.

기술 해법은 `PortCall`, `PortServiceEvent`, `PortRotation`, `PortClearanceCase`, `PortReleaseGate`, `TariffRef`, `PriceCenter`, `CostCenter`, `PortEvidenceAssertion`을 RDF/OWL로 정규화하고, SHACL/SPARQL gate로 identity·routing evidence·service tariff·release chronology를 검증하는 것이다.

KPI 목표는 `PortCallLinkCoverage ≥ 95.00%`, `ServiceEvidenceCompleteness ≥ 98.00%`, `RoutingEvidenceAccuracy = 100.00%`, `PortInvoiceNumericIntegrity = 100.00%`, `DEMDETClockCoverage ≥ 95.00%`, `Validation p95 < 5.00s`이다.

**ENG-KR one-liner:** Port owns port-call and service evidence; route truth remains in `ShipmentRoutingPattern`, warehouse handling remains in `WarehouseHandlingProfile`, and CostGuard verdict remains in invoice-cost.

---

## 2. Schema (RDF/OWL + SHACL 요약)

### 2.1 Governance & Scope Boundary

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-07` owns **PortCall**, **PortRotation**, **PortServiceEvent**, **PortClearanceCase**, **PortReleaseGate**, **PortServiceOrder**, **TariffRef**, **PriceCenter**, **CostCenter mapping evidence**, and **OFCO service proof** only.
3. Program-wide shipment visibility uses `ShipmentRoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
4. Port may record `plannedRoutingPattern`, `declaredDestination`, `offshoreTransitRequired`, and `importRoutingDecision` as evidence. Port does not assign final route truth without an approved master action.
5. `WarehouseHandlingProfile.confirmedFlowCode` is warehouse-only and is created/confirmed under `CONSOLIDATED-02`; port never owns warehouse handling classification.
6. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; port may flag offshore transit requirement but must not type MOSB as Warehouse.
7. Port service and OFCO invoice facts provide evidence for `CONSOLIDATED-05`; the final CostGuard band, approval hold, and payment decision remain outside this document.
8. Document/OCR and communication records can attach evidence through `Document`, `VerificationResult`, `CommunicationEvent`, `ApprovalAction`, and `AuditRecord`, but they do not redefine port execution truth.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-07 | Delegated / excluded |
|---|---|---|
| Port call identity | Rotation, vessel/voyage, port/terminal/berth, ATA/ATD, port status | Global identifier policy in `CONSOLIDATED-00` |
| Port services | Channel crossing, pilotage, tug, berthing, PHC, port dues, waste, FW supply, equipment, manpower, gate pass, document processing | Final AP payment and CostGuard band in `CONSOLIDATED-05` |
| Port release handoff | BOE/DO/gate-pass evidence, M90/M91/M92/M100 timestamps, release blocker evidence | Customs declaration ownership in `CONSOLIDATED-00/06` |
| Routing evidence | `plannedRoutingPattern`, `declaredDestination`, `offshoreTransitRequired`, `importRoutingDecision` | Final `ShipmentUnit.hasRoutingPattern` ownership in master / approved action |
| MOSB evidence | `offshoreTransitRequired=true`, Port-to-MOSB corridor evidence, AGI/DAS route warning | MOSB staging / LCT / marine execution in `CONSOLIDATED-04/06` |
| Tariff reference | `TariffRef`, `ServiceTariffLine`, provider/service mapping evidence | Contract negotiation and rate ownership in `CONSOLIDATED-05` |
| Port invoice evidence | OFCO/SAFEEN/ADP invoice line evidence, subject parser, rotation linkage, amount arithmetic | Invoice object final audit, approval, payment in `CONSOLIDATED-05` |
| Operations export | Port delay, clearance time, route evidence coverage, DEM/DET clock evidence | Dashboard aggregation in `CONSOLIDATED-09` |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with Port | Not allowed in CONSOLIDATED-07 |
|---|---|---|
| Master spine | Link `PortCall`, `PortServiceEvent`, `MilestoneEvent`, `ShipmentUnit`, `ReleaseOrder` | Redefine `ShipmentRoutingPattern`, milestone dictionary, or identity hierarchy |
| Infrastructure | Read `Port`, `Terminal`, `Berth`, `Gate`, `TransportCorridor`, `AccessPolicy` | Promote node constraints into current authority decision without RAG/SOP evidence |
| Warehouse | Export M100/gate-out evidence to prepare M110; read no WHP class | Assign or calculate `WarehouseHandlingProfile.confirmedFlowCode` |
| Document/OCR | Consume BL/BOE/DO/invoice/permit evidence and OCR confidence | Let OCR mutate `PortCall` or `ReleaseOrder` without approval |
| Marine/Bulk | Provide `offshoreTransitRequired`, port-to-MOSB evidence, cargo profile | Own M115/M116/M117 marine execution or engineering approval |
| Cost | Export `ServiceEvent`, `TariffRef`, `PriceCenter`, `CostCenter`, OFCO line evidence | Own CostGuard result, payment hold, or AP approval |
| Material handling | Export M90/M91/M92/M100 evidence and release blockers | Collapse material custody chain into port service history |
| Communication | Link approval messages as evidence | Redefine logistics object classes or expose unmasked PII |
| Operations | Export port KPIs and exception facts | Replace port evidence model with dashboard-only dimensions |

### 2.4 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Port-origin route code as lifecycle language | `plannedRoutingPattern` + `importRoutingDecision` | Treat as routing evidence only |
| Port-derived warehouse handling class | `WarehouseHandlingProfile.confirmedFlowCode` under `CONSOLIDATED-02` | Remove port ownership |
| Port invoice as final cost verdict | `PortInvoiceEvidence` → `CostEvidenceAssertion` | CostGuard remains in `CONSOLIDATED-05` |
| MOSB modeled as warehouse destination | `OffshoreStagingNode` / `MarineInterfaceNode` | Keep offshore staging semantics |
| Unstructured OFCO subject as transaction truth | `SubjectParseResult` + `EvidenceAssertion` | Require review/action before mutation |

### 2.5 Ontology Layer Map

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Node | `Port`, `Terminal`, `Berth`, `Gate`, `YardArea`, `Channel`, `Anchorage` | Physical port infrastructure |
| Core transaction | `PortCall`, `PortRotation`, `PortClearanceCase`, `PortReleaseGate`, `PortServiceOrder` | Port operation execution objects |
| Service event | `PortServiceEvent`, `ChannelTransitEvent`, `PilotageEvent`, `TugServiceEvent`, `BerthingEvent`, `PHCEvent`, `PortDuesEvent`, `GatePassEvent`, `DocumentProcessingEvent` | Service-level operational evidence |
| Commercial reference | `TariffRef`, `ServiceTariffLine`, `PriceCenter`, `CostCenter`, `ChargeComponentEvidence` | Rate and cost mapping evidence |
| Identity | `Identifier`, `RotationNo`, `OFCOInvoiceNo`, `SAFEENInvoiceNo`, `ADPInvoiceNo`, `SamsungRef`, `HVDCCodeTag`, `BLNo`, `ContainerNo`, `DONo` | Any-key identity cluster |
| Release | `BOEStatusEvidence`, `DeliveryOrderEvidence`, `GatePassEvidence`, `EIREvidence`, `ReleaseBlocker` | M90/M91/M92/M100 control |
| Evidence | `PortEvidenceAssertion`, `VerificationResult`, `AuditRecord`, `ProofArtifact`, `CommunicationEvent` | Provenance and approval evidence |
| KPI | `PortKPI`, `ClearanceTimeMetric`, `ServiceCoverageMetric`, `DEMDETExposureMetric` | Port performance analytics |

### 2.6 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `PortCall` | `portCallId`, `rotationNo`, `vesselName`, `portOfEntry`, `ata`, `status` | `forShipmentUnit`, `atPort`, `hasServiceEvent`, `hasReleaseGate`, `evidencedByDocument` | Primary port transaction object |
| `PortRotation` | `rotationNo`, `carrier`, `vesselName`, `voyageNo`, `eta`, `ata`, `atd` | `identifiesPortCall`, `linkedToBL`, `linkedToInvoice` | Rotation is a strong identity key |
| `PortServiceEvent` | `serviceEventId`, `serviceType`, `provider`, `eventTime`, `qty`, `unit`, `amount`, `currency` | `relatesToPortCall`, `usesTariffRef`, `evidencedByInvoiceLine` | Operational service evidence; not final cost verdict |
| `PortClearanceCase` | `caseId`, `boeNo`, `clearanceStatus`, `clearedAt`, `broker`, `blockerCode` | `forShipmentUnit`, `hasBOEDocument`, `hasPermitEvidence` | M90/M91 interface |
| `PortReleaseGate` | `gateId`, `releaseStatus`, `doNo`, `doReleasedAt`, `gatePassNo`, `gateOutAt` | `forPortCall`, `createsMilestone`, `hasReleaseBlocker` | M92/M100 interface |
| `TariffRef` | `tariffId`, `provider`, `serviceType`, `unit`, `rate`, `currency`, `validFrom`, `validTo` | `appliesToServiceEvent`, `supportsCostEvidence` | Rate reference evidence for cost domain |
| `PriceCenter` | `priceCenterCode`, `priceCenterName`, `serviceFamily` | `classifiesServiceEvent` | OFCO mapping dimension |
| `CostCenter` | `costCenterCode`, `costCenterName`, `costOwner` | `classifiesChargeEvidence` | AP/cost allocation evidence |
| `PortEvidenceAssertion` | `assertionId`, `assertionType`, `confidence`, `sourceSystem`, `createdAt` | `assertsAboutPortCall`, `wasDerivedFrom`, `reviewedByAction` | Evidence-only unless action-approved |
| `ReleaseBlocker` | `blockerId`, `blockerType`, `severity`, `openedAt`, `resolvedAt` | `blocksPortReleaseGate`, `requiresApprovalAction` | Compliance / document / gate blocker |

### 2.7 Object Properties

| Property | Domain → Range | Cardinality | Use |
|---|---|---:|---|
| `port:forShipmentUnit` | `PortCall` → `ShipmentUnit` | 1..n | Connect port call to operational twin |
| `port:atPort` | `PortCall` → `Port` | 1..1 | Port of entry |
| `port:hasTerminal` | `PortCall` → `Terminal` | 0..n | Terminal / berth routing |
| `port:hasServiceEvent` | `PortCall` → `PortServiceEvent` | 0..n | Port service execution evidence |
| `port:usesTariffRef` | `PortServiceEvent` → `TariffRef` | 0..1 | Rate reference |
| `port:evidencedByInvoiceLine` | `PortServiceEvent` → `InvoiceLine` | 0..n | Invoice evidence; cost owns final audit |
| `port:hasReleaseGate` | `PortCall` → `PortReleaseGate` | 0..1 | DO/gate-out gate |
| `port:createsMilestone` | `PortReleaseGate` → `MilestoneEvent` | 0..n | M92/M100 link |
| `port:declaresRoutingEvidence` | `PortCall` → `PortEvidenceAssertion` | 0..n | Planned route evidence |
| `port:hasReleaseBlocker` | `PortReleaseGate` → `ReleaseBlocker` | 0..n | Blocker control |
| `port:hasPriceCenter` | `PortServiceEvent` → `PriceCenter` | 0..1 | OFCO mapping |
| `port:hasCostCenter` | `PortServiceEvent` → `CostCenter` | 0..1 | Cost allocation evidence |
| `port:wasDerivedFrom` | `PortEvidenceAssertion` → `Document` | 1..n | PROV evidence |

### 2.8 Datatype Properties

| Property | Domain | Range | Rule |
|---|---|---|---|
| `port:rotationNo` | `PortCall`, `PortRotation` | `xsd:string` | Required identity key if available |
| `port:plannedRoutingPattern` | `PortCall` | SKOS enum string | Evidence only: `PRE_ARRIVAL`, `DIRECT`, `WH_ONLY`, `MOSB_DIRECT`, `WH_MOSB`, `MIXED` |
| `port:declaredDestination` | `PortCall` | site code string | MIR/SHU/AGI/DAS or approved site code |
| `port:offshoreTransitRequired` | `PortCall` | `xsd:boolean` | True for AGI/DAS unless exception approved |
| `port:importRoutingDecision` | `PortCall` | enum string | `PRE_CLEARANCE`, `NORMAL`, `EXCEPTION`, `HUMAN_REVIEW` |
| `port:ata` | `PortCall` | `xsd:dateTime` | ATA evidence |
| `port:doReleasedAt` | `PortReleaseGate` | `xsd:dateTime` | M92 basis |
| `port:gateOutAt` | `PortReleaseGate` | `xsd:dateTime` | M100 basis |
| `port:serviceType` | `PortServiceEvent` | enum string | Controlled service vocabulary |
| `port:provider` | `PortServiceEvent` | string | OFCO / SAFEEN / ADP / terminal / agency |
| `port:amount` | `PortServiceEvent` | `xsd:decimal` | Evidence amount only |
| `port:currency` | `PortServiceEvent` | enum string | AED/USD allowed unless explicit policy |
| `port:qty` | `PortServiceEvent` | `xsd:decimal` | Numeric integrity required |
| `port:unitRate` | `PortServiceEvent` | `xsd:decimal` | `qty × unitRate = amount ± 0.01` |
| `port:serviceEvidenceConfidence` | `PortEvidenceAssertion` | `xsd:decimal` | Target ≥ 0.92 for OCR-derived evidence |

### 2.9 Controlled Vocabularies

#### 2.9.1 ServiceType

| ServiceType | Provider examples | Cost evidence class | Notes |
|---|---|---|---|
| `CHANNEL_TRANSIT` | SAFEEN | `PortChargeEvidence` | Channel crossing / transit service |
| `PORT_DUES` | ADP | `PortChargeEvidence` | Port dues and authority charges |
| `BERTHING` | ADP / terminal | `PortChargeEvidence` | Berth usage / berthing arrangement |
| `PILOTAGE` | Port authority / agent | `PortChargeEvidence` | Pilot / launch service |
| `TUG_ASSIST` | Tug operator / port authority | `PortChargeEvidence` | Tugboat support |
| `PHC_BULK_HANDLING` | Terminal / port operator | `PortChargeEvidence` | Port handling charge / bulk handling |
| `EQUIPMENT_HIRE` | OFCO / terminal | `PortChargeEvidence` | Crane, forklift, trailer, SPMT support evidence |
| `MANPOWER` | OFCO / terminal | `PortChargeEvidence` | Labor / stevedore evidence |
| `GATE_PASS` | Authority / agent | `ReleaseEvidence` | Gate/access permit evidence |
| `DOCUMENT_PROCESSING` | OFCO / broker | `ServiceEvidence` | Document handling / agency task evidence |
| `FW_SUPPLY` | OFCO / supplier | `AtCostEvidence` | Fresh water supply evidence |
| `CARGO_CLEARANCE_AGENCY` | OFCO / broker | `AgencyFeeEvidence` | Cargo clearance service evidence |

#### 2.9.2 PortStatus

| Status | Meaning | Exit condition |
|---|---|---|
| `PRE_ARRIVAL` | Vessel/cargo expected; port file opened | ATA/M80 evidence |
| `ARRIVED` | PortCall ATA recorded | Customs/terminal review started |
| `UNDER_CLEARANCE` | BOE/DO/permit review active | M91/M92 evidence |
| `RELEASED` | DO released; release gate open | Gate-out executed |
| `GATED_OUT` | M100 complete | Inland haulage custody active |
| `BLOCKED` | One or more release blockers open | blocker resolved / override approved |
| `CLOSED` | Port service and evidence package closed | Cost and operation export complete |

#### 2.9.3 ReleaseBlockerType

| BlockerType | Severity default | Evidence required |
|---|---:|---|
| `BOE_NOT_SUBMITTED` | HIGH | BOE draft/submission evidence |
| `BOE_NOT_CLEARED` | HIGH | clearance confirmation |
| `DO_MISSING` | HIGH | Delivery Order document |
| `GATE_PASS_MISSING` | HIGH | gate/access pass |
| `PERMIT_MISSING` | HIGH | MOIAT/FANR/DCD/ADNOC permit evidence where applicable |
| `DG_OR_OOG_APPROVAL_MISSING` | HIGH | DG/OOG permit/approval |
| `TARIFF_REF_MISSING` | WARN | TariffRef / special approval |
| `ROUTING_EVIDENCE_GAP` | WARN | destination and route evidence |
| `HIGH_VALUE_SERVICE` | HIGH | ApprovalAction if amount > 100,000.00 AED |

### 2.10 RDF/OWL Skeleton

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix port: <http://samsung.com/project-logistics/port#> .
@prefix cost: <http://samsung.com/project-logistics/cost#> .
@prefix doc:  <http://samsung.com/project-logistics/document#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

port:PortCall a owl:Class ;
  rdfs:subClassOf hvdc:ExecutionTransaction ;
  rdfs:label "Port Call" .

port:PortServiceEvent a owl:Class ;
  rdfs:subClassOf hvdc:ServiceEvent ;
  rdfs:label "Port Service Event" .

port:PortReleaseGate a owl:Class ;
  rdfs:subClassOf hvdc:ReleaseGate ;
  rdfs:label "Port Release Gate" .

port:TariffRef a owl:Class ;
  rdfs:subClassOf cost:TariffRef ;
  rdfs:label "Port Tariff Reference" .

port:forShipmentUnit a owl:ObjectProperty ;
  rdfs:domain port:PortCall ;
  rdfs:range hvdc:ShipmentUnit .

port:plannedRoutingPattern a owl:DatatypeProperty ;
  rdfs:domain port:PortCall ;
  rdfs:range xsd:string ;
  rdfs:comment "Port-recorded routing evidence. It does not replace ShipmentUnit.hasRoutingPattern." .

port:declaredDestination a owl:DatatypeProperty ;
  rdfs:domain port:PortCall ;
  rdfs:range xsd:string .

port:offshoreTransitRequired a owl:DatatypeProperty ;
  rdfs:domain port:PortCall ;
  rdfs:range xsd:boolean .

port:hasServiceEvent a owl:ObjectProperty ;
  rdfs:domain port:PortCall ;
  rdfs:range port:PortServiceEvent .

port:usesTariffRef a owl:ObjectProperty ;
  rdfs:domain port:PortServiceEvent ;
  rdfs:range port:TariffRef .
```

### 2.11 Key SHACL Rules

```turtle
port:PortCallShape a sh:NodeShape ;
  sh:targetClass port:PortCall ;
  sh:property [ sh:path port:rotationNo ; sh:minCount 1 ; sh:message "PortCall must carry RotationNo or approved alternate identifier." ] ;
  sh:property [ sh:path port:forShipmentUnit ; sh:minCount 1 ; sh:message "PortCall must link to at least one ShipmentUnit." ] ;
  sh:property [ sh:path port:atPort ; sh:minCount 1 ; sh:message "PortCall must identify port of entry." ] .

port:PlannedRoutingPatternShape a sh:NodeShape ;
  sh:targetClass port:PortCall ;
  sh:property [
    sh:path port:plannedRoutingPattern ;
    sh:in ("PRE_ARRIVAL" "DIRECT" "WH_ONLY" "MOSB_DIRECT" "WH_MOSB" "MIXED") ;
    sh:message "plannedRoutingPattern must use ShipmentRoutingPattern vocabulary and must remain evidence-only."
  ] .

port:AGIDASPortEvidenceShape a sh:NodeShape ;
  sh:targetClass port:PortCall ;
  sh:sparql [
    sh:message "AGI/DAS port calls require offshoreTransitRequired=true and MOSB-compatible plannedRoutingPattern unless exception approved." ;
    sh:select """
      PREFIX port: <http://samsung.com/project-logistics/port#>
      SELECT $this WHERE {
        $this port:declaredDestination ?dest .
        FILTER(?dest IN ("AGI", "DAS"))
        OPTIONAL { $this port:offshoreTransitRequired ?mosbFlag . }
        OPTIONAL { $this port:plannedRoutingPattern ?pattern . }
        OPTIONAL { $this port:hasApprovedException ?exception . }
        FILTER(!BOUND(?exception))
        FILTER(!BOUND(?mosbFlag) || ?mosbFlag != true || !BOUND(?pattern) || ?pattern NOT IN ("MOSB_DIRECT", "WH_MOSB", "MIXED"))
      }
    """ ;
  ] .

port:ServiceNumericIntegrityShape a sh:NodeShape ;
  sh:targetClass port:PortServiceEvent ;
  sh:sparql [
    sh:message "PortServiceEvent amount must equal qty × unitRate within 0.01 when qty and unitRate exist." ;
    sh:select """
      PREFIX port: <http://samsung.com/project-logistics/port#>
      SELECT $this WHERE {
        $this port:qty ?qty ; port:unitRate ?rate ; port:amount ?amount .
        BIND(ABS((?qty * ?rate) - ?amount) AS ?delta)
        FILTER(?delta > 0.01)
      }
    """ ;
  ] .

port:NoWarehouseHandlingClassAtPortShape a sh:NodeShape ;
  sh:targetClass port:PortCall ;
  sh:sparql [
    sh:message "PortCall must not own warehouse handling classification; use WarehouseHandlingProfile in CONSOLIDATED-02." ;
    sh:select """
      PREFIX wh: <http://samsung.com/project-logistics/warehouse#>
      SELECT $this WHERE { $this wh:confirmedFlowCode ?code . }
    """ ;
  ] .
```

### 2.12 Core Rules 3–5개

| Rule ID | Rule | Severity | Business effect |
|---|---|---|---|
| `PORT-ID-001` | Any `PortCall` must resolve to `ShipmentUnit` by Rotation, BL, Container, Samsung Ref, HVDC Code, DO, or invoice key. | BLOCK | No orphan port cost/service records |
| `PORT-ROUTE-001` | `plannedRoutingPattern` is evidence only and must use master `ShipmentRoutingPattern` vocabulary. | BLOCK | No legacy route-code leakage |
| `PORT-AGI-001` | AGI/DAS destination requires `offshoreTransitRequired=true` and MOSB-compatible planned pattern unless approved exception exists. | HIGH | Prevent offshore route evidence gap |
| `PORT-REL-001` | M100 Gate-out requires M92 DO Released and gate-pass/EIR evidence. | BLOCK | Prevent unauthorized release and DEM/DET ambiguity |
| `PORT-SVC-001` | `qty × unitRate = amount ± 0.01`; invoice total check remains with CostGuard. | HIGH | Prevent service-line overcharge / numeric drift |

---

## 3. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 3.1 Foundry Object Type Mapping

| Foundry Object Type | Source dataset | Key properties | Link Types |
|---|---|---|---|
| `PortCall` | OFCO/AD Ports/terminal call file | `rotationNo`, `vesselName`, `voyageNo`, `portOfEntry`, `ata`, `atd`, `status` | `forShipmentUnit`, `atPort`, `hasServiceEvent` |
| `PortRotation` | carrier/agent rotation register | `rotationNo`, `carrier`, `eta`, `ata`, `voyageNo` | `identifiesPortCall`, `linkedToBL` |
| `PortServiceEvent` | OFCO service sheet / invoice line / terminal service log | `serviceType`, `provider`, `qty`, `unitRate`, `amount`, `currency` | `relatesToPortCall`, `usesTariffRef`, `evidencedByInvoiceLine` |
| `PortClearanceCase` | ATLP / broker / customs status | `boeNo`, `status`, `submittedAt`, `clearedAt`, `blockerCode` | `forShipmentUnit`, `hasBOEDocument` |
| `PortReleaseGate` | DO / gate-pass / EIR register | `doNo`, `doReleasedAt`, `gatePassNo`, `gateOutAt` | `forPortCall`, `createsMilestone` |
| `TariffRef` | contract/tariff master | `provider`, `serviceType`, `rate`, `unit`, `validity` | `appliesToServiceEvent` |
| `PriceCenter` | OFCO mapping table | `priceCenterCode`, `serviceFamily` | `classifiesServiceEvent` |
| `CostCenter` | AP/cost-center master | `costCenterCode`, `costOwner` | `classifiesChargeEvidence` |
| `ReleaseBlocker` | validation engine / SOP exception table | `blockerType`, `severity`, `openedAt`, `resolvedAt` | `blocksPortReleaseGate` |
| `PortKPI` | dashboard table | `metricCode`, `targetValue`, `actualValue`, `computedAt` | `measuresPortCall` |

### 3.2 Source-System Integration Points

| Source system | Dataset / payload | Port ontology output | Validation |
|---|---|---|---|
| OFCO | service order, invoice subject, agency task, line amount | `PortServiceEvent`, `PortEvidenceAssertion`, `PriceCenter` | subject parse confidence, service type match |
| SAFEEN | channel crossing / marine service invoice | `ChannelTransitEvent`, `TariffRef` evidence | Rotation and service date match |
| AD Ports / ADP | port dues, terminal/berth/service reference | `PortDuesEvent`, `BerthingEvent`, `TariffRef` | tariff validity and provider match |
| Terminal / port operator | ATA, berth, discharge/gate status | `PortCall`, `PortReleaseGate`, `MilestoneEvent` | chronology M80→M92→M100 |
| Carrier / agent | BL, DO, arrival notice, rotation | `PortRotation`, `DeliveryOrderEvidence` | DO before M100 |
| ATLP / broker | BOE status, duty/tax/permit evidence | `PortClearanceCase`, `ReleaseBlocker` | M90/M91 completeness |
| LDG / OCR | CI/PL/BL/BOE/DO/Invoice extraction | `Document`, `VerificationResult`, `PortEvidenceAssertion` | MeanConf ≥ 0.92, TableAcc ≥ 0.98 |
| WMS | WH receiving M110 handoff | M100 → M110 trace continuity | no WHP assignment at port |
| Marine / MOSB | M115 staging and offshore requirement | `offshoreTransitRequired`, MOSB evidence link | AGI/DAS MOSB chain check |
| Cost / AP | invoice header/lines, RateRef, CostGuard | `ChargeComponentEvidence` feed | no CostGuard verdict at port |
| Communication layer | email/chat approvals | `ApprovalAction`, `AuditRecord` evidence | PII masking, action provenance |

### 3.3 Foundry Link Types

| Link Type | From → To | Rule |
|---|---|---|
| `portCallForShipmentUnit` | `PortCall` → `ShipmentUnit` | Any-key resolver must create/confirm link |
| `serviceForPortCall` | `PortServiceEvent` → `PortCall` | Rotation/date/service provider evidence required |
| `tariffForService` | `TariffRef` → `PortServiceEvent` | Validity window must cover service date |
| `invoiceLineForService` | `InvoiceLine` → `PortServiceEvent` | Cost domain consumes, port does not approve payment |
| `releaseGateForPortCall` | `PortReleaseGate` → `PortCall` | M92/M100 gate evidence |
| `portCallCreatesMilestone` | `PortCall` / `PortReleaseGate` → `MilestoneEvent` | M80/M90/M91/M92/M100 links only |
| `evidenceForPortCall` | `Document` / `CommunicationEvent` → `PortEvidenceAssertion` | Evidence cannot mutate without approved action |
| `blockerForReleaseGate` | `ReleaseBlocker` → `PortReleaseGate` | Open blocker blocks M100 action |

### 3.4 Action Workflow

| Action | Trigger | Pre-checks | Write-back |
|---|---|---|---|
| `ResolvePortCallIdentity` | new Rotation / OFCO invoice / DO / BL | key uniqueness, confidence ≥ 0.95 | link `PortCall` to `ShipmentUnit` |
| `RecordPortArrival` | ATA / arrival notice | vessel/rotation match | create M80 `MilestoneEvent` |
| `RecordBOESubmission` | BOE draft/submission | BOE no., document hash | create/update M90 |
| `RecordBOEClearance` | clearance confirmation | BOE status cleared, permit evidence | create/update M91 |
| `RecordDORelease` | DO release evidence | BL/DO match, carrier/agent evidence | create/update M92 |
| `RecordGateOut` | gate pass / EIR / terminal out | M92 exists, blockers closed | create/update M100 |
| `ClassifyPortService` | invoice/service line parsed | service type confidence, provider, tariff ref | create `PortServiceEvent` |
| `CreatePortCostEvidence` | service event complete | numeric integrity, rotation link | emit evidence to CostGuard |
| `OpenPortReleaseBlocker` | missing BOE/DO/permit/gate evidence | severity and owner | create `ReleaseBlocker` |
| `ApprovePortException` | high severity blocker / high value service | human reviewer, reason, expiry | attach `ApprovalAction` |

### 3.5 OFCO Subject → Service / PriceCenter Mapping

| Subject cue | ServiceType | Cost center evidence | Price center evidence | Owner |
|---|---|---|---|---|
| `SAFEEN` + `Channel` / `Transit` | `CHANNEL_TRANSIT` | `PORT_HANDLING_CHARGE` | `CHANNEL_TRANSIT_CHARGES` | Port evidence → CostGuard |
| `ADP INV` + `Port Dues` | `PORT_DUES` | `PORT_HANDLING_CHARGE` | `PORT_DUES` | Port evidence → CostGuard |
| `Cargo Clearance` | `CARGO_CLEARANCE_AGENCY` | `CONTRACT` | `AGENCY_FEE_FOR_CARGO_CLEARANCE` | Port evidence → CostGuard |
| `Arranging FW Supply` / `FW Supply` | `FW_SUPPLY` | `CONTRACT` | `SUPPLY_WATER_5000IG` | Port evidence → CostGuard |
| `Berthing Arrangement` | `BERTHING` | `CONTRACT_AF_FOR_BA` | `AGENCY_FEE_FOR_BERTHING_ARRANGEMENT` | Port evidence → CostGuard |
| `5000 IG FW` | `FW_SUPPLY` | `AT_COST_WATER_SUPPLY` | `SUPPLY_WATER_5000IG` | Port evidence → CostGuard |
| `Pilot` / `Pilot Launch` | `PILOTAGE` | `PORT_HANDLING_CHARGE` | `PILOTAGE_SERVICE` | Port evidence → CostGuard |
| `Tug` / `Towage` | `TUG_ASSIST` | `PORT_HANDLING_CHARGE` | `TUG_ASSISTANCE` | Port evidence → CostGuard |
| `PHC` / `Bulk Handling` | `PHC_BULK_HANDLING` | `PORT_HANDLING_CHARGE` | `PORT_HANDLING_CHARGE` | Port evidence → CostGuard |
| `Gate Pass` / `Access Pass` | `GATE_PASS` | `PERMIT_OR_ACCESS` | `GATE_PASS_SERVICE` | Port evidence → ReleaseGate |

### 3.6 Milestone Interface

| Port evidence | Canonical milestone | Stage | Downstream consumer |
|---|---|---|---|
| terminal arrival / discharge readiness | M80 ATA | `PORT_ENTRY` | master, operations, material handling |
| BOE submitted | M90 BOE Submitted | `CUSTOMS_CLEARANCE` | customs/material handling |
| BOE cleared | M91 BOE Cleared | `CUSTOMS_CLEARANCE` | release gate, DEM/DET |
| Delivery Order released | M92 DO Released | `CUSTOMS_CLEARANCE` | material handling, cost DEM/DET |
| Gate pass / EIR / terminal gate-out | M100 Gate-out Completed | `INLAND_HAULAGE` | WH/MOSB/Site chain |
| Port service complete | ServiceEvent closeout | port service layer | cost evidence and KPI |

---

## 4. Validation (SPARQL/RAG/Human-gate)

### 4.1 Validation Control Matrix

| Rule ID | Control | Source | Severity | Result target |
|---|---|---|---|---|
| `PORT-ID-001` | PortCall must resolve to ShipmentUnit | Rotation/BL/DO/Invoice/Samsung Ref/HVDC Code | BLOCK | 100.00% linked |
| `PORT-ROUTE-001` | `plannedRoutingPattern` enum only, evidence-only | PortCall | BLOCK | 100.00% valid enum |
| `PORT-AGI-001` | AGI/DAS must have MOSB-compatible evidence | PortCall + destination | HIGH | 100.00% gate coverage |
| `PORT-REL-001` | M100 requires M92 + gate-pass/EIR | ReleaseGate | BLOCK | 100.00% chronology |
| `PORT-SVC-001` | Service line numeric integrity | ServiceEvent | HIGH | amount delta ≤ 0.01 |
| `PORT-TAR-001` | ServiceEvent should map to TariffRef or approved exception | ServiceEvent | WARN/HIGH | coverage ≥ 95.00% |
| `PORT-COST-001` | CostGuard verdict not written by port domain | ServiceEvent / CostEvidence | BLOCK | 0.00 unauthorized verdicts |
| `PORT-WH-001` | No WHP classification on PortCall | PortCall | BLOCK | 0.00 violations |
| `PORT-PII-001` | Routine port output must mask phone/e-mail | Communication/personnel evidence | BLOCK | 0.00 PII leakage |

### 4.2 SPARQL — Any-key PortCall Resolution

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX port: <http://samsung.com/project-logistics/port#>
PREFIX id:   <http://samsung.com/project-logistics/id#>

SELECT ?portCall ?keyType ?keyValue ?unit
WHERE {
  ?portCall a port:PortCall ;
            id:hasIdentifier ?key .
  ?key id:keyType ?keyType ;
       id:keyValue ?keyValue .
  OPTIONAL { ?portCall port:forShipmentUnit ?unit . }
  FILTER(!BOUND(?unit))
}
ORDER BY ?keyType ?keyValue
```

### 4.3 SPARQL — AGI/DAS Offshore Evidence Gap

```sparql
PREFIX port: <http://samsung.com/project-logistics/port#>

SELECT ?portCall ?rotationNo ?dest ?plannedPattern ?mosbFlag
WHERE {
  ?portCall a port:PortCall ;
            port:rotationNo ?rotationNo ;
            port:declaredDestination ?dest .
  OPTIONAL { ?portCall port:plannedRoutingPattern ?plannedPattern . }
  OPTIONAL { ?portCall port:offshoreTransitRequired ?mosbFlag . }
  OPTIONAL { ?portCall port:hasApprovedException ?exception . }
  FILTER(?dest IN ("AGI", "DAS"))
  FILTER(!BOUND(?exception))
  FILTER(!BOUND(?mosbFlag) || ?mosbFlag != true || !BOUND(?plannedPattern) || ?plannedPattern NOT IN ("MOSB_DIRECT", "WH_MOSB", "MIXED"))
}
```

### 4.4 SPARQL — M100 Without DO Release

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX port: <http://samsung.com/project-logistics/port#>

SELECT ?gate ?unit ?gateOutAt
WHERE {
  ?gate a port:PortReleaseGate ;
        port:forShipmentUnit ?unit ;
        port:gateOutAt ?gateOutAt .
  FILTER NOT EXISTS { ?gate port:doReleasedAt ?doReleasedAt . }
}
```

### 4.5 SPARQL — Port Service Numeric Variance

```sparql
PREFIX port: <http://samsung.com/project-logistics/port#>

SELECT ?service ?serviceType ?qty ?unitRate ?amount ?delta
WHERE {
  ?service a port:PortServiceEvent ;
           port:serviceType ?serviceType ;
           port:qty ?qty ;
           port:unitRate ?unitRate ;
           port:amount ?amount .
  BIND(ABS((?qty * ?unitRate) - ?amount) AS ?delta)
  FILTER(?delta > 0.01)
}
ORDER BY DESC(?delta)
```

### 4.6 SPARQL — Port Domain Unauthorized Cost Verdict

```sparql
PREFIX port: <http://samsung.com/project-logistics/port#>
PREFIX cost: <http://samsung.com/project-logistics/cost#>

ASK {
  ?service a port:PortServiceEvent ;
           cost:hasCostGuardBand ?band .
}
```

Expected result: `false`. Port exports service and tariff evidence only; `CostGuardResult` belongs to `CONSOLIDATED-05`.

### 4.7 SPARQL — WHP Classification Leakage at Port

```sparql
PREFIX port: <http://samsung.com/project-logistics/port#>
PREFIX wh:   <http://samsung.com/project-logistics/warehouse#>

ASK {
  ?portCall a port:PortCall ;
            wh:confirmedFlowCode ?code .
}
```

Expected result: `false`. Warehouse handling classification is valid only on `WarehouseHandlingProfile`.

### 4.8 RAG Check Policy

| RAG target | Trigger | Required evidence |
|---|---|---|
| MOIAT / customs release SOP | BOE/permit gate changes, customs blocker | current authority/SOP link, reviewed date |
| FANR | regulated/nuclear/radiation-related cargo flag | permit/certificate evidence, reviewer |
| DCD / DG | dangerous goods, fire safety, restricted cargo | DG permit / DCD evidence |
| ADNOC / CICPA / site access | AGI/DAS/offshore/site access | gate pass / access policy evidence |
| AD Ports / terminal tariff | tariff mismatch or new service code | tariff schedule / contract version |
| SAFEEN / marine service | channel/marine service change | provider invoice/service reference |
| Incoterms 2020 | cost/risk responsibility dispute | contract term + delivery point evidence |

RAG output must write `PortEvidenceAssertion` + `AuditRecord`; it must not silently mutate `PortCall`, `ReleaseOrder`, `Invoice`, or `CostGuardResult`.

### 4.9 Human-gate Matrix

| Trigger | Threshold | Gate owner | Action |
|---|---:|---|---|
| Port service / invoice evidence amount | > 100,000.00 AED | Logistics Manager + Cost Owner | approval before CostGuard/payment release |
| Open blocker at M100 | any BLOCK severity | Port Lead + Customs/Material Lead | block gate-out action |
| AGI/DAS without MOSB evidence | any | Marine Lead + Material Lead | route exception or MOSB evidence required |
| TariffRef missing on high value service | > 25,000.00 AED | Cost Owner | attach tariff / special approval |
| DG/OOG permit missing | any | HSE + Port Lead | block release until permit evidence attached |
| RAG source older than approved SOP window | any high-risk gate | Compliance Owner | refresh evidence |
| OCR confidence below threshold | MeanConf < 0.92 or TableAcc < 0.98 | LDG Owner | reprocess / human review |

### 4.10 ZERO / Fail-safe Table

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Identity resolution | Rotation/BL/DO/Invoice key conflict | Wrong shipment release/cost linkage | all candidate keys + source hashes | stop write-back; run Any-key cluster review |
| Release gate | DO/gate-pass/BOE evidence missing | unauthorized gate-out / DEM/DET dispute | BOE, DO, gate pass, EIR | block M100 action |
| AGI/DAS route evidence | MOSB flag/pattern missing | offshore delivery failure | declared destination, route plan, MOSB booking | human gate |
| Service tariff | TariffRef unavailable | overcharge / audit failure | tariff schedule / contract ref | hold CostEvidence export |
| Compliance | MOIAT/FANR/DCD/ADNOC ambiguity | regulatory hold | current SOP/permit evidence | RAG refresh and approval |

---

## 5. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 5.1 Compliance Object Model

| Object | Purpose | Port use |
|---|---|---|
| `RegulatoryRequirement` | authority requirement anchor | maps permit/document requirement to PortCall/ReleaseGate |
| `PermitDocument` | evidence of permit/certification | source evidence for blocker clearance |
| `ComplianceCheck` | validation result | PASS/WARN/HIGH/BLOCK per gate |
| `ReleaseBlocker` | operational blocker | prevents M100 until resolved |
| `ApprovalAction` | human decision | exception/override with actor, reason, expiry |
| `AuditRecord` | provenance trail | source hash, reviewer, timestamp |

### 5.2 Incoterms 2020 Control

| Control | Port implication | Validation |
|---|---|---|
| Cost responsibility | Port dues, terminal handling, agency fee responsibility depends on contract term and delivery point | Link `IncotermTerm`, contract, service event |
| Risk transfer | Gate-out / terminal handover may affect risk status | Link M92/M100 evidence |
| Documentary obligation | CI/PL/BL/BOE/DO/permit evidence required before release | LDG cross-document gate |
| Dispute handling | Port evidence supports cost/claim, not payment approval | CostGuard and claim owner decide |

### 5.3 UAE Regulatory Controls

| Authority / domain | Port trigger | Evidence object | Gate |
|---|---|---|---|
| MOIAT / Customs | import clearance, BOE, duty/tax, certificate | `BOEDocument`, `CustomsEntry`, `PermitDocument` | M90/M91/M92 |
| FANR | regulated cargo requiring nuclear/radiation control | `PermitDocument`, `ComplianceCheck` | before M92/M100 |
| DCD / DG | dangerous goods, flammable or controlled cargo | `DGPermitEvidence`, `HSEApproval` | before terminal release |
| ADNOC / CICPA / site access | AGI/DAS/offshore/security access | `GatePassEvidence`, `AccessPolicy` | before M100 / M115 |
| AD Ports / terminal | port dues, berth, terminal handling, gate-out | `TariffRef`, `ServiceEvent`, `EIR` | service closeout / M100 |
| SAFEEN / marine support | channel transit / marine service | `ServiceEvent`, `TariffRef` | service evidence closeout |

### 5.4 Compliance Blockers

| Blocker | Severity | Default action |
|---|---:|---|
| BOE missing or uncleared | BLOCK | no M92 / no M100 |
| DO missing | BLOCK | no M100 |
| Gate pass missing/expired | BLOCK | no M100 |
| AGI/DAS MOSB evidence missing | HIGH | human gate and route exception |
| DG/OOG permit missing | BLOCK | no release |
| TariffRef missing on high value service | HIGH | hold cost evidence export |
| Unmasked PII in communication evidence | BLOCK | mask before register/write |

### 5.5 Privacy and NDA Guard

Routine port output may include names/roles only when required for accountability. Phone numbers, e-mail addresses, personal IDs, and access-card numbers must be masked before persistence or downstream export. `CommunicationEvent` and `ApprovalAction` references must carry source hash and masked display fields.

---

## 6. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Scope | Pros | Cons | Est. cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A — Port Evidence Lite | PortCall + Rotation + planned routing evidence + basic service mapping | Fast migration, low schema risk, immediate OFCO traceability | Limited tariff automation and DEM/DET analytics | 35,000.00 AED | Medium | 2.00 weeks |
| B — OFCO Service Twin | Full ServiceEvent, TariffRef, PriceCenter/CostCenter evidence, numeric checks | Strong invoice-service audit, reusable CostGuard feed | Needs service taxonomy and tariff table cleanup | 95,000.00 AED | Medium | 5.00 weeks |
| C — Release & DEM/DET Control | M90/M91/M92/M100, release blockers, gate-pass/EIR, DEM/DET evidence | Direct delay/cost prevention, strong material handoff | Requires ATLP/terminal/carrier data quality | 125,000.00 AED | High | 6.00 weeks |
| D — Integrated Port Ops Twin | Options B+C + RAG + communication approvals + dashboard export | Full operational/control twin, best audit posture | Highest integration effort | 185,000.00 AED | Medium | 8.00 weeks |

Recommended default: **Option C** if DEM/DET and release delays are the immediate business pain; **Option D** if OFCO service billing and release-control automation must be deployed together.

---

## 7. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Duration | Work package | Exit KPI |
|---|---:|---|---|
| Prepare | 1.00 week | inventory source columns, normalize Rotation/Invoice/BL/DO keys, define service taxonomy | Key dictionary coverage ≥ 95.00% |
| Pilot | 2.00 weeks | build `PortCall`, `PortServiceEvent`, `plannedRoutingPattern`, `declaredDestination` mapping on sample OFCO/ADP/SAFEEN set | PortCallLinkCoverage ≥ 90.00% |
| Build | 3.00 weeks | implement SHACL rules, Any-key resolver, M90/M91/M92/M100 release gate, TariffRef links | Validation pass rate = 100.00% |
| Operate | continuous | daily exception queue, release blocker alerts, service numeric variance, high-value approval | Open critical blockers age < 24.00 hrs |
| Scale | continuous | integrate operations dashboard, CostGuard feed, RAG refresh, communication approvals | Port evidence completeness ≥ 98.00% |

### 7.1 KPI Dictionary

| KPI | Formula | Target |
|---|---|---:|
| `PortCallLinkCoverage` | linked PortCalls / total PortCalls × 100.00 | ≥ 95.00% |
| `ServiceEvidenceCompleteness` | ServiceEvents with provider+type+amount+evidence / total | ≥ 98.00% |
| `RoutingEvidenceAccuracy` | correct planned route evidence / reviewed PortCalls | 100.00% |
| `AGIDASMOSBFlagCoverage` | AGI/DAS with MOSB evidence / AGI/DAS PortCalls | 100.00% |
| `ReleaseChronologyIntegrity` | M92 before M100 cases / gated-out cases | 100.00% |
| `TariffRefCoverage` | ServiceEvents with TariffRef or approved exception / total | ≥ 95.00% |
| `PortInvoiceNumericIntegrity` | service lines passing qty×rate and amount checks / total | 100.00% |
| `DEMDETClockCoverage` | M92/M100 clock pairs / eligible cases | ≥ 95.00% |
| `ValidationLatencyP95` | validation p95 runtime | < 5.00s |
| `PIILeakage` | unmasked e-mail/phone hits in routine output | 0.00 |

---

## 8. Automation notes (RPA/LLM/Sheets/TG hooks)

### 8.1 Foundry Functions

| Function | Input | Output | Guard |
|---|---|---|---|
| `resolvePortCallAnyKey()` | Rotation, BL, DO, invoice, container, Samsung Ref, HVDC Code | `PortCall` ↔ `ShipmentUnit` link candidates | confidence ≥ 0.95 or human review |
| `classifyPortServiceEvent()` | invoice subject, provider, amount, service date | `PortServiceEvent`, `PriceCenter`, `CostCenter` | service taxonomy + TariffRef check |
| `validatePortReleaseGate()` | BOE/DO/gate-pass/EIR evidence | M90/M91/M92/M100 status, blockers | no M100 if BLOCK open |
| `emitPortCostEvidence()` | service event + tariff evidence | Cost evidence payload | no CostGuard verdict written by port |
| `detectAGIDASPortEvidenceGap()` | destination + planned route + MOSB flag | exception / alert | AGI/DAS requires MOSB evidence |
| `openPortReleaseBlocker()` | missing/invalid release evidence | `ReleaseBlocker` | owner and SLA required |

### 8.2 RPA Hooks

| Hook | Trigger | Action |
|---|---|---|
| `OFCO_INVOICE_PARSE` | new OFCO/SAFEEN/ADP invoice | subject parse, service mapping, numeric check |
| `ROTATION_MATCH` | new rotation/port call file | Any-key cluster update |
| `DO_RELEASE_CHECK` | DO release event | create/update M92 |
| `GATE_OUT_CHECK` | EIR/gate pass event | create/update M100 if M92 exists |
| `TARIFF_GAP_ALERT` | missing tariff on service event | alert Cost Owner |
| `AGIDAS_MOSB_ALERT` | AGI/DAS without MOSB evidence | alert Marine + Material Leads |

### 8.3 LLM Guardrail

LLM extraction may propose `serviceType`, `PriceCenter`, `CostCenter`, `plannedRoutingPattern`, and `ReleaseBlocker` candidates. It must write only `PortEvidenceAssertion` until a Foundry Action approves the target object update. Confidence below 0.92 must route to human review.

### 8.4 Sheets / Excel Mapping

| Column / field | Ontology property | Rule |
|---|---|---|
| OFCO Invoice No | `id:OFCOInvoiceNo` | identifier only |
| SAFEEN Invoice No | `id:SAFEENInvoiceNo` | identifier only |
| ADP Invoice No | `id:ADPInvoiceNo` | identifier only |
| Rotation / Rot# | `port:rotationNo` | primary PortCall key |
| Subject | `port:subjectText` → `SubjectParseResult` | parse to service evidence |
| Vessel | `port:vesselName` | normalize name |
| ETA / ATA / ATD | `port:eta`, `port:ata`, `port:atd` | ISO datetime |
| Port / Terminal / Berth | `port:atPort`, `port:hasTerminal`, `port:berthName` | node master lookup |
| Final destination | `port:declaredDestination` | MIR/SHU/AGI/DAS/site code |
| Route pattern | `port:plannedRoutingPattern` | evidence only |
| Qty / EA / Rate / Amount | `port:qty`, `port:unitRate`, `port:amount` | numeric integrity |
| Currency | `port:currency` | preserve original currency |
| BOE / DO / Gate Pass | `port:boeNo`, `port:doNo`, `port:gatePassNo` | release gate evidence |

### 8.5 Telegram / Alert Hooks

```text
[PORT-GATE][BLOCK] Rotation={rotationNo} Unit={shipmentUnitId} Missing={blockerType} Owner={owner} SLA={hours}h
[PORT-COST][WARN] Service={serviceType} Provider={provider} Amount={amount} {currency} MissingTariffRef={true|false}
[PORT-ROUTE][HIGH] Destination={AGI|DAS} plannedRoutingPattern={pattern} MOSBFlag={true|false} Action=Review
[PORT-DEMDET][WARN] M92={doReleasedAt} M100=missing Age={hours}h FreeTime={freeTimeHours}h
```

---

## 9. QA checklist & Assumptions(가정:)

### 9.1 QA Checklist

| # | Check | Target |
|---:|---|---|
| 1.00 | Frontmatter version is `2.0-final` | PASS |
| 2.00 | `spine_ref` points to `CONSOLIDATED-00-master-ontology.md` | PASS |
| 3.00 | `checked_against` includes `00`~`09`, AGENTS, Review, Palantir blueprint | PASS |
| 4.00 | Port does not own `WarehouseHandlingProfile.confirmedFlowCode` | PASS |
| 5.00 | Port uses `plannedRoutingPattern` as evidence only | PASS |
| 6.00 | MOSB modeled as `OffshoreStagingNode` / `MarineInterfaceNode` | PASS |
| 7.00 | AGI/DAS offshore evidence gate exists | PASS |
| 8.00 | M90/M91/M92/M100 release chronology defined | PASS |
| 9.00 | Port service amount arithmetic rule defined | PASS |
| 10.00 | TariffRef and service mapping integrated with Cost domain only as evidence | PASS |
| 11.00 | CostGuard verdict excluded from port ownership | PASS |
| 12.00 | Document/OCR evidence-only boundary retained | PASS |
| 13.00 | Communication layer evidence-only boundary retained | PASS |
| 14.00 | RAG gate defined for current authority/SOP dependencies | PASS |
| 15.00 | High-value Human-gate threshold = 100,000.00 AED | PASS |
| 16.00 | Validation p95 target < 5.00s | PASS |
| 17.00 | PII masking rule included | PASS |
| 18.00 | Options ≥3 included with cost/risk/time | PASS |
| 19.00 | Roadmap uses Prepare→Pilot→Build→Operate→Scale | PASS |
| 20.00 | CmdRec included | PASS |

### 9.2 Assumptions(가정:)

| Assumption | Impact | Mitigation |
|---|---|---|
| OFCO/SAFEEN/ADP subject lines contain enough rotation/service clues for first-pass mapping | Some service lines may require manual review | use `SubjectParseResult.confidence` and review queue |
| Rotation number is the strongest port-call identity key when available | Missing rotation can create orphan service evidence | Any-key fallback using BL/DO/Invoice/Samsung Ref/HVDC Code |
| AGI/DAS requires MOSB-compatible offshore evidence unless approved exception exists | Prevents accidental direct onshore modeling | human-gated route exception |
| Current tariff and authority rules may change | Hard-coded legal/fee assumptions become stale | RAG refresh before approval/action |
| Port service amount is evidence, not payment truth | Cost approval remains consistent | CostGuard consumes evidence and writes final verdict |
| Communication evidence may include PII | Privacy/NDA leakage risk | mask routine outputs and store source hash only |

### 9.3 Compatibility Patch Register — 5.00 Parallel Lanes

| Lane | Focus | Corpus checked | Finding | Patch applied | Result |
|---:|---|---|---|---|---|
| 1.00 | Master spine | `CONSOLIDATED-00`, AGENTS, Review | Port must be PortCall/ServiceEvent/Tariff hub, not route owner | frontmatter, scope, governance, identity, milestone links normalized | PASS |
| 2.00 | Flow/WHP boundary | `CONSOLIDATED-02`, AGENTS | WH handling class belongs only to WHP | port-owned WH class language removed; `plannedRoutingPattern` kept evidence-only | PASS |
| 3.00 | Document/OCR + Cost | `CONSOLIDATED-03`, `CONSOLIDATED-05` | OCR and port service lines are evidence; CostGuard owns verdict | `PortEvidenceAssertion`, `TariffRef`, `PriceCenter`, `CostCenter` export model added | PASS |
| 4.00 | Marine/material/infrastructure | `CONSOLIDATED-01`, `04`, `06` | AGI/DAS needs MOSB-compatible route evidence and M115 chain downstream | AGI/DAS port evidence gate, M90/M91/M92/M100 interface, MOSB non-warehouse rule added | PASS |
| 5.00 | Operations/comms/artifact hygiene | `CONSOLIDATED-08`, `09`, PDF blueprint | Need evidence-only communication, KPI export, no PII, validation automation | KPI dictionary, RAG/Human-gate, PII guard, automation hooks, JSON report added | PASS |

---

## 10. CmdRec (1–3)

```text
/switch_mode PRIME + /logi-master report --deep --KRsummary
/logi-master invoice-audit --AEDonly --deep
/logi-master cert-chk --deep --KRsummary
```
