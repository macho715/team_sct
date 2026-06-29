# Minkyu Cha (차민규) — Major Work Analysis Report

## FINAL_10x Patch Review Note

- Review date: `2026-04-27` (Asia/Dubai).
- Cross-document validation rounds: `10.00`.
- PII handling: e-mail and phone values masked in final distribution copy.
- Role boundary checked against `Team_역할분담_매트릭스.md`, `FMC_OrgChart_Data.json`, and `CONSOLIDATED-00` M10~M160 milestone model.

> Basis for preparation: FMC_OrgChart_Data.json + DuckDB email_search.duckdb statistics
> Date prepared: April 27, 2026

---

## 1. Basic Information

| Item | Details |
|------|------|
| **Name** | Minkyu Cha (차민규) |
| **Chat handle** | `차민규` / `Minkyu` |
| **FMC number** | No.2 |
| **Affiliation** | Samsung C&T HVDC Project — Logistics Team |
| **SITE** | MUSSAFAH |
| **Position** | Material Management |
| **E-mail** | mi***@samsung.com |
| **DuckDB e-mail count** | 1,379 cases |
| **Active Sites** | AGI (192), DAS (31), MIR (18), MIRFA (4), GHALLAN (3) |
| **Data range** | 2024-10 ~ 2026-02 |
| **DuckDB LPO mentions** | LPO-1770 (2 cases), LPO-292 (2 cases) — not a work assignment |
| **DuckDB Top Companies** | Samsung (374 cases), samsungvpn.com (98 cases), Jopetwil-Marine (32 cases), hanlimenc.com (11 cases), GROUPMD (11 cases) |

> **Official role definition (DuckDB + organization chart)**:
> - Material Management — manages inbound/outbound logistics for project materials as the material management owner
> - Jopetwil-Marine (32 cases) = involvement in marine/offshore environment
> - User confirmation reflected: invoice checking and vendor progress payment management are also included in major work

---

## 2. Major Work Categories

> Based on DuckDB PlainTextBody keyword analysis results: `samsung` (1,841 occurrences), `hvdc` (990 occurrences), `https` (625 occurrences), `onshore` (390 occurrences), `logistics` (341 occurrences), `manager` (264 occurrences), `haitham` (244 occurrences), `ofco` (270 occurrences)

### 2-1. Material Management — Material Inbound/Outbound Management ★Main Work

As the Material Management owner, he manages project material receiving, dispatch, and status:

- AGI site 192 cases + DAS site 31 cases + MIR 18 cases = project-wide material management

> **DuckDB evidence (Minkyu Cha e-mail)**:
> - `"Out of office (17, Jan, 2026 - 14 Feb-2026)"` — work coverage during absence
> - `"Vendor Update"` — supplier status update
> - `"Request for gate pass for collection of cement bulker"` — cement bulker Gate Pass request

---

### 2-2. Marine/Offshore Material Management Support ★Core

Jopetwil-Marine (32 cases), `haitham` (244 keyword occurrences) — linked with Haitham's marine/MOSB work:

- Support material coordination related to Jopetwil 71 vessel
- Coordinate offshore site material inbound with Haitham (Marine Supervisor)
- Manage materials related to ADNOC offshore regulatory compliance
- Plan/coordinate material supply to offshore sites

---

### 2-3. Vendor Management and Gate Pass Coordination ★Recurring Work

Management of multiple vendors and handling Gate Pass requests:

- `"Request for gate pass for collection of cement bulker"` — Gate Pass for cement bulker collection
- `"RE: [HVDC-SHU]China to Dubai (BANSUK) // 7 pieces, 1 pallet Lighting Fixture"` — overseas inbound lighting fixture
- `"RE: [HVDC-ADOPT-SCT-0177] Booking Order / 5001003776 / Earthing & Lightning Protection Material"` — SCT Booking Order
- `"RE: [HVDC-ADOPT-SCT-0177] FINAL SHIPPING NOTICE / 5001003776 / Earthing & Lightning Protection Material / Incheon Airport"` — shipping notice departing Incheon
- hanlimenc.com (11 cases) — related vendor

---

### 2-4. AGI Site-Centered Material Flow Management

AGI has the highest activity volume, with 192 cases:

- `"RE: [HVDC-AGI] HVDC-AGI-ALS-BL-535_LCT PER ASPERA_09.02.2026_1ST SHIPMENT/AGI DEPARTURE NOTIFICATION"` — AGI marine departure notification
- Material management related to large equipment in AGI, including SKM AC/HVAC/AHU/MU
- Coordination of movement plans within the AGI site with DSV/Hitachi and others

---

### 2-5. Invoice Checking and Vendor Progress Payment Management ★Major Work

He compares vendor billing details against work progress and performs confirmation/coordination for progress payments:

- Check amounts, target work, and related material/logistics details in vendor invoices
- Compare work progress and supporting evidence before vendor progress payments
- Check invoice and vendor materials required for payment review
- Share payment review results with Team Lead Sanguk and the related approval line

