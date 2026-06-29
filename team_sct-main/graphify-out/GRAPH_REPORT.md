# Graph Report - .  (2026-06-14)

## Corpus Check
- 25 files · ~147,494 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 198 nodes · 283 edges · 15 communities (12 shown, 3 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.79)
- Token cost: 562,000 input · 15,000 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Cost & Invoice Allocation|Cost & Invoice Allocation]]
- [[_COMMUNITY_Member Work Areas & Marine Ops|Member Work Areas & Marine Ops]]
- [[_COMMUNITY_COST-GUARD & Port Pricing|COST-GUARD & Port Pricing]]
- [[_COMMUNITY_Warehouse & LPO Execution|Warehouse & LPO Execution]]
- [[_COMMUNITY_Core Ontology & Shipment Model|Core Ontology & Shipment Model]]
- [[_COMMUNITY_Marine & MOSB Handling|Marine & MOSB Handling]]
- [[_COMMUNITY_Customs Clearance & Regulatory|Customs Clearance & Regulatory]]
- [[_COMMUNITY_Site Receiving & Handover|Site Receiving & Handover]]
- [[_COMMUNITY_Routing Patterns & Analytics|Routing Patterns & Analytics]]
- [[_COMMUNITY_Locations & Offshore Sites|Locations & Offshore Sites]]
- [[_COMMUNITY_Document Guardian & OCR|Document Guardian & OCR]]
- [[_COMMUNITY_Communication Evidence Layer|Communication Evidence Layer]]
- [[_COMMUNITY_Claude Config Permissions|Claude Config Permissions]]
- [[_COMMUNITY_Incoterms Standard|Incoterms Standard]]
- [[_COMMUNITY_HVDC Code Tag|HVDC Code Tag]]

## God Nodes (most connected - your core abstractions)
1. `RoutingPattern (DIRECT/WH_ONLY/MOSB_DIRECT/WH_MOSB/MIXED)` - 14 edges
2. `ShipmentUnit (Operational Twin)` - 14 edges
3. `MarineOperation` - 12 edges
4. `Haitham (Haitham Mohammad Madaneya)` - 11 edges
5. `MaterialHandlingCase` - 11 edges
6. `Ken (Ken Espiritu Lopez)` - 10 edges
7. `Sanguk Jeong / Shariff (Logistics Team Lead)` - 10 edges
8. `HVDC 물류팀 역할분담 매트릭스` - 10 edges
9. `LocationNode` - 10 edges
10. `InvoiceLine` - 10 edges

## Surprising Connections (you probably didn't know these)
- `confirmedFlowCode (WH Handling Class)` --semantically_similar_to--> `RoutingPattern (DIRECT/WH_ONLY/MOSB_DIRECT/WH_MOSB/MIXED)`  [INFERRED] [semantically similar]
  CONSOLIDATED-02-warehouse-flow.md → C:/Users/jichu/Downloads/team/Team_role_allocation_matrix.en.md
- `Human-gate Control` --semantically_similar_to--> `Evidence-only Rule`  [INFERRED] [semantically similar]
  CONSOLIDATED-01-core-framework-infra.md → CONSOLIDATED-03-document-ocr.md
- `AuditRecord` --semantically_similar_to--> `ProofArtifact`  [INFERRED] [semantically similar]
  CONSOLIDATED-08-communication.md → CONSOLIDATED-05-invoice-cost.md
- `MarineRoutingPattern` --conceptually_related_to--> `RoutingPattern (DIRECT/WH_ONLY/MOSB_DIRECT/WH_MOSB/MIXED)`  [EXTRACTED]
  CONSOLIDATED-04-barge-bulk-cargo.md → C:/Users/jichu/Downloads/team/Team_role_allocation_matrix.en.md
- `CONSOLIDATED-03 Document Guardian & OCR` --references--> `CONSOLIDATED-00 Master Ontology`  [EXTRACTED]
  CONSOLIDATED-03-document-ocr.md → CONSOLIDATED-00-master-ontology.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **E2E Logistics Milestone Flow (M10~M160)** — member_karthik, member_minkyu_cha, member_arvin, member_ken, member_haitham, member_jhysn, member_ronnel, member_roldan, member_sanguk [EXTRACTED 1.00]
