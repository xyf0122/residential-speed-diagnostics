"""Kinematic envelope and critical spacing (schematic for Section 4.1).

Stop-to-stop case (eta0 = eta1 = 0, Remark 1) on symbolic dimensional axes.
Drawing values use arbitrary coherent length/time units: nu = 1 speed unit,
omega = 0.8 speed unit, alpha = 1 and beta = 1.3 acceleration units.
The axes are not normalized numerical axes; no empirical data are used.
Line-art style: thin black lines, white space, and one accent colour for speed above
the objective (deeper where regions nest).

  (a) Envelopes v_ell(x) for ell = ell*_omega, ell*, and a longer section.
  (b) The same envelopes in squared speed: straight rays of slope 2*alpha and -2*beta.
  (c) Top view in the (x, ell) plane: nested wedges where v > omega and where v = nu.

Requirements: Python 3.9+, numpy, matplotlib (no LaTeX installation needed).
Run: python src/figure5.py --out output/figure5
"""
import argparse
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np


# ------------------------------------------------------------------ style
mpl.rcParams.update({
    "mathtext.fontset": "cm",          # Computer Modern math, matching LaTeX
    "font.family": "serif",
    "font.serif": ["DejaVu Serif"],    # bundled with matplotlib
    "font.size": 8.5,
    "pdf.fonttype": 42,                # embed TrueType fonts (journal-friendly)
    "savefig.dpi": 600,
    "lines.solid_capstyle": "round",
    "lines.dash_capstyle": "round",
})

K = "#1a1a1a"              # line colour
ACC = "#C0392B"            # single accent: speed above the objective
ALPHA_FILL = 0.25          # opacity per layer; nested layers deepen
LW, THIN = 0.85, 0.45      # main and secondary line widths (pt)
DOT = (0, (1, 2.2))        # dotted reference lines

# ------------------------------------------------------------------ model (arbitrary coherent units; symbolic axes)
NU, OMEGA = 1.0, 0.8       # desired speed and speed objective
ALPHA, BETA = 1.0, 1.3     # acceleration and braking bounds (beta > alpha)

L_OMEGA = OMEGA**2 * (ALPHA + BETA) / (2 * ALPHA * BETA)   # Eq. (14) with eta = 0
L_STAR = NU**2 * (ALPHA + BETA) / (2 * ALPHA * BETA)       # Eq. (13)
L3 = 1.42 * L_STAR                                          # a longer section
SPACINGS = [L_OMEGA, L_STAR, L3]
SPACING_LABELS = [r"\ell^{\star}_{\omega}", r"\ell^{\star}", r"\ell"]


def m(s):
    """Wrap a string in math mode."""
    return rf"${s}$"


def envelope(x, ell):
    """Kinematic envelope v_ell(x) of Eq. (12)."""
    return np.minimum.reduce([np.full_like(x, NU), np.sqrt(2 * ALPHA * x),
                              np.sqrt(np.clip(2 * BETA * (ell - x), 0, None))])


def sublabel(ax, s):
    ax.text(0, 1.02, s, transform=ax.transAxes, ha="left", va="bottom",
            fontfamily="DejaVu Sans", fontweight="bold", fontsize=10, clip_on=False)


