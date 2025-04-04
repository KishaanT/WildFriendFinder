import 'dart:async';

import 'package:flutter/material.dart';
import 'FirstPage.dart';

void main() {
  runApp(const WildFriendFinder());
}

class WildFriendFinder extends StatelessWidget {
  const WildFriendFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
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
        () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> FirstPage()))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey,
      child: Text("Splash Screen to change", style: TextStyle(fontSize: 18, color: Colors.white),),
      height: 100,
      width: 300,
    );
  }
}


