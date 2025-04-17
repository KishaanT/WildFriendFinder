import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wildfriendfinder/User.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  TextEditingController usernameController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController DOBController = TextEditingController();

  Future<int> getNextUserID() async {
    final counterRef = FirebaseFirestore.instance.collection('Counters').doc('userCounter');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentCount = snapshot.exists ? snapshot.get('count') : 0;
      int nextID = currentCount + 1;

      transaction.set(counterRef, {'count': nextID});
      return nextID;
    });
  }

  Future<void> registerUser(

      String username,
      String password,
      String fName,
      String lName,
      String email,
      String phone,
      String address,
      String DOB) async {
    try {
      QuerySnapshot<Map<String, dynamic>> checkUserExist =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: username)
              .get();

      if (checkUserExist.docs.isNotEmpty) {
        print('Username already exist');
      }

      int newUserId = await getNextUserID();

      User newUser = User(
        userId: newUserId,
        username: username,
        fName : fName,
        lName : lName,
        password: password,
        email: email,
        phone: phone,
        address: address,
        DOB: DOB,
      );

      DocumentReference<Map<String, dynamic>> user = await FirebaseFirestore
          .instance
          .collection('Users')
          .add(newUser.toFirestore());

      clearController();
      print('Successfully Registered. ${newUser}');
    } catch (e) {
      print('Error, Registration incomplete');
    }
  }

  void clearController() {
    fNameController.clear();
    lNameController.clear();
    usernameController.clear();
    passwordController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    DOBController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Wild Friend Finder",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  SizedBox(height: 30),
                  SizedBox(width: 350,
                    child:TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ), ),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: fNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: lNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ), ),

                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: DOBController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                    ),),

                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ), ),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: () async {
                    String fName = fNameController.text.trim();
                    String lName = lNameController.text.trim();
                    String username = usernameController.text.trim();
                    String password = passwordController.text.trim();
                    String email = emailController.text.trim();
                    String phone = phoneController.text.trim();
                    String address = addressController.text.trim();
                    String DOB = DOBController.text.trim();
                    registerUser(username, password, fName, lName, email, phone, address, DOB);
                    // Navigator.pop(context);
                  }, child: Text('Register'))
                ],
              )),
        ));
  }
}
