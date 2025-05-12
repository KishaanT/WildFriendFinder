import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Pet.dart';

class NewListing extends StatefulWidget {
  final String? ownerId;

  const NewListing({super.key, required this.ownerId});

  @override
  State<NewListing> createState() => _NewListingState();
}

class _NewListingState extends State<NewListing> {

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController speciesController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? docUserId;
  Future<void> addPetListing() async {
    // int newOwnerId = int.parse(widget.ownerId);
    // DocumentSnapshot userDoc = await FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc()
    //     .get();

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Users')
        .where('userId', isEqualTo: widget.ownerId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = snapshot.docs.first;
      docUserId = userDoc.id; // This is the document ID
    }

    try {
      Pet newPet = Pet(
        name: nameController.text.trim(),
        age: ageController.text.trim(),
        species: speciesController.text.trim(),
        breed: breedController.text.trim(),
        sex: sexController.text.trim(),
        description: descriptionController.text.trim(),
        ownerId: docUserId
      );

      await FirebaseFirestore.instance.collection('Pets')
      .add(newPet.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet added successfully!')),
      );

      clearFields();
    } catch(e) {
      showError("Failed to make listing");
      print('Error: $e');

    }
  }

  void showError(String error) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Unsuccessful'),
          content: Text(error),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ));
  }
  void clearFields() {
    nameController.clear();
    ageController.clear();
    speciesController.clear();
    breedController.clear();
    sexController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ), ),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: speciesController,
                      decoration: InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: breedController,
                      decoration: InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: sexController,
                      decoration: InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                    ),),

                  SizedBox(height: 10,),
                  SizedBox(width: 350,
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ), ),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: () async {
                    addPetListing();
                  }, child: Text('Post Listing')),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: () async {
                    Navigator.pop(context);
                  }, child: Text('Go to Listing')),
                ],
              )),
        ),
    );
  }
}
