import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Client-owned bridge facts that stay local until the shared schema expands.
class PortalFreeTierPolicy {
  const PortalFreeTierPolicy({
    this.trafficGb = 5,
    this.periodDays = 30,
    this.deviceLimit = 1,
    this.nodePool = 'NL-free',
  });

  final int trafficGb;
  final int periodDays;
  final int deviceLimit;
  final String nodePool;
}

class PortalClientStrategy {
  const PortalClientStrategy({
    this.publicTargetPlatforms = const ['Android', 'iOS', 'macOS', 'Windows'],
    this.automaticActivationPlatforms = const ['Android', 'Windows'],
    this.keyDeliveryPlatforms = const [
      'Android',
      'iOS',
      'macOS',
      'Windows',
    ],
    this.freeTier = const PortalFreeTierPolicy(),
  });

  final List<String> publicTargetPlatforms;
  final List<String> automaticActivationPlatforms;
  final List<String> keyDeliveryPlatforms;
  final PortalFreeTierPolicy freeTier;

  String get publicTargetBadgeLabel =>
      '${publicTargetPlatforms.length}-platform target';

  String get automaticActivationPlatformLine =>
      automaticActivationPlatforms.join(' / ');

  String get keyDeliveryPlatformLine => keyDeliveryPlatforms.join(' / ');

  String get publicTargetPlatformLine => publicTargetPlatforms.join(' / ');
}

final portalClientStrategyProvider = Provider<PortalClientStrategy>(
  (ref) => const PortalClientStrategy(),
);

class PortalTransportVariant {
  const PortalTransportVariant({
    required this.label,
    this.detail = '',
  });

  final String label;
  final String detail;

  String get badgeLabel => detail.isEmpty ? label : '$label · $detail';
}

PortalTransportVariant? resolvePortalTransportVariant(
  PortalExperience experience,
) {
  final managedKind = _humanizeTransportVariant(
    experience.importPayload.managedManifest.transportKind,
  );
  final profile = _humanizeTransportVariant(
    experience.connectionPolicy.transportProfile.isNotEmpty
        ? experience.connectionPolicy.transportProfile
        : experience.connectionPolicy.supportContext.transport,
  );

  if (managedKind.isEmpty && profile.isEmpty) return null;
  if (managedKind.isEmpty) {
    return PortalTransportVariant(label: profile);
  }
  if (profile.isEmpty || profile == managedKind) {
    return PortalTransportVariant(label: managedKind);
  }
  return PortalTransportVariant(label: managedKind, detail: profile);
}

String _humanizeTransportVariant(String raw) {
  final normalized = raw.trim();
  if (normalized.isEmpty) return '';

  return normalized
      .split(RegExp('[-_]+'))
      .where((token) => token.isNotEmpty)
      .map(_humanizeTransportToken)
      .where((token) => token.isNotEmpty)
      .join(' ');
}

String _humanizeTransportToken(String token) {
  final lower = token.trim().toLowerCase();
  if (lower.isEmpty) return '';
  if (RegExp(r'^\d+$').hasMatch(lower)) return lower;

  return switch (lower) {
    'grpc' => 'gRPC',
    'http' => 'HTTP',
    'https' => 'HTTPS',
    'http2' => 'HTTP/2',
    'tcp' => 'TCP',
    'udp' => 'UDP',
    'tls' => 'TLS',
    'quic' => 'QUIC',
    'ws' => 'WebSocket',
    'wss' => 'Secure WebSocket',
    'primary' => '',
    'fallback' => 'fallback',
    _ => '${lower[0].toUpperCase()}${lower.substring(1)}',
  };
}
