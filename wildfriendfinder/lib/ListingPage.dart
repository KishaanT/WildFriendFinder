import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
 import 'HomePage.dart';
 import 'NewListing.dart';

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
      'listingPage'
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> NewListing(ownerId: 2,)));
            }, child: Text('New Listing'))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.deepPurple,),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list),label: "List")
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
