abstract class Constants {
  static const appName = "POKROV";
  static const githubUrl = String.fromEnvironment(
    "PORTAL_RELEASE_REPOSITORY_URL",
  );
  static const githubReleasesApiUrl = String.fromEnvironment(
    "PORTAL_RELEASES_API_URL",
  );
  static const githubLatestReleaseUrl = String.fromEnvironment(
    "PORTAL_RELEASES_LATEST_URL",
  );
  static const appCastUrl = String.fromEnvironment(
    "PORTAL_RELEASES_APPCAST_URL",
  );
  static bool get hasReleaseRepositoryUrl => githubUrl.isNotEmpty;
  static bool get hasReleaseApiUrl => githubReleasesApiUrl.isNotEmpty;
  static bool get hasAppCastUrl => appCastUrl.isNotEmpty;
  static bool get hasReleaseMetadata =>
      hasReleaseRepositoryUrl && hasReleaseApiUrl && hasAppCastUrl;
  static const telegramChannelUrl = "https://t.me/pokrov_vpn";
  static const privacyPolicyUrl = "https://pokrov.space/privacy";
  static const termsAndConditionsUrl = "https://pokrov.space/terms";
  static const cfWarpPrivacyPolicy =
      "https://www.cloudflare.com/application/privacypolicy/";
  static const cfWarpTermsOfService =
      "https://www.cloudflare.com/application/terms/";
}

const kAnimationDuration = Duration(milliseconds: 250);
