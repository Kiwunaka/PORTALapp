import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum PortalSectionTone {
  neutral,
  accent,
  muted,
}

class PortalSectionCard extends StatelessWidget {
  const PortalSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.tone = PortalSectionTone.neutral,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final PortalSectionTone tone;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      padding: padding,
      accent: accent,
      style: switch (tone) {
        PortalSectionTone.neutral => PremiumPanelStyle.neutral,
        PortalSectionTone.accent => PremiumPanelStyle.accent,
        PortalSectionTone.muted => PremiumPanelStyle.muted,
      },
      child: child,
    );
  }
}

class PortalMetricTile extends StatelessWidget {
  const PortalMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumIconOrb(icon: icon, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.labelLarge),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PortalStatusBadge extends StatelessWidget {
  const PortalStatusBadge({
    required this.label,
    super.key,
    this.icon,
    this.accent,
  });

  final String label;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return PremiumBadge(
      label: label,
      icon: icon,
      accent: accent,
    );
  }
}

class PortalListRow extends StatelessWidget {
  const PortalListRow({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final trailingWidget = trailing;
        final useCompactLayout =
            trailingWidget != null && constraints.maxWidth < 430;
        final textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );

        if (useCompactLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 14),
                  ],
                  Expanded(child: textBlock),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: trailingWidget,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 14),
            ],
            Expanded(child: textBlock),
            if (trailingWidget != null) ...[
              const SizedBox(width: 12),
              Flexible(child: trailingWidget),
            ],
          ],
        );
      },
    );

    if (onTap == null) return row;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: row,
      ),
    );
  }
}

class PortalAsyncBody extends StatelessWidget {
  const PortalAsyncBody({
    required this.value,
    required this.builder,
    super.key,
    this.loadingLabel,
    this.errorLabel,
  });

