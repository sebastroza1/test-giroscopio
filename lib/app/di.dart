import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../features/motion_monitor/data/providers/ble_generic_watch_provider.dart';
import '../features/motion_monitor/data/providers/huawei_watch_provider.dart';
import '../features/motion_monitor/data/providers/phone_sensor_provider.dart';
import '../features/motion_monitor/data/providers/wearos_watch_provider.dart';
import '../features/motion_monitor/data/repositories/motion_repository_impl.dart';
import '../features/motion_monitor/domain/repositories/motion_repository.dart';
import '../features/motion_monitor/domain/services/watch_provider.dart';
import '../features/motion_monitor/presentation/controller/motion_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<Logger>(() => Logger());

  sl.registerLazySingleton<PhoneSensorProvider>(() => PhoneSensorProvider());

  sl.registerLazySingleton<WatchProvider>(() => HuaweiWatchProvider(sl<Logger>()),
      instanceName: 'huawei');
  sl.registerLazySingleton<WatchProvider>(() => WearOsWatchProvider(sl<Logger>()),
      instanceName: 'wearos');
  sl.registerLazySingleton<WatchProvider>(() => BleGenericWatchProvider(sl<Logger>()),
      instanceName: 'ble_generic');

  sl.registerLazySingleton<MotionRepository>(
    () => MotionRepositoryImpl(
      phoneProvider: sl<PhoneSensorProvider>(),
      watchProviders: [
        sl<WatchProvider>(instanceName: 'ble_generic'),
        sl<WatchProvider>(instanceName: 'huawei'),
        sl<WatchProvider>(instanceName: 'wearos'),
      ],
      preferredProvider: 'ble_generic',
      logger: sl<Logger>(),
    ),
  );

  sl.registerFactory<MotionController>(
    () => MotionController(sl<MotionRepository>(), sl<Logger>()),
  );
}
