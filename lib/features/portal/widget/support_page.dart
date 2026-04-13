import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
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
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.supportTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: PortalAsyncBody(
                  value: experience,
                  builder: (context, portal) {
                    final supportDiagnostics = buildPortalSupportDiagnostics(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              const Gap(16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => launchPortalLink(
                                      context,
                                      config.supportTelegramUrl,
                                    ),
                                    icon: const Icon(Icons.telegram),
                                    label: Text(copy.openTelegramSupport),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => launchPortalLink(
                                      context,
                                      supportEmailUri.toString(),
                                    ),
                                    icon: const Icon(Icons.mail_outline),
                                    label: Text(copy.emailSupport),
                                  ),
                                  if (supportDiagnostics.webappUrl.isNotEmpty)
                                    OutlinedButton.icon(
                                      onPressed: () => launchPortalLink(
                                        context,
                                        supportDiagnostics.webappUrl,
                                      ),
                                      icon: const Icon(Icons.open_in_browser),
                                      label: Text(
                                        copy.isRussian
                                            ? 'Открыть веб-кабинет'
                                            : 'Open web cabinet',
                                      ),
                                    ),
                                  OutlinedButton.icon(
                                    onPressed: () => copyPortalText(
                                      context,
                                      diagnostics,
                                      success: copy.diagnosticsCopied,
                                    ),
                                    icon: const Icon(
                                      Icons.health_and_safety_outlined,
                                    ),
                                    label: Text(copy.copyDiagnostics),
                                  ),
                                ],
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
                        const Gap(16),
                        if (portal.hasProvisionedAccess)
                          ...portal.supportThreads.map(
                            (thread) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PortalSectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            copy.localizeServerText(
                                              thread.subject,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        PortalStatusBadge(
                                          label: copy.supportStatus(
                                            thread.status,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(10),
                                    ...thread.messages.take(2).map(
                                          (message) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
