# HVDC Logistics Ontology — Combined Corpus

- Bundle: `HVDC_Email_Drafting_Auto_SCT_v2.3_2026-05-12`
- Date: `2026-05-12`
- Status: PASS
- Patch focus: `EmailDraftMode`, `AUTO_SCT_ONTOLOGY_REQUIRED`, mandatory `sct_ontology`, hard-marked `EmailActionCard`



---

# FILE: CONSOLIDATED-00-master-ontology.md

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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
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
7. Email reply drafting defaults to `EmailDraftMode` with mandatory `sct_ontology` grounding. A draft request must automatically invoke or display `sct_ontology`, then output a hard-marked `EmailActionCard` and the draft while keeping ontology verdict labels out of the outbound email body.

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
6. Email drafts are not operational truth, not evidence registration, and not transaction mutation.
7. Email draft outputs must include mandatory `sct_ontology` review plus `EmailActionCard` with `ontology_use = AUTO_SCT_ONTOLOGY_REQUIRED`.

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
| `V-COMM-DRAFT-001` | email draft output | draft-mode reply must auto-invoke or surface `sct_ontology`; `EmailActionCard` required | BLOCK |

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
| `EmailDraftGuard` | User requests reply/draft | Invoke/surface `sct_ontology`, then emit `EmailActionCard` + draft; no KG action unless explicitly requested |

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


---

# FILE: CONSOLIDATED-01-core-framework-infra.md

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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
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


---

# FILE: CONSOLIDATED-02-warehouse-flow.md

---
title: "HVDC Warehouse Operations & WarehouseHandlingProfile Ontology — Consolidated"
type: "ontology-design"
domain: "warehouse-operations"
sub-domains:
  - warehouse-management
  - warehouse-handling-profile
  - inventory-tracking
  - storage-classification
  - stock-control
  - preservation-control
  - dangerous-goods-control
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "warehouse operations and WarehouseHandlingProfile algorithm extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - ISO-9001
  - ISO-14001
  - IMDG-Code
  - IATA-DGR
source_files:
  - 1_CORE-03-hvdc-warehouse-ops.md
  - 1_CORE-08-flow-code.md
  - FLOW_CODE_V35_ALGORITHM.md
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
---

# hvdc-warehouse-flow · CONSOLIDATED-02

## 1. ExecSummary

`CONSOLIDATED-02`는 HVDC Logistics KG의 **warehouse operations + WarehouseHandlingProfile(WHP) extension**이다. 이 문서는 창고 입고, 검수, put-away, 보관, preservation, picking, staging, dispatch, 재고 스냅샷, 위험물/특수화물 보관 제약을 정의한다.

비즈니스 임팩트는 **재고 위치 정확도 향상**, **창고 용량/보관조건 위반 조기 차단**, **OOG/DG/항온항습 자재 손상 리스크 감소**, **M110~M121 창고 구간의 감사 가능한 operational twin 생성**이다.

기술 해법은 `WarehouseHandlingProfile`을 M110 WH Received에서 생성하고, M111 Put-away 이후에 `confirmedFlowCode`를 warehouse-only storage/handling class로 확정하는 것이다. 전체 route visibility는 `RoutingPattern`, `JourneyStage`, `JourneyLeg`, `MilestoneEvent`가 담당한다.

KPI 목표는 `WHP Coverage ≥ 98.00%`, `Stock Accuracy ≥ 99.00%`, `Capacity Band = 75.00–85.00%`, `NumericIntegrity = 100.00%`, `Validation p95 < 5.00s`이다.

**ENG-KR one-liner:** Route stays in `RoutingPattern`; warehouse handling stays in `WarehouseHandlingProfile.confirmedFlowCode`.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-02` owns **warehouse operations** and **`WarehouseHandlingProfile` algorithm** only.
3. `confirmedFlowCode` is a warehouse-only storage/handling classification and may exist only on `WarehouseHandlingProfile`.
4. Program-wide shipment visibility uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
5. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; it is not modeled as a top-level `Warehouse` in this document.
6. Port, customs, OCR, cost, marine, operations, and communication domains may provide evidence to warehouse decisions, but they do not own or assign `confirmedFlowCode`.
7. Legacy route-code language is migration debt. This document uses it only in explicit deprecation context.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-02 | Delegated / excluded |
|---|---|---|
| Warehouse receiving | M110 WH Received, appointment, unloading, visual check | Port/customs release logic in `CONSOLIDATED-07` / `CONSOLIDATED-06` |
| Put-away and storage | M111 put-away, bin/zone assignment, storage class, preservation | Site receiving after dispatch in `CONSOLIDATED-06` |
| WH dispatch | M120 Picked/Staged, M121 WH Dispatched | Marine LCT/barge execution in `CONSOLIDATED-04` |
| Inventory | `StockSnapshot`, `InventoryBalance`, stock status, cycle count | Cost audit in `CONSOLIDATED-05` |
| WHP algorithm | `confirmedFlowCode`, `flowConfirmationStatus`, `wh_handling_cnt` | Route classification in `CONSOLIDATED-00` |
| DG/OOG storage gate | DG segregation, OOG/abnormal handling, HSE gate | Engineering final lift/stability approval in `CONSOLIDATED-04` |
| Evidence ingestion | OCR/WMS/ERP/Port evidence references | Document extraction logic in `CONSOLIDATED-03` |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with warehouse | Not allowed in CONSOLIDATED-02 |
|---|---|---|
| Core master | Read `ShipmentUnit`, `RoutingPattern`, `JourneyStage`, `MilestoneEvent`, `JourneyLeg` | Redefine master route dictionary |
| Infrastructure | Read `Warehouse`, `WarehouseZone`, `LocationNode`, `OffshoreStagingNode` | Classify MOSB as a Warehouse |
| Document/OCR | Read `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, extracted storage requirements | Assign `confirmedFlowCode` from OCR |
| Port | Read `plannedRoutingPattern`, `declaredDestination`, release evidence | Assign warehouse handling class at port |
| Marine/Bulk | Read M115/M116/M117 and marine handling constraints | Use warehouse code as marine route class |
| Cost | Export `wh_handling_cnt`, dwell days, storage class evidence | Make cost domain owner of WHP |
| Operations | Export stock, warehouse events, capacity, KPI | Replace `RoutingPattern` with warehouse code |
| Communication | Attach `CommunicationEvent`, `ApprovalAction`, `AuditRecord` as evidence | Redefine logistics execution objects |

### 2.4 Legacy Migration Rules

| Legacy wording | Canonical replacement | Patch action |
|---|---|---|
| Flow Code as Port→WH→MOSB→Site route | `ShipmentRoutingPattern` | Replace in route analytics and dashboards |
| Pre-arrival as Flow Code | `JourneyStage = PRE_ARRIVAL` or `ShipmentStatus = PLANNED/READY` | Remove from WHP confirmed class |
| Port assigns Flow Code | `PortCall.plannedRoutingPattern` | Treat as routing evidence only |
| Document extracts Flow Code | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` | Keep confidence and provenance |
| Cost by Flow Code | `costByRoutingPattern` + `wh_handling_cnt` | Keep WH evidence read-only |
| MOSB as Warehouse | `OffshoreStagingNode` / `MarineInterfaceNode` | Optional storage capability only |

---

## 3. Schema — RDF/OWL + SHACL 요약

### 3.1 Warehouse Ontology Layer

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Node | `Warehouse`, `WarehouseZone`, `StorageBin`, `YardSlot` | Physical WH location and storage capacity |
| Transaction | `WarehouseTask`, `PutAwayTask`, `PickTask`, `DispatchTask` | Work execution and accountability |
| Event | `WarehouseEvent`, `WHReceivedEvent`, `PutAwayEvent`, `PickEvent`, `DispatchEvent`, `CycleCountEvent` | Time-stamped state changes |
| Inventory | `StockSnapshot`, `InventoryBalance`, `StockStatus` | Inventory state and reconciliation |
| Handling | `WarehouseHandlingProfile`, `StorageRequirementClass`, `PreservationRequirement` | Storage/handling classification |
| Control | `DangerousCargoControl`, `OOGHandlingControl`, `CapacityProfile`, `QuarantineHold` | Risk and capacity controls |
| Evidence | `AuditRecord`, `ApprovalAction`, `VerificationResult`, `CommunicationEvent` | Provenance and human-gate proof |
| KPI | `WarehouseKPI`, `CapacityUtilizationMetric`, `StockAccuracyMetric` | Operational monitoring |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `Warehouse` | `warehouseId`, `warehouseName`, `warehouseType`, `operator`, `locationNodeId` | `hasZone`, `hasCapacityProfile`, `handlesStorageClass` | Indoor/outdoor/DG/special warehouse only |
| `WarehouseZone` | `zoneId`, `zoneType`, `temperatureControlled`, `humidityControlled`, `dgAllowed` | `partOfWarehouse`, `hasStorageBin` | DG and OOG zones must be explicit |
| `StorageBin` | `binId`, `binStatus`, `maxWeightKg`, `maxVolumeCbm`, `storageClassAllowed` | `partOfZone` | Optional for yard-level operations |
| `WarehouseTask` | `taskId`, `taskType`, `taskStatus`, `assignedOperator`, `plannedAt`, `completedAt` | `forShipmentUnit`, `usesEquipment`, `generatesEvent` | Operational transaction object |
| `WarehouseEvent` | `eventId`, `eventType`, `eventTime`, `qtyPkg`, `weightKg`, `volumeCbm` | `forShipmentUnit`, `atWarehouse`, `evidencedByDocument` | M110/M111/M120/M121 anchor |
| `StockSnapshot` | `snapshotId`, `snapshotTime`, `qtyPkg`, `weightKg`, `volumeCbm`, `stockStatus` | `forShipmentUnit`, `capturedAtWarehouse` | Snapshot, not event |
| `InventoryBalance` | `balanceId`, `asOfDate`, `qtyAvailable`, `qtyQuarantine`, `qtyDispatched` | `summarizesStockSnapshot` | Warehouse/month aggregate |
| `WarehouseHandlingProfile` | `profileId`, `flowConfirmationStatus`, `wh_handling_cnt`, `createdAt` | `forShipmentUnit`, `createdByM110`, `confirmedByM111` | Only owner of `confirmedFlowCode` |
| `StorageRequirementClass` | `storageRequirementCode`, `temperatureRange`, `humidityMaxPct`, `indoorRequired` | `requiredByMaterial`, `satisfiedByZone` | Material requirement, not WHP result |
| `PreservationRequirement` | `preservationCode`, `inspectionIntervalDays`, `nextDueDate` | `appliesToShipmentUnit` | Transformer/OOG/DG preservation |
| `DangerousCargoControl` | `dgClass`, `unNumber`, `segregationGroup`, `permitRequired` | `controlsShipmentUnit`, `requiresApproval` | DG gate |
| `CapacityProfile` | `capacityPkg`, `capacityWeightKg`, `capacityVolumeCbm`, `targetUtilizationPct` | `forWarehouse` | Capacity guard |
| `WarehouseKPI` | `metricName`, `metricValue`, `metricDate`, `targetValue` | `measuresWarehouse` | Dashboard output |

### 3.3 `WarehouseHandlingProfile` Class Contract

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

hvdc:WarehouseHandlingProfile a owl:Class ;
  rdfs:label "Warehouse Handling Profile" ;
  rdfs:comment "Warehouse-only storage/handling profile created by M110 WH Received and confirmed by M111 Put-away." .

hvdc:confirmedFlowCode a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:integer ;
  rdfs:comment "Warehouse-only storage/handling class; not a shipment route code." .

hvdc:flowConfirmationStatus a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:string ;
  rdfs:comment "tentative | confirmed | overridden | void" .

hvdc:wh_handling_cnt a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:integer ;
  rdfs:comment "Actual count of WH_RECEIVED events for the ShipmentUnit. Does not define the storage class." .

hvdc:warehouseDwellDays a owl:DatatypeProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range xsd:decimal .

hvdc:forShipmentUnit a owl:ObjectProperty ;
  rdfs:domain hvdc:WarehouseHandlingProfile ;
  rdfs:range hvdc:ShipmentUnit .
```

### 3.4 Handling Class Dictionary

`confirmedFlowCode` is retained as an integer because downstream sheets and historical WH dashboards already use numeric class codes. The meaning is now restricted to **warehouse storage/handling class**.

| Code | Canonical class name | Korean name | Storage / handling meaning | Typical evidence | Human-gate |
|---:|---|---|---|---|---|
| 0.00 | `STANDARD_INDOOR` | 표준 실내 | Standard dry indoor storage | WH zone = indoor, no special condition | No |
| 1.00 | `STANDARD_OUTDOOR` | 표준 야적 | Standard outdoor yard / covered yard | WH zone = outdoor, weather-tolerant cargo | No |
| 2.00 | `SPECIAL_INDOOR` | 특수 실내 | Temperature/humidity/precision indoor handling | humidity limit, shock-sensitive, preservation | Yes if high-value |
| 3.00 | `SPECIAL_OUTDOOR` | 특수 야적 | Outdoor with cover, dunnage, corrosion protection, oversized yard control | anti-corrosion, covered yard, heavy pallet | Yes if abnormal |
| 4.00 | `HAZMAT_DG` | 위험물 | DG / hazardous cargo segregated storage | UN No., DG class, MSDS, permit | Mandatory |
| 5.00 | `OOG_ABNORMAL` | 초대형·이상화물 | OOG/heavy/abnormal cargo requiring engineered handling | lift plan, rigging, abnormal dimensions | Mandatory |

**Important:** `wh_handling_cnt` tracks how many warehouse receipt events occurred. It is not a route code and it does not change the meaning of `confirmedFlowCode`.

### 3.5 Object Properties

| Property | Domain → Range | Purpose |
|---|---|---|
| `hasWarehouseHandlingProfile` | `ShipmentUnit → WarehouseHandlingProfile` | WHP ownership link |
| `createdByM110` | `WarehouseHandlingProfile → MilestoneEvent` | Creation evidence |
| `confirmedByM111` | `WarehouseHandlingProfile → WarehouseEvent` | Put-away confirmation evidence |
| `handledAtWarehouse` | `WarehouseEvent → Warehouse` | Event location |
| `storedInZone` | `StockSnapshot → WarehouseZone` | Current storage position |
| `storedInBin` | `StockSnapshot → StorageBin` | Fine-grain bin position |
| `requiresStorageClass` | `ShipmentUnit → StorageRequirementClass` | Material requirement |
| `requiresPreservation` | `ShipmentUnit → PreservationRequirement` | Preservation / maintenance requirement |
| `hasDangerousCargoControl` | `ShipmentUnit → DangerousCargoControl` | DG control and segregation |
| `usesWarehouseEquipment` | `WarehouseTask → EquipmentResource` | Forklift/crane/rigging assignment |
| `evidencedByDocument` | `WarehouseEvent → Document` | DO, PL, MRR, photo, checklist evidence |
| `hasWarehouseApproval` | `WarehouseTask → ApprovalAction` | Human approval proof |

### 3.6 Datatype Properties

| Property | Domain | Type | Constraint |
|---|---|---|---|
| `warehouseId` | `Warehouse` | string | required, unique |
| `zoneType` | `WarehouseZone` | enum | `INDOOR`, `OUTDOOR`, `DG`, `OOG`, `QUARANTINE`, `STAGING` |
| `eventType` | `WarehouseEvent` | enum | `WH_RECEIVED`, `PUT_AWAY`, `PICKED`, `STAGED`, `DISPATCHED`, `CYCLE_COUNT`, `QUARANTINE_HOLD` |
| `qtyPkg` | `WarehouseEvent`, `StockSnapshot` | decimal | ≥ 0.00 |
| `weightKg` | `WarehouseEvent`, `StockSnapshot` | decimal | ≥ 0.00 |
| `volumeCbm` | `WarehouseEvent`, `StockSnapshot` | decimal | ≥ 0.00 |
| `flowConfirmationStatus` | `WarehouseHandlingProfile` | enum | `tentative`, `confirmed`, `overridden`, `void` |
| `confirmedFlowCode` | `WarehouseHandlingProfile` | integer | 0..5; required only when confirmed/overridden |
| `wh_handling_cnt` | `WarehouseHandlingProfile` | integer | ≥ 1 if WHP exists |
| `warehouseDwellDays` | `WarehouseHandlingProfile` | decimal | computed from M110 to M121 / current date |
| `capacityUtilizationPct` | `CapacityProfile` | decimal | 0.00–100.00 |

---

## 4. WarehouseHandlingProfile Algorithm

### 4.1 Lifecycle

| Step | Milestone / event | WHP state | Required action |
|---:|---|---|---|
| 1.00 | M100 Gate-out or WH appointment | no WHP or expected placeholder | Check whether WH receipt is planned |
| 2.00 | M110 WH Received | `flowConfirmationStatus = tentative` | Create WHP and link WH_RECEIVED event |
| 3.00 | Physical inspection | tentative | Capture actual zone, DG/OOG flags, damage/shortage flags |
| 4.00 | M111 Put-away | confirmed | Assign `confirmedFlowCode` and zone/bin |
| 5.00 | Override case | overridden | Human-gate with reason and approval |
| 6.00 | M120 Picked/Staged | confirmed/overridden | Update stock status to PICKED/STAGED |
| 7.00 | M121 WH Dispatched | confirmed/overridden | Close dwell calculation and dispatch event |
| 8.00 | Direct/non-WH shipment | no WHP | Do not create confirmedFlowCode |

### 4.2 Input Evidence

| Evidence source | Used for | Ownership |
|---|---|---|
| WMS receipt row | M110 creation, qty/weight/CBM, warehouse location | Warehouse |
| Put-away task | M111 confirmation and zone/bin assignment | Warehouse |
| ERP/material master | storage requirement, high-value flag, material category | Master data |
| OCR/LDG | extracted storage notes, destination evidence, route evidence | Document evidence only |
| Port/DO | release and gate-out proof | Port/customs evidence |
| Marine/OOG plan | abnormal/OOG flag, rigging constraints | Marine/OOG evidence |
| DG documents | UN No., MSDS, DG class, permit requirement | Compliance evidence |
| Photos/checklists | condition, packing damage, seal status | Evidence layer |

### 4.3 Deterministic Classification Logic

The algorithm assigns a warehouse class after actual put-away. Route semantics are not used to assign the class.

```python
from dataclasses import dataclass
from typing import Literal

FlowStatus = Literal["tentative", "confirmed", "overridden", "void"]

@dataclass
class WHPInput:
    m110_exists: bool
    m111_putaway_exists: bool
    actual_zone_type: str            # INDOOR | OUTDOOR | DG | OOG | QUARANTINE | STAGING
    material_requires_indoor: bool
    temperature_control_required: bool
    humidity_control_required: bool
    outdoor_special_protection: bool
    dg_class: str | None
    un_number: str | None
    is_oog: bool
    is_heavy_lift: bool
    abnormal_dimension_flag: bool
    wh_received_event_count: int
    override_code: int | None = None
    override_reason: str | None = None

def classify_confirmed_flow_code(x: WHPInput) -> dict:
    if not x.m110_exists:
        return {
            "create_whp": False,
            "flowConfirmationStatus": "void",
            "confirmedFlowCode": None,
            "reason": "No WH Received event; direct or non-warehouse shipment."
        }

    status: FlowStatus = "tentative"
    if not x.m111_putaway_exists:
        return {
            "create_whp": True,
            "flowConfirmationStatus": status,
            "confirmedFlowCode": None,
            "wh_handling_cnt": x.wh_received_event_count,
            "reason": "WHP created at M110; class awaits M111 put-away confirmation."
        }

    if x.override_code is not None:
        assert x.override_reason, "Override requires reason."
        return {
            "create_whp": True,
            "flowConfirmationStatus": "overridden",
            "confirmedFlowCode": x.override_code,
            "wh_handling_cnt": x.wh_received_event_count,
            "reason": x.override_reason
        }

    if x.dg_class or x.un_number or x.actual_zone_type == "DG":
        code = 4
    elif x.is_oog or x.is_heavy_lift or x.abnormal_dimension_flag or x.actual_zone_type == "OOG":
        code = 5
    elif x.temperature_control_required or x.humidity_control_required or x.material_requires_indoor:
        code = 2
    elif x.outdoor_special_protection or x.actual_zone_type == "OUTDOOR_SPECIAL":
        code = 3
    elif x.actual_zone_type == "OUTDOOR":
        code = 1
    else:
        code = 0

    return {
        "create_whp": True,
        "flowConfirmationStatus": "confirmed",
        "confirmedFlowCode": code,
        "wh_handling_cnt": x.wh_received_event_count,
        "reason": "Class assigned from actual warehouse storage/handling condition."
    }
```

### 4.4 Classification Precedence

| Rank | Condition | Code | Reason |
|---:|---|---:|---|
| 1.00 | DG / UN No. / MSDS / DG zone | 4.00 | Regulatory segregation dominates storage decision |
| 2.00 | OOG / heavy lift / abnormal dimensions / engineered handling | 5.00 | Requires abnormal handling and engineering control |
| 3.00 | Temperature/humidity/precision indoor | 2.00 | Special indoor preservation |
| 4.00 | Outdoor with cover, dunnage, corrosion protection | 3.00 | Special outdoor preservation |
| 5.00 | Standard outdoor yard | 1.00 | Normal outdoor storage |
| 6.00 | Standard dry indoor | 0.00 | Default standard indoor |

Composite cases must retain additional boolean flags such as `isHazmat`, `isOOG`, `isHighValue`, `requiresPreservation`, and `requiresHumanGate`. If DG and OOG both apply, `confirmedFlowCode = 4` with `abnormalHandlingFlag = true`, unless HSE/WH Manager approves an override.

### 4.5 `wh_handling_cnt` Rule

| Rule | Meaning |
|---|---|
| `wh_handling_cnt = COUNT(WH_RECEIVED events)` | Actual warehouse receipt count for the ShipmentUnit |
| `wh_handling_cnt ≥ 1` | Required if a WHP exists |
| `wh_handling_cnt = 0` | Do not create confirmed WHP; use shipment route and milestone data instead |
| `wh_handling_cnt > 1` | Multi-warehouse handling; does not change `confirmedFlowCode` by itself |
| `wh_handling_cnt` and `RoutingPattern` | Can be jointly analyzed by cost/ops, but remain separate semantics |

### 4.6 State Machine

```text
NO_WHP
  ├─ M110 WH_RECEIVED → WHP_TENTATIVE
  │    ├─ M111 PUT_AWAY + auto class → WHP_CONFIRMED
  │    ├─ M111 PUT_AWAY + manual override → WHP_OVERRIDDEN
  │    └─ receipt cancelled / wrong link → WHP_VOID
  └─ direct shipment / no WH receipt → remain NO_WHP

WHP_CONFIRMED / WHP_OVERRIDDEN
  ├─ M120 PICKED/STAGED → WH_STAGED
  ├─ M121 DISPATCHED → WH_DISPATCHED
  └─ discrepancy found → QUARANTINE_HOLD or OSD/NCR workflow
```

---

## 5. Warehouse Operations Model

### 5.1 Milestone Alignment

| Milestone | Warehouse meaning | Object created / updated |
|---|---|---|
| M100 Gate-out | Inland haulage starts; WH appointment may be expected | `JourneyLeg`, `WarehouseTask` optional |
| M110 WH Received | Physical receipt into warehouse | `WarehouseEvent`, `WarehouseHandlingProfile`, `StockSnapshot` |
| M111 Put-away | Zone/bin confirmed | `PutAwayTask`, WHP `confirmedFlowCode`, `StockSnapshot` |
| M112 Quarantine Hold | Discrepancy, DG hold, damage, missing docs | `QuarantineHold`, `Exception` |
| M120 Picked/Staged | Prepared for dispatch | `PickTask`, `WarehouseEvent` |
| M121 WH Dispatched | Leaves warehouse | `DispatchTask`, stock decrement, dwell close |
| M130 Site Arrived | Site receipt outside WH scope | Read-only downstream milestone |

### 5.2 Warehouse Event Types

| Event type | Required fields | Stock impact |
|---|---|---|
| `WH_RECEIVED` | `shipmentUnit`, `warehouse`, `eventTime`, `qtyPkg`, `weightKg`, `volumeCbm` | Increase expected/received stock |
| `PUT_AWAY` | `zone`, `bin/slot`, `eventTime`, `operator` | Stock status = AVAILABLE / QUARANTINE |
| `QUARANTINE_HOLD` | `reason`, `severity`, `approvalRequired` | Stock status = QUARANTINE |
| `PRESERVATION_CHECK` | `checkType`, `result`, `nextDueDate` | No quantity change |
| `CYCLE_COUNT` | `countedQty`, `systemQty`, `variance` | Reconciliation |
| `PICKED` | `pickTask`, `qtyPkg`, `eventTime` | Stock status = PICKED |
| `STAGED` | `stagingArea`, `dispatchPlanRef` | Stock status = STAGED |
| `DISPATCHED` | `destinationNode`, `carrier`, `truckRef`, `eventTime` | Decrease warehouse stock |

### 5.3 Stock Status Vocabulary

| Status | Meaning | Allowed transition |
|---|---|---|
| `EXPECTED` | WH receipt planned but not physically received | → RECEIVED |
| `RECEIVED` | Physically received, awaiting put-away | → AVAILABLE / QUARANTINE |
| `AVAILABLE` | Put-away complete and available for issue | → PICKED / QUARANTINE |
| `QUARANTINE` | Blocked due to OSD, QC, DG, document gap | → AVAILABLE / CLAIM_OPENED |
| `PICKED` | Picked for outbound movement | → STAGED |
| `STAGED` | Staged at dispatch area | → DISPATCHED |
| `DISPATCHED` | Left warehouse | terminal state for WH stock |
| `ISSUED` | Issued to construction/site team | site/material issue layer |

### 5.4 Capacity Control

| Capacity band | Rule | Action |
|---|---|---|
| `< 75.00%` | Under-utilized | Consolidation review |
| `75.00–85.00%` | Target utilization | Normal operation |
| `85.01–95.00%` | High utilization | Intake scheduling review |
| `> 95.00%` | Critical | Overflow WH / dispatch acceleration / human-gate |

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?warehouse ?utilPct ?band
WHERE {
  ?cp a hvdc:CapacityProfile ;
      hvdc:forWarehouse ?warehouse ;
      hvdc:capacityUtilizationPct ?utilPct .
  BIND(
    IF(?utilPct > 95.00, "CRITICAL",
    IF(?utilPct > 85.00, "HIGH",
    IF(?utilPct >= 75.00, "TARGET", "LOW"))) AS ?band
  )
}
ORDER BY DESC(?utilPct)
```

### 5.5 Inventory Integrity Formulae

| Formula | Gate |
|---|---|
| `Opening + Receipts − Dispatches ± Adjustments = Closing` | `InventoryBalanceShape` |
| `Σ StockSnapshot.qtyPkg by warehouse = WMS balance ± 0.00` | `StockReconciliationShape` |
| `Event.qtyPkg ≥ 0.00`, `weightKg ≥ 0.00`, `volumeCbm ≥ 0.00` | `WarehouseEventNumericShape` |
| `WHP exists ⇒ at least one WH_RECEIVED event` | `WHPM110Shape` |
| `confirmed/overridden WHP ⇒ confirmedFlowCode present` | `WHPConfirmedClassShape` |

---

## 6. Integration — Foundry ↔ ERP/WMS/ATLP/OCR/Invoice

### 6.1 Foundry Object Types

| Foundry Object Type | Backing dataset | Key properties | Links |
|---|---|---|---|
| `Warehouse` | `location_node_master` / WMS master | `warehouseId`, `warehouseType`, `operator`, `capacity` | hasZone, hasCapacityProfile |
| `WarehouseZone` | WMS zone/bin master | `zoneId`, `zoneType`, `storageClassAllowed` | partOfWarehouse |
| `WarehouseTask` | WMS task table | `taskId`, `taskType`, `taskStatus`, `operator` | forShipmentUnit, generatesEvent |
| `WarehouseEvent` | WMS event log | `eventType`, `eventTime`, `qtyPkg`, `weightKg`, `volumeCbm` | forShipmentUnit, handledAtWarehouse |
| `StockSnapshot` | WMS stock snapshot | `snapshotTime`, `stockStatus`, `qtyPkg`, `weightKg`, `volumeCbm` | capturedAtWarehouse, forShipmentUnit |
| `WarehouseHandlingProfile` | WHP gold dataset | `confirmedFlowCode`, `flowConfirmationStatus`, `wh_handling_cnt`, `dwellDays` | forShipmentUnit, createdByM110 |
| `CapacityProfile` | WH capacity register | `capacityPkg`, `capacityWeightKg`, `capacityVolumeCbm`, `utilPct` | forWarehouse |
| `DangerousCargoControl` | DG register / MSDS | `unNumber`, `dgClass`, `segregationGroup` | controlsShipmentUnit |
| `PreservationRequirement` | material / vendor instruction | `preservationCode`, `inspectionIntervalDays`, `nextDueDate` | appliesToShipmentUnit |
| `WarehouseKPI` | KPI mart | `metricName`, `metricValue`, `metricDate` | measuresWarehouse |

### 6.2 Source-to-Ontology Mapping

| Source | Input fields | Ontology mapping | Validation gate |
|---|---|---|---|
| WMS Receipt | receipt no., package no., date, warehouse, qty, weight, CBM | `WH_RECEIVED`, M110, WHP tentative | required fields + non-negative values |
| WMS Put-away | zone/bin, actual put-away date, operator | M111, WHP confirmed class | storage class compatible with zone |
| WMS Dispatch | truck ref, destination, dispatch date, qty | M121, stock decrement | cannot dispatch unavailable/quarantine stock |
| ERP / PO | material category, vendor, PO, package | `StorageRequirementClass`, high-value flag | material master completeness |
| LDG/OCR | PL/CI/DO notes, dimensions, DG fields | evidence only | confidence threshold + cross-doc consistency |
| Port / Customs | DO released, gate pass, route evidence | precondition for WH receipt | M92/M100 ordering |
| Marine / OOG | OOG, rigging, lashing plan evidence | OOG flag / abnormal gate | human-gate if OOG_ABNORMAL |
| Cost | warehouse charge lines, storage days | read WHP and dwell evidence | no cost-owned WHP updates |
| Communication | approvals, exception emails, photos | `ApprovalAction`, `CommunicationEvent` evidence | provenance / masking |

### 6.3 Foundry Link Types

| Link Type | Cardinality | Purpose |
|---|---:|---|
| `ShipmentUnit_hasWHP` | 1:0..1 | Link operational shipment unit to WHP |
| `WHP_createdBy_M110` | 1:1 | Link WHP to WH Received milestone |
| `WHP_confirmedBy_PutAway` | 1:0..1 | Link WHP to put-away event |
| `ShipmentUnit_hasWarehouseEvent` | 1:N | Warehouse timeline |
| `WarehouseEvent_handledAt_Warehouse` | N:1 | Event location |
| `StockSnapshot_capturedAt_WarehouseZone` | N:1 | Current inventory location |
| `WarehouseTask_generates_Event` | 1:N | Task-to-event provenance |
| `ShipmentUnit_requires_Preservation` | 1:N | Preservation controls |
| `ShipmentUnit_has_DGControl` | 1:0..1 | Dangerous cargo controls |
| `Warehouse_has_CapacityProfile` | 1:1 | Capacity monitoring |
| `WarehouseEvent_evidencedBy_Document` | N:N | Photos/checklists/DO/PL evidence |

### 6.4 Foundry Action Types

| Action Type | Object | Parameters | Edits | Guard |
|---|---|---|---|---|
| `RecordWHReceipt` | `ShipmentUnit` | `warehouseId`, `eventTime`, `qtyPkg`, `weightKg`, `volumeCbm` | Create M110, WH_RECEIVED, WHP tentative | M92/M100 evidence, no duplicate open WHP |
| `ConfirmPutAway` | `WarehouseHandlingProfile` | `zoneId`, `binId`, `storageClassEvidence` | Create M111, set class/status | zone compatibility, DG/OOG gate |
| `OverrideWHPClass` | `WarehouseHandlingProfile` | `overrideCode`, `reason`, `approver` | Set status overridden | Human-gate mandatory |
| `CreateQuarantineHold` | `StockSnapshot` | `reason`, `severity`, `evidenceDoc` | Stock status QUARANTINE, Exception | cannot dispatch |
| `RecordPreservationCheck` | `ShipmentUnit` | `checkType`, `result`, `nextDueDate` | Preservation event | overdue flag if missed |
| `RecordWHPickStage` | `WarehouseTask` | `qtyPkg`, `stagingArea`, `dispatchPlanRef` | M120/PICKED/STAGED | available stock only |
| `RecordWHDispatch` | `WarehouseTask` | `carrier`, `truckRef`, `destinationNode`, `eventTime` | M121/DISPATCHED, stock decrement | no quarantine, qty available |
| `CloseCycleCount` | `Warehouse` | `countedQty`, `varianceReason` | Inventory adjustment | variance approval if > 2.00% |

---

## 7. Validation — SHACL / SPARQL / RAG / Human-gate

### 7.1 SHACL — WHP Boundary Shape

```turtle
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

