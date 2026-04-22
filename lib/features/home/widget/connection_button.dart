import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/core/widget/animated_text.dart';
import 'package:hiddify/core/widget/pokrov_logo.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/connection/widget/experimental_feature_notice.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;
    final requiresReconnect =
        ref.watch(configOptionNotifierProvider).valueOrNull;

    ref.listen(
      connectionNotifierProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
        if (next
            case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog.fromErr(t.presentError(connectionFailure))
              .show(context);
        }
      },
    );

    Future<bool> showExperimentalNotice() async {
      final hasExperimental = ref.read(ConfigOptions.hasExperimentalFeatures);
      final canShowNotice = !ref.read(disableExperimentalFeatureNoticeProvider);
      if (hasExperimental && canShowNotice && context.mounted) {
        return await const ExperimentalFeatureNoticeDialog().show(context) ??
            false;
      }
      return true;
    }

    final theme = context.connectionButtonTheme;
    final copy = PortalCopy.of(context);
    final (buttonColor, glowColor, helper) = switch (connectionStatus) {
      AsyncData(value: Connected()) when requiresReconnect == true => (
          theme.reconnectColor,
          theme.connectedGlow,
          copy.isRussian
              ? 'Применить изменения конфигурации'
              : 'Apply configuration changes'
        ),
      AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => (
          theme.connectedColor,
          theme.connectedGlow,
          copy.isRussian
              ? 'Обновляем самый быстрый маршрут'
              : 'Refreshing the fastest route'
        ),
      AsyncData(value: Connected()) => (
          theme.connectedColor,
          theme.connectedGlow,
          copy.isRussian
              ? 'Защищённый туннель активен'
              : 'Secure tunnel is live'
        ),
      AsyncData(value: _) || AsyncError() => (
          theme.idleColor,
          theme.idleGlow,
          copy.isRussian
              ? 'Одно касание включает защиту'
              : 'Tap once to secure this device'
        ),
      _ => (
          theme.idleColor,
          theme.idleGlow,
          copy.isRussian
              ? 'Проверяем лучший маршрут'
              : 'Checking the best route'
        ),
    };

    return _ConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Disconnected()) || AsyncError() => () async {
            if (await showExperimentalNotice()) {
              return await ref
                  .read(connectionNotifierProvider.notifier)
                  .toggleConnection();
            }
          },
        AsyncData(value: Connected()) => () async {
            if (requiresReconnect == true && await showExperimentalNotice()) {
              return await ref
                  .read(connectionNotifierProvider.notifier)
                  .reconnect(await ref.read(activeProfileProvider.future));
            }
            return await ref
                .read(connectionNotifierProvider.notifier)
                .toggleConnection();
          },
        _ => () {},
      },
      enabled: switch (connectionStatus) {
        AsyncData(value: Connected()) ||
        AsyncData(value: Disconnected()) ||
        AsyncError() =>
          true,
        _ => false,
      },
      label: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true =>
          t.connection.reconnect,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 =>
          t.connection.connecting,
        AsyncData(value: final status) => status.present(t),
        _ => '',
      },
      helperLabel: helper,
      buttonColor: buttonColor,
      glowColor: glowColor,
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.helperLabel,
    required this.buttonColor,
    required this.glowColor,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final String helperLabel;
  final Color buttonColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionTheme = context.connectionButtonTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: SizedBox(
            width: 232,
            height: 232,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 214,
                  height: 214,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        glowColor.withOpacity(enabled ? 0.45 : 0.18),
                        glowColor.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scaleXY(
                      begin: 0.94,
                      end: 1.03,
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                    )
                    .fade(
                      begin: 0.55,
                      end: 0.95,
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                    ),
                Container(
                  width: 196,
                  height: 196,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: connectionTheme.ringColor,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface.withOpacity(
                          theme.brightness == Brightness.light ? 0.95 : 0.88,
                        ),
                        theme.colorScheme.surfaceContainerHighest.withOpacity(
                          theme.brightness == Brightness.light ? 0.72 : 0.44,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  key: const ValueKey('home_connection_button'),
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? onTap : null,
                    customBorder: const CircleBorder(),
                    child: Ink(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: connectionTheme.ringColor,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.9),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(enabled ? 0.26 : 0.12),
                            blurRadius: 34,
                            spreadRadius: -8,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: buttonColor),
                          duration: const Duration(milliseconds: 240),
                          builder: (context, value, child) {
                            return PokrovLogo(
                              color: value,
                              width: 86,
                              height: 86,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ).animate(target: enabled ? 0 : 1).scaleXY(end: 0.96),
              ],
            ),
          ),
        ),
        const Gap(20),
        ExcludeSemantics(
          child: AnimatedText(
            label,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const Gap(10),
        PremiumBadge(
          label: helperLabel,
          icon: Icons.bolt_rounded,
          accent: buttonColor,
        ),
      ],
    );
  }
}
