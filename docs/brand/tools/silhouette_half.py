"""Generates the CapybaraSilhouette path: the right half is hand-placed against
source/capybara-v2.png (ears to soles, yuzu left out), then mirrored so the shape is exactly
symmetric. View box 68 x 100, matching the art's 0.68 width-to-height.

usage: python3 silhouette_half.py  -> prints the SVG path data
"""
W = 68
start = (34, 2.2)                                   # top of the domed head, centre line
right = [
    ((40.5, 2.2), (46, 3.4), (49.5, 5.6)),          # dome down to the inner corner of the ear
    ((49.8, 2), (52.5, 0.3), (55.2, 0.3)),          # small round ear
    ((58.6, 0.3), (60.6, 2.8), (60.4, 5.6)),
    ((60.3, 6.8), (59.9, 7.6), (59.3, 8.2)),        # outer corner where the ear meets the head
    ((63.6, 12), (66.6, 21), (66.6, 31)),           # round head down to the cheek
    ((66.6, 39), (63, 42), (63, 48)),               # waist under the cheek
    ((63, 55), (68, 60), (68, 69)),                 # belly, widest point
    ((68, 80), (63, 88), (56.5, 91.5)),             # belly round to the base
    ((56, 95), (56.4, 99.8), (53, 99.8)),           # outer foot
    ((49, 99.8), (46, 99.8), (43, 99.8)),           # sole
    ((41, 99.8), (40.9, 96), (40.6, 93.5)),         # inner leg
    ((38.5, 92.9), (36.5, 92.8), (34, 92.8)),       # gap between the legs, centre line
]


def mirror(p):
    return (round(W - p[0], 2), p[1])


segments = []
previous = start
for c1, c2, end in right:
    segments.append((previous, c1, c2, end))
    previous = end
left = [(mirror(e), mirror(c2), mirror(c1), mirror(s)) for (s, c1, c2, e) in reversed(segments)]


def fmt(p):
    return f"{p[0]:g} {p[1]:g}"


commands = [f"M {fmt(start)}"] + [f"C {fmt(c1)} {fmt(c2)} {fmt(e)}" for _, c1, c2, e in segments + left] + ["Z"]
print(" ".join(commands))