hvdc:WHPShape a sh:NodeShape ;
  sh:targetClass hvdc:WarehouseHandlingProfile ;
  sh:property [
    sh:path hvdc:flowConfirmationStatus ;
    sh:datatype xsd:string ;
    sh:in ("tentative" "confirmed" "overridden" "void") ;
    sh:minCount 1 ;
    sh:message "WarehouseHandlingProfile requires flowConfirmationStatus." ;
  ] ;
  sh:property [
    sh:path hvdc:wh_handling_cnt ;
    sh:datatype xsd:integer ;
    sh:minInclusive 1 ;
    sh:minCount 1 ;
    sh:message "WHP requires wh_handling_cnt >= 1 because it is created only after WH receipt." ;
  ] ;
  sh:sparql [
    sh:message "confirmedFlowCode is required only when WHP is confirmed or overridden." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this
      WHERE {
        $this hvdc:flowConfirmationStatus ?status .
        FILTER(?status IN ("confirmed", "overridden"))
        FILTER NOT EXISTS { $this hvdc:confirmedFlowCode ?code . }
      }
    """ ;
  ] ;
  sh:sparql [
    sh:message "confirmedFlowCode must be integer 0..5 when present." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this
      WHERE {
        $this hvdc:confirmedFlowCode ?code .
        FILTER(?code < 0 || ?code > 5)
      }
    """ ;
  ] .
```

### 7.2 SHACL — Global Flow Code Boundary

```turtle
hvdc:GlobalConfirmedFlowCodeBoundaryShape a sh:NodeShape ;
  sh:targetSubjectsOf hvdc:confirmedFlowCode ;
  sh:sparql [
    sh:message "VIOLATION-1: confirmedFlowCode may exist only on WarehouseHandlingProfile." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this
      WHERE {
        $this hvdc:confirmedFlowCode ?code .
        FILTER NOT EXISTS { $this a hvdc:WarehouseHandlingProfile . }
      }
    """ ;
  ] .
```

### 7.3 SHACL — MOSB Not Warehouse

```turtle
hvdc:MOSBNotWarehouseShape a sh:NodeShape ;
  sh:targetClass hvdc:Warehouse ;
  sh:sparql [
    sh:message "MOSB must not be typed as Warehouse. Use OffshoreStagingNode / MarineInterfaceNode." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this
      WHERE {
        $this a hvdc:Warehouse ;
              hvdc:nodeCode ?code .
        FILTER(CONTAINS(UCASE(STR(?code)), "MOSB"))
      }
    """ ;
  ] .
```

### 7.4 SHACL — Warehouse Event Minimum Fields

```turtle
hvdc:WarehouseEventShape a sh:NodeShape ;
  sh:targetClass hvdc:WarehouseEvent ;
  sh:property [ sh:path hvdc:eventId ; sh:datatype xsd:string ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:eventType ; sh:in ("WH_RECEIVED" "PUT_AWAY" "QUARANTINE_HOLD" "PRESERVATION_CHECK" "CYCLE_COUNT" "PICKED" "STAGED" "DISPATCHED") ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:eventTime ; sh:datatype xsd:dateTime ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:qtyPkg ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:weightKg ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ] ;
  sh:property [ sh:path hvdc:volumeCbm ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ] .
```

### 7.5 SPARQL — WHP Missing After WH Receipt

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?shipmentUnit ?event ?eventTime
WHERE {
  ?event a hvdc:WarehouseEvent ;
         hvdc:eventType "WH_RECEIVED" ;
         hvdc:forShipmentUnit ?shipmentUnit ;
         hvdc:eventTime ?eventTime .
  FILTER NOT EXISTS { ?shipmentUnit hvdc:hasWarehouseHandlingProfile ?whp . }
}
ORDER BY ?eventTime
```

### 7.6 SPARQL — Confirmed WHP Without Put-away

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?whp ?shipmentUnit ?status
WHERE {
  ?whp a hvdc:WarehouseHandlingProfile ;
       hvdc:forShipmentUnit ?shipmentUnit ;
       hvdc:flowConfirmationStatus ?status .
  FILTER(?status IN ("confirmed", "overridden"))
  FILTER NOT EXISTS { ?whp hvdc:confirmedByM111 ?putAwayEvent . }
}
```

### 7.7 SPARQL — Quarantine Dispatch Blocker

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?shipmentUnit ?stock ?dispatchTask
WHERE {
  ?stock a hvdc:StockSnapshot ;
         hvdc:forShipmentUnit ?shipmentUnit ;
         hvdc:stockStatus "QUARANTINE" .
  ?dispatchTask a hvdc:WarehouseTask ;
                hvdc:forShipmentUnit ?shipmentUnit ;
                hvdc:taskType "DISPATCH" ;
                hvdc:taskStatus ?status .
  FILTER(?status IN ("PLANNED", "READY", "IN_PROGRESS", "COMPLETED"))
}
```

### 7.8 RAG Checks

| RAG gate | Trigger | Required evidence |
|---|---|---|
| DG storage | DG class, UN No., MSDS, chemical battery/gas/material flag | Current HSE/DCD/DG SOP, MSDS, segregation table |
| FANR-sensitive item | radiation/nuclear-related material flag | FANR permit / project compliance record |
| MOIAT regulated product | regulated equipment/product flag | CoC / approval evidence |
| OOG/abnormal | dimension/weight threshold or lift plan required | engineering method statement / rigging evidence |
| High-value cargo | value > 100,000.00 AED | WH Manager + Finance approval |
| Capacity critical | utilization > 95.00% | overflow approval / dispatch acceleration plan |

### 7.9 Human-gate Matrix

| Gate | Trigger | Required role | Blocked action |
|---|---|---|---|
| WHP override | `flowConfirmationStatus = overridden` | WH Manager | WHP finalization |
| DG storage | `confirmedFlowCode = 4` | HSE / DG Controller | Put-away / dispatch |
| OOG abnormal | `confirmedFlowCode = 5` | WH Manager + Rigging/Engineering | Put-away / movement |
| Quarantine release | `stockStatus = QUARANTINE` | QA/QC + WH Manager | Dispatch |
| Capacity critical | utilization > 95.00% | Logistics Manager | New receipt |
| High-value | value > 100,000.00 AED | WH Manager + Finance | Release / transfer |

---

## 8. Compliance — Incoterms / MOIAT / FANR / DCD / ADNOC

| Compliance area | Warehouse implication | Ontology object / evidence |
|---|---|---|
| Incoterms 2020 | Determines cost/risk responsibility for storage, demurrage, detention, last-mile handover | `PurchaseOrder.incoterm`, `Contract`, `CostResponsibility` |
| MOIAT | Regulated products may require certificate evidence before release/storage decision | `PermitDocument`, `RegulatoryRequirement`, `ComplianceCheck` |
| FANR | Radiation/nuclear-sensitive materials require permit evidence and controlled storage handling | `PermitDocument`, `DangerousCargoControl`, `ApprovalAction` |
| DCD / DG / IMDG / IATA DGR | DG segregation, MSDS, compatible storage, HSE procedure | `DangerousCargoControl`, `WarehouseZone.dgAllowed` |
| ADNOC / CICPA / GatePass | Access and movement evidence for controlled nodes and dispatch | `GatePass`, `ApprovalAction`, `JourneyLeg` |
| ISO 9001 / ISO 14001 | Quality/environmental controls for inventory, preservation, records | `AuditRecord`, `PreservationRequirement`, `WarehouseKPI` |

Compliance attributes are evidence-driven. `CONSOLIDATED-02` does not hard-code authority-specific validity or SLA values unless project SOP evidence is attached.

---

## 9. Options ≥3

| Option | Description | Pros | Cons | CostIndex | Risk | Time |
|---|---|---|---|---:|---:|---:|
| A. WHP-only MVP | Implement M110/M111 WHP creation, class assignment, basic stock snapshot | Fast deployment, removes semantic collision | Limited capacity/DG automation | 1.00/5.00 | 20.00% | 4.00 weeks |
| B. Warehouse Control Twin | MVP + WMS task/events + capacity + quarantine + preservation | Strong operational control, high auditability | Requires WMS data quality | 2.50/5.00 | 18.00% | 8.00 weeks |
| C. WH + Compliance Gate | Control Twin + DG/FANR/MOIAT/ADNOC gates + RAG evidence | Best for regulated/high-risk cargo | Requires current SOP integration | 3.50/5.00 | 22.00% | 10.00 weeks |
| D. Full RDF/Foundry Bridge | Full SHACL/OWL validation + Foundry Actions + external RDF export | Highest semantic consistency | Architecture complexity | 5.00/5.00 | 30.00% | 14.00 weeks |

Recommended sequence: **A → B → C**, then D only if external RDF reasoning or enterprise graph reuse is required.

---

## 10. Roadmap — Prepare → Pilot → Build → Operate → Scale

| Phase | Scope | KPI |
|---|---|---|
| Prepare | WH master, zone/bin, storage class dictionary, WMS event mapping | WarehouseMasterCoverage ≥ 95.00% |
| Pilot | M110/M111 WHP for one indoor WH + one outdoor yard | WHP Coverage ≥ 95.00%, class error ≤ 2.00% |
| Build | WMS events, stock snapshots, capacity, quarantine, preservation | Stock Accuracy ≥ 99.00%, NumericIntegrity = 100.00% |
| Operate | Foundry actions, SHACL gates, exception workflow, dashboards | Validation p95 < 5.00s, Capacity band 75.00–85.00% |
| Scale | Multi-WH rollout, DG/OOG RAG gate, cost/ops integration | WHP Coverage ≥ 98.00%, HumanGate leakage = 0.00건 |

---

## 11. Automation Notes — RPA / LLM / Sheets / TG Hooks

| Automation | Trigger | Action |
|---|---|---|
| `WHPInjector` | M110 WH Received | Create `WarehouseHandlingProfile` with tentative status |
| `PutAwayClassifier` | M111 Put-away | Assign `confirmedFlowCode` from actual zone/condition evidence |
| `WHPBoundaryGuard` | Any write to `confirmedFlowCode` | Block if subject is not `WarehouseHandlingProfile` |
| `MOSBClassGuard` | Node master update | Block MOSB typed as Warehouse |
| `DGStorageGuard` | DG class / UN No. / MSDS detected | Require DG zone + HSE approval |
| `OOGHandlingGuard` | OOG/heavy/abnormal dimension detected | Require lift/rigging method evidence |
| `CapacityGuard` | capacity utilization > 85.00% | WARN; > 95.00% CRITICAL and human-gate |
| `QuarantineDispatchBlocker` | Dispatch task for quarantined stock | Block dispatch until release approval |
| `CycleCountBot` | Monthly / variance event | Generate variance and approval list |
| `DailyWHDigest` | 08:00 Asia/Dubai | WHP gaps, overdue preservation, capacity risk, quarantine list |

---

## 12. QA Checklist & Assumptions

### 12.1 QA Checklist

| Check | PASS criteria |
|---|---|
| Flow Code boundary | `confirmedFlowCode` appears only on `WarehouseHandlingProfile` |
| Route separation | Route state uses `RoutingPattern`, not WHP class |
| M110 trigger | WHP created only after WH Received |
| M111 confirmation | Confirmed/overridden WHP has put-away evidence |
| MOSB classification | MOSB is not top-level Warehouse |
| WH event quality | `eventType`, `eventTime`, `qtyPkg`, `warehouse` required |
| Stock integrity | no negative qty/weight/CBM; inventory formula balances |
| Capacity control | 75.00–85.00% target band; >95.00% CRITICAL |
| DG control | DG cargo stored only in DG-compatible zones |
| OOG control | OOG/abnormal class requires human-gate |
| Cost boundary | Cost reads WHP evidence but does not assign it |
| OCR boundary | OCR provides evidence only, no direct WHP assignment |
| Evidence privacy | PII in people/contact evidence masked unless explicitly authorized |

### 12.2 Assumptions

- `ShipmentUnit` is the operational anchor; `WarehouseHandlingProfile` is attached to it.
- Direct shipments with no WH receipt do not receive a confirmed WHP.
- `confirmedFlowCode` is retained for backward compatibility but redefined as warehouse-only storage/handling class.
- `wh_handling_cnt` is derived from actual WH receipt events, not planned route hops.
- Authority-specific validity, permit lead-time, and submission templates require current project SOP / portal evidence before automation.
- MOSB may expose storage-like capability, but the class remains `OffshoreStagingNode` / `MarineInterfaceNode` outside this warehouse taxonomy.

---

## 13. Patch Ledger — 5x Corpus Compatibility Review

| Pass | Lens | Patch applied | Result |
|---:|---|---|---|
| 1.00 | Master spine alignment | Re-anchored document to `CONSOLIDATED-00` and removed route ownership from WHP | PASS |
| 2.00 | Flow Code boundary | Recast `confirmedFlowCode` as warehouse storage/handling class only | PASS |
| 3.00 | Extension compatibility | Aligned OCR/Port/Cost/Marine/Ops as evidence consumers/providers only | PASS |
| 4.00 | SHACL/SPARQL gates | Added WHP boundary, conditional class, MOSB-not-Warehouse, event/stock validation | PASS |
| 5.00 | Artifact QA | Added Foundry mapping, KPI, roadmap, automation, assumptions, command recommendations | PASS |

---

## 14. CmdRec

```text
/warehouse-master --fast stock-audit
```

```text
/wh-handling validate --strict
```

```text
/logi-master report --deep --KRsummary
```


---

# FILE: CONSOLIDATED-03-document-ocr.md

---
title: "HVDC Document Guardian & OCR Pipeline Ontology — Consolidated"
type: "ontology-design"
domain: "document-processing"
sub-domains:
  - document-guardian
  - trust-ontology
  - semantic-verification
  - ocr-extraction
  - data-refinement
  - validation-framework
  - route-evidence
  - compliance-evidence
  - cost-evidence
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "LDG/OCR trust layer and cross-document validation extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - GS1-EPCIS
  - DCSA-T&T
  - UN/CEFACT-BSP-RDM
  - WCO-DM
  - ICC-Incoterms-2020
source_files:
  - 1_CORE-06-hvdc-doc-guardian.md
  - 1_CORE-07-hvdc-ocr-pipeline.md
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
semantic_patch:
  - "Document/OCR is evidence-only and does not own operational route truth."
  - "Canonical document evidence fields: routeEvidence, destinationEvidence, mosbLegIndicator, routeEvidenceConfidence."
  - "WarehouseHandlingProfile.confirmedFlowCode remains warehouse-only and is never assigned by LDG/OCR."
  - "MOSB is OffshoreStagingNode / MarineInterfaceNode evidence, not Warehouse."
  - "Cross-document validation writes VerificationResult and AuditRecord, not transaction mutation."
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
---

# hvdc-document-ocr · CONSOLIDATED-03

## 1. ExecSummary

`CONSOLIDATED-03`은 HVDC Logistics KG의 **Logistics Document Guardian(LDG) + OCR trust layer extension**이다. CI/PL/BL/BOE/DO/Permit/MRR/MRI/POD/GRN/OSDR 등 문서를 `Document`, `DocumentEntity`, `CrossDocLink`, `VerificationResult`, `AuditRecord`로 정규화하여 Any-key traceability와 문서 정합성 검증을 제공한다.

비즈니스 임팩트는 **통관·릴리즈 지연 차단**, **금액·수량·중량 불일치 조기 검출**, **AGI/DAS MOSB 증빙 누락 차단**, **문서 증빙 기반 비용·운영 감사 추적성 확보**이다. 기술 해법은 OCR token/table extraction → semantic normalization → entity linking → SHACL/SPARQL gate → Foundry Object/Action write-back guard 순서로 구성한다.

KPI 목표는 `MeanConf ≥ 0.92`, `TableAcc ≥ 0.98`, `NumericIntegrity = 1.00`, `CrossDocumentConsistency = 1.00`, `RouteEvidenceAccuracy ≥ 0.95`, `Validation p95 < 5.00s`이다. 모든 금액·수량 계산은 원문 단위와 원통화를 보존하고, 변환은 승인된 downstream Cost/Customs layer에서만 수행한다.

**ENG-KR one-liner:** Documents provide evidence; `ShipmentUnit` owns route state, `WarehouseHandlingProfile` owns warehouse handling class, and LDG owns trust/verification artifacts only.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-03` owns document ingestion, OCR extraction, semantic normalization, cross-document validation, and evidence trust scoring only.
3. Program-wide shipment visibility uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
4. LDG/OCR may extract `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, storage notes, compliance hints, and invoice line evidence. It shall not assign `ShipmentUnit.hasRoutingPattern` directly.
5. `confirmedFlowCode` may exist only on `WarehouseHandlingProfile` and only after warehouse evidence per `CONSOLIDATED-02`; LDG/OCR never writes it.
6. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; LDG can detect MOSB references as evidence but cannot type MOSB as Warehouse.
7. Evidence cannot mutate operational transactions unless an approved Foundry Action writes the target transaction object with reviewer and audit trail.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-03 | Delegated / excluded |
|---|---|---|
| Document intake | File registry, hash, document type, source system, page/image metadata | Source-system master ownership |
| OCR extraction | OCR tokens, table cells, positions, confidence, language/script hints | OCR engine procurement and training policy |
| Semantic normalization | Unit, currency, quantity, date, party, port, site, HS, permit, route evidence normalization | Final customs classification and tariff decision |
| Entity linking | BL, container, invoice, PO, package, DO, BOE, permit, shipment key linking | Master identity policy in `CONSOLIDATED-00` |
| Cross-document validation | CI/PL/BL/BOE/DO/MRR/POD/GRN consistency checks | Transaction creation in Customs/WH/Site layers |
| Evidence trust layer | `VerificationResult`, `TrustLayer`, `AuditRecord`, `ProofArtifact` | Communication evidence ownership in `CONSOLIDATED-08` |
| Cost evidence | Invoice line extraction and numeric integrity checks | RateRef, CostGuard verdict ownership in `CONSOLIDATED-05` |
| Compliance evidence | MOIAT/FANR/DCD/ADNOC permit extraction and expiry evidence | Current authority interpretation and operational approval |
| Warehouse interface | Storage requirement evidence, DG/OOG notes, destination evidence | WHP assignment and stock operations in `CONSOLIDATED-02` |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface from LDG/OCR | Not allowed in CONSOLIDATED-03 |
|---|---|---|
| Core master | Attach `Document`, `DocumentEntity`, `VerificationResult` to `ShipmentUnit` | Redefine `ShipmentUnit`, `RoutingPattern`, or milestone dictionary |
| Warehouse | Provide storage notes, DG/OOG evidence, destination evidence | Assign `confirmedFlowCode` or create WH stock truth |
| Port | Validate BL/DO/BOE/port call evidence and declared destination | Own port routing decision or OFCO service truth |
| Customs | Extract HS/origin/value/permit/BOE evidence | Collapse `CustomsEntry` into `BOEDocument` |
| Marine/Bulk | Extract MOSB/LCT/lashing/stability evidence | Own `MarineRoutingPattern` or offshore operation approval |
| Cost | Extract invoice lines, quantities, rates, amount totals | Own `RateRef`, `CostGuardResult`, or FX override |
| Operations | Provide normalized document evidence for dashboards | Replace milestone or stock analytics |
| Communication | Link approval email/chat evidence through audit record | Redefine communication classes |

### 2.4 Evidence-only Rule

```text
Document/OCR output = Document + DocumentEntity + EvidenceAssertion + VerificationResult + AuditRecord
Operational truth    = ShipmentUnit / CustomsEntry / ReleaseOrder / WarehouseTask / SiteReceipt / Invoice / CostGuardResult
Write guard          = Evidence can propose; approved Action can mutate.
```

### 2.5 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Document-derived warehouse route code | `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` | Keep as evidence with confidence and provenance |
| OCR assigns operational route | `RouteEvidenceAssertion` attached to `Document` | Route owner remains `ShipmentUnit` / approved action |
| Document assigns warehouse handling class | storage/DG/OOG evidence only | WHP owner remains `CONSOLIDATED-02` |
| MOSB captured as warehouse | `mosbLegIndicator = true`, `OffshoreStagingNode` evidence | Do not type MOSB as Warehouse |
| Cost verdict from OCR alone | `InvoiceLineEvidence` + numeric check | Cost verdict owner remains `CONSOLIDATED-05` |

---

## 3. Schema (RDF/OWL + SHACL 요약)

### 3.1 Ontology Layer Map

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Document | `Document`, `CommercialInvoiceDocument`, `PackingListDocument`, `BillOfLadingDocument`, `BOEDocument`, `DeliveryOrderDocument`, `PermitDocument`, `MRR`, `MRI`, `POD`, `GRN`, `OSDR` | Documentary evidence object |
| OCR | `Page`, `ImageArtifact`, `OCRBlock`, `OCRToken`, `OCRCell`, `ExtractedTable` | Raw OCR/text/table extraction |
| Semantic normalization | `DocumentEntity`, `NormalizedValue`, `UnitNormalization`, `CurrencyNormalization`, `DateNormalization` | Canonical field representation |
| Evidence | `EvidenceAssertion`, `RouteEvidenceAssertion`, `ComplianceEvidenceAssertion`, `CostEvidenceAssertion` | Evidence-only assertions with provenance |
| Linking | `Identifier`, `CrossDocLink`, `EntityMatch`, `SameAsCluster` | Any-key resolution and cross-doc relationship |
| Validation | `VerificationResult`, `ValidationRun`, `ValidationRule`, `Discrepancy` | SHACL/SPARQL output |
| Trust | `TrustLayer`, `ConfidenceScore`, `QualityMetric`, `ProofArtifact`, `AuditRecord` | Reliability and audit trail |
| Human gate | `ReviewTask`, `ApprovalAction`, `OverrideDecision` | Manual review and controlled write-back |

### 3.2 Document Types and Required Evidence

| Document Type | Required fields | Primary cross-check | Blocking rule |
|---|---|---|---|
| `CommercialInvoiceDocument` | `invoiceNo`, `vendor`, `currency`, `totalAmount`, `lineCount`, `incoterm` | CI total vs line total; CI qty/value vs PL/BOE | `NumericIntegrity != 1.00` blocks finance/customs automation |
| `PackingListDocument` | `plNo`, `packageCount`, `grossWeightKg`, `volumeCbm`, `caseNo` | PL qty/weight/CBM vs CargoUnit and CI | package/weight mismatch blocks auto-link |
| `BillOfLadingDocument` | `blNo`, `carrier`, `vesselVoyage`, `portOfLoading`, `portOfDischarge`, `containerNo` | BL vs Shipment/Container/PortCall | BL/container unresolved blocks shipment certainty |
| `BOEDocument` | `boeNo`, `declarationDate`, `customsAuthority`, `hsCode`, `declaredValue` | Evidence for `CustomsEntry` | BOE cannot replace `CustomsEntry` transaction |
| `DeliveryOrderDocument` | `doNo`, `releaseDate`, `terminal`, `releaseParty` | Evidence for `ReleaseOrder` and M92 | DO missing before M100 blocks gate-out evidence |
| `PermitDocument` | `permitNo`, `authority`, `permitType`, `issueDate`, `expiryDate` | MOIAT/FANR/DCD/ADNOC controls | expired/missing permit blocks regulated move |
| `MRR` / `MRI` | `receiptNo`, `inspectionNo`, `siteCode`, `receivedQty`, `condition` | Evidence for `SiteReceipt` / inspection | mismatch triggers OSDR/NCR review |
| `POD` / `GRN` | `podNo`, `grnNo`, `acceptanceDate`, `acceptedQty` | Handover and closeout evidence | missing closure evidence blocks final status |
| `OSDR` | `osdrNo`, `defectType`, `severity`, `claimRef` | Exception/claim evidence | severity HIGH/CRITICAL requires human-gate |
| `PTW` / `FRA` / `MethodStatement` | `approvalNo`, `workScope`, `expiryDate`, `approverRole` | Heavy-lift/marine execution gate | expired approval blocks M117/M130 evidence |
| `LashingPlan` / `StabilityReport` | `planNo`, `revision`, `engineerApproval` | Marine/OOG technical gate | missing approval blocks offshore movement evidence |

### 3.3 Evidence Properties

| Property | Domain | Range | Ownership rule |
|---|---|---|---|
| `routeEvidence` | `Document` | string / SKOS concept | Evidence only; supports routing decision |
| `destinationEvidence` | `Document` | site code string | Evidence only; normalized to MIR/SHU/AGI/DAS when possible |
| `mosbLegIndicator` | `Document` | boolean | Evidence only; true when MOSB/offshore/LCT leg is explicit or inferable |
| `routeEvidenceConfidence` | `Document` | decimal | 0.00–1.00 |
| `storageRequirementEvidence` | `Document` | string / SKOS concept | Evidence only for WHP after M110 |
| `dgEvidence` | `Document` | `DGEvidenceAssertion` | Evidence only for DCD/DG gate |
| `oOGEvidence` | `Document` | `OOGEvidenceAssertion` | Evidence only for marine/OOG human-gate |
| `complianceEvidence` | `Document` | `ComplianceEvidenceAssertion` | Evidence only for permit checks |
| `costEvidence` | `Document` | `CostEvidenceAssertion` | Evidence only for CostGuard pipeline |
| `extractedEntity` | `Document` | `DocumentEntity` | OCR extraction output |
| `crossDocLink` | `DocumentEntity` | `CrossDocLink` | Semantic verification |
| `verificationResult` | `Document` | `VerificationResult` | LDG result |

### 3.4 Core Classes (TTL)

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix ldg:  <http://samsung.com/project-logistics/document#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix dqv:  <http://www.w3.org/ns/dqv#> .

hvdc:Document a owl:Class ;
  rdfs:label "Logistics Document" .

ldg:Page a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:OCRBlock a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:OCRToken a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:ExtractedTable a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:DocumentEntity a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:EvidenceAssertion a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:RouteEvidenceAssertion a owl:Class ; rdfs:subClassOf ldg:EvidenceAssertion .
ldg:ComplianceEvidenceAssertion a owl:Class ; rdfs:subClassOf ldg:EvidenceAssertion .
ldg:CostEvidenceAssertion a owl:Class ; rdfs:subClassOf ldg:EvidenceAssertion .
ldg:CrossDocLink a owl:Class ; rdfs:subClassOf prov:Entity .
ldg:VerificationResult a owl:Class ; rdfs:subClassOf dqv:QualityMeasurement .
ldg:AuditRecord a owl:Class ; rdfs:subClassOf prov:Activity .

