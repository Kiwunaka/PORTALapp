import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/pokrov_logo.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyProfilesHomeBody extends HookConsumerWidget {
  const EmptyProfilesHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialActivation = ref.watch(portalTrialActivationControllerProvider);
    final copy = PortalCopy.of(context);

    ref.listen<AsyncValue<void>>(
      portalTrialActivationControllerProvider,
      (previous, next) {
        final wasLoading = previous?.isLoading ?? false;
        if (!wasLoading || next.isLoading) return;

        final messenger = ScaffoldMessenger.of(context);
        next.whenOrNull(
          data: (_) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(copy.trialReadyToast),
              ),
            );
            unawaited(() async {
              final completed = await ref
                  .read(routeModeChoiceCompletedProvider.future)
                  .catchError((_) => false);
              await Future<void>.delayed(Duration.zero);
              final navigatorContext = rootNavigatorKey.currentContext;
              if ((!context.mounted && navigatorContext == null) ||
                  completed == true) {
                return;
              }
              await showRouteModePage(
                navigatorContext ?? context,
                requiredSetup: true,
              );
            }());
          },
          error: (error, _) => messenger.showSnackBar(
            SnackBar(
              content: Text(copy.trialError(error)),
            ),
          ),
        );
      },
    );

    final title = copy.emptyStateTitle;
    final body = copy.emptyStateBody;
    final bonus = copy.emptyStateBonusTitle;
    final cta = copy.emptyStatePrimaryAction;
    final secondary = copy.emptyStateSecondaryAction;
    final isCompact = MediaQuery.sizeOf(context).width < 460;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: PortalSectionCard(
              tone: PortalSectionTone.accent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const PortalStatusBadge(
                        label: 'POKROV',
                        icon: FluentIcons.shield_24_regular,
                      ),
                      PortalStatusBadge(
                        label: copy.trialPlatformsBadge,
                        icon: FluentIcons.phone_desktop_24_regular,
                      ),
                    ],
                  ),
                  const Gap(18),
                  if (isCompact) ...[
                    const PremiumIconOrb(
                      icon: FluentIcons.sparkle_24_regular,
                      size: 56,
                    ),
                    const Gap(14),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Gap(10),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PremiumIconOrb(
                          icon: FluentIcons.sparkle_24_regular,
                          size: 56,
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const Gap(10),
                              Text(
                                body,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const Gap(18),
                  PortalSectionCard(
                    tone: PortalSectionTone.muted,
                    padding: const EdgeInsets.all(18),
                    child: isCompact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PokrovLogo(width: 42, height: 42),
                              const Gap(14),
                              Text(
                                bonus,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Gap(4),
                              Text(
                                copy.emptyStateBonusBody,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PokrovLogo(width: 42, height: 42),
                              const Gap(14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bonus,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const Gap(4),
                                    Text(
                                      copy.emptyStateBonusBody,
                                      style: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  const Gap(20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: trialActivation.isLoading
                            ? null
                            : () => ref
                                .read(
                                  portalTrialActivationControllerProvider
                                      .notifier,
                                )
                                .activateTrial(
                                  locale: Localizations.localeOf(context),
                                ),
                        icon: trialActivation.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Icon(FluentIcons.flash_24_regular),
                        label: Text(cta),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => const AddProfileRoute().push(context),
                        icon: const Icon(FluentIcons.add_24_regular),
                        label: Text(secondary),
                      ),
                    ],
                  ),
                ]
                    .animate(interval: 70.ms)
                    .fadeIn(duration: 260.ms)
                    .slideY(begin: 0.06, end: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyActiveProfileHomeBody extends HookConsumerWidget {
  const EmptyActiveProfileHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final copy = PortalCopy.of(context);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: PortalSectionCard(
              tone: PortalSectionTone.muted,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumSectionHeader(
                    eyebrow: copy.profilesEyebrow,
                    title: copy.chooseActiveProfileTitle,
                    subtitle: t.home.noActiveProfileMsg,
                  ),
                  const Gap(18),
                  OutlinedButton(
                    onPressed: () =>
                        const ProfilesOverviewRoute().push(context),
                    child: Text(t.profile.overviewPageTitle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
