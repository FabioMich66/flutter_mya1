import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  Future<void> openAsApp(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
