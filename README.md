# 🛰️ OD Console — Orbit Determination Simulator

An interactive, single-file **orbit determination** simulator with a cyber-industrial
tactical UI: a 3D textured Earth, live 2D/3D orbit views, a guided 8-stage estimation
journey, and seven real estimators (batch **and** sequential) sharing one validated
two-body engine.

> 📦 Single `.html` file · no build step · runs in any modern browser.
> 🌐 The 3D Earth uses Three.js from a CDN (first load needs internet); everything else is offline.

**🔗 Live demo:** `[https://2248220hub.github.io/Orbit_OD_Simulator/]`

---

## ✨ Features

- 🌍 **3D textured Earth** (Three.js) with a slow, calm rotation and a tactical wireframe graticule.
- 🔁 **2D / 3D view toggle** — default flat 2D orbit view for clarity; switch to an inclined 3D view.
- 🧮 **Seven estimators**, batch and sequential, on one planar two-body model:
  LS · WLS · WLS+a priori · MVE · MVE+a priori · Kalman · Extended Kalman.
- 🧭 **Guided 8-stage journey** from problem setup → first guess → STM → residuals → normal
  equations → solve → iterate → results.
- 📐 **Live state-vector & Keplerian panel** (glassmorphism) comparing **true vs estimated** state.
- ⏱️ **Mission clocks** — UTC, GPS (week:sec), and Julian Date, ticking live with a LIVE-synced dot.
- 📟 **Telemetry ticker** — colour-coded engine log streamed over the orbit view.
- 🗺️ **Ground-track minimap** — equirectangular sub-satellite trace at sped-up playback.
- 📊 **Covariance analysis** — 1σ, correlations, condition number, trace, log-determinant,
  consistency check, and a prior-vs-posterior covariance ellipse.
- 🔊 **Audio cues** — subtle click feedback and a convergence chime (mutable).
- 🔀 **Coherent UI** — changing sensor, noise model, estimator, or prior live-updates the plots.

---

## 🧭 The estimation loop (8 stages)

| # | Stage | What happens | Key relation |
|---|-------|--------------|--------------|
| 1 | Problem | Pick sensor quality + noise model; run a tracking pass | `Yᵢ = G(Xᵢ,tᵢ) + εᵢ` |
| 2 | Guess | Choose a first reference `X*₀` (Lambert / Newton) | `x = X − X*` |
| 3 | STM | Propagate the state-transition matrix `Φ(t,t₀)` | `Φ̇ = A Φ,  Φ(t₀,t₀)=I` |
| 4 | O−C | Compute pre-fit residuals (observed − computed) | `yᵢ = Yᵢ − G(X*ᵢ)` |
| 5 | H = H̃Φ | Map every observation back to the epoch | `Hᵢ = H̃ᵢ Φ(tᵢ,t₀)` |
| 6 | Solve | Form & invert the normal equations | `x̂₀ = Λ⁻¹ N` |
| 7 | Iterate | Update reference, re-linearise, repeat | `X*₀ ← X*₀ + x̂₀` |
| 8 | Results | Estimate, covariance, consistency report | `P₀ = Λ⁻¹` |

---

## 🧮 Estimators

| Filter | Weight `W` | Prior | Solution |
|--------|-----------|-------|----------|
| **LS** | `I` | — | `x̂ = (HᵀH)⁻¹Hᵀy`,  `P=(HᵀH)⁻¹σ²` |
| **WLS** | `1/σ²` | — | `x̂ = (HᵀWH)⁻¹HᵀWy` |
| **WLS + a priori** | `1/σ²` | `P̄₀` | `x̂ = (HᵀWH+P̄⁻¹)⁻¹(HᵀWy+P̄⁻¹x̄)` |
| **MVE** | `R⁻¹` | — | `x̂ = (HᵀR⁻¹H)⁻¹HᵀR⁻¹y` |
| **MVE + a priori** | `R⁻¹` | `P̄₀` | `x̂ = (HᵀR⁻¹H+P̄⁻¹)⁻¹(HᵀR⁻¹y+P̄⁻¹x̄)` |
| **Kalman (KF)** | per-obs | `P̄₀` | `K = P̄H̃ᵀ(H̃P̄H̃ᵀ+R)⁻¹`,  `x̂ = x̄ + K(y−H̃x̄)` |
| **Extended KF** | per-obs | `P̄₀` | KF + relinearise: `X*₀ ← X̂₀`, re-propagate each pass |

