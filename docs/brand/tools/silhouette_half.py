"""Generates the CapybaraSilhouette path: the right half is hand-placed against
source/capybara-v2.png (see README), then mirrored so the shape is exactly symmetric.

usage: python3 silhouette_half.py  -> prints the SVG path data
"""
# Right half of the front-facing capybara, clockwise from the top of the yuzu to the centre between the feet.
# Mirrored to make the left half. Units: view box 62 x 100.
W = 62
start = (31, 0.2)
right = [
    ((35.6, 0.2), (39.3, 3.9), (39.3, 8.5)),        # yuzu
    ((39.3, 10), (39, 11.3), (38.5, 12)),
    ((40.5, 11.3), (42.5, 11.2), (44.5, 11.6)),     # head top
    ((45.5, 8.8), (49, 8.4), (52.5, 8.5)),          # ear
    ((56.5, 8.6), (58.6, 11.5), (57.8, 16)),
    ((57.3, 19), (55.5, 21), (55.5, 24.5)),          # temple
    ((55.5, 30), (61.4, 33), (61.4, 40)),            # cheek
    ((61.4, 46), (57.5, 48), (57.5, 52)),            # neck
    ((57.5, 57), (62, 63), (62, 71.5)),              # belly
    ((62, 82), (56.5, 90), (51, 93)),                # bottom
    ((50.4, 96), (51, 99.8), (48, 99.8)),            # foot
    ((44, 99.8), (42, 99.8), (39, 99.8)),
    ((37, 99.8), (36.8, 95.5), (36.4, 93.6)),        # inner leg
    ((34.5, 93), (33, 92.8), (31, 92.8)),            # crotch
]
def mirror(p): return (round(W - p[0], 2), p[1])
segs = []
prev = start
for c1, c2, end in right:
    segs.append((prev, c1, c2, end)); prev = end
left = [(mirror(e), mirror(c2), mirror(c1), mirror(s)) for (s, c1, c2, e) in reversed(segs)]
def f(p): return f"{p[0]:g} {p[1]:g}"
lines = [f"M {f(start)}"]
for s, c1, c2, e in segs + left:
    lines.append(f"C {f(c1)} {f(c2)} {f(e)}")
lines.append("Z")
print(" ".join(lines))