hvdc:documentNo a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:docType a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:docHash a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:issueDate a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:date .
hvdc:sourceSystem a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:string .
hvdc:ocrConfidence a owl:DatatypeProperty ; rdfs:domain hvdc:Document ; rdfs:range xsd:decimal .

hvdc:routeEvidence a owl:DatatypeProperty ;
  rdfs:domain hvdc:Document ;
  rdfs:range xsd:string ;
  rdfs:comment "Evidence-only route phrase or normalized concept label extracted from document." .

hvdc:destinationEvidence a owl:DatatypeProperty ;
  rdfs:domain hvdc:Document ;
  rdfs:range xsd:string ;
  rdfs:comment "Evidence-only site/destination value, e.g., MIR, SHU, AGI, DAS." .

hvdc:mosbLegIndicator a owl:DatatypeProperty ;
  rdfs:domain hvdc:Document ;
  rdfs:range xsd:boolean ;
  rdfs:comment "Evidence-only indicator that document mentions or implies MOSB/offshore staging." .

hvdc:routeEvidenceConfidence a owl:DatatypeProperty ;
  rdfs:domain hvdc:Document ;
  rdfs:range xsd:decimal .

ldg:hasPage a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range ldg:Page .
ldg:hasOCRBlock a owl:ObjectProperty ; rdfs:domain ldg:Page ; rdfs:range ldg:OCRBlock .
ldg:hasToken a owl:ObjectProperty ; rdfs:domain ldg:OCRBlock ; rdfs:range ldg:OCRToken .
ldg:hasExtractedTable a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range ldg:ExtractedTable .
ldg:hasDocumentEntity a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range ldg:DocumentEntity .
ldg:hasEvidenceAssertion a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range ldg:EvidenceAssertion .
ldg:hasVerificationResult a owl:ObjectProperty ; rdfs:domain hvdc:Document ; rdfs:range ldg:VerificationResult .
ldg:wasExtractedFrom a owl:ObjectProperty ; rdfs:domain ldg:DocumentEntity ; rdfs:range ldg:OCRToken .
```

### 3.5 Core SHACL Rules

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix ldg:  <http://samsung.com/project-logistics/document#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

ldg:DocumentBaseShape a sh:NodeShape ;
  sh:targetClass hvdc:Document ;
  sh:property [ sh:path hvdc:documentNo ; sh:minCount 1 ; sh:message "Document must have documentNo." ] ;
  sh:property [ sh:path hvdc:docType ; sh:minCount 1 ; sh:message "Document must have docType." ] ;
  sh:property [ sh:path hvdc:docHash ; sh:minCount 1 ; sh:message "Document must have docHash." ] ;
  sh:property [ sh:path hvdc:ocrConfidence ; sh:minInclusive 0.00 ; sh:maxInclusive 1.00 ; sh:message "OCR confidence must be 0.00-1.00." ] .

ldg:RouteEvidenceShape a sh:NodeShape ;
  sh:targetClass hvdc:Document ;
  sh:property [ sh:path hvdc:routeEvidenceConfidence ; sh:minInclusive 0.00 ; sh:maxInclusive 1.00 ; sh:message "routeEvidenceConfidence must be 0.00-1.00." ] ;
  sh:sparql [
    sh:message "AGI/DAS document evidence must include MOSB/offshore evidence or be routed to human review." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:destinationEvidence ?dest .
        FILTER(UCASE(STR(?dest)) IN ("AGI", "DAS"))
        FILTER NOT EXISTS { $this hvdc:mosbLegIndicator true }
      }
    """ ;
  ] .

ldg:EvidenceOwnershipGuardShape a sh:NodeShape ;
  sh:targetClass hvdc:Document ;
  sh:sparql [
    sh:message "Document/OCR must not assign warehouse handling class; keep evidence-only." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this ?p ?v .
        FILTER(CONTAINS(LCASE(STR(?p)), "confirmedflowcode"))
      }
    """ ;
  ] .

ldg:OCRKPIGateShape a sh:NodeShape ;
  sh:targetClass ldg:VerificationResult ;
  sh:sparql [
    sh:severity sh:Violation ;
    sh:message "OCR KPI gate failed: MeanConf>=0.92, TableAcc>=0.98, NumericIntegrity=1.00, CrossDocumentConsistency=1.00 required." ;
    sh:select """
      PREFIX ldg: <http://samsung.com/project-logistics/document#>
      SELECT $this WHERE {
        $this ldg:meanConf ?meanConf ;
              ldg:tableAcc ?tableAcc ;
              ldg:numericIntegrity ?numInt ;
              ldg:crossDocumentConsistency ?crossDoc .
        FILTER(?meanConf < 0.92 || ?tableAcc < 0.98 || ?numInt != 1.00 || ?crossDoc != 1.00)
      }
    """ ;
  ] .
```

### 3.6 Key Rules

1. **Document identity:** every document must have `documentNo`, `docType`, `docHash`, `sourceSystem`, and at least 1.00 source provenance record.
2. **Evidence boundary:** `routeEvidence`, `destinationEvidence`, and `mosbLegIndicator` are evidence only; they cannot directly write `ShipmentUnit.hasRoutingPattern`.
3. **Warehouse boundary:** `confirmedFlowCode` is blocked on all `Document` subjects; WHP classification belongs only to `WarehouseHandlingProfile` after M110/M111.
4. **Numeric integrity:** `Σ(lineAmount) = invoiceTotal ± 2.00%` and `EA × Rate = Amount ± 0.01`; any breach blocks automated finance/customs action.
5. **AGI/DAS gate:** `destinationEvidence IN (AGI,DAS)` requires MOSB/offshore evidence or human-gate review before downstream route acceptance.

---

## 4. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 4.1 LDG Pipeline

```text
Document intake
  → file hash + source registry
  → OCR text/table extraction
  → semantic normalization
  → entity tagging and identifier resolution
  → cross-document verification
  → SHACL/SPARQL validation
  → TrustLayer / AuditRecord creation
  → Foundry Object update request
  → Human-gate / approved Action write-back when needed
```

### 4.2 Source-System Integration Points

| Source / system | Input to LDG | Foundry object target | Write rule |
|---|---|---|---|
| ERP / procurement | PO, package, vendor, material, CI, PL | `PurchaseOrder`, `Package`, `MaterialMaster`, `Document` | LDG writes document evidence; ERP remains master for PO/material |
| Carrier / forwarder | BL/AWB, container, vessel/voyage, ETA/ATA text | `BillOfLadingDocument`, `Container`, `JourneyLeg` evidence | LDG can propose link; carrier/ops event owns transport truth |
| Customs / ATLP / eDAS | BOE, HS, origin, value, permit refs | `BOEDocument`, `CustomsEntry` evidence | `CustomsEntry` is not collapsed into BOE |
| Port / OFCO | DO, release, terminal, rotation, service invoices | `DeliveryOrderDocument`, `PortCall`, `ReleaseOrder` evidence | Port domain owns service event and planned route evidence |
| WMS | WH receipt docs, put-away labels, storage notes | `WarehouseTask`, `WarehouseHandlingProfile` evidence | WMS/WHP owner assigns warehouse class after M110/M111 |
| Marine / MOSB | PTW, FRA, method statement, lashing/stability, LCT docs | `MarineEvent`, `OperationTask`, `PermitDocument` evidence | Marine domain owns offshore operation and approvals |
| Invoice / cost | invoice header/lines, charge description, currency, amount | `Invoice`, `InvoiceLine`, `CostEvidenceAssertion` | Cost domain owns `RateRef` and CostGuard verdict |
| Site / FMC | MRR, MRI, POD, GRN, OSDR | `SiteReceipt`, `InspectionEvent`, `Exception` evidence | Site domain owns receipt and exception transactions |

### 4.3 Foundry Object Mapping

| LDG object | Foundry object / link | Cardinality | Notes |
|---|---|---:|---|
| `Document` | `Document` object | 1.00 file → 1.00 document object | hash-stable identity |
| `DocumentEntity` | `Document` → `extractedEntity` | 1.00 document → many entities | field-level evidence |
| `EvidenceAssertion` | `Document` → `supports` → operational object | many-to-many | no truth mutation |
| `CrossDocLink` | `DocumentEntity` ↔ `DocumentEntity` | many-to-many | BL/CI/PL/BOE/DO consistency graph |
| `VerificationResult` | `Document` → `validatedBy` | 1.00 validation run → many results | SHACL/SPARQL output |
| `AuditRecord` | `ValidationRun` / `ApprovalAction` | many-to-one | proof trail |
| `ReviewTask` | exception queue | conditional | triggered by ZERO/WARN/HIGH/CRITICAL |

### 4.4 Event and Milestone Interface

| Milestone / stage | Required document evidence | LDG validation role |
|---|---|---|
| M40 Export Cleared | CI, PL, COO/FCO, export license where applicable | Export document completeness and identity link |
| M50 Terminal Received | BL/AWB, carrier receipt, container evidence | Port/container linkage evidence |
| M80 ATA | BL/AWB, arrival notice, port call | Arrival evidence confidence |
| M90/M91 BOE Submitted/Cleared | BOE, HS, origin, value, permit evidence | Customs document consistency |
| M92 DO Released | DO, release order evidence | DO before gate-out gate |
| M100 Gate-out | DO, gate pass, permit/access evidence | Gate-out evidence gate |
| M110 WH Received | receipt note, warehouse intake evidence | WHP evidence input only |
| M115 MOSB Staged | MOSB/LCT/offshore staging evidence | AGI/DAS MOSB proof gate |
| M117 Sail-away | lashing/stability/PTW/FRA/method statement | Marine approval evidence gate |
| M130 Site Arrived | MRR/MRI/site delivery evidence | Site receipt evidence link |
| M140 POD/GRN | POD, GRN, accepted qty | closeout evidence |
| M160 Closed | claim/cost closeout docs | final audit completeness |

---

## 5. Validation (SPARQL/RAG/Human-gate)

### 5.1 Validation Control Matrix

| Rule ID | Target | Logic | Severity |
|---|---|---|---|
| `D-IDENT-001` | `Document` | documentNo/docType/docHash/sourceSystem required | BLOCK |
| `D-OCR-001` | `VerificationResult` | MeanConf ≥ 0.92 | WARN/BLOCK by doc criticality |
| `D-TABLE-001` | `ExtractedTable` | TableAcc ≥ 0.98 for CI/PL/BOE/Invoice tables | BLOCK |
| `D-NUM-001` | CI/Invoice | EA × Rate = Amount ± 0.01 | BLOCK |
| `D-NUM-002` | CI/Invoice | Σ lineAmount = totalAmount ± 2.00% | BLOCK |
| `D-QTY-001` | CI/PL/CargoUnit | package/qty/weight/CBM consistency | WARN/BLOCK |
| `D-ROUTE-001` | `Document` | AGI/DAS destination requires MOSB/offshore evidence or review | BLOCK |
| `D-WHP-001` | `Document` | document must not write warehouse handling class | BLOCK |
| `D-CUSTOMS-001` | BOE | BOE document linked to CustomsEntry evidence only | BLOCK |
| `D-RELEASE-001` | DO | DO evidence required before M100 gate-out | BLOCK |
| `D-PERMIT-001` | Permit | authority/type/issueDate/expiryDate required | BLOCK |
| `D-PII-001` | Contact/person fields | tel/email masked unless approved | BLOCK |
| `D-HASH-001` | Document | file hash must match registry value | BLOCK |
| `D-HG-001` | Human-gate | high-value, regulated, OCR-low-confidence, or exception docs require review | BLOCK |

### 5.2 SPARQL — Cross-document Quantity / Weight Check

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX ldg:  <http://samsung.com/project-logistics/document#>

SELECT ?shipment ?ci ?pl ?ciQty ?plQty ?ciWeight ?plWeight ?verdict
WHERE {
  ?shipment hvdc:hasDocument ?ci, ?pl .
  ?ci hvdc:docType "CommercialInvoiceDocument" ; ldg:packageQty ?ciQty ; ldg:grossWeightKg ?ciWeight .
  ?pl hvdc:docType "PackingListDocument" ; ldg:packageQty ?plQty ; ldg:grossWeightKg ?plWeight .
  BIND(IF(?ciQty = ?plQty && ABS(?ciWeight - ?plWeight) <= 0.01, "PASS", "FAIL") AS ?verdict)
}
ORDER BY ?verdict ?shipment
```

### 5.3 SPARQL — AGI/DAS MOSB Evidence Gap

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?document ?docNo ?dest ?routeEvidence ?confidence
WHERE {
  ?document a hvdc:Document ;
            hvdc:documentNo ?docNo ;
            hvdc:destinationEvidence ?dest .
  OPTIONAL { ?document hvdc:routeEvidence ?routeEvidence . }
  OPTIONAL { ?document hvdc:routeEvidenceConfidence ?confidence . }
  FILTER(UCASE(STR(?dest)) IN ("AGI", "DAS"))
  FILTER NOT EXISTS { ?document hvdc:mosbLegIndicator true }
}
```

### 5.4 SPARQL — Evidence Boundary Guard

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>

SELECT ?document ?property ?value
WHERE {
  ?document a hvdc:Document ; ?property ?value .
  FILTER(CONTAINS(LCASE(STR(?property)), "confirmedflowcode"))
}
```

### 5.5 SPARQL — Any-key Document Resolution

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX ldg:  <http://samsung.com/project-logistics/document#>

SELECT ?inputKey ?shipmentUnit ?document ?docType ?docNo ?confidence
WHERE {
  VALUES ?inputKey { "BL_NO" "CONTAINER_NO" "INVOICE_NO" "DO_NO" "BOE_NO" "PO_NO" "HVDC_CODE" }
  ?identifier hvdc:identifierScheme ?inputKey ;
              hvdc:identifierValue ?value .
  ?shipmentUnit hvdc:hasIdentifier ?identifier ;
                hvdc:hasDocument ?document .
  ?document hvdc:docType ?docType ;
            hvdc:documentNo ?docNo ;
            hvdc:ocrConfidence ?confidence .
}
ORDER BY ?shipmentUnit ?docType
```

### 5.6 RAG Check Policy

| RAG check | Trigger | Required action |
|---|---|---|
| `RegulatoryRAG` | MOIAT/FANR/DCD/ADNOC permit rule, HS classification, controlled item keywords | Retrieve current approved SOP/authority evidence before automated release |
| `RateRAG` | invoice line requires rate interpretation | Retrieve current contract/RateRef in `CONSOLIDATED-05`; LDG only supplies evidence |
| `RouteRAG` | AGI/DAS, MOSB, LCT, offshore terms detected | Retrieve current routing plan / marine approval / port evidence |
| `DocumentTemplateRAG` | new vendor template or unseen table layout | compare to approved document template library and route to reviewer if unknown |
| `ExceptionRAG` | OSDR/NCR/damage/shortage keyword detected | retrieve claim SOP and linked inspection evidence |

### 5.7 Human-gate Policy

| Condition | Human role | Output |
|---|---|---|
| `totalAmount > 100,000.00 AED` or equivalent source-currency threshold | Cost / finance reviewer | `ApprovalAction` before cost automation |
| `MeanConf < 0.92` or `TableAcc < 0.98` | Document controller | corrected extraction or ZERO hold |
| `NumericIntegrity != 1.00` | Finance / document controller | discrepancy record |
| AGI/DAS document lacks MOSB/offshore evidence | Logistics / marine reviewer | route evidence acceptance or exception |
| regulated product / DG / FANR / DCD keywords detected | Compliance owner | permit verification |
| OOG/heavy-lift/lashing/stability/PTW terms detected | Marine / HSE engineer | technical gate acceptance |
| OSDR/NCR/damage/shortage detected | QA/QC + claim owner | exception and claim linkage |

### 5.8 ZERO Fail-safe Table

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Document intake | docHash/sourceSystem missing | evidence spoofing / duplicate object | source file, registry hash | block ingestion |
| OCR extraction | confidence below threshold | incorrect value propagation | source image, corrected field | human review |
| Table parsing | table accuracy below threshold | amount/qty mismatch | extracted table, original page | table re-extraction |
| Cross-doc validation | CI/PL/BL/BOE mismatch | customs hold / wrong shipment link | matching document set | discrepancy resolution |
| Compliance | permit expired/missing | regulatory breach | valid permit/SOP evidence | compliance approval |
| Route evidence | AGI/DAS lacks MOSB evidence | offshore delivery blocker | MOSB/LCT/route plan evidence | marine/logistics review |

---

## 6. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 6.1 Compliance Object Handling

| Compliance object | Document evidence | LDG action | Owner |
|---|---|---|---|
| `IncotermTerm` | CI/PO incoterm and delivery place | extract and cross-check with invoice responsibility | Core / Cost |
| `MOIATRequirement` | certificate/ref/expiry, regulated product hint | create compliance evidence assertion | Compliance owner |
| `FANRRequirement` | radiation/nuclear/source terms, permit ref | trigger human-gate | Compliance owner |
| `DCDDangerousGoodsRequirement` | DG class, UN No., MSDS, storage segregation | trigger DG evidence and WH/HSE gate | HSE / WH |
| `ADNOC/CICPA/SiteAccess` | gate pass, access permit, security approval | validate expiry before M100/M130 evidence | Site / security |
| `WCO/HSClassification` | HS code, origin, value, material description | flag low confidence or mismatch | Customs owner |
| `Marine/HSEApproval` | PTW, FRA, method statement, lashing/stability | evidence gate for M117/M130 | Marine / HSE |

### 6.2 Non-collapse Compliance Rules

1. `BOEDocument` is evidence for `CustomsEntry`; it is not the `CustomsEntry` transaction.
2. `DeliveryOrderDocument` is evidence for `ReleaseOrder`; it is not the `ReleaseOrder` transaction.
3. `MRR`, `MRI`, `POD`, `GRN`, and `OSDR` are site/inspection/closeout evidence; they do not replace `SiteReceipt`, `InspectionEvent`, or `Exception` objects.
4. Permit files prove compliance status but do not approve movement unless a valid `ApprovalAction` exists.
5. Communication evidence is linked through `AuditRecord` / `ApprovalAction`, not by redefining logistics objects.

### 6.3 Document Requirements by Operational Stage

| Stage | Required document evidence | Minimum validation |
|---|---|---|
| Export origin | CI, PL, COO/FCO, export license where applicable | documentNo/hash/shipper/consignee/qty/weight |
| Import UAE | BOE, HS, origin/value, regulated-item permit where applicable | HS/value/permit consistency |
| Port release | DO, release confirmation, terminal evidence | releaseDate, terminal, shipment/container link |
| Inland/WH | gate pass, receipt note, storage notes, MSDS if DG | M100/M110 evidence and WHP input only |
| MOSB/marine | PTW, FRA, method statement, LCT/loading/lashing/stability evidence | approval validity and M115/M117 support |
| Site receiving | MRR, MRI, POD, GRN, OSDR where applicable | siteCode, receivedQty, condition, acceptanceDate |
| Closeout | final cost, claim, NCR/OSDR closure documents | proof artifact and audit completeness |

---

## 7. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Description | Pros | Cons | Cost estimate | Risk | Time |
|---|---|---|---|---:|---|---:|
| A. Baseline LDG Evidence Layer | OCR + JSON-LD payload + SHACL gates for CI/PL/BL/BOE/DO | fastest rollout; strong document traceability | limited real-time action control | 35,000.00 AED | Medium | 2.00 weeks |
| B. Hybrid Foundry Object + KG | Foundry Objects/Links + RDF export + SPARQL validation | best balance; operational dashboard ready | requires object/action governance | 85,000.00 AED | Medium | 4.00 weeks |
| C. Real-time Semantic Digital Twin | streaming OCR evidence, action gates, RAG checks, human-gate queues | highest automation and auditability | highest integration complexity | 160,000.00 AED | High | 8.00 weeks |
| D. Compliance-first Variant | permit/HS/DG/FANR/MOIAT gate before route/cost automation | lowers regulatory risk | slower operational throughput | 70,000.00 AED | Low | 3.00 weeks |

**Recommendation:** Option B for first production deployment. It preserves evidence-only semantics, integrates with Foundry objects, and keeps cost/customs/warehouse ownership boundaries intact.

---

## 8. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Duration | Deliverables | KPI gate |
|---|---:|---|---|
| Prepare | 1.00 week | document type registry, JSON-LD context, SHACL baseline, identifier dictionary | DocumentTypeCoverage ≥ 90.00% |
| Pilot | 2.00 weeks | CI/PL/BL/BOE/DO sample run, Any-key linking, cross-doc discrepancy report | MeanConf ≥ 0.92; NumericIntegrity = 1.00 |
| Build | 3.00 weeks | Foundry Object/Link mapping, SPARQL rules, review queue, audit payload | CrossDocumentConsistency = 1.00 |
| Operate | continuous | daily LDG run, exception triage, KPI dashboard, human-gate SLA | Validation p95 < 5.00s; Review SLA ≤ 24.00h |
| Scale | continuous | Permit/RAG, marine docs, site closeout docs, CostGuard handoff | EvidenceCompleteness ≥ 98.00% |

---

## 9. Automation notes (RPA/LLM/Sheets/TG hooks)

### 9.1 Automation Architecture

| Automation | Trigger | Action | Guard |
|---|---|---|---|
| `LDGIngestBot` | new file in document store | create `Document` + hash + sourceSystem | duplicate hash blocker |
| `OCRTableBot` | document accepted | extract token/table/cell evidence | MeanConf/TableAcc gate |
| `EntityLinker` | extracted entities available | create identifiers and cross-doc links | Any-key conflict review |
| `RouteEvidenceBot` | destination/route/MOSB terms detected | create route evidence assertion | evidence-only; no route truth write |
| `PermitGuard` | regulated/DG/FANR/MOIAT terms detected | create compliance review task | current SOP/RAG required |
| `NumericGuard` | invoice/CI table parsed | check EA×Rate and Σ totals | block if NumericIntegrity != 1.00 |
| `WHPBoundaryGuard` | any document tries warehouse class write | block and create violation | WHP owner only |
| `CostEvidenceHandoff` | invoice evidence validated | pass clean evidence to CostGuard | cost verdict remains Cost domain |
| `TelegramDigest` | daily 08:00 Asia/Dubai | send mismatch/hold summary | PII masked |
| `SheetsExport` | reviewer requests export | export discrepancy matrix | source hash included |

### 9.2 LDG_AUDIT Payload Skeleton

```json
{
  "auditId": "LDG-AUDIT-{documentNo}-{runId}",
  "runDate": "2026-04-27",
  "timezone": "Asia/Dubai",
  "document": {
    "documentNo": "string",
    "docType": "CommercialInvoiceDocument",
    "docHash": "sha256:string",
    "sourceSystem": "ERP|Carrier|ATLP|WMS|Port|Site|Manual"
  },
  "metrics": {
    "meanConf": 0.92,
    "tableAcc": 0.98,
    "numericIntegrity": 1.00,
    "crossDocumentConsistency": 1.00,
    "routeEvidenceAccuracy": 0.95
  },
  "evidence": {
    "routeEvidence": "string",
    "destinationEvidence": "AGI|DAS|MIR|SHU|UNKNOWN",
    "mosbLegIndicator": true,
    "complianceEvidence": ["permitRef", "hsCode", "dgClass"],
    "costEvidence": ["currency", "totalAmount", "lineCount"]
  },
  "verdict": "PASS|WARN|FAIL|ZERO",
  "humanGateRequired": false,
  "proofArtifact": {
    "ruleIds": ["D-IDENT-001", "D-OCR-001"],
    "reviewer": null,
    "timestamp": "2026-04-27T00:00:00+04:00"
  }
}
```

---

## 10. QA checklist & Assumptions(가정:)

### 10.1 QA Checklist

| Check | PASS criteria |
|---|---|
| Master spine alignment | `CONSOLIDATED-00` object boundaries preserved |
| Evidence-only discipline | LDG writes evidence, verification, audit only |
| Route separation | Route truth uses `ShipmentUnit.hasRoutingPattern`, not document-owned route status |
| WHP boundary | `confirmedFlowCode` appears only as blocked/guarded WHP concept; never as document property |
| MOSB classification | MOSB evidence maps to `OffshoreStagingNode` / `MarineInterfaceNode`, not Warehouse |
| Document type coverage | CI/PL/BL/BOE/DO/Permit/MRR/MRI/POD/GRN/OSDR modeled |
| Non-collapse rule | BOE/DO/MRR/POD/GRN/OSDR remain evidence, not transaction objects |
| Numeric integrity | EA×Rate and invoice total rules defined |
| KPI gates | MeanConf, TableAcc, NumericIntegrity, CrossDocumentConsistency gates defined |
| Compliance | Incoterms/MOIAT/FANR/DCD/ADNOC evidence controls included |
| PII handling | contact details masked in audit/export outputs unless approved |
| Human-gate | high-value, regulated, low-confidence, and exception cases routed to review |

### 10.2 Assumptions(가정:)

- `ShipmentUnit` is the operational anchor for document linkage.
- LDG can propose evidence and discrepancies, but approved Foundry Actions are required to mutate operational truth.
- OCR engines and table parsers produce token/cell-level confidence and bounding boxes.
- Project-specific permit rules, authority forms, and rate tables require current approved SOP or contract evidence before automation.
- Currency conversion, if required, is performed downstream under `CONSOLIDATED-05`; LDG preserves original currency and values.
- PII in person/contact evidence is masked in all routine audit exports.

---

## 11. Patch Ledger — 5x Corpus Compatibility Review

### 11.1 Parallel Review Lanes

| Pass | Review lane | Corpus checked | Finding | Patch applied | Status |
|---:|---|---|---|---|---|
| 1.00 | Master spine | `CONSOLIDATED-00`, `AGENTS.md`, review note | Document layer must be evidence-only and cannot override master route/WHP ownership | Rewrote governance, non-collapse, evidence boundary | PASS |
| 2.00 | Warehouse boundary | `CONSOLIDATED-02`, `CONSOLIDATED-06` | WHP classification starts at M110/M111; OCR may only provide storage/DG/OOG evidence | Added WHPBoundaryGuard and blocked document-level warehouse class writes | PASS |
| 3.00 | Route/marine/port/cost boundary | `CONSOLIDATED-04`, `05`, `07`, `09` | Port/marine/cost/ops consume evidence but own their own truth objects | Replaced legacy route-code wording with `routeEvidence` and `RoutingPattern` handoff | PASS |
| 4.00 | Validation/compliance | `CONSOLIDATED-01`, `05`, `06`, `07` | Need permit, HS, DO, BOE, AGI/DAS MOSB, numeric gate controls | Added SHACL/SPARQL/RAG/human-gate matrix | PASS |
| 5.00 | Artifact hygiene | full md corpus + PDF architecture | Need final document in v2.0-frontmatter with 5 validation passes and no canonical legacy leakage | Added `validation_passes: 5`, checked_against list, final QA checklist | PASS |

### 11.2 Final Patch Summary

