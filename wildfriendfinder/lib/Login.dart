import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wildfriendfinder/User.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wildfriendfinder/HomePage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? userLoggedIn;

  // Notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize the notification plugin
  void _initializeNotifications() async {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher'); // icon for Android
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show a simple notification
  Future<void> _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id', // Channel ID
      'channel_name', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Welcome Back!', // Notification title
      'New Request Notification', // Notification body
      generalNotificationDetails,
    );
  }

  Future<bool> checkUserRequests(String userId) async {
    QuerySnapshot<Map<String, dynamic>> requests = await FirebaseFirestore.instance.collection('PetRequests')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return requests.docs.isNotEmpty;
  }

  Future<void> login(String username, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> login = await FirebaseFirestore
          .instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (login.docs.isNotEmpty) {
        print('Login Successful');
        String userId = login.docs.first.id;

        bool checkRequest = await checkUserRequests(userId);
        if (checkRequest) {
          print('Has notifications');
          await _showNotification();
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userId,index:0),
          ),
        );
      } else {
        showLoginError("Invalid username or password");
      }
    } catch (e) {
      print('Login Error: $e');
    }
  }
  void showLoginError(String error) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Login Unsuccessful'),
              content: Text(error),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ));
  }

  void clearController() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Login'),
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Wild Friend Finder",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  SizedBox(height: 30),
                  Text("Login into Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  Text("Enter your username and password to sign in", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 20,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ), ),


                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: () async {
                     await login(usernameController.text.trim(), passwordController.text.trim());
                     clearController();
                     // _showNotification();
                  }, child: Text('Login', style: TextStyle(color: Colors.black)),),
                  SizedBox(height: 10),
                ],
              )
          ),
        ));
  }
}
