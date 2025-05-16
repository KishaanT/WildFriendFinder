import 'dart:io';

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
  String? docUserId; // We can delete this

  String? selectedImagePath;

  final List<Map<String, String>> availableImages = [
    {'path': 'assets/dog1.jpg', 'name': 'Dog 1'},
    {'path': 'assets/dog2.jpg', 'name': 'Dog 2'},
    {'path': 'assets/dog3.jpg', 'name': 'Dog 3'},
    {'path': 'assets/dog4.jpg', 'name': 'Dog 4'},
    {'path': 'assets/dog5.jpg', 'name': 'Dog 5'},
    {'path': 'assets/dog6.jpg', 'name': 'Dog 6'},
    {'path': 'assets/default.jpg', 'name': 'Default'},
  ];

  Future<void> addPetListing() async {
    try {
      Pet newPet = Pet(
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          species: speciesController.text.trim(),
          breed: breedController.text.trim(),
          sex: sexController.text.trim(),
          description: descriptionController.text.trim(),
          ownerId: widget.ownerId,
          imageAssetsPath: selectedImagePath ?? 'assets/default.jpg',
      );
      await FirebaseFirestore.instance
          .collection('Pets')
          .add(newPet.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet added successfully!')),
      );

      clearFields();
    } catch (e) {
      showError("Failed to make listing");
      print('Error: $e');
    }
  }

  void showError(String error) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Unsuccessful'),
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
    setState(() {
      selectedImagePath = null;
    });
  }

  void showImagePicker() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image'),
          content: Container(
            width: 300,
            height: 400,
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                ),
              itemCount: availableImages.length,
              itemBuilder: (context, index) {
                  final image = availableImages[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImagePath = image['path'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border:  Border.all(
                          color: selectedImagePath == image['path']
                              ? Colors.blue
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                              child: Image.asset(image['path']!, fit: BoxFit.cover,)
                          ),
                          Text(image['path']!),
                        ],
                      ),
                    ),
                  );
              },
            ),
          ),
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Wild Friend Finder",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  SizedBox(height: 30),

                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImagePath != null
                    ? Image.asset(selectedImagePath!, fit: BoxFit.cover,)
                        : IconButton(icon: Icon(Icons.add_photo_alternate, size: 50, ), onPressed: showImagePicker
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: showImagePicker, child: Text(selectedImagePath != null ? 'Change Image' : 'Select Image')),


                  SizedBox(height: 20,),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: speciesController,
                      decoration: InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: breedController,
                      decoration: InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: sexController,
                      decoration: InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true
                      ),
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        addPetListing();
                      },
                      child: Text('Post Listing')),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text('Go to Listing')),
                ],
              ),
            )),
      ),
    );
  }
}
