import 'dart:async';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'SignUp.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dog Finder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Text("Find a new friend today!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context,
                      'loginPage',
                  );
                },
                child: Text("Login",style: TextStyle(fontSize: 18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                fixedSize: Size(300, 40)
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context,
                    'signUpPage'
                );
              },
              child: Text("Sign Up",style: TextStyle(fontSize: 18),),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  fixedSize: Size(300, 40)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