- `sub-domains` updated from legacy route-code framing to `route-evidence`, `compliance-evidence`, and `cost-evidence`.
- `extension_of` updated to `hvdc-master-ontology-v2.0-final`.
- Document evidence properties aligned to master: `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, `routeEvidenceConfidence`.
- `routeEvidence` range corrected to string / SKOS concept instead of numeric route code.
- Added `EvidenceOwnershipGuardShape` to block document-level warehouse class writes.
- Added AGI/DAS MOSB evidence check and human-gate logic.
- Preserved LDG/OCR classes while collapsing duplicate property blocks into a controlled schema.
- Added Foundry integration, CostGuard handoff, compliance gate, and ZERO fail-safe.

---

## 12. CmdRec

- `/switch_mode LATTICE + /logi-master document-guardian --deep --trust-validation` — LDG/OCR 문서 신뢰 검증 실행
- `/logi-master cert-chk --deep --KRsummary` — MOIAT/FANR/DCD/ADNOC permit evidence 점검
- `/logi-master invoice-audit --AEDonly` — LDG invoice evidence를 CostGuard로 전달하여 라인별 Δ% 검증


---

# FILE: CONSOLIDATED-04-barge-bulk-cargo.md

---
title: "HVDC Marine, Barge & Bulk Cargo Ontology — Consolidated"
type: "ontology-design"
domain: "marine-barge-bulk-operations"
sub-domains:
  - marine-operations
  - barge-lct-operations
  - bulk-cargo-operations
  - oog-heavy-lift
  - stowage-and-seafastening
  - stability-control
  - lifting-and-rigging
  - mosb-offshore-staging
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "marine, bulk, OOG, lashing, stability, LCT/barge execution extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - IMSBC-Code
  - SOLAS
  - IMDG-Code
  - BIMCO-SUPPLYTIME-2017
source_files:
  - 1_CORE-05-hvdc-bulk-cargo-ops.md
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
validation_passes: 5
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
---

# hvdc-barge-bulk-cargo · CONSOLIDATED-04

## 1. ExecSummary

`CONSOLIDATED-04`는 HVDC Logistics KG의 **marine / barge / bulk / OOG execution extension**이다. 본 문서는 MOSB staging, LCT/barge loading, seafastening, stability, lifting, discharge, marine handover를 `ShipmentUnit`, `CargoUnit`, `MarineOperation`, `MarineEvent`, `OperationTask`, `StowagePlan`, `LashingPlan`, `StabilityCase`, `LiftingPlan`으로 정규화한다.

비즈니스 임팩트는 **AGI/DAS offshore delivery의 M115→M116→M117→M130 traceability**, **deck pressure / stability / lashing / rigging gate의 사전 차단**, **LCT utilization 및 MOSB dwell risk의 가시화**, **marine document evidence 기반 승인 추적**이다.

기술 해법은 `MarineRoutingPattern`과 `offshoreDeliveryPattern`을 marine leg 전용 분류로 사용하고, end-to-end route는 `ShipmentRoutingPattern`, 실행 상태는 `MilestoneEvent`, warehouse 내부 처리는 `WarehouseHandlingProfile`로 분리하는 것이다.

KPI 목표는 `MarinePlanCoverage ≥ 95.00%`, `DeckPressurePassRate = 100.00%`, `StabilityGatePassRate = 100.00%`, `LashingEvidenceCompleteness ≥ 98.00%`, `LCTUtilization = 80.00–85.00%`, `Validation p95 < 5.00s`이다.

**ENG-KR one-liner:** Marine execution owns MOSB staging, LCT/barge events, stowage, lashing, stability, and lifting controls; route truth remains in `RoutingPattern`, and warehouse handling remains in `WarehouseHandlingProfile` only.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-04` owns **marine / barge / bulk / OOG execution semantics** only.
3. Program-wide shipment visibility uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`.
4. Marine leg classification uses `MarineRoutingPattern` and `offshoreDeliveryPattern`.
5. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; it is not a top-level `Warehouse`.
6. Warehouse handling classification is owned only by `WarehouseHandlingProfile.confirmedFlowCode` in `CONSOLIDATED-02`.
7. Documents, port records, costs, and communications provide evidence; they do not own marine execution truth.
8. Engineering approval remains human-gated. This ontology validates data readiness and consistency; it does not replace MWS, marine warranty, naval architecture, lifting engineer, HSE, port authority, or client approval.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-04 | Delegated / excluded |
|---|---|---|
| MOSB staging | M115, laydown, consolidation, marine readiness, staging inspection | Warehouse put-away and stock ownership in `CONSOLIDATED-02` |
| LCT / barge execution | M116 loaded, barge trip, ATD/ETA/ATA, sail-away approval M117 | Port entry / customs release in `CONSOLIDATED-07` / `CONSOLIDATED-06` |
| Bulk cargo | Aggregate, sand, soil, rock, steel bundle, pipe bundle, precast, jumbo bags | Commercial invoice audit in `CONSOLIDATED-05` |
| OOG / heavy lift | Transformer, cable drum, pre-assembled module, A-frame, PC beam/column | Supplier manufacturing readiness in ERP / procurement |
| Stowage | deck slot, COG, footprint, deck pressure, sequence | CAD/BIM geometry as external engineering evidence |
| Seafastening / lashing | lashing assembly, WLL, angle, count, safety factor, inspection | Final engineering calculation approval |
| Stability | displacement, GM, VCG, trim, list, loading condition, weather gate | Naval architecture final approval |
| Lifting / rigging | lifting plan, rigging gear, sling angle, crane/Hiab/SPMT interface | Final lifting engineer approval |
| Marine permits | PTW, JSA/TRA, hot work, working-over-water, port/marine clearance | Authority approval system of record |
| Evidence | load plan, lashing plan, stability report, rigging plan, inspection photo, survey report | OCR extraction internals in `CONSOLIDATED-03` |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with marine/bulk | Not allowed in CONSOLIDATED-04 |
|---|---|---|
| Core master | Read/write `MarineEvent`, `OperationTask`, `JourneyLeg`, `MilestoneEvent` links | Redefine `ShipmentRoutingPattern` dictionary |
| Infrastructure | Read `Port`, `Berth`, `Jetty`, `OffshoreStagingNode`, `Site`, `TransportCorridor` | Type MOSB as top-level `Warehouse` |
| Warehouse | Read WH dispatch evidence M121 and storage constraints | Assign or interpret warehouse handling class |
| Document/OCR | Consume `routeEvidence`, `destinationEvidence`, `mosbLegIndicator`, plan documents | Treat OCR output as engineering approval |
| Port | Consume `plannedRoutingPattern`, berth, gate, port service evidence | Assign marine execution status from port invoice alone |
| Material handling | Provide M115/M116/M117/M130 milestone continuity | Collapse site receipt into marine discharge |
| Cost | Export marine charge evidence and LCT utilization | Own cost bands or CostGuard verdict |
| Operations/KPI | Export marine event, LCT, MOSB dwell, safety gate KPIs | Replace routing analytics with marine-only vocabulary |

### 2.4 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Marine domain using warehouse handling class language | `MarineRoutingPattern` and `offshoreDeliveryPattern` | Replace in all marine tables and SHACL |
| Port→WH→MOSB→Site described as marine class | `ShipmentRoutingPattern` for E2E, `MarineRoutingPattern` for MOSB/LCT leg | Separate routing layers |
| MOSB treated as warehouse | `OffshoreStagingNode` with optional `LaydownArea` / `StorageCapability` | Preserve staging function only |
| Direct cost implication from marine class | `MarineChargeEvidence`, `LCTTrip`, `MarineServiceEvent` | Cost domain calculates audit result |
| Document-derived marine approval | `DocumentEvidence` + `ApprovalAction` | Human-gate for MWS / stability / lifting |

---

## 3. Schema — RDF/OWL + SHACL 요약

### 3.1 Marine Ontology Layer

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Core cargo | `CargoUnit`, `BulkCargoUnit`, `OOGCargoUnit`, `HeavyLiftCargoUnit` | Marine-handled cargo object |
| Marine operation | `MarineOperation`, `BargeOperation`, `LCTOperation`, `BulkCargoOperation` | Marine execution transaction |
| Event | `MarineEvent`, `MOSBStagedEvent`, `LCTLoadedEvent`, `SailAwayEvent`, `OffshoreDischargeEvent` | Time-stamped execution evidence |
| Stowage | `StowagePlan`, `DeckArea`, `DeckSlot`, `StowagePosition` | Deck layout and pressure control |
| Seafastening | `LashingPlan`, `LashingAssembly`, `LashingElement`, `SeafasteningInspection` | Sea transport securing control |
| Stability | `StabilityCase`, `LoadingCondition`, `BallastCondition`, `HydrostaticLimit` | Barge/LCT stability gate |
| Lifting | `LiftingPlan`, `LiftOperation`, `RiggingGear`, `CraneResource`, `SPMTResource` | Load handling gate |
| Environment | `MarineWeatherWindow`, `SeaStateObservation`, `TideWindow` | Weather / tide feasibility gate |
| Resource | `MarineAsset`, `Barge`, `LCT`, `Crew`, `EquipmentResource` | Vessel, crew, equipment allocation |
| Compliance | `MarinePermit`, `PTW`, `JSA`, `TRA`, `MWSApproval`, `HSEApproval` | Approval and permit evidence |
| Evidence | `MarineDocument`, `SurveyReport`, `InspectionPhoto`, `AuditRecord` | Provenance and validation proof |
| KPI | `MarineKPI`, `LCTUtilizationMetric`, `MOSBDwellMetric`, `DeckPressureMetric` | Operational monitoring |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `MarineOperation` | `operationId`, `operationType`, `operationStatus`, `plannedStart`, `actualStart`, `actualEnd` | `forShipmentUnit`, `hasMarineEvent`, `usesMarineAsset`, `requiresApproval` | Parent marine transaction |
| `BargeOperation` | `bargeOperationId`, `bargeName`, `voyageNo`, `marineRoutingPattern` | `subClassOf MarineOperation`, `hasStowagePlan`, `hasStabilityCase` | Generic barge movement |
| `LCTOperation` | `lctOperationId`, `lctName`, `wellsId`, `musNo`, `departureNode`, `arrivalNode` | `subClassOf BargeOperation`, `hasLCTTrip` | AGI/DAS LCT leg |
| `BulkCargoUnit` | `cargoId`, `bulkCategory`, `qty`, `uom`, `weightMt`, `volumeCbm` | `belongsTo ShipmentUnit`, `allocatedTo DeckSlot` | Aggregate/sand/soil/bulk cargo |
| `OOGCargoUnit` | `cargoId`, `lengthM`, `widthM`, `heightM`, `grossWeightMt`, `cogX`, `cogY`, `cogZ` | `requiresLiftingPlan`, `requiresLashingPlan` | OOG/heavy project cargo |
| `DeckArea` | `deckAreaId`, `usableLengthM`, `usableWidthM`, `maxUniformLoadTpm2`, `maxPointLoadT` | `partOf MarineAsset`, `containsDeckSlot` | LCT/barge deck capacity |
| `DeckSlot` | `slotId`, `xM`, `yM`, `lengthM`, `widthM`, `allowablePressureTpm2` | `partOf DeckArea`, `occupiedBy CargoUnit` | Stowage position |
| `StowagePlan` | `planId`, `planVersion`, `approvalStatus`, `totalWeightMt`, `maxDeckPressureTpm2` | `forMarineOperation`, `hasStowagePosition`, `approvedBy` | Load plan control object |
| `LashingPlan` | `planId`, `calcMethod`, `approvalStatus`, `safetyFactorMin` | `secures CargoUnit`, `hasLashingAssembly`, `verifiedBy` | Seafastening control |
| `LashingAssembly` | `assemblyId`, `requiredCapacityT`, `calculatedTensionT`, `safetyFactor` | `uses LashingElement`, `appliedTo CargoUnit` | Per-cargo lashing proof |
| `LashingElement` | `elementId`, `elementType`, `wllT`, `angleDeg`, `count` | `partOf LashingAssembly` | Chain, belt, wire, shackle, turnbuckle |
| `StabilityCase` | `caseId`, `loadingCondition`, `displacementMt`, `gmM`, `vcgM`, `trimM`, `listDeg` | `evaluates MarineAsset`, `considers StowagePlan`, `approvedBy` | Stability gate |
| `LiftingPlan` | `liftId`, `liftMethod`, `grossLiftWeightMt`, `slingAngleDeg`, `approvalStatus` | `for CargoUnit`, `uses RiggingGear`, `uses EquipmentResource` | Lift / LOLO / RORO interface |
| `MarineWeatherWindow` | `windowId`, `startTime`, `endTime`, `maxWindKn`, `maxSeaState`, `visibilityNm` | `appliesTo MarineOperation`, `verifiedBy` | Weather feasibility |
| `MarinePermit` | `permitId`, `permitType`, `issuer`, `validFrom`, `validTo`, `status` | `requiredFor MarineOperation`, `evidencedByDocument` | PTW, JSA, TRA, marine clearance |
| `MarineDocument` | `docId`, `docType`, `docVersion`, `docHash`, `approvalStatus` | `evidences MarineOperation`, `wasDerivedFrom` | Plan/report/proof artifact |

### 3.3 Controlled Vocabularies

| Vocabulary | Values | Owner |
|---|---|---|
| `MarineRoutingPattern` | `DIRECT_MOSB`, `WH_THEN_MOSB`, `LCT_DIRECT`, `OFFSHORE_PENDING`, `SPLIT_MARINE_LEG`, `EXCEPTIONAL_HEAVY_LIFT` | `CONSOLIDATED-04` |
| `OffshoreDeliveryPattern` | `MOSB_TO_AGI`, `MOSB_TO_DAS`, `PORT_TO_MOSB`, `WH_TO_MOSB`, `BARGE_SHUTTLE`, `PENDING_ASSIGNMENT` | `CONSOLIDATED-04` |
| `MarineOperationStatus` | `PLANNED`, `READY`, `PERMIT_PENDING`, `APPROVED`, `LOADING`, `SAIL_AWAY_APPROVED`, `IN_TRANSIT`, `DISCHARGING`, `COMPLETED`, `BLOCKED`, `CANCELLED` | `CONSOLIDATED-04` |
| `CargoMarineCategory` | `BULK_AGGREGATE`, `BULK_SAND`, `BULK_SOIL`, `STEEL_STRUCTURE`, `PIPE_BUNDLE`, `PRECAST_UNIT`, `JUMBO_BAG`, `TRANSFORMER`, `CABLE_DRUM`, `A_FRAME`, `MIXED_PROJECT_CARGO` | `CONSOLIDATED-04` |
| `StowageApprovalStatus` | `DRAFT`, `CHECKED`, `APPROVED`, `REJECTED`, `SUPERSEDED` | `CONSOLIDATED-04` |
| `LashingApprovalStatus` | `DRAFT`, `CALCULATED`, `ENGINEER_REVIEWED`, `APPROVED`, `FIELD_VERIFIED`, `REJECTED` | `CONSOLIDATED-04` |
| `StabilityGateStatus` | `NOT_STARTED`, `DATA_MISSING`, `CALCULATED`, `PASS`, `FAIL`, `APPROVED_WITH_CONDITION` | `CONSOLIDATED-04` |
| `WeatherGateStatus` | `OPEN`, `WATCH`, `HOLD`, `CLOSED`, `OVERRIDE_APPROVED` | `CONSOLIDATED-04` |

### 3.4 Object Property Map

| Object property | Domain → Range | Meaning |
|---|---|---|
| `marine:forShipmentUnit` | `MarineOperation → ShipmentUnit` | Marine operation belongs to shipment unit |
| `marine:hasMarineRoutingPattern` | `MarineOperation → MarineRoutingPattern` | Marine leg classification |
| `marine:hasOffshoreDeliveryPattern` | `MarineOperation → OffshoreDeliveryPattern` | Offshore delivery path |
| `marine:usesMarineAsset` | `MarineOperation → MarineAsset` | LCT/barge/vessel allocation |
| `marine:usesDeckArea` | `StowagePlan → DeckArea` | Deck capacity context |
| `marine:positionsCargo` | `StowagePlan → CargoUnit` | Cargo included in stowage plan |
| `marine:securedBy` | `CargoUnit → LashingAssembly` | Cargo seafastening relation |
| `marine:evaluatedBy` | `MarineOperation → StabilityCase` | Stability proof |
| `marine:liftedBy` | `CargoUnit → LiftOperation` | Lift execution link |
| `marine:requiresPermit` | `MarineOperation → MarinePermit` | Permit gate |
| `marine:evidencedBy` | `MarineOperation → MarineDocument` | Evidence trace |
| `marine:generatesMilestone` | `MarineEvent → MilestoneEvent` | M115/M116/M117/M130 linkage |

### 3.5 Datatype Property Map

| Datatype property | Domain | Range / rule |
|---|---|---|
| `marine:grossWeightMt` | `CargoUnit` | `xsd:decimal`, `> 0.00` |
| `marine:lengthM`, `marine:widthM`, `marine:heightM` | `CargoUnit` | `xsd:decimal`, `> 0.00` |
| `marine:cogXM`, `marine:cogYM`, `marine:cogZM` | `CargoUnit` | `xsd:decimal`, required for OOG/heavy lift |
| `marine:footprintSqm` | `CargoUnit` | `lengthM × widthM` |
| `marine:deckPressureTpm2` | `DeckSlot` / `StowagePosition` | `grossWeightMt / footprintSqm` |
| `marine:maxUniformLoadTpm2` | `DeckArea` | deck limit |
| `marine:gmM` | `StabilityCase` | `xsd:decimal`, project-defined minimum gate |
| `marine:listDeg`, `marine:trimM` | `StabilityCase` | project-defined limit |
| `marine:wllT` | `LashingElement` | working load limit |
| `marine:safetyFactor` | `LashingAssembly` | must be `>= requiredSafetyFactor` |
| `marine:maxWindKn`, `marine:maxSeaState` | `MarineWeatherWindow` | weather gate |
| `marine:approvalStatus` | plan/document classes | controlled vocabulary |

---

## 4. Routing & Milestone Model

### 4.1 Separation of E2E Routing and Marine Leg

| Layer | Vocabulary | Example | Owner |
|---|---|---|---|
| End-to-end shipment route | `ShipmentRoutingPattern` | `MOSB_DIRECT`, `WH_MOSB`, `MIXED` | `CONSOLIDATED-00` |
| Journey stage | `JourneyStage` | `MOSB_STAGING`, `OFFSHORE_TRANSIT`, `SITE_RECEIVING` | `CONSOLIDATED-00` |
| Marine leg | `MarineRoutingPattern` | `DIRECT_MOSB`, `WH_THEN_MOSB`, `LCT_DIRECT` | `CONSOLIDATED-04` |
| Offshore delivery | `offshoreDeliveryPattern` | `MOSB_TO_AGI`, `MOSB_TO_DAS` | `CONSOLIDATED-04` |
| Warehouse handling | `WarehouseHandlingProfile.confirmedFlowCode` | warehouse-only handling class | `CONSOLIDATED-02` |

### 4.2 Marine Milestone Chain

| Milestone | Name | Required evidence | Blocking rule |
|---|---|---|---|
| `M115` | MOSB Staged | MOSB staging request, laydown allocation, cargo inspection, ALS/Marine confirmation | Cannot proceed to M116 without cargo, deck, permit readiness |
| `M116` | LCT / Barge Loaded | stowage plan, loading checklist, lashing inspection, deck pressure check | Cannot proceed to M117 if lashing/stability not approved |
| `M117` | Sail-away Approved | weather/tide gate, stability approval, marine clearance, vessel readiness | Cannot depart if weather gate is HOLD/CLOSED without override |
| `M118` | Offshore Arrival / Alongside | ATA AGI/DAS, berth/landing confirmation, site readiness | Cannot discharge if site access or lifting permit missing |
| `M119` | Offshore Discharged | discharge checklist, receiving handover, damage/shortage note | Must create exception if OSD found |
| `M130` | Site Arrived | site receipt / MRR / POD / GRN evidence | AGI/DAS requires prior M115/M116/M117 evidence unless exception approved |

### 4.3 MarineRoutingPattern Rules

| Pattern | Canonical path | Use case | Required milestones |
|---|---|---|---|
| `DIRECT_MOSB` | Port → MOSB → LCT/Barge → AGI/DAS | Bulk/OOG cargo bypasses warehouse and stages at MOSB | M100 → M115 → M116 → M117 → M130 |
| `WH_THEN_MOSB` | WH → MOSB → LCT/Barge → AGI/DAS | Cargo consolidated or preserved in WH before offshore move | M121 → M115 → M116 → M117 → M130 |
| `LCT_DIRECT` | MOSB → LCT/Barge → Site | Marine leg only; used when upstream route is already resolved | M115 → M116 → M117 → M130 |
| `OFFSHORE_PENDING` | MOSB staged, site/voyage not yet fixed | Waiting for site readiness, permit, vessel, weather, or priority | M115 open; M116 not allowed |
| `SPLIT_MARINE_LEG` | One shipment split across multiple LCT trips | Heavy/volume split, mixed cargo or partial dispatch | Each trip needs separate M116/M117 |
| `EXCEPTIONAL_HEAVY_LIFT` | Special engineering route | Transformer, oversized module, abnormal lift | MWS / engineering / HSE human-gate mandatory |

### 4.4 AGI/DAS Offshore Rule

1. If `declaredDestination IN (AGI, DAS)`, the shipment must carry `ShipmentRoutingPattern IN (MOSB_DIRECT, WH_MOSB, MIXED)` or an explicit exception.
2. If a marine leg is present, `MarineRoutingPattern` must be one of `DIRECT_MOSB`, `WH_THEN_MOSB`, `LCT_DIRECT`, `SPLIT_MARINE_LEG`, `EXCEPTIONAL_HEAVY_LIFT`.
3. `M130 Site Arrived` for AGI/DAS is invalid without prior M115, M116, and M117 unless `ExceptionStatus = APPROVED_OVERRIDE`.
4. MOSB laydown/storage is modeled as `LaydownArea` or `StorageCapability` attached to `OffshoreStagingNode`, not as a top-level `Warehouse`.

---

## 5. Marine Operations Process

### 5.1 Prepare — Marine Readiness

| Step | Input | Output | Gate |
|---|---|---|---|
| Cargo data capture | CI/PL, packing list, survey sheet, WMS, site request | normalized `CargoUnit` and `BulkCargoUnit` | Dimensions, weight, COG completeness |
| Route confirmation | port/WH dispatch, destination, site priority | `ShipmentRoutingPattern` + `MarineRoutingPattern` candidate | AGI/DAS MOSB rule |
| Marine asset nomination | LCT/barge availability, deck strength, cargo footprint | `MarineAsset` allocation | deck capacity and availability |
| Permit readiness | PTW, JSA/TRA, gate pass, ADNOC/ALS clearance | `MarinePermit` records | valid dates and issuer |
| Engineering document readiness | load plan, lashing plan, stability report, lifting plan | `MarineDocument` evidence | approved version only |

### 5.2 MOSB Staging — M115

| Control | Required data | Fail condition |
|---|---|---|
| Cargo identity | `shipmentId`, `packageNo`, `HVDC_CODE`, cargo label | unresolved identity |
| Physical condition | photo, inspection report, damage note | unclosed OSD |
| Laydown allocation | `LaydownArea`, footprint, access path | area capacity exceeded |
| Sequence readiness | load order, priority, site receiving window | no linked LCT/voyage plan |
| Permit readiness | access, PTW, HSE, security | expired or missing permit |

### 5.3 LCT / Barge Loading — M116

| Control | Required data | Fail condition |
|---|---|---|
| Stowage | deck slot, cargo position, sequence | unapproved stowage plan |
| Deck pressure | weight, footprint, deck allowable | pressure above limit |
| Lashing | lashing assembly, WLL, angle, count | safety factor below gate |
| Stability | GM, VCG, trim, list, loading condition | stability gate not PASS/approved |
| Lift / ramp | crane/Hiab/SPMT/ramp data | SWL, axle, ramp, or lift data missing |
| Checklist | loading checklist, inspection sign-off | no field verification |

### 5.4 Sail-away — M117

| Control | Required data | Fail condition |
|---|---|---|
| Weather | wind, sea state, visibility, forecast window | weather gate HOLD/CLOSED |
| Tide / berth | tide window, berth availability, pilot/port control | window mismatch |
| Marine readiness | crew, vessel certificate, fuel, communication | incomplete readiness |
| Client / authority gate | ALS/ADNOC/MWS/HSE approval as applicable | missing approval |
| Document pack | manifest, PL, inspection, load plan, lashing/stability report | incomplete evidence pack |

### 5.5 Offshore Discharge and Site Handover — M118/M119/M130

| Control | Required data | Fail condition |
|---|---|---|
| Arrival | ATA, berth/landing confirmation, site access | arrival not confirmed |
| Discharge method | crane/ramp/Hiab/SPMT/lifting plan | method not approved |
| Receiving | MRR/POD/GRN, site inspection | missing site evidence |
| OSD | damage, shortage, overage, NCR | exception not created |
| Close-out | final report, signed checklist, document archive | missing close-out pack |

---

## 6. Stowage, Deck Pressure, Lashing, Stability, Lifting

### 6.1 Stowage Data Model

| Data item | Required for | Rule |
|---|---|---|
| `cargo.lengthM`, `cargo.widthM`, `cargo.heightM` | all OOG / project cargo | must be > 0.00 |
| `cargo.grossWeightMt` | all cargo | must be > 0.00 |
| `cargo.cogX/Y/Z` | OOG, heavy lift, transformer, unstable cargo | required before M116 |
| `deck.maxUniformLoadTpm2` | all deck areas | required before deck pressure validation |
| `deck.maxPointLoadT` | point-loaded cargo / jacking / skid | required before M116 |
| `position.xM`, `position.yM` | all deck stowage | must be inside deck boundary |
| `stowage.sequenceNo` | multi-cargo loading | must not conflict with discharge sequence |

### 6.2 Deck Pressure Rule

Formula:

```text
footprintSqm = lengthM × widthM
deckPressureTpm2 = grossWeightMt / footprintSqm
PASS if deckPressureTpm2 <= DeckArea.maxUniformLoadTpm2
ZERO if grossWeightMt, lengthM, widthM, or deck capacity is missing for OOG/heavy cargo
```

Minimum SHACL gate:

```turtle
@prefix marine: <https://hvdc-project.com/ontology/marine/> .
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

marine:DeckPressureShape a sh:NodeShape ;
  sh:targetClass marine:StowagePosition ;
  sh:property [
    sh:path marine:deckPressureTpm2 ;
    sh:datatype xsd:decimal ;
    sh:minInclusive 0.00 ;
    sh:message "deckPressureTpm2 must be calculated before M116." ;
  ] ;
  sh:sparql [
    sh:message "Deck pressure exceeds the allowable deck load for the assigned DeckArea." ;
    sh:select """
      PREFIX marine: <https://hvdc-project.com/ontology/marine/>
      SELECT $this
      WHERE {
        $this marine:deckPressureTpm2 ?p ;
              marine:assignedDeckArea ?area .
        ?area marine:maxUniformLoadTpm2 ?limit .
        FILTER(?p > ?limit)
      }
    """ ;
  ] .
```

### 6.3 Lashing / Seafastening Rule

```text
Required input:
- Cargo gross weight and COG
- Expected acceleration / voyage condition
- Lashing element WLL, angle, count
- Effective capacity per direction
- Minimum safety factor

PASS if calculated safety factor >= required safety factor and field inspection is signed.
ZERO if lashing plan is missing for OOG, transformer, heavy lift, or deck cargo exposed to sea passage.
```

SHACL gate:

```turtle
marine:LashingApprovalShape a sh:NodeShape ;
  sh:targetClass marine:LashingPlan ;
  sh:property [
    sh:path marine:approvalStatus ;
    sh:in ("APPROVED" "FIELD_VERIFIED") ;
    sh:message "LashingPlan must be APPROVED or FIELD_VERIFIED before M117." ;
  ] ;
  sh:property [
    sh:path marine:safetyFactorMin ;
    sh:minInclusive 1.00 ;
    sh:message "Lashing safety factor must be present and positive." ;
  ] .
```

### 6.4 Stability Rule

```text
Required input:
- MarineAsset loading condition
- Cargo list and deck positions
- Ballast condition
- GM, VCG, trim, list
- Applicable operating limit / approval note

PASS if StabilityCase.status IN (PASS, APPROVED_WITH_CONDITION) and condition notes are closed.
ZERO if stability report is missing before sail-away for LCT/barge heavy or mixed deck load.
```

SHACL gate:

```turtle
marine:StabilityGateShape a sh:NodeShape ;
  sh:targetClass marine:StabilityCase ;
  sh:property [
    sh:path marine:stabilityGateStatus ;
    sh:in ("PASS" "APPROVED_WITH_CONDITION") ;
    sh:message "StabilityCase must pass or be approved with condition before M117." ;
  ] ;
  sh:property [
    sh:path marine:gmM ;
    sh:datatype xsd:decimal ;
    sh:message "GM must be available for stability gate." ;
  ] .
```

### 6.5 Lifting / Rigging Rule

```text
Required input:
- Lift weight and COG
- Lift points
- Crane/Hiab/SPMT capacity
- Rigging gear WLL
- Sling angle and load share
- Lift supervisor approval

PASS if every rigging gear WLL >= calculated load share and lifting plan status is APPROVED.
ZERO if lift weight, COG, lift points, or rigging capacity is missing for OOG/heavy lift.
```

### 6.6 Weather / Tide Gate

| Gate | PASS | AMBER | ZERO |
|---|---|---|---|
| Wind | within operation limit | forecast uncertain / near limit | above limit and no override |
| Sea state | within marine plan | worsening trend | above limit and no override |
| Visibility | within navigation / lifting limit | restricted visibility warning | below minimum |
| Tide | compatible with draft / berth / ramp | narrow window | incompatible with operation |
| Port control / pilot | confirmed | pending confirmation | rejected / unavailable |

---

## 7. Integration — Foundry ↔ ERP/WMS/ATLP/Port/Invoice

### 7.1 Foundry Object Type Mapping

| Foundry Object Type | Source dataset | Key properties | Link Types |
|---|---|---|---|
| `MarineOperation` | marine operation register | `operationId`, `operationType`, `status`, `plannedStart`, `actualEnd` | forShipmentUnit → ShipmentUnit; usesMarineAsset → MarineAsset |
| `LCTOperation` | LCT/voyage tracker | `lctName`, `wellsId`, `musNo`, `ATD`, `ETA`, `ATA` | generatesMilestone → M116/M117/M118 |
| `BulkCargoUnit` | manifest / PL / WMS / site request | `cargoId`, `bulkCategory`, `qty`, `uom`, `weightMt` | belongsTo → ShipmentUnit; allocatedTo → DeckSlot |
| `OOGCargoUnit` | PL / engineering cargo sheet | `dimensions`, `grossWeightMt`, `COG`, `liftPoints` | requires → StowagePlan/LashingPlan/LiftingPlan |
| `MarineAsset` | vessel/barge master | `assetName`, `assetType`, `deckLimit`, `certificateStatus` | usedBy → MarineOperation |
| `StowagePlan` | load plan / deck plan | `planVersion`, `approvalStatus`, `maxDeckPressureTpm2` | positionsCargo → CargoUnit |
| `LashingPlan` | lashing calculation / inspection | `approvalStatus`, `safetyFactorMin` | secures → CargoUnit |
| `StabilityCase` | stability report | `gmM`, `vcgM`, `trimM`, `status` | evaluates → MarineOperation |
| `LiftingPlan` | rigging/lift plan | `liftMethod`, `grossLiftWeightMt`, `approvalStatus` | forCargo → CargoUnit |
| `MarinePermit` | PTW/JSA/TRA/GatePass | `permitType`, `issuer`, `validFrom`, `validTo` | requiredFor → MarineOperation |
| `MarineDocument` | document store / LDG | `docType`, `docHash`, `approvalStatus` | evidences → MarineOperation |
| `MarineKPI` | dashboard dataset | `metricCode`, `targetValue`, `actualValue` | measures → MarineOperation / MarineAsset |

### 7.2 Dataset Integration Points

| Source system | Dataset | Ontology output | Validation |
|---|---|---|---|
| ERP / PMO | `project_po_package_material` | `ShipmentUnit`, `CargoUnit`, `MaterialMaster` | package-material completeness |
| WMS | `wh_dispatch_m121` | M121 evidence, cargo availability | dispatch before M115 |
| Port / OFCO | `portcall_service_event` | port departure / service evidence | port evidence only |
| Marine / ALS / OFCO | `lct_voyage_register` | `LCTOperation`, ATD/ETA/ATA, voyage ID | M116/M117/M118 completeness |
| LDG / Document OCR | `marine_document_evidence` | `MarineDocument`, docHash, approval status | approved version check |
| Engineering | `stowage_lashing_stability_lift` | plans and calculation cases | human-gate and required fields |
| HSE / Permit | `ptw_jsa_tra_register` | `MarinePermit`, approval actions | valid permit window |
| Site / FMC | `site_receipt_m130` | `SiteReceipt`, MRR/POD/GRN | M130 after M117 |
| Cost | `marine_invoice_lines` | `MarineChargeEvidence` | handed off to `CONSOLIDATED-05` |

### 7.3 Link Model

```text
ShipmentUnit
  ├─ hasRoutingPattern → ShipmentRoutingPattern
  ├─ hasMilestone → M115 / M116 / M117 / M118 / M119 / M130
  ├─ hasCargoUnit → CargoUnit / BulkCargoUnit / OOGCargoUnit
  ├─ hasMarineOperation → MarineOperation / LCTOperation
  │    ├─ usesMarineAsset → LCT / Barge
  │    ├─ hasStowagePlan → StowagePlan
  │    ├─ hasLashingPlan → LashingPlan
  │    ├─ hasStabilityCase → StabilityCase
  │    ├─ hasLiftingPlan → LiftingPlan
  │    ├─ requiresPermit → MarinePermit
  │    └─ evidencedBy → MarineDocument
  ├─ hasSiteReceipt → SiteReceipt
  ├─ hasCostItem → MarineChargeEvidence / InvoiceLine
  └─ hasException → Delay / Damage / Shortage / NCR / Claim
```

---

## 8. Validation — SPARQL / RAG / Human-gate

### 8.1 SHACL Gate Summary

| Shape | Target | Rule | Severity |
|---|---|---|---|
| `MarineOperationBaseShape` | `MarineOperation` | operationId, status, ShipmentUnit link required | VIOLATION |
| `MarineRoutingPatternShape` | `MarineOperation` | valid `MarineRoutingPattern` enum | VIOLATION |
| `AGIDASMarineChainShape` | `ShipmentUnit` | AGI/DAS M130 requires M115/M116/M117 unless approved exception | VIOLATION |
| `MOSBNodeBoundaryShape` | `LocationNode` | MOSB cannot be top-level Warehouse | VIOLATION |
| `DeckPressureShape` | `StowagePosition` | deck pressure <= deck limit | VIOLATION |
| `OOGDataCompletenessShape` | `OOGCargoUnit` | dimensions, weight, COG required | VIOLATION |
| `LashingApprovalShape` | `LashingPlan` | approved/field verified before M117 | VIOLATION |
| `StabilityGateShape` | `StabilityCase` | PASS or approved condition before M117 | VIOLATION |
| `LiftingPlanShape` | `LiftingPlan` | gross lift weight, rigging gear, approval required | VIOLATION |
| `WeatherGateShape` | `MarineWeatherWindow` | weather gate not closed before M117 | WARNING / VIOLATION |
| `PermitValidityShape` | `MarinePermit` | operation time within valid permit window | VIOLATION |
| `HumanGateShape` | high-risk marine operation | MWS/engineering/HSE approval required | ZERO |

### 8.2 SPARQL — AGI/DAS Marine Chain Compliance

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
PREFIX marine: <https://hvdc-project.com/ontology/marine/>

SELECT ?unit ?dest ?pattern ?m115 ?m116 ?m117 ?m130 ?verdict
WHERE {
  ?unit hvdc:declaredDestination ?dest ;
        hvdc:hasRoutingPattern ?pattern .
  FILTER(?dest IN ("AGI", "DAS"))
  OPTIONAL { ?unit hvdc:hasMilestone ?m115 . ?m115 hvdc:milestoneCode "M115" . }
  OPTIONAL { ?unit hvdc:hasMilestone ?m116 . ?m116 hvdc:milestoneCode "M116" . }
  OPTIONAL { ?unit hvdc:hasMilestone ?m117 . ?m117 hvdc:milestoneCode "M117" . }
  OPTIONAL { ?unit hvdc:hasMilestone ?m130 . ?m130 hvdc:milestoneCode "M130" . }
  BIND(IF(BOUND(?m115) && BOUND(?m116) && BOUND(?m117) && BOUND(?m130), "PASS", "FAIL") AS ?verdict)
}
ORDER BY ?verdict ?dest
```

### 8.3 SPARQL — Deck Pressure Exception

```sparql
PREFIX marine: <https://hvdc-project.com/ontology/marine/>

SELECT ?operation ?cargo ?slot ?pressure ?limit
WHERE {
  ?operation marine:hasStowagePlan ?plan .
  ?plan marine:hasStowagePosition ?slot .
  ?slot marine:forCargo ?cargo ;
        marine:deckPressureTpm2 ?pressure ;
        marine:assignedDeckArea ?area .
  ?area marine:maxUniformLoadTpm2 ?limit .
  FILTER(?pressure > ?limit)
}
ORDER BY DESC(?pressure)
```

### 8.4 SPARQL — Missing Human Gate

```sparql
PREFIX marine: <https://hvdc-project.com/ontology/marine/>

SELECT ?operation ?cargo ?riskClass
WHERE {
  ?operation a marine:MarineOperation ;
             marine:hasCargoUnit ?cargo ;
             marine:riskClass ?riskClass .
  FILTER(?riskClass IN ("OOG", "HEAVY_LIFT", "TRANSFORMER", "CRITICAL_BULK"))
  FILTER NOT EXISTS { ?operation marine:hasApproval ?approval . ?approval marine:approvalStatus "APPROVED" . }
}
```

### 8.5 RAG Check

| Check | Evidence source | Rule |
|---|---|---|
| SOLAS / IMSBC applicability | approved project HSE / marine standard registry | use latest project-approved standard reference |
| IMDG / DG cargo | DG declaration, SDS, permit | DG cannot be loaded without segregation evidence |
| BIMCO / SUPPLYTIME charter interface | contract / charter party evidence | cost/liability interpreted outside ontology; only evidence links here |
| Port / Marine clearance | port control / agency / ALS confirmation | M117 blocked without clearance |
| Weather / tide | approved weather source / port control | AI forecast is advisory; final decision requires human gate |

### 8.6 Human-gate Matrix

| Condition | Required reviewer | Output |
|---|---|---|
| Cargo > 50.00 MT or OOG critical cargo | lifting engineer + marine superintendent | approved lifting/stowage plan |
| Transformer / critical HVDC equipment | MWS / client / HSE as applicable | approved transport method statement |
| Deck pressure near limit | marine engineer / naval architect | approved deck calculation |
| Stability case with condition | naval architect / vessel master | approved condition note |
| Weather/tide near threshold | vessel master / port control | go/no-go decision |
| OSD during load/discharge | QA/QC + logistics + site | exception + claim record |
| Permit ambiguity | HSE / authority focal | permit closure evidence |

---

## 9. Compliance

### 9.1 Standards / Authority Alignment

| Area | Control | Ontology binding |
|---|---|---|
| Marine safety | SOLAS / project marine procedure | `MarinePermit`, `MarineWeatherWindow`, `MarineEvent` |
| Bulk cargo | IMSBC / project cargo SOP | `BulkCargoUnit`, `BulkCargoOperation` |
| Dangerous goods | IMDG / SDS / DG segregation | `DangerousCargoControl`, `MarinePermit` |
| Offshore support vessel | BIMCO SUPPLYTIME 2017 contract evidence | `MarineContract`, `MarineAsset`, `MarineOperation` |
| ADNOC / ALS access | gate pass, PTW, JSA/TRA, site/marine clearance | `MarinePermit`, `ApprovalAction` |
| MWS / engineering approval | method statement, stowage/lashing/stability/lift plans | `MWSApproval`, `StowagePlan`, `LashingPlan`, `StabilityCase`, `LiftingPlan` |
| Customs / release | BOE, DO, port release | read-only evidence from `CONSOLIDATED-06/07` |
| Site receipt | MRR/POD/GRN/OSDR | handoff to `CONSOLIDATED-06` |

### 9.2 ZERO / Fail-safe Triggers

| Trigger | Reason | Required data |
|---|---|---|
| OOG/heavy cargo without dimensions, gross weight, or COG | Cannot validate deck pressure, stability, or lift | dimensions, weight, COG, lift points |
| Lashing plan missing before M117 | Sea passage securing not evidenced | approved lashing plan and inspection |
| Stability report missing before M117 | Sail-away safety not evidenced | approved stability case |
| Deck capacity missing for assigned deck | Deck pressure cannot be validated | deck area load limits |
| AGI/DAS M130 without M115/M116/M117 | MOSB/LCT chain broken | milestone evidence or approved exception |
| Expired/missing PTW/JSA/TRA/gate pass | Authority/HSE gate not closed | valid permit evidence |
| Weather/port control closed and no override | Go/no-go decision unsafe | official go/no-go approval |
| OSD found and no exception record | Claim/audit chain broken | exception/OSDR/NCR record |

---

## 10. Options ≥3

| Option | Description | Pros | Cons | Cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A. Baseline Marine Evidence Layer | Marine operation register + document evidence + M115/M116/M117 gates | 빠른 적용, 기존 Excel/MD 호환 | engineering calculation 자동화 제한 | 45,000.00 AED | Medium | 2.00 weeks |
| B. Hybrid Foundry Object + KG | Foundry Object Types + RDF/SHACL validation + dashboard KPI | traceability, validation, automation 균형 | 초기 mapping discipline 필요 | 110,000.00 AED | Medium | 5.00 weeks |
| C. Engineering-linked Marine Twin | deck/stowage/lashing/stability/lift objects with CAD/BIM hooks | deck pressure / stability / lift gate 고도화 | CAD/BIM/engineering data 품질 의존 | 220,000.00 AED | High | 10.00 weeks |
| D. Compliance-first Marine Control | PTW/JSA/TRA/MWS/HSE approval-first 운영 | 안전/감사에 강함 | 운영 KPI/최적화는 제한 | 85,000.00 AED | Low | 4.00 weeks |

**Recommended option:** Option B. Hybrid Foundry Object + KG. It gives the best balance between immediate marine control, ontology consistency, and future engineering automation.

---

## 11. Roadmap — Prepare → Pilot → Build → Operate → Scale

| Phase | Duration | Key work | KPI target | Owner |
|---|---:|---|---|---|
| Prepare | 1.00 week | marine object schema, identifier map, milestone map, document list | object coverage ≥ 90.00% | Ontology / Logistics |
| Pilot | 2.00 weeks | 1 LCT voyage + 1 OOG cargo + 1 bulk cargo validation | M115/M116/M117 completeness = 100.00% | Marine / FMC |
| Build | 3.00 weeks | Foundry object mapping, SHACL gates, SPARQL checks, dashboard panels | validation pass ≥ 98.00% | Data / Ops |
| Operate | ongoing | daily marine readiness board, exception workflow, human-gate approval | ZERO leakage = 0.00건 | Logistics / Marine |
| Scale | 4.00 weeks | CAD/BIM link, deck pressure heatmap, weather/tide gate, cost handoff | LCT utilization 80.00–85.00% | PMO / Digital |

---

## 12. Automation Notes

### 12.1 RPA / LLM / Sheets / Telegram Hooks

| Hook | Trigger | Action | Human gate |
|---|---|---|---|
| `MarineReadinessBot` | new cargo list / PL / WMS dispatch | create marine readiness checklist | approve before M115 |
| `MOSBStagingBot` | M121 or direct gate-out | open M115 staging candidate | ALS/Marine confirmation |
| `StowageGuard` | stowage plan upload | calculate deck pressure and slot conflict | marine engineer approval |
| `LashingGuard` | lashing plan upload | check WLL/angle/count/safety factor fields | engineer sign-off |
| `StabilityGuard` | stability report upload | verify case status and mandatory values | naval architect / master approval |
| `PermitGuard` | PTW/JSA/TRA/gate pass update | check validity window | HSE / authority approval |
| `WeatherTie` | planned M117 within 48.00 hrs | attach weather/tide gate status | vessel master / port control |
| `OSDGuard` | damage/shortage photo or note | create exception/NCR/claim candidate | QA/QC confirmation |
| `TelegramDigest` | daily 07:30 Asia/Dubai | send marine readiness / blocked list | read-only alert |
| `SheetsExport` | daily close | export LCT/MOSB/milestone KPI | manager review |

### 12.2 Command-ready Workflow

```text
/logi-master stowage --deep --noheatmap
/logi-master weather-tie --route MOSB-AGI --horizon 72h
/logi-master report --marine --KRsummary
```

---

## 13. QA Checklist & Assumptions

### 13.1 QA Checklist

| No | Check | PASS condition |
|---:|---|---|
| 1.00 | Master spine alignment | `CONSOLIDATED-00` remains canonical |
| 2.00 | Flow Code boundary | no marine/offshore classification by warehouse handling code |
| 3.00 | MOSB boundary | MOSB typed as `OffshoreStagingNode` / `MarineInterfaceNode` |
| 4.00 | Route separation | `ShipmentRoutingPattern` ≠ `MarineRoutingPattern` |
| 5.00 | Milestone continuity | M115/M116/M117/M130 chain complete for AGI/DAS |
| 6.00 | Deck pressure | pressure calculated and within deck limit |
| 7.00 | Lashing | approved / field verified before sail-away |
| 8.00 | Stability | PASS or approved condition before sail-away |
| 9.00 | Lift plan | OOG/heavy cargo has approved lift/rigging data |
| 10.00 | Permit | PTW/JSA/TRA/gate pass valid during operation |
| 11.00 | Weather/tide | final go/no-go has human evidence |
| 12.00 | Site handover | MRR/POD/GRN or exception linked |
| 13.00 | Cost handoff | marine charge evidence exported, CostGuard not redefined |
| 14.00 | Document evidence | docHash/version/approval status captured |
| 15.00 | PII/NDA | names allowed if operational; phone/email masked in public artifacts |

### 13.2 Assumptions

- 가정: 본 문서는 ontology/data-control layer이며, engineering calculation 결과 자체를 대체하지 않는다.
- 가정: Deck allowable load, GM limit, wind/sea-state limits, tide/ramp constraints are project/vessel-specific and must be provided as approved source data before live validation.
- 가정: MOSB laydown can be represented as `LaydownArea` or `StorageCapability`; this does not convert MOSB into a top-level warehouse.
- 가정: Cost rates, charter terms, and liability interpretation remain in contract/cost documents; this document only exports marine evidence.

---

## 14. Validation Patch Log — 5 Parallel Passes

| Pass | Review lane | Defect found | Patch applied | Result |
|---:|---|---|---|---|
| 1.00 | Master spine alignment | old document mixed marine class with end-to-end route wording | separated `ShipmentRoutingPattern` and `MarineRoutingPattern` | PASS |
| 2.00 | Flow Code boundary | legacy route-coded language appeared in marine context | confined warehouse handling to `CONSOLIDATED-02` reference only | PASS |
| 3.00 | MOSB boundary | MOSB staging could be read as warehouse-like | modeled MOSB as `OffshoreStagingNode` with `LaydownArea` capability | PASS |
| 4.00 | Engineering gate | original text described engineering objects but lacked hard gates | added deck pressure, lashing, stability, lifting, weather, permit ZERO gates | PASS |
| 5.00 | Integration / artifact hygiene | adjacent-domain handoffs needed clearer ownership | added Foundry mapping, dataset integration, handoff model, QA checklist | PASS |

---

## 15. CmdRec

- `/switch_mode LATTICE + /logi-master stowage --deep --noheatmap`
- `/switch_mode PRIME + /logi-master report --marine --KRsummary`
- `/switch_mode ORACLE + /logi-master weather-tie --route MOSB-AGI --horizon 72h`


---

# FILE: CONSOLIDATED-05-invoice-cost.md

---
title: "HVDC Invoice & Cost Management Ontology — Consolidated"
type: "ontology-design"
domain: "invoice-cost-management"
sub-domains:
  - invoice-verification
  - cost-guard
  - rate-reference
  - tariff-reference
  - route-cost-evidence
  - warehouse-cost-evidence
  - port-charge-control
  - marine-charge-control
  - dem-det-control
  - cost-allocation
  - audit-proof
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "invoice, rate reference, tariff reference, CostGuard, DEM/DET, cost allocation, and PRISM.KERNEL audit extension"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - UN-CEFACT-BSP-RDM
  - WCO-DM
  - ICC-Incoterms-2020
source_files:
  - 1_CORE-04-hvdc-invoice-cost.md
  - legacy_COST_GUARD_notes
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
cost_guard:
  delta_formula: "(DraftAmount - StandardAmount) / StandardAmount * 100.00"
  pass: "abs(delta_pct) <= 2.00"
  warn: "2.01 <= abs(delta_pct) <= 5.00"
  high: "5.01 <= abs(delta_pct) <= 10.00"
  critical: "abs(delta_pct) > 10.00"
  invoice_total_tolerance_pct: 2.00
  line_amount_tolerance: 0.01
  human_gate_aed: 100000.00
fx_policy:
  rule: "preserve_original_currency"
  allowed_currencies:
    - AED
    - USD
  conversion: "disabled unless approved FxPolicy override exists"
semantic_patch:
  - "Cost domain reads ShipmentRoutingPattern and warehouse evidence; it does not own route truth or WarehouseHandlingProfile.confirmedFlowCode."
  - "Legacy Flow Code route/cost wording migrated to costByRoutingPattern, routeBasedCostDriver, and wh_handling_cnt evidence."
  - "COST-GUARD band updated to master v2.0: PASS <= 2.00%, WARN 2.01-5.00%, HIGH 5.01-10.00%, CRITICAL > 10.00%."
  - "Original currency is preserved; FX conversion requires explicit FxPolicy override and audit proof."
  - "OFCO/port invoice mapping, LDG/OCR evidence, WMS WHP evidence, marine charge evidence, and DEM/DET clocks are separated by ownership."
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
---

# hvdc-invoice-cost · CONSOLIDATED-05

## 1. ExecSummary

`CONSOLIDATED-05`는 HVDC Logistics KG의 **invoice + rate + CostGuard extension**이다. 목적은 Draft Invoice를 `Invoice → InvoiceLine → ChargeComponent → RateRef/TariffRef → CostGuardResult → ApprovalAction`으로 정규화하여 과청구, DEM/DET 누락, 경로 기반 비용 오분류, 통화/합계 오류를 조기 차단하는 것이다.

비즈니스 임팩트는 **라인 단위 과금 검증**, **Port/WH/MOSB/Site 비용 책임 추적**, **100,000.00 AED 이상 고가 청구 Human-gate**, **PRISM.KERNEL 감사 증빙 자동화**이다. 기술 해법은 Any-key identity resolution, route/warehouse/marine evidence read-only binding, 원통화 보존, SHACL/SPARQL 검증, Foundry Action 기반 승인·반려 workflow를 결합한다.

KPI 목표는 `LineNumericIntegrity = 100.00%`, `InvoiceTotalIntegrity = 100.00%`, `RateRefCoverage ≥ 95.00%`, `CostGuardBandCoverage = 100.00%`, `Validation p95 < 5.00s`, `UnauthorizedCostLeakage = 0.00 AED`이다.

**ENG-KR one-liner:** Cost owns invoice audit and rate comparison; route truth stays in `ShipmentRoutingPattern`, warehouse handling stays in `WarehouseHandlingProfile`, and every verdict writes a PRISM proof.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-05` owns **Invoice**, **InvoiceLine**, **ChargeComponent**, **RateRef**, **TariffRef**, **CostTransaction**, **DEMDETClock**, **CostGuardResult**, **CostAllocation**, and **PRISM.KERNEL** audit proof only.
3. Program-wide shipment visibility uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`; cost may read these as cost drivers but shall not create or override them.
4. `WarehouseHandlingProfile.confirmedFlowCode` is warehouse-only and belongs to `CONSOLIDATED-02`; cost may read `WarehouseHandlingProfile.wh_handling_cnt`, dwell evidence, storage class, and WH events as evidence.
5. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`, not a top-level warehouse. MOSB-related charges are modeled as `MOSBCharge`, `MarineCharge`, `LCTCharge`, or `StagingCharge`, not as generic warehouse charges unless a specific warehouse service evidence exists.
6. LDG/OCR may provide invoice line evidence, route evidence, destination evidence, and numeric extraction confidence. Final CostGuard verdict is owned by `CostGuardResult`, not by OCR.
7. Port/OFCO records service evidence and tariff evidence. Cost compares invoice lines against `TariffRef` / `RateRef`; port does not own CostGuard verdict.
8. Currency is preserved in the original invoice/rate-table currency. FX conversion is disabled unless an approved `FxPolicy` override exists with rate, date, approver, and proof hash.
9. High-value, abnormal, or compliance-sensitive invoices are blocked until a human approval action is linked.
10. Legacy route-coded cost language is migration debt and may appear only in deprecation notes, detection queries, or patch ledgers.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-05 | Delegated / excluded |
|---|---|---|
| Invoice audit | Invoice header, line, charge component, tax, total, source document link | OCR token/table extraction in `CONSOLIDATED-03` |
| Rate comparison | Contract rate, tariff, special approval rate, lane rate, unit rate | Commercial negotiation and contract execution |
| CostGuard result | Δ%, band, verdict, blocking reason, approval requirement | Payment execution in ERP/AP |
| Route-based cost | Reads `ShipmentRoutingPattern`, route driver, journey leg evidence | Route ownership in `CONSOLIDATED-00` / operations |
| Warehouse cost | Reads WHP `wh_handling_cnt`, WH events, dwell days, storage class evidence | WHP assignment and stock truth in `CONSOLIDATED-02` |
| Port cost | OFCO/SAFEEN/ADP service evidence, tariff ref, price/cost center mapping | Port service execution truth in `CONSOLIDATED-07` |
| Marine cost | LCT/barge/MOSB charge evidence, marine event link, trip utilization | Marine operation truth and engineering approval in `CONSOLIDATED-04` |
| DEM/DET | Clock start/end, free-time, delay attribution, M92→M100 alert | Customs/DO/gate-out execution in `CONSOLIDATED-06/07` |
| Compliance cost | Incoterm responsibility, duty/tax evidence, permit blocker cost | Authority interpretation and permit approval in `CONSOLIDATED-01/06` |
| Audit proof | PRISM.KERNEL recap, artifact JSON, source hash, rule version | External legal acceptance of claim/payment |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface with Cost | Not allowed in CONSOLIDATED-05 |
|---|---|---|
| Master spine | Read `ShipmentUnit`, `RoutingPattern`, `JourneyStage`, `JourneyLeg`, `MilestoneEvent`, identifier clusters | Redefine master route dictionary or milestone sequence |
| Core infrastructure | Read `LocationNode`, port/WH/MOSB/site capability, Incoterm/cost owner anchor | Treat all routes as MOSB routes |
| Warehouse | Read `WarehouseHandlingProfile.wh_handling_cnt`, WH received/dispatch events, dwell and storage evidence | Assign `confirmedFlowCode` or interpret it as end-to-end route |
| Document/OCR | Consume invoice evidence, extracted amount/rate/qty, confidence, `routeEvidence`, `destinationEvidence`, `mosbLegIndicator` | Let OCR produce final CostGuard verdict or mutate invoice truth without approval |
| Port/OFCO | Consume `PortCall`, `ServiceEvent`, `TariffRef`, `PriceCenter`, `RotationNo`, invoice number | Own finance approval or CostGuard band |
| Marine/Bulk | Consume `MarineChargeEvidence`, `LCTTrip`, M115/M116/M117 links, utilization | Own cost band or payment decision |
| Material handling | Consume M92/M100/M110/M115/M130 timings and DEM/DET triggers | Collapse material receipt into invoice validation |
| Operations/KPI | Export audited cost facts and exception status | Replace cost audit with dashboard-only aggregation |
| Communication | Link approval emails/chats as `CommunicationEvent` / `ApprovalAction` evidence | Store unmasked phone/e-mail PII in routine cost output |

### 2.4 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Cost driven by route-coded Flow Code | `costByRoutingPattern` + `routeBasedCostDriver` | Route is read from `ShipmentRoutingPattern`; WH evidence remains read-only |
| Invoice owns or extracts warehouse handling class | `CostEvidenceAssertion` linked to WHP evidence | No cost-domain write to `confirmedFlowCode` |
| USD-only base calculation | `CurrencyPolicy.preserveOriginalCurrency = true` | Compare in original currency; FX only by approved override |
| Legacy pass tolerance above current master threshold | Master COST-GUARD band: PASS ≤ 2.00% | Updated all examples and validation logic |
| MOSB charge as warehouse charge | `MOSBCharge` / `MarineCharge` / `StagingCharge` | MOSB remains offshore staging / marine interface |
| OCR invoice verdict | `InvoiceLineEvidence` → `CostGuardResult` | OCR supplies evidence; CostGuard owns verdict |

---

## 3. Schema (RDF/OWL + SHACL 요약)

### 3.1 Ontology Layer Map

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Invoice document | `Invoice`, `InvoiceLine`, `InvoiceHeader`, `TaxLine`, `InvoiceStatus` | Header/line/total/tax truth for payable review |
| Charge taxonomy | `ChargeComponent`, `PortCharge`, `WarehouseCharge`, `MarineCharge`, `MOSBCharge`, `DEMDETCharge`, `CustomsCharge`, `TruckingCharge`, `HandlingCharge`, `InsuranceCharge` | Charge type normalization |
| Rate reference | `RateRef`, `TariffRef`, `ContractRateRef`, `MarketRateRef`, `SpecialRateRef`, `RateBasis`, `RateValidityWindow` | Standard amount source |
| Lane and service | `ODLane`, `ServiceEventRef`, `PortServiceRef`, `JourneyLegRef`, `VehicleClass`, `EquipmentClass` | Charge-to-operation join |
| Cost decision | `CostGuardResult`, `RiskBand`, `VarianceResult`, `ApprovalRequirement`, `DisputeReason` | Δ%, band, verdict, action |
| Cost accounting | `CostTransaction`, `CostAllocation`, `CostCenter`, `PriceCenter`, `CostResponsibility`, `IncotermCostRule` | AP/ERP posting and ownership |
| Time/cost clock | `DEMDETClock`, `FreeTimePolicy`, `DwellCostClock`, `DelayAttribution` | DEM/DET and dwell risk |
| Currency | `CurrencyPolicy`, `FxPolicy`, `MonetaryAmount`, `CurrencyCode` | Original-currency preservation and override control |
| Evidence | `CostEvidenceAssertion`, `DocumentEvidenceRef`, `RateEvidenceRef`, `AuditRecord`, `ProofArtifact`, `ApprovalAction` | Provenance, proof, human gate |
| KPI | `CostKPI`, `OverageMetric`, `RateCoverageMetric`, `AuditLatencyMetric` | Dashboard and SLA |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `Invoice` | `invoiceId`, `invoiceNo`, `vendor`, `issueDate`, `currency`, `invoiceTotal`, `invoiceStatus` | `hasInvoiceLine`, `linkedToShipmentUnit`, `evidencedByDocument`, `hasCostGuardResult` | Header-level audit object |
| `InvoiceLine` | `lineId`, `lineNo`, `chargeDesc`, `qty`, `uom`, `rate`, `lineAmount`, `currency` | `partOfInvoice`, `usesRateRef`, `forChargeComponent`, `linkedToOperation` | Line amount must equal `qty × rate ± 0.01` |
| `ChargeComponent` | `chargeType`, `chargeBasis`, `serviceScope`, `taxableFlag` | `mappedFromDescription`, `mappedToCostCenter` | Controlled charge taxonomy |
| `RateRef` | `rateRefId`, `sourceType`, `standardRate`, `currency`, `uom`, `validFrom`, `validTo` | `appliesToLane`, `appliesToChargeComponent`, `approvedBy` | Contract/tariff/market/special rate reference |
| `TariffRef` | `tariffId`, `authorityOrProvider`, `serviceCode`, `tariffRate`, `effectiveDate` | `appliesToPortService`, `evidencedByTariffDoc` | OFCO/SAFEEN/ADP style service tariff reference |
| `ODLane` | `laneId`, `originNode`, `destinationNode`, `viaNode`, `mode`, `vehicleClass`, `uom` | `resolvedByApprovedLaneMap`, `supportsRoutingPattern` | Lane matching and rate join |
| `CurrencyPolicy` | `policyId`, `preserveOriginalCurrency`, `allowedCurrencies`, `fxOverrideRequired` | `appliesToInvoice`, `appliesToRateRef` | Default: no conversion |
| `FxPolicy` | `fxPolicyId`, `fromCurrency`, `toCurrency`, `fxRate`, `rateDate`, `approvedBy` | `overridesCurrencyPolicy`, `hasApprovalAction` | Explicit override only |
| `CostGuardResult` | `resultId`, `deltaPct`, `band`, `verdict`, `severity`, `calculatedAt` | `forInvoiceLine`, `comparedAgainstRateRef`, `requiresApproval`, `hasProofArtifact` | Final audit result |
| `DEMDETClock` | `clockId`, `clockType`, `freeTimeHours`, `clockStart`, `clockEnd`, `billableHours` | `forShipmentUnit`, `triggeredByMilestone`, `linkedToInvoiceLine` | DEM/DET and dwell cost evidence |
| `CostAllocation` | `allocationId`, `costCenter`, `priceCenter`, `allocatedAmount`, `currency` | `allocatesInvoiceLine`, `chargedToParty` | AP/controlling view |
| `ProofArtifact` | `proofId`, `artifactType`, `ruleVersion`, `sourceHash`, `calculationHash`, `createdAt` | `provesCostGuardResult`, `wasDerivedFrom` | PRISM.KERNEL proof |

### 3.3 Controlled Vocabularies

| Vocabulary | Values |
|---|---|
| `RiskBand` | `PASS`, `WARN`, `HIGH`, `CRITICAL` |
| `Verdict` | `ACCEPTABLE`, `REVIEW_REQUIRED`, `FINANCE_APPROVAL_REQUIRED`, `REJECT`, `HOLD_FOR_EVIDENCE` |
| `RateSourceType` | `CONTRACT`, `TARIFF`, `MARKET`, `QUOTATION`, `SPECIAL_APPROVAL`, `AT_COST`, `UNKNOWN` |
| `ChargeType` | `PORT_DUES`, `CHANNEL_TRANSIT`, `PILOTAGE`, `TUG`, `PHC`, `CUSTOMS_CLEARANCE`, `TRUCKING`, `WAREHOUSE_HANDLING`, `WAREHOUSE_STORAGE`, `MOSB_STAGING`, `LCT_BARGE`, `MARINE_SUPPORT`, `DEMURRAGE`, `DETENTION`, `DUTY_TAX`, `INSURANCE`, `DOCUMENTATION`, `OTHER` |
| `CurrencyCode` | `AED`, `USD` by default; others require `FxPolicy` override |
| `InvoiceStatus` | `DRAFT`, `RECEIVED`, `EVIDENCE_LINKED`, `AUDITED`, `APPROVED`, `REJECTED`, `DISPUTED`, `PAID`, `SUPERSEDED` |
| `CostEvidenceStatus` | `MISSING`, `PROPOSED`, `LINKED`, `VALIDATED`, `REJECTED`, `OVERRIDDEN` |

### 3.4 RoutingPattern Cost Driver Matrix

| `ShipmentRoutingPattern` | Cost components expected | Evidence required | CostGuard note |
|---|---|---|---|
| `PRE_ARRIVAL` | Pre-alert, documentation, booking, estimated port cost | BL/booking/ETA evidence | No final trucking/WH/marine charge approval without operational milestone |
| `DIRECT` | Port service + direct trucking + site delivery | M92/M100/M130 or equivalent release/site evidence | No WH or MOSB charges unless exception approved |
| `WH_ONLY` | Port + trucking to WH + WH handling/storage + trucking to site | M100/M110/M120/M121/M130, WHP evidence | WH charge must link to WHP/dwell evidence |
| `MOSB_DIRECT` | Port + trucking/staging to MOSB + LCT/barge/marine + site receipt | M100/M115/M116/M117/M130 | MOSB/marine charges expected; WH charges require separate evidence |
| `WH_MOSB` | Port + WH handling/storage + WH-to-MOSB + MOSB staging + marine + site receipt | M110/M121/M115/M116/M117/M130 | Highest audit surface; split WH vs MOSB vs marine charges |
| `MIXED` | Variable | Exception record, split cargo, partial route evidence | Human review mandatory before approval |

### 3.5 Rate Basis Rules

| Rate basis | Required dimensions | Numeric rule |
|---|---|---|
| `PER_EA` | qty, unit rate | `qty × rate = amount ± 0.01` |
| `PER_TRUCK` | truck count, vehicle class, lane | `truckCount × rate = amount ± 0.01` |
| `PER_TEU` | TEU count, lane, container type | `teu × rate = amount ± 0.01` |
| `PER_CBM` | volumeCbm, storage/service type | `cbm × rate = amount ± 0.01` |
| `PER_MT` | weightMt, cargo class | `mt × rate = amount ± 0.01` |
| `PER_DAY` | billableDays, free-time policy | `days × rate = amount ± 0.01` |
| `AT_COST` | source receipt, pass-through proof | amount must match source evidence ± 0.01 |
| `LUMP_SUM` | approved quotation / work order | total must match approved amount ± 0.01 |

### 3.6 RDF/OWL Skeleton

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix prov: <http://www.w3.org/ns/prov#> .

hvdc:Invoice a owl:Class ;
  rdfs:subClassOf hvdc:CostDocument .

hvdc:InvoiceLine a owl:Class ;
  rdfs:subClassOf hvdc:CostLine .

hvdc:RateRef a owl:Class .
hvdc:TariffRef a owl:Class ;
  rdfs:subClassOf hvdc:RateRef .

hvdc:CostGuardResult a owl:Class ;
  rdfs:subClassOf hvdc:VerificationResult .

hvdc:DEMDETClock a owl:Class .
hvdc:ProofArtifact a owl:Class ;
  rdfs:subClassOf prov:Entity .

hvdc:hasInvoiceLine a owl:ObjectProperty ;
  rdfs:domain hvdc:Invoice ;
  rdfs:range hvdc:InvoiceLine .

hvdc:usesRateRef a owl:ObjectProperty ;
  rdfs:domain hvdc:InvoiceLine ;
  rdfs:range hvdc:RateRef .

hvdc:hasCostGuardResult a owl:ObjectProperty ;
  rdfs:domain hvdc:InvoiceLine ;
  rdfs:range hvdc:CostGuardResult .

hvdc:linkedToShipmentUnit a owl:ObjectProperty ;
  rdfs:domain hvdc:Invoice ;
  rdfs:range hvdc:ShipmentUnit .

hvdc:readsWarehouseEvidence a owl:ObjectProperty ;
  rdfs:domain hvdc:InvoiceLine ;
  rdfs:range hvdc:WarehouseHandlingProfile ;
  rdfs:comment "Read-only evidence link. Cost domain must not write confirmedFlowCode." .

hvdc:deltaPct a owl:DatatypeProperty ;
  rdfs:domain hvdc:CostGuardResult ;
  rdfs:range xsd:decimal .

hvdc:band a owl:DatatypeProperty ;
  rdfs:domain hvdc:CostGuardResult ;
  rdfs:range xsd:string .

hvdc:currency a owl:DatatypeProperty ;
  rdfs:range xsd:string .
```

