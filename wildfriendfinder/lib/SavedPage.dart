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
  int _selectIndex = 2;

  Future<void>? _savedPetsFuture;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _savedPetsFuture = _loadSavedPets();
  }

  Future<void> _loadSavedPets() async {
    print('Starting _loadSavedPets for user: ${widget.userId}');
    try {
      CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');
      print('Fetching user document...');
      DocumentSnapshot userDoc = await usersRef.doc(widget.userId).get();
      print('User document fetched.');

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('savedPets')) {
          _savedPets = List<String>.from(data['savedPets']);
          print('Saved pets loaded: $_savedPets');
        } else {
          _savedPets = [];
          print('No savedPets field found for user.');
        }
      } else {
        _savedPets = [];
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error loading saved pets: $e');
      _savedPets = [];
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          print('isLoading set to false.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> index =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
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
            FutureBuilder<void>(
              future: _savedPetsFuture,
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child:
                      CircularProgressIndicator());
                } else if (futureSnapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${futureSnapshot.error}'));
                } else {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Pets')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text(
                                "No pets available."));
                      }

                      final pets = snapshot.data!.docs;

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