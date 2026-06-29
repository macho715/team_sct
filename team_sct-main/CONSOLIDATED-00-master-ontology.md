---
title: "HVDC Logistics Knowledge Graph — Master Ontology"
type: "master-ontology-spine"
domain: "hvdc-logistics"
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
owner: "HVDC Logistics Ontology Working Set"
canonical_authority: true
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
extended_by:
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
evidence_layer:
  - CONSOLIDATED-08-communication.md
replaces:
  - CONSOLIDATED-00-master-ontology.md@2026-04-11
  - CONSOLIDATED-00-master-ontology_rev.md@2026-04-27
validation_passes: 5
---

# hvdc-master-ontology · CONSOLIDATED-00

## ExecSummary

HVDC 물류 온톨로지의 master spine은 `ShipmentUnit`을 중심으로 Project, Package, PO, Material, CargoUnit, Container, PortCall, CustomsEntry, ReleaseOrder, WarehouseTask, SiteReceipt, Document, MilestoneEvent, Exception, Cost 객체를 연결한다.

본 문서는 전체 문서 세트(`CONSOLIDATED-01`~`09`, `AGENTS.md`, `HVDC Logistics Ontology Review.txt`, Palantir Semantic Digital Twin PDF)를 기준으로 재작성한 canonical reference다. Extension 문서가 본 spine과 충돌하면 본 문서가 우선한다.

핵심 설계는 **Any-key in → Identifier resolution → ShipmentUnit → route/document/customs/warehouse/site/cost/exception full trace**이다. KPI 목표는 Key Resolution ≥ **95.00%**, Milestone Coverage ≥ **90.00%**, NumericIntegrity = **100.00%**, Validation p95 < **5.00s**이다.

**ENG-KR one-liner:** Any key resolves to one operational twin; routing uses `RoutingPattern`, execution uses `MilestoneEvent`, evidence uses documents, and warehouse handling uses `WarehouseHandlingProfile` only.

---

## Table of Contents

