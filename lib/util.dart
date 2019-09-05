import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class Util {
  static Future<void> launchMap(String address) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$address";
    googleMapUrl = Uri.encodeFull(googleMapUrl);
    if (Platform.isIOS) {
      if (!await canLaunch("googlemaps://")) {
        var iosMapUrl = "http://maps.apple.com/?q=$address";
        iosMapUrl = Uri.encodeFull(iosMapUrl);
        await launch(iosMapUrl);
        return;
      }
    }
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    }
  }
}
