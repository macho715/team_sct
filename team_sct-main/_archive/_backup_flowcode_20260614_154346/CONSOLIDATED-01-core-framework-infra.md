---
title: "HVDC Core Framework & Infrastructure Ontology — Consolidated"
type: "ontology-design"
domain: "framework-infrastructure"
sub-domains:
  - logistics-framework
  - node-infrastructure
  - construction-logistics
  - transport-network
  - standards-alignment
  - compliance-control
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "high-level standards, regulations, infrastructure nodes, and project framework extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - GS1-EPCIS-CBV
  - DCSA-Track-and-Trace
  - UN-CEFACT-BSP-RDM
  - WCO-DM-4.2.0
  - ICC-Incoterms-2020
  - UN-LOCODE-2025-1
  - ISO-6346
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - BIMCO-SUPPLYTIME-2017
source_files:
  - 1_CORE-01-hvdc-core-framework.md
  - 1_CORE-02-hvdc-infra-nodes.md
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-08-communication.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
validation_passes: 5
---

# hvdc-core-framework-infra · CONSOLIDATED-01

## 1. ExecSummary

`CONSOLIDATED-01`은 HVDC Logistics KG의 **reference framework + infrastructure-node extension**이다. 본 문서는 `CONSOLIDATED-00` master spine을 재정의하지 않고, 표준·규정·노드·운영 제약을 `ShipmentUnit`, `JourneyLeg`, `MilestoneEvent`, `LocationNode`, `RegulatoryRequirement`에 연결하는 상위 참조 레이어로만 동작한다.

비즈니스 임팩트는 **Port/Customs/WH/MOSB/Site 노드별 release blocker 조기 검출**, **DEM/DET·GatePass·Permit 지연 감소**, **Any-key 기반 프로젝트 물류 traceability**이다. 기술 해법은 RDF/OWL class boundary, SHACL gate, SPARQL node-risk query, Foundry Object/Link mapping을 결합한다.

KPI 목표는 `NodeMasterCoverage ≥ 95.00%`, `PermitEvidenceCompleteness ≥ 98.00%`, `RoutingPatternValidation = 100.00%`, `Validation p95 < 5.00s`, `HumanGate leakage = 0.00건`이다.

**ENG-KR one-liner:** Standards and infrastructure nodes are reference anchors; execution truth still flows through `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-01` provides high-level standards, regulations, infrastructure nodes, and framework constraints only.
3. Program-wide shipment visibility uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
4. Warehouse handling classification is owned only by `WarehouseHandlingProfile` in `CONSOLIDATED-02` and triggered by M110 WH Received.
5. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; it is not a top-level `Warehouse`.
6. `CONSOLIDATED-08` is an evidence layer. It may attach `CommunicationEvent`, `ApprovalAction`, and `AuditRecord`; it does not redefine logistics execution classes.
7. Extension-local legacy route-code language is migration debt and must not be promoted into this framework document.

### 2.2 Scope Matrix

| Scope item | Included in CONSOLIDATED-01 | Excluded / delegated |
|---|---|---|
| Standards alignment | UN/CEFACT, WCO, DCSA, ICC, UN/LOCODE, ISO, BIMCO, PROV-O, OWL-Time, SKOS, DQV | Detailed API payloads and carrier-specific integration |
| Infrastructure nodes | Port, terminal, berth, gate, yard, warehouse, offshore staging, site, corridor | Site construction work-pack execution |
| Compliance anchors | MOIAT, FANR, DCD/DG, ADNOC/CICPA/GatePass, Customs, Incoterms | Authority-specific operational truth unless evidenced by current SOP |
| Route semantics | Node capability and allowed route constraints | End-to-end route state machine, which remains in `CONSOLIDATED-00` |
| Warehouse handling | Boundary reference only | WH algorithm and storage classification, which remain in `CONSOLIDATED-02` |
| Marine / OOG | Node capability and gate constraints | LCT, stability, rigging, lashing, which remain in `CONSOLIDATED-04` |
| Cost | Standards and KPI anchors | Invoice line audit and CostGuard, which remain in `CONSOLIDATED-05` |
| Operations analytics | KPI definitions and node risk views | DataFrame/Excel operation mapping, which remains in `CONSOLIDATED-09` |

### 2.3 Corpus Compatibility Anchors

| Source | Required compatibility rule |
|---|---|
| `CONSOLIDATED-00` | Reuse `LocationNode`, `JourneyLeg`, `MilestoneEvent`, `RoutingPattern`, `RegulatoryRequirement`, `PermitDocument` |
| `CONSOLIDATED-02` | Do not assign or calculate WH handling class in this file |
| `CONSOLIDATED-03` | Treat document fields as evidence: `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` |
| `CONSOLIDATED-04` | Use `MarineRoutingPattern` and M115/M116/M117 for offshore execution |
| `CONSOLIDATED-05` | Cost reads route and WH evidence; cost does not own WH handling classification |
| `CONSOLIDATED-06` | Material handling uses `RoutingPattern + MilestoneStatus`; AGI/DAS requires MOSB evidence |
| `CONSOLIDATED-07` | Port records `plannedRoutingPattern` and `declaredDestination` as evidence only |
| `CONSOLIDATED-08` | Evidence only; no core node or route class redefinition |
| `CONSOLIDATED-09` | Consume `hasRoutingPattern`, stock, milestone, and cost semantics; do not redefine them |

