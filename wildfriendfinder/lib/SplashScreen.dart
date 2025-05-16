import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wildfriendfinder/NotificationsPage.dart';
import 'FirstPage.dart';
import 'Login.dart';
import 'SignUp.dart';
import 'HomePage.dart';
import 'ListingPage.dart';
import 'NewListing.dart';
import 'OneListing.dart';
import 'dart:async';
import 'AccountPage.dart';
import 'SavedPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD0m59RSyjasm8k5EmQ_6JNse-rN4hN-eo",
          appId: "153879182337",
          messagingSenderId: "153879182337",
          projectId: "wildfriendfinder"));

  runApp(const WildFriendFinder());
}

class WildFriendFinder extends StatelessWidget {
  const WildFriendFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        'firstPage': (context) => FirstPage(),
        'loginPage': (context) => Login(),
        'signUpPage': (context) => SignUp(),
        'listingPage': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>? ?? <String,dynamic>{};
          return ListingPage(
            userId: args?['userId'],
            index: args?['index'],
          );
        },
        'newListingPage': (context) => NewListing(ownerId: null),
        'oneListingPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OneListing(
            userId: args['userId'],
            petId: null,
          );
        },
        'accountPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AccountPage(
            userId: args['userId'],
            index: args['index'],
          );
        },
        'homePage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return HomePage(
            userId: args['userId'],
            index: args['index'],
          );
        },
        'notifications': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
          return NotificationsPage(
            userId: args['userId'],
            index: args['index'],
          );
        },
        'savedPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>;
          return SavedPage(
              userId: args['userId'],
              index: args['index'],
          );
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushNamed(
              context,
              'firstPage',
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Saved Listings",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Icon(
              Icons.pets,
              size: 100,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
