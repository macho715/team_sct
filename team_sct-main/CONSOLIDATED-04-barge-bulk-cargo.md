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
