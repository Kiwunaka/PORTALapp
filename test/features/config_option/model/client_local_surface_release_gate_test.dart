import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/features/config_option/model/client_local_surface_release_gate.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';

void main() {
  group('ClientLocalSurfaceReleaseGate.evaluate', () {
    test('blocks Android release when native command server audit is missing', () {
      final result = ClientLocalSurfaceReleaseGate.evaluate(
        config: _baseConfig(),
        platform: ClientPlatform.android,
        buildMode: ClientBuildMode.release,
        nativeCommandServerAuditPassed: false,
      );

      expect(result.isBlocked, isTrue);
      expect(
        result.findings,
        contains(LocalSurfaceFinding.nativeCommandServerUnverified),
      );
    });

    test('blocks release when Clash API or LAN sharing are enabled', () {
      final result = ClientLocalSurfaceReleaseGate.evaluate(
        config: _baseConfig().copyWith(
          enableClashApi: true,
          allowConnectionFromLan: true,
        ),
        platform: ClientPlatform.android,
        buildMode: ClientBuildMode.release,
        nativeCommandServerAuditPassed: true,
      );

      expect(result.isBlocked, isTrue);
      expect(result.findings, contains(LocalSurfaceFinding.clashApiEnabled));
      expect(result.findings, contains(LocalSurfaceFinding.lanAccessEnabled));
    });

    test('blocks Android release when local listener ports stay enabled', () {
      final result = ClientLocalSurfaceReleaseGate.evaluate(
        config: _baseConfig().copyWith(
          mixedPort: 12334,
          tproxyPort: 12335,
          localDnsPort: 16450,
        ),
        platform: ClientPlatform.android,
        buildMode: ClientBuildMode.release,
        nativeCommandServerAuditPassed: true,
      );

      expect(result.isBlocked, isTrue);
      expect(result.findings, contains(LocalSurfaceFinding.mixedPortEnabled));
      expect(result.findings, contains(LocalSurfaceFinding.tproxyPortEnabled));
      expect(result.findings, contains(LocalSurfaceFinding.localDnsPortEnabled));
    });

    test('does not block non-Android release when only Android-native audit is missing', () {
      final result = ClientLocalSurfaceReleaseGate.evaluate(
        config: _baseConfig(),
        platform: ClientPlatform.windows,
        buildMode: ClientBuildMode.release,
        nativeCommandServerAuditPassed: false,
      );

      expect(result.isBlocked, isFalse);
      expect(result.findings, isEmpty);
    });
  });
}

SingboxConfigOption _baseConfig() {
  return const SingboxConfigOption(
    region: 'other',
    routingMode: RoutingMode.global,
    blockAds: false,
    useXrayCoreWhenPossible: false,
    executeConfigAsIs: false,
    logLevel: LogLevel.warn,
    resolveDestination: false,
    ipv6Mode: IPv6Mode.disable,
    remoteDnsAddress: 'udp://1.1.1.1',
    remoteDnsDomainStrategy: DomainStrategy.auto,
    directDnsAddress: 'udp://1.1.1.1',
    directDnsDomainStrategy: DomainStrategy.auto,
    mixedPort: 0,
    tproxyPort: 0,
    localDnsPort: 0,
    tunImplementation: TunImplementation.gvisor,
    mtu: 9000,
    strictRoute: true,
    connectionTestUrl: 'http://cp.cloudflare.com',
    urlTestInterval: Duration(minutes: 10),
    enableClashApi: false,
    clashApiPort: 16756,
    enableTun: true,
    enableTunService: false,
    setSystemProxy: false,
    bypassLan: false,
    allowConnectionFromLan: false,
    enableFakeDns: false,
    enableDnsRouting: true,
    independentDnsCache: true,
    rules: [],
    mux: SingboxMuxOption(
      enable: false,
      padding: false,
      maxStreams: 8,
      protocol: MuxProtocol.h2mux,
    ),
    tlsTricks: SingboxTlsTricks(
      enableFragment: false,
      fragmentSize: OptionalRange(min: 10, max: 30),
      fragmentSleep: OptionalRange(min: 2, max: 8),
      mixedSniCase: false,
      enablePadding: false,
      paddingSize: OptionalRange(min: 1, max: 1500),
    ),
    warp: SingboxWarpOption(
      enable: false,
      mode: WarpDetourMode.proxyOverWarp,
      wireguardConfig: '',
      licenseKey: '',
      accountId: '',
      accessToken: '',
      cleanIp: 'auto',
      cleanPort: 0,
      noise: OptionalRange(min: 1, max: 3),
      noiseSize: OptionalRange(min: 10, max: 30),
      noiseDelay: OptionalRange(min: 10, max: 30),
      noiseMode: 'm4',
    ),
    warp2: SingboxWarpOption(
      enable: false,
      mode: WarpDetourMode.proxyOverWarp,
      wireguardConfig: '',
      licenseKey: '',
      accountId: '',
      accessToken: '',
      cleanIp: 'auto',
      cleanPort: 0,
      noise: OptionalRange(min: 1, max: 3),
      noiseSize: OptionalRange(min: 10, max: 30),
      noiseDelay: OptionalRange(min: 10, max: 30),
      noiseMode: 'm4',
    ),
  );
}
