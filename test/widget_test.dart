import 'package:flutter_test/flutter_test.dart';

import 'package:ev_telemetry_dashboard/bloc/telemetry_bloc.dart';
import 'package:ev_telemetry_dashboard/bloc/telemetry_event.dart';
import 'package:ev_telemetry_dashboard/bloc/telemetry_state.dart';
import 'package:ev_telemetry_dashboard/models/telemetry_data.dart';
import 'package:ev_telemetry_dashboard/services/telemetry_socket_service.dart';

void main() {
  group('TelemetryData', () {
    test('parses speed and batteryLevel from JSON', () {
      final data = TelemetryData.fromJson({'speed': 72.5, 'batteryLevel': 88});

      expect(data.speed, 72.5);
      expect(data.batteryLevel, 88);
    });

    test('defaults malformed numeric fields to zero', () {
      final data =
          TelemetryData.fromJson({'speed': 'fast', 'batteryLevel': null});

      expect(data.speed, 0);
      expect(data.batteryLevel, 0);
    });
  });

  group('TelemetryBloc', () {
    test('initial state is idle with zeroed telemetry', () {
      final bloc = TelemetryBloc(_NoopSocketService());

      expect(bloc.state.status, TelemetryStatus.initial);
      expect(bloc.state.data, const TelemetryData(speed: 0, batteryLevel: 0));

      bloc.close();
    });

    test('emits live state when a frame is received', () async {
      final bloc = TelemetryBloc(_NoopSocketService());

      bloc.add(const TelemetryDataReceived(
        TelemetryData(speed: 55, batteryLevel: 90),
      ));

      await expectLater(
        bloc.stream,
        emits(
          isA<TelemetryState>()
              .having((s) => s.status, 'status', TelemetryStatus.live)
              .having((s) => s.data.speed, 'speed', 55)
              .having((s) => s.data.batteryLevel, 'batteryLevel', 90),
        ),
      );

      await bloc.close();
    });
  });
}

/// A socket service stand-in that never emits, so BLoC unit tests stay
/// deterministic and offline.
class _NoopSocketService extends TelemetrySocketService {
  @override
  Stream<TelemetryData> connect() => const Stream.empty();

  @override
  Future<void> dispose() async {}
}
