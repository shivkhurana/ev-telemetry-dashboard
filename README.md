# EV Telemetry Dashboard

A high-performance **Electric Vehicle (EV) Telemetry Dashboard** built with
Flutter. It streams live vehicle data over **WebSockets** and renders it through
a reactive **BLoC** architecture on a clean, dark-themed UI.

## Features

- **Real-time telemetry** over WebSockets (`web_socket_channel`).
- **BLoC state management** (`flutter_bloc`) for a predictable, testable data flow.
- **Live gauges** — animated circular progress indicators for **Speed** and
  **Battery Level** with modern typography.
- **Connection status** indicator (Idle / Connecting / Live / Offline).
- **Resilient parsing** — malformed frames are ignored instead of crashing.

## Architecture

```
WebSocket (wss://echo.websocket.events)
        │  JSON: { "speed": <num>, "batteryLevel": <num> }
        ▼
TelemetrySocketService  ──►  Stream<TelemetryData>
        │
        ▼
TelemetryBloc  (TelemetryEvent ──► TelemetryState)
        │
        ▼
DashboardScreen  (BlocBuilder ──► TelemetryGauge widgets)
```

### Project layout

| Path | Responsibility |
| --- | --- |
| `lib/models/telemetry_data.dart` | Immutable telemetry frame + JSON parsing |
| `lib/services/telemetry_socket_service.dart` | WebSocket connection & frame stream |
| `lib/bloc/telemetry_event.dart` | Events the BLoC reacts to |
| `lib/bloc/telemetry_state.dart` | UI-facing immutable state |
| `lib/bloc/telemetry_bloc.dart` | Connects the socket stream to state |
| `lib/widgets/telemetry_gauge.dart` | Reusable circular gauge widget |
| `lib/screens/dashboard_screen.dart` | Dark-themed dashboard UI |
| `lib/main.dart` | App entry point, theme, BLoC wiring |

## WebSocket data contract

The dashboard expects JSON messages of the form:

```json
{ "speed": 72.5, "batteryLevel": 88.0 }
```

Because the demo points at the public echo server
`wss://echo.websocket.events`, the service publishes simulated frames on a fixed
cadence and renders the echoed values — so the dashboard comes alive without a
real vehicle backend. Point `TelemetrySocketService(url: ...)` at your own
endpoint to consume live data.

## Getting started

```bash
flutter pub get
flutter run        # choose a device / emulator / web
```

Run the analyzer and tests:

```bash
flutter analyze
flutter test
```

## Dependencies

- [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) — BLoC state management
- [`web_socket_channel`](https://pub.dev/packages/web_socket_channel) — WebSocket client
