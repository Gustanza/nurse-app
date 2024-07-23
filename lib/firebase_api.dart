import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleNots(RemoteMessage message) async {
  //
}

class FirebaseApi {
  final FirebaseMessaging fm = FirebaseMessaging.instance;

  initMessaging() async {
    await fm.requestPermission();
    await fm.getToken();
    FirebaseMessaging.onBackgroundMessage(handleNots);
  }
}