---

## 3. Standards Alignment Matrix

### 3.1 Reference Standards

| Standard / authority | Current framework role | Ontology binding | RAG status on 2026-04-27 |
|---|---|---|---|
| UN/CEFACT BSP-RDM | Buy-Ship-Pay semantic reference for party, shipment, consignment, transport means, invoice | `Party`, `Shipment`, `Consignment`, `Document`, `InvoiceLine` | Official UNECE RDM page retained as reference anchor |
| WCO Data Model 4.2.0 | Customs declaration, bond, origin/certificate data alignment | `CustomsEntry`, `BOEDocument`, `HSCode`, `CertificateOfOrigin` | WCO announced v4.2.0 on 2025-07-15 |
| DCSA Track & Trace | Container / shipment event visibility and operational event normalization | `Container`, `CarrierEvent`, `JourneyLeg`, `MilestoneEvent` | Use latest release per DCSA standard documentation; conformance references newer T&T release line |
| ICC Incoterms 2020 | Cost/risk responsibility and delivery obligation | `IncotermTerm`, `RiskTransferPoint`, `CostResponsibility` | Incoterms 2020 remains the official ICC ruleset anchor |
| UN/LOCODE 2025-1 | Port, terminal, city, and trade location code normalization | `LocationNode.unlocode`, `Port.unlocode` | UNECE lists 2025-1 as current published release in 2026 |
| ISO 6346 | Container identification and equipment code | `Container.containerNo`, `Container.isoType` | Stable reference; local validation via check digit required |
| GS1 EPCIS / CBV | Event-centric visibility pattern | `VisibilityEvent`, `MilestoneEvent`, `Disposition` | Use as event model anchor, not as full replacement |
| PROV-O | Provenance and evidence lineage | `AuditRecord`, `Evidence`, `SourceSystem`, `wasDerivedFrom` | Required for document, communication, and RAG evidence |
| OWL-Time | Time interval, instant, duration | `plannedDt`, `estimatedDt`, `actualDt`, `dwellDuration` | Required for milestone and dwell clocks |
| SKOS | Controlled vocabularies and code lists | `RoutingPattern`, `JourneyStage`, `NodeType`, `PermitType` | Required for enum governance |
| DQV | Data quality metadata | `ValidationResult`, `QualityMetric`, `ConfidenceScore` | Required for OCR/KPI trust |
| BIMCO SUPPLYTIME 2017 | Offshore support vessel contract and knock-for-knock responsibility reference | `MarineContract`, `CharterTerm`, `LiabilityRegime` | Official BIMCO page identifies SUPPLYTIME 2017 as the latest edition |

### 3.2 Standards-to-Domain Mapping

| Domain | Primary standard anchor | HVDC object layer | Mandatory validation |
|---|---|---|---|
| Procurement / PO | UN/CEFACT BSP-RDM | `PurchaseOrder`, `Package`, `Vendor`, `MaterialMaster` | PO/package/material link completeness |
| Customs | WCO DM, HS nomenclature | `CustomsEntry`, `BOEDocument`, `HSCode`, `DutyLine` | HS, origin, value, quantity, permit evidence |
| Shipping / carrier | DCSA T&T, ISO 6346 | `Shipment`, `Container`, `BillOfLadingDocument`, `MilestoneEvent` | BL/container/event key resolution |
| Commercial terms | ICC Incoterms 2020 | `IncotermTerm`, `RiskTransferPoint`, `CostResponsibility` | Risk/cost owner matches PO and invoice |
| Port / terminal | UN/LOCODE, DCSA event pattern | `Port`, `Terminal`, `PortCall`, `ServiceEvent` | PortCall→Shipment linkage and node code validity |
| Warehouse | ISO 9001/14001 internal QMS + WH SOP | `Warehouse`, `WarehouseTask`, `WarehouseHandlingProfile` | WH task and storage class gate |
| Offshore / marine | BIMCO SUPPLYTIME 2017 + project marine SOP | `OffshoreStagingNode`, `MarineEvent`, `Vessel`, `LCT` | PTW/FRA/weather/lashing/stability human gate |
| Evidence / audit | PROV-O, DQV | `AuditRecord`, `CommunicationEvent`, `VerificationResult` | Provenance, confidence, hash, reviewer |

---

## 4. Schema — RDF/OWL + SHACL Summary

### 4.1 Core Classes

