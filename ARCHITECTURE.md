# ClearAir AI — Software Architecture

ClearAir AI follows **Clean Architecture** principles to separate concerns into Presentation, Domain, and Data layers. This ensures testability, modularity, and independent evolution of UI components and external APIs without side effects.

---

## High-Level Architectural Diagram

```
+-----------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                                 |
|  Screens (10 Sections)  |  Widgets (Gauges, Badges, Chips)  |  StateNotifiers     |
|  - HomeDashboardScreen  |  - AqiGauge, AqiBadge             |  - AirQualityState  |
|  - LiveAirQualityScreen |  - DataStatusIndicator            |  - RoutineState     |
|  - AiAssistantScreen    |  - WhyThisMattersDialog           |  - IndoorState      |
|  - SettingsScreen       |  - ResponsiveLayout               |  - SettingsState    |
+-----------------------------------------------------------------------------------+
                                       |
                                       | watches / dispatches via Riverpod
                                       v
+-----------------------------------------------------------------------------------+
|                                  DOMAIN LAYER                                     |
|  Models (Equatable & JSON)          |  Repository Contracts (Interfaces)          |
|  - AirQualityData                   |  - AirQualityRepository                     |
|  - LocationItem                     |  - RoutineRepository                        |
|  - HouseholdProfile                 |  - IndoorRepository                         |
|  - RoutineItem                      |  - SustainableRepository                    |
|  - SustainableAlternativeItem       |  - CommunityRepository                      |
|  - CommunityChallenge               |  - AiAssistantRepository                    |
|  - AiAssistantMessage               |  - SettingsRepository                       |
|  - AppSettings                      |  - LocationRepository                       |
+-----------------------------------------------------------------------------------+
                                       ^
                                       | implements contracts
                                       |
+-----------------------------------------------------------------------------------+
|                                   DATA LAYER                                      |
|  Data Sources                       |  Repository Implementations                 |
|  - OpenMeteoAqiApi (Live HTTP)      |  - AirQualityRepositoryImpl                 |
|  - DemoDataProvider (Local Determin)|  - RoutineRepositoryImpl                    |
|  - GeminiAiClient (GenAI / Local)   |  - IndoorRepositoryImpl                     |
|  - LocalStorageService (SharedPrefs)|  - AiAssistantRepositoryImpl                |
+-----------------------------------------------------------------------------------+
```

---

## Directory Organization

```
lib/
├── core/
│   ├── constants/
│   │   ├── aqi_standards.dart      # US EPA & India NAQI scales, breakpoints & categories
│   │   └── emission_factors.dart   # Standard conversion factors (CO2/km, fuel/hr idle)
│   ├── router/
│   │   ├── app_router.dart         # GoRouter setup with 10 StatefulShellBranches
│   │   └── navigation_shell.dart   # Adaptive NavigationRail / Drawer / BottomBar
│   ├── theme/
│   │   ├── app_colors.dart         # Contrast-verified palette for EPA AQI tiers
│   │   └── app_theme.dart          # Light and Deep Navy Dark Material 3 theme definitions
│   └── utils/
│       ├── aqi_calculator.dart     # US EPA piecewise linear interpolation from PM2.5
│       └── impact_calculator.dart  # Net emissions, fuel, cost & particulate calculations
├── domain/
│   ├── models/                     # Immutable value objects (AirQuality, Routine, Household...)
│   └── repositories/               # Pure abstract contracts for data operations
├── data/
│   ├── datasources/
│   │   ├── open_meteo_aqi_api.dart # Live global air quality, weather & geocoding client
│   │   ├── demo_data_provider.dart # Deterministic datasets (Delhi, LA, London, Beijing, Zurich)
│   │   ├── gemini_ai_client.dart   # Gemini 1.5 Flash client with deterministic local engine
│   │   └── local_storage_service.dart # SharedPreferences wrapper for robust JSON persistence
│   └── repositories_impl/          # Concrete implementations binding datasources to domain
├── presentation/
│   ├── providers/                  # Riverpod StateNotifierProviders for all UI state
│   ├── widgets/                    # Reusable atomic UI components (AqiGauge, PollutantCard...)
│   └── screens/                    # 10 comprehensive dashboard view screens
└── main.dart                       # App initialization & root ProviderScope binding
```

---

## State Management Architecture (Riverpod)

- **`localStorageServiceProvider`**: Global provider initialized before runApp, ensuring offline storage is immediately accessible to repositories.
- **`airQualityProvider`**: Reactively listens to changes in `locationProvider`. Whenever the active location changes or a refresh is requested, it queries `airQualityRepositoryProvider` with a 30-minute caching strategy.
- **`routineProvider`**: Generates daily routines by evaluating the current atmospheric conditions (`airQualityProvider`) against family vulnerabilities (`householdProvider`).
- **`settingsProvider`**: Centralizes user preferences including theme mode, reduced motion, standard scale selection, and optional GenAI API credentials.

---

## Responsive Layout Strategy

- **Desktop (width >= 1100px)**: Wide navigation rail with active brand header, persistent status indicator, and multi-column grid layouts.
- **Tablet (700px <= width < 1100px)**: Collapsed navigation rail with intuitive icons and two-column cards.
- **Mobile (width < 700px)**: Standard AppBar, slide-out Drawer for deep navigation, and a 5-item BottomNavigationBar for rapid one-thumb access to core dashboards.
