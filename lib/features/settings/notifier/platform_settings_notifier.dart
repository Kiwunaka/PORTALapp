import 'dart:io';

import 'package:hiddify/features/connection/data/connection_platform_source.dart';
import 'package:hiddify/features/settings/data/settings_data_providers.dart';
import 'package:hiddify/singbox/service/singbox_service_provider.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_settings_notifier.g.dart';

enum RouteModePickerKind {
  installedApps,
  manualExecutableEntry,
}

class RouteModePickerSupport {
  const RouteModePickerSupport({
    required this.kind,
    required this.nativePickerAvailable,
  });

  final RouteModePickerKind kind;
  final bool nativePickerAvailable;
}

final routeModePickerSupportProvider = Provider<RouteModePickerSupport>((ref) {
  if (Platform.isWindows) {
    return const RouteModePickerSupport(
      kind: RouteModePickerKind.manualExecutableEntry,
      nativePickerAvailable: false,
    );
  }
  return const RouteModePickerSupport(
    kind: RouteModePickerKind.installedApps,
    nativePickerAvailable: true,
  );
});

final desktopPrivilegeProvider = FutureProvider.autoDispose<bool>((ref) async {
  if (!PlatformUtils.isDesktop) {
    return true;
  }
  return ConnectionPlatformSourceImpl().checkPrivilege();
});

@riverpod
class IgnoreBatteryOptimizations extends _$IgnoreBatteryOptimizations {
  @override
  Future<bool> build() async {
    return ref
        .watch(settingsRepositoryProvider)
        .isIgnoringBatteryOptimizations()
        .getOrElse((l) => false)
        .run();
  }

  Future<void> request() async {
    await ref
        .read(settingsRepositoryProvider)
        .requestIgnoreBatteryOptimizations()
        .run();
    await Future.delayed(const Duration(seconds: 1));
    ref.invalidateSelf();
  }
}

@riverpod
class ResetTunnel extends _$ResetTunnel with AppLogger {
  @override
  Future<void> build() async {}

  Future<void> run() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(singboxServiceProvider).resetTunnel().getOrElse(
        (err) {
          loggy.warning("error resetting tunnel", err);
          throw err;
        },
      ).run(),
    );
  }
}