| Class | Type | Required properties | Purpose |
|---|---|---|---|
| `hvdc:FrameworkStandard` | Reference | `standardCode`, `version`, `authority`, `ragCheckedAt` | Standard registry |
| `hvdc:RegulatoryRequirement` | Reference / compliance | `requirementCode`, `authority`, `scope`, `effectiveStatus` | Compliance condition |
| `hvdc:PermitRequirement` | Compliance | `permitType`, `authority`, `trigger`, `evidenceRequired` | Permit gate |
| `hvdc:IncotermTerm` | Contract reference | `termCode`, `riskTransferPoint`, `costResponsibility` | Contract risk/cost owner |
| `hvdc:LocationNode` | Master / infrastructure | `nodeCode`, `nodeType`, `nodeName`, `countryCode`, `status` | Parent infrastructure node |
| `hvdc:Port` | Infrastructure | `unlocode`, `portAuthority`, `cargoProfile` | Port-of-entry node |
| `hvdc:Terminal` | Infrastructure | `terminalCode`, `terminalType`, `parentPort` | Berth/CY/CFS terminal node |
| `hvdc:Warehouse` | Infrastructure | `warehouseCode`, `storageType`, `capacityProfile` | Warehouse node only |
| `hvdc:OffshoreStagingNode` | Infrastructure | `nodeCode`, `marineInterfaceType`, `supportsLCT` | MOSB / marine interface |
| `hvdc:Site` | Infrastructure | `siteCode`, `siteType`, `receivingCapability` | MIR/SHU/AGI/DAS receiving node |
| `hvdc:TransportCorridor` | Infrastructure | `mode`, `fromNode`, `toNode`, `permitRequired` | Allowed movement corridor |
| `hvdc:AccessPolicy` | Compliance | `policyCode`, `authority`, `locationScope` | GatePass/CICPA/ADNOC access |
| `hvdc:CapacityProfile` | Ops reference | `capacityUnit`, `ratedCapacity`, `currentUtilization` | Node capacity monitoring |
| `hvdc:ServiceCapability` | Ops reference | `capabilityType`, `cargoCategory`, `equipmentRequired` | Node capability match |
| `hvdc:InfrastructureKPI` | KPI | `metricCode`, `targetValue`, `actualValue`, `unit` | Dashboard/KPI control |

### 4.2 Object Properties

| Property | Domain → Range | Cardinality | Meaning |
|---|---|---:|---|
| `hvdc:nodePartOf` | `LocationNode → LocationNode` | N:1 | Terminal/yard/site subdivision hierarchy |
| `hvdc:connectsTo` | `LocationNode → LocationNode` | N:N | Node adjacency for route graph |
| `hvdc:servedByCorridor` | `LocationNode → TransportCorridor` | 1:N | Allowed movement path |
| `hvdc:hasCapability` | `LocationNode → ServiceCapability` | 1:N | Cargo/service support |
| `hvdc:hasCapacityProfile` | `LocationNode → CapacityProfile` | 1:N | Capacity and utilization |
| `hvdc:governedBy` | `LocationNode → RegulatoryRequirement` | N:N | Jurisdictional / authority control |
| `hvdc:requiresPermit` | `TransportCorridor → PermitRequirement` | 0:N | Permit gate |
| `hvdc:hasAccessPolicy` | `LocationNode → AccessPolicy` | 0:N | GatePass/security control |
| `hvdc:supportsRoutingPattern` | `LocationNode → skos:Concept` | 0:N | Allowed route pattern evidence |
| `hvdc:servesJourneyStage` | `LocationNode → skos:Concept` | 0:N | Stage capability |
| `hvdc:operatedBy` | `LocationNode → Party` | 0:N | Operational owner |
| `hvdc:evidencedBy` | `RegulatoryRequirement → Document` | 0:N | Compliance proof |
| `hvdc:triggersHumanGate` | `RegulatoryRequirement → ApprovalAction` | 0:N | Manual approval condition |

### 4.3 Data Properties

| Property | Domain | Range | Constraint |
|---|---|---|---|
| `hvdc:nodeCode` | `LocationNode` | `xsd:string` | Required, unique within project |
| `hvdc:nodeType` | `LocationNode` | enum | `PORT`, `TERMINAL`, `WAREHOUSE`, `OFFSHORE_STAGING`, `SITE`, `GATE`, `CORRIDOR` |
| `hvdc:unlocode` | `Port` | `xsd:string` | Optional but required where official UN/LOCODE exists |
| `hvdc:countryCode` | `LocationNode` | ISO 3166 string | UAE nodes use `AE` |
| `hvdc:capacitySqm` | `CapacityProfile` | decimal | ≥ 0.00 |
| `hvdc:capacityTeu` | `CapacityProfile` | decimal | ≥ 0.00 |
| `hvdc:maxPayloadT` | `ServiceCapability` | decimal | ≥ 0.00 |
| `hvdc:maxOogLengthM` | `ServiceCapability` | decimal | ≥ 0.00 |
| `hvdc:gatePassRequired` | `AccessPolicy` | boolean | Required for controlled nodes |
| `hvdc:permitLeadTimeDays` | `PermitRequirement` | decimal | RAG-checked; do not hardcode if unknown |
| `hvdc:ragCheckedAt` | `FrameworkStandard` | `xsd:date` | ISO date required |
| `hvdc:validationStatus` | any governed object | enum | `PASS`, `WARN`, `FAIL`, `PENDING_HUMAN` |

### 4.4 Turtle Skeleton

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

hvdc:LocationNode a owl:Class .
hvdc:Port a owl:Class ; rdfs:subClassOf hvdc:LocationNode .
hvdc:Terminal a owl:Class ; rdfs:subClassOf hvdc:LocationNode .
hvdc:Warehouse a owl:Class ; rdfs:subClassOf hvdc:LocationNode .
hvdc:OffshoreStagingNode a owl:Class ; rdfs:subClassOf hvdc:LocationNode .
hvdc:Site a owl:Class ; rdfs:subClassOf hvdc:LocationNode .
hvdc:TransportCorridor a owl:Class .
hvdc:RegulatoryRequirement a owl:Class .
hvdc:PermitRequirement a owl:Class ; rdfs:subClassOf hvdc:RegulatoryRequirement .
hvdc:FrameworkStandard a owl:Class .
hvdc:CapacityProfile a owl:Class .
hvdc:ServiceCapability a owl:Class .
hvdc:AccessPolicy a owl:Class .

