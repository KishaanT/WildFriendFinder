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

  const ListingPage({
    super.key,
    required this.userId,
    required this.index,
  });

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  // final Stream<QuerySnapshot> _petStream = FirebaseFirestore.instance.collection('Pets').snapshots();

  CollectionReference pets = FirebaseFirestore.instance.collection('Pets');

  TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  bool isGridView = false;
  //  List <Map<String, dynamic>> _petsList = [];
  bool isLoading = true;
  List<dynamic> _savedPets = [];

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
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Users');

      DocumentSnapshot documentSnapshot =
      await collectionRef.doc(widget.userId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('savedPets')) {
          List<dynamic> retrievedArray = data['savedPets'];

          // 7. Update the state with the retrieved array.
          setState(() {
            _savedPets = retrievedArray;
            isLoading =
            false; //  set isLoading to false after successfully fetching
          });
          print('Retrieved array: $_savedPets'); //debugging
        } else {
          print('Array field does not exist in the document.');
          setState(() {
            isLoading =
            false; //  set isLoading to false if the array doesn't exist
          });
        }
      } else {
        print('Document does not exist.');
        setState(() {
          isLoading =
          false; //  set isLoading to false if the document doesn't exist
        });
      }
    } catch (e) {
      print('Error retrieving array: $e');
      setState(() {
        isLoading =
        false; //  set isLoading to false on error, to prevent the app from hanging
      });
      // Handle errors appropriately in your application
    }
  }

  Future<void> _savePet(String petId) async {
    CollectionReference usersRef =
    FirebaseFirestore.instance.collection('Users');
    DocumentReference userDocRef = usersRef.doc(widget.userId);

    try {
      if (_savedPets.contains(petId)) {
        await userDocRef.update({
          'savedPets': FieldValue.arrayRemove([petId])
        });
        setState(() {
          _savedPets.remove(petId);
        });
      } else {
        await userDocRef.update({
          'savedPets': FieldValue.arrayUnion([petId])
        });
        setState(() {
          _savedPets.add(petId);
        });
      }
    } catch (e) {
      print("Error saving pet: $e"); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> index =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = index['index'];
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
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection('Pets').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No pets available."));
                }

                final pets = snapshot.data!.docs;

                final filteredPets = pets.where((pet) {
                  if (searchTerm.isEmpty) return true;
                  final breed =
                  (pet['breed'] ?? '').toString().toLowerCase();
                  return breed.contains(searchTerm);
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
                          'No pets found matching "$searchTerm"',
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
                      final petId = pet.id; // Get the pet's ID
                      final isSaved =
                      _savedPets.contains(petId);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OneListing(
                                    petId: petId,
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
                                      Text(pet['name'] ?? 'Unnamed',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold)),
                                      Row(
                                        children: [
                                          Text('Breed: ${pet['breed']}'),
                                          Spacer(),
                                          IconButton(
                                            icon: Icon(isSaved
                                                ? Icons.favorite
                                                : Icons
                                                .favorite_border),
                                            onPressed: () {
                                              _savePet(
                                                  petId); // Use petId here
                                            },
                                            color: Colors.red,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      );
                    })
                    : ListView.builder(
                  itemCount: filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = filteredPets[index];
                    final petId = pet.id; // Get the pet ID
                    final isSaved =
                    _savedPets.contains(petId); // Check if saved
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: pet['imageAssetsPath'] != null
                            ? Image.asset(pet['imageAssetsPath'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover)
                            : Image.asset('assets/default.jpg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover),
                        title: Text(pet['name'] ?? 'Unnamed'),
                        subtitle: Text('Breed: ${pet['breed']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${pet['age']} yrs'),
                            SizedBox(width: 8), // Add some spacing
                            IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () {
                                _savePet(
                                    petId); // Pass the pet ID to _savePet
                              },
                              color: Colors.red,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OneListing(
                                petId: petId,
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
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
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: Colors.deepPurple,
            ),
            label: "List",
          ),
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
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              color: Colors.deepPurple,
            ),
            label: "Account",
          )
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