> **Reflection basis**:
> - Registered as major work for Minkyu Cha based on user confirmation
> - This is a role-definition supplement, not an item independently confirmed by DuckDB statistics alone

---

## 3. Work Importance Matrix

| Rank | Work Area | Frequency | Impact | DuckDB Basis |
|------|-----------|------|--------|-------------|
| **1** | **Material Management — material inbound/outbound management** | **Very high** | **Very high** | **AGI 192 cases, Samsung 374 cases** |
| **2** | **Invoice checking and vendor progress payment management** | **High** | **High** | **User confirmation reflected** |
| **3** | **Marine/Offshore material coordination** | **High** | **High** | **Jopetwil-Marine 32 cases, haitham 244 occurrences** |
| **4** | **Vendor Management and Gate Pass** | **High** | **Medium** | **hanlimenc 11 cases, SCT-0177** |
| **5** | **AGI Site material flow management** | **High** | **High** | **AGI 192 cases (highest)** |
| **6** | **Holiday/absence management** | **Intermittent** | **Low** | **Out of office 2026-01-17~02-14** |

---

## 4. Role Comparison with Other Team Members

| Work Area | Minkyu Cha | Sanguk (Team Lead) | Arvin | Karthik | kEn | Haitham | Roldan |
|-----------|-------|-------------|-------|---------|-----|---------|--------|
| **Domain** | Material management | Team lead | Overseas customs documents | Domestic LPO documents | Warehouse/LPO execution | Marine/MOSB | Field receipt |
| **Core deliverables** | Material inbound/outbound status | Team decision-making | BOE/DO/MSDS | PL/DN/MTC | LPO execution status | SR/LCT | POD/GRN |
| **Cost/progress payment** | ★ Invoice checking/vendor progress payment review | Approval/full authority | - | LPO document linkage | Execution data support | Marine work evidence | Field receipt evidence |
| **Offshore involvement** | ★ Jopetwil coordination | Overall supervision | FANR/MOIAT | - | - | ★ Marine operations | - |
| **AGI Site** | ★ AGI 192 cases | AGI+DAS overall control | AGI+DAS | AGI+DAS | AGI+DAS | AGI+DAS | AGI+DAS |
| **Vendor/execution documents** | Jopetwil/Vendor | Jopetwil overall control | - | ★ Domestic LPO | LPO execution | - | Equipment LPO |
| **E2E position** | M50~M130 | M10~M160 | M90~M92 | M10~M30 | M100~M121 | M115~M117 | M130~M140 |

### 4-1. Minkyu Cha's Unique Position

In the **Material Management** role, Minkyu Cha focuses on **material status management and coordination** rather than the physical flow of materials. He also performs vendor invoice checking and progress payment review, helping material and vendor work continue through the cost-closing stage. A core part of the role is coordinating material supply to offshore sites in connection with Haitham's marine operations and Jopetwil 71 vessel operations. He supports Team Lead Sanguk's supervision across the M90~M160 segment.

---

## 5. E2E Logistics Process Position (Ontology-Based)

> This section follows the CONSOLIDATED-00-master-ontology.md Milestone M10~M160 framework.

### 5-1. Responsible Milestones

| Milestone | Name | Minkyu Cha Role |
|----------|------|-------------|
| **M50** | Terminal Received | Confirm AGI field material terminal receipt |
| **M80** | ATA (Arrival) | Support vessel arrival coordination, including Jopetwil 71 |
| **M90~M92** | BOE/DO | Coordinate marine customs-clearance materials linked with Jopetwil-Marine |
| **M100** | Gate-out | Handle Gate Pass requests, including cement bulker |
| **M110** | WH Received | Manage material receiving status |
| **M130** | Site Arrived | Track AGI Site material arrival status |
| **M160** | Cost Closed | Invoice checking and vendor progress payment review |

**Responsible Journey Stage**: PORT_ENTRY → CUSTOMS_CLEARANCE → INLAND_HAULAGE → WH_RECEIPT → SITE_RECEIVING

### 5-2. Involvement by RoutingPattern

| RoutingPattern | Minkyu Cha Role |
|----------------|-------------|
| `MOSB_DIRECT` | Material coordination via Jopetwil 71 vessel |
| `WH_MOSB` | Material management for combined warehouse + marine route |
| `DIRECT` | AGI direct-delivery material management |

### 5-3. Ontology Responsibility Classes

`MaterialMaster` · `Shipment` · `ServiceRequest` · `MilestoneEvent` (material status tracking) · `Invoice` · `InvoiceLine` · `CostTransaction` (invoice checking and progress payment review)

### 5-4. Special Role Linked with Jopetwil-Marine

Within the team, Minkyu Cha is a **support owner for material coordination related to the Jopetwil 71 marine vessel**, coordinating material status between Haitham's marine operations and Team Lead Sanguk's decision-making.

---

## 6. FMC Organization Chart and Ontology Reflection Supplement

> Reference materials: `../FMC_OrgChart_Data.json`, DuckDB email_search.duckdb
> Personal information handling: E-mail/phone numbers are masked in the final distribution copy.

