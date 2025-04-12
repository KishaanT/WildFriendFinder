import 'dart:async';
import 'package:flutter/material.dart';
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
            Text("Wild Friend Finder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Text("Find your wild friend today!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () {},
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
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
