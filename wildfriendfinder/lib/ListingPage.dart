import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
 import 'HomePage.dart';
 import 'NewListing.dart';
import 'OneListing.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

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
      'newListingPage'
    ];

    void pageChange(int index){
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(
            context,
            _widgetOption[index],
            arguments: {
              'index': _selectIndex
            }
        );
      });
    }


    return Scaffold(
      appBar: AppBar(
        title: Text("Wild Friend Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Column(
        children: [
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
                            MaterialPageRoute(builder: (context) => OneListing(petId: pet.id)),
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
                      builder: (context) => NewListing(ownerId: 2), // Pass ownerId here
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
          BottomNavigationBarItem(icon: Icon(Icons.list),label: "List"),
          BottomNavigationBarItem(icon: Icon(Icons.add),label: "New Listing"),
        ],
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectIndex,
        selectedItemColor: Colors.indigoAccent,
        onTap: pageChange,
        iconSize: 35,

      ),
    );
  }
}
