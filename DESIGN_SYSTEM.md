# ClearAir AI — Design System & Accessibility Specification

## Visual Direction & Philosophy

ClearAir AI is designed with an **environmental technology** aesthetic that balances scientific precision with a calm, reassuring interface during stressful smog and hazardous pollution events.

- **Foundations**: Deep Navy (`#0A1128`, `#0F172A`, `#1E293B`) and Clean Slate White (`#F8FAFC`, `#FFFFFF`).
- **Brand Accents**: Vibrant Teal (`#0D9488`, `#14B8A6`) and Fresh Emerald Green (`#10B981`, `#059669`).
- **Subtle Surface Elevation**: Flat Material 3 cards bounded by hairline borders (`#E2E8F0` light, `#334155` dark) instead of heavy dropped shadows.

---

## Air Quality Status Palette (WCAG 2.2 AA Aligned)

Every air quality status indicator uses dual-channel communication (color + text label + numeric scale), ensuring users who experience color vision deficiencies can immediately distinguish severity levels.

| Tier | Range (US EPA) | Hex Color | Semantics & Meaning |
|---|---|---|---|
| **Good** | 0 – 50 | `#10B981` (Emerald) | Air quality is satisfactory; safe for all outdoor activities. |
| **Moderate** | 51 – 100 | `#F59E0B` (Amber) | Acceptable; sensitive individuals should take breaks. |
| **Poor / Sensitive** | 101 – 150 | `#F97316` (Orange) | Unhealthy for sensitive groups (children, elderly, asthmatics). |
| **Unhealthy** | 151 – 200 | `#EF4444` (Red) | Adverse effects for general public; avoid strenuous outdoor exercise. |
| **Very Poor** | 201 – 300 | `#8B5CF6` (Purple) | Health alert; serious risk of respiratory aggravation. |
| **Severe / Hazardous** | 301 – 500+ | `#701A75` (Deep Fuchsia/Maroon) | Emergency condition; everyone should avoid all outdoor exposure. |

---

## Data State Indicators

Transparency is central to ClearAir AI. Every dataset displayed is badged with an explicit status indicator:

| Status Badge | Indicator Color | Meaning |
|---|---|---|
| `LIVE DATA` | `#0284C7` (Sky Blue) | Fetched directly in real-time from open monitoring networks. |
| `CACHED DATA` | `#D97706` (Amber) | Previously fetched measurements retained for offline availability. |
| `ESTIMATED DATA`| `#2563EB` (Royal Blue) | Interpolated atmospheric model estimate based on surrounding grid. |
| `DEMO DATA` | `#9333EA` (Purple) | Curated deterministic simulation dataset for testing and demonstration. |

---

## WCAG 2.2 AA Accessibility Compliance

1. **Contrast Ratios**: All body text maintains a contrast ratio >= 4.5:1 against card backgrounds; large headers maintain >= 3.0:1.
2. **Screen Reader Semantics**: Key visual widgets (`AqiGauge`, `AqiBadge`, `PollutantMetricCard`) are wrapped in `Semantics` widgets providing clear spoken summaries (e.g., *"Air Quality Index gauge showing 382, rated Severe. Extreme Toxic Smog Exposure"*).
3. **Keyboard Navigability**: All interactive buttons, checkboxes, text fields, and chips are fully navigable with standard focus traversal.
4. **Reduced Motion Toggle**: Available in Settings, allowing users sensitive to vestibular motion to disable transitions and animated progress bars.
5. **Touch Targets**: All actionable buttons and form inputs meet or exceed the standard 44x44 dp minimum touch target dimensions.