hvdc:nodeCode a owl:DatatypeProperty ;
  rdfs:domain hvdc:LocationNode ;
  rdfs:range xsd:string .

hvdc:nodeType a owl:DatatypeProperty ;
  rdfs:domain hvdc:LocationNode ;
  rdfs:range xsd:string .

hvdc:connectsTo a owl:ObjectProperty ;
  rdfs:domain hvdc:LocationNode ;
  rdfs:range hvdc:LocationNode .

hvdc:governedBy a owl:ObjectProperty ;
  rdfs:domain hvdc:LocationNode ;
  rdfs:range hvdc:RegulatoryRequirement .

hvdc:requiresPermit a owl:ObjectProperty ;
  rdfs:domain hvdc:TransportCorridor ;
  rdfs:range hvdc:PermitRequirement .
```

---

## 5. Infrastructure Node Model

### 5.1 Node Type Dictionary

| NodeType | Class | Description | Allowed journey stages |
|---|---|---|---|
| `PORT` | `Port` | Seaport or entry port | `PORT_ENTRY`, `TERMINAL_HANDLING`, `CUSTOMS_CLEARANCE` |
| `TERMINAL` | `Terminal` | CY/CFS/berth/gate within a port | `TERMINAL_HANDLING`, `INLAND_HAULAGE` |
| `WAREHOUSE` | `Warehouse` | Indoor/outdoor/dangerous/OOG storage facility | `WH_RECEIPT`, `WH_STORAGE`, `WH_DISPATCH` |
| `OFFSHORE_STAGING` | `OffshoreStagingNode` | Marine interface / staging base for offshore movements | `MOSB_STAGING`, `OFFSHORE_TRANSIT` |
| `SITE_ONSHORE` | `Site` | Onshore construction / receiving site | `SITE_RECEIVING`, `MATERIAL_ISSUE` |
| `SITE_OFFSHORE` | `Site` | Offshore island/site receiving node | `SITE_RECEIVING`, `MATERIAL_ISSUE` |
| `GATE` | `Gate` | Controlled access point | `INLAND_HAULAGE`, `SITE_RECEIVING` |
| `CORRIDOR` | `TransportCorridor` | Route segment between nodes | All movement stages |

### 5.2 Core Node Registry

| Node | Canonical class | Function | RoutingPattern support | Compliance gates |
|---|---|---|---|---|
| Khalifa Port | `Port` | Container import, terminal handling, carrier event source | `DIRECT`, `WH_ONLY`, `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | Port access, customs, BL/DO, container release |
| Zayed Port | `Port` | Breakbulk, OOG, heavy cargo, bulk handling | `DIRECT`, `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | Port access, OOG method statement, customs, lifting plan |
| Jebel Ali Port / Free Zone | `Port` | Free-zone and special supplier import cases | `DIRECT`, `WH_ONLY`, `WH_MOSB`, `MIXED` | Free-zone customs, re-clearance, BOE/DO |
| Port Terminal / CY / CFS | `Terminal` | Gate-in/out, CY storage, terminal services | Evidence only | Terminal release and service event validation |
| DSV Indoor / controlled WH | `Warehouse` | Controlled indoor storage | `WH_ONLY`, `WH_MOSB` | WMS receipt, preservation, stock accuracy |
| DSV Yard / outdoor WH | `Warehouse` | Outdoor/yard storage | `WH_ONLY`, `WH_MOSB` | Capacity, preservation, HSE |
| AAA / Al Markaz storage | `Warehouse` | Overflow or project storage | `WH_ONLY`, `WH_MOSB`, `MIXED` | Lease/contract, WH capacity, insurance |
| MOSB | `OffshoreStagingNode` | Marine interface, consolidation, LCT/barge staging | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | ADNOC/ALS access, PTW/FRA, marine weather gate, M115 evidence |
| MIR Site | `Site` / `SITE_ONSHORE` | Onshore receiving and laydown | `DIRECT`, `WH_ONLY`, `MIXED` | Site access, MRR/MRI/GRN, lifting/HSE if OOG |
| SHU Site | `Site` / `SITE_ONSHORE` | Onshore receiving and installation support | `DIRECT`, `WH_ONLY`, `MIXED` | Site access, capacity, MRR/MRI/GRN |
| DAS Island | `Site` / `SITE_OFFSHORE` | Offshore receiving | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | M115 prerequisite, LCT/barge, ADNOC HSE, site permit |
| AGI Island | `Site` / `SITE_OFFSHORE` | Offshore receiving | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | M115 prerequisite, LCT/barge, ADNOC HSE, site permit |

### 5.3 MOSB Boundary Rule

`MOSB` may have laydown, temporary holding, and staging functions, but the top-level class is `OffshoreStagingNode`, not `Warehouse`. If a physical sub-area inside MOSB is used for temporary storage, model it as `StorageCapability` or `LaydownArea` attached to `MOSB`; do not type MOSB as a `Warehouse`.

```turtle
hvdc:MOSB a hvdc:OffshoreStagingNode ;
  hvdc:nodeCode "MOSB" ;
  hvdc:nodeType "OFFSHORE_STAGING" ;
  hvdc:servesJourneyStage hvdc:MOSB_STAGING ;
  hvdc:servesJourneyStage hvdc:OFFSHORE_TRANSIT ;
  hvdc:supportsRoutingPattern hvdc:MOSB_DIRECT ;
  hvdc:supportsRoutingPattern hvdc:WH_MOSB .
