/// App-wide settings to fill in before publishing.
class AppConfig {
  static const version = '1.0.0';

  /// Where "Report an error" emails go when Firebase is not set up.
  static const supportEmail = 'your-email@example.com';

  /// Your deployed Cloudflare Worker URL, e.g.
  /// `https://processpk-ask.YOUR-SUBDOMAIN.workers.dev`
  /// Leave empty to hide "Ask ProcessPK".
  static const aiEndpoint = '';

  /// Free questions per day on each phone.
  static const aiDailyLimit = 5;

  /// Public URL of your privacy policy (required by Google Play).
  static const privacyPolicyUrl = 'https://example.com/processpk-privacy';
}
