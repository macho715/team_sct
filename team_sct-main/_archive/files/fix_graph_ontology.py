#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fix_graph_ontology.py  —  HVDC Team Ontology graph_pro.html 정제 패치
=====================================================================
검증 리포트(AMBER)에서 도출된 6개 결함을 결정론적으로 수정한다.

  FIX-1 (O3,P0) 노이즈 제거   : .claude/settings.local.json 설정 노드 3개 + 인접 엣지 제거
  FIX-2 (O2,P0) 중복 클래스 머지: 동일 클래스의 문서별 복제 노드를 canonical(00 우선)로 병합 + 엣지 리다이렉트/디둡
  FIX-3 (O4,P0) HVDCCodeTag 연결: 고립(deg0) 핵심 식별자를 Identifier/ShipmentUnit/Any-key에 연결
  FIX-4 (O5,P1) 커뮤니티 라벨   : comm0 "Cost & Invoice Allocation" 오라벨 → 실제 구성(05~07) 반영
  FIX-5 (O6,P2) 술어 의미론     : member→role/concept 의 implements → performs (행위자-역할 관계)
  FIX-6 (B5,P2) PII 경로 마스킹 : src 의 C:/Users/jichu/Downloads/team/ → team/

이후 deg / size / bridges / ftCounts / stats 를 재계산한다.
입력 HTML 의 DATA 리터럴만 교체하므로 나머지 코드/스타일/스크립트는 100% 보존된다.

사용법:
  python3 fix_graph_ontology.py <input.html> <output.html> [--changelog changes.json]
