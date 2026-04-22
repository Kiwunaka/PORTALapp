import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuickSettingsModal extends HookConsumerWidget {
  const QuickSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final isRussian = t.$meta.locale.languageCode == 'ru';
    final serviceMode = ref.watch(ConfigOptions.serviceMode);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (PlatformUtils.isDesktop)
            ListTile(
              leading: const Icon(FluentIcons.shield_task_24_regular),
              title: const Text('Device optimization'),
              subtitle: Text(
                _desktopOptimizationMessage(
                  serviceMode: serviceMode,
                  isRussian: isRussian,
                ),
              ),
            ),
          ListTile(
            title: const Text('Routing preset'),
            subtitle: Text(
              presentConsumerRoutingMode(
                ref.watch(ConfigOptions.routingMode),
                t,
              ),
            ),
            trailing: const Icon(FluentIcons.chevron_right_24_regular),
            onTap: () => const DevicesRoute().go(context),
          ),
          ListTile(
            title: Text(
              isRussian ? 'Открыть поддержку' : 'Open support',
            ),
            subtitle: Text(
              isRussian
                  ? 'Откроем поддержку с уже подготовленным контекстом устройства.'
                  : 'Jump into support with your device context already prepared.',
            ),
            trailing: const Icon(FluentIcons.chat_24_regular),
            onTap: () => const SupportRoute().go(context),
          ),
          const Gap(8),
          ListTile(
            title: const Text('Advanced and recovery tools'),
            subtitle: Text(
              isRussian
                  ? 'Открывайте их только для диагностики, восстановления или редких сценариев поддержки.'
                  : 'Open these only when recovery or support needs extra steps.',
            ),
            trailing: const Icon(FluentIcons.chevron_right_24_regular),
            onTap: () => const DevicesRoute().go(context),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

String _desktopOptimizationMessage({
  required ServiceMode serviceMode,
  required bool isRussian,
}) {
  if (serviceMode != ServiceMode.tun) {
    return isRussian
        ? 'Полная оптимизация устройства остаётся в инструментах совместимости. Поддержка проведёт вас туда только при необходимости.'
        : 'Full-device optimization stays behind compatibility tools. Support will guide you there only when needed.';
  }

  return isRussian
      ? 'Перезапустите POKROV от имени администратора, чтобы оптимизировать всё устройство.'
      : 'Restart POKROV as Administrator before optimizing the whole device.';
}
