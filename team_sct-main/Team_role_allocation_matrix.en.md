# HVDC Logistics Team Role Allocation Matrix

## FINAL_10x Patch Review Note

- Review date: `2026-04-27` (Asia/Dubai).
- Cross-document validation rounds: `10.00`.
- PII handling: e-mail and phone values masked in final distribution copy.
- Role boundary checked against `Team_역할분담_매트릭스.md`, `FMC_OrgChart_Data.json`, and `CONSOLIDATED-00` M10~M160 milestone model.

> Basis for preparation: `individual_rev` individual major-work documents + `CONSOLIDATED-00-master-ontology.md` / `CONSOLIDATED-01-core-framework-infra.md` Milestone M10~M160 framework
> Date prepared: April 27, 2026
> **Team lead**: Sanguk / Shariff (same person — Logistics Team Lead)
> **Same-person consolidation**: Ronnel = ronpap20 = Ronnel Papa Initan. Representative document is `Ronnel_주요업무_분석.md`.
> ⚠️ Kim Guk-il: resigned (chat quotations in the document are preserved only as historical evidence)

---

## 1. Responsibility Map by E2E Segment

```
[Team Lead Overlay] → M10~M160 ★ Jeongsanguk/Sanguk/Shariff (overall supervision, approval, decision-making)
       ↓
[Overseas suppliers/forwarders] → Overseas inbound shipping documents
       ↓
[UAE arrival · customs clearance] → M80~M92 ★ Arvin (overseas BOE/DO/MSDS/FANR/MOIAT/EC/BL)
       ↓
[Domestic LPO document preparation] → M10~M30 ★ Karthik (domestic LPO/PL/DN/MTC)
       ↓
[Material status · Vendor · progress payment review] → M50~M130 / M160 ★ Minkyu Cha (material status, invoice checking, vendor progress payment review)
       ↓
[Warehouse receiving · storage · dispatch] → M100~M121 ★ kEn (LPO/WarehouseTask)
       ↓ (WH_MOSB/MOSB_DIRECT pattern)
[MOSB marine segment] → M115~M117 ★ Haitham (SR/LCT/RORO/LOLO)
       ↓
[MOSB(VP24) field supervision] → AGI/DAS-bound cargo, container stuffing, MOSB outdoor warehouse ★ Jhysn
       ↓
[VP24 owner] → VP24 lifting/stuffing/offloading, crane/forklift status ★ Ronnel/ronpap20
       ↓
[Field receipt · inspection · handover] → M130~M140 ★ Roldan (Site/POD/GRN/Backload)
       ↓
[Cost closure] → M160 ★ Minkyu Cha review + Sanguk approval / Finance Human-gate
```

---

## 2. Responsibility Matrix by Milestone

