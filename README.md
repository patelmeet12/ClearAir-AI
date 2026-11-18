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

- Flutter SDK (v3.24+ recommended, tested on Flutter 3.38 / Dart 3.10)
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

3. Run the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

4. Run all automated tests:
   ```bash
   flutter test
   ```

5. Build for production web deployment:
   ```bash
   flutter build web --release
   ```

---

## 🛠️ Technology Stack & Architecture

- **Framework**: Flutter Web (CanvasKit / HTML renderer) & Dart
- **Design System**: Material 3 with custom Deep Navy, Clean White, and Teal/Emerald palette
- **State Management**: Riverpod (`flutter_riverpod: ^2.6.1`)
- **Navigation**: GoRouter (`go_router: ^14.8.1`) with `StatefulShellRoute`
- **Data Persistence**: `SharedPreferences` (lightweight, zero unnecessary backend overhead)
- **Live Atmospheric API**: Open-Meteo Air Quality & Weather API (Open data, zero API key required)
- **Charts**: `fl_chart: ^0.68.0` for 24-hour diurnal forecasts and weekly trends
- **GenAI Client**: Gemini 1.5 Flash API connector with deterministic local rule-based fallback

---

## 📚 Documentation Index

- [Product Overview](./PRODUCT_OVERVIEW.md)
- [Clean Architecture](./ARCHITECTURE.md)
- [Design System & WCAG 2.2 AA Accessibility](./DESIGN_SYSTEM.md)
- [Privacy & Security Specification](./PRIVACY_AND_SECURITY.md)
- [GenAI & Deterministic Engine Integration](./AI_INTEGRATION.md)
- [Testing & Quality Engineering](./TESTING.md)