  final AsyncValue<PortalExperience> value;
  final Widget Function(BuildContext context, PortalExperience experience)
      builder;
  final String? loadingLabel;
  final String? errorLabel;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);
    final resolvedLoading = loadingLabel ?? copy.loadingServiceData;
    final resolvedError = errorLabel ?? copy.serviceUnavailable;

    return value.when(
      data: (experience) => builder(context, experience),
      error: (error, _) => PortalSectionCard(
        tone: PortalSectionTone.muted,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumSectionHeader(
              eyebrow: copy.isRussian ? 'Статус сервиса' : 'Service status',
              title: resolvedError,
              subtitle: '$error',
            ),
          ],
        ),
      ),
      loading: () => PortalSectionCard(
        tone: PortalSectionTone.muted,
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                resolvedLoading,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatPortalDate(DateTime? value) {
  if (value == null) return '--';
  final safe = value.toLocal();
  final month = safe.month.toString().padLeft(2, '0');
  final day = safe.day.toString().padLeft(2, '0');
  return '$day.$month.${safe.year}';
}

String formatPortalTraffic(double value) {
  if (value <= 0) return '0 GB';
  final fixed =
      value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return '$fixed GB';
}

String buildPortalCheckoutUrl(String rawUrl, {String? planCode}) {
  final safeRawUrl = rawUrl.trim();
  if (safeRawUrl.isEmpty) return '';
  final uri = Uri.tryParse(safeRawUrl);
  if (uri == null) return safeRawUrl;
  final normalizedPlan = planCode?.trim() ?? '';
  if (normalizedPlan.isEmpty) return uri.toString();
  final query = Map<String, String>.from(uri.queryParameters);
  query['plan'] = normalizedPlan;
  return uri.replace(queryParameters: query).toString();
}

double portalAdaptiveTileWidth(
  BuildContext context, {
  double horizontalPadding = 32,
  double spacing = 12,
  double minWidth = 180,
  double maxWidth = 260,
  int preferredColumns = 2,
}) {
  final availableWidth = MediaQuery.sizeOf(context).width - horizontalPadding;
  if (preferredColumns <= 1) {
    return availableWidth.clamp(minWidth, maxWidth);
  }

  final columnsWidth =
      (availableWidth - (spacing * (preferredColumns - 1))) / preferredColumns;
  if (columnsWidth >= minWidth) {
    return columnsWidth.clamp(minWidth, maxWidth);
  }

  return availableWidth.clamp(minWidth, maxWidth);
}

bool portalUseCompactLayout(
  BuildContext context, {
  double breakpoint = 430,
}) {
  return MediaQuery.sizeOf(context).width < breakpoint;
}

class _PortalSupportDiagnosticsCompat {
  const _PortalSupportDiagnosticsCompat({
    required this.accountId,
    required this.deviceName,
    required this.planCode,
    required this.appVersion,
    required this.platform,
    required this.operatingSystemVersion,
    required this.linkedTelegramId,
    required this.linkedTelegramUsername,
    required this.routingMode,
    required this.dnsPolicy,
    required this.transportProfile,
    required this.transportKind,
    required this.engineHint,
    required this.profileRevision,
    required this.packageCatalogVersion,
    required this.rulesetVersion,
    required this.supportRecoveryOrder,
    required this.webappUrl,
  });

  factory _PortalSupportDiagnosticsCompat.fromPortal({
    required PortalExperience portal,
    required PortalPublicConfig config,
    AppInfoEntity? appInfo,
  }) {
    final supportContext = portal.connectionPolicy.supportContext;
    final managedManifest = portal.importPayload.managedManifest;

    return _PortalSupportDiagnosticsCompat(
      accountId: _readString(
        () => portal.session.accountId,
        fallback: 'unknown',
      ),
      deviceName: _readString(
        () => portal.session.deviceName,
        fallback: 'Current device',
      ),
      planCode: _readString(
        () => portal.subscription.currentPlanCode,
        fallback: 'unknown',
      ),
      appVersion: appInfo?.presentVersion ?? '',
      platform: appInfo?.operatingSystem ?? '',
      operatingSystemVersion: appInfo?.operatingSystemVersion ?? '',
      linkedTelegramId: _readInt(() => portal.session.linkedTelegramId),
      linkedTelegramUsername: _readString(
        () => portal.session.linkedTelegramUsername,
      ),
      routingMode: _firstNonEmpty([
        _readString(() => supportContext.routingMode),
        _readString(() => portal.connectionPolicy.routingModeDefault),
      ]),
      dnsPolicy: _readString(() => portal.connectionPolicy.dnsPolicy),
      transportProfile: _firstNonEmpty([
        _readString(() => portal.connectionPolicy.transportProfile),
        _readString(() => supportContext.transport),
      ]),
      transportKind: _readString(() => managedManifest.transportKind),
      engineHint: _readString(() => managedManifest.engineHint),
      profileRevision: _readString(() => managedManifest.profileRevision),
      packageCatalogVersion: _readString(
        () => portal.connectionPolicy.packageCatalogVersion,
      ),
      rulesetVersion: _readString(() => portal.connectionPolicy.rulesetVersion),
      supportRecoveryOrder: _readStringList(
        () => portal.connectionPolicy.supportRecoveryOrder,
        fallback: const ['app', 'web', 'telegram'],
      ),
      webappUrl: config.webappUrl.trim(),
    );
  }

  final String accountId;
  final String deviceName;
  final String planCode;
  final String appVersion;
  final String platform;
  final String operatingSystemVersion;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
  final String routingMode;
  final String dnsPolicy;
  final String transportProfile;
  final String transportKind;
  final String engineHint;
  final String profileRevision;
  final String packageCatalogVersion;
  final String rulesetVersion;
  final List<String> supportRecoveryOrder;
  final String webappUrl;

  String linkedTelegramLabel(bool isRussian) {
    if (linkedTelegramUsername.trim().isNotEmpty && linkedTelegramId > 0) {
      return '@${linkedTelegramUsername.trim()} ($linkedTelegramId)';
    }
    if (linkedTelegramUsername.trim().isNotEmpty) {
      return '@${linkedTelegramUsername.trim()}';
    }
    if (linkedTelegramId > 0) {
      return isRussian ? 'ID $linkedTelegramId' : 'ID $linkedTelegramId';
    }
    return isRussian ? 'не привязан' : 'not linked';
  }

  String get recoveryOrderLabel {
    final normalized = supportRecoveryOrder
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (normalized.isEmpty) {
      return 'app -> web -> telegram';
    }
    return normalized.join(' -> ');
  }
}

PortalSupportDiagnostics buildPortalSupportDiagnostics({
  required PortalExperience portal,
  required PortalPublicConfig config,
  AppInfoEntity? appInfo,
}) {
  final diagnostics = _PortalSupportDiagnosticsCompat.fromPortal(
    portal: portal,
    config: config,
    appInfo: appInfo,
  );
  return PortalSupportDiagnostics(
    accountId: diagnostics.accountId,
    deviceName: diagnostics.deviceName,
    planCode: diagnostics.planCode,
    appVersion: diagnostics.appVersion,
    platform: diagnostics.platform,
    operatingSystemVersion: diagnostics.operatingSystemVersion,
    linkedTelegramId: diagnostics.linkedTelegramId,
    linkedTelegramUsername: diagnostics.linkedTelegramUsername,
    routingMode: diagnostics.routingMode,
    dnsPolicy: diagnostics.dnsPolicy,
    transportProfile: diagnostics.transportProfile,
    transportKind: diagnostics.transportKind,
    engineHint: diagnostics.engineHint,
    profileRevision: diagnostics.profileRevision,
    packageCatalogVersion: diagnostics.packageCatalogVersion,
    rulesetVersion: diagnostics.rulesetVersion,
    supportRecoveryOrder: diagnostics.supportRecoveryOrder,
    webappUrl: diagnostics.webappUrl,
  );
}

String buildPortalDiagnosticsText({
  required PortalSupportDiagnostics diagnostics,
  bool isRussian = false,
}) {
  final lines = <String>[
    '${_diagnosticsLabel("Account", "Аккаунт", isRussian)}: ${diagnostics.accountId}',
    '${_diagnosticsLabel("Device", "Устройство", isRussian)}: ${diagnostics.deviceName}',
    '${_diagnosticsLabel("Plan", "План", isRussian)}: ${diagnostics.planCode}',
    '${_diagnosticsLabel("App version", "Версия приложения", isRussian)}: ${_valueOrFallback(diagnostics.appVersion)}',
    '${_diagnosticsLabel("Platform", "Платформа", isRussian)}: ${_combinePlatform(diagnostics.platform, diagnostics.operatingSystemVersion)}',
    '${_diagnosticsLabel("Linked Telegram", "Telegram", isRussian)}: ${_linkedTelegramLabel(diagnostics, isRussian)}',
    '${_diagnosticsLabel("Routing mode", "Режим маршрутизации", isRussian)}: ${_valueOrFallback(diagnostics.routingMode)}',
    '${_diagnosticsLabel("DNS policy", "DNS-политика", isRussian)}: ${_valueOrFallback(diagnostics.dnsPolicy)}',
    '${_diagnosticsLabel("Transport profile", "Транспортный профиль", isRussian)}: ${_valueOrFallback(diagnostics.transportProfile)}',
    '${_diagnosticsLabel("Package catalog", "Каталог пакетов", isRussian)}: ${_valueOrFallback(diagnostics.packageCatalogVersion)}',
    '${_diagnosticsLabel("Ruleset", "Набор правил", isRussian)}: ${_valueOrFallback(diagnostics.rulesetVersion)}',
    '${_diagnosticsLabel("Recovery order", "Порядок восстановления", isRussian)}: ${diagnostics.recoveryOrderLabel}',
    '${_diagnosticsLabel("Web cabinet", "Веб-кабинет", isRussian)}: ${_valueOrFallback(diagnostics.webappUrl)}',
  ];

  _appendOptionalLine(
    lines,
    label: _diagnosticsLabel("Transport kind", "Тип транспорта", isRussian),
    value: diagnostics.transportKind,
  );
  _appendOptionalLine(
    lines,
    label: _diagnosticsLabel("Engine hint", "Движок", isRussian),
    value: diagnostics.engineHint,
  );
  _appendOptionalLine(
    lines,
    label: _diagnosticsLabel("Profile revision", "Ревизия профиля", isRussian),
    value: diagnostics.profileRevision,
  );

  return lines.join('\n');
}

Uri buildPortalSupportEmailUri({
  required String contactEmail,
  required PortalSupportDiagnostics diagnostics,
  required String appLabel,
  bool isRussian = false,
}) {
  return Uri(
    scheme: 'mailto',
    path: contactEmail.trim(),
    queryParameters: {
      'subject': '$appLabel support request',
      'body': [
        if (isRussian) 'Опишите, что именно не работает:' else 'Describe what is going wrong:',
        '',
        buildPortalDiagnosticsText(
          diagnostics: diagnostics,
          isRussian: isRussian,
        ),
      ].join('\n'),
    },
  );
}

Future<void> launchPortalLink(
  BuildContext context,
  String rawUrl, {
  String? failureMessage,
}) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || rawUrl.trim().isEmpty) return;
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    final copy = PortalCopy.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failureMessage ?? copy.linkOpenFailed)),
    );
  }
}