| Milestone | Name | Primary Responsibility | Support · Evidence · Review |
|---------|------|---------|----------------|
| M10 | Cargo Ready | Karthik | Sanguk supervision, Minkyu Cha vendor status check |
| M20 | Packed / Marked | Karthik | Minkyu Cha supports vendor PL collection |
| M30 | Pickup Completed | Karthik | Roldan/Jhysn/Ronnel support field information |
| M50 | Terminal Received | Minkyu Cha | Sanguk supervision |
| M80 | ATA (arrival) | Arvin | Sanguk supervision |
| M90 | BOE Submitted | Arvin | Sanguk supervision |
| M91 | BOE Cleared | Arvin | Sanguk approval/supervision |
| M92 | DO Released | Arvin | Roldan prepares field vehicle entry |
| M100 | Gate-out | Arvin / Roldan / Karthik | kEn confirms dispatch, Jhysn identifies MOSB(VP24) field vehicles/containers, Ronnel provides information for some VP24 gate pass requests |
| M110 | WH Received (WH In) | kEn | Karthik PL/DN/MTC prior materials, Haitham SR submission, Minkyu Cha material status check |
| M111 | Put-away | kEn | Sanguk supervision |
| M115 | MOSB Staged | Haitham | Jhysn supervises MOSB(VP24) AGI/DAS-bound cargo and outdoor warehouse field; Ronnel/ronpap20 reports VP24 work status |
| M116 | LCT/Barge Loaded | Haitham | Jhysn supervises container stuffing; Ronnel/ronpap20 reports VP24 stuffing/lifting status |
| M117 | Sail-away Approved | Haitham | Sanguk supervision, Jhysn checks MOSB(VP24) field status |
| M120 | Picked / Staged | kEn | Jhysn supervises MOSB(VP24) staged status; Ronnel/ronpap20 checks VP24 stuffing/offloading/lifting progress |
| M121 | Dispatched | kEn | Roldan awaits handover |
| M130 | Site Arrived | Roldan | Jhysn provides MOSB(VP24) status evidence before AGI/DAS dispatch; Ronnel/ronpap20 provides VP24 work completion evidence |
| M131 | Site Inspected (Good) | Roldan | Jhysn provides MOSB(VP24) dispatch status evidence; Ronnel provides VP24 work evidence |
| M132 | Site Inspected (OSD) | Roldan | Jhysn supervises MOSB(VP24) damage/bent status; Ronnel reports VP24 work status |
| M140 | POD / GRN / Backload | Roldan | Ronnel/ronpap20 requests collection of reusable gear such as webbing slings, Jhysn checks MOSB outdoor warehouse status, kEn provides inventory history |
| M150 | Claim Opened | Roldan | Arvin SIM claim, Sanguk supervision |
| M160 | Cost Closed | Minkyu Cha review / Sanguk approval | Finance Human-gate, invoice and progress payment evidence check |

> ★ = primary owner / ◎ = support or related role

---

## 3. Team Member Involvement by RoutingPattern

| RoutingPattern | Primary Responsibility Flow | Support · Review |
|----------------|--------------|-----------|
| `DIRECT` | Arvin M90~92 → Roldan M130~140 | Karthik domestic LPO documents, Material Management material/vendor/M160 review |
| `WH_ONLY` | Arvin M90~92 → kEn M110~121 → Roldan M130~140 | Karthik PL/DN/MTC, Minkyu Cha material status, Jhysn/Ronnel field evidence |
| `MOSB_DIRECT` | Arvin M90~92 → Haitham M115~117 → Roldan M130~140 | Jhysn supervises MOSB(VP24) AGI/DAS-bound cargo field, Ronnel/ronpap20 reports VP24 work status, Sanguk supervises |
| `WH_MOSB` | Arvin M90~92 → kEn M110~120 → Haitham M115~117 → Roldan M130~140 | Karthik handles DSV yard material recovery, Minkyu Cha reviews vendor/progress payments, Jhysn supervises MOSB outdoor warehouse and stuffing, Ronnel owns VP24 |
| `MIXED` | Sanguk determines the responsibility route by situation | Each owner is responsible only for evidence for their own milestone, and Minkyu Cha links cost/progress payment review to M160 |

---

## 4. Work Area Comparison Table

| Person | Domain | Core Deliverables / Check Values | E2E Position |
|------|--------|----------------------|----------|
| Jeongsanguk / Sanguk / Shariff | Team lead overlay | Overall operation instructions, approvals, vessel/backload coordination | Overall supervision of M10~M160 |
| Minkyu Cha / Minkyu | Material Management | Material status, vendor coordination, invoice checking, vendor progress payment review | M50~M130 + M160 |
| Arvin | Overseas inbound documents/customs clearance | BOE, DO, MSDS, FANR, MOIAT, EC, BL(Bill of Lading) | M80~M92 |
| Karthik | Domestic LPO-centered documents | Domestic LPO, PL, DN, MTC, Revised PL, Gate Pass | M10~M30/M100 |
| kEn / Ken | Warehouse/LPO execution | LPO execution status, WH Receipt, dispatch instruction | M100~M121 |
| Haitham | Vessel/MOSB | SR, LCT location report, loading completion, MOSB staging | M115~M117 |
| Roldan / DaN | Field receipt/Backload | POD, GRN, Backload, CCU collection, OSD trigger | M130~M150 |
| Jhysn / Jhason / Jason | MOSB(VP24) field supervision | Field supervision of AGI/DAS-bound cargo, container stuffing, MOSB outdoor warehouse management, exit pass request information | Supervision/support for M100/M115/M116/M120/M130/M140 |
| Ronnel / ronpap20 | VP24 owner | VP24 lifting, stuffing, offloading, crane/forklift status, webbing sling collection | Support for M115/M116/M120/M130/M140 |

