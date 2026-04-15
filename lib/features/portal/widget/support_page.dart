import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SupportPage extends HookConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);
    final config = ref.watch(portalPublicConfigProvider);
    final appInfo = ref.watch(appInfoProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: CustomScrollView(
              slivers: [
                NestedAppBar(title: Text(copy.supportTitle)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: PortalAsyncBody(
                      value: experience,
                      builder: (context, portal) {
                        final supportDiagnostics =
                            buildPortalSupportDiagnostics(
                          portal: portal,
                          config: config,
                          appInfo: appInfo,
                        );
                        final diagnostics = buildPortalDiagnosticsText(
                          diagnostics: supportDiagnostics,
                          isRussian: copy.isRussian,
                        );
                        final supportEmailUri = buildPortalSupportEmailUri(
                          contactEmail: config.contactEmail,
                          diagnostics: supportDiagnostics,
                          appLabel: config.brandName,
                          isRussian: copy.isRussian,
                        );
                        final hasSupportThreads = portal.hasProvisionedAccess &&
                            portal.supportThreads.isNotEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PortalSectionCard(
                              tone: PortalSectionTone.accent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PremiumSectionHeader(
                                    eyebrow: copy.needHelpEyebrow,
                                    title: copy.getHelpFast,
                                    subtitle: copy.supportSubtitle,
                                  ),
                                  const Gap(16),
                                  PortalSectionCard(
                                    tone: PortalSectionTone.muted,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          copy.preparedContext,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const Gap(8),
                                        Text(diagnostics),
                                      ],
                                    ),
                                  ),
                                  if (hasSupportThreads) ...[
                                    const Gap(16),
                                    PortalSectionCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PremiumSectionHeader(
                                            eyebrow: copy.needHelpEyebrow,
                                            title: copy.supportThreadsTitle,
                                            subtitle:
                                                copy.supportThreadsSubtitle,
                                          ),
                                          const Gap(14),
                                          ...portal.supportThreads.map(
                                            (thread) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: PortalSectionCard(
                                                tone: PortalSectionTone.muted,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    LayoutBuilder(
                                                      builder: (
                                                        context,
                                                        constraints,
                                                      ) {
                                                        final title = Text(
                                                          copy.localizeServerText(
                                                            thread.subject,
                                                          ),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium,
                                                        );
                                                        final badge =
                                                            PortalStatusBadge(
                                                          label: copy
                                                              .supportStatus(
                                                            thread.status,
                                                          ),
                                                        );

                                                        if (constraints
                                                                .maxWidth <
                                                            420) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              title,
                                                              const Gap(8),
                                                              badge,
                                                            ],
                                                          );
                                                        }

                                                        return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: title,
                                                            ),
                                                            const Gap(12),
                                                            badge,
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    const Gap(10),
                                                    ...thread.messages
                                                        .take(2)
                                                        .map(
                                                          (message) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              bottom: 8,
                                                            ),
                                                            child: Text(
                                                              copy.localizeServerText(
                                                                message.body,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Gap(16),
                                  _SupportActions(
                                    supportDiagnostics: supportDiagnostics,
                                    supportEmailUri: supportEmailUri,
                                    diagnostics: diagnostics,
                                    config: config,
                                    copy: copy,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            PortalSectionCard(
                              tone: PortalSectionTone.muted,
                              child: PortalListRow(
                                title: copy.deviceContext,
                                subtitle: copy.deviceContextDetails(
                                  portal.session.deviceName,
                                  portal.session.accountId,
                                ),
                                leading: const PremiumIconOrb(
                                  icon: Icons.smartphone_rounded,
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportActions extends StatelessWidget {
  const _SupportActions({
    required this.supportDiagnostics,
    required this.supportEmailUri,
    required this.diagnostics,
    required this.config,
    required this.copy,
  });

  final PortalSupportDiagnostics supportDiagnostics;
  final Uri supportEmailUri;
  final String diagnostics;
  final PortalPublicConfig config;
  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (supportDiagnostics.webappUrl.isNotEmpty)
        FilledButton.icon(
          onPressed: () => launchPortalLink(
            context,
            supportDiagnostics.webappUrl,
          ),
          icon: const Icon(Icons.open_in_browser),
          label: Text(copy.continueInWebCabinet),
        ),
      OutlinedButton.icon(
        onPressed: () => launchPortalLink(
          context,
          supportEmailUri.toString(),
        ),
        icon: const Icon(Icons.mail_outline),
        label: Text(copy.emailSupport),
      ),
      OutlinedButton.icon(
        onPressed: () => launchPortalLink(
          context,
          config.supportTelegramUrl,
        ),
        icon: const Icon(Icons.telegram),
        label: Text(copy.openTelegramSupport),
      ),
      OutlinedButton.icon(
        onPressed: () => copyPortalText(
          context,
          diagnostics,
          success: copy.diagnosticsCopied,
        ),
        icon: const Icon(Icons.health_and_safety_outlined),
        label: Text(copy.copyDiagnostics),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final button in buttons) ...[
                button,
                const Gap(12),
              ],
            ]..removeLast(),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: buttons,
        );
      },
    );
  }
}
