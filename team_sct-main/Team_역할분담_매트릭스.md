# HVDC 물류팀 역할분담 매트릭스

## FINAL_10x Patch Review Note

- Review date: `2026-04-27` (Asia/Dubai).
- Cross-document validation rounds: `10.00`.
- PII handling: e-mail and phone values masked in final distribution copy.
- Role boundary checked against `Team_역할분담_매트릭스.md`, `FMC_OrgChart_Data.json`, and `CONSOLIDATED-00` M10~M160 milestone model.

> 작성 기준: `individual_rev` 개인별 주요업무 문서 + `CONSOLIDATED-00-master-ontology.md` / `CONSOLIDATED-01-core-framework-infra.md` Milestone M10~M160 체계
> 작성일: 2026년 4월 27일
> **팀장**: 상욱 / Shariff (동일인 — 물류팀 팀장)
> **동일 인물 정리**: Ronnel = ronpap20 = Ronnel Papa Initan. 대표 문서는 `Ronnel_주요업무_분석.md`.
> ⚠️ 김국일: 퇴사 (문서 내 채팅 인용은 역사적 증거로만 보존)

---

## 1. E2E 구간별 책임자 맵

```
[팀장 Overlay] → M10~M160 ★ 정상욱/상욱/Shariff (전체 감독·승인·의사결정)
       ↓
[해외 공급업체/포워더] → 해외 inbound 선적 서류
       ↓
[UAE 입항 · 통관] → M80~M92 ★ Arvin (해외 BOE/DO/MSDS/FANR/MOIAT/EC/BL)
       ↓
[국내 LPO 문서 준비] → M10~M30 ★ Karthik (국내 LPO/PL/DN/MTC)
       ↓
[자재 현황·Vendor·기성 검토] → M50~M130 / M160 ★ 차민규 (자재 현황, 청구서 확인, 업체 기성 지급 검토)
       ↓
[창고 입고·보관·출고] → M100~M121 ★ kEn (LPO/WarehouseTask)
       ↓ (WH_MOSB/MOSB_DIRECT 패턴)
[MOSB 해상 구간] → M115~M117 ★ Haitham (SR/LCT/RORO/LOLO)
       ↓
[MOSB(VP24) 현장 감독] → AGI/DAS 향 화물, container stuffing, MOSB 야외 창고 ★ Jhysn
       ↓
[VP24 담당] → VP24 lifting/stuffing/offloading, crane/forklift 상태 ★ Ronnel/ronpap20
       ↓
[현장 수령·검수·인수인계] → M130~M140 ★ Roldan (Site/POD/GRN/Backload)
       ↓
[비용 정산 완료] → M160 ★ 차민규 검토 + 정상욱 승인 / Finance Human-gate
```

---

## 2. 마일스톤별 책임 매트릭스

