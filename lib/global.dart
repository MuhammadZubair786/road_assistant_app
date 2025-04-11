import 'package:url_launcher/url_launcher.dart';

openWhatsapp(data) async {
  final whatsappNumber = data["contact_no"].replaceAll('+', '');
  final whatsappUrl = Uri.parse("https://wa.me/$whatsappNumber");
  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl);
  } else {
    throw 'Could not launch $whatsappUrl';
  }
}

openCallDailer(data) async {
  final Uri uri = Uri(scheme: 'tel', path: data['contact_no']);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<void> openSmsApp(String phoneNumber, [String? message]) async {
  final Uri smsUri = Uri(
    scheme: 'sms',
    path: phoneNumber,
    queryParameters: message != null ? {'body': message} : null,
  );

  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $smsUri';
  }
}
