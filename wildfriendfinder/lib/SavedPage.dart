import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'NewListing.dart';
import 'OneListing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class SavedPage extends StatefulWidget {
  final String? userId;
  final int? index;

  const SavedPage({
    super.key,
    required this.userId,
    required this.index,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  CollectionReference pets = FirebaseFirestore.instance.collection('Pets');
  TextEditingController searchController = TextEditingController();
  String searchTerm = '';
  bool isGridView = false;
  bool isLoading = true;
  List<String> _savedPets = [];
  int _selectIndex = 2; // Initialize _selectIndex for SavedPage

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPets();
  }

  Future<void> _loadSavedPets() async {
    try {
      CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');
      DocumentSnapshot userDoc = await usersRef.doc(widget.userId).get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('savedPets')) {
          _savedPets = List<String>.from(data['savedPets']);
        } else {
          _savedPets = [];
        }
      } else {
        _savedPets = [];
      }
    } catch (e) {
      print('Error loading saved pets: $e');
      _savedPets = [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> index =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    //int _selectIndex = index['index'];  //remove this
    List<String> _widgetOption = [
      'homePage',
      'listingPage',
      'savedPage', // Ensure 'savedPage' is in the list
      'notifications',
      'accountPage'
    ];

    void pageChange(int index) {
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(context, _widgetOption[index], arguments: {
          'userId': widget.userId,
          'index': _selectIndex
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
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
              icon: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.deepPurple,
              ))
        ],
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
                  borderSide:
                  BorderSide(color: Colors.deepPurple, width: 2),
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
            child:
            // Use a FutureBuilder to first get the saved pets, then use a StreamBuilder
            // to listen to changes in the 'Pets' collection.
            FutureBuilder<void>(
              future: _loadSavedPets(), // A Future that completes when _loadSavedPets is done.
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child:
                      CircularProgressIndicator()); // Show loading until saved pets are loaded
                } else if (futureSnapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${futureSnapshot.error}')); // Show error if loading saved pets fails
                } else {
                  // Once _loadSavedPets is complete, use a StreamBuilder to listen to 'Pets'
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Pets')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator()); // Show loading for pets data
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text(
                                "No pets available.")); //  no pets in general
                      }

                      final pets = snapshot.data!.docs;

                      // Filter pets based on both search term and savedPets
                      final filteredPets = pets.where((pet) {
                        final petId = pet.id;
                        final breed =
                        (pet['breed'] ?? '').toString().toLowerCase();
                        return _savedPets.contains(petId) &&
                            breed.contains(searchTerm);
                      }).toList();

                      if (filteredPets.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                _savedPets.isEmpty
                                    ? 'No pets saved yet.'
                                    : 'No saved pets found matching "$searchTerm"',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return isGridView
                          ? GridView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: filteredPets.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            final pet = filteredPets[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OneListing(
                                          petId: pet.id,
                                          userId: widget.userId,
                                        )));
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: pet['imageAssetsPath'] != null
                                            ? Image.asset(
                                            pet['imageAssetsPath'],
                                            fit: BoxFit.cover)
                                            : Image.asset(
                                            'assets/default.jpg',
                                            fit: BoxFit.cover),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(pet['name'] ??
                                                  'Unnamed',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold)),
                                              Text(
                                                  'Breed: ${pet['breed']}'),
                                            ]),
                                      )
                                    ]),
                              ),
                            );
                          })
                          : ListView.builder(
                        itemCount: filteredPets.length,
                        itemBuilder: (context, index) {
                          final pet = filteredPets[index];
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              leading: pet['imageAssetsPath'] != null
                                  ? Image.asset(
                                  pet['imageAssetsPath'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover)
                                  : Image.asset('assets/default.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover),
                              title: Text(pet['name'] ?? 'Unnamed'),
                              subtitle: Text('Breed: ${pet['breed']}'),
                              trailing:
                              Text('${pet['age']} yrs'),
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
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewListing(ownerId: widget.userId),
                    ),
                  );
                },
                child: Text('New Listing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
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