- **HVDC Team Role Allocation** — role_overseas_inbound_docs_coordinator, role_marine_mosb_coordinator, role_mosb_vp24_field_supervisor, role_domestic_lpo_document_controller, role_warehouse_execution_coordinator, role_material_management_coordinator, role_site_receiving_coordinator, role_field_handling_support, role_logistics_team_leader [EXTRACTED 1.00]
- **Gate/Exit Pass Multi-Owner Collaboration** — member_arvin, member_roldan, member_ken, member_karthik [EXTRACTED 1.00]
- **Customs Clearance Document Pack** — concept_bl, concept_boe, concept_do, concept_commercial_invoice, concept_packing_list [INFERRED 0.75]
- **AGI/DAS Offshore Marine Milestone Chain** — node_mosb, concept_marine_operation, concept_stowage_plan, concept_lashing_plan, concept_stability_case [EXTRACTED 1.00]
- **Warehouse Inbound Handling Flow** — concept_warehouse_receiving, concept_warehouse_handling_profile, concept_confirmed_flow_code, concept_milestone_model [EXTRACTED 1.00]
- **Invoice Audit Normalization Flow** — consolidated_05_invoice, consolidated_05_invoice_line, consolidated_05_charge_component, consolidated_05_rate_ref, consolidated_05_cost_guard_result, consolidated_05_proof_artifact [EXTRACTED 1.00]
- **AGI/DAS Offshore Delivery Milestone Chain** — consolidated_06_mosb_staging, consolidated_06_marine_readiness_gate, consolidated_06_site_receipt, concept_milestone_model [EXTRACTED 1.00]
- **Port Clearance to Gate-out Release Chain** — consolidated_07_port_clearance_case, consolidated_07_port_release_gate, consolidated_07_release_blocker, concept_milestone_model [EXTRACTED 0.85]

## Communities (15 total, 3 thin omitted)

### Community 0 - "Cost & Invoice Allocation"
Cohesion: 0.09
Nodes (27): Any-key Identity Resolution, DEM/DET Clock, CONSOLIDATED-00 Master Ontology Spine, Material Handling Chain, Port Operations, Vendor Payment / Cost Allocation, ChargeComponent, CostAllocation (+19 more)

### Community 1 - "Member Work Areas & Marine Ops"
Cohesion: 0.11
Nodes (24): CCU / Waste / Basket Management, Commercial Invoice (CI), Container Stuffing & Outdoor Warehouse Management, CONSOLIDATED-00 Milestone Model (M10~M160), Inspection / TPI / TUV Coordination, Invoice Checking & Vendor Progress Payment Review, Jopetwil 71 Marine Material Coordination, Material Inbound/Outbound Management (+16 more)

### Community 2 - "COST-GUARD & Port Pricing"
Cohesion: 0.12
Nodes (19): COST-GUARD Result Engine, CostGuardResult, High-value Human-gate (>100000 AED), PRISM.KERNEL Audit Proof, ProofArtifact, RateRef, RiskBand (PASS/WARN/HIGH/CRITICAL), TariffRef (+11 more)

### Community 3 - "Warehouse & LPO Execution"
Cohesion: 0.14
Nodes (18): Alphamed CCU Recovery Coordination, Delivery Note (DN), DSV Yard Material Management & Repair, LPO (Local Purchase Order), MOSB Marine Material Staging, MRR (Material Receipt Report), Material Transfer Certificate (MTC), Packing List / DN / MTC Preparation (+10 more)

### Community 4 - "Core Ontology & Shipment Model"
Cohesion: 0.17
Nodes (17): Any-key Resolution Flow, confirmedFlowCode (WH Handling Class), Flow Code Boundary Rule, Identifier (Logistics Key), JourneyLeg, JourneyStage Vocabulary, MilestoneEvent Model (M10~M160), ShipmentUnit (Operational Twin) (+9 more)

### Community 5 - "Marine & MOSB Handling"
Cohesion: 0.14
Nodes (17): LashingPlan / Seafastening, LCTOperation, LiftingPlan / Rigging, MarineOperation, MarineRoutingPattern, MOSB-Not-Warehouse Boundary Rule, OffshoreStagingNode (MOSB), Permit to Work (PTW) / FRA (+9 more)