1. [Governance & Corpus Boundary](#part-1)
2. [Canonical Dictionaries](#part-2)
3. [Identity & Key Policy](#part-3)
4. [Core Master Data Model](#part-4)
5. [Execution Transaction Model](#part-5)
6. [Document & Evidence Model](#part-6)
7. [End-to-End Process & Milestone Model](#part-7)
8. [Knowledge Graph Node/Edge Design](#part-8)
9. [Integration Architecture](#part-9)
10. [Validation Rules: SHACL, SPARQL, RAG, Human-gate](#part-10)
11. [Compliance Controls](#part-11)
12. [Warehouse Flow Code Policy](#part-12)
13. [Options, Roadmap, Automation, QA](#part-13)
14. [CmdRec](#cmdrec)

---

## Part 1: Governance & Corpus Boundary {#part-1}

### 1.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the **canonical semantic spine** for the repository.
2. Program-wide shipment visibility shall use **`RoutingPattern` + `JourneyStage` + `MilestoneEvent` + `JourneyLeg`**.
3. Port, customs, document/OCR, cost, marine, operations, and communication domains may provide **evidence**; they shall not own warehouse handling classification.
4. `MOSB` is an **Offshore Staging / Marine Interface Node**. It is not a top-level `Warehouse` class.
5. `CONSOLIDATED-08-communication.md` is an **Evidence Layer** extension. It connects through `CommunicationEvent`, `ApprovalAction`, and `AuditRecord` only.
6. Legacy route-coded language is migration debt. It may be listed only in the late migration appendix in [Part 12](#part-12).

### 1.2 Corpus Role Matrix

| File | Role in this master spine | Master integration rule |
|---|---|---|
| `CONSOLIDATED-01-core-framework-infra.md` | Standards, node infrastructure, compliance anchors | Reuse Party, Asset, Location, Contract, Regulation, KPI concepts as reference-layer classes |
| `CONSOLIDATED-02-warehouse-flow.md` | Warehouse operations and `WarehouseHandlingProfile` algorithm | Warehouse handling classification belongs here only |
| `CONSOLIDATED-03-document-ocr.md` | LDG/OCR trust layer and cross-document validation | Documents extract `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` only |
| `CONSOLIDATED-04-barge-bulk-cargo.md` | Marine, bulk, OOG, lashing, stability, LCT/barge extension | Uses `MarineRoutingPattern`, `MarineEvent`, `OperationTask`, M115/M116/M117 |
| `CONSOLIDATED-05-invoice-cost.md` | Invoice, rate reference, CostGuard, PRISM.KERNEL | Cost reads route + WH evidence; it does not own warehouse classification |
| `CONSOLIDATED-06-material-handling.md` | Customs → WH → MOSB → Site material chain | Canonicalizes JourneyStage, milestones, AGI/DAS M115→M130 rule |
| `CONSOLIDATED-07-port-operations.md` | OFCO/PortCall/ServiceEvent/Tariff hub | Port records `plannedRoutingPattern` and `declaredDestination` as evidence |
| `CONSOLIDATED-08-communication.md` | Email/chat evidence and action layer | Evidence only; no core logistics class redefinition |
| `CONSOLIDATED-09-operations.md` | Ops analytics, routing KPI, reporting | Consumes `hasRoutingPattern`, milestone, stock, cost semantics |
| `AGENTS.md` | Repository-wide modeling governance | Precedence, non-negotiable rules, validation gate policy |
| `HVDC Logistics Ontology Review.txt` | Structural review and redesign source | Used to normalize layers, identity, milestones, and query entry points |
| `Palantir 온톨로지 기반 물류 자동화.pdf` | Semantic Digital Twin architecture blueprint | Used for ontology/KG/validation/automation architecture framing |

### 1.3 Data Layer Separation

| Layer | Purpose | Canonical classes |
|---|---|---|
| Master Data | Stable reference and planning data | `Project`, `Package`, `PurchaseOrder`, `Vendor`, `MaterialMaster`, `HVDCCodeTag`, `LocationNode`, `EquipmentResource` |
| Execution Transactions | What moved or was processed | `Shipment`, `ShipmentUnit`, `CargoUnit`, `Container`, `JourneyLeg`, `PortCall`, `CustomsEntry`, `ReleaseOrder`, `WarehouseTask`, `SiteReceipt` |
| Documents | Documentary evidence | `CommercialInvoiceDocument`, `PackingListDocument`, `BillOfLadingDocument`, `BOEDocument`, `DeliveryOrderDocument`, `PermitDocument`, `MRR`, `MRI`, `ITP`, `MAR`, `MRS`, `MIS`, `POD`, `GRN`, `OSDR` |
| Events | Time-stamped state transitions | `MilestoneEvent`, `InspectionEvent`, `WarehouseEvent`, `MarineEvent`, `ServiceEvent`, `CommunicationEvent` |
| Exceptions | Disruption and resolution | `Exception`, `Delay`, `Damage`, `Shortage`, `Overage`, `NCR`, `Claim` |
| Cost | Financial traceability | `Invoice`, `InvoiceLine`, `RateRef`, `CostTransaction`, `TariffRef`, `DEMDETClock`, `CostGuardResult` |
| Evidence | Provenance, proof, approvals | `AuditRecord`, `ApprovalAction`, `VerificationResult`, `TrustLayer`, `ProofArtifact` |

### 1.4 Non-collapse Rule

| Do not collapse | Correct model |
|---|---|
| `CustomsEntry` into `BOEDocument` | `CustomsEntry` is a transaction; `BOEDocument` is evidence |
| `ReleaseOrder` into `DeliveryOrderDocument` | `ReleaseOrder` is a release transaction; DO is evidence |
| `SiteReceipt` into `MRR` / `OSDR` / `POD` / `GRN` | `SiteReceipt` is a site transaction; documents evidence it |
| `MOSB` into `Warehouse` | `MOSB` is `OffshoreStaging`; optional storage capability is a property, not a class collapse |
| Route status into warehouse handling classification | Route status uses `RoutingPattern`, `JourneyStage`, `MilestoneEvent`, `JourneyLeg` |

---

## Part 2: Canonical Dictionaries {#part-2}

### 2.1 RoutingPattern Dictionary

`ShipmentRoutingPattern` is an end-to-end route classifier. It is a SKOS-controlled vocabulary and must be encoded as named concepts, not integers.

| Pattern | Canonical path | Business meaning | Valid owner |
|---|---|---|---|
| `PRE_ARRIVAL` | Not yet arrived / insufficient evidence | Pre-arrival or unresolved route | `ShipmentUnit`, `PortCall` evidence |
| `DIRECT` | Port → Site | No warehouse and no MOSB staging | `ShipmentUnit` |
| `WH_ONLY` | Port → WH → Site | Warehouse leg, no offshore staging | `ShipmentUnit` |
| `MOSB_DIRECT` | Port → MOSB → Site | Offshore staging without warehouse leg | `ShipmentUnit` / marine extension |
| `WH_MOSB` | Port → WH → MOSB → Site | Warehouse plus offshore staging | `ShipmentUnit` / marine extension |
| `MIXED` | Mixed / incomplete / exceptional | Multi-path, split cargo, or insufficient closure | `ShipmentUnit` |

### 2.2 MarineRoutingPattern Dictionary

| Pattern | Path | Owner domain |
|---|---|---|
| `DIRECT_MOSB` | Port → MOSB | `CONSOLIDATED-04`, `CONSOLIDATED-06` |
| `WH_THEN_MOSB` | WH → MOSB | `CONSOLIDATED-04`, `CONSOLIDATED-06` |
| `LCT_DIRECT` | LCT / barge direct operation | `CONSOLIDATED-04` |
| `OFFSHORE_PENDING` | Offshore route not yet confirmed | Exception / marine planning |

### 2.3 JourneyStage Vocabulary

| Stage Code | Korean Name | Entry Milestone | Exit Milestone | Operational use |
|---|---|---|---|---|
| `PLANNING` | 계획 | M10 | M20 | Demand/readiness planning |
| `ORIGIN_DISPATCH` | 원산지 출발 | M20 | M40 | Packing, pickup, export clearance |
| `PORT_ENTRY` | 입항 | M50 / M80 | M92 | Terminal arrival and import readiness |
| `TERMINAL_HANDLING` | 터미널 작업 | M50 | M61 | Gate-in, loading, ATD |
| `CUSTOMS_CLEARANCE` | 통관 | M80 | M92 | BOE and import release |
| `INLAND_HAULAGE` | 내륙 운송 | M92 | M100 | DO, gate-out, domestic move |
| `WH_RECEIPT` | 창고 입고 | M100 | M110 | WH appointment and receipt |
| `WH_STORAGE` | 창고 보관 | M110 | M120 | Put-away, storage, preservation |
| `WH_DISPATCH` | 창고 출고 | M120 | M121 | Picking, staging, dispatch |
| `MOSB_STAGING` | MOSB 스테이징 | M121 / direct inland arrival | M115 | Offshore staging |
| `OFFSHORE_TRANSIT` | 해상 운송 | M116 | M117 | LCT/barge loading and sail-away |
| `SITE_RECEIVING` | 현장 수령 | M117 / M100 direct | M130 | Arrival and receiving |
| `MATERIAL_ISSUE` | 자재 불출 | M131/M132 | M140 | Inspection, POD, GRN |
| `CLOSEOUT` | 완료 | M140 | M160 | Claim/cost closure |
| `EXCEPTION` | 예외 처리 | Any blocking event | Resolved milestone | Delay/damage/shortage/NCR |

### 2.4 Domain Vocabulary Crosswalk

| Domain | Use | Do not use as canonical |
|---|---|---|
| Core shipment | `ShipmentRoutingPattern`, `JourneyStage`, `MilestoneEvent`, `JourneyLeg` | Numeric route codes |
| Port | `plannedRoutingPattern`, `declaredDestination`, `offshoreTransitRequired`, `importRoutingDecision` | `assignedFlowCode` |
| Document/OCR | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, `routeEvidenceConfidence` | `extractedFlowCode` |
| Cost | `routeBasedCostDriver`, `costByRoutingPattern`, `wh_handling_cnt` evidence | `costByFlowCode` |
| Marine/Bulk | `MarineRoutingPattern`, `offshoreDeliveryPattern`, `MarineEvent` | Warehouse route codes |
| Warehouse | `WarehouseHandlingProfile`, `storageClass`, `flowConfirmationStatus`, `confirmedFlowCode` | E2E route ownership |
| Operations/KPI | `hasRoutingPattern`, milestone analytics, stock analytics | End-to-end Flow Code analytics |
| Communication | `CommunicationEvent`, `ApprovalAction`, `AuditRecord` | Core class ownership |

### 2.5 Status Vocabularies

| Vocabulary | Values |
|---|---|
| `ShipmentStatus` | `PLANNED`, `READY`, `IN_TRANSIT`, `ARRIVED`, `UNDER_CLEARANCE`, `RELEASED`, `WAREHOUSED`, `DISPATCHED`, `DELIVERED`, `CLOSED`, `EXCEPTION` |
| `DocumentStatus` | `DRAFT`, `RECEIVED`, `OCR_EXTRACTED`, `VALIDATED`, `REJECTED`, `SUPERSEDED` |
| `CustomsStatus` | `NOT_STARTED`, `BOE_SUBMITTED`, `UNDER_REVIEW`, `CLEARED`, `HELD`, `REJECTED` |
| `ReleaseStatus` | `PENDING`, `DO_RELEASED`, `GATE_PASS_ISSUED`, `GATE_OUT`, `BLOCKED` |
| `StockStatus` | `EXPECTED`, `RECEIVED`, `PUT_AWAY`, `AVAILABLE`, `QUARANTINE`, `PICKED`, `STAGED`, `DISPATCHED`, `ISSUED` |
| `SiteReceiptStatus` | `EXPECTED`, `ARRIVED`, `INSPECTED_GOOD`, `INSPECTED_OSD`, `ACCEPTED`, `REJECTED`, `CLAIM_OPENED` |
| `ExceptionStatus` | `OPEN`, `MITIGATING`, `WAITING_APPROVAL`, `RESOLVED`, `CLOSED` |
| `CostGuardBand` | `PASS`, `WARN`, `HIGH`, `CRITICAL` |

---

## Part 3: Identity & Key Policy {#part-3}

### 3.1 Identity Principle

**One internal object, many external identifiers.**

Every operational object must be reachable from at least one external key, and every high-value object must carry normalized key lineage through `Identifier`.

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

hvdc:Identifier a owl:Class ;
  rdfs:label "Logistics Identifier" ;
  rdfs:comment "External key normalized to a resolvable internal object." .

hvdc:identifierScheme a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:string .
hvdc:identifierValue  a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:string .
hvdc:normalizedValue  a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:string .
hvdc:sourceSystem     a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:string .
hvdc:isPrimary        a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:boolean .
hvdc:validFrom        a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:dateTime .
hvdc:validTo          a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:dateTime .
hvdc:confidenceScore  a owl:DatatypeProperty ; rdfs:domain hvdc:Identifier ; rdfs:range xsd:decimal .

hvdc:resolvesTo a owl:ObjectProperty ;
  rdfs:domain hvdc:Identifier ;
  rdfs:range owl:Thing .
```

### 3.2 Identifier Families

| Family | Identifier schemes | Target objects |
|---|---|---|
| Project | `projectCode`, `contractNo`, `siteWorkPackage` | `Project`, `Package` |
| Procurement | `packageNo`, `poNo`, `vendorCode`, `releaseNo` | `Package`, `PurchaseOrder`, `Vendor` |
| Material | `materialCode`, `mfgPartNo`, `serialNo`, `HVDC_CODE`, `tagNo` | `MaterialMaster`, `HVDCCodeTag`, `CargoUnit` |
| Shipment | `shipmentId`, `bookingNo`, `blNo`, `voyageNo`, `rotationNo`, `carrierRef` | `Shipment`, `ShipmentUnit`, `BillOfLadingDocument`, `PortCall` |
| Container | `containerNo`, `sealNo`, `isoCode` | `Container`, `CargoUnit` |
| Customs | `boeNo`, `declarationLineRef`, `hsCode`, `cooRef` | `CustomsEntry`, `BOEDocument` |
| Release | `doNo`, `gatePassRef`, `freeTimeRef` | `ReleaseOrder`, `DeliveryOrderDocument` |
| Warehouse | `whReceiptNo`, `warehouseId`, `locationCode`, `binNo`, `stockRef` | `WarehouseTask`, `WarehouseLocation`, `WarehouseHandlingProfile` |
| Site | `siteCode`, `mrrNo`, `mriNo`, `mrsNo`, `misNo`, `podNo`, `grnNo` | `SiteReceipt`, `InspectionEvent`, `MRR`, `POD`, `GRN` |
| Exception | `exceptionId`, `claimRef`, `ncrRef`, `osdrNo` | `Exception`, `Claim`, `NCR`, `OSDR` |
| Cost | `invoiceNo`, `invoiceLineNo`, `costCode`, `tariffRef`, `rateRefId` | `Invoice`, `InvoiceLine`, `RateRef`, `CostGuardResult` |

### 3.3 Parent-Child Hierarchy

```text
Project
  └─ hasPackage → Package
       └─ coveredBy → PurchaseOrder
            └─ issuedTo → Vendor
                 └─ supplies → MaterialMaster
                      ├─ taggedBy → HVDCCodeTag
                      └─ unitizedAs → CargoUnit
                           ├─ packedIn → Container
                           └─ belongsTo → ShipmentUnit
                                ├─ groupedIn → Shipment
                                ├─ hasJourneyLeg[]
                                ├─ hasMilestone[]
                                ├─ hasDocument[]
                                ├─ hasWarehouseHandlingProfile?  # only if WH event exists
                                ├─ hasSiteReceipt?
                                ├─ hasCostItem[]
                                └─ hasException[]
```

### 3.4 Any-key Resolution Flow

```text
Input key: ETA / HVDC_CODE / Vendor / PO / Package / Material / Shipment / Container / BL / BOE / DO / WH / Site / Claim / Invoice
  → normalize(identifierScheme, identifierValue)
  → Identifier.normalizedValue
  → Identifier.resolvesTo(object)
  → if object is not ShipmentUnit, traverse to nearest ShipmentUnit
  → return Operational Twin context:
      currentStage, routingPattern, currentLocation,
      journeyLegs, milestones, documents, customs, release,
      warehouse profile, site receipt, cost, exception, evidence
```

### 3.5 Identity Quality Gates

| Gate | Rule | Threshold |
|---|---|---:|
| `IdentifierCompleteness` | `identifierScheme`, `identifierValue`, `normalizedValue`, `sourceSystem` required | 100.00% |
| `AnyKeyResolution` | Key resolves to an object or candidate match | ≥ 95.00% |
| `HighValueMatchReview` | Invoice or shipment value > 100,000.00 AED requires human review if confidence < 0.98 | 100.00% |
| `DuplicateClusterCheck` | Same normalized key cannot map to conflicting live objects without `sameAsCandidate` | 0.00 conflicts |
| `HVDCCodePolicy` | `HVDC_CODE` is a cross-cutting tag, not sole identity anchor | mandatory |

---

## Part 4: Core Master Data Model {#part-4}

### 4.1 Master Object Types

| Object Type | Primary internal key | Required properties | Notes |
|---|---|---|---|
| `Project` | `projectRid` | `projectCode`, `projectName`, `country`, `status` | Parent scope |
| `Package` | `packageRid` | `packageNo`, `packageType`, `siteCode`, `requiredDate` | Procurement and site demand bridge |
| `PurchaseOrder` | `poRid` | `poNo`, `vendorCode`, `incoterm`, `currency`, `issueDate` | Incoterms and payment anchors |
| `Vendor` | `vendorRid` | `vendorCode`, `vendorName`, `country`, `role` | Supplier/shipper/manufacturer roles |
| `MaterialMaster` | `materialRid` | `materialCode`, `description`, `uom`, `hsCode`, `originCountry` | HS, origin, compliance |
| `HVDCCodeTag` | `hvdcCodeRid` | `hvdcCode`, `engineeringArea`, `siteRelevance` | Cross-cutting engineering-logistics tag |
| `Party` | `partyRid` | `partyCode`, `partyName`, `partyRole` | Shipper, consignee, carrier, broker, authority |
| `ContractTerm` | `contractTermRid` | `termType`, `termCode`, `effectiveDate` | Incoterm, charter, service contract |
| `RegulatoryRequirement` | `regReqRid` | `authority`, `requirementType`, `triggerCondition` | MOIAT/FANR/DCD/ADNOC gates |

### 4.2 Location and Node Types

| Object Type | Required properties | Classification rule |
|---|---|---|
| `LocationNode` | `nodeCode`, `nodeType`, `name`, `country`, `geoRef` | Superclass for all logistics nodes |
| `Port` | `portCode`, `UNLOCODE`, `portName` | Port of loading/discharge/entry |
| `Terminal` | `terminalId`, `terminalName`, `portCode`, `berth` | Terminal under port |
| `Warehouse` | `warehouseId`, `name`, `warehouseType`, `operator` | Indoor/outdoor/DG/OOG storage node |
| `WarehouseLocation` | `locationCode`, `zone`, `rackBinYard`, `capacityClass` | Sub-location of `Warehouse` only |
| `OffshoreStaging` | `nodeCode`, `operator`, `marineAccessMode` | `MOSB` belongs here, not to `Warehouse` |
| `Site` | `siteCode`, `siteName`, `onshoreOffshore`, `receivingRule` | AGI/DAS/MIR/SHU |
| `Berth`, `Jetty`, `LaydownYard`, `SiteGate` | local operational fields | Specialized location nodes |

### 4.3 Resource Types

| Object Type | Required properties | Usage |
|---|---|---|
| `Carrier` | `carrierCode`, `carrierName`, `mode` | Main carriage / ocean / road / air |
| `Forwarder` | `forwarderCode`, `name`, `serviceRole` | Freight forwarder / 3PL |
| `Broker` | `brokerCode`, `name`, `authorityScope` | Customs and permit processes |
| `EquipmentResource` | `equipId`, `equipType`, `SWL`, `certificateRef` | Crane, forklift, SPMT, spreader, rigging gear |
| `VesselResource` | `vesselName`, `imo`, `vesselType`, `capacity` | Vessel, LCT, barge, tug |
| `ManpowerResource` | `personOrRoleId`, `role`, `certificateRef` | Use role-based identifiers where PII masking is required |

---

## Part 5: Execution Transaction Model {#part-5}

### 5.1 Core Transaction Objects

| Object Type | Required properties | Key links |
|---|---|---|
| `Shipment` | `shipmentId`, `mode`, `status`, `plannedRoutingPattern`, `origin`, `destination`, `ETD`, `ETA`, `ATD`, `ATA` | `hasUnit`, `hasPortCall`, `hasDocument` |
| `ShipmentUnit` | `shipmentUnitId`, `routingPattern`, `currentStage`, `currentLocation`, `declaredDestination` | Central operational twin |
| `CargoUnit` | `cargoUnitId`, `packageNo`, `grossWeight`, `volume`, `dimensions`, `condition` | `belongsToShipmentUnit`, `packedIn` |
| `Container` | `containerNo`, `sealNo`, `isoType`, `freeTime` | `containsCargoUnit` |
| `JourneyLeg` | `legId`, `legSequence`, `fromNode`, `toNode`, `mode`, `plannedETD`, `plannedETA`, `actualATD`, `actualATA` | `departsFrom`, `arrivesAt` |
| `PortCall` | `portCallId`, `rotationNo`, `portCode`, `plannedRoutingPattern`, `declaredDestination` | `evidencesShipment`, `hasServiceEvent` |
| `ServiceEvent` | `serviceEventId`, `serviceType`, `eventDt`, `provider`, `costCenter` | Port/OFCO service proof |
| `CustomsEntry` | `customsEntryId`, `boeRef`, `customsStatus`, `duty`, `broker`, `clearanceDate`, `hsCode` | `referencesBOEDocument` |
| `ReleaseOrder` | `releaseOrderId`, `doRef`, `releaseDate`, `terminal`, `freeTime`, `gatePassRef` | `referencesDODocument` |
| `Delivery` | `deliveryId`, `dispatchDate`, `arrivalDate`, `originNode`, `destinationNode`, `vehicleRef` | `usesJourneyLeg` |
| `WarehouseTask` | `taskId`, `warehouseId`, `locationCode`, `stockStatus`, `storageRequirementClass`, `preservationStatus` | `createsWarehouseEvent` |
| `SiteReceipt` | `receiptId`, `siteCode`, `receiptType`, `inspectionResult`, `mrrRef`, `osdrRef`, `podRef`, `grnRef` | `generatesSiteDocuments` |
| `MarineTask` | `marineTaskId`, `marineRoutingPattern`, `vesselRef`, `operationWindow`, `approvalStatus` | `hasMarineEvent`, `usesEquipment` |

### 5.2 Transaction / Document Split

```text
CustomsEntry --references--> BOEDocument
ReleaseOrder --references--> DeliveryOrderDocument
SiteReceipt --references--> MRR / MRI / MRS / MIS / POD / GRN / OSDR
PortCall --evidencedBy--> ArrivalNotice / PortInvoice / ServiceRecord
WarehouseTask --evidencedBy--> WHReceipt / PutAwayNote / PickList / DispatchNote
MarineTask --evidencedBy--> PTW / FRA / MethodStatement / LashingPlan / StabilityReport / TideTable
```

### 5.3 Foundry Ontology Object Mapping

| Foundry Object Type | Backing dataset family | Cardinality / notes |
|---|---|---|
| `ShipmentUnit` | TMS + ERP package + WMS + LDG linked facts | One central operational twin per traceable unit |
| `Identifier` | normalized keys from all sources | N:1 to target object |
| `JourneyLeg` | carrier/TMS/road/marine feeds | N:1 to `ShipmentUnit` |
| `MilestoneEvent` | EPCIS/DCSA/TMS/WMS/port/site events | N:1 to `ShipmentUnit` |
| `Document` | LDG/OCR/document repository | N:N with ShipmentUnit/CargoUnit/Transaction |
| `CostGuardResult` | invoice audit pipeline | N:1 to InvoiceLine / Invoice |
| `WarehouseHandlingProfile` | WMS WH In/put-away events | 0..1 per ShipmentUnit unless split handling exists |
| `CommunicationEvent` | email/chat/task system | Evidence-only link to object/action |

### 5.4 Action Types

| Action Type | Target | Required parameters | Guard |
|---|---|---|---|
| `ResolveAnyKey` | `Identifier` | `identifierScheme`, `identifierValue` | confidence ≥ 0.95 or human review |
| `RecordPortRoutingEvidence` | `PortCall` | `plannedRoutingPattern`, `declaredDestination`, `offshoreTransitRequired` | No warehouse classification write |
| `SubmitBOE` | `CustomsEntry` | `boeRef`, `hsCode`, `broker`, `duty` | CI/PL/BL and permit readiness |
| `ReleaseDO` | `ReleaseOrder` | `doRef`, `releaseDate`, `gatePassRef` | BOE cleared |
| `RecordGateOut` | `ShipmentUnit` | `terminal`, `actualDt`, `carrier` | DO exists |
| `ConfirmWHIn` | `WarehouseTask` | `warehouseId`, `actualDt`, `locationCode`, `storageClass` | M110 creates/updates WHP |
| `StageMOSB` | `MarineTask` | `mosbNode`, `actualDt`, `vesselRef` | Required for AGI/DAS offshore route |
| `RecordSiteArrival` | `SiteReceipt` | `siteCode`, `actualDt`, `receiptType` | M115 check for AGI/DAS MOSB routes |
| `CloseCostGuard` | `Invoice` | `reviewDecision`, `approvalRef` | Delta band and human-gate applied |
| `OpenClaim` | `Exception` | `claimType`, `evidenceDoc`, `amount` | OSDR/NCR evidence required |

---

## Part 6: Document & Evidence Model {#part-6}

### 6.1 Document Base Class

```turtle
hvdc:Document a owl:Class ;
  rdfs:label "Logistics Document" .

hvdc:documentNo    a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:docType       a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:docHash       a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:issueDate     a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:date .
hvdc:sourceSystem  a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:ocrConfidence a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:decimal .
hvdc:validatedBy   a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range hvdc:VerificationResult .
```

### 6.2 Document Types

| Document Type | Required properties | Primary validation |
|---|---|---|
| `CommercialInvoiceDocument` | `invoiceNo`, `vendor`, `currency`, `totalAmount`, `lineCount` | Invoice total = Σ line ± 2.00% |
| `PackingListDocument` | `plNo`, `packageCount`, `grossWeight`, `volume` | PL package/weight/volume vs CargoUnit |
| `BillOfLadingDocument` | `blNo`, `carrier`, `portOfLoading`, `portOfDischarge` | BL vs Shipment/Container/PortCall |
| `CertificateOfOriginDocument` | `cooNo`, `originCountry`, `issuer` | Origin consistency with material |
| `BOEDocument` | `boeNo`, `declarationDate`, `customsAuthority` | Evidence for `CustomsEntry` |
| `DeliveryOrderDocument` | `doNo`, `releaseDate`, `terminal` | Evidence for `ReleaseOrder` |
| `PermitDocument` | `permitNo`, `authority`, `permitType`, `expiryDate` | MOIAT/FANR/DCD/ADNOC controls |
| `MRR` / `MRI` | `receiptNo`, `inspectionNo`, `siteCode` | Site receipt and inspection evidence |
| `MRS` / `MIS` | `requestNo`, `issueNo`, `siteCode` | Material request / issue evidence |
| `POD` / `GRN` | `podNo`, `grnNo`, `acceptanceDate` | Handover closure |
| `OSDR` | `osdrNo`, `defectType`, `severity`, `claimRef` | Exception/claim trigger |
| `PTW` / `FRA` / `MethodStatement` | `approvalNo`, `workScope`, `expiryDate` | Heavy-lift/marine execution gate |
| `LashingPlan` / `StabilityReport` | `planNo`, `engineerApproval`, `revision` | Marine/OOG technical gate |

### 6.3 OCR / LDG Evidence Properties

| Property | Domain | Range | Ownership rule |
|---|---|---|---|
| `routeEvidence` | `Document` | string / SKOS concept | Evidence only; feeds routing decision |
| `destinationEvidence` | `Document` | site code string | Evidence only |
| `mosbLegIndicator` | `Document` | boolean | Evidence only |
| `routeEvidenceConfidence` | `Document` | decimal | 0.00–1.00 |
| `extractedEntity` | `Document` | `DocumentEntity` | OCR extraction |
| `crossDocLink` | `DocumentEntity` | `CrossDocLink` | Semantic verification |
| `verificationResult` | `Document` | `VerificationResult` | LDG result |

### 6.4 Evidence Layer Rules

1. Evidence may support a routing, compliance, cost, or exception decision.
2. Evidence may not directly mutate the operational truth unless an approved Action writes the transaction object.
3. Communication records are linked through `CommunicationEvent`, `ApprovalAction`, and `AuditRecord`.
4. PII shall be masked except approved business names and role-level contacts.
5. Proof artifacts shall store source document, extraction confidence, rule ID, verdict, timestamp, and reviewer when applicable.

### 6.5 OCR KPI Gates

| KPI | Threshold | Action |
|---|---:|---|
| `MeanConf` | ≥ 0.92 | Below threshold → human review |
| `TableAcc` | ≥ 0.98 | Below threshold → table re-extraction |
| `NumericIntegrity` | 1.00 | Any break → block finance/customs release |
| `CrossDocumentConsistency` | 1.00 | Strict for CI/PL/BL/BOE/DO critical fields |
| `RouteEvidenceAccuracy` | ≥ 0.95 | Below threshold → route evidence review |

---

## Part 7: End-to-End Process & Milestone Model {#part-7}

### 7.1 MilestoneEvent Class

```turtle
hvdc:MilestoneEvent a owl:Class ;
  rdfs:label "Logistics Milestone Event" ;
  rdfs:comment "First-class event containing planned, estimated, and actual timestamps." .

hvdc:milestoneCode    a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:string .
hvdc:milestoneName    a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:string .
hvdc:plannedDt        a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:dateTime .
hvdc:estimatedDt      a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:dateTime .
hvdc:actualDt         a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:dateTime .
hvdc:statusAfterEvent a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:string .
hvdc:eventLocation    a owl:ObjectProperty ;  rdfs:domain hvdc:MilestoneEvent ; rdfs:range hvdc:LocationNode .
hvdc:responsibleParty a owl:ObjectProperty ;  rdfs:domain hvdc:MilestoneEvent ; rdfs:range hvdc:Party .
hvdc:sourceDocument   a owl:ObjectProperty ;  rdfs:domain hvdc:MilestoneEvent ; rdfs:range hvdc:Document .
hvdc:sourceSystem     a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:string .
hvdc:exceptionFlag    a owl:DatatypeProperty ; rdfs:domain hvdc:MilestoneEvent ; rdfs:range xsd:boolean .
```

### 7.2 Canonical Milestone Dictionary

| Milestone | Name | Journey Stage | Owner domain | Required evidence |
|---|---|---|---|---|
| M10 | Cargo Ready | `PLANNING` | Vendor/Expeditor | readiness notice / inspection release |
| M20 | Packed / Marked | `ORIGIN_DISPATCH` | Vendor | PL / marking sheet |
| M30 | Pickup Completed | `ORIGIN_DISPATCH` | Forwarder | pickup note / transport order |
| M40 | Export Cleared | `ORIGIN_DISPATCH` | Export broker | export declaration |
| M50 | Terminal Received | `PORT_ENTRY` / `TERMINAL_HANDLING` | Terminal | terminal receipt |
| M60 | Loaded On Board | `TERMINAL_HANDLING` | Carrier | load list / BL |
| M61 | ATD | `TERMINAL_HANDLING` | Carrier | carrier milestone |
| M70 | Transshipment Occurred | `TERMINAL_HANDLING` | Carrier | transshipment notice |
| M80 | ATA | `PORT_ENTRY` | Carrier/Agent | arrival notice |
| M90 | BOE Submitted | `CUSTOMS_CLEARANCE` | Import broker | BOE draft/submission |
| M91 | BOE Cleared | `CUSTOMS_CLEARANCE` | Import broker | clearance confirmation |
| M92 | DO Released | `CUSTOMS_CLEARANCE` | Carrier/Agent | DO / release note |
| M100 | Gate-out Completed | `INLAND_HAULAGE` | Terminal/Forwarder | gate pass / EIR |
| M110 | Warehouse Received | `WH_RECEIPT` | Warehouse operator | WH receipt |
| M111 | Put-away Completed | `WH_STORAGE` | Warehouse operator | put-away note |
| M115 | MOSB Staged | `MOSB_STAGING` | Marine contractor | MOSB staging record |
| M116 | LCT/Barge Loaded | `OFFSHORE_TRANSIT` | Marine contractor | load manifest / marine event |
| M117 | Sail-away Approved | `OFFSHORE_TRANSIT` | Marine / ALS | sail-away approval |
| M120 | Picked / Staged | `WH_DISPATCH` | Warehouse operator | pick/stage list |
| M121 | Dispatched | `WH_DISPATCH` | WH/Site logistics | dispatch note |
| M130 | Site Arrived | `SITE_RECEIVING` | Site logistics | delivery note / arrival record |
| M131 | Site Inspected — Good | `SITE_RECEIVING` | QA/QC | MRI/MRR good result |
| M132 | Site Inspected — OSD | `SITE_RECEIVING` | QA/QC | OSDR / defect evidence |
| M140 | POD / GRN / Handover | `MATERIAL_ISSUE` | Site stores | POD / GRN |
| M150 | Claim Opened | `CLOSEOUT` | Claims | claim file / OSDR/NCR |
| M160 | Cost Closed | `CLOSEOUT` | Cost control | final invoice / cost closure |

### 7.3 E2E 19-step Process Map

| Step | Process | Primary milestone(s) | Key objects | Risk / exception |
|---:|---|---|---|---|
| 1 | Project / Package / PO Release | demand event | Project, Package, PO | Missing package/PO chain |
| 2 | Vendor Readiness | M10 | Vendor, MaterialMaster | readiness delay |
| 3 | Packing / Marking / Labelling | M20 | CargoUnit, PL, CI | packing discrepancy |
| 4 | Pickup / Origin Haulage | M30 | ShipmentUnit, JourneyLeg | truck no-show / damage |
| 5 | Export Customs Clearance | M40 | Customs export record | export hold |
| 6 | Terminal Receiving | M50 | PortCall, Terminal | terminal delay |
| 7 | Vessel Loading / Departure | M60/M61 | Shipment, BL, Container | rollover / lashing issue |
| 8 | Ocean / Transshipment | M70 | JourneyLeg | missed connection |
| 9 | Arrival / Pre-arrival Review | M80 | PortCall, Document pack | missing docs |
| 10 | Import BOE | M90/M91 | CustomsEntry, BOEDocument | customs hold / permit expiry |
| 11 | DO / Gate-out | M92/M100 | ReleaseOrder, Delivery | DEM/DET exposure |
| 12 | Inland Transport | JourneyLeg event | Delivery, Truck/SPMT | access restriction |
| 13 | Warehouse Receiving | M110 | WarehouseTask, WHP | receipt mismatch |
| 14 | Put-away / Storage / Preservation | M111 | WarehouseTask, StockSnapshot | wrong bin / preservation failure |
| 15 | Picking / Staging / Dispatch | M120/M121 | WarehouseTask, Delivery | short pick / wrong material |
| 16 | Offshore / Heavy-lift / OOG | M115/M116/M117 | MarineTask, MarineEvent | HSE stop / weather / lift failure |
| 17 | Site Delivery / Inspection | M130/M131/M132 | SiteReceipt, InspectionEvent | OSD / damage / shortage |
| 18 | POD / GRN / Handover | M140 | POD, GRN, SiteReceipt | missing acknowledgement |
| 19 | Exception / Claim / Cost Closure | M150/M160 | Exception, Claim, Invoice | lingering claim/cost exposure |

### 7.4 AGI/DAS Offshore Rule

```text
IF ShipmentUnit.declaredDestination IN ("AGI", "DAS")
AND ShipmentUnit.routingPattern IN ("MOSB_DIRECT", "WH_MOSB", "MIXED")
AND M130.actualDt IS NOT NULL
AND M115.actualDt IS NULL
THEN VIOLATION-2: Block site arrival closure and request MOSB evidence.
```

---

## Part 8: Knowledge Graph Node/Edge Design {#part-8}

### 8.1 Node Families

| Node family | Classes | Primary resolution keys |
|---|---|---|
| Master | Project, Package, PO, Vendor, MaterialMaster, HVDCCodeTag | projectCode, packageNo, poNo, vendorCode, materialCode, HVDC_CODE |
| Transport | Shipment, ShipmentUnit, JourneyLeg, PortCall, Delivery | shipmentId, bookingNo, BL No., rotationNo, ETA/ATA |
| Physical | CargoUnit, Container, EquipmentResource, VesselResource | cargoUnitId, containerNo, sealNo, equipId, vesselName |
| Document | CI, PL, BL, BOE, DO, Permit, MRR, OSDR, POD, GRN | documentNo, docHash |
| Event | MilestoneEvent, WarehouseEvent, MarineEvent, InspectionEvent, ServiceEvent | eventId, milestoneCode |
| Exception | Delay, Damage, Shortage, Overage, NCR, Claim | exceptionId, claimRef, ncrRef, osdrNo |
| Cost | Invoice, InvoiceLine, RateRef, CostTransaction, DEMDETClock | invoiceNo, invoiceLineNo, costCode, tariffRef |
| Evidence | AuditRecord, CommunicationEvent, ApprovalAction, VerificationResult | threadId, emailId, approvalRef, proofId |

### 8.2 Edge Grammar

```turtle
# Containment / hierarchy
hvdc:hasPackage, hvdc:coveredBy, hvdc:issuedTo, hvdc:supplies, hvdc:unitizedAs, hvdc:containsCargoUnit, hvdc:packedIn, hvdc:hasUnit

# Identity
hvdc:hasIdentifier, hvdc:resolvesTo, hvdc:sameAsCandidate, hvdc:hasNormalizedKey

# Movement
hvdc:hasJourneyLeg, hvdc:departsFrom, hvdc:arrivesAt, hvdc:deliveredTo, hvdc:storedAt, hvdc:stagedAt

# Evidence / provenance
hvdc:evidencedBy, hvdc:referencesDocument, hvdc:attachedTo, hvdc:provenanceOf, hvdc:validatedBy

# Status / event
hvdc:hasMilestone, hvdc:hasInspection, hvdc:hasWarehouseEvent, hvdc:hasMarineEvent, hvdc:triggeredBy

# Responsibility
hvdc:operatedBy, hvdc:approvedBy, hvdc:handledBy, hvdc:assignedTo, hvdc:issuedBy

# Compliance
hvdc:requiresPermit, hvdc:classifiedByHS, hvdc:conformsTo, hvdc:governedBy, hvdc:checkedBy

# Finance
hvdc:chargesFor, hvdc:mappedToCostCode, hvdc:linkedToInvoice, hvdc:usesRateRef, hvdc:accruesTo
```

### 8.3 Query Templates

#### ETA / ATA → Full Context

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>

SELECT ?unit ?eta ?stage ?routing ?location ?boe ?do ?whp ?site ?risk ?invoice
WHERE {
  ?leg hvdc:estimatedATA ?eta .
  FILTER(?eta > NOW() && ?eta < NOW() + "P7D"^^xsd:duration)
  ?unit hvdc:hasJourneyLeg ?leg ;
        hvdc:hasCurrentStage ?stage ;
        hvdc:hasRoutingPattern ?routing ;
        hvdc:hasCurrentLocation ?location .
  OPTIONAL { ?unit hvdc:hasCustomsEntry ?ce . ?ce hvdc:boeRef ?boe . }
  OPTIONAL { ?unit hvdc:hasReleaseOrder ?ro . ?ro hvdc:doRef ?do . }
  OPTIONAL { ?unit hvdc:hasWarehouseHandlingProfile ?whp . }
  OPTIONAL { ?unit hvdc:hasSiteReceipt ?site . }
  OPTIONAL { ?unit hvdc:hasException ?risk . }
  OPTIONAL { ?unit hvdc:hasCostItem ?invoice . }
}
ORDER BY ?eta
```

#### Any-key → ShipmentUnit Twin

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?unit ?scheme ?value ?stage ?routing ?doc ?milestone ?cost ?exception
WHERE {
  ?id hvdc:identifierScheme ?scheme ;
      hvdc:normalizedValue ?value ;
      hvdc:resolvesTo ?resolved .
  BIND(COALESCE(?resolved, ?id) AS ?seed)
  ?seed (hvdc:belongsToShipmentUnit|^hvdc:hasDocument|^hvdc:packedIn|^hvdc:hasCustomsEntry|^hvdc:hasReleaseOrder)* ?unit .
  ?unit a hvdc:ShipmentUnit ;
        hvdc:hasCurrentStage ?stage ;
        hvdc:hasRoutingPattern ?routing .
  OPTIONAL { ?unit hvdc:hasDocument ?doc . }
  OPTIONAL { ?unit hvdc:hasMilestone ?milestone . }
  OPTIONAL { ?unit hvdc:hasCostItem ?cost . }
  OPTIONAL { ?unit hvdc:hasException ?exception . }
}
```

#### BOE No. → Release and Cost Trace

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?entry ?unit ?shipment ?boe ?do ?gateOut ?invoice ?deltaPct ?band
WHERE {
  ?entry a hvdc:CustomsEntry ; hvdc:boeRef ?boe .
  ?unit hvdc:hasCustomsEntry ?entry .
  OPTIONAL { ?unit hvdc:groupedIn ?shipment . }
  OPTIONAL { ?unit hvdc:hasReleaseOrder ?ro . ?ro hvdc:doRef ?do . }
  OPTIONAL { ?unit hvdc:hasMilestone ?m . ?m hvdc:milestoneCode "M100" ; hvdc:actualDt ?gateOut . }
  OPTIONAL { ?unit hvdc:hasCostItem ?line . ?line hvdc:belongsToInvoice ?invoice ; hvdc:deltaPct ?deltaPct ; hvdc:costGuardBand ?band . }
}
```

---

## Part 9: Integration Architecture {#part-9}

### 9.1 Pipeline Pattern

```text
Raw source
  → Bronze: source schema, ingest timestamp, source owner, file hash
  → Silver: normalized identifiers, dates, units, currencies, locations
  → Gold: canonical object tables + link tables + evidence tables
  → Ontology: Object Types, Link Types, Actions, Functions
  → Validation: SHACL/SPARQL rules + RAG evidence + human-gate
  → Apps: Logistics COP, KPI, COST-GUARD, Document Guardian, routing dashboard
```

### 9.2 Source-to-Ontology Mapping

| Source system / feed | Canonical objects | Link points |
|---|---|---|
| ERP / Procurement | Project, Package, PO, Vendor, MaterialMaster | Project→Package→PO→Vendor→Material |
| Engineering tag register | HVDCCodeTag, MaterialMaster | Material↔HVDCCodeTag |
| TMS / Forwarder | Shipment, ShipmentUnit, JourneyLeg, Delivery | Shipment→Unit→Leg |
| Carrier / DCSA-style feed | Container, BL, MilestoneEvent | Container→CargoUnit, BL→Shipment |
| OFCO / Port Ops | PortCall, ServiceEvent, TariffRef, InvoiceLine | PortCall↔Shipment, ServiceEvent→InvoiceLine |
| ATLP / Customs / Broker | CustomsEntry, ReleaseOrder, PermitDocument | CustomsEntry→BOE, ReleaseOrder→DO |
| WMS | WarehouseTask, WarehouseEvent, StockSnapshot, WarehouseHandlingProfile | ShipmentUnit→WarehouseTask→WHP |
| Marine / MOSB | MarineTask, MarineEvent, VesselResource, EquipmentResource | ShipmentUnit→M115/M116/M117 |
| Site systems | SiteReceipt, InspectionEvent, MRR, OSDR, POD, GRN | SiteReceipt→Documents |
| LDG / OCR | Document, DocumentEntity, VerificationResult, AuditRecord | Document→ShipmentUnit / Transaction |
| Invoice / Finance | Invoice, InvoiceLine, RateRef, CostGuardResult | InvoiceLine→ShipmentUnit / PortCall / Task |
| Communication | CommunicationEvent, ApprovalAction, AuditRecord | Evidence link only |

### 9.3 Foundry Implementation Notes

| Foundry layer | Implementation rule |
|---|---|
| Object Types | Create object types from Gold datasets only; raw records remain evidence/source lineage |
| Link Types | Materialize edge tables for high-cardinality links; derive secondary links through Functions |
| Actions | Use transaction-gated Actions for BOE, DO, WH In, MOSB, Site Arrival, Cost Closure |
| Functions | Implement `resolveAnyKey`, `computeCurrentStage`, `computeRoutingPattern`, `costGuardDelta`, `validateAGIDASGate` |
| Workshop / Quiver | Publish COP, search panel, shipment timeline, route risk, CostGuard views |
| Automation | Trigger validation on ingest, action submit, milestone close, invoice audit, daily digest |

### 9.4 Integration KPIs

| KPI | Target |
|---|---:|
| Object mapping coverage | ≥ 95.00% |
| Link completeness | ≥ 95.00% |
| Any-key search precision | ≥ 95.00% |
| Milestone coverage | ≥ 90.00% |
| Validation p95 latency | < 5.00s |
| Audit trail completeness | 100.00% for blocked actions |

---

## Part 10: Validation Rules: SHACL, SPARQL, RAG, Human-gate {#part-10}

### 10.1 Validation Control Matrix

| Rule ID | Target | Logic | Severity |
|---|---|---|---|
| `V-IDENT-001` | `Identifier` | scheme/value/normalized/source required | BLOCK |
| `V-SU-001` | `ShipmentUnit` | must have ≥1 Identifier, RoutingPattern, CurrentStage | BLOCK |
| `V-FLOW-001` | `confirmedFlowCode` | subject must be `WarehouseHandlingProfile` | BLOCK |
| `V-FLOW-002` | `WarehouseHandlingProfile` | confirmation requires M110 actual timestamp | BLOCK |
| `V-ROUTE-001` | `ShipmentUnit` | RoutingPattern enum only | BLOCK |
| `V-AGIDAS-001` | AGI/DAS unit | M130 requires M115 for MOSB-inclusive routes | BLOCK |
| `V-DOC-001` | CI/PL/BL/BOE/DO | cross-document key, qty, weight consistency | WARN/BLOCK |
| `V-CUSTOMS-001` | `CustomsEntry` | BOE document must be linked but not collapsed | BLOCK |
| `V-RELEASE-001` | `ReleaseOrder` | DO document must exist before M100 | BLOCK |
| `V-SITE-001` | `SiteReceipt` | M130 must link to SiteCode and delivery evidence | BLOCK |
| `V-COST-001` | `InvoiceLine` | EA × Rate = Amount ± 0.01 | BLOCK |
| `V-COST-002` | `Invoice` | Σ lineAmount = invoiceTotal ± 2.00% | BLOCK |
| `V-COST-003` | `CostGuardResult` | Δ% band assigned | BLOCK |
| `V-EVID-001` | `Document` / communication | evidence cannot own transaction truth | BLOCK |

### 10.2 SHACL: ShipmentUnit Required Shape

```turtle
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix hvdc: <http://samsung.com/project-logistics#> .

hvdc:ShipmentUnitRequiredShape a sh:NodeShape ;
  sh:targetClass hvdc:ShipmentUnit ;
  sh:property [
    sh:path hvdc:hasIdentifier ; sh:minCount 1 ;
    sh:message "ShipmentUnit must have at least one Identifier." ;
  ] ;
  sh:property [
    sh:path hvdc:hasRoutingPattern ; sh:minCount 1 ;
    sh:in (hvdc:PRE_ARRIVAL hvdc:DIRECT hvdc:WH_ONLY hvdc:MOSB_DIRECT hvdc:WH_MOSB hvdc:MIXED) ;
    sh:message "ShipmentUnit must have a valid ShipmentRoutingPattern." ;
  ] ;
  sh:property [
    sh:path hvdc:hasCurrentStage ; sh:minCount 1 ;
    sh:message "ShipmentUnit must have a current JourneyStage." ;
  ] .
```

### 10.3 SHACL: Warehouse Boundary Shape

```turtle
hvdc:FlowCodeBoundaryShape a sh:NodeShape ;
  sh:targetSubjectsOf hvdc:confirmedFlowCode ;
  sh:sparql [
    sh:message "VIOLATION-1: confirmedFlowCode found outside WarehouseHandlingProfile — immediate block." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:confirmedFlowCode ?fc .
        FILTER NOT EXISTS { $this a hvdc:WarehouseHandlingProfile }
      }
    """ ;
  ] .
```

### 10.4 SHACL: WHP Confirmation Requires M110

```turtle
hvdc:WarehouseHandlingConfirmationShape a sh:NodeShape ;
  sh:targetClass hvdc:WarehouseHandlingProfile ;
  sh:sparql [
    sh:message "VIOLATION-1B: WarehouseHandlingProfile cannot be confirmed before M110 Warehouse Received." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:flowConfirmationStatus "confirmed" ;
              hvdc:belongsToShipmentUnit ?unit .
        FILTER NOT EXISTS {
          ?unit hvdc:hasMilestone ?m110 .
          ?m110 hvdc:milestoneCode "M110" ; hvdc:actualDt ?dt .
        }
      }
    """ ;
  ] .
```

### 10.5 SHACL: AGI/DAS MOSB Milestone Shape

```turtle
hvdc:AGIDASStagingShape a sh:NodeShape ;
  sh:targetClass hvdc:ShipmentUnit ;
  sh:sparql [
    sh:message "VIOLATION-2: AGI/DAS shipment missing MOSB staging milestone M115 before Site Arrived M130." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:declaredDestination ?dest ;
              hvdc:hasRoutingPattern ?rp ;
              hvdc:hasMilestone ?m130 .
        FILTER(?dest IN ("AGI", "DAS"))
        FILTER(?rp IN (hvdc:MOSB_DIRECT, hvdc:WH_MOSB, hvdc:MIXED))
        ?m130 hvdc:milestoneCode "M130" ; hvdc:actualDt ?arrived .
        FILTER NOT EXISTS {
          $this hvdc:hasMilestone ?m115 .
          ?m115 hvdc:milestoneCode "M115" ; hvdc:actualDt ?staged .
        }
      }
    """ ;
  ] .
```

### 10.6 SHACL: Invoice Numeric Integrity

```turtle
hvdc:InvoiceLineNumericShape a sh:NodeShape ;
  sh:targetClass hvdc:InvoiceLine ;
  sh:sparql [
    sh:message "COST-GUARD: InvoiceLine amount must equal qty * rate within 0.01." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:qty ?qty ; hvdc:rate ?rate ; hvdc:amount ?amount .
        BIND(ABS((?qty * ?rate) - ?amount) AS ?delta)
        FILTER(?delta > 0.01)
      }
    """ ;
  ] .
```

### 10.7 COST-GUARD Rule

```text
DeltaPct = (DraftAmount - StandardAmount) / StandardAmount * 100.00

Band:
  <= 2.00%       PASS
  2.01% - 5.00%  WARN
  5.01% - 10.00% HIGH
  > 10.00%       CRITICAL

Human-gate:
  invoiceTotal > 100,000.00 AED OR band IN (HIGH, CRITICAL) → Finance approval required.
```

### 10.8 SPARQL: Legacy Term Detection

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?s ?p ?o
WHERE {
  ?s ?p ?o .
  FILTER(CONTAINS(LCASE(STR(?p)), "assignedflowcode") ||
         CONTAINS(LCASE(STR(?p)), "extractedflowcode") ||
         CONTAINS(LCASE(STR(?p)), "costbyflowcode") ||
         CONTAINS(LCASE(STR(?p)), "haslogisticsflowcode"))
}
```

### 10.9 RAG / Latest Evidence Gate

| Trigger | Required evidence refresh |
|---|---|
| Regulation / authority notice changed | RAG check against latest approved SOP / authority source |
| MOIAT/FANR/DCD/ADNOC permit mismatch | Compliance owner review |
| Cost/rate table change | Contract/rate master re-ingest and audit proof |
| Route exception for AGI/DAS | Marine + Site Logistics review |
| Low OCR confidence | LDG re-extraction or human document validation |

### 10.10 Human-gate Matrix

| Trigger | Approver |
|---|---|
| Invoice total > 100,000.00 AED | Finance Approver |
| CostGuard `HIGH` / `CRITICAL` | Cost Control Lead |
| AGI/DAS M130 without M115 | Marine Lead + Site Logistics |
| WHP override | Warehouse Manager |
| Permit expired or missing | Compliance Lead |
| OSD / NCR / damage / shortage | QA/QC + Claims |
| Identifier confidence < 0.95 for operational action | Data Steward |

---

## Part 11: Compliance Controls {#part-11}

### 11.1 Compliance Object Model

| Object | Required properties | Links |
|---|---|---|
| `ComplianceRequirement` | `authority`, `requirementType`, `triggerCondition`, `effectiveDate`, `status` | appliesTo Material/Shipment/Site/Node |
| `PermitDocument` | `permitNo`, `authority`, `permitType`, `issueDate`, `expiryDate` | evidences requirement |
| `ComplianceCheck` | `checkId`, `ruleId`, `result`, `checkedAt`, `checkedBy` | validates ShipmentUnit / Document / Material |
| `ApprovalAction` | `approvalRef`, `approverRole`, `approvedAt`, `decision` | authorizes Action |

### 11.2 Incoterms 2020 Control

| Control | Logic |
|---|---|
| `IncotermPresence` | PO / Shipment must carry `incoterm` and delivery place |
| `RiskTransferPoint` | JourneyLeg responsibility changes at incoterm-defined point |
| `CostResponsibility` | InvoiceLine must map to buyer/seller responsibility according to term |
| `DisputeEvidence` | Any cost dispute must attach contract term and route/service evidence |

### 11.3 UAE Regulatory Controls

| Authority / topic | Ontology handling |
|---|---|
| MOIAT | `MaterialMaster.isRegulatedProduct`, `requiresMOIATCoC`, `certificateRef`, `certificateExpiryDate` |
| FANR | `requiresFANRPermit`, `radiationSourceFlag`, `permitRef`, `permitExpiryDate` |
| DCD / Dangerous Goods | `dgClass`, `UNNumber`, `storageSegregationClass`, `dangerousCargoWarehouseRequired` |
| ADNOC / CICPA / Site Access | `AccessPermit`, `GatePass`, `SecurityApproval`, `LocationNode.governedBy` |
| WCO / HS | `hsCode`, `classificationConfidence`, `customsRiskScore`, `CustomsEntry` linkage |
| DCSA / carrier events | `BillOfLadingDocument`, `Container`, `MilestoneEvent`, `JourneyLeg` alignment |

### 11.4 Compliance Blockers

```text
IF regulated product AND missing valid MOIAT/FANR/DCD permit → block DO / GatePass / Site Issue.
IF hsCode missing on InvoiceLine / MaterialMaster → block BOE draft.
IF gatePass expired before gate-out → block M100.
IF AGI/DAS offshore cargo lacks marine approval evidence → block M117/M130.
```

---

## Part 12: Warehouse Flow Code Policy {#part-12}

### 12.1 Policy Scope

This part intentionally appears near the end of the master document. Warehouse Flow Code is a **warehouse-handling classification**, not the master route language.

Allowed owner:

```text
WarehouseHandlingProfile.confirmedFlowCode
```

Disallowed owners:

```text
Shipment, ShipmentUnit, PortCall, CustomsEntry, Document, Invoice, InvoiceLine, MarineTask, OperationsKPI, CommunicationEvent
```

### 12.2 WarehouseHandlingProfile Class

```turtle
hvdc:WarehouseHandlingProfile a owl:Class ;
  rdfs:label "Warehouse Handling Profile" ;
  rdfs:comment "Warehouse-only profile created by M110 Warehouse Received / put-away evidence." .

hvdc:confirmedFlowCode a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:integer ;
  rdfs:comment "Warehouse-only handling classification. Not a route classifier." .

hvdc:flowConfirmationStatus a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:string .

hvdc:wh_handling_cnt a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:integer .

hvdc:storageClass a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:string .

hvdc:flowEvidenceSource a owl:ObjectProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range hvdc:WarehouseEvent .
```

### 12.3 Confirmed Flow Code Values

| Code | Warehouse handling meaning | Minimum evidence | Notes |
|---:|---|---|---|
| 0 | `PRE_WH_OR_TENTATIVE` | No M110 WH In evidence and pre-arrival/expected status | Tentative until evidence arrives |
| 1 | `WH_BYPASS_CONFIRMED` | No M110 WH In evidence and direct delivery/bypass evidence | Confirms no warehouse handling |
| 2 | `SINGLE_WH_HANDLING` | Exactly 1 M110 WH In / put-away evidence | Standard warehouse handling |
| 3 | `WH_LINKED_OFFSHORE_HANDLING` | Warehouse evidence plus MOSB staging evidence or AGI/DAS minimum offshore handling class | WH evidence with offshore interface |
| 4 | `MULTI_WH_OFFSHORE_HANDLING` | At least 2 WH handling events plus MOSB staging evidence | Multi-WH + offshore interface |
| 5 | `MIXED_OR_UNRESOLVED_WH_PATTERN` | Incomplete, conflicting, split, or pending warehouse evidence | Requires reason flag and review |

> Numeric values are retained for warehouse operational compatibility only. They must never be interpreted as the master Port → WH → MOSB → Site route classifier. The master route classifier remains `ShipmentRoutingPattern`.

### 12.4 Legacy Migration Map

| Legacy phrase | Canonical replacement | Owner |
|---|---|---|
| `Flow Code 0 = Pre Arrival` | `ShipmentRoutingPattern.PRE_ARRIVAL` or pre-arrival milestone state | `ShipmentUnit` / `PortCall` |
| `Flow Code 1 = Port → Site` | `ShipmentRoutingPattern.DIRECT` | `ShipmentUnit` |
| `Flow Code 2 = Port → WH → Site` | `ShipmentRoutingPattern.WH_ONLY` | `ShipmentUnit` |
| `Flow Code 3 = Port → MOSB → Site` | `ShipmentRoutingPattern.MOSB_DIRECT` | `ShipmentUnit` / Marine |
| `Flow Code 4 = Port → WH → MOSB → Site` | `ShipmentRoutingPattern.WH_MOSB` | `ShipmentUnit` / Marine |
| `Flow Code 5 = Mixed` | `ShipmentRoutingPattern.MIXED` | `ShipmentUnit` |
| `assignedFlowCode` | `plannedRoutingPattern` | `PortCall` evidence |
| `extractedFlowCode` | `routeEvidence` | `Document` evidence |
| `costByFlowCode` | `costByRoutingPattern` / `routeBasedCostDriver` | Cost domain |
| `Flow Code 3/4/5` in marine text | `MarineRoutingPattern` / `offshoreDeliveryPattern` | Marine extension |

### 12.5 Warehouse Flow Validation Rules

1. `confirmedFlowCode` can appear only on `WarehouseHandlingProfile`.
2. `flowConfirmationStatus = confirmed` requires M110 actual milestone.
3. `confirmedFlowCode` shall not be used as a KPI bucket for end-to-end route analytics.
4. Cost may read `WarehouseHandlingProfile.wh_handling_cnt` and `storageClass` as evidence, but cost cannot assign `confirmedFlowCode`.
5. Port and OCR may supply route/WH evidence but cannot write `confirmedFlowCode`.

---

## Part 13: Options, Roadmap, Automation, QA {#part-13}

### 13.1 Implementation Options

| Option | Scope | Pros | Cons | CostIndex | Risk | Time |
|---|---|---|---|---:|---:|---:|
| A. Master Spine MVP | `ShipmentUnit`, Identifier, Document, Milestone, Cost baseline | Fast search/COP enablement | Limited marine/claims depth | 1.00/5.00 | 20.00% | 4.00 weeks |
| B. Operational Twin | MVP + WHP + PortCall + CustomsEntry + SiteReceipt | Strong route and action validation | More integration work | 2.50/5.00 | 18.00% | 8.00 weeks |
| C. Full Semantic Control Tower | Operational Twin + marine/OOG + CostGuard + compliance RAG | Full chain visibility and audit | Data quality dependency | 4.00/5.00 | 22.00% | 12.00 weeks |
| D. Enterprise RDF Bridge | Foundry Ontology + RDF/SHACL/GraphDB bridge | Strong OWL/SHACL reasoning | Higher architecture complexity | 5.00/5.00 | 30.00% | 16.00 weeks |

### 13.2 Roadmap

| Phase | Scope | KPI |
|---|---|---|
| Prepare | Source inventory, object/link dictionary, namespace lock | Semantic blocker count = 0.00 |
| Pilot | One onshore + one AGI/DAS + one invoice end-to-end | Key Resolution ≥ 95.00%; Milestone Coverage ≥ 90.00% |
| Build | Gold datasets + Ontology mapping + Actions | Object mapping ≥ 95.00%; Link completeness ≥ 95.00% |
| Operate | SHACL/SPARQL validation + COP dashboard + CostGuard | Validation p95 < 5.00s; NumericIntegrity = 100.00% |
| Scale | Marine/OOG, compliance RAG, predictive ETA/risk | Full-chain visibility ≥ 95.00%; ETA MAPE ≤ 12.00% |

### 13.3 Automation Notes

| Automation | Trigger | Action |
|---|---|---|
| `AnyKeySearchBot` | User enters BL/BOE/Container/HVDC_CODE/Invoice | Resolve object and open ShipmentUnit twin |
| `PreArrivalGuard` | M80 ATA / arrival notice | Validate CI/PL/BL/BOE/permit readiness |
| `GateOutGuard` | M100 action attempt | Check DO, BOE cleared, gate pass validity |
| `WHPInjector` | M110 WH Received | Create or update WarehouseHandlingProfile |
| `AGIDASGuard` | M130 Site Arrived attempt | Require M115 for AGI/DAS MOSB routes |
| `CostGuardBot` | Invoice loaded | Compute Δ%, band, proof artifact |
| `OSDRClaimBot` | M132 OSD event | Create OSDR/Claim draft and evidence pack |
| `ComplianceRAG` | Missing/expired permit | Retrieve latest approved SOP/authority evidence |
| `DailyCOPDigest` | Daily 08:00 Asia/Dubai | At-risk shipments, customs holds, DEM/DET, high-cost invoices |

### 13.4 QA Checklist

| Check | PASS criteria |
|---|---|
| Canonical authority | This file governs all extensions |
| Data separation | Master/transaction/document/event/exception/cost/evidence separated |
| Flow boundary | `confirmedFlowCode` only on `WarehouseHandlingProfile` |
| Flow placement | Warehouse Flow Code policy located after validation/compliance, not in early dictionaries |
| MOSB | `MOSB` typed as `OffshoreStaging`, not `Warehouse` |
| Port compatibility | `plannedRoutingPattern`, `declaredDestination`, `offshoreTransitRequired` retained |
| OCR compatibility | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` retained |
| Cost compatibility | `routeBasedCostDriver`, `wh_handling_cnt`, CostGuard bands retained |
| Marine compatibility | `MarineRoutingPattern`, M115/M116/M117 retained |
| Ops compatibility | `hasRoutingPattern` and milestone analytics retained |
| Communication compatibility | evidence-only connection retained |
| Numeric integrity | line math ±0.01; invoice total ±2.00% |
| Compliance | Incoterms/MOIAT/FANR/DCD/ADNOC controls modeled |
| Validation | SHACL/SPARQL rules included for core blockers |

### 13.5 Assumptions

| Assumption | Reason | Risk |
|---|---|---|
| Gold datasets exist or will be built before Ontology mapping | Foundry object types should not map directly to raw data | Raw schema drift |
| Project-specific MOIAT/FANR/DCD/ADNOC SOPs are externally governed | Current regulatory process may change | RAG/human review required |
| Existing extension docs may still contain legacy prose | Master spine governs; extensions should be patched later | Mixed vocabulary if extensions are not migrated |
| `HVDC_CODE` is a tag, not a sole identity key | Required for multi-key traceability | Duplicate/ambiguous tags |

---

## CmdRec {#cmdrec}

```text
/switch_mode PRIME + /logi-master report --deep --KRsummary
```

```text
/logi-master cert-chk --deep
```

```text
/logi-master invoice-audit --AEDonly
```