```

### 5.4 Transport Corridor Model

| Corridor | Mode | From → To | Permit / gate | Primary milestones |
|---|---|---|---|---|
| Port-to-WH | Truck / trailer / SPMT | Port/terminal → Warehouse | DO, gate pass, OOG permit if required | M92 → M100 → M110 |
| Port-to-Site | Truck / trailer / SPMT | Port/terminal → MIR/SHU | DO, gate pass, site receiving plan | M92 → M100 → M130 |
| Port-to-MOSB | Truck / trailer / SPMT | Port/terminal → MOSB | DO, access pass, marine staging plan | M92 → M100 → M115 |
| WH-to-Site | Truck / trailer | Warehouse → MIR/SHU | WH dispatch, gate pass | M121 → M130 |
| WH-to-MOSB | Truck / trailer / SPMT | Warehouse → MOSB | WH dispatch, access pass | M121 → M115 |
| MOSB-to-AGI/DAS | LCT / barge / marine support | MOSB → AGI/DAS | PTW/FRA/weather/lashing/handover | M115 → M116 → M117 → M130 |
| Inter-WH transfer | Truck | Warehouse → Warehouse | transfer order | M111/M121 as applicable |

---

## 6. Routing & Journey Constraints

### 6.1 RoutingPattern Compatibility

| RoutingPattern | Required node sequence | Node constraints | Notes |
|---|---|---|---|
| `PRE_ARRIVAL` | Origin / vessel / pre-entry | No UAE infrastructure milestone yet | No WH handling classification |
| `DIRECT` | Port → Site | Site must be MIR/SHU unless explicitly approved | No MOSB requirement |
| `WH_ONLY` | Port → Warehouse → Site | Warehouse milestone M110 required | No offshore leg |
| `MOSB_DIRECT` | Port → MOSB → Site | MOSB M115 required before offshore site arrival | Mandatory for AGI/DAS direct offshore route |
| `WH_MOSB` | Port → Warehouse → MOSB → Site | M110 and M115 required | Used for storage + offshore staging |
| `MIXED` | Incomplete, exception, multi-hop, unresolved | Requires exception review | Must not become a permanent normal state |

### 6.2 AGI/DAS Offshore Gate

AGI/DAS shipments must carry an offshore-compatible `RoutingPattern` and must have M115 `MOSB Staged` before M130 `Site Arrived`. This file defines the infrastructure constraint; `CONSOLIDATED-00` owns the canonical validation shape and `CONSOLIDATED-04/06` implement marine/material details.

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?unit ?dest ?pattern
WHERE {
  ?unit hvdc:declaredDestination ?dest ;
        hvdc:hasRoutingPattern ?pattern .
  FILTER(?dest IN ("AGI", "DAS"))
  FILTER(?pattern NOT IN ("MOSB_DIRECT", "WH_MOSB", "MIXED"))
}
```

### 6.3 No Universal MOSB Assumption

Do not assert that all cargo must pass through MOSB. Correct logic:

- MIR/SHU onshore cargo may be `DIRECT` or `WH_ONLY`.
- AGI/DAS offshore cargo requires MOSB-inclusive routing or an explicit exception gate.
- Bulk/OOG cargo often uses MOSB, but the requirement is route- and destination-dependent.
- Port and OCR sources provide evidence, not final route ownership.

---

## 7. Integration — Foundry ↔ ERP/WMS/ATLP/Port/Invoice

### 7.1 Foundry Object Type Mapping

| Foundry Object Type | Source dataset | Key properties | Link Types |
|---|---|---|---|
| `FrameworkStandard` | standards registry / RAG table | `standardCode`, `version`, `authority`, `ragCheckedAt` | appliesTo → ObjectType |
| `RegulatoryRequirement` | compliance master | `authority`, `requirementCode`, `scope`, `trigger` | governs → LocationNode / CargoCategory |
| `PermitRequirement` | permit matrix | `permitType`, `authority`, `leadTimeDays`, `evidenceRequired` | requiredFor → JourneyLeg / LocationNode |
| `LocationNode` | node master | `nodeCode`, `nodeType`, `nodeName`, `countryCode` | connectsTo → LocationNode |
| `Port` | port/terminal master | `unlocode`, `portAuthority`, `cargoProfile` | hasTerminal → Terminal |
| `Warehouse` | WMS/location master | `warehouseCode`, `storageType`, `capacity` | supports → WarehouseTask |
| `OffshoreStagingNode` | marine/MOSB master | `supportsLCT`, `marineInterfaceType` | stagesFor → Site |
| `Site` | site master | `siteCode`, `siteType`, `receivingCapability` | receives → ShipmentUnit |
| `TransportCorridor` | route matrix | `mode`, `fromNode`, `toNode`, `permitRequired` | usedBy → JourneyLeg |
| `AccessPolicy` | gate/security SOP | `policyCode`, `issuer`, `locationScope` | controls → LocationNode |
| `CapacityProfile` | WMS/yard/site capacity | `capacityUnit`, `ratedCapacity`, `currentUtilization` | belongsTo → LocationNode |
| `InfrastructureKPI` | dashboard / KPI dataset | `metricCode`, `targetValue`, `actualValue` | measures → LocationNode |

