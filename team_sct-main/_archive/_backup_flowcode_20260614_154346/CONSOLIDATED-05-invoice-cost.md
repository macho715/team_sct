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