---

## 4. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 4.1 Integration Flow

```text
Any key
  → resolveAnyKey(invoiceNo / BL / Container / DO / Rotation / SamsungRef / HVDCCode / CaseNo)
  → SameAsCluster
  → Invoice + InvoiceLine
  → ShipmentUnit / PortCall / WarehouseTask / MarineOperation / SiteReceipt link
  → RateRef / TariffRef / ApprovedLaneMap join
  → CostGuard Δ% calculation
  → CostGuardResult + PRISM.KERNEL proof
  → ApprovalAction or DisputeAction
```

### 4.2 Foundry Object and Link Mapping

| Foundry object type | Source dataset | Key fields | Link types |
|---|---|---|---|
| `Invoice` | AP invoice, OFCO invoice, vendor draft, LDG document registry | invoiceNo, vendor, issueDate, currency | `linkedToShipmentUnit`, `hasInvoiceLine`, `evidencedByDocument` |
| `InvoiceLine` | AP line table, OCR extracted table, OFCO line table | invoiceNo, lineNo, chargeDesc, amount | `partOfInvoice`, `usesRateRef`, `forChargeComponent`, `linkedToOperation` |
| `RateRef` | contract rate sheet, tariff table, approved quotation, special approval | rateRefId, rateSourceType, lane, chargeType, validity | `appliesToLane`, `approvedBy`, `evidencedByRateDoc` |
| `ODLane` | ApprovedLaneMap, RefDestinationMap, route graph | origin, destination, via, mode, uom | `supportsRoutingPattern`, `normalizesDestination` |
| `CostGuardResult` | Function output | invoiceLineId, deltaPct, band, verdict | `forInvoiceLine`, `requiresApproval`, `hasProofArtifact` |
| `CostAllocation` | ERP/Controlling table | costCenter, priceCenter, amount, currency | `allocatesInvoiceLine`, `chargedToParty` |
| `DEMDETClock` | Port/customs/DO/gate event table | M92, M100, free-time, billable hours | `forShipmentUnit`, `linkedToInvoiceLine` |
| `ProofArtifact` | Rule engine output | proofHash, ruleVersion, sourceHash | `provesCostGuardResult`, `wasDerivedFrom` |

### 4.3 Source-System Interfaces

| Source | Consumed data | Cost domain action | Write-back |
|---|---|---|---|
| ERP / AP | invoice header, line, vendor, payment status | create/update `Invoice`, `InvoiceLine`, `CostAllocation` | audit status, approval hold, dispute reason |
| Contract / Rate Master | contract rates, tariff rates, special approvals, validity | create/update `RateRef`, `TariffRef`, `RateValidityWindow` | rate coverage KPI, missing ref list |
| LDG / OCR | extracted invoice line, confidence, table cells, document hash | create `CostEvidenceAssertion`; compare only after confidence gate | discrepancy list, OCR retry request |
| Port / OFCO | `PortCall`, `ServiceEvent`, Rotation, tariff/service line | map service line to `ChargeComponent` and `TariffRef` | rate mismatch and service-evidence exception |
| WMS | WH events, dwell, WHP, stock movement evidence | validate WH handling/storage charges | WH charge evidence gap |
| ATLP / Customs / DO | BOE, DO release, gate-out timestamps | start/stop DEM/DET and customs cost checks | release blocker / DEMDET alert |
| Marine / MOSB | M115/M116/M117, LCT trip, marine service event | validate MOSB/LCT/marine charges | marine cost exception |
| Operations dashboard | route, stock, milestone, cost status | publish audited cost facts | KPI table and exception feed |

### 4.4 Cost Ownership and Responsibility

| Cost object | Owner | Evidence source | Control rule |
|---|---|---|---|
| `PortCharge` | Cost domain verdict, port service evidence | `CONSOLIDATED-07` | service line must map to `ServiceEvent` or `TariffRef` |
| `WarehouseCharge` | Cost domain verdict, WH evidence | `CONSOLIDATED-02` | WH charge requires WHP and WH event/dwell proof |
| `MOSBCharge` | Cost domain verdict, marine/MOSB evidence | `CONSOLIDATED-04/06` | AGI/DAS or MOSB leg evidence required |
| `MarineCharge` | Cost domain verdict, marine operation evidence | `CONSOLIDATED-04` | LCT/barge charge requires M115/M116/M117 or approved exception |
| `DEMDETCharge` | Cost domain verdict, release/gate timestamps | `CONSOLIDATED-06/07` | free-time policy and milestone clock must be present |
| `DutyTaxCharge` | Cost domain verdict, customs/tax evidence | `CONSOLIDATED-01/06` | BOE/value/HS/tax evidence required |

---

## 5. Validation (SPARQL/RAG/Human-gate)

### 5.1 COST-GUARD Calculation Standard

```text
DeltaPct = (DraftAmount - StandardAmount) / StandardAmount * 100.00
AbsDeltaPct = ABS(DeltaPct)

Band:
  AbsDeltaPct <= 2.00          PASS
  2.01 <= AbsDeltaPct <= 5.00  WARN
  5.01 <= AbsDeltaPct <= 10.00 HIGH
  AbsDeltaPct > 10.00          CRITICAL

Line numeric tolerance:
  ABS(qty * rate - lineAmount) <= 0.01

Invoice total tolerance:
  ABS(sum(lineAmount) - invoiceTotal) / invoiceTotal * 100.00 <= 2.00
```

### 5.2 Verdict Matrix

| Band | Δ% range | Default verdict | Action |
|---|---:|---|---|
| `PASS` | ≤ 2.00% | `ACCEPTABLE` | Auto-pass if all evidence gates pass |
| `WARN` | 2.01–5.00% | `REVIEW_REQUIRED` | Cost reviewer check; no payment hold unless repeated or high-value |
| `HIGH` | 5.01–10.00% | `FINANCE_APPROVAL_REQUIRED` | Payment hold and finance approval |
| `CRITICAL` | > 10.00% | `REJECT` or `DISPUTED` | Immediate dispute / vendor clarification |

### 5.3 Human-gate Triggers

| Trigger | Required role | Output object |
|---|---|---|
| `invoiceTotal > 100000.00 AED` | Finance approver | `ApprovalAction` |
| `band IN (HIGH, CRITICAL)` | Cost Control Lead + Finance | `ApprovalAction` or `DisputeAction` |
| rate reference missing | Cost Control Lead | `RateRefException` |
| FX override requested | Finance approver | `FxPolicy` + proof |
| AGI/DAS marine charge without M115/M116/M117 evidence | Marine Lead + Site Logistics | `MarineCostException` |
| WH charge without WHP/WH event evidence | Warehouse Manager | `WarehouseCostException` |
| permit/customs/tax evidence missing | Compliance Lead | `ComplianceCostHold` |
| OCR confidence below threshold | Document controller | `OCRRetryTask` |

### 5.4 SHACL — Invoice Line Numeric Integrity

```turtle
@prefix hvdc: <http://samsung.com/project-logistics#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .

hvdc:InvoiceLineNumericShape a sh:NodeShape ;
  sh:targetClass hvdc:InvoiceLine ;
  sh:property [ sh:path hvdc:qty ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:rate ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ; sh:minCount 1 ] ;
  sh:property [ sh:path hvdc:lineAmount ; sh:datatype xsd:decimal ; sh:minInclusive 0.00 ; sh:minCount 1 ] ;
  sh:sparql [
    sh:message "COST-GUARD: InvoiceLine lineAmount must equal qty * rate within 0.01." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:qty ?qty ; hvdc:rate ?rate ; hvdc:lineAmount ?amount .
        BIND(ABS((?qty * ?rate) - ?amount) AS ?delta)
        FILTER(?delta > 0.01)
      }
    """ ;
  ] .
```

### 5.5 SHACL — Invoice Total Integrity

```turtle
hvdc:InvoiceTotalShape a sh:NodeShape ;
  sh:targetClass hvdc:Invoice ;
  sh:sparql [
    sh:message "COST-GUARD: Sum of lineAmount must match invoiceTotal within 2.00%." ;
    sh:select """
      PREFIX hvdc: <http://samsung.com/project-logistics#>
      SELECT $this WHERE {
        $this hvdc:invoiceTotal ?total .
        {
          SELECT $this (SUM(?lineAmount) AS ?sumLine) WHERE {
            $this hvdc:hasInvoiceLine ?line .
            ?line hvdc:lineAmount ?lineAmount .
          } GROUP BY $this
        }
        BIND(ABS(?sumLine - ?total) / ?total * 100.00 AS ?deltaPct)
        FILTER(?deltaPct > 2.00)
      }
    """ ;
  ] .
```

### 5.6 SHACL — CostGuard Band Assignment

```turtle
hvdc:CostGuardBandShape a sh:NodeShape ;
  sh:targetClass hvdc:CostGuardResult ;
  sh:property [
    sh:path hvdc:band ;
    sh:in ("PASS" "WARN" "HIGH" "CRITICAL") ;
    sh:minCount 1 ;
  ] ;
  sh:property [
    sh:path hvdc:deltaPct ;
    sh:datatype xsd:decimal ;
    sh:minCount 1 ;
  ] .
```

### 5.7 SPARQL — Missing Rate Reference

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?invoice ?line ?chargeDesc ?amount
WHERE {
  ?invoice hvdc:hasInvoiceLine ?line .
  ?line hvdc:chargeDesc ?chargeDesc ; hvdc:lineAmount ?amount .
  FILTER NOT EXISTS { ?line hvdc:usesRateRef ?rateRef . }
}
```

### 5.8 SPARQL — MOSB/Marine Charge Without Route Evidence

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?invoice ?line ?unit ?pattern
WHERE {
  ?invoice hvdc:hasInvoiceLine ?line ; hvdc:linkedToShipmentUnit ?unit .
  ?line hvdc:forChargeComponent ?charge .
  ?charge hvdc:chargeType ?chargeType .
  ?unit hvdc:hasRoutingPattern ?pattern .
  FILTER(?chargeType IN ("MOSB_STAGING", "LCT_BARGE", "MARINE_SUPPORT"))
  FILTER(?pattern NOT IN ("MOSB_DIRECT", "WH_MOSB", "MIXED"))
}
```

### 5.9 SPARQL — WH Charge Without WH Evidence

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?invoice ?line ?unit
WHERE {
  ?invoice hvdc:hasInvoiceLine ?line ; hvdc:linkedToShipmentUnit ?unit .
  ?line hvdc:forChargeComponent ?charge .
  ?charge hvdc:chargeType ?chargeType .
  FILTER(?chargeType IN ("WAREHOUSE_HANDLING", "WAREHOUSE_STORAGE"))
  FILTER NOT EXISTS { ?line hvdc:readsWarehouseEvidence ?whp . }
  FILTER NOT EXISTS { ?unit hvdc:hasMilestone ?m110 . ?m110 hvdc:milestoneCode "M110" . }
}
```

### 5.10 SPARQL — DEM/DET Clock Risk After DO Release

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?unit ?m92Actual ?m100Actual ?billableHours
WHERE {
  ?unit hvdc:hasMilestone ?m92 .
  ?m92 hvdc:milestoneCode "M92" ; hvdc:actualDt ?m92Actual .
  OPTIONAL {
    ?unit hvdc:hasMilestone ?m100 .
    ?m100 hvdc:milestoneCode "M100" ; hvdc:actualDt ?m100Actual .
  }
  OPTIONAL { ?unit hvdc:hasDEMDETClock ?clock . ?clock hvdc:billableHours ?billableHours . }
  FILTER(!BOUND(?m100Actual) || ?billableHours > 0.00)
}
```