### 7.2 Dataset Integration Points

| Source system | Dataset | Ontology output | Validation |
|---|---|---|---|
| ERP / PMO | `project_po_package_material` | Project, Package, PO, Material, Vendor | PO-package-material completeness |
| Port / OFCO | `portcall_service_tariff` | Port, Terminal, PortCall, ServiceEvent | PortCall↔Shipment link |
| Carrier / forwarder | `carrier_container_events` | Container, CarrierEvent, JourneyLeg | DCSA-style event sequence |
| Customs / ATLP / broker | `customs_boe_permit_release` | CustomsEntry, PermitDocument, ReleaseOrder | WCO field and permit evidence |
| WMS | `warehouse_location_capacity_task` | Warehouse, CapacityProfile, WarehouseTask | WH capacity and stock integrity |
| Marine / MOSB | `mosb_lct_barge_events` | OffshoreStagingNode, MarineEvent, Corridor | M115/M116/M117 sequence |
| Site receiving | `site_mrr_grn_osdr` | Site, SiteReceipt, InspectionEvent | M130/M140 evidence |
| LDG / OCR | `doc_entity_evidence` | Document, Evidence, VerificationResult | OCR confidence and cross-doc checks |
| Invoice / Cost | `invoice_line_rate_ref` | Invoice, InvoiceLine, RateRef, CostGuardResult | Δ% and numeric integrity |
| Communication | `email_chat_approval_evidence` | CommunicationEvent, ApprovalAction, AuditRecord | Evidence-only linking |

### 7.3 Foundry Action Types

| Action | Target | Inputs | Guard |
|---|---|---|---|
| `RegisterLocationNode` | LocationNode | node code, type, owner, capabilities | node code uniqueness |
| `UpdateCapacityProfile` | CapacityProfile | node, capacity, current utilization | utilization ≤ threshold or WARN |
| `AttachPermitRequirement` | PermitRequirement | authority, trigger, required evidence | current SOP/RAG source required |
| `ApproveAccessPolicy` | AccessPolicy | location, role, validity, approver | expiry date and approver required |
| `ValidateNodeForRouting` | ShipmentUnit / JourneyLeg | origin, destination, routing pattern | AGI/DAS + MOSB gate |
| `OpenInfrastructureException` | Exception | node, blocker, evidence, owner | human-gate for high-risk blockers |

---

## 8. Validation — SHACL / SPARQL / RAG / Human-gate

### 8.1 SHACL Constraints

```turtle
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

hvdc:LocationNodeShape a sh:NodeShape ;
  sh:targetClass hvdc:LocationNode ;
  sh:property [
    sh:path hvdc:nodeCode ;
    sh:minCount 1 ;
    sh:datatype xsd:string ;
    sh:message "LocationNode requires nodeCode." ;
  ] ;
  sh:property [
    sh:path hvdc:nodeType ;
    sh:minCount 1 ;
    sh:in ("PORT" "TERMINAL" "WAREHOUSE" "OFFSHORE_STAGING" "SITE_ONSHORE" "SITE_OFFSHORE" "GATE" "CORRIDOR") ;
    sh:message "LocationNode nodeType must use controlled vocabulary." ;
  ] .

hvdc:MOSBNotWarehouseShape a sh:NodeShape ;
  sh:targetNode hvdc:MOSB ;
  sh:sparql [
    sh:message "MOSB must be OffshoreStagingNode, not Warehouse." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE { $this a hvdc:Warehouse . }
    """ ;
  ] .

hvdc:PermitRequirementShape a sh:NodeShape ;
  sh:targetClass hvdc:PermitRequirement ;
  sh:property [ sh:path hvdc:authority ; sh:minCount 1 ; sh:datatype xsd:string ] ;
  sh:property [ sh:path hvdc:evidenceRequired ; sh:minCount 1 ; sh:datatype xsd:boolean ] .

hvdc:CapacityProfileShape a sh:NodeShape ;
  sh:targetClass hvdc:CapacityProfile ;
  sh:property [
    sh:path hvdc:currentUtilizationPct ;
    sh:datatype xsd:decimal ;
    sh:minInclusive 0.00 ;
    sh:maxInclusive 100.00 ;
  ] .
```

### 8.2 SPARQL Audit Queries

#### Node without governance

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?node ?type
WHERE {
  ?node a hvdc:LocationNode ; hvdc:nodeType ?type .
  FILTER NOT EXISTS { ?node hvdc:governedBy ?req . }
}
```

#### AGI/DAS route without MOSB stage

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?unit ?dest ?m130
WHERE {
  ?unit hvdc:declaredDestination ?dest ;
        hvdc:hasMilestone ?m130 .
  ?m130 hvdc:milestoneCode "M130" ; hvdc:actualDt ?actual .
  FILTER(?dest IN ("AGI", "DAS"))
  FILTER NOT EXISTS {
    ?unit hvdc:hasMilestone ?m115 .
    ?m115 hvdc:milestoneCode "M115" ; hvdc:actualDt ?m115Actual .
  }
}
```

