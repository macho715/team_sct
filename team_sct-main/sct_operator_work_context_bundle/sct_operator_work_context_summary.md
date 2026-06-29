# SCT Operator Work Context Overlay

- Output: `sct_operator_work_context.html`
- Purpose: Replace the former AI metadata/verdict panel with an operator work-context panel.
- Language: English UI for the work panel and export text.
- Coverage: 191.00 nodes / 286.00 edges mapped to operator workstreams.
- Review queue: 27.00 AMBER nodes / 8.00 AMBER edges.

## How to use

1. Open the HTML file.
2. Choose an **Operator lens** from the right panel.
3. Click any graph node.
4. Read **Related workstream**, **Current stage**, **Primary owner**, **Your relation**, **What to check now**, **Immediate action**, and **Next handoff**.
5. Use **Copy Work Instruction** or **Operator JSON** for work queue handoff.

## Design boundary

The overlay is an operator guidance layer. It is not source-system truth and does not update ERP/WMS/ATLP/Foundry unless an approved Foundry Action writes back.
