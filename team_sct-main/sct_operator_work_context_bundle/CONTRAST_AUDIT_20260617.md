# sct_operator_work_context.html — 색상·명암비 점검 (WCAG)

- date: 2026-06-17 · 방식: 라이브 프리뷰 실측 + 실효(opacity 블렌딩) 대비 계산 · 기준: 텍스트 4.5:1 / UI·그래픽 3:1
- **결론: 텍스트·노드·팔레트는 처음부터 전부 PASS. 유일한 미달이던 그래프 엣지/보더 대비를 수정해 전 항목 PASS로 정리.**

## 텍스트 (≥4.5:1) — 전부 PASS
| 쌍 | 대비 |
|---|---|
| 본문 #e6e6ef / bg #0c0c16 | 15.68 |
| 본문 / panel #15152a | 14.44 |
| muted #8a8aa8 / bg | 5.82 |
| muted / panel2 #1d1d38 | 4.89 |
| accent #6ea8e0 / bg | 7.72 |
| 노드 폰트 #cfcfe6 / bg | 12.71 |
| AMBER #f2c14e / bg | 11.59 |

## 팔레트 (그래픽 ≥3:1) — 전부 PASS
- 팀원 9색: 4.28(Sanguk #4E79A7) ~ 12.08(Jhysn #EDC948)
- 타입 5색: 4.28 ~ 8.04

## 그래프 엣지·보더 — 수정 (실효 대비, opacity 반영)
| 요소 | before | after | 판정 |
|---|---|---|---|
| 기본 엣지(PASS, 278개) | `#3a3a55`@0.75 = **1.49 FAIL** | `#66669a`@0.9 = **3.16** | ✅ |
| INFERRED 엣지(=AMBER 8개) | amber + dashed (색 ternary상 amber 우선) | 동일, amber 11.59 + dashed | ✅ |
| INFERRED 비-AMBER fallback | `#5a5a80`@0.55 = 1.69 | `#8585b2`@0.78 = 3.78 (현재 0건) | ✅ |
| 패널 보더 `--line` | `#4a4a7e` = **2.38 FAIL** | `#5c5c98` = **3.19** | ✅ |

## spotlight 효과 (이전 추가분) 영향 점검
- 사람 클릭 흑백 회색 `#646464` = 3.29:1 (PASS) — 흐려도 형태 식별 가능.
- 비포커스 엣지 `#2c2c36`@0.16 = 1.41 (의도적 dim, 디자인상 거의 비표시 — 유지).
- 복원 시 새 엣지색 `#66669a` 정상 적용 확인.

## 수정 파일
- `sct_operator_work_context.html` (단일 오프라인): `--line` 토큰 1곳 + `edgeView` 색/opacity 1곳
- 백업: `20260617_sct_operator_work_context_pre-spotlight_v1.html.bak`