---

## 5. Role Overlap/Gap Analysis

### 5-1. Overlap Areas (Normal Collaboration)
| Overlapping Work | Owner 1 | Owner 2 | Coordination Method |
|-----------|---------|---------|----------|
| Gate/Exit Pass handling | Arvin (e-mail sending) | Roldan/kEn/Karthik (case-by-case field/warehouse/SCT execution) | Arvin sends documents, Roldan prepares MOSB vehicle entry, kEn executes warehouse/field work, Karthik coordinates SCT/DSV yard Gate Pass |
| LPO handling | kEn (warehouse/field execution reporting) | Karthik/Roldan (domestic LPO documents/equipment LPO) | kEn owns the operation table, Karthik owns domestic LPO-based PL/DN/MTC and vendor status, Roldan owns equipment rental LPO/timesheet |
| TPI document management | Arvin (tracking/requests) | Haitham/kEn/Roldan (inspection/delivery/renewal administration) | Arvin tracks documents, Haitham handles field inspection, kEn handles Webbing Sling delivery schedule, Roldan handles equipment TPI renewal SR |
| Shipping tracking reports | Arvin (overseas/customs) | Haitham (vessel/MOSB) | Segmented separation (customs vs marine) |
| BL terminology | Arvin (Bill of Lading) | Roldan/kEn (Backload) | BL in Arvin's documents is Bill of Lading; BL in Roldan/kEn documents is Backload |
| DSV Follow-up | Arvin (overseas inbound customs/document condition coordination) | kEn/Roldan (warehouse/field execution) | Arvin coordinates incomplete overseas document cases with DSV Minhaj, while kEn/Roldan handle dispatch/delivery/receipt execution |
| DSV yard material recovery | Karthik (damaged box/HE case repair confirmation) | kEn/Roldan (warehouse location/field delivery) | Karthik confirms repairs and delivery permission, kEn reports warehouse status, Roldan handles field delivery/receipt |
| SR handling | Haitham (WELLS ID-based operation SR) | Roldan/Karthik (equipment/consumables/Gate Pass-type administration) | Haitham owns marine/warehouse operation SR, Roldan owns equipment/consumables SR/PR, Karthik supports service requests in the nature of Gate Pass |
| Delivery Coordination | Roldan (actual delivery execution/receipt confirmation) | Arvin/kEn/Karthik (prior handling of overseas customs/warehouse/domestic LPO documents) | Arvin handles overseas customs/DSV requests, kEn issues warehouse dispatch instructions, Karthik provides domestic LPO-based PL/DN/MTC, Roldan confirms field receipt |
| Backload/CCU | Roldan (collection/return/pickup execution) | kEn/Haitham (inventory reporting/history confirmation) | Roldan handles Backload transport and waste CCU collection, kEn reports BL Laydown, Haitham confirms CCU history during MOSB work |

### 5-2. Potential Gaps (Risks)
| Gap Area | Problem Situation | Recommended Cover |
|-----------|---------|----------|
| LPO handling when kEn is absent | Warehouse contractor work cannot proceed | Sanguk/Shariff provides urgent LPO approval |
| Domestic LPO PL/DN/MTC collection when Karthik is absent | Without PL, un-stuffing and MRR creation are delayed, and the domestic vendor contact window becomes vacant | Designate Khemlal(SCT) as first backup and share domestic LPO vendor contacts and the PL tracker |
| Customs clearance when Arvin is absent | BOE/DO processing stops completely | Prior delegation procedure required |
| Vessel tracking when Haitham is absent | MOSB plan visibility is lost | Khemlal(SCT) temporary acting coverage |
| Field receipt/Backload when Roldan is absent | Site arrival, inspection, and Backload data are interrupted | Operate a handover table based on kEn/Nicole/Site team |

