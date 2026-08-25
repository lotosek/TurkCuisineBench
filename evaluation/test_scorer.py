#!/usr/bin/env python3

from score_pilot import normalize_tr, score


CASES = [
    ("ZIRH", "zırh", "zırh", "CO"),
    ("Cevap: Çığ.", "çığ", "çığ", "CO"),
    ("  ARMUT   biçimli bardaklar ", "armut biçimli bardaklar", "armut biçimli bardak | armut biçimli bardaklar", "CO"),
    ("2–4", "2-4", "2-4 | 2 ila 4", "CO"),
    ("Bilmiyorum", "bilmiyorum", "su", "NA"),
    ("Su çünkü gelenek böyledir.", "su çünkü gelenek böyledir", "su", "REVIEW"),
    ("Ince belli bardak", "ınce belli bardak", "ince belli bardak", "REVIEW"),
    ("15", "15", "15 | %15", "CO"),
]


for raw, expected_normalized, accepted, expected_label in CASES:
    assert normalize_tr(raw) == expected_normalized, (raw, normalize_tr(raw), expected_normalized)
    assert score(raw, accepted)["auto_label"] == expected_label, (raw, score(raw, accepted), expected_label)

print(f"PASS: {len(CASES)} scorer cases")