#### Capacity warning

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?node ?util
WHERE {
  ?node hvdc:hasCapacityProfile ?cap .
  ?cap hvdc:currentUtilizationPct ?util .
  FILTER(?util > 85.00)
}
```

### 8.3 RAG Checks

| RAG check | Trigger | Required evidence | Human-gate |
|---|---|---|---|
| Standards version | Quarterly or schema release | Official authority source and `ragCheckedAt` | Ontology owner |
| MOIAT product conformity | Regulated product / certificate missing | MOIAT certificate or exemption evidence | Compliance |
| FANR / radiation-source control | Nuclear/radiation-related material | FANR licence/permit evidence or project legal note | Compliance + HSE |
| DCD / DG | Dangerous goods | DG declaration, segregation evidence, HSE approval | HSE |
| ADNOC / CICPA access | Controlled port/site/MOSB access | GatePass/access approval | Site logistics |
| OOG / heavy corridor | OOG / abnormal load | route survey, method statement, permit | Heavy-lift engineer |
| Weather / marine | MOSB-to-AGI/DAS movement | weather window, FRA, PTW, marine approval | Marine coordinator |

### 8.4 Human-gate Thresholds

| Gate | Trigger | Required role |
|---|---|---|
| High-value cost | Invoice or claim > 100,000.00 AED | Finance approver |
| Capacity overload | WH/MOSB/Site utilization > 85.00% | Logistics manager |
| Permit uncertainty | missing or expired authority evidence | Compliance owner |
| AGI/DAS M115 violation | M130 exists without M115 | Marine + Site logistics |
| OOG method statement missing | OOG cargo enters corridor without approved MS | Heavy-lift engineer |
| Dangerous goods mismatch | DG class, UN number, or segregation missing | HSE |

---

## 9. Compliance — Incoterms / MOIAT / FANR / DCD / ADNOC

### 9.1 Compliance Object Model

| Compliance area | Object | Evidence | Blocking rule |
|---|---|---|---|
| Incoterms 2020 | `IncotermTerm` | PO/contract term | cost/risk owner must match PO and invoice |
| Customs / WCO | `CustomsEntry`, `BOEDocument` | BOE, HS, origin, value | BOE draft blocked if mandatory fields missing |
| MOIAT | `ConformityCertificateRequirement` | UAE CoC / ECAS/EQM-style evidence or exemption | DO/GatePass blocked for regulated products without certificate evidence |
| FANR | `RadiationPermitRequirement` | licence/permit evidence | BOE or movement blocked until compliance owner approves |
| DCD / DG | `DangerousGoodsRequirement` | DG declaration, SDS, segregation plan | WH/storage/transport blocked if DG data incomplete |
| ADNOC / CICPA / site access | `AccessPolicy`, `GatePass` | gate pass/access approval | gate entry blocked if expired or missing |
| BIMCO / Marine contract | `MarineContract`, `CharterTerm` | SUPPLYTIME or project marine contract clause | marine work order requires liability/insurance check |

### 9.2 Incoterms Control

Incoterms are not route classifiers. They determine delivery obligation, cost responsibility, and risk transfer. Store them on PO/Shipment contract context and use them to validate invoice and release ownership.

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?shipment ?term ?invoiceOwner ?expectedOwner
WHERE {
  ?shipment hvdc:hasIncoterm ?term ; hvdc:hasInvoice ?invoice .
  ?term hvdc:localCostOwner ?expectedOwner .
  ?invoice hvdc:chargedTo ?invoiceOwner .
  FILTER(?invoiceOwner != ?expectedOwner)
}
```

### 9.3 Permit Control

Permit validation is event-gated:

| Event | Permit / evidence precondition |
|---|---|
| M50 Terminal Received | BL/manifest and port record exist |
| M90 BOE Submitted | CI/PL/BL, HS, origin, value, permits if applicable |
| M92 DO Released | BOE cleared, DO evidence, regulated-product certificates if applicable |
| M100 Gate-out | DO + gate pass + transporter details |
| M110 WH Received | WMS receiving task and preservation requirement |
| M115 MOSB Staged | access approval, marine plan, staging evidence |
| M116 LCT Loaded | PTW/FRA, lashing/stability approval, weather window |
| M130 Site Arrived | receiving plan, site access, offshore prerequisite if applicable |

---

## 10. Options ≥3

| Option | Description | Pros | Cons | CostIndex | Risk | Time |
|---|---|---|---|---:|---:|---:|
| A. Reference-first | Standards + node registry only | fast, low disruption, strong external alignment | weaker operational automation | 1.00/5.00 | 20.00% | 4.00 weeks |
| B. Hybrid framework | Standards + nodes + SHACL + Foundry actions | best balance, deployable gates, direct COP integration | requires curated node master | 2.50/5.00 | 18.00% | 8.00 weeks |
| C. Ops Twin | Hybrid + live capacity + gate-pass + permit clocks | strongest operational value, supports exception management | needs source-system integration | 4.00/5.00 | 24.00% | 12.00 weeks |
| D. Enterprise RDF Bridge | Full RDF/OWL + external graph + Foundry bridge | strongest reasoning and SHACL governance | architecture and maintenance complexity | 5.00/5.00 | 30.00% | 16.00 weeks |

Recommended path: **Option B** for controlled rollout, then Option C for live operations.

---

## 11. Roadmap — Prepare → Pilot → Build → Operate → Scale

| Phase | Scope | KPI |
|---|---|---|
| Prepare | Confirm standards registry, node dictionary, authority matrix | NodeMasterCoverage ≥ 90.00% |
| Pilot | 1.00 onshore route + 1.00 offshore route + 1.00 OOG case | RoutingPatternValidation = 100.00% |
| Build | Foundry Object/Link mapping, SHACL gates, SPARQL audit panels | Link completeness ≥ 95.00% |
| Operate | Daily infra blocker review, permit expiry monitor, capacity warning | Validation p95 < 5.00s |
| Scale | Extend to all nodes, marine/OOG, cost, RAG compliance | PermitEvidenceCompleteness ≥ 98.00% |

---

## 12. Automation Notes — RPA / LLM / Sheets / TG Hooks

| Automation | Trigger | Output |
|---|---|---|
| `NodeMasterGuard` | new or modified LocationNode | node code, type, governance, capability validation |
| `PermitExpiryBot` | permit expiry within threshold | compliance review list |
| `RouteNodeFitGuard` | route planning / JourneyLeg creation | allowed route and node capability check |
| `AGIDASGateBot` | AGI/DAS route or M130 event | M115 prerequisite check |
| `CapacityGuard` | WH/MOSB/Site utilization update | WARN at > 85.00%, HIGH at > 95.00% |
| `CertChkRAG` | regulated product or uncertain authority rule | latest authority evidence retrieval request |
| `GatePassGuard` | gate-out / site entry / MOSB staging | access policy and validity check |
| `WeatherTieMarineGuard` | M116/M117 marine movement | weather/FRA/PTW checklist |
| `DailyInfraDigest` | 08:00 Asia/Dubai daily | node blocker, permit, capacity, route exception summary |

---

## 13. QA Checklist & Assumptions

### 13.1 QA Checklist

| Check | PASS 기준 |
|---|---|
| Master spine alignment | `CONSOLIDATED-00` vocabulary reused, not redefined |
| Flow boundary | Warehouse handling class not used as route/cost/document/marine classifier |
| MOSB classification | MOSB typed as `OffshoreStagingNode`, not `Warehouse` |
| Universal MOSB claim | Removed; MOSB is conditional by destination/routing/cargo |
| Evidence ownership | Port/OCR/Cost/Communication provide evidence only |
| Node registry | Port/WH/MOSB/Site/Terminal/Gate/Corridor separated |
| Compliance | Incoterms, Customs, MOIAT, FANR, DCD/DG, ADNOC/CICPA, BIMCO anchors present |
| SHACL | LocationNode, MOSB, Permit, Capacity shapes present |
| SPARQL | governance, AGI/DAS, capacity queries present |
| PII | No phone/e-mail contact registry embedded |
| KPI format | Operational numbers use two-decimal format where applicable |

### 13.2 Assumptions

- `CONSOLIDATED-00` remains the semantic authority for core classes and milestones.
- Current operational facts such as site gate rules, permit lead time, authority forms, and ADNOC/CICPA details must be RAG-checked against current project SOP before automated release.
- FANR-related permit validity and processing timelines are not hardcoded here because authority-specific service evidence must be confirmed for the actual cargo and licence context.
- `FMC_OrgChart_Data.json` is not embedded in this document. Names, phone numbers, and e-mail addresses remain PII and require masking before register write.

---

## 14. RAG Source Anchors

| Anchor | Official source URL | Use in this document |
|---|---|---|
| UN/CEFACT RDM | https://unece.org/trade/uncefact/rdm | BSP-RDM semantic alignment |
| WCO Data Model v4.2.0 | https://www.wcoomd.org/en/media/newsroom/2025/july/world-customs-organization-releases-data-mode.aspx | Customs data model version anchor |
| WCO Data Model app | https://datamodel.wcoomd.org/ | WCO DM access and package verification |
| DCSA Track & Trace | https://dcsa.org/standards/track-and-trace | Container visibility/event alignment |
| DCSA Track & Trace documentation | https://dcsa.org/standards/track-and-trace/standard-documentation-track-and-trace | Latest-release adoption gate |
| ICC Incoterms 2020 | https://iccwbo.org/business-solutions/incoterms-rules/incoterms-2020/ | Incoterm rule anchor |
| MOIAT regulated product CoC | https://moiat.gov.ae/en/services/issue-conformity-certificates-for-regulated-products | UAE conformity evidence anchor |
| UN/LOCODE | https://unece.org/trade/uncefact/unlocode | Location code release anchor |
| BIMCO SUPPLYTIME 2017 | https://www.bimco.org/contractual-affairs/bimco-contracts/contracts/supplytime-2017/ | Offshore support vessel contract anchor |
| UAE nuclear legal baseline | https://uaelegislation.gov.ae/en/legislations/1123/download | FANR-controlled activity legal baseline |

---

## 15. CmdRec

```text
/switch_mode PRIME + /logi-master cert-chk --deep --KRsummary
```

```text
/logi-master report --deep --KRsummary
```

```text
/logi-master hs-risk --deep --AEDonly
```