---

## 6. Ontology Class Responsibility Summary

| Ontology Class | Primary Owner |
|----------------|---------|
| `ActorRole.LogisticsTeamLeader` · `ApprovalAction` | **Jeongsanguk/Sanguk/Shariff** |
| `MaterialMaster` · `Shipment` · `MilestoneEvent` | **Minkyu Cha** material status management |
| `Invoice` · `InvoiceLine` · `CostTransaction` · `CostGuardResult` | **Minkyu Cha** invoice checking/vendor progress payment review / **Sanguk** approval |
| `CustomsEntry` · `BOE` · `DO` | **Arvin** |
| `PermitApplication` (FANR/MOIAT/EC) | **Arvin** |
| Domestic `PackingList` · `DeliveryNote(DN)` · `MaterialTransferCertificate(MTC)` | **Karthik** |
| `Container(CCU)` · `ServiceRequest(Gate Pass)` · `WarehouseTask(field verification)` | **Karthik** |
| `WarehouseTask` · `WarehouseHandlingProfile` | **kEn** |
| `LPO (LocalPurchaseOrder)` | **kEn** primary execution owner / **Karthik** domestic LPO documents/vendor status / **Roldan** equipment rental LPO |
| `ServiceRequest (SR)` · `MarineEvent` · `LCT` | **Haitham** primary owner / **Roldan** equipment/consumables SR/PR administration |
| `MilestoneEvent.M115~M117` | **Haitham** |
| `SiteReceipt` · `POD` · `GRN` · `BackloadEvent` | **Roldan** |
| `Exception (OSD/Damage)` → `Claim` | **Roldan** |
| `FieldEvidence` · `CommunicationEvent` · `EquipmentStatusReport` | **Jhysn** MOSB(VP24) field supervision evidence / **Ronnel/ronpap20** VP24 handling evidence |
| `OffshoreStaging` · `LaydownArea` · `StuffingEvent` | **Jhysn** MOSB outdoor warehouse/container stuffing supervision |
| `LiftingEvent` · `StuffingEvent` · `EquipmentResource` | **Ronnel/ronpap20** VP24 work owner |

---

*This document was consolidated based on the nine individual major-work documents in `individual_rev` and ontology 00/01 documents.*

<!-- 2026-04-27-10person-update -->
## 7. 2026-04-27 Integrated Role Reflection

> Reference materials: `individual_rev` individual major-work documents + duckdb_query_results.json

| Person | Additional Reflected Core Role | Boundary with Existing Five Members |
|------|----------------------|------------------|
| Jhysn | Field supervision of all AGI/DAS-bound cargo at MOSB(VP24), container stuffing, MOSB outdoor warehouse management | Ronnel/ronpap20 owns VP24, Haitham owns LCT/MOSB marine operations, Roldan owns final field receipt |
| Ronnel/ronpap20 | VP24 owner — VP24 lifting, stuffing, offloading, forklift/crane status checks | Jhysn supervises MOSB(VP24) field, Roldan owns final field receipt, kEn owns warehouse operations |
| Sanguk(Jeongsanguk) | Team Lead overlay — overall team operations, vessel movement report, backload coordination | As the same person as Sanguk/Shariff, he has full delegated authority for Logistics Team Lead duties |
| Minkyu Cha(Minkyu) | Material Management overlay — vendor coordination, invoice checking, vendor progress payment review | Supports vendor and invoice/payment review as the Material Management owner |

### 7-1. Expanded E2E Support Segments