| 마일스톤 | 이름 | 주 책임 | 보조·증빙·검토 |
|---------|------|---------|----------------|
| M10 | Cargo Ready | Karthik | 정상욱 감독, 차민규 vendor 상태 확인 |
| M20 | Packed / Marked | Karthik | 차민규 vendor PL 취합 보조 |
| M30 | Pickup Completed | Karthik | Roldan/Jhysn/Ronnel 현장 정보 보조 |
| M50 | Terminal Received | 차민규 | 정상욱 감독 |
| M80 | ATA (입항) | Arvin | 정상욱 감독 |
| M90 | BOE Submitted | Arvin | 정상욱 감독 |
| M91 | BOE Cleared | Arvin | 정상욱 승인·감독 |
| M92 | DO Released | Arvin | Roldan 현장 입차 준비 |
| M100 | Gate-out | Arvin / Roldan / Karthik | kEn 배차 확인, Jhysn MOSB(VP24) 현장 차량·container 식별, Ronnel VP24 일부 gate pass 요청 정보 |
| M110 | WH Received (WH In) | kEn | Karthik PL/DN/MTC 선행자료, Haitham SR 제출, 차민규 자재 현황 확인 |
| M111 | Put-away | kEn | 정상욱 감독 |
| M115 | MOSB Staged | Haitham | Jhysn은 MOSB(VP24) AGI/DAS 향 화물·야외 창고 현장 감독, Ronnel/ronpap20은 VP24 작업 상태 보고 |
| M116 | LCT/Barge Loaded | Haitham | Jhysn은 container stuffing 감독, Ronnel/ronpap20은 VP24 stuffing·lifting 상태 보고 |
| M117 | Sail-away Approved | Haitham | 정상욱 감독, Jhysn MOSB(VP24) 현장 상태 확인 |
| M120 | Picked / Staged | kEn | Jhysn은 MOSB(VP24) staged 상태 감독, Ronnel/ronpap20은 VP24 stuffing/offloading/lifting 진행률 확인 |
| M121 | Dispatched | kEn | Roldan 인수 대기 |
| M130 | Site Arrived | Roldan | Jhysn은 AGI/DAS 출고 전 MOSB(VP24) 상태 증빙, Ronnel/ronpap20은 VP24 작업 완료 증빙 |
| M131 | Site Inspected (Good) | Roldan | Jhysn MOSB(VP24) 출고 상태 증빙, Ronnel VP24 작업 증빙 |
| M132 | Site Inspected (OSD) | Roldan | Jhysn MOSB(VP24) damage/bent 상태 감독, Ronnel VP24 작업 상태 보고 |
| M140 | POD / GRN / Backload | Roldan | Ronnel/ronpap20 webbing sling 등 reusable gear 회수 요청, Jhysn MOSB 야외 창고 상태 확인, kEn 재고 이력 |
| M150 | Claim Opened | Roldan | Arvin SIM claim, 정상욱 감독 |
| M160 | Cost Closed | 차민규 검토 / 정상욱 승인 | Finance Human-gate, Invoice·기성 지급 증빙 확인 |

> ★ = 주 책임자 / ◎ = 보조 또는 연관 역할

---

## 3. RoutingPattern별 팀원 관여도

| RoutingPattern | 주 책임 흐름 | 보조·검토 |
|----------------|--------------|-----------|
| `DIRECT` | Arvin M90~92 → Roldan M130~140 | Karthik 국내 LPO 문서, Material Management 자재·vendor·M160 검토 |
| `WH_ONLY` | Arvin M90~92 → kEn M110~121 → Roldan M130~140 | Karthik PL/DN/MTC, 차민규 자재 현황, Jhysn/Ronnel 현장 증빙 |
| `MOSB_DIRECT` | Arvin M90~92 → Haitham M115~117 → Roldan M130~140 | Jhysn은 MOSB(VP24) AGI/DAS 향 화물 현장 감독, Ronnel/ronpap20은 VP24 작업상태 보고, 정상욱 감독 |
| `WH_MOSB` | Arvin M90~92 → kEn M110~120 → Haitham M115~117 → Roldan M130~140 | Karthik DSV 야드 복구, 차민규 vendor·기성 검토, Jhysn은 MOSB 야외 창고·stuffing 감독, Ronnel은 VP24 담당 |
| `MIXED` | 정상욱이 상황별 책임 경로 확정 | 각 담당자는 자기 milestone 증빙만 책임지고, 차민규는 비용·기성 검토를 M160에 연결 |

---

## 4. 업무 영역 비교표

| 인물 | 도메인 | 핵심 산출물 / 확인값 | E2E 위치 |
|------|--------|----------------------|----------|
| 정상욱 / 상욱 / Shariff | 팀장 overlay | 전체 운영 지시, 승인, vessel/backload coordination | M10~M160 전체 감독 |
| 차민규 / Minkyu | Material Management | 자재 현황, vendor coordination, 청구서 확인, 업체 기성 지급 검토 | M50~M130 + M160 |
| Arvin | 해외 inbound 서류·통관 | BOE, DO, MSDS, FANR, MOIAT, EC, BL(Bill of Lading) | M80~M92 |
| Karthik | 국내 LPO 중심 서류 | 국내 LPO, PL, DN, MTC, Revised PL, Gate Pass | M10~M30/M100 |
| kEn / Ken | 창고·LPO 실행 | LPO 실행현황, WH Receipt, dispatch instruction | M100~M121 |
| Haitham | 선박·MOSB | SR, LCT 위치보고, 선적완료, MOSB staging | M115~M117 |
| Roldan / DaN | 현장 수령·Backload | POD, GRN, Backload, CCU 회수, OSD trigger | M130~M150 |
| Jhysn / Jhason / Jason | MOSB(VP24) 현장 감독 | AGI/DAS 향 화물 현장 감독, container stuffing, MOSB 야외 창고 관리, exit pass 요청 정보 | M100/M115/M116/M120/M130/M140 감독·보조 |
| Ronnel / ronpap20 | VP24 담당 | VP24 lifting, stuffing, offloading, crane/forklift 상태, webbing sling 회수 | M115/M116/M120/M130/M140 보조 |

