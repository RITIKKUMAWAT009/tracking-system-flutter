import 'package:background_location_tracker/core/platform/battery_channel.dart';
import 'package:background_location_tracker/core/platform/platform_channel.dart';
import 'package:background_location_tracker/features/tracking/data/datasources/location_local_datasource.dart';
import 'package:background_location_tracker/features/tracking/data/datasources/location_local_datasource_impl.dart';
import 'package:background_location_tracker/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:background_location_tracker/features/tracking/data/services/battery_service_impl.dart';
import 'package:background_location_tracker/features/tracking/data/services/location_service_impl.dart';
import 'package:background_location_tracker/features/tracking/data/services/tracking_service_impl.dart';
import 'package:background_location_tracker/features/tracking/domain/repositories/location_repository.dart';
import 'package:background_location_tracker/features/tracking/domain/services/battery_service.dart';
import 'package:background_location_tracker/features/tracking/domain/services/location_service.dart';
import 'package:background_location_tracker/features/tracking/domain/services/tracking_service.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/check_tracking_status_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/get_battery_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/get_locations_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/save_location_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/start_tracking_usecase.dart';
import 'package:background_location_tracker/features/tracking/domain/usecases/stop_tracking_usecase.dart';
import 'package:background_location_tracker/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  /// DataSources
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => const LocationLocalDatasourceImpl(),
  );

  /// Repository
  sl.registerLazySingleton<LocationRepository>(
    () => TrackingRepositoryImpl(sl()),
  );

  /// Services
  sl.registerLazySingleton<LocationService>(() => const LocationServiceImpl());

  sl.registerLazySingleton<TrackingService>(
    () => TrackingServiceImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => const PlatformChannel());

  sl.registerLazySingleton(() => const BatteryChannel());

  sl.registerLazySingleton<BatteryService>(() => BatteryServiceImpl(sl()));

  /// UseCases
  sl.registerLazySingleton(() => SaveLocationUseCase(sl()));

  sl.registerLazySingleton(() => GetLocationsUseCase(sl()));

  sl.registerLazySingleton(() => StartTrackingUseCase(sl()));

  sl.registerLazySingleton(() => StopTrackingUseCase(sl()));
  sl.registerLazySingleton(() => CheckTrackingStatusUseCase(sl()));

  sl.registerLazySingleton(() => GetBatteryUseCase(sl()));

  /// Bloc
  sl.registerFactory(
    () => TrackingBloc(
      startTrackingUseCase: sl(),
      stopTrackingUseCase: sl(),
      saveLocationUseCase: sl(),
      getLocationsUseCase: sl(),
      getBatteryUseCase: sl(),
      checkTrackingStatusUseCase: sl(),
    ),
  );
}