> ⚖️ **Batch vs sequential:** the batch update `x̂₀ = Λ⁻¹N` uses all historical data at once
> (Λ = Information Matrix, N = Accumulated Information Vector `HᵀWy`). KF/EKF process one
> observation at a time via the Kalman gain `K`. The two are equivalent for the linear case
> (verified to ~1e-10).

---

## ⚙️ Options

| 🎚️ Noise model | Description |
|-------------|-------------|
| White | uncorrelated Gaussian, `R = σ²I` |
| Coloured | first-order AR(1), `ρ = 0.85`, `Rᵢⱼ = σ²·ρ^{|i−j|}` |

| 🎯 A priori `P̄₀` | σ (pos / vel) | Effect |
|----------------|---------------|--------|
| Weak | ≈ 10 | almost no prior → pure WLS/MVE |
| Nominal | ≈ 1 / 0.1 | balanced |
| Tight | ≈ 0.1 / 0.01 | prior dominates the solution |
| Custom | log sliders | set each σ and an `x̄₀` offset |

> 🧊 **Whitening:** `W = R⁻¹` via Cholesky (`R = V Vᵀ`, `z = V⁻¹y`). Using a diagonal weight on
> coloured noise leaves wRMS biased — the UI warns when this happens.

---

## 📊 Plots & readouts

- 📈 **Pre-fit residuals** — connected line exposing the systematic signature of the state error.
- 📉 **Post-fit residuals** — scatter that should collapse to noise; the title states wRMS honestly.
- 🔻 **‖x̂₀‖ per iteration** — log-scale convergence with the ε threshold.
- 🧊 **Covariance block** — 1σ uncertainties, six correlation coefficients, `cond(Λ)`, `tr(P)`,
  `log₁₀|P|`, and a consistency check (is truth within 3σ?).

> ℹ️ `wRMS = √( Σ εᵢ²/σ² / m )` → **≈ 1** means residuals reached the noise floor.

---

## 🎛️ Controls

| Element | Where | Use |
|---------|-------|-----|
| 🔢 Stage chips | top bar | jump between completed stages |
| 🔁 2D / 3D toggle | top of orbit view | switch flat vs 3D orbit display |
| 📐 ELEMENTS tab | right edge | slide-in state-vector & Keplerian panel |
| ⏱️ Mission clocks | top-right | UTC · GPS · Julian Date |
| 📟 Telemetry ticker | over orbit view | live engine log |
| 🔊 Mute toggle | header | enable / disable sound cues |
| ♻️ Reset & re-iterate | Stage 7 | try a different filter from scratch |

---

## 🚀 Run & host

- 💻 **Locally:** open `OD_Simulator.html` in any modern browser (hard-refresh with Ctrl/⌘+Shift+R after updates).
- ☁️ **Publish to GitHub Pages:** run `push.bat` (Windows) — it copies the file to `index.html`,
  commits, and pushes to your repo. Then enable **Settings → Pages → Branch: main / root**.

---

## 🔧 Technical notes

- 🪐 Pure two-body dynamics (`μ = 1`), planar state `[x, y, ẋ, ẏ]`, RK4 propagation with the 20-D STM.
- 🧭 Keplerian elements (`a, e, i, Ω, ω, ν`) are derived from the planar state; `i`/`Ω` are display values for the 3D view.
- ➗ All linear algebra (Gaussian elimination, Cholesky, 4×4 inverse, power-iteration condition number) is hand-rolled — no math libraries.
- 📦 Single file (~110 KB). Only external dependency: Three.js (CDN) for the 3D Earth, with a procedural 2D fallback.

> 🎓 *Educational simulator — not for operational navigation.*