| Item | Details |
|------|------|
| **Real name in organization chart** | Minkyu Cha |
| **Organization chart position** | Material Management |
| **FMC No.** | 2 |
| **SITE** | MUSSAFAH |
| **E-mail** | mi***@samsung.com |
| **Conversation/document notation** | 차민규 / Minkyu |
| **DuckDB e-mail** | 1,379 cases (2024-10 ~ 2026-02) |
| **DuckDB Top Sites** | AGI (192), DAS (31), MIR (18) |
| **DuckDB Body keywords** | samsung 1,841 occurrences, hvdc 990 occurrences, offshore 390 occurrences, haitham 244 occurrences, ofco 270 occurrences |
| **DuckDB Top Companies** | Samsung (374 cases), samsungvpn.com (98 cases), Jopetwil-Marine (32 cases) |
| **Proposed ontology ActorRole** | `MaterialManagementCoordinator` (material management coordinator) |
| **Connected milestones** | M50~M130 (material inbound/outbound tracking segment), M160 (invoice checking and vendor progress payment review) |
| **Position in team** | Material Management — material status management, invoice checking, vendor progress payment review, reporting to Team Lead Sanguk |

---

<!-- 2026-04-27-duckdb-verification-start -->
## 2026-04-27 DuckDB-Based Verification Block

> DuckDB: `email_search.duckdb` | Basis: emails table | Query basis: e-mail included in SenderEmail or RecipientTo

### DuckDB E-mail Statistics

| Item | Result |
|------|------|
| **Total e-mails** | 1,379 cases |
| **Active Sites** | AGI (192), DAS (31), MIR (18), MIRFA (4), GHALLAN (3) |
| **LPO mentions** | LPO-1770 (2 cases), LPO-292 (2 cases) — not a work assignment |
| **Top Companies** | Samsung (374 cases), samsungvpn.com (98 cases), Jopetwil-Marine (32 cases), hanlimenc.com (11 cases) |
| **Data range** | 2024-10-11 ~ 2026-02-12 |

### Major Subject Keywords (Top 10)

- **Out of office (17, Jan, 2026 - 14 Feb-2026)** — absence management
- **Vendor Update** — supplier update
- **RE: [HVDC-SHU]China to Dubai (BANSUK) // 7 pieces / 1 pallet Lighting Fixture** — lighting fixture
- **Request for gate pass for collection of cement bulker** — cement Gate Pass
- **RE: [HVDC-ADOPT-SCT-0177] Booking Order / 5001003776 / Earthing & Lightning Protection Material** — SCT Booking
- **RE: [HVDC-ADOPT-SCT-0177] FINAL SHIPPING NOTICE / 5001003776 / Earthing & Lightning Protection Material / Incheon Airport** — departure notification
- **RE: [HVDC-AGI] HVDC-AGI-ALS-BL-535_LCT PER ASPERA_09.02.2026_1ST SHIPMENT/AGI DEPARTURE NOTIFICATION** — marine departure
- **[Holiday 신청] 업무 공지 — 차민규 [2026.02.15] / Request for Working on Holiday** — holiday request

### Body Keyword Frequency (Top 20)

| Keyword | Count |
|--------|------|
| `samsung` | 1,841 occurrences |
| `hvdc` | 990 occurrences |
| `https` | 625 occurrences |
| `dear` | 618 occurrences |
| `please` | 584 occurrences |
| `minkyu` | 575 occurrences |
| `regards` | 413 occurrences |
| `onshore` | 390 occurrences |
| `logistics` | 341 occurrences |
| `contact` | 337 occurrences |
| `kindly` | 335 occurrences |
| `ofco` | 270 occurrences |
| `manager` | 264 occurrences |
| `haitham` | 244 occurrences |

### DuckDB-Based Role Verification

| Verification Item | Result | Judgment |
|-----------|------|------|
| Material Management signature | Samsung 1,841 occurrences, logistics 341 occurrences | ✅ |
| Invoice checking and vendor progress payment | User confirmation reflected | ✅ |
| Offshore/Jopetwil signature | Jopetwil-Marine 32 cases, haitham 244 occurrences | ✅ |
| AGI Site involvement | AGI 192 cases (highest) | ✅ |
| Vendor/Gate Pass signature | SCT-0177 Booking Order, cement bulker | ✅ |
| Team Lead Sanguk support | team leader involvement pattern | ✅ |

**Role judgment**: The e-mail activity pattern of `Minkyu Cha` (차민규) is consistent with the `MaterialManagementCoordinator` role. AGI Site material management, Jopetwil-Marine coordination, linkage with Haitham Marine Supervisor, and Vendor/Gate Pass handling are reflected in the DuckDB data. Based on user confirmation, invoice checking and vendor progress payment review are also added as major work.
<!-- 2026-04-27-duckdb-verification-end -->

---

*This document was prepared by analyzing FMC_OrgChart_Data.json and DuckDB email_search.duckdb statistics.*