---

## 5. 역할 중복/공백 분석

### 5-1. 중복 영역 (정상적 협력)
| 중복 업무 | 담당자 1 | 담당자 2 | 조율 방법 |
|-----------|---------|---------|----------|
| Gate/Exit Pass 처리 | Arvin (이메일 발송) | Roldan/kEn/Karthik (현장·창고·SCT 건별 실행) | Arvin은 문서 발송, Roldan은 MOSB 입차 준비, kEn은 창고·현장 실행, Karthik은 SCT/DSV 야드 Gate Pass 조율 |
| LPO 처리 | kEn (창고·현장 실행 보고) | Karthik/Roldan (국내 LPO 서류·장비 LPO) | kEn은 운영표, Karthik은 국내 LPO 기반 PL/DN/MTC와 vendor status, Roldan은 장비 렌탈 LPO·timesheet |
| TPI 문서 관리 | Arvin (추적·요청) | Haitham/kEn/Roldan (검사·납기·갱신 행정) | Arvin은 문서 추적, Haitham은 현장 검사, kEn은 Webbing Sling 납기, Roldan은 장비 TPI 갱신 SR |
| 선적 트래킹 보고 | Arvin (해외·통관) | Haitham (선박·MOSB) | 구간별 분리 (통관 vs 해상) |
| BL 용어 | Arvin (Bill of Lading) | Roldan/kEn (Backload) | Arvin 문서의 BL은 선하증권, Roldan/kEn 문서의 BL은 Backload로 구분 |
| DSV Follow-up | Arvin (해외 inbound 통관·서류 조건 조율) | kEn/Roldan (창고·현장 실행) | Arvin은 DSV Minhaj와 해외 서류 미완료 건을 조율하고, kEn/Roldan은 출고·배송·수령 실행을 담당 |
| DSV 야드 자재 복구 | Karthik (damaged box/HE case 수리 확인) | kEn/Roldan (창고 위치·현장 배송) | Karthik은 수리 확인과 delivery permission, kEn은 창고 상태 보고, Roldan은 현장 배송·수령 |
| SR 처리 | Haitham (WELLS ID 기반 운영 SR) | Roldan/Karthik (장비·소모품·Gate Pass성 행정) | Haitham은 해상·창고 운영 SR, Roldan은 장비·소모품 SR/PR, Karthik은 Gate Pass 성격의 서비스 요청 보조 |
| Delivery Coordination | Roldan (실제 배송 실행·수령 확인) | Arvin/kEn/Karthik (해외 통관·창고·국내 LPO 서류 선행 처리) | Arvin은 해외 통관·DSV 요청, kEn은 창고 출고 지시, Karthik은 국내 LPO 기반 PL/DN/MTC 제공, Roldan은 현장 수령 확인 |
| Backload/CCU | Roldan (회수·반납·수거 실행) | kEn/Haitham (재고 보고·이력 확인) | Roldan은 Backload 운송과 폐기물 CCU 수거, kEn은 BL Laydown 보고, Haitham은 MOSB 작업 중 CCU 이력 확인 |

### 5-2. 잠재적 공백 (리스크)
| 공백 영역 | 문제 상황 | 권장 커버 |
|-----------|---------|----------|
| kEn 부재 시 LPO 처리 | 창고 협력사 작업 불가 | 상욱/Shariff가 긴급 LPO 승인 |
| Karthik 부재 시 국내 LPO PL/DN/MTC 취합 | PL 없이는 un-stuffing 및 MRR 생성이 지연되고 국내 vendor 연락 창구가 공백화됨 | Khemlal(SCT)을 1차 백업으로 지정하고 국내 LPO vendor 연락처·PL tracker를 공유 |
| Arvin 부재 시 통관 | BOE/DO 처리 전면 중단 | 사전 위임 절차 필요 |
| Haitham 부재 시 선박 트래킹 | MOSB 계획 시야 상실 | Khemlal(SCT) 임시 대행 |
| Roldan 부재 시 현장 수령·Backload | 현장 도착·검수·Backload 데이터가 끊김 | kEn/Nicole/Site team 기준 인수인계표 운영 |

---

## 6. 온톨로지 클래스 책임 요약

| 온톨로지 클래스 | 주 담당자 |
|----------------|---------|
| `ActorRole.LogisticsTeamLeader` · `ApprovalAction` | **정상욱/상욱/Shariff** |
| `MaterialMaster` · `Shipment` · `MilestoneEvent` | **차민규** 자재 현황 관리 |
| `Invoice` · `InvoiceLine` · `CostTransaction` · `CostGuardResult` | **차민규** 청구서 확인·업체 기성 지급 검토 / **정상욱** 승인 |
| `CustomsEntry` · `BOE` · `DO` | **Arvin** |
| `PermitApplication` (FANR/MOIAT/EC) | **Arvin** |
| 국내 `PackingList` · `DeliveryNote(DN)` · `MaterialTransferCertificate(MTC)` | **Karthik** |
| `Container(CCU)` · `ServiceRequest(Gate Pass)` · `WarehouseTask(현장 검증)` | **Karthik** |
| `WarehouseTask` · `WarehouseHandlingProfile` | **kEn** |
| `LPO (LocalPurchaseOrder)` | **kEn** 실행 주 담당 / **Karthik** 국내 LPO 서류·vendor status / **Roldan** 장비 렌탈 LPO |
| `ServiceRequest (SR)` · `MarineEvent` · `LCT` | **Haitham** 주 담당 / **Roldan** 장비·소모품 SR/PR 행정 |
| `MilestoneEvent.M115~M117` | **Haitham** |
| `SiteReceipt` · `POD` · `GRN` · `BackloadEvent` | **Roldan** |
| `Exception (OSD/Damage)` → `Claim` | **Roldan** |
| `FieldEvidence` · `CommunicationEvent` · `EquipmentStatusReport` | **Jhysn** MOSB(VP24) 현장 감독 증빙 / **Ronnel/ronpap20** VP24 handling 증빙 |
| `OffshoreStaging` · `LaydownArea` · `StuffingEvent` | **Jhysn** MOSB 야외 창고·container stuffing 감독 |
| `LiftingEvent` · `StuffingEvent` · `EquipmentResource` | **Ronnel/ronpap20** VP24 작업 담당 |

---

*본 문서는 `individual_rev`의 개인별 주요업무 문서 9개와 온톨로지 00/01 문서를 기준으로 통합 작성되었습니다.*

<!-- 2026-04-27-10person-update -->
## 7. 2026-04-27 통합 역할 반영

> 기준 자료: `individual_rev` 개인별 주요업무 문서 + duckdb_query_results.json

| 인물 | 추가 반영된 핵심 역할 | 기존 5명과의 경계 |
|------|----------------------|------------------|
| Jhysn | MOSB(VP24)에서 AGI/DAS 향 모든 화물의 현장 감독, container stuffing, MOSB 야외 창고 관리 | Ronnel/ronpap20은 VP24 담당, Haitham은 LCT/MOSB 해상 운영, Roldan은 최종 현장 수령 책임 |
| Ronnel/ronpap20 | VP24 담당 — VP24 lifting, stuffing, offloading, forklift/crane 상태 확인 | Jhysn은 MOSB(VP24) 현장 감독, Roldan은 최종 현장 수령 책임, kEn은 창고 운영 |
| 정상욱(Sanguk) | Team Lead overlay — 전체 팀 운영, vessel movement report, backload coordination | 상욱/Shariff 동일인으로서 물류팀 팀장 직무 전결 |
| 차민규(Minkyu) | Material Management overlay — vendor coordination, 청구서 확인, 업체 기성 지급 검토 | Material Management 담당으로서 vendor·invoice/payment 검토 보조 |

### 7-1. 확장 E2E 보조 구간

| 구간 | 주 담당 | 보조·증빙 |
|------|---------|----------|
| M10 Cargo Ready | Karthik | 정상욱(Team Lead 관할shipment 확인) |
| M20 Packed/Marked | Karthik | 차민규(vendor PL 취합 보조) |
| M30 Pickup | Karthik | Roldan/Jhysn/Ronnel 현장 정보 보조 |
| M80 ATA | Arvin | - |
| M90 BOE Submitted | Arvin | - |
| M100 Gate-out | Arvin/Roldan/Karthik | Jhysn은 MOSB(VP24) 현장 차량·container 식별 정보 제공 |
| M110 WH Received | kEn | Haitham(SR 작성) |
| M115 MOSB Staged | Haitham | Jhysn은 MOSB(VP24) AGI/DAS 향 화물·야외 창고 감독, Ronnel/ronpap20은 VP24 작업 상태 보고 |
| M116 Loaded/Staged | Haitham | Jhysn은 container stuffing 감독, Ronnel/ronpap20은 VP24 stuffing/lifting 작업 상태 보고 |
| M120 Picked/Staged | kEn | Jhysn은 MOSB(VP24) staged 상태 감독, Ronnel/ronpap20은 VP24 stuffing/offloading/lifting 진행률 확인 |
| M130 Site Arrived | Roldan | Jhysn은 AGI/DAS 출고 전 MOSB(VP24) 상태 증빙, Ronnel/ronpap20은 VP24 작업 완료 증빙 |
| M140 Backload | Roldan | Ronnel/ronpap20은 webbing sling 등 reusable gear 회수 요청 보조, Jhysn은 MOSB 야외 창고 상태 확인 |

### 7-2. 공백 리스크

| 공백 영역 | 영향 | 1차 보완 |
|---------|------|----------|
| Jhysn 부재 | MOSB(VP24)에서 AGI/DAS 향 화물, container stuffing, 야외 창고 현장 감독 공백 | Haitham이 MOSB 해상 운영 기준으로 임시 판단하고, Ronnel/ronpap20은 VP24 작업 상태를 별도 보고 |
| Ronnel/ronpap20 부재 | VP24 lifting·stuffing·offloading 상태 확인이 늦어짐 | Jhysn이 MOSB(VP24) 현장 감독 기준으로 상태를 재확인하고 kEn이 창고 상태를 재확인 |
| 정상욱(Team Lead) 부재 | 팀 전체 운영·승인· vessel movement 보고 공백 | Shariff(동일인)가 직접 운영 |
| 차민규(Material mgmt) 부재 | vendor coordination·청구서 확인 차질 | 정상욱이 직접 vendor·invoice 검토 조율 |
| Minkyu 부재 시 청구서/기성 지급 | 청구서 확인과 업체 기성 지급 검토 지연 가능성 | 정상욱/Shariff 승인 루틴으로 보완 |

<!-- 2026-04-27-10person-update -->

<!-- 2026-04-27-fmc-identity-matrix-start -->
## 8. 2026-04-27 FMC 조직도 식별 검증표

> 기준 자료: `../FMC_OrgChart_Data.json`
> 개인정보 처리: 이메일/전화번호는 최종 배포본에서 마스킹한다.
> DuckDB 기준: `email_search.duckdb` (OUTLOOK_HVDC_ALL_202409202510.xlsx 기반) — 직접 이메일 기준 / handle 언급 기준

| 문서 기준 인물 | 대화·문서 표기 | 조직도 실명 | 조직도 직책 | SITE | 조직도 이메일 | ontology ActorRole | DuckDB 직접메일 | DuckDB handle검색 | 검증 상태 |
|---|---|---|---|---|---|---|---|---|---|
| 정상욱/상욱 | 정상욱/상욱/Jeong | Sanguk Jeong | Logistic Manager | MUSSAFAH | su***@samsung.com | `LogisticsTeamLeader` | 66건 | 4,513건 | 조직도 JSON + DuckDB 확인 |
| 차민규 | 차민규/Minkyu | Minkyu Cha | Material Management | MUSSAFAH | mi***@samsung.com | `MaterialManagementCoordinator` | 0건 | 1,335건 | 조직도 JSON + DuckDB 확인 |
| Arvin | Arvin | Arvin Q. Caadan | Logistics Officer | MUSSAFAH | ar***@samsung.com | `OverseasInboundDocsCoordinator` | - | - | 조직도 JSON 기준 확인 |
| Karthik | Karthik, Karthik SCT Logistics | Karthik Raj | Storekeeper | MUSSAFAH | ka***@samsung.com | `DomesticLPODocumentController` | 557건 | 1,563건 | 조직도 JSON + DuckDB 확인 |
| kEn | kEn | Ken Espiritu Lopez | FMC | MUSSAFAH | ke***@samsung.com | `WarehouseExecutionCoordinator` | - | - | 조직도 JSON 기준 확인 |
| Roldan | Roldan, DaN | Roldan Mendoza | Logistics Officer | MUSSAFAH | rb***@samsung.com | `SiteReceivingCoordinator` | 1,563건 | 0건 | 조직도 JSON + DuckDB 확인 |
| Haitham | Haitham | Haitham Mohammad Madaneya | Marine Supervisor | MUSSAFAH | ha***@samsung.com | `MarineMOSBCoordinator` | 783건 | 3,049건 | 조직도 JSON + DuckDB 확인 |
| Jhysn | Jhysn, Jhason, Jason | Jhason Alim De Guzman | FMC | MUSSAFAH | jh***@samsung.com | `MOSBVP24FieldSupervisor` | 79건 | 0건 | 조직도 JSON + 사용자 역할 정정 반영 |
| Ronnel | Ronnel, ronpap20 | Ronnel Papa Initan | Logistics Officer | MUSSAFAH | p.***@samsung.com | `FieldHandlingSupport` | - | - | 조직도 JSON + 대표 문서 병합 확인 |

### 8-1. DuckDB 이메일 주요 키워드 요약

| 인물 | Email | Gate Pass | Delivery | Backload | BL | CCU | LPO | TPI | Site |
|------|-------|-----------|----------|----------|----|-----|-----|-----|------|
| 정상욱(Sanguk) | su***@samsung.com | - | 887 | 989 | - | - | - | - | - |
| 차민규(Minkyu) | mi***@samsung.com | - | - | - | - | - | - | - | - |
| Arvin | ar***@samsung.com | - | - | - | - | - | - | - | - |
| Karthik | ka***@samsung.com | 9 | 153 | - | 14 | 2 | 30 | 3 | 9 |
| kEn | ke***@samsung.com | - | - | - | - | - | - | - | - |
| Roldan | rb***@samsung.com | 15 | 421 | 92 | 21 | 32 | 41 | 30 | 47 |
| Haitham | ha***@samsung.com | 45 | 124 | 2 | 8 | 1 | 13 | 79 | 9 |
| Jhysn | jh***@samsung.com | - | - | - | 1 | - | - | - | - |
| Ronnel/ronpap20 | p.***@samsung.com | 1 | 3 | 1 | 4 | 2 | 0 | - | - |

### 8-2. Sanguk/Minkyu Team Lead overlay 역할 근거

**Sanguk (정상욱) DuckDB**:
- Vessel/movement 1,738회 — vessel movement report 전결·배포
- Backload 989회 — 전체 backload coordination 관할
- ADNOC/FANR/MOIAT 관련 문서 다수
- Top sites: AGI 1,313건, DAS 1,119건 — 전체 팀 운영 범위 반영

**Minkyu (차민규) DuckDB**:
- Material management keywords: logistics 341회, manager 264회, officer 194회
- Jopetwil-Marine 32건 — LCT marine coordination 관련
- haitham 244회, arvin 180회 — Material management로서 팀원들과의 협업 빈번
- 사용자 확인 반영 — 청구서 확인 및 업체 기성 지급 검토를 주요 업무로 등록

검증 판단: 팀 매트릭스는 역할 분담표이므로 전화번호는 포함하지 않는다. 조직도 실명·직책·이메일은 인물 식별 보조 근거로 사용하고, ontology 00/01 반영 시에는 ActorRole 중심으로 연결한다.
<!-- 2026-04-27-fmc-identity-matrix-end -->
