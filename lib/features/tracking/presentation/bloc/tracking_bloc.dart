import 'dart:async';

import 'package:background_location_tracker/core/utils/app_enums.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/check_tracking_status_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/get_battery_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/get_locations_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/save_location_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/start_tracking_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/stop_tracking_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final StartTrackingUseCase startTrackingUseCase;
  final StopTrackingUseCase stopTrackingUseCase;
  final GetLocationsUseCase getLocationsUseCase;
  final SaveLocationUseCase saveLocationUseCase;
  final GetBatteryUseCase getBatteryUseCase;
  final CheckTrackingStatusUseCase checkTrackingStatusUseCase;
  Timer? _batteryTimer;
  Timer? _locationsRefreshTimer;

  TrackingBloc({
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
    required this.getLocationsUseCase,
    required this.saveLocationUseCase,
    required this.getBatteryUseCase,
    required this.checkTrackingStatusUseCase,
  }) : super(const TrackingState()) {
    on<LoadLocationsRequested>(_onLoadLocations);
    on<StartTrackingRequested>(_onStartTracking);
    on<StopTrackingRequested>(_onStopTracking);
    on<BatteryRequested>(_onBatteryRequested);
    on<SaveLocationRequested>(_onSaveLocation);
    on<CheckTrackingStatusRequested>(_onCheckTrackingStatus);

    add(const CheckTrackingStatusRequested());
    add(const BatteryRequested());
    _batteryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const BatteryRequested()),
    );
  }
  Future<void> _onCheckTrackingStatus(
    CheckTrackingStatusRequested event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await checkTrackingStatusUseCase();

    result.fold((failure) {}, (running) {
      emit(
        state.copyWith(
          isTracking: running,
          status: running ? TrackingStatus.tracking : TrackingStatus.stopped,
        ),
      );

      if (running) {
        _locationsRefreshTimer?.cancel();
        _locationsRefreshTimer = Timer.periodic(
          const Duration(seconds: 60),
          (_) => add(const LoadLocationsRequested()),
        );
      }
    });
  }

  Future<void> _onLoadLocations(
    LoadLocationsRequested event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(status: TrackingStatus.loading));

    final result = await getLocationsUseCase();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TrackingStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (locations) {
        emit(
          state.copyWith(status: TrackingStatus.loaded, locations: locations),
        );
      },
    );
  }

  Future<void> _onStartTracking(
    StartTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(status: TrackingStatus.loading));

    final result = await startTrackingUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TrackingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(status: TrackingStatus.tracking, isTracking: true));
        _locationsRefreshTimer?.cancel();
        _locationsRefreshTimer = Timer.periodic(
          const Duration(seconds: 60),
          (_) => add(const LoadLocationsRequested()),
        );
        add(const LoadLocationsRequested());
      },
    );
  }

  Future<void> _onStopTracking(
    StopTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await stopTrackingUseCase();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: TrackingStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        _locationsRefreshTimer?.cancel();
        _locationsRefreshTimer = null;
        emit(state.copyWith(status: TrackingStatus.stopped, isTracking: false));
        add(const LoadLocationsRequested());
      },
    );
  }

  Future<void> _onBatteryRequested(
    BatteryRequested event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await getBatteryUseCase();

    result.fold((failure) {}, (battery) {
      emit(state.copyWith(batteryPercentage: battery));
    });
  }

  Future<void> _onSaveLocation(
    SaveLocationRequested event,
    Emitter<TrackingState> emit,
  ) async {
    final saveResult = await saveLocationUseCase(event.location);

    await saveResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: TrackingStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        final locationsResult = await getLocationsUseCase();

        locationsResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: TrackingStatus.error,
                errorMessage: failure.message,
              ),
            );
          },
          (locations) {
            emit(
              state.copyWith(
                locations: locations,
                status: state.isTracking
                    ? TrackingStatus.tracking
                    : TrackingStatus.loaded,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _batteryTimer?.cancel();
    _locationsRefreshTimer?.cancel();
    return super.close();
  }
}
