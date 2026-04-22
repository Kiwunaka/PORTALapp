import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/window/notifier/window_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'system_tray_notifier.g.dart';

enum DesktopTrayMenuAction {
  openApp,
  toggleConnection,
  support,
  quit,
}

class DesktopTrayMenuEntry {
  const DesktopTrayMenuEntry({
    required this.label,
    required this.action,
    this.disabled = false,
  });

  final String label;
  final DesktopTrayMenuAction action;
  final bool disabled;
}

List<DesktopTrayMenuEntry> buildDesktopTrayMenuEntries({
  required TranslationsEn translations,
  required ConnectionStatus connection,
}) {
  final isRussian = translations.$meta.locale.languageCode == 'ru';

  return [
    const DesktopTrayMenuEntry(
      label: 'Open POKROV',
      action: DesktopTrayMenuAction.openApp,
    ),
    DesktopTrayMenuEntry(
      label: switch (connection) {
        Disconnected() => translations.tray.status.connect,
        Connecting() => translations.tray.status.connecting,
        Connected() => translations.tray.status.disconnect,
        Disconnecting() => translations.tray.status.disconnecting,
      },
      action: DesktopTrayMenuAction.toggleConnection,
      disabled: connection.isSwitching,
    ),
    DesktopTrayMenuEntry(
      label: isRussian ? 'Поддержка' : 'Support',
      action: DesktopTrayMenuAction.support,
    ),
    DesktopTrayMenuEntry(
      label: translations.tray.quit,
      action: DesktopTrayMenuAction.quit,
    ),
  ];
}

String buildDesktopTrayTooltip({
  required String appName,
  required TranslationsEn translations,
  required ConnectionStatus connection,
  int? latencyMs,
}) {
  if (connection is Disconnected) return appName;
  return '$appName - ${connection.present(translations)}';
}

@Riverpod(keepAlive: true)
class SystemTrayNotifier extends _$SystemTrayNotifier with AppLogger {
  @override
  Future<void> build() async {
    if (!PlatformUtils.isDesktop) return;

    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.value?.urlTestDelay ?? 0;
    final newConnectionStatus = delay > 0 && delay < 65000;
    ConnectionStatus connection;
    try {
      connection = await ref.watch(connectionNotifierProvider.future);
    } catch (e) {
      loggy.warning("error getting connection status", e);
      connection = const ConnectionStatus.disconnected();
    }

    final t = ref.watch(translationsProvider);

    final tooltip = buildDesktopTrayTooltip(
      appName: Constants.appName,
      translations: t,
      connection: connection,
      latencyMs: delay,
    );
    if (connection == const Disconnected()) {
      setIcon(connection);
    } else if (newConnectionStatus) {
      setIcon(const Connected());
      // else if (delay>1000)
      //   SystemTrayNotifier.setIcon(timeout ? Disconnecting() : Connecting());
    } else {
      setIcon(const Disconnecting());
    }
    if (Platform.isMacOS) {
      windowManager.setBadgeLabel('');
    }
    if (!Platform.isLinux) await trayManager.setToolTip(tooltip);

    final entries = buildDesktopTrayMenuEntries(
      translations: t,
      connection: connection,
    );

    final menu = Menu(
      items: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) MenuItem.separator(),
          _toMenuItem(
            ref: ref,
            entry: entries[index],
          ),
        ],
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  static void setIcon(ConnectionStatus status) {
    if (!PlatformUtils.isDesktop) return;
    trayManager
        .setIcon(
          _trayIconPath(status),
          isTemplate: Platform.isMacOS,
        )
        .asStream();
  }

  static String _trayIconPath(ConnectionStatus status) {
    if (Platform.isWindows) {
      final Brightness brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;
      switch (status) {
        case Connected():
          return Assets.images.trayIconConnectedIco;
        case Connecting():
          return Assets.images.trayIconDisconnectedIco;
        case Disconnecting():
          return Assets.images.trayIconDisconnectedIco;
        case Disconnected():
          if (isDarkMode) {
            return Assets.images.trayIconIco;
          } else {
            return Assets.images.trayIconDarkIco;
          }
      }
    }
    switch (status) {
      case Connected():
        return Assets.images.trayIconConnectedPng.path;
      case Connecting():
        return Assets.images.trayIconDisconnectedPng.path;
      case Disconnecting():
        return Assets.images.trayIconDisconnectedPng.path;
      case Disconnected():
        return Assets.images.trayIconPng.path;
    }
    // return Assets.images.trayIconPng.path;
  }

  MenuItem _toMenuItem({
    required Ref ref,
    required DesktopTrayMenuEntry entry,
  }) {
    return switch (entry.action) {
      DesktopTrayMenuAction.openApp => MenuItem(
          label: entry.label,
          onClick: (_) async {
            await ref.read(windowNotifierProvider.notifier).open();
            ref.read(routerProvider).go(const HomeRoute().location);
          },
        ),
      DesktopTrayMenuAction.toggleConnection => MenuItem.checkbox(
          label: entry.label,
          checked: false,
          disabled: entry.disabled,
          onClick: (_) async {
            await ref
                .read(connectionNotifierProvider.notifier)
                .toggleConnection();
          },
        ),
      DesktopTrayMenuAction.support => MenuItem(
          label: entry.label,
          onClick: (_) async {
            await ref.read(windowNotifierProvider.notifier).open();
            ref.read(routerProvider).go(const SupportRoute().location);
          },
        ),
      DesktopTrayMenuAction.quit => MenuItem(
          label: entry.label,
          onClick: (_) async {
            return ref.read(windowNotifierProvider.notifier).quit();
          },
        ),
    };
  }
}
