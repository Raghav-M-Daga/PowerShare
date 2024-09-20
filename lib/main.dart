import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_app/pages/allRequests.dart';
import 'package:share_app/pages/allRequests.dart';
import 'package:share_app/pages/requestsYouAccepted.dart';

import 'package:share_app/pages/structure/Competition.dart';
import 'package:share_app/pages/welcome_screenV2.dart';
import 'package:share_app/pages/firestoreTest.dart';
import 'package:share_app/pages/structure/NotificationsHandlerV2.dart';
import 'package:share_app/pages/yourRequests.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await LocalNoticeService().setup();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YourRequests(new Competition("November 12th Qualifying Tournament", "12/10/22", "NorCal", true)),
      routes: {
        'welcome_screen': (context) => WelcomeScreen(),
        // 'registration_screen': (context) => RegistrationScreen(),
        'firestore_test': (context) => UserInformation(),
        // 'sign_up': (context) => RegistrationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}