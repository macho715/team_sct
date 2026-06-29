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
