import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart';
import 'localization_service.dart';

class WhatsAppService {
  static Future<void> sendMessage({
    required BuildContext context,
    required String phone,
    required String name,
    required String shopName,
    required double balance,
  }) async {
    final localization = LocalizationService.of(context);
    if (localization == null) return;

    final message = localization.translate(
      'whatsapp_msg',
      args: [name, shopName, balance.toStringAsFixed(2)],
    );

    final url = 'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback for web or if whatsapp is not installed
      final webUrl = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl));
      }
    }
  }
}
