"""Cut the near-white background out of a flat illustration (colour-to-alpha).

Only light pixels connected to the image border count as background, so whites inside the
character's outline (eye highlights, bottle, belly) stay opaque. Within that region each pixel
is un-blended from white, which keeps anti-aliased outline edges and the soft ground shadow
as partial alpha with no white halo.

usage: python3 matte.py in.png out.png
"""
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

LIGHT = 200   # min channel above which a border-connected pixel counts as background
NOISE = 0.03  # alpha below this (JPEG-ish noise in the white) becomes fully clear


def matte(rgb: np.ndarray) -> np.ndarray:
    light = rgb.min(axis=2) >= LIGHT
    labels, _ = ndimage.label(light)
    border = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    background = np.isin(labels, border[border > 0])

    alpha = np.ones(rgb.shape[:2])
    a = ((255 - rgb) / 255).max(axis=2)
    a = np.clip((a - NOISE) / (1 - NOISE), 0, 1)
    alpha[background] = a[background]

    out = rgb.copy()
    safe = np.maximum(alpha, 1e-6)[..., None]
    unblended = np.clip((rgb - (1 - alpha[..., None]) * 255) / safe, 0, 255)
    out[background] = unblended[background]
    return np.dstack([out, alpha * 255]).round().astype(np.uint8)


if __name__ == "__main__":
    rgb = np.asarray(Image.open(sys.argv[1]).convert("RGB")).astype(float)
    Image.fromarray(matte(rgb), "RGBA").save(sys.argv[2], optimize=True)
