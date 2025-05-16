import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wildfriendfinder/FirstPage.dart';
import 'package:wildfriendfinder/Login.dart';
import 'package:wildfriendfinder/User.dart';

class AccountPage extends StatefulWidget {
  final String? userId;
  final int? index;

  const AccountPage({
    super.key,
    required this.userId,
    required this.index,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  TextEditingController usernameController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController DOBController = TextEditingController();
  TextEditingController ownerIdController = TextEditingController();

  Future<void> updateUserData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update({
        'username': usernameController.text.trim(),
        'fName': fNameController.text.trim(),
        'lName': lNameController.text.trim(),
        'password': passwordController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'DOB': DOBController.text.trim(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating account: ${e.toString()}'),
        ),
      );
      print('Error updating user data: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();


      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          usernameController.text = userData['username'] ?? '';
          fNameController.text = userData['fName'] ?? '';
          lNameController.text = userData['lName'] ?? '';
          passwordController.text = userData['password'] ?? '';
          emailController.text = userData['email'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          addressController.text = userData['address'] ?? '';
          DOBController.text = userData['DOB'] ?? '';
        });
      }
    } catch (e) {
      print('Error getting user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> deleteUserAccount() async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Account'),
              content: Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .delete();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login page
      Navigator.of(context).pushNamedAndRemoveUntil(
        'loginPage', // Replace with your actual login route name
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: ${e.toString()}'),
        ),
      );
      print('Error deleting user account: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> index = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = index['index'];
    print(_selectIndex);
    List<String> _widgetOption = [
      'homePage',
      'listingPage',
      'savedPage',
      'notifications',
      'accountPage'
    ];

    void pageChange(int index) {
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(context, _widgetOption[index],
            arguments: {'index': _selectIndex, 'userId': widget.userId});
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Account ",
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile icon and welcome text at the top
              Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${fNameController.text + " " + lNameController.text}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> FirstPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              // fixedSize: Size(100, 40)
                            ),
                            child: Text('Logout'))
                      ]),
                  SizedBox(height: 20),
                ],
              ),

              // Form fields
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: fNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: DOBController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      // fixedSize: Size(100, 40)
                    ),
                    child: Text('Update Profile'),
                  ),
                  ElevatedButton(
                    onPressed: deleteUserAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      // fixedSize: Size(100, 40)
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Text(
              //   'UserID: ${widget.userId}',
              //   style: TextStyle(fontSize: 16),
              // ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.deepPurple,
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                color: Colors.deepPurple,
              ),
              label: "List"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.bookmark,
                color: Colors.deepPurple,
              ),
              label: "Saved"
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                color: Colors.deepPurple,
              ),
              label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle,
                color: Colors.deepPurple,
              ),
              label: "Account")
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectIndex,
        selectedItemColor: Colors.indigoAccent,
        onTap: pageChange,
        iconSize: 35,
      ),
    );
  }
}
