# ClearAir AI — Intelligent Air Quality & Pollution Protection Assistant

> **Core Message:** *Breathe smarter. Live healthier. Reduce pollution together.*

ClearAir AI is a production-grade, GenAI-powered web application built with Flutter Web, Dart, and Material 3. It empowers families, individuals, and urban communities to navigate hazardous winter smog, industrial particulate inversions, and everyday urban air pollution. Rather than merely presenting passive data, ClearAir AI translates complex atmospheric sensor metrics into prioritized, personalized daily routines, indoor air purification checklists, safe travel alternatives, and community clean air pledges.

---

## 🌟 Key Application Features

1. **Home Dashboard**: Live location AQI gauge, EPA & NAQI category status, six-pollutant concentrations (PM2.5, PM10, NO2, SO2, CO, O3), real-time weather conditions, family safety reminders, today's prioritized actions, and transparent impact tracking.
2. **Location-Aware Air Quality Intelligence**: Instant global geocoding search, multiple saved locations (Home, Workplace, School, Custom), side-by-side pollution comparison, and 24-hour diurnal forecast trend charts.
3. **GenAI Protection Assistant**: Conversational environmental assistant answering complex questions (child safety, outdoor recess, transit exposure, indoor filtration on a budget, senior citizen precautions). Features full evidence citations and explicit medical safety disclaimers.
4. **Family Safety Planner**: Minimal, privacy-first demographic matrix (adults, children, seniors, sensitivity flags, schedule types, budget tiers) that dynamically tunes protection advisories without collecting any PII.
5. **Indoor Air Quality Optimizer**: Actionable indoor purification guide with live ventilation timing based on outdoor AQI, HEPA filter maintenance countdown tracker, range-hood exhaust practices, and scientific debunking of houseplant myths regarding fine PM2.5.
6. **Smart Daily Routine Generator**: Time-slotted morning, afternoon, evening, and night action plans balancing personal lung exposure reduction against urban emissions reduction (never advises cycling or jogging during hazardous smog!).
7. **Sustainable Alternatives & Carbon Impact**: Practical replacements for everyday carbon-intensive activities with transparent conversion factors (solo car → transit, anti-idling, trip chaining, smart appliance scheduling).
8. **Community Impact Dashboard**: Collective impact tracking (actions completed, vehicle trips avoided, fuel saved, CO2e prevented) with opt-in civic clean-air challenges (e.g., *Zero Idling Challenge*, *Transit Sprint*).
9. **"Why This Matters" AI Explainer**: Interactive evidence-aware explainer for every completed action, breaking down: *What Changed*, *Exposure Reduction*, *Emission Reduction*, *Who Benefits*, *Model Assumptions*, and *Estimate Limitations*.
10. **Insights & Reports**: Weekly air quality trajectory graphs, routine adherence metrics, indoor checklist completion scores, and one-click exportable text/clipboard reports.
11. **Settings & Extensible AI Architecture**: Light and deep navy dark themes, WCAG 2.2 AA reduced-motion toggle, US EPA vs. India NAQI scale selection, deterministic local demo mode toggle, and secure, client-side GenAI credential configuration (zero hardcoded secrets).

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.24+ recommended, tested on Flutter 3.29 / Dart 3.8)
- Google Chrome or any modern Chromium/WebKit browser

### Installation & Run

1. Clone or navigate to the project directory:
   ```bash
   cd clearair_ai
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis with fatal warnings:
   ```bash
   flutter analyze --fatal-infos
   ```

4. Run the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

5. Run all 56 automated tests with coverage:
   ```bash
   flutter test --coverage
   ```

6. Build for production web deployment:
   ```bash
   flutter build web --release --no-tree-shake-icons
   ```

---

## 🛠️ Technology Stack & Architecture

- **Framework**: Flutter Web (CanvasKit / Wasm / HTML renderer) & Dart
- **Design System**: Material 3 with custom Deep Navy, Clean White, and Teal/Emerald palette
- **State Management**: Riverpod (`flutter_riverpod: ^2.5.1`)
- **Navigation**: GoRouter (`go_router: ^14.2.0`) with `StatefulShellRoute`
- **Data Persistence**: `SharedPreferences` (`shared_preferences: ^2.2.3`)
- **Live Atmospheric API**: Open-Meteo Air Quality & Weather API (Open data, zero API key required)
- **Networking**: `http: ^1.2.1` with timeout guards and `AppLogger` fallbacks
- **Charts**: `fl_chart: ^0.68.0` for 24-hour diurnal forecasts and weekly trends
- **Value Equality & Identifiers**: `equatable: ^2.0.5`, `uuid: ^4.4.0`
- **Date & Number Formatting**: `intl: ^0.19.0`
- **GenAI Client**: Gemini 1.5 Flash API connector with deterministic local rule-based fallback
- **CI/CD**: GitHub Actions workflow in [`.github/workflows/ci.yml`](./.github/workflows/ci.yml)
- **Accessibility**: WCAG 2.2 AA compliant with root `MediaQuery` reduced-motion propagation and screen-reader semantics

---

## 📚 Documentation Index

- [Product Overview](./PRODUCT_OVERVIEW.md)
- [Clean Architecture](./ARCHITECTURE.md)
- [Design System & WCAG 2.2 AA Accessibility](./DESIGN_SYSTEM.md)
- [Privacy & Security Specification](./PRIVACY_AND_SECURITY.md)
- [GenAI & Deterministic Engine Integration](./AI_INTEGRATION.md)
- [Testing & Quality Engineering](./TESTING.md)