"""
import re, sys, json, argparse
from collections import defaultdict

# ---------------------------------------------------------------- 설정 테이블
NOISE_PREFIXES = ("claude_settings",)                       # FIX-1

MERGE = {                                                   # FIX-2  dup -> canonical
    "consolidated_06_site_receipt":        "concept_site_receipt",
    "consolidated_08_communication_event": "concept_communication_event",
    "consolidated_08_approval_action":     "concept_approval_action",
    "consolidated_08_audit_record":        "concept_audit_record",
    "consolidated_07_port_call":           "concept_port_call",
    "concept_anykey_resolution":           "concept_any_key_resolution",
    "concept_master_ontology":             "consolidated_00_master_ontology",
}

NEW_EDGES = [                                               # FIX-3  HVDCCodeTag 연결
    {"from": "concept_shipment_unit",      "to": "concept_hvdc_code_tag", "rel": "references",              "conf": "EXTRACTED"},
    {"from": "concept_hvdc_code_tag",      "to": "concept_identifier",    "rel": "conceptually_related_to", "conf": "EXTRACTED"},
    {"from": "concept_any_key_resolution", "to": "concept_hvdc_code_tag", "rel": "references",              "conf": "EXTRACTED"},
]

COMM0_NEW_LABEL = "Cost/Material/Port (05–07)"             # FIX-4
PII_FIND, PII_REPL = "C:/Users/jichu/Downloads/team/", "team/"   # FIX-6
NEW_RELATION = "performs"                                   # FIX-5


# ---------------------------------------------------------------- 유틸
def edge_key(e):                       # 무방향 + 관계 기준 중복 판정 키
    a, b = e["from"], e["to"]
    return (a, b, e["rel"]) if a <= b else (b, a, e["rel"])


def transform(data, log):
    nodes, edges = data["nodes"], data["edges"]
    by_id = {n["id"]: n for n in nodes}

    # --- FIX-1 노이즈 노드 제거 -------------------------------------------
    noise = {n["id"] for n in nodes if n["id"].startswith(NOISE_PREFIXES)}
    nodes = [n for n in nodes if n["id"] not in noise]
    before_e = len(edges)
    edges = [e for e in edges if e["from"] not in noise and e["to"] not in noise]
    log["fix1_removed_nodes"] = sorted(noise)
    log["fix1_removed_edges"] = before_e - len(edges)

    # --- FIX-6 PII 경로 마스킹 (노드 제거 후) -----------------------------
    masked = 0
    for n in nodes:
        if PII_FIND in n.get("src", ""):
            n["src"] = n["src"].replace(PII_FIND, PII_REPL)
            masked += 1
    log["fix6_paths_masked"] = masked

    # --- FIX-2 중복 머지 (엣지 리다이렉트) --------------------------------
    merged_present = {d for d in MERGE if d in {n["id"] for n in nodes}}
    nodes = [n for n in nodes if n["id"] not in MERGE]      # 복제 노드 삭제
    for e in edges:
        e["from"] = MERGE.get(e["from"], e["from"])
        e["to"]   = MERGE.get(e["to"],   e["to"])
    log["fix2_merged"] = {k: MERGE[k] for k in sorted(merged_present)}

    # --- FIX-3 신규 엣지 추가 ---------------------------------------------
    edges.extend(NEW_EDGES)
    log["fix3_new_edges"] = [f'{e["from"]} -[{e["rel"]}]-> {e["to"]}' for e in NEW_EDGES]

    # 엣지 정리: 자기루프 제거 + 디둡(EXTRACTED 우선)
    cleaned, seen = [], {}
    dropped_self = dropped_dup = 0
    for e in edges:
        if e["from"] == e["to"]:
            dropped_self += 1
            continue
        k = edge_key(e)
        if k in seen:
            j = seen[k]
            if cleaned[j]["conf"] == "INFERRED" and e["conf"] != "INFERRED":
                cleaned[j] = e          # EXTRACTED 가 INFERRED 를 대체
            dropped_dup += 1
            continue
        seen[k] = len(cleaned)
        cleaned.append(e)
    edges = cleaned
    log["fix2_dropped_selfloops"] = dropped_self
    log["fix2_dropped_dupedges"]  = dropped_dup

    by_id = {n["id"]: n for n in nodes}

    # --- FIX-5 술어 implements -> performs (member -> role/concept) -------
    changed = 0
    for e in edges:
        f, t = by_id.get(e["from"]), by_id.get(e["to"])
        if (e["rel"] == "implements" and f and f["ft"] == "document"
                and e["from"].startswith("member_")
                and (e["to"].startswith("role_") or e["to"].startswith("concept_"))):
            e["rel"] = NEW_RELATION
            changed += 1
    if NEW_RELATION not in data["relations"]:
        data["relations"].append(NEW_RELATION)
    log["fix5_predicate_relabeled"] = changed

    # --- FIX-4 comm0 라벨 정정 -------------------------------------------
    relabeled = 0
    for n in nodes:
        if n.get("comm") == 0 and n.get("commLabel") != COMM0_NEW_LABEL:
            n["commLabel"] = COMM0_NEW_LABEL
            relabeled += 1
    log["fix4_comm0_relabeled"] = relabeled
    log["fix4_comm0_new_label"] = COMM0_NEW_LABEL

    # ---------------------------------------------------------------- 재계산
    deg = defaultdict(int)
    cross = defaultdict(int)
    for e in edges:
        f, t = by_id.get(e["from"]), by_id.get(e["to"])
        if not f or not t:
            continue
        deg[e["from"]] += 1
        deg[e["to"]]   += 1
        if f.get("comm") != t.get("comm"):     # cross-community = bridge
            cross[e["from"]] += 1
            cross[e["to"]]   += 1
    for n in nodes:
        n["deg"]     = deg.get(n["id"], 0)
        n["bridges"] = cross.get(n["id"], 0)
        n["size"]    = max(6, n["deg"] * 3)

    ft_counts = defaultdict(int)
    for n in nodes:
        ft_counts[n["ft"]] += 1

    data["nodes"]      = nodes
    data["edges"]      = edges
    data["ftCounts"]   = dict(ft_counts)
    data["stats"] = {
        "nodes":       len(nodes),
        "edges":       len(edges),
        "communities": len({n["comm"] for n in nodes}),
        "inferred":    sum(1 for e in edges if e["conf"] == "INFERRED"),
        "hyperedges":  data["stats"].get("hyperedges", 0),
    }
    log["result_stats"] = data["stats"]
    log["result_ftCounts"] = data["ftCounts"]
    return data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp"); ap.add_argument("out")
    ap.add_argument("--changelog", default=None)
    a = ap.parse_args()

    raw = open(a.inp, encoding="utf-8").read()
    m = re.search(r"const DATA = (\{.*?\});\r?\nconst TYPE_COLORS", raw, re.S)
    if not m:
        sys.exit("DATA block not found")
    data = json.loads(m.group(1))

    log = {}
    data = transform(data, log)

    new_lit = "const DATA = " + json.dumps(data, ensure_ascii=False, separators=(",", ":")) + ";"
    out = raw[:m.start()] + new_lit + raw[m.start() + len(m.group(0)) - len("\nconst TYPE_COLORS"):]
    # 위 슬라이싱은 'const TYPE_COLORS' 앞까지 교체; 줄바꿈 보존 위해 재구성
    out = raw.replace(m.group(0), new_lit + "\r\nconst TYPE_COLORS")
    open(a.out, "w", encoding="utf-8", newline="").write(out)

    if a.changelog:
        json.dump(log, open(a.changelog, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=2)
    print(json.dumps(log, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