### Community 6 - "Customs Clearance & Regulatory"
Cohesion: 0.19
Nodes (15): BL (Bill of Lading), BOE (Bill of Entry), Customs Clearance / CustomsEntry, Overseas Inbound Customs Clearance Documentation, DO (Delivery Order), FANR (Federal Authority for Nuclear Regulation), MOIAT / EC Approval, MSDS (Material Safety Data Sheet) (+7 more)

### Community 7 - "Site Receiving & Handover"
Cohesion: 0.19
Nodes (14): Backload (BL) Management, Exit Pass / Gate Pass Processing, Goods Received Note (GRN), OSDR (Over/Short/Damage Report), Proof of Delivery (POD), POD / GRN / Handover, Siemens (SIM) Claims & OSDR, SiteReceipt (+6 more)

### Community 8 - "Routing Patterns & Analytics"
Cohesion: 0.15
Nodes (13): RoutingPattern (DIRECT/WH_ONLY/MOSB_DIRECT/WH_MOSB/MIXED), AnalyticsRun, DataMappingRule, OperationDataset / OperationRecord, OperationalSnapshot, ReconciliationResult / DataQualityFinding, ReportArtifact (5-sheet / 27-sheet), DIRECT Routing Pattern (+5 more)

### Community 9 - "Locations & Offshore Sites"
Cohesion: 0.22
Nodes (10): AGI/DAS Offshore MOSB Gate Rule, LocationNode, TransportCorridor, AGI Island Site, DAS Island Site, Jebel Ali Port / Free Zone, Khalifa Port, MIR Site (+2 more)

### Community 10 - "Document Guardian & OCR"
Cohesion: 0.22
Nodes (9): ApprovalAction, AuditRecord, CommunicationEvent, Evidence-only Rule, Human-gate Control, LDG / OCR Pipeline, VerificationResult / TrustLayer, CONSOLIDATED-03 Document Guardian & OCR (+1 more)

### Community 11 - "Communication Evidence Layer"
Cohesion: 0.22
Nodes (9): Communication Evidence Layer, Operations Analytics & Reporting, CONSOLIDATED-08 Communication Evidence Ontology, CommunicationEvent, MessageThread, PIIRedactionRecord, SLAClock / EscalationRecord, Consume-only Analytics Principle (+1 more)

## Knowledge Gaps
- **82 isolated node(s):** `allow`, `MSDS (Material Safety Data Sheet)`, `Siemens (SIM) Claims & OSDR`, `DSV (Logistics Partner)`, `SR (Service Request) Submission` (+77 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ShipmentUnit (Operational Twin)` connect `Core Ontology & Shipment Model` to `Cost & Invoice Allocation`, `Marine & MOSB Handling`, `Customs Clearance & Regulatory`, `Site Receiving & Handover`, `Routing Patterns & Analytics`, `Communication Evidence Layer`?**
  _High betweenness centrality (0.283) - this node is a cross-community bridge._
- **Why does `RoutingPattern (DIRECT/WH_ONLY/MOSB_DIRECT/WH_MOSB/MIXED)` connect `Routing Patterns & Analytics` to `Cost & Invoice Allocation`, `Member Work Areas & Marine Ops`, `Core Ontology & Shipment Model`, `Marine & MOSB Handling`?**
  _High betweenness centrality (0.190) - this node is a cross-community bridge._
- **Why does `MarineOperation` connect `Marine & MOSB Handling` to `Core Ontology & Shipment Model`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **What connects `allow`, `MSDS (Material Safety Data Sheet)`, `Siemens (SIM) Claims & OSDR` to the rest of the system?**
  _88 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Cost & Invoice Allocation` be split into smaller, more focused modules?**
  _Cohesion score 0.09116809116809117 - nodes in this community are weakly interconnected._
- **Should `Member Work Areas & Marine Ops` be split into smaller, more focused modules?**
  _Cohesion score 0.10507246376811594 - nodes in this community are weakly interconnected._
- **Should `COST-GUARD & Port Pricing` be split into smaller, more focused modules?**
  _Cohesion score 0.12280701754385964 - nodes in this community are weakly interconnected._