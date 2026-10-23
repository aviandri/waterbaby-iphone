# MilkBaby brand

## The character

MilkBaby's mascot is a chubby, round capybara seen from the front. It stands on short legs and has
big sparkly eyes, rosy cheeks, a cream belly and an orange yuzu with a leaf on its head. It holds a
pink-cap baby bottle in both paws. The art is flat and pastel with thin brown outlines.

The approved originals, made with Higgsfield, are in `source/`:

| File | What it is |
|---|---|
| `source/capybara-v2.png` | **The character** (1024², near-white background) |
| `source/goal-reached.mp4` | 5 s, 960², 24 fps silent loop: raises the bottle and squint-smiles while confetti bursts. The first and last frames match. |
| `source/app-icon-higgsfield-2048.png` | Icon render: head and shoulders on cream, generated from `capybara-v2.png` with `nano_banana_flash` and recoloured to `#FFF6E6` |
| `source/capybara-v1-alt-sitting.png` | Alternate sitting pose, for reference only |

## Where it is used

| App asset | Made from | SwiftUI | Used for |
|---|---|---|---|
| `CapybaraHero` image set | `capybara-v2.png`, background cut to transparent (`tools/matte.py`), cropped | `CapybaraIllustration` | Onboarding welcome, reminders pitch, Reduce Motion fallback |
| `CapybaraLogo` image set | Icon render masked to a circle, 600² | `CapybaraLogo` | Splash |
| `AppIcon.png` (1024², RGB, no alpha) | Icon render, downscaled | — | Home screen |
| `MilkBaby/Resources/goal-reached.mp4` | `goal-reached.mp4` with the grey background levelled to pure white, no audio track | `GoalReachedView`, `GoalReachedOverlay` | Celebration when the daily goal is first reached |
| `capybara-silhouette.svg` | Traced over `capybara-v2.png` (yuzu left out), mirrored (`tools/silhouette_half.py`) | `CapybaraSilhouette`, `MascotFillView` | Home fill meter |

![fill meter](fill-preview.png)

### Silhouette

The silhouette is the character from the front, ears to soles: a domed head with two small,
separate round ears, round cheeks, a slight waist, a chubby belly that bulges at the sides, and two
short legs with a gap between them. The yuzu is left out so the head reads cleanly at low fill
levels. It is drawn in a 68×100 view box, which matches the art (459 px wide by 677 px from ear tip
to sole), so `CapybaraSilhouette.aspect` is 0.68. Always size it with that constant, not a literal.
`MascotFillView` maps 0–100% from the soles to the ear tips (`CapybaraSilhouette.verticalExtent`).

To change the shape, edit the right-half points in `tools/silhouette_half.py`, then paste its
output into both `capybara-silhouette.svg` and `CapybaraSilhouette.swift`. The Swift `SVGPath`
parser reads the same absolute `M`/`C`/`Z` data.

### Goal celebration

`GoalReachedOverlay` dims Home and shows the looping clip on a 280-pt white card captioned
"Goal reached! 🎉", with `ConfettiView` falling over it. It dismisses on tap or after 5 s. The clip is
levelled so its background is exactly white (RGB 255), which makes it disappear into the card.
With Reduce Motion on, the card shows the still `CapybaraHero` instead.

## Colours

| Use | Colour | Theme |
|---|---|---|
| Icon and badge background | `#FFF6E6` | `CapybaraLogo.iconBackground` |
| Fur | `#B07D54` | `Theme.capybaraBrown` |
| Outlines and dark fur | `#6B472E` | `Theme.capybaraDark` |
| Milk bands | cream, peach, butter, sky | `MilkType.color` |

## Regenerating

```sh
pip install --user numpy scipy pillow
python3 docs/brand/tools/matte.py docs/brand/source/capybara-v2.png hero.png   # then crop to the bounding box + 8 px
# video: ffmpeg -i source/goal-reached.mp4 -vf "format=rgb24,colorchannelmixer=rr=1.04:gg=1.045:bb=1.052,format=yuv420p" \
#        -c:v libx264 -crf 20 -preset slow -an -movflags +faststart goal-reached.mp4
```

Check a new matte on a dark background before shipping it, to catch halos.
