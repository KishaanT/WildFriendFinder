import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
 import 'HomePage.dart';
 import 'NewListing.dart';
import 'OneListing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ListingPage extends StatefulWidget {
  final String? userId;
  final int? index;

  const ListingPage({super.key,
    required this.userId,
    required this.index,});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {

  final Stream<QuerySnapshot> _petStream = FirebaseFirestore.instance.collection('Pets').snapshots();

  CollectionReference pets = FirebaseFirestore.instance.collection('Pets');


  @override
  Widget build(BuildContext context) {


    final Map<String, dynamic> index = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = index['index'];
    List<String> _widgetOption = [
      'homePage',
      'listingPage',
      'accountPage'
    ];
    List _petsList = [];

    Future<void> fetchPets() async {
      final String response =
          await rootBundle.loadString('assets/jsonFiles/petsListing.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _petsList = data;
      });
    }

    void pageChange(int index){
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(
            context,
            _widgetOption[index],
            arguments: {
              'userId' : widget.userId,
              'index': _selectIndex
            }
        );
      });
    }


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Wild Friend Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Column(
        children: [
          ListView.builder(
              itemCount: _petsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_petsList[index]['name']),
                  subtitle: Text('${_petsList[index]['species']} • ${_petsList[index]['breed']}'),
                  trailing: Text('${_petsList[index]['age']} yrs'),
                );
              }
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Pets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final pets = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(pet['name'] ?? 'Unnamed'),
                        subtitle: Text('${pet['species']} • ${pet['breed']}'),
                        trailing: Text('${pet['age']} yrs'),
                        onTap: () {
                          // Navigator.pushNamed(
                          //     context,
                          //     'oneListingPage',
                          // arguments: {
                          //       'petId': pet.id
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OneListing(petId: pet.id, userId: widget.userId)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Centered "New Listing" Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewListing(ownerId: widget.userId), // Pass ownerId here
                    ),
                  );
                },
                child: Text('New Listing'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.deepPurple,),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list,color: Colors.deepPurple,),label: "List"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle,color: Colors.deepPurple,),label: "Account")
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