### 5.11 SPARQL — High-value Approval Requirement

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?invoice ?total ?currency
WHERE {
  ?invoice a hvdc:Invoice ; hvdc:invoiceTotal ?total ; hvdc:currency ?currency .
  FILTER(?currency = "AED" && ?total > 100000.00)
  FILTER NOT EXISTS { ?invoice hvdc:hasApprovalAction ?approval . }
}
```

### 5.12 PRISM.KERNEL Audit Proof

PRISM.KERNEL is the fixed audit trace format. It stores a 5-line recap plus a JSON proof artifact.

```json
{
  "prismKernelVersion": "2.0-final",
  "recap": [
    "Invoice: INV-2026-001 | Vendor: DSV Logistics | Currency: AED | Total: 98000.00",
    "Line: 10 | Charge: TRUCKING | Lane: Khalifa Port -> MIR | Qty: 4.00 | UOM: TRUCK",
    "DraftAmount: 9800.00 | StandardAmount: 10000.00 | DeltaPct: -2.00 | Band: PASS",
    "Evidence: RateRef=RATE-AED-TRK-001 | RoutingPattern=DIRECT | FxOverride=false",
    "Verdict: ACCEPTABLE | ProofHash: sha256:example-pass-20260427"
  ],
  "artifact": {
    "invoiceId": "INV-2026-001",
    "invoiceLineId": "INV-2026-001-L10",
    "currency": "AED",
    "draftAmount": 9800.00,
    "standardAmount": 10000.00,
    "deltaPct": -2.00,
    "band": "PASS",
    "verdict": "ACCEPTABLE",
    "calculation": "(9800.00 - 10000.00) / 10000.00 * 100.00 = -2.00",
    "ruleVersion": "COST-GUARD-2.0-final",
    "createdAt": "2026-04-27T00:00:00+04:00"
  }
}
```

### 5.13 RAG and Human-gate Control

| Trigger | RAG / evidence refresh | Human-gate |
|---|---|---|
| rate table changed | Contract/rate master re-ingest; new `RateRef` validity window | Cost Control Lead |
| Incoterm/cost owner mismatch | PO/contract evidence refresh | Finance + Contract owner |
| MOIAT/FANR/DCD/ADNOC permit cost blocker | latest approved SOP / authority evidence / project permit register | Compliance Lead |
| DEM/DET claim | DO release, gate-out, terminal free-time proof | Logistics + Finance |
| marine/MOSB charge | M115/M116/M117, LCT trip, marine approval evidence | Marine Lead |
| OCR confidence below KPI | LDG retry or manual document validation | Document Controller |

---

## 6. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 6.1 Compliance Principles

1. Incoterms are **cost/risk responsibility controls**, not route classifiers.
2. Customs, MOIAT, FANR, DCD/DG, ADNOC/CICPA, and site access requirements are modeled as `RegulatoryRequirement` / `PermitDocument` / `ApprovalAction` evidence; cost audit consumes these only when they affect charge responsibility or payment blocking.
3. BOE, DO, GatePass, permit, SDS, marine PTW, and site receiving evidence remain documentary/transactional proof and are not collapsed into invoice objects.
4. Tax/VAT values are validated against invoice evidence and the project `TaxPolicy`; the cost ontology does not hardcode external tax law as operational truth.
5. Any authority rule or tariff table that may have changed after `2026-04-27` requires RAG refresh before production approval.

### 6.2 Incoterms Control

| Incoterm impact | Cost validation |
|---|---|
| Delivery obligation | Invoice charge owner must match PO/contract responsibility |
| Risk transfer | Damage/claim charge must align with risk transfer point |
| Local charges | Port/WH/customs/marine charges must be mapped to buyer/seller responsibility |
| Insurance/freight | Freight and insurance lines require Incoterm-specific owner check |

```sparql
PREFIX hvdc: <http://samsung.com/project-logistics#>
SELECT ?shipment ?term ?invoice ?chargedTo ?expectedOwner
WHERE {
  ?shipment hvdc:hasIncoterm ?term ; hvdc:hasInvoice ?invoice .
  ?term hvdc:localCostOwner ?expectedOwner .
  ?invoice hvdc:chargedTo ?chargedTo .
  FILTER(?chargedTo != ?expectedOwner)
}
```

### 6.3 Authority and Permit Cost Controls

| Compliance area | Evidence consumed by cost | Blocking rule |
|---|---|---|
| Customs / WCO-aligned data | BOE, HS, origin, declared value, duty/tax line | duty/tax charge blocked if BOE/value evidence missing |
| MOIAT product conformity | CoC/exemption or project compliance note | regulated-product release cost blocked if evidence missing |
| FANR controlled material | licence/permit/compliance approval | movement/storage charge blocked until compliance approval |
| DCD / DG | SDS, DG declaration, segregation/storage evidence | DG surcharge/storage charge blocked without DG evidence |
| ADNOC / CICPA / access | gate pass/access approval | access/gate/marine/site charge blocked if pass missing/expired |
| Marine / PTW / FRA | PTW, FRA, weather window, lashing/marine approval | LCT/marine charge blocked without M115/M116/M117 evidence or exception |

---

## 7. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Scope | Pros | Cons | Cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A. Audit Lite | Line numeric integrity + invoice total + manual rate lookup | Fast deployment; low system dependency | Limited route/WH/marine validation | 40.00 hrs | Medium: manual rate drift | 5.00 days |
| B. KG CostGuard | Full RDF/OWL object model + RateRef + CostGuardResult + PRISM proof | Strong traceability and repeatable approval | Requires rate master and identity map | 120.00 hrs | Medium: initial mapping gaps | 15.00 days |
| C. Foundry Integrated | Foundry Object/Link/Action + ERP/WMS/Port/LDG integration | Operationally deployable; automated holds and dashboards | Higher integration load | 240.00 hrs | Medium-High: source-system readiness | 30.00 days |
| D. Predictive Cost Control | CostGuard + anomaly model + DEM/DET forecast + TG hooks | Early overage prediction and exception management | Needs historical cost/event quality | 320.00 hrs | High: model governance and drift | 45.00 days |

**Recommended path:** Option B as baseline, then Option C for production, then Option D after stable audited history is available.

---

## 8. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Work package | Output | KPI / acceptance |
|---|---|---|---|
| Prepare | Normalize invoice headers, line tables, charge taxonomy, rate-source registry, currency policy | `Invoice`, `InvoiceLine`, `RateRef`, `ChargeComponent` draft schema | `SchemaCoverage ≥ 95.00%`, `PIILeakage = 0.00건` |
| Pilot | Run 1.00-month invoice sample through line numeric check, rate join, banding | CostGuard pilot report + PRISM proof | `LineNumericIntegrity = 100.00%`, `RateJoinCoverage ≥ 85.00%` |
| Build | Connect Foundry objects, links, Functions, Actions; integrate ERP/LDG/OFCO/WMS evidence | Production-ready CostGuard pipeline | `RateRefCoverage ≥ 95.00%`, `Validation p95 < 5.00s` |
| Operate | Apply approval holds, dispute workflow, DEM/DET alerts, monthly audit pack | Daily/weekly cost exception digest | `UnauthorizedCostLeakage = 0.00 AED`, `ApprovalSLA ≤ 48.00 hrs` |
| Scale | Add anomaly scoring, route-cost benchmarking, vendor performance, trend dashboard | Cost intelligence layer | `OverageΔReduction ≥ 10.00%`, `DEMDETBaselineReduction ≥ 10.00%` |

---

## 9. Automation notes (RPA/LLM/Sheets/TG hooks)

### 9.1 Automation Map

| Automation | Trigger | Function / action | Output |
|---|---|---|---|
| `InvoiceIngestGuard` | new invoice document or AP record | parse header/line, attach document evidence | `Invoice` + `InvoiceLine` |
| `RateJoinBot` | invoice line created | match `ChargeComponent + ODLane + UOM + validity` to `RateRef` | rate join / missing ref exception |
| `CostGuardFunction` | rate join complete | compute Δ%, band, verdict | `CostGuardResult` |
| `CurrencyLockGuard` | currency mismatch or FX request | block conversion unless `FxPolicy` exists | `CurrencyException` |
| `PortTariffGuard` | OFCO/SAFEEN/ADP service line | validate `ServiceEvent` + `TariffRef` | port cost exception |
| `WHChargeGuard` | WH handling/storage charge | require WHP/WH event/dwell evidence | WH cost exception |
| `MarineChargeGuard` | MOSB/LCT/marine charge | require M115/M116/M117 or approved exception | marine cost exception |
| `DEMDETBot` | M92 exists and M100 delayed or invoice has DEM/DET | compute clock and billable hours | DEM/DET risk alert |
| `HighValueGate` | invoiceTotal > 100000.00 AED | create finance approval task | `ApprovalAction` required |
| `PRISMProofBot` | any CostGuard verdict | generate proof JSON and hash | `ProofArtifact` |
| `DailyCostDigest` | 08:00 Asia/Dubai daily | summarize WARN/HIGH/CRITICAL and missing evidence | TG/Sheet/Workshop view |

### 9.2 ZERO Fail-safe

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Input gate | invoiceNo/vendor/currency/lineAmount missing | wrong entity or wrong payable | corrected invoice header/line table | block audit |
| Rate gate | no matching `RateRef` or tariff evidence | false over/under billing | contract/tariff/quotation proof | create `RateRefException` |
| Currency gate | invoice and rate currency differ without `FxPolicy` | false Δ% | approved FX policy and date | block CostGuard verdict |
| Evidence gate | WH/MOSB/marine charge lacks operational evidence | payment for unperformed service | milestone/event/proof document | hold invoice line |
| Compliance gate | permit/tax/customs blocker unresolved | regulatory or client dispute | BOE/permit/access proof | compliance review |

---

## 10. QA checklist & Assumptions(가정:)

### 10.1 QA Checklist

| Check | PASS 기준 |
|---|---|
| Master spine alignment | `Invoice`, `InvoiceLine`, `RateRef`, `CostGuardResult`, `DEMDETClock` match `CONSOLIDATED-00` cost layer |
| Flow boundary | cost does not own or assign `WarehouseHandlingProfile.confirmedFlowCode` |
| Route boundary | cost reads `ShipmentRoutingPattern`; it does not create route truth |
| Warehouse evidence | WH charges link to WHP/WH event/dwell evidence where applicable |
| MOSB classification | MOSB charges use offshore staging/marine classes, not top-level warehouse semantics |
| OCR boundary | LDG/OCR evidence is consumed, not treated as final verdict |
| Port boundary | OFCO/port lines link to `PortCall`, `ServiceEvent`, `TariffRef`; CostGuard owns verdict |
| Numeric integrity | `EA × Rate = Amount ± 0.01` and `Σ lines = invoiceTotal ± 2.00%` |
| CostGuard band | every audited line has Δ%, band, verdict, and proof |
| Currency | original currency preserved; FX override has approval if used |
| Human-gate | >100000.00 AED, HIGH, CRITICAL, missing evidence, and compliance blockers require approval |
| PII | contact phone/e-mail not embedded in routine audit proof |
| KPI format | numeric targets and thresholds use 2.00-decimal format |

### 10.2 Assumptions(가정:)

- `CONSOLIDATED-00-master-ontology.md` remains the semantic authority for route, milestone, evidence, and cost layer boundaries.
- Contract/rate master and tariff tables are approved project evidence and are synchronized before CostGuard execution.
- `RateRef` validity windows are maintained by the cost/rate owner; expired rates are not used unless a `SpecialRateRef` approval exists.
- Currency conversion is not applied by default. Cross-currency comparison requires `FxPolicy` approval.
- Authority-specific requirements, tariff notices, VAT/tax interpretation, and permit lead times must be refreshed by RAG/current SOP before production payment approval.
- `FMC_OrgChart_Data.json` PII is not embedded in this document or routine proof outputs.

---

## 11. Patch Ledger — 5x Corpus Compatibility Review

### 11.1 Parallel Review Lanes

| Pass | Review lane | Corpus checked | Finding | Patch applied | Status |
|---:|---|---|---|---|---|
| 1.00 | Master spine / AGENTS | `CONSOLIDATED-00`, `AGENTS.md`, review note | Cost must read route + WH evidence and must not own WH classification | Rewrote governance, frontmatter, cost-domain rule, route/WH ownership language | PASS |
| 2.00 | WH/OCR boundary | `CONSOLIDATED-02`, `CONSOLIDATED-03`, `CONSOLIDATED-06` | WHP starts at M110/M111; OCR provides evidence only; material layer uses milestones | Added read-only WHP evidence, OCR handoff, M92/M100 and M110/M121 controls | PASS |
| 3.00 | Port/marine/ops boundary | `CONSOLIDATED-04`, `CONSOLIDATED-07`, `CONSOLIDATED-09` | OFCO and marine events provide service evidence; dashboards consume cost facts only | Added PortTariffGuard, MarineChargeGuard, CostAllocation, ops export model | PASS |
| 4.00 | Validation/compliance | `CONSOLIDATED-01`, `CONSOLIDATED-06`, `CONSOLIDATED-07`, master validation rules | Need master COST-GUARD bands, SHACL/SPARQL gates, high-value approval, RAG hooks | Updated bands to 2.00/5.00/10.00, added human-gate and compliance controls | PASS |
| 5.00 | Artifact hygiene | full md corpus + semantic digital twin blueprint | Need v2.0-final frontmatter, checked_against, no canonical legacy leakage, downloadable final | Added 5-pass patch ledger, QA checklist, assumptions, CmdRec, and final file write | PASS |

### 11.2 Final Patch Summary

- `version` updated from `consolidated-1.1` to `2.0-final`.
- `extension_of` updated to `hvdc-master-ontology-v2.0-final`.
- `sub-domains` migrated away from legacy route-code framing into invoice/rate/tariff/route-cost-evidence/WH-cost-evidence/DEM-DET controls.
- `CostGuard` bands corrected to master v2.0 threshold: PASS ≤ 2.00%, WARN 2.01–5.00%, HIGH 5.01–10.00%, CRITICAL > 10.00%.
- USD-only calculation wording removed. Original currency preservation and explicit `FxPolicy` override added.
- Route cost matrix now reads `ShipmentRoutingPattern`; it does not own route state.
- Warehouse charge validation reads `WarehouseHandlingProfile.wh_handling_cnt` and WH events; it never assigns `confirmedFlowCode`.
- MOSB charges separated into `MOSBCharge`, `MarineCharge`, `LCTCharge`, and `StagingCharge`.
- Port/OFCO service evidence mapped to `TariffRef`, `ServiceEvent`, `PriceCenter`, and `CostCenter` without port-owned CostGuard verdict.
- PRISM.KERNEL retained and upgraded to include `ruleVersion`, original currency, source hash, calculation hash, and approval state.

### 11.3 Legacy Term Detection Query

Use this query in repository QA. Hits are allowed only inside explicit deprecation/patch sections.

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

---

## 12. CmdRec

```text
/switch_mode COST-GUARD + /logi-master invoice-audit --deep --AEDonly
```

```text
/logi-master invoice-audit --deep --KRsummary --highlight-mismatch
```

```text
/logi-master cert-chk --deep --KRsummary
```


---

# FILE: CONSOLIDATED-06-material-handling.md

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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
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


---

# FILE: CONSOLIDATED-07-port-operations.md

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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
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


---

# FILE: CONSOLIDATED-08-communication.md

---
title: "HVDC Communication Evidence Layer Ontology — Consolidated"
type: "evidence-layer-extension"
domain: "communication"
sub-domains:
  - email
  - chat
  - approval-evidence
  - escalation-control
  - sla-clock
  - audit-proof
  - pii-redaction
version: "2.0-final"
date: "2026-04-27"
timezone: "Asia/Dubai"
status: "active"
spine_ref: "CONSOLIDATED-00-master-ontology.md"
extension_of: "hvdc-master-ontology-v2.0-final"
canonical_role: "email/chat evidence, approval action, audit record, and communication SLA extension"
layer: "evidence"
owner: "HVDC Logistics Ontology Working Set"
standards:
  - RDF
  - OWL
  - SHACL
  - SPARQL
  - JSON-LD
  - PROV-O
  - OWL-Time
  - SKOS
  - DQV
  - GS1-EPCIS-CBV
source_files:
  - 2_EXT-03-hvdc-comm-email.md
  - 2_EXT-04-hvdc-comm-chat.md
  - FMC_OrgChart_Data.json
checked_against:
  - CONSOLIDATED-00-master-ontology.md
  - CONSOLIDATED-01-core-framework-infra.md
  - CONSOLIDATED-02-warehouse-flow.md
  - CONSOLIDATED-03-document-ocr.md
  - CONSOLIDATED-04-barge-bulk-cargo.md
  - CONSOLIDATED-05-invoice-cost.md
  - CONSOLIDATED-06-material-handling.md
  - CONSOLIDATED-07-port-operations.md
  - CONSOLIDATED-09-operations.md
  - AGENTS.md
  - HVDC Logistics Ontology Review.txt
  - Palantir 온톨로지 기반 물류 자동화.pdf
validation_passes: 5
semantic_patch:
  - "Communication is evidence-only and does not redefine ShipmentUnit, RoutingPattern, JourneyStage, JourneyLeg, MilestoneEvent, WarehouseTask, PortCall, CostGuardResult, or SiteReceipt."
  - "Core connection is restricted to CommunicationEvent, ApprovalAction, AuditRecord, EvidenceAttachment, and EscalationRecord."
  - "WarehouseHandlingProfile.confirmedFlowCode remains warehouse-only; communication may cite the approved WHP identifier as evidence only."
  - "MOSB is represented as OffshoreStagingNode / MarineInterfaceNode evidence; communication shall not classify MOSB as Warehouse."
  - "PII fields from contact data are masked before register write; raw tel/e-mail never appears in the evidence graph."
  - "A message can propose, request, or approve; only an authorized Foundry Action can mutate operational truth."
  - "Email drafting defaults to EmailDraftMode with mandatory sct_ontology grounding; sct_ontology is invoked or surfaced even when the user does not explicitly request it."
  - "A hard-marked EmailActionCard is mandatory after the ontology review and is not an operational ActionRequest unless the user asks to register or write an action."
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
---

# hvdc-communication · CONSOLIDATED-08

## 1. ExecSummary

`CONSOLIDATED-08`은 HVDC Logistics KG의 **communication evidence layer**이다. 이메일, WhatsApp, Telegram, Teams, meeting note, phone memo, approval memo를 `CommunicationEvent`, `ApprovalAction`, `AuditRecord`, `EvidenceAttachment`, `EscalationRecord`로 정규화한다.

비즈니스 임팩트는 **승인 누락 0.00건**, **SLA breach 조기 경보**, **OSD/NCR/DEM-DET/permit blocker 증빙 자동 연결**, **PII 마스킹 기반 감사 추적성 확보**이다. 기술 해법은 PROV-O provenance, OWL-Time SLA clock, SHACL evidence gate, SPARQL unresolved-action query, Foundry Action write-back guard를 결합한다.

KPI 목표는 `CommunicationLinkCoverage ≥ 95.00%`, `ApprovalEvidenceCompleteness ≥ 98.00%`, `PIILeakage = 0.00건`, `ActionClosureSLA ≥ 90.00%`, `Validation p95 < 5.00s`이다.

Email reply drafting은 별도 `EmailDraftMode`로 처리하되, 모든 답장 작성 요청은 먼저 `sct_ontology` 검토를 자동 수행하거나 화면에 노출한다. 그 다음 하드마킹된 `EmailActionCard`와 이메일 본문 초안을 분리해서 출력한다.

**ENG-KR one-liner:** Communication is proof, not operational truth; messages attach evidence, while authorized Foundry Actions update the logistics twin.

---

## 2. Governance & Scope Boundary

### 2.1 Master Governance Rule

1. `CONSOLIDATED-00-master-ontology.md` is the canonical semantic spine.
2. `CONSOLIDATED-08` is an **evidence layer**, not a core logistics execution layer.
3. This document owns `CommunicationEvent`, `MessageThread`, `ApprovalAction`, `AuditRecord`, `EvidenceAttachment`, `EscalationRecord`, `SLAClock`, and `PIIRedactionRecord`.
4. Program-wide shipment state uses `RoutingPattern`, `JourneyStage`, `JourneyLeg`, and `MilestoneEvent`; communication may refer to these as target objects only.
5. Warehouse handling classification remains on `WarehouseHandlingProfile.confirmedFlowCode`; communication cannot create, assign, or infer it.
6. `MOSB` is an `OffshoreStagingNode` / `MarineInterfaceNode`; communication can store MOSB-related approval evidence but cannot type MOSB as a warehouse.
7. A message cannot mutate operational transactions. It can create an evidence assertion, approval request, escalation, or work queue item. A separate authorized Foundry Action performs any transaction update.
8. Email drafting requests are `EmailDraftMode` by default and must automatically invoke or surface `sct_ontology` grounding.
9. Email draft output must include a separate ontology review, then a hard-marked `EmailActionCard`, then the draft body. The card is a presentation/triage artifact, not a KG `ActionRequest`.
10. Explicit user triggers such as `CostGuard`, compliance judgement, evidence pack creation, or Action registration open deeper ontology/action lanes, but baseline `sct_ontology` review is always required.

### 2.2 Included vs Delegated Scope

| Scope item | Included in CONSOLIDATED-08 | Delegated / excluded |
|---|---|---|
| Email and chat evidence | Message, thread, sender role, receiver role, timestamp, channel, attachment hash | Mailbox administration and raw server retention policy |
| Approval action | Approve / reject / request revision / acknowledge / escalate | Final operational mutation in target domain |
| Audit proof | Provenance, reviewer, evidence pointer, action rationale, before/after object references | Legal opinion and commercial settlement |
| SLA clock | Due time, response time, breach status, escalation tier | Project schedule critical path ownership |
| PII redaction | Masked phone/e-mail, role-only exposure, hash-only identity join | HR master data and raw contact vault |
| Evidence linking | Link to ShipmentUnit, Document, PortCall, CustomsEntry, WarehouseTask, SiteReceipt, Invoice, Exception | Redefining those classes |
| RAG summary | Summarize discussion and cite evidence objects | Treating LLM summary as source-of-truth |
| Email drafting | mandatory `sct_ontology` review + `EmailActionCard` + email body draft in `EmailDraftMode` | Converting the card to KG action without explicit instruction |

### 2.3 Domain Boundary Crosswalk

| Domain | Allowed interface from communication | Not allowed in CONSOLIDATED-08 |
|---|---|---|
| Master spine | Attach `CommunicationEvent`, `ApprovalAction`, `AuditRecord` to `ShipmentUnit`, `MilestoneEvent`, `Exception` | Redefine identity policy or milestone dictionary |
| Infrastructure | Reference `Party`, `RoleAssignment`, `LocationNode`, `RegulatoryRequirement` | Create authority decision as fact without evidence |
| Warehouse | Attach approval evidence to M110/M111/M120/M121 or WHP reviewer action | Own or calculate WH handling class |
| Document/OCR | Link extracted document discrepancy to message thread and reviewer decision | Replace LDG `VerificationResult` |
| Marine/Bulk | Link MWS/stability/lashing/lift approval evidence | Replace engineering approval or marine execution truth |
| Cost | Attach invoice clarification and approval record to `CostGuardResult` | Own `RateRef`, cost band, payment verdict |
| Material handling | Attach approval/evidence to release, site receipt, OSD/NCR/Claim | Mutate custody chain directly |
| Port | Attach port service clarification and OFCO/SAFEEN/ADP discussion evidence | Own `PortCall` or `TariffRef` truth |
| Operations | Feed unresolved action counts, SLA KPI, and exception communication metrics | Define route or stock analytics |

### 2.4 Evidence-only Write Guard

```text
Message received        -> CommunicationEvent + MessageThread + EvidenceAttachment
Reviewer decision       -> ApprovalAction + AuditRecord
Operational update      -> Authorized Foundry Action in target ontology
Audit closure           -> AuditRecord links beforeObjectRef, afterObjectRef, evidenceHash
```

### 2.4.1 Email Drafting Guard

```text
User says "답장 작성하라" / "draft reply" / "메일 회신 작성"
  -> EmailDraftMode
  -> Invoke or surface sct_ontology
  -> Emit hard-marked EmailActionCard
  -> Emit email draft
  -> DO NOT create ActionRequest unless user explicitly says register/write/escalate
```

Mandatory card:

```text
[EMAIL_ACTION_CARD]
mode: EMAIL_DRAFT
ontology_use: AUTO_SCT_ONTOLOGY_REQUIRED | EXPLICIT_DEEP_ONTOLOGY
reply_stance: ACKNOWLEDGE | HOLD | REQUEST_INFO | ESCALATE | APPROVE | REJECT
blocking_inputs: <comma-separated missing inputs or NONE>
next_action: <single operational next step>
send_status: DRAFT_READY | HOLD_FOR_REVIEW
[/EMAIL_ACTION_CARD]
```

For mixed requests, use two separated lanes:

```text
Ontology lane  -> mandatory sct_ontology review
Email lane     -> EmailActionCard + Draft
Action lane    -> ActionRequest only if explicitly requested
```


### 2.5 Legacy Migration Rules

| Legacy wording / pattern | Canonical replacement | Patch action |
|---|---|---|
| Message as direct logistics state | `CommunicationEvent` evidence attached to target object | Remove direct state mutation language |
| Chat command directly updates shipment | `ActionRequest` + authorized Foundry Action | Add reviewer and audit proof |
| Email-derived route status | `RouteEvidenceAssertion` or `ApprovalAction.targetObjectRef` | Route owner remains core shipment layer |
| Message-derived WH handling class | `CommunicationEvidence` on WHP decision | WHP owner remains `CONSOLIDATED-02` |
| Raw phone/e-mail in graph | `maskedContactRef`, `roleId`, `hashKey` | Redact before write |
| Email draft skips `sct_ontology` | `EmailDraftMode` with `ontology_use = AUTO_SCT_ONTOLOGY_REQUIRED` | Run or surface baseline ontology review before drafting |
| Draft action card treated as KG action | `EmailActionCard` presentation artifact | Convert to `ActionRequest` only on explicit register/write/escalate request |

---

## 3. Schema (RDF/OWL + SHACL 요약)

### 3.1 Ontology Layer Map

| Layer | Class / vocabulary | Purpose |
|---|---|---|
| Message | `CommunicationEvent`, `EmailMessage`, `ChatMessage`, `MeetingNote`, `PhoneMemo` | Raw or normalized communication event |
| Thread | `MessageThread`, `ConversationCluster`, `ThreadParticipant` | Multi-message discussion and participants |
| Intent | `CommunicationIntent`, `RequestIntent`, `ApprovalIntent`, `EscalationIntent`, `ClarificationIntent` | Semantic intent classification |
| Action | `ActionRequest`, `ApprovalAction`, `RevisionRequest`, `EscalationRecord`, `AcknowledgementAction` | Human decision and workflow action |
| Drafting | `EmailDraftArtifact`, `EmailActionCard` | Reply composition output after mandatory ontology grounding |
| Evidence | `EvidenceAttachment`, `AttachmentManifest`, `DocumentPointer`, `ObjectPointer`, `AuditRecord` | Provenance and proof artifact |
| SLA | `SLAClock`, `ResponseWindow`, `BreachRecord`, `EscalationTier` | Response and closure timing |
| Security | `PIIRedactionRecord`, `AccessControlTag`, `SensitivityLabel` | Privacy and access guard |
| Quality | `CommunicationKPI`, `EvidenceLinkMetric`, `ClosureMetric`, `PIILeakageMetric` | KPI observations |

### 3.2 Core Classes

| Class | Required properties | Key relations | Notes |
|---|---|---|---|
| `CommunicationEvent` | `eventId`, `channel`, `eventTime`, `normalizedSubject`, `language`, `sourceSystem` | `belongsToThread`, `hasParticipant`, `hasIntent`, `referencesObject`, `hasEvidenceAttachment` | Root evidence object |
| `EmailMessage` | `messageId`, `sentAt`, `receivedAt`, `subjectHash`, `bodyHash` | `subClassOf CommunicationEvent` | Body is optionally stored outside KG |
| `EmailDraftArtifact` | `draftId`, `draftPurpose`, `createdAt`, `language`, `sourceThreadHash` | `draftsReplyTo`, `hasEmailActionCard` | Draft-only artifact; not sent evidence until registered |
| `EmailActionCard` | `mode`, `ontologyUse`, `replyStance`, `blockingInputs`, `nextAction`, `sendStatus` | `summarizesDraft`, optional `mayOpenActionRequest` | Hard-marked output card; not a KG action by default |
| `ChatMessage` | `messageId`, `channelProvider`, `sentAt`, `messageHash` | `subClassOf CommunicationEvent` | WhatsApp/Telegram/Teams normalized |
| `MessageThread` | `threadId`, `threadStatus`, `openedAt`, `lastActivityAt` | `hasMessage`, `hasOpenAction`, `referencesObject` | One thread can reference many shipments |
| `CommunicationIntent` | `intentCode`, `confidence`, `classifierVersion` | `classifiedFrom`, `requiresActionType` | LLM/RAG intent is evidence, not truth |
| `ActionRequest` | `requestId`, `requestType`, `dueAt`, `priority`, `requestedByRole` | `targetObjectRef`, `assignedToRole`, `openedByMessage` | Creates queue item |
| `ApprovalAction` | `actionId`, `decision`, `decisionAt`, `actorRole`, `reasonCode` | `approvesRequest`, `targetObjectRef`, `supportedByEvidence`, `writesAuditRecord` | Required for human-gated updates |
| `AuditRecord` | `auditId`, `createdAt`, `actorRole`, `actionType`, `evidenceHash` | `wasDerivedFrom`, `beforeObjectRef`, `afterObjectRef` | PROV-O anchor |
| `EvidenceAttachment` | `attachmentId`, `artifactType`, `artifactHash`, `sourceUriHash`, `mimeType` | `attachedToMessage`, `pointsToDocument`, `pointsToObject` | Raw file may live in document store |
| `SLAClock` | `clockId`, `slaType`, `startAt`, `dueAt`, `closedAt`, `breachStatus` | `forThread`, `forActionRequest`, `escalatesTo` | OWL-Time compatible |
| `PIIRedactionRecord` | `redactionId`, `fieldType`, `redactedAt`, `maskPolicy`, `hashKey` | `protectsParticipant`, `appliesToMessage` | No raw phone/e-mail in KG |

### 3.3 Object Properties

| Property | Domain → Range | Cardinality | Purpose |
|---|---|---:|---|
| `belongsToThread` | `CommunicationEvent → MessageThread` | 1..1 | Thread grouping |
| `referencesObject` | `CommunicationEvent → ShipmentUnit/Document/Invoice/Exception/etc.` | 0..n | Evidence target |
| `openedByMessage` | `ActionRequest → CommunicationEvent` | 1..1 | Request provenance |
| `supportedByEvidence` | `ApprovalAction → EvidenceAttachment/CommunicationEvent/Document` | 1..n | Decision proof |
| `writesAuditRecord` | `ApprovalAction → AuditRecord` | 1..1 | Audit closure |
| `protectsParticipant` | `PIIRedactionRecord → ThreadParticipant` | 1..1 | PII protection |
| `escalatesTo` | `SLAClock → EscalationRecord` | 0..1 | Breach action |
| `linkedToVerification` | `CommunicationEvent → VerificationResult` | 0..n | LDG discrepancy discussion |

### 3.4 Data Properties

| Property | Range | Rule |
|---|---|---|
| `channel` | SKOS enum | `EMAIL`, `WHATSAPP`, `TELEGRAM`, `TEAMS`, `MEETING`, `PHONE_MEMO`, `SYSTEM_ALERT` |
| `eventTime` | `xsd:dateTime` | ISO-8601 with Asia/Dubai operational timezone or UTC offset |
| `language` | SKOS enum | `EN`, `KO`, `AR`, `MIXED`, `UNKNOWN` |
| `decision` | SKOS enum | `APPROVED`, `REJECTED`, `REVISION_REQUIRED`, `ACKNOWLEDGED`, `ESCALATED` |
| `breachStatus` | SKOS enum | `OPEN`, `ON_TIME`, `WARN`, `BREACHED`, `WAIVED` |
| `sensitivityLabel` | SKOS enum | `PUBLIC`, `PROJECT_INTERNAL`, `CONFIDENTIAL`, `PII_MASKED`, `LEGAL_HOLD` |
| `confidence` | decimal | `0.00 <= confidence <= 1.00` |
| `evidenceHash` | string | Required for every `AuditRecord` |
| `ontologyUse` | SKOS enum | `AUTO_SCT_ONTOLOGY_REQUIRED` for all email draft requests unless deeper explicit ontology lane is requested |
| `sendStatus` | SKOS enum | `DRAFT_READY` or `HOLD_FOR_REVIEW` |

### 3.5 Core SHACL Shapes (요약)

```turtle
comm:CommunicationEventShape a sh:NodeShape ;
  sh:targetClass comm:CommunicationEvent ;
  sh:property [ sh:path comm:eventId ; sh:minCount 1 ; sh:maxCount 1 ] ;
  sh:property [ sh:path comm:channel ; sh:minCount 1 ; sh:in ( "EMAIL" "WHATSAPP" "TELEGRAM" "TEAMS" "MEETING" "PHONE_MEMO" "SYSTEM_ALERT" ) ] ;
  sh:property [ sh:path comm:eventTime ; sh:minCount 1 ; sh:datatype xsd:dateTime ] ;
  sh:property [ sh:path comm:belongsToThread ; sh:minCount 1 ; sh:maxCount 1 ] .

comm:ApprovalActionShape a sh:NodeShape ;
  sh:targetClass comm:ApprovalAction ;
  sh:property [ sh:path comm:decision ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:decisionAt ; sh:minCount 1 ; sh:datatype xsd:dateTime ] ;
  sh:property [ sh:path comm:actorRole ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:targetObjectRef ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:supportedByEvidence ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:writesAuditRecord ; sh:minCount 1 ; sh:maxCount 1 ] .

comm:PIIRedactionShape a sh:NodeShape ;
  sh:targetClass comm:ThreadParticipant ;
  sh:property [ sh:path comm:maskedContactRef ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:rawContactValue ; sh:maxCount 0 ] .

comm:EmailActionCardShape a sh:NodeShape ;
  sh:targetClass comm:EmailActionCard ;
  sh:property [ sh:path comm:mode ; sh:hasValue "EMAIL_DRAFT" ] ;
  sh:property [ sh:path comm:ontologyUse ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:replyStance ; sh:minCount 1 ] ;
  sh:property [ sh:path comm:sendStatus ; sh:minCount 1 ] .
```

### 3.6 Foundry Object Model

| Foundry object | Ontology class | Primary key | Links |
|---|---|---|---|
| `COMMUNICATION_EVENT` | `CommunicationEvent` | `eventId` | Thread, target object, attachment |
| `MESSAGE_THREAD` | `MessageThread` | `threadId` | Messages, action requests, target objects |
| `ACTION_REQUEST` | `ActionRequest` | `requestId` | Thread, assignee role, due time |
| `APPROVAL_ACTION` | `ApprovalAction` | `actionId` | Request, evidence, audit record |
| `AUDIT_RECORD` | `AuditRecord` | `auditId` | Actor role, source evidence, before/after refs |
| `SLA_CLOCK` | `SLAClock` | `clockId` | Thread/action, escalation |
| `PII_REDACTION_RECORD` | `PIIRedactionRecord` | `redactionId` | Participant, mask policy |

---

## 4. Integration (Foundry↔ERP/WMS/ATLP/Invoice)

### 4.1 Source System Interfaces

| Source | Input | Output in CONSOLIDATED-08 | Ownership boundary |
|---|---|---|---|
| Gmail / Outlook | Message metadata, subject/body hash, attachment manifest | `EmailMessage`, `EvidenceAttachment`, `MessageThread` | Does not create shipment truth |
| Email draft UI | User-provided email text and draft request | `EmailDraftArtifact`, `EmailActionCard` | Always calls or surfaces `sct_ontology`; does not create KG action |
| WhatsApp / Telegram / Teams | Message ID, group, timestamp, sender role, content hash | `ChatMessage`, `CommunicationIntent`, `SLAClock` | Does not create approved action |
| Document store / LDG | Document pointer, VerificationResult, OCR discrepancy | `DocumentPointer`, `linkedToVerification` | LDG owns document validation |
| ERP / WMS / ATLP | Object identifiers and status references | `ObjectPointer` to ShipmentUnit/WarehouseTask/ReleaseOrder | Target system owns transaction |
| Invoice / CostGuard | Invoice clarification and approval request | `ActionRequest`, `ApprovalAction`, `AuditRecord` | Cost domain owns verdict |
| Port / OFCO | Port service clarification and release evidence discussion | `CommunicationEvent` linked to `PortCall`/`ServiceEvent` | Port domain owns port event |
| FMC Org Chart | Role, site, designation, masked contact reference | `ThreadParticipant`, `RoleAssignment` | Raw PII remains outside KG |

### 4.2 Canonical Ingestion Pipeline

```text
1. Channel collector
   - Collect message metadata, timestamp, channel, sender role, recipient role.
   - Store raw body only in approved secure store if policy permits.

2. Redaction gate
   - Replace phone/e-mail with masked references.
   - Preserve role, site, designation, organization unit, and hash join key.

3. Thread resolver
   - Join by message thread id, subject hash, object key, date window, and sender/receiver role.
   - Do not merge unrelated shipments only because the same person appears.

4. Intent classifier
   - Classify as INFO, REQUEST, APPROVAL, ESCALATION, CLARIFICATION, CLAIM, COST_QUERY.
   - Store classifier version and confidence.

5. Object linker
   - Resolve HVDC_CODE, BL, DO, BOE, invoice, container, package, PO, site, warehouse, exception, claim.
   - Attach unresolved keys to `UnresolvedEvidenceKey`.

6. Action gate
   - Create `ActionRequest` if action is required.
   - Create `ApprovalAction` only when actor role is authorized and evidence exists.

7. Audit write
   - Write `AuditRecord` with evidence hash, before/after object references, and reviewer role.
