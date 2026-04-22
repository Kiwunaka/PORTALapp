import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/auto_start/notifier/auto_start_notifier.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revealCompatibilityTools = useState(false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            const NestedAppBar(
              title: Text('Preferences'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: PremiumSectionHeader(
                            eyebrow: 'POKROV shell',
                            title: 'Preferences',
                            subtitle:
                                'Keep the main experience calm, polished, and easy to recover.',
                          ),
                        ),
                        const Gap(16),
                        const PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: _EverydayComfortSection(),
                        ),
                        const Gap(16),
                        const PortalSectionCard(
                          child: _RouteModeSection(),
                        ),
                        const Gap(16),
                        if (PlatformUtils.isDesktop) ...[
                          const PortalSectionCard(
                            child: _DesktopOptimizationSection(),
                          ),
                          const Gap(16),
                        ],
                        PortalSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PremiumSectionHeader(
                                eyebrow: 'Compatibility tools',
                                title: 'Compatibility tools',
                                subtitle:
                                    'Manual recovery and device-specific tools stay hidden until you need them.',
                              ),
                              const Gap(12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: revealCompatibilityTools.value
                                    ? Column(
                                        key: const ValueKey(
                                          'compatibility-open',
                                        ),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const AdvancedSettingTiles(),
                                          const Gap(12),
                                          _ResponsiveActionButton(
                                            child: TextButton.icon(
                                              onPressed: () =>
                                                  revealCompatibilityTools
                                                      .value = false,
                                              icon: const Icon(
                                                Icons.visibility_off_outlined,
                                              ),
                                              label: const Text(
                                                'Hide compatibility tools',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        key: const ValueKey(
                                          'compatibility-closed',
                                        ),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'The default path stays simple. Reveal these tools only for recovery, diagnostics, or edge cases.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const Gap(14),
                                          _ResponsiveActionButton(
                                            child: FilledButton.tonalIcon(
                                              onPressed: () =>
                                                  revealCompatibilityTools
                                                      .value = true,
                                              icon: const Icon(
                                                Icons.visibility_outlined,
                                              ),
                                              label: const Text(
                                                'Reveal compatibility tools',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteModeSection extends ConsumerWidget {
  const _RouteModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(routeModeChoiceCompletedProvider);
    final mode = ref.watch(consumerRouteModeProvider);
    final selectionCount = ref.watch(consumerRouteSelectionCountProvider);

    final title = switch (mode) {
      ConsumerRouteMode.allTraffic => 'Optimize everything',
      ConsumerRouteMode.selectedApps => 'Only selected apps',
    };

    final subtitle = switch (completed) {
      AsyncData(value: true) when mode == ConsumerRouteMode.selectedApps =>
        '$selectionCount selected app${selectionCount == 1 ? '' : 's'}.',
      AsyncData(value: true) => 'This device uses one calm default route.',
      _ => 'Set this before the first optimized session.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionHeader(
          eyebrow: 'Route mode',
          title: 'Route mode',
          subtitle: 'Choose how this device should use POKROV.',
        ),
        const Gap(12),
        PortalListRow(
          title: title,
          subtitle: subtitle,
          leading: const PremiumIconOrb(
            icon: Icons.alt_route_rounded,
            size: 46,
          ),
        ),
        const Gap(14),
        _ResponsiveActionButton(
          child: FilledButton.tonalIcon(
            onPressed: () => showRouteModePage(context),
            icon: const Icon(Icons.tune_rounded),
            label: Text(completed.valueOrNull == true ? 'Change' : 'Set up'),
          ),
        ),
      ],
    );
  }
}

class _DesktopOptimizationSection extends ConsumerWidget {
  const _DesktopOptimizationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final serviceMode = sharedPreferences.hasValue
        ? ref.watch(ConfigOptions.serviceMode)
        : ServiceMode.tun;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionHeader(
          eyebrow: 'Desktop optimization',
          title: 'Full-device optimization',
          subtitle:
              'Keep the public desktop path focused on full-device optimization, and use support when Windows needs extra privileges.',
        ),
        const Gap(12),
        PortalListRow(
          title: 'Full-device optimization',
          subtitle: _desktopOptimizationSummary(
            preferencesReady: sharedPreferences.hasValue,
            serviceMode: serviceMode,
          ),
          leading: const PremiumIconOrb(
            icon: Icons.admin_panel_settings_outlined,
            size: 46,
          ),
        ),
        const Gap(14),
        _ResponsiveActionButton(
          child: FilledButton.tonalIcon(
            onPressed: () => const SupportRoute().go(context),
            icon: const Icon(Icons.headset_mic_outlined),
            label: const Text('Open support'),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveActionButton extends StatelessWidget {
  const _ResponsiveActionButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return SizedBox(width: double.infinity, child: child);
        }
        return child;
      },
    );
  }
}

class _EverydayComfortSection extends ConsumerWidget {
  const _EverydayComfortSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final analytics = ref.watch(analyticsControllerProvider);
    final autoStart = ref.watch(autoStartNotifierProvider);

    final isLoading = sharedPreferences.isLoading ||
        analytics.isLoading ||
        autoStart.isLoading;
    final hasError =
        sharedPreferences.hasError || analytics.hasError || autoStart.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionHeader(
          eyebrow: 'Everyday comfort',
          title: 'Everyday comfort',
          subtitle:
              'Language, theme, startup, haptics, and the small things you feel every day.',
        ),
        const Gap(8),
        if (isLoading)
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'Preparing everyday preferences...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          )
        else if (hasError)
          Text(
            'Preferences are temporarily unavailable.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...const [
          GeneralSettingTiles(),
          PlatformSettingsTiles(),
        ],
      ],
    );
  }
}

String _desktopOptimizationSummary({
  required bool preferencesReady,
  required ServiceMode serviceMode,
}) {
  if (!preferencesReady) {
    return 'Checking whether desktop optimization preferences are ready...';
  }

  if (serviceMode != ServiceMode.tun) {
    return 'Compatibility mode is still active. Keep it hidden from ordinary use and switch only with support guidance.';
  }

  return 'Restart POKROV as Administrator before optimizing the whole device.';
}