| Segment | Primary Owner | Support · Evidence |
|------|---------|----------|
| M10 Cargo Ready | Karthik | Sanguk(Team Lead jurisdictional shipment check) |
| M20 Packed/Marked | Karthik | Minkyu Cha(supports vendor PL collection) |
| M30 Pickup | Karthik | Roldan/Jhysn/Ronnel support field information |
| M80 ATA | Arvin | - |
| M90 BOE Submitted | Arvin | - |
| M100 Gate-out | Arvin/Roldan/Karthik | Jhysn provides MOSB(VP24) field vehicle/container identification information |
| M110 WH Received | kEn | Haitham(SR preparation) |
| M115 MOSB Staged | Haitham | Jhysn supervises MOSB(VP24) AGI/DAS-bound cargo and outdoor warehouse; Ronnel/ronpap20 reports VP24 work status |
| M116 Loaded/Staged | Haitham | Jhysn supervises container stuffing; Ronnel/ronpap20 reports VP24 stuffing/lifting work status |
| M120 Picked/Staged | kEn | Jhysn supervises MOSB(VP24) staged status; Ronnel/ronpap20 checks VP24 stuffing/offloading/lifting progress |
| M130 Site Arrived | Roldan | Jhysn provides MOSB(VP24) status evidence before AGI/DAS dispatch; Ronnel/ronpap20 provides VP24 work completion evidence |
| M140 Backload | Roldan | Ronnel/ronpap20 supports requests to collect reusable gear such as webbing slings, Jhysn checks MOSB outdoor warehouse status |

### 7-2. Gap Risks

| Gap Area | Impact | Primary Mitigation |
|---------|------|----------|
| Jhysn absent | Gap in field supervision of AGI/DAS-bound cargo, container stuffing, and outdoor warehouse at MOSB(VP24) | Haitham makes temporary judgments based on MOSB marine operations, and Ronnel/ronpap20 reports VP24 work status separately |
| Ronnel/ronpap20 absent | Confirmation of VP24 lifting/stuffing/offloading status is delayed | Jhysn re-confirms status based on MOSB(VP24) field supervision and kEn re-confirms warehouse status |
| Sanguk(Team Lead) absent | Gap in overall team operations, approvals, and vessel movement reporting | Shariff(same person) operates directly |
| Minkyu Cha(Material mgmt) absent | Disruption to vendor coordination and invoice checking | Sanguk directly coordinates vendor/invoice review |
| Invoice/progress payment when Minkyu is absent | Potential delay in invoice checking and vendor progress payment review | Covered through Sanguk/Shariff approval routine |

<!-- 2026-04-27-10person-update -->

<!-- 2026-04-27-fmc-identity-matrix-start -->
## 8. 2026-04-27 FMC Organization Chart Identification Verification Table

> Reference material: `../FMC_OrgChart_Data.json`
> Personal information handling: E-mail/phone numbers are masked in the final distribution copy.
> DuckDB basis: `email_search.duckdb` (based on OUTLOOK_HVDC_ALL_202409202510.xlsx) — direct e-mail basis / handle mention basis

