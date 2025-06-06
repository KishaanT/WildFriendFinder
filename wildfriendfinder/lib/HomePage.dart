import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wildfriendfinder/AccountPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:wildfriendfinder/NotificationsPage.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  final int index;

  const HomePage({super.key, required this.userId, required this.index});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? fullname;

  Future<Map<String, dynamic>> fetchDog() async {
    final url = Uri.parse('https://api.thedogapi.com/v1/breeds');
    final response = await http.get(
      url,
      headers: {
        'x-api-key':
            'live_iXh3yfMN3LW4GF7kkO3YIactwGRx2VtxwlvqXKeH3cphARP9tWoWAo3WA7C7iQBW',
      },
    );
    if (response.statusCode == 200) {
      final List breeds = jsonDecode(response.body);

      // Pick a breed based on today's date
      final int index = DateTime.now().minute % breeds.length;
      final breed = breeds[index];

      return {
        'name': breed['name'],
        'temperament': breed['temperament'] ?? 'Unknown',
        'image': breed['image']?['url'] ?? '',
        'life-span': breed['life_span'] ?? 'Unknown',
      };
    } else {
      throw Exception('Failed to load breeds');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser(widget.userId!);
  }

  Future<void> fetchUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final userdata = snapshot.data();
        String fName = userdata!['fName'];
        String lName = userdata['lName'];
        setState(() {
          fullname = '$fName $lName';
        });
        print('Full name: $fName $lName');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Map<String, dynamic> data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    int _selectIndex = widget.index;
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
        Navigator.pushNamed(context, _widgetOption[index], arguments: {
          'index': _selectIndex,
          'userId': widget.userId,
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Dog Finder",
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
      body: Column(
      children: [
      if (fullname != null)
        Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Text(
    'Welcome, $fullname',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
                future: fetchDog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final dog = snapshot.data!;
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Dog of the Day',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic)),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          if (dog['image'].isNotEmpty)
                            Image.network(dog['image'], height: 200),
                          SizedBox(height: 16),
                          Text(dog['name'],
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text(dog['temperament'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Life Span : ' + dog['life-span'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
                  }
                }),
          ),
        ],
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
