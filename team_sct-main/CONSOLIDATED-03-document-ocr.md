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