String _diagnosticsLabel(String en, String ru, bool isRussian) {
  return isRussian ? ru : en;
}

String _linkedTelegramLabel(
  PortalSupportDiagnostics diagnostics,
  bool isRussian,
) {
  return diagnostics.linkedTelegramLabel(isRussian);
}

String _valueOrFallback(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '--';
  return normalized;
}

String _combinePlatform(String platform, String operatingSystemVersion) {
  final normalizedPlatform = platform.trim();
  final normalizedVersion = operatingSystemVersion.trim();
  if (normalizedPlatform.isEmpty && normalizedVersion.isEmpty) return '--';
  if (normalizedPlatform.isEmpty) return normalizedVersion;
  if (normalizedVersion.isEmpty) return normalizedPlatform;
  return '$normalizedPlatform $normalizedVersion';
}

void _appendOptionalLine(
  List<String> lines, {
  required String label,
  required String value,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty) return;
  lines.add('$label: $normalized');
}

dynamic _readDynamic(dynamic Function() reader) {
  try {
    return reader();
  } catch (_) {
    return null;
  }
}

String _readString(
  dynamic Function() reader, {
  String fallback = '',
}) {
  final value = _readDynamic(reader);
  if (value == null) return fallback;
  return value.toString().trim();
}

int _readInt(dynamic Function() reader, {int fallback = 0}) {
  final value = _readDynamic(reader);
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _readStringList(
  dynamic Function() reader, {
  List<String> fallback = const [],
}) {
  final value = _readDynamic(reader);
  if (value is List) {
    final normalized = value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    if (normalized.isNotEmpty) return normalized;
  }
  return fallback;
}

String _firstNonEmpty(Iterable<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

Future<void> copyPortalText(
  BuildContext context,
  String value, {
  String? success,
}) async {
  if (value.trim().isEmpty) return;
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    final copy = PortalCopy.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ?? copy.copied)),
    );
  }
}