```

### 4.3 Any-key Resolution Inputs

| Key type | Communication evidence field | Target class |
|---|---|---|
| `HVDC_CODE` | `mentionedKey` / `subjectKey` | `ShipmentUnit`, `Package`, `MaterialMaster` |
| BL / Container / Seal | `mentionedTransportKey` | `BillOfLadingDocument`, `Container`, `JourneyLeg` |
| BOE / DO / Permit | `mentionedReleaseKey` | `CustomsEntry`, `ReleaseOrder`, `PermitDocument` |
| Invoice / OFCO / SAFEEN / ADP | `mentionedCostKey` | `Invoice`, `InvoiceLine`, `PortServiceEvent` |
| Warehouse / Bin / Yard | `mentionedWarehouseKey` | `WarehouseTask`, `StockSnapshot`, `WarehouseHandlingProfile` |
| Site / AGI / DAS / MIR / SHU | `mentionedSiteKey` | `SiteReceipt`, `LocationNode` |
| OSDR / NCR / Claim | `mentionedExceptionKey` | `Exception`, `NCR`, `Claim` |

### 4.4 Target Object Update Guard

| Message content | Allowed automatic output | Requires human-gated action |
|---|---|---|
| "Please approve DO release" | `ActionRequest(type=RELEASE_APPROVAL)` | Yes, before release update |
| "Invoice line is accepted" | `ApprovalAction(decision=APPROVED)` if actor is authorized | Yes, before CostGuard closure |
| "Cargo is damaged" | `CommunicationEvent` + `ActionRequest(type=OSD_INSPECTION)` | Yes, before NCR/Claim creation |
| "AGI delivery confirmed" | `CommunicationEvent` with site delivery evidence | Yes, before M130 site receipt if no system event |
| "Storage class confirmed" | Evidence attached to WHP review | Yes, WHP remains warehouse-owned |
| "답장 작성하라" / "draft reply" | mandatory `sct_ontology` review + `EmailActionCard` + draft body | No, unless user explicitly requests action registration |
| "sct_ontology 사용 후 답장" | `OntologyReview` + `EmailActionCard(ontologyUse=EXPLICIT_DEEP_ONTOLOGY)` + draft | Yes, if review result is used for operational mutation |

### 4.5 Email Drafting Output Contract

Email draft outputs must be structurally predictable:

1. `OntologyReview` first through `sct_ontology`.
2. `EmailActionCard` second.
3. `Draft` third.
4. `Notes` optional and limited to missing input or send-risk.
5. Ontology verdict labels must stay outside the outbound email body; use `reply_stance` and `send_status` inside the draft card.

Example for a hold/request-info reply:

```text
[EMAIL_ACTION_CARD]
mode: EMAIL_DRAFT
ontology_use: AUTO_SCT_ONTOLOGY_REQUIRED
reply_stance: HOLD
blocking_inputs: HE forwarder PIC, booking availability, OEM receiving readiness, cargo dims/wt/condition
next_action: request HE forwarder and OEM receiving confirmation before shipment decision
send_status: DRAFT_READY
[/EMAIL_ACTION_CARD]
```

---

## 5. Validation (SPARQL/RAG/Human-gate)

### 5.0 Prompt-level Gate — Email Drafting

| Rule ID | Trigger | Required output | Block condition |
|---|---|---|---|
| `COMM-DRAFT-001` | reply/draft email request | mandatory `sct_ontology` review + `EmailActionCard` + draft | missing ontology review or hard-marked card |
| `COMM-DRAFT-002` | reply/draft email request | `ontology_use = AUTO_SCT_ONTOLOGY_REQUIRED` | `sct_ontology` not invoked or not surfaced |
| `COMM-DRAFT-003` | draft + ontology output | separated Ontology lane and Email lane | ontology verdict mixed into email body |
| `COMM-DRAFT-004` | action/register request absent | no KG `ActionRequest` write | card converted into operational action without instruction |

### 5.1 SPARQL — Communication must not own logistics state

```sparql
SELECT ?msg ?badPredicate WHERE {
  ?msg a comm:CommunicationEvent .
  ?msg ?badPredicate ?value .
  FILTER(?badPredicate IN (
    hvdc:hasRoutingPattern,
    hvdc:hasJourneyStage,
    hvdc:hasMilestoneStatus,
    wh:confirmedFlowCode,
    cost:costGuardVerdict
  ))
}
```

Expected result: **0.00 rows**. Communication can reference target objects, not set these fields.

### 5.2 SPARQL — ApprovalAction completeness

```sparql
SELECT ?action WHERE {
  ?action a comm:ApprovalAction .
  FILTER NOT EXISTS { ?action comm:decision ?decision }
  UNION
  { FILTER NOT EXISTS { ?action comm:actorRole ?role } }
  UNION
  { FILTER NOT EXISTS { ?action comm:targetObjectRef ?target } }
  UNION
  { FILTER NOT EXISTS { ?action comm:supportedByEvidence ?evidence } }
  UNION
  { FILTER NOT EXISTS { ?action comm:writesAuditRecord ?audit } }
}
```

Expected result: **0.00 rows** before any operational mutation.

### 5.3 SPARQL — Open action breach list

```sparql
SELECT ?request ?dueAt ?thread ?target WHERE {
  ?request a comm:ActionRequest ;
           comm:dueAt ?dueAt ;
           comm:requestStatus "OPEN" ;
           comm:targetObjectRef ?target ;
           comm:openedByMessage ?msg .
  ?msg comm:belongsToThread ?thread .
  FILTER(?dueAt < NOW())
}
ORDER BY ?dueAt
```

Use for SLA escalation and daily action backlog.

### 5.4 SPARQL — PII leakage candidate

```sparql
SELECT ?node ?field WHERE {
  ?node ?field ?value .
  FILTER(?field IN (comm:rawPhone, comm:rawEmail, comm:rawContactValue))
}
```

Expected result: **0.00 rows**. Raw contact values remain in secured source systems or are masked before register write.

### 5.5 SPARQL — Evidence link completeness

```sparql
SELECT ?thread WHERE {
  ?thread a comm:MessageThread .
  FILTER NOT EXISTS { ?thread comm:referencesObject ?target }
  FILTER NOT EXISTS { ?thread comm:triageStatus "GENERAL_BROADCAST" }
}
```

Expected result: **0.00 unresolved operational threads**.

### 5.6 RAG Check Rules

| RAG item | Trigger | Required action |
|---|---|---|
| Regulation or authority instruction | MOIAT/FANR/DCD/ADNOC/CICPA/Port authority wording appears | Attach source document and action date |
| Commercial approval | Cost, rate, invoice, DEM/DET, variation wording appears | Link to CostGuard / Contract / ApprovalAction |
| Operational exception | Delay, damage, shortage, OSD, NCR, claim wording appears | Open `ActionRequest` and evidence pack |
| Site delivery | AGI/DAS/MIR/SHU arrival wording appears | Link to milestone candidate and require material gate |
| Privacy | Phone/e-mail/person contact fields appear | Apply `PIIRedactionRecord` before KG write |

### 5.7 Human-gate

Human-gate is mandatory when any of the following is true:

| Condition | Gate |
|---|---|
| Cost exposure > 100,000.00 AED | Cost owner approval |
| Regulatory statement or permit validity affects release | Compliance owner approval |
| M130 site receipt is inferred from communication only | Material handling owner approval |
| WH handling class is referenced in communication | Warehouse owner approval |
| Marine stability/lashing/lift approval is discussed | Marine / engineering owner approval |
| Raw contact PII is detected | Data protection owner approval before write |

---

## 6. Compliance (Incoterms/MOIAT/FANR/DCD/ADNOC)

### 6.1 Compliance Role

`CONSOLIDATED-08` does not decide compliance. It stores evidence of communication, approvals, and audit lineage for compliance-related decisions.

| Compliance area | Communication evidence | Target owner |
|---|---|---|
| Incoterms 2020 | Cost/risk responsibility clarification, handover discussion | Contract / Cost domain |
| MOIAT / Customs | BOE, certificate, exemption, clearance discussion | Customs / Document domain |
| FANR | Nuclear/radiation-related certificate discussion | Compliance owner |
| DCD / DG | Dangerous goods permit and safety note discussion | Warehouse / HSE / Document domain |
| ADNOC / CICPA / GatePass | Site/offshore access and gate pass approval evidence | Material handling / Site / Port |
| Port authority / SAFEEN / ADP | Service clarification, berth/gate discussion | Port operations |
| Data privacy | PII masking and access control records | Data governance |

### 6.2 Access and Privacy Guard

1. Raw body text is optional. The evidence graph can operate using `bodyHash`, `summary`, `attachmentHash`, and `object pointers`.
2. Phone/e-mail from the organization chart is masked before any register write.
3. Names may be retained only as role-linked participant labels when project policy permits.
4. Sensitive threads receive `sensitivityLabel = CONFIDENTIAL` or `PII_MASKED`.
5. Legal hold threads cannot be auto-archived without a retention policy action.

### 6.3 Audit Retention

| Evidence type | Retention recommendation | Notes |
|---|---|---|
| ApprovalAction | Project closeout + contractual retention | Required for release/cost/compliance decisions |
| AuditRecord | Same as target transaction | Keep before/after refs |
| MessageThread summary | Project closeout + audit window | Keep hash and role metadata |
| Raw message body | Policy-controlled secure store | Not required inside KG |
| Attachment manifest | Same as referenced document | Hash required |
| PII redaction log | Same as communication register | No raw PII |

---

## 7. Options ≥3 (Pros/Cons/Cost/Risk/Time)

| Option | Scope | Pros | Cons | Est. cost | Risk | Time |
|---|---|---|---|---:|---|---:|
| A | Evidence Register Lite | Fast deployment; thread/action visibility; low integration complexity | Limited automation; manual target linking | 30,000.00 AED | MEDIUM | 2.00 weeks |
| B | Approval & SLA Control | ApprovalAction, SLAClock, escalation, audit proof | Needs role model and access policy | 75,000.00 AED | MEDIUM | 4.00 weeks |
| C | RAG Evidence Copilot | Summaries, intent classification, unresolved action extraction | Requires model governance and confidence gating | 120,000.00 AED | HIGH | 6.00 weeks |
| D | Integrated Communication Twin | Full linkage to LDG, CostGuard, WMS, Port, Material, Ops dashboards | Highest governance and integration load | 180,000.00 AED | HIGH | 8.00 weeks |

Recommended baseline: **Option B** for immediate approval/SLA control. Scale to **Option D** when target object links and PII redaction policy are stable.

---

## 8. Roadmap (Prepare→Pilot→Build→Operate→Scale + KPI)

| Phase | Duration | Work package | KPI |
|---|---:|---|---|
| Prepare | 1.00 week | Define channel list, role dictionary, PII mask policy, evidence target classes | Role coverage ≥ 95.00% |
| Pilot | 2.00 weeks | Ingest sample email/chat threads, build `MessageThread`, link to 3.00 target domains | Link precision ≥ 90.00% |
| Build | 3.00 weeks | Add `ActionRequest`, `ApprovalAction`, `SLAClock`, `AuditRecord`, SHACL gates | Approval completeness ≥ 98.00% |
| Operate | Ongoing | Daily unresolved-action report, SLA breach alert, audit pack creation | SLA breach resolution ≤ 24.00 hrs |
| Scale | 4.00 weeks | Add RAG summarization, cross-domain evidence search, Ops dashboard hooks | CommunicationLinkCoverage ≥ 95.00% |

---

## 9. Automation notes (RPA/LLM/Sheets/TG hooks)

### 9.1 Foundry Functions

| Function | Input | Output | Guard |
|---|---|---|---|
| `normalizeMessageEvent` | raw channel payload | `CommunicationEvent` | PII redaction pre-check |
| `resolveMessageThread` | message metadata + target keys | `MessageThread` | Avoid cross-shipment false merge |
| `classifyCommunicationIntent` | message summary + attachments | `CommunicationIntent` | Store confidence and classifier version |
| `openActionRequest` | intent + target object | `ActionRequest` | Require target or triage status |
| `recordApprovalAction` | request + actor role + decision | `ApprovalAction` + `AuditRecord` | Check authorization |
| `createEvidencePack` | thread + target object + attachments | `ProofArtifact` | Hash required |
| `emailDraftGuard` | email text + draft request | mandatory `sct_ontology` review + `EmailActionCard` + draft | `AUTO_SCT_ONTOLOGY_REQUIRED`; no KG action unless explicit trigger |
| `escalateBreachedSLA` | SLAClock | `EscalationRecord` | Business hours calendar |

### 9.2 RPA / Messaging Hooks

```text
/email-intake --source=gmail --mask-pii --link-anykey
/chat-intake --source=telegram --mask-pii --open-actions
/approval-gate --target=<objectKey> --evidence=<threadId> --human-gate
/sla-watch --domain=release,cost,claim --threshold=24.00h
```

### 9.3 LLM Guardrail

| LLM output | Allowed use | Not allowed |
|---|---|---|
| Thread summary | Analyst review, audit pack prefill | Operational fact without evidence |
| Intent classification | Queue routing | Approval decision |
| Key extraction | Candidate object linking | Identity resolution without confidence |
| Risk note | Escalation hint | Regulatory interpretation as fact |
| Email draft | Reply composition after mandatory ontology review | KG mutation or ontology verdict inside outbound email body |
| EmailActionCard | Draft triage and send-readiness | Replacement for `ActionRequest` without explicit user instruction |

### 9.4 Sheets / Dashboard Hooks

| Sheet / dashboard | Metric | Source |
|---|---|---|
| Daily Action Backlog | Open actions by domain and owner role | `ActionRequest` |
| Approval Completeness | ApprovalAction with evidence and audit | `ApprovalAction` |
| SLA Breach Heatmap | Breach count by domain/site | `SLAClock` |
| Exception Communication | OSD/NCR/Claim threads by age | `MessageThread` + `Exception` |
| PII Compliance | Redaction coverage and leakage count | `PIIRedactionRecord` |

---

## 10. QA checklist & Assumptions

### 10.1 QA Checklist

| # | Check | Expected |
|---:|---|---|
| 1.00 | `CommunicationEvent` has channel and eventTime | PASS |
| 2.00 | Every actionable thread has `ActionRequest` or triage status | PASS |
| 3.00 | `ApprovalAction` has actorRole, decision, target, evidence, audit | PASS |
| 4.00 | No communication object writes route, milestone, cost verdict, or WH handling class directly | PASS |
| 5.00 | Raw phone/e-mail fields are absent from KG | PASS |
| 6.00 | Every attachment has artifact hash | PASS |
| 7.00 | Every audit record has evidence hash | PASS |
| 8.00 | RAG summaries are marked as summaries, not evidence truth | PASS |
| 9.00 | MOSB is described as offshore staging / marine interface only | PASS |
| 10.00 | SLAClock closedAt cannot precede startAt | PASS |
| 11.00 | High-value cost approval has Human-gate | PASS |
| 12.00 | Regulatory statements require current source/evidence link | PASS |
| 13.00 | Communication object links to at least one target or `GENERAL_BROADCAST` triage | PASS |
| 14.00 | Names from FMC role data do not expose phone/e-mail | PASS |
| 15.00 | LLM confidence is stored for intent classification | PASS |
| 16.00 | Authorized actor role is checked before approval mutation | PASS |
| 17.00 | Cross-domain target objects are referenced, not redefined | PASS |
| 18.00 | Validation p95 remains < 5.00s for indexed keys | PASS |
| 19.00 | All operational updates write before/after object refs | PASS |
| 20.00 | ZERO/Failsafe table used when evidence is insufficient | PASS |

### 10.2 Assumptions

| Assumption | Impact | Mitigation |
|---|---|---|
| Email/chat channels can provide stable message IDs or hashes | Thread resolution depends on stable keys | Store channel-specific fallback hash |
| Project role dictionary is approved | Actor authorization depends on role | Keep role approval as Prepare-phase gate |
| Raw message storage policy may differ by channel | KG may not store bodies | Use body hash + summary + attachment manifest |
| FMC contact data contains PII | Raw contact values cannot be written to KG | Apply mask and hash before register write |
| RAG/LLM confidence may be imperfect | Wrong target linkage risk | Human-gate low-confidence action |

### 10.3 ZERO / Fail-safe

| 단계 | 이유 | 위험 | 요청데이터 | 다음조치 |
|---|---|---|---|---|
| Evidence write paused | Target object unresolved or PII unmasked | False linkage / privacy leakage | HVDC key, source message hash, role confirmation | Run `resolveAnyKey` and redaction gate |
| Approval action paused | Actor role not authorized | Unauthorized transaction update | RoleAssignment and approval matrix | Human-gate by domain owner |
| Compliance summary paused | Current authority source missing | Wrong release decision | Permit/SOP/source document and action date | RAG verification and compliance review |
| Operational mutation paused | Message is only a request or claim | Transaction truth contamination | Approved action and evidence pack | Foundry Action after reviewer approval |

---

## 11. CmdRec

```text
/switch_mode LATTICE + /logi-master report --deep --KRsummary
/logi-master cert-chk --deep --KRsummary
/logi-master kpi-dash --communication-sla --noheatmap
```


---

# FILE: CONSOLIDATED-09-operations.md

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
final_validation_rounds: 5
final_validation_status: "PASS"
final_validated_date: "2026-04-27"
final_patch_bundle: "HVDC_Logistics_Ontology_FINAL_5x_2026-04-27"
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


---

# FILE: AGENTS.md

# AGENTS.md

Repository-wide instructions for AI agents working in this HVDC Logistics Ontology / Knowledge Graph repository.

This repository is an **end-to-end HVDC project logistics control model**, not a warehouse-only model. Work across procurement interface, packing, port / terminal, customs, marine / MOSB, warehouse, site delivery, inspection, exception, claim, and cost.

## 1. Scope and precedence

1. This file applies repository-wide unless a deeper `AGENTS.md` overrides it for a subtree.
2. `CONSOLIDATED-00-master-ontology.md` is the **canonical semantic spine**.
3. `CONSOLIDATED-08-communication.md` is an **Evidence Layer** document, not a Core Master Model document.
4. If any extension conflicts with `CONSOLIDATED-00`, follow `CONSOLIDATED-00` and patch the extension. Do not promote extension-local legacy semantics into the master spine.
5. Treat legacy route-based Flow Code language as **migration debt**, not design authority.

## 2. Current repository state

The repository contains a correct master-spine direction plus mixed legacy content in some extensions.

- Canonical authority: `CONSOLIDATED-00-master-ontology.md`
- Evidence-only extension: `CONSOLIDATED-08-communication.md`
- Files that often require semantic migration attention: `CONSOLIDATED-02`, `03`, `04`, `05`, `07`, `09`
- `CONSOLIDATED-06` may contain both newer aligned patterns and older legacy fragments depending on section/example

When editing any extension, actively remove legacy Flow Code route semantics instead of preserving them.

## 3. Mission of every change

Every change should improve one or more of these without breaking the others:

- ontology-based data model
- knowledge graph traversal
- identifier-based traceability from any entry point
- AI-ready operational logic
- SHACL / SPARQL validation
- dashboard / automation / visibility readiness

## 4. Non-negotiable semantic rules

### 4.1 Flow Code boundary

`Flow Code` is a **warehouse-handling classification only**.

Allowed owner:
- `WarehouseHandlingProfile.confirmedFlowCode`

Do **not** use Flow Code as:
- shipment route classification
- port routing decision
- customs stage
- document-extracted operational status
- invoice / cost ownership field
- marine / offshore routing class
- operations KPI bucket for end-to-end route logic

If you see any of the following in new or edited content, treat them as invalid unless explicitly deprecated and migrated:

- `assignedFlowCode`
- `extractedFlowCode`
- `costByFlowCode`
- `hasLogisticsFlowCode` used as end-to-end route status
- `Flow Code 0~5` used to describe Port → WH → MOSB → Site journey semantics

### 4.2 Shipment visibility model

Program-wide shipment visibility must use:

- `RoutingPattern`
- `JourneyStage`
- `MilestoneEvent`
- `JourneyLeg`

Do not replace milestone logic, route logic, site delivery logic, or customs logic with Flow Code.

### 4.3 MOSB classification

`MOSB` is an **Offshore Staging / Marine Interface Node**.

It is **not** a Warehouse in the top-level ontology.

You may model optional storage capability at MOSB, but do not collapse MOSB into Warehouse semantics.

### 4.4 Evidence versus ownership

Documents, port records, and cost records may provide **evidence** about routing or handling. They do not own warehouse Flow Code.

Examples:
- Port may record `plannedRoutingPattern`, not `assignedFlowCode`
- OCR may extract `routeEvidence`, not `extractedFlowCode`
- Cost may read `routeBasedCostDriver` and warehouse evidence, not own Flow Code
- Marine / bulk may use `MarineRoutingPattern`, not `Flow Code 3/4/5`


### 4.5 Email drafting mode boundary

Email reply generation is `EmailDraftMode` with mandatory `sct_ontology` grounding.

Default rule:
- A request such as "답장 작성하라", "reply", "draft email", "메일 회신 작성", or "회신 문안 작성" must produce an email draft and a hard-marked `EmailActionCard`.
- The agent must use `sct_ontology` even when the user does not explicitly ask for it.
- The agent may draft the email after ontology grounding, but it must not mix ontology verdict labels into the outbound email body.

Explicit trigger rule:
- Baseline `sct_ontology` review is mandatory for every email draft request.
- Outputs must be separated into `OntologyReview`, `EmailActionCard`, and `Draft`.

Hard-marked action card rule:
- Every email draft output must include this compact card immediately after `OntologyReview`, using the exact bracket markers:

```text
[EMAIL_ACTION_CARD]
mode: EMAIL_DRAFT
ontology_use: AUTO_SCT_ONTOLOGY_REQUIRED | EXPLICIT_DEEP_ONTOLOGY
reply_stance: ACKNOWLEDGE | HOLD | REQUEST_INFO | ESCALATE | APPROVE | REJECT
blocking_inputs: <comma-separated missing inputs or NONE>
next_action: <single operational next step>
send_status: DRAFT_READY | HOLD_FOR_REVIEW
[/EMAIL_ACTION_CARD]
```

- `EmailActionCard` is a presentation and triage artifact. It is **not** a KG `ActionRequest` and must not mutate `ShipmentUnit`, `MilestoneEvent`, `WarehouseHandlingProfile`, `CostGuardResult`, or any transaction object.
- Only an explicit user instruction to register/write/escalate converts the card or ontology review into `ActionRequest` / `ApprovalAction` evidence under `CONSOLIDATED-08`.

## 5. Canonical vocabulary by domain

### 5.1 Core shipment / logistics
Use:
- `ShipmentRoutingPattern`: `PRE_ARRIVAL`, `DIRECT`, `WH_ONLY`, `MOSB_DIRECT`, `WH_MOSB`, `MIXED`
- `JourneyStage`
- `MilestoneEvent`
- `JourneyLeg`
- `DeliveryStatus`
- `SiteReceiptStatus`

### 5.2 Port (`CONSOLIDATED-07`)
Use:
- `plannedRoutingPattern`
- `declaredDestination`
- `offshoreTransitRequired`
- `importRoutingDecision`

Do not use:
- `assignedFlowCode`
- `Port-Assigned Flow Code`

### 5.3 Document / OCR (`CONSOLIDATED-03`)
Use:
- `routeEvidence`
- `destinationEvidence`
- `mosbLegIndicator`

Do not use:
- `extractedFlowCode`
- document-owned Flow Code assignment

### 5.4 Cost (`CONSOLIDATED-05`)
Use:
- `costByRoutingPattern`
- `routeBasedCostDriver`
- `WarehouseHandlingProfile.wh_handling_cnt`

Do not use:
- `costByFlowCode`
- prose that says “Flow Code directly impacts cost” as canonical model language

### 5.5 Marine / Bulk (`CONSOLIDATED-04`)
Use:
- `MarineRoutingPattern`
- `offshoreDeliveryPattern`
- `MOSB staging`
- `LCT / barge leg`

Do not use:
- `Flow Code 3/4/5` as marine classification language

### 5.6 Warehouse (`CONSOLIDATED-02`)
Use:
- `WarehouseHandlingProfile`
- `confirmedFlowCode`
- `flowConfirmationStatus`
- `wh_handling_cnt`
- warehouse receiving / put-away / storage / picking / staging / dispatch

Keep warehouse Flow Code inside warehouse-internal operational logic.

### 5.7 Operations / KPI (`CONSOLIDATED-09`)
Use:
- route-type analytics
- milestone analytics
- warehouse KPI
- stock KPI
- cost KPI

Do not use:
- end-to-end route analytics framed as Flow Code analytics

## 6. Required data separation

Keep these layers distinct in prose, TTL, SHACL, SPARQL, tables, and examples:

- **Master Data**: Project, Package, PO, Vendor, MaterialMaster, Port, Terminal, Warehouse, Site, EquipmentResource
- **Transaction Data**: Shipment, ShipmentLeg, PortCall, CustomsEntry, ReleaseOrder, Delivery, WarehouseTask, SiteReceipt
- **Document Data**: CI, PL, BL, BOE, DO, Permit, MRR, MRI, ITP, MAR, MRS, MIS, POD, GRN, OSDR
- **Event Data**: MilestoneEvent, InspectionEvent, WarehouseEvent, MarineEvent
- **Exception Data**: Delay, Damage, Shortage, NCR, Claim
- **Cost Data**: Invoice, InvoiceLine, Duty, DEM/DET, PortCharge, WarehouseCharge, MarineCharge
- **Evidence Data**: AuditRecord, CommunicationEvent, ApprovalAction

Do not collapse:
- `CustomsEntry` into `BOE document`
- `ReleaseOrder` into `DO document`
- `SiteReceipt` into `MRR` / `OSDR document`

## 7. Identity and key policy

Follow the rule:

**One internal object, many external identifiers.**

Every design and example should support an identifier pattern with at least:

- `identifierScheme`
- `identifierValue`
- `normalizedValue`
- `sourceSystem`
- `isPrimary`
- `validFrom`
- `validTo`

Expected identifier families:
- Project: `projectCode`
- Procurement: `packageNo`, `poNo`, `vendorCode`
- Material: `materialCode`, `mfgPartNo`, `serialNo`, `HVDC_CODE`
- Shipment: `shipmentId`, `bookingNo`, `BL No.`, `voyageNo`, `rotationNo`
- Container: `containerNo`, `sealNo`
- Customs: `BOE No.`, declaration line ref
- Release: `DO No.`, gate pass ref
- Warehouse: warehouse receipt no., location code
- Exception / Cost: `exceptionId`, `claimRef`, `invoiceNo`, `costCode`

`HVDC_CODE` is a cross-cutting engineering / logistics tag. It is **not** the sole graph identity anchor.

## 8. Milestone governance

Use a first-class milestone model.

Minimum canonical milestone dictionary:
- `M10` Cargo Ready
- `M20` Packed / Marked
- `M30` Pickup Completed
- `M40` Export Cleared
- `M50` Terminal Received
- `M60` Loaded On Board
- `M61` ATD
- `M70` Transshipment Occurred
- `M80` ATA
- `M90` BOE Submitted
- `M91` BOE Cleared
- `M92` DO Released
- `M100` Gate-out Completed
- `M110` Warehouse Received
- `M111` Put-away Completed
- `M120` Picked / Staged
- `M121` Dispatched
- `M130` Site Arrived
- `M131` Site Inspected — Good
- `M132` Site Inspected — OSD
- `M140` POD / GRN / Handover
- `M150` Claim Opened
- `M160` Cost Closed

Offshore-specific extensions such as `M115`, `M116`, `M117` may exist, but they must remain consistent with the master spine.

`WarehouseHandlingProfile.confirmedFlowCode` may only be confirmed after `M110`.

## 9. Validation gates that must never be bypassed

### Standard validation command for consolidated ontology docs

For the consolidated ontology document set, the repo-local standard validation gate is:

```powershell
.venv\Scripts\python.exe scripts\validate_logi_ontology_docs.py
```

Apply this gate to:
- `CONSOLIDATED-02-warehouse-flow.md`
- `CONSOLIDATED-04-barge-bulk-cargo.md`
- `CONSOLIDATED-09-operations.md`

Use this command before claiming:
- semantic migration complete
- publication blocker count = 0
- SHACL validation complete for the consolidated ontology subset

`grep` gates and manual spot-checks are still useful, but they do not replace this command for the `02/04/09` document group.

### VIOLATION-1
`confirmedFlowCode` found outside `WarehouseHandlingProfile` → immediate block

### VIOLATION-2
For `AGI` / `DAS` shipments using `MOSB_DIRECT`, `WH_MOSB`, or `MIXED`, if `M130 Site Arrived` exists but `M115 MOSB Staged` does not exist → immediate block

### Additional mandatory checks
- no milestone model may be replaced by Flow Code
- no new integer route-type property where the conceptual value is a named routing pattern
- no document model may own operational status if it only provides evidence

## 10. Standards alignment policy

When adding or revising ontology content, align with these standards where relevant:

- `GS1 EPCIS/CBV` for event visibility
- `DCSA Track & Trace` for container / shipping milestones
- `UN/CEFACT BSP-RDM` for semantic reference data
- `WCO Data Model` for customs semantics
- `PROV-O` for provenance / evidence
- `OWL-Time` for time modeling
- `SKOS` for controlled vocabularies
- `DQV` for data quality metadata

Use standards as alignment anchors, not boilerplate filler.

## 11. File-specific responsibilities

- `CONSOLIDATED-00-master-ontology.md`  
  Canonical semantic spine. Any semantic change starts here.

- `CONSOLIDATED-01-core-framework-infra.md`  
  High-level standards, regulations, nodes, and project framework.

- `CONSOLIDATED-02-warehouse-flow.md`  
  Warehouse-only operational logic and `WarehouseHandlingProfile`. Remove route lifecycle semantics.

- `CONSOLIDATED-03-document-ocr.md`  
  Document evidence, OCR, trust, provenance, cross-document validation. Do not assign Flow Code here.

- `CONSOLIDATED-04-barge-bulk-cargo.md`  
  Marine / bulk / heavy-lift / offshore extension. Use marine routing semantics.

- `CONSOLIDATED-05-invoice-cost.md`  
  Invoice, tariff, cost guard, rate verification, cost traceability. Use route-based cost driver plus warehouse evidence.

- `CONSOLIDATED-06-material-handling.md`  
  End-to-end material-handling extension. Express movement through `RoutingPattern + MilestoneStatus`, not legacy Flow Code chains.

- `CONSOLIDATED-07-port-operations.md`  
  PortCall, ServiceEvent, tariff / invoice linkage, import routing decision. Port may declare routing intent, not warehouse Flow Code.

- `CONSOLIDATED-08-communication.md`  
  Evidence layer only. Connect to core through `AuditRecord`, `CommunicationEvent`, and `ApprovalAction` only.

- `CONSOLIDATED-09-operations.md`  
  Operations analytics / reporting / KPI layer. Consume canonical semantics; do not redefine them.

## 12. Editing workflow for agents

1. Read the relevant section of `CONSOLIDATED-00` first.
2. For semantic changes, patch `CONSOLIDATED-00` before or together with the extension.
3. If an extension still contains legacy terms, migrate the prose, TTL, SHACL, SPARQL, examples, and KPI language in the same change.
4. Do not leave mixed terminology in one file.
5. Do not patch examples only; update surrounding vocabulary and validation logic too.
6. If evidence is insufficient, mark it explicitly as:
   - `GAP:` missing design evidence
   - `ASSUMPTION:` target-state design assumption
7. Never invent current operational truth from analogy or guesswork.
8. After editing `CONSOLIDATED-02`, `CONSOLIDATED-04`, or `CONSOLIDATED-09`, run `.venv\Scripts\python.exe scripts\validate_logi_ontology_docs.py` before reporting completion.

## 13. Routing guidance for agents

To avoid unnecessary reading:

- Start with `CONSOLIDATED-00`
- Then read only the target extension plus directly linked dependencies
- Use `CONSOLIDATED-08` only for evidence / communication work
- Use legacy fragments only when performing migration or deprecation work
- Prefer canonical vocabulary from the spine over repeated prose in extensions

## 14. Modeling and writing conventions

- Use English standard logistics terms first
- Add Korean explanation only where it improves local readability
- Use ISO date / datetime formats
- Use explicit milestone codes for event transitions
- Use two decimal places for monetary examples
- Keep object / property names stable once canonicalized
- Prefer string enums / SKOS concepts for routing patterns; do not encode them as integers
- Keep prose, TTL, SHACL, SPARQL, tables, and examples semantically aligned

## 15. Query-connectivity requirement

Any new design must preserve traversal from at least these entry points:

- ETA / ETD / ATA / ATD
- `HVDC_CODE`
- Vendor / Vendor Code
- Package No. / PO No.
- Material Code
- Shipment ID
- Container No. / Seal No.
- BL No.
- BOE No.
- DO No.
- Warehouse / Warehouse Location
- Site Code
- Exception ID / Claim Ref
- Cost Code / Invoice No.

If a change breaks upstream / downstream traversal from one of these keys, it is not acceptable.

## 16. Planning documents

For large semantic migrations, cross-file refactors, or validation-pack rewrites:

- create or update a plan document before editing many files
- keep the plan synchronized with the actual patch set
- do not start wide refactors without naming the canonical target vocabulary first