| Document-Based Person | Conversation/Document Notation | Real Name in Organization Chart | Organization Chart Position | SITE | Organization Chart E-mail | ontology ActorRole | DuckDB Direct Mail | DuckDB Handle Search | Verification Status |
|---|---|---|---|---|---|---|---|---|---|
| Jeongsanguk/Sanguk | Jeongsanguk/Sanguk/Jeong | Sanguk Jeong | Logistic Manager | MUSSAFAH | su***@samsung.com | `LogisticsTeamLeader` | 66 cases | 4,513 cases | Organization chart JSON + DuckDB confirmed |
| Minkyu Cha | Minkyu Cha/Minkyu | Minkyu Cha | Material Management | MUSSAFAH | mi***@samsung.com | `MaterialManagementCoordinator` | 0 cases | 1,335 cases | Organization chart JSON + DuckDB confirmed |
| Arvin | Arvin | Arvin Q. Caadan | Logistics Officer | MUSSAFAH | ar***@samsung.com | `OverseasInboundDocsCoordinator` | - | - | Confirmed based on organization chart JSON |
| Karthik | Karthik, Karthik SCT Logistics | Karthik Raj | Storekeeper | MUSSAFAH | ka***@samsung.com | `DomesticLPODocumentController` | 557 cases | 1,563 cases | Organization chart JSON + DuckDB confirmed |
| kEn | kEn | Ken Espiritu Lopez | FMC | MUSSAFAH | ke***@samsung.com | `WarehouseExecutionCoordinator` | - | - | Confirmed based on organization chart JSON |
| Roldan | Roldan, DaN | Roldan Mendoza | Logistics Officer | MUSSAFAH | rb***@samsung.com | `SiteReceivingCoordinator` | 1,563 cases | 0 cases | Organization chart JSON + DuckDB confirmed |
| Haitham | Haitham | Haitham Mohammad Madaneya | Marine Supervisor | MUSSAFAH | ha***@samsung.com | `MarineMOSBCoordinator` | 783 cases | 3,049 cases | Organization chart JSON + DuckDB confirmed |
| Jhysn | Jhysn, Jhason, Jason | Jhason Alim De Guzman | FMC | MUSSAFAH | jh***@samsung.com | `MOSBVP24FieldSupervisor` | 79 cases | 0 cases | Organization chart JSON + user role correction reflected |
| Ronnel | Ronnel, ronpap20 | Ronnel Papa Initan | Logistics Officer | MUSSAFAH | p.***@samsung.com | `FieldHandlingSupport` | - | - | Organization chart JSON + representative document merge confirmed |

### 8-1. DuckDB E-mail Key Keyword Summary

| Person | Email | Gate Pass | Delivery | Backload | BL | CCU | LPO | TPI | Site |
|------|-------|-----------|----------|----------|----|-----|-----|-----|------|
| Jeongsanguk(Sanguk) | su***@samsung.com | - | 887 | 989 | - | - | - | - | - |
| Minkyu Cha(Minkyu) | mi***@samsung.com | - | - | - | - | - | - | - | - |
| Arvin | ar***@samsung.com | - | - | - | - | - | - | - | - |
| Karthik | ka***@samsung.com | 9 | 153 | - | 14 | 2 | 30 | 3 | 9 |
| kEn | ke***@samsung.com | - | - | - | - | - | - | - | - |
| Roldan | rb***@samsung.com | 15 | 421 | 92 | 21 | 32 | 41 | 30 | 47 |
| Haitham | ha***@samsung.com | 45 | 124 | 2 | 8 | 1 | 13 | 79 | 9 |
| Jhysn | jh***@samsung.com | - | - | - | 1 | - | - | - | - |
| Ronnel/ronpap20 | p.***@samsung.com | 1 | 3 | 1 | 4 | 2 | 0 | - | - |

### 8-2. Sanguk/Minkyu Team Lead Overlay Role Evidence

**Sanguk (Jeongsanguk) DuckDB**:
- Vessel/movement 1,738 occurrences — full authority for vessel movement report distribution
- Backload 989 occurrences — jurisdiction over overall backload coordination
- Many ADNOC/FANR/MOIAT-related documents
- Top sites: AGI 1,313 cases, DAS 1,119 cases — reflects overall team operation scope

**Minkyu (Minkyu Cha) DuckDB**:
- Material management keywords: logistics 341 occurrences, manager 264 occurrences, officer 194 occurrences
- Jopetwil-Marine 32 cases — involvement in LCT marine coordination
- haitham 244 occurrences, arvin 180 occurrences — frequent collaboration with team members as Material Management
- User confirmation reflected — invoice checking and vendor progress payment review registered as major work

Validation judgment: Because the team matrix is a role allocation table, phone numbers are not included. Real names, positions, and e-mails from the organization chart are used as supporting evidence for person identification, and ontology 00/01 reflection is connected primarily through ActorRole.
<!-- 2026-04-27-fmc-identity-matrix-end -->
