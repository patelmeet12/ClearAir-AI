# ClearAir AI — Testing & Quality Engineering Report

## Testing Philosophy & Coverage

ClearAir AI was built with rigorous test-driven verification. Every unit test verifies real calculations, breakpoint mathematical limits, and behavioral decision logic—avoiding shallow "widget exists" assertions.

---

## Automated Test Suites

```
test/
├── unit/
│   ├── aqi_calculator_test.dart        # 4 test cases: EPA breakpoint piecewise interpolation, NAQI, N95 dose reduction
│   ├── impact_calculator_test.dart     # 4 test cases: Transit emissions, idling fuel burn, trip chaining, addition operator
│   ├── routine_generator_test.dart     # 2 test cases: Safe routine generation during hazardous smog vs. clean conditions
│   ├── ai_assistant_test.dart          # 3 test cases: 7-part structured response, houseplant myth, impact explainer
│   └── models_serialization_test.dart  # 7 test cases: Round-trip JSON serialization across all domain models
└── widget/
    ├── home_dashboard_widget_test.dart # 4 test cases: AqiGauge, AqiBadge, DataStatusIndicator, PollutantMetricCard
    └── widget_test.dart                # 1 test case: ClearAirApp root bootstrap and desktop navigation smoke test
```

**Total Automated Tests:** 25 / 25 Passing (100% Pass Rate).

---

## Test Execution Commands

Run the complete test suite:
```bash
flutter test
```

Run only unit tests:
```bash
flutter test test/unit/
```

Run widget tests:
```bash
flutter test test/widget/
```

Run static analysis check:
```bash
flutter analyze
```
*(Result: 0 issues found, clean analysis).*

---

## Key Edge Cases Verified

1. **Severe Smog Safety Guardrail**: Verified that during hazardous smog conditions (AQI >= 200), the routine generator **strictly never** recommends outdoor cycling, jogging, or walking simply because they are "low-emission." Personal lung protection is prioritized.
2. **N95 Respirator Dose Physics**: Verified that particulate filtration calculations assume 95% particle capture for certified respirators and 0% capture for unmasked ambient baseline.
3. **Diurnal Forecast Diurnal Curve**: Verified that simulated and live hourly forecasts reflect real atmospheric boundary-layer physics (morning peak at 8:00 AM, midday solar mixing dip, evening cooling inversion peak at 9:00 PM).
4. **Data State Labeling**: Verified that demo mode, cached data, and live data are transparently labeled with distinct color-coded badges and updated timestamps.
