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

  TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  List <Map<String, dynamic>> _petsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //  _loadPetData();
    // if(_petsList.isEmpty){
    //   print("Empty");
    //   isLoading = false;
    // }
    // else{
    //   print("Not Empty");
    // }
  }

  // Future<void> _loadPetData() async {
  //   try {
  //     String jsonString = await rootBundle.loadString('assets/petsListing.json');
  //     final List<dynamic> jsonData = jsonDecode(jsonString);
  //     setState(() {
  //       _petsList = jsonData.cast<Map<String, dynamic>>();
  //     });
  //   } catch (e) {
  //     print('Error loading JSON: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> index = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = index['index'];
    List<String> _widgetOption = [
      'homePage',
      'listingPage',
      'accountPage'
    ];


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
        title: Text("Dog Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by breed...',
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchTerm = '';
                    });
                  },
                  icon: Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Pets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No pets available."));
                }

                final pets = snapshot.data!.docs;

                final filteredPets = pets.where((pet) {
                  if (searchTerm.isEmpty) return true;
                  final breed = (pet['breed'] ?? '').toString().toLowerCase();
                  return breed.contains(searchTerm);
                }).toList();

                if (filteredPets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No pets found matching "$searchTerm"',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = filteredPets[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: pet['imageAssetsPath'] != null
                            ? Image.asset(pet['imageAssetsPath'], width: 60, height: 60, fit: BoxFit.cover)
                            : Image.asset('assets/default.jpg', width: 60, height: 60, fit: BoxFit.cover),
                        title: Text(pet['name'] ?? 'Unnamed'),
                        subtitle: Text('${pet['species']} • ${pet['breed']}'),
                        trailing: Text('${pet['age']} yrs'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OneListing(
                                petId: pet.id,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
         if(!isLoading)
              Expanded(
                  child: Column(
                    children: [
                      ListView.builder(
                          itemCount: _petsList.length,
                          itemBuilder: (context,index){
                            return Card(
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                leading: _petsList[index]['imageAssetsPath'] != null
                                ? Image.asset(_petsList[index]['imageAssetsPath'], width: 60, height: 60, fit: BoxFit.cover)
                                : Image.asset('assets/default.jpg', width: 60, height: 60, fit: BoxFit.cover),
                                  title: Text(_petsList[index]['name'] ?? 'Unnamed'),
                                  subtitle: Text('${_petsList[index]['species']} • ${_petsList[index]['breed']}'),
                                  trailing: Text('${_petsList[index]['age']} yrs'),
                              )
                            );
                          }
                      )
                    ],
                  )
              ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewListing(ownerId: widget.userId),
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

