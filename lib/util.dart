import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
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

  static void showIconTextToast(
      BuildContext context, IconData icon, String text) {
    BotToast.showCustomText(
      //backgroundColor: Colors.black26,
      align: Alignment(0, -0.1),
      toastBuilder: (cancelFunc) {
        return FractionallySizedBox(
          widthFactor: 0.4,
          heightFactor: 0.3,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.black54,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.mail,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double getGrayLevel({Color color, int r, int g, int b}) {
    if (color != null) {
      r = color.red;
      g = color.green;
      b = color.blue;
    }
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  }
}
