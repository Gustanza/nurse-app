import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/firebase_api.dart';
import 'package:nurse_project/screens/auth_stuff.dart';
import 'package:nurse_project/screens/nyumbani.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initMessaging();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(const NurseApp(runnerble: Usahili()));
    } else {
      runApp(const NurseApp(runnerble: Nyumbani()));
    }
  });
}

class NurseApp extends StatelessWidget {
  final Widget runnerble;
  const NurseApp({super.key, required this.runnerble});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: runnerble,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
    );
  }
}