def brace(ax, x0, x1, y, h, label, fs=8.5):
    """Horizontal curly brace from x0 to x1 at height y, tip pointing down."""
    n = 400
    half = (x1 - x0) / 2
    b = 70 / (x1 - x0)
    xh = np.linspace(0, half, n // 2)
    yh = 1 / (1 + np.exp(-b * (xh - xh[0]))) + 1 / (1 + np.exp(-b * (xh - xh[-1])))
    yy = np.concatenate((yh, yh[-2::-1])) - 0.5
    ax.plot(np.linspace(x0, x1, len(yy)), y - h * yy, color=K, lw=THIN)
    ax.text((x0 + x1) / 2, y - 1.35 * h, label, ha="center", va="top", fontsize=fs)


# ------------------------------------------------------------------ panels
def panel_speed(ax):
    """(a) Envelopes in speed: one shared acceleration arc, three braking arcs."""
    for ell in SPACINGS:
        x = np.linspace(0, ell, 600)
        v = envelope(x, ell)
        ax.fill_between(x, OMEGA, v, where=v > OMEGA, color=ACC, alpha=ALPHA_FILL, lw=0)
        ax.plot(x, v, color=K, lw=LW)
    for yv in (OMEGA, NU):                                   # apexes at the critical spacings
        ax.plot(yv**2 / (2 * ALPHA), yv, "o", ms=2.6, color=K, zorder=5)
    for y, lab in [(OMEGA, r"\omega"), (NU, r"\nu")]:
        ax.plot([-0.02, L3 + 0.04], [y, y], color=K, lw=THIN, ls=DOT)
        ax.text(-0.05, y, m(lab), ha="right", va="center")
    ax.plot([0, L3], [0, 0], color=K, lw=THIN)
    for ell, lab in zip(SPACINGS, SPACING_LABELS):
        ax.plot([ell, ell], [0, -0.025], color=K, lw=THIN)
        ax.text(ell, -0.06, m(lab), ha="center", va="top")
    ax.plot([0, 0], [0, 1.04], color=K, lw=THIN)
    ax.set_xlim(-0.16, L3 + 0.06)
    ax.set_ylim(-0.22, 1.16)
    ax.set_axis_off()
    sublabel(ax, "a")


def panel_squared(ax):
    """(b) Capped squared-speed envelope; above-cap construction rays are dashed."""
    top = 1.18
    x_cap = NU**2 / (2 * ALPHA)
    ax.plot([0, x_cap], [0, NU**2], color=K, lw=LW)  # solid envelope to cap
    ax.plot([x_cap, top / (2 * ALPHA)], [NU**2, top], color=K, lw=THIN,
            ls=(0, (2.5, 2)))  # construction continuation only, not envelope
    for ell in SPACINGS:
        xa = 2 * BETA * ell / (2 * (ALPHA + BETA))                      # apex position
        ya = min(2 * ALPHA * xa, NU**2)
        x = np.linspace(0, ell, 600)
        y = np.minimum.reduce([2 * ALPHA * x, 2 * BETA * (ell - x), np.full_like(x, NU**2)])
        ax.fill_between(x, OMEGA**2, y, where=y > OMEGA**2, color=ACC, alpha=ALPHA_FILL, lw=0)
        keep = x >= min(xa, x_cap)                                      # draw from the apex on
        ax.plot(x[keep], y[keep], color=K, lw=LW)
        if ell <= L_STAR + 1e-9:
            ax.plot(xa, ya, "o", ms=2.6, color=K, zorder=5)
    # braking ray of the longest section, continued beyond the cap
    ax.plot([L3 - NU**2 / (2 * BETA), L3 - top / (2 * BETA)], [NU**2, top], color=K, lw=THIN,
            ls=(0, (2.5, 2)))
    for y, lab in [(OMEGA**2, r"\omega^2"), (NU**2, r"\nu^2")]:
        ax.plot([-0.02, L3 + 0.04], [y, y], color=K, lw=THIN, ls=DOT)
        ax.text(-0.05, y, m(lab), ha="right", va="center")
    ax.plot([0, L3], [0, 0], color=K, lw=THIN)
    ax.text(0.17, 0.42, m(r"2\alpha"), ha="right", va="center")
    ax.text(L3 - 0.06, 0.38, m(r"-2\beta"), ha="left", va="center")
    brace(ax, 0.0, x_cap, -0.04, 0.05, m(r"\frac{\nu^2}{2\alpha}"))
    brace(ax, x_cap, L_STAR, -0.04, 0.05, m(r"\frac{\nu^2}{2\beta}"))
    ax.plot([0, 0], [0, 1.07], color=K, lw=THIN)
    ax.set_xlim(-0.16, L3 + 0.06)
    ax.set_ylim(-0.28, 1.28)
    ax.set_axis_off()
    sublabel(ax, "b")


def panel_phase(ax):
    """(c) The (x, ell) plane: each horizontal line is one section; nested wedges mark
    where the envelope exceeds omega and where it reaches nu."""
    lmax = L3 + 0.28
    xo, xn = OMEGA**2 / (2 * ALPHA), NU**2 / (2 * ALPHA)               # acceleration distances
    do, dn = OMEGA**2 / (2 * BETA), NU**2 / (2 * BETA)                 # braking distances
    for xw, lw_, dw in [(xo, L_OMEGA, do), (xn, L_STAR, dn)]:
        w = [(xw, lw_), (xw, lmax), (lmax - dw, lmax)]
        ax.add_patch(plt.Polygon(w, closed=True, facecolor=ACC, alpha=ALPHA_FILL, lw=0))
        ax.plot([xw, xw], [lw_, lmax], color=K, lw=THIN)
        ax.plot([xw, lmax - dw], [lw_, lmax], color=K, lw=THIN)
        ax.plot(xw, lw_, "o", ms=2.6, color=K, zorder=5)
    # domain 0 <= x <= ell <= lmax
    ax.plot([0, 0, lmax, 0], [0, lmax, lmax, 0], color=K, lw=LW, solid_joinstyle="round")
    for ell, lab in zip(SPACINGS, SPACING_LABELS):
        ax.plot([0, ell], [ell, ell], color=K, lw=THIN, ls=DOT)
        ax.text(-0.04, ell, m(lab), ha="right", va="center")
    # exceedance length on the longest section equals ell - ell*_omega
    ax.annotate("", xy=(xo, L3), xytext=(L3 - do, L3),
                arrowprops=dict(arrowstyle="<->", lw=THIN, color=K, shrinkA=0, shrinkB=0,
                                mutation_scale=6))
    ax.text((xo + L3 - do) / 2, L3 + 0.025, m(r"\ell-\ell^{\star}_{\omega}"), ha="center",
            va="bottom", fontsize=8)
    ax.text(lmax * 0.60, lmax * 0.60 - 0.07, m(r"x=\ell"), rotation=45, rotation_mode="anchor",
            fontsize=8, ha="center", va="top")
    ax.set_xlim(-0.24, lmax + 0.03)
    ax.set_ylim(-0.12, lmax + 0.15)
    ax.set_aspect("equal")
    ax.set_axis_off()
    sublabel(ax, "c")


def draw(out):
    out.mkdir(parents=True, exist_ok=True)
    fig, axes = plt.subplots(1, 3, figsize=(7.0, 2.35),
                             gridspec_kw={"width_ratios": [1, 1, 1]})
    fig.subplots_adjust(left=0.015, right=0.99, bottom=0.04, top=0.90, wspace=0.13)
    for ax, draw in zip(axes, (panel_speed, panel_squared, panel_phase)):
        draw(ax)
        ax.set_box_aspect(1)  # identical square panel canvases; panel c retains equal data units
    fig.canvas.draw()
    boxes = [ax.get_window_extent() for ax in axes]
    assert np.allclose([box.width for box in boxes], boxes[0].width)
    assert np.allclose([box.height for box in boxes], boxes[0].height)
    fig.savefig(out / "Figure5.pdf", bbox_inches="tight", pad_inches=0.025)
    plt.close(fig)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    draw(parser.parse_args().out)
