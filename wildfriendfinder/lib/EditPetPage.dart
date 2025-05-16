import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wildfriendfinder/NewListing.dart';

class EditPetPage extends StatefulWidget {
  final String? petId;
  final Map<String, dynamic> petData;

  const EditPetPage({super.key, required this.petId, required this.petData});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController speciesController;
  late TextEditingController breedController;
  late TextEditingController sexController;
  late TextEditingController descriptionController;
  bool isLoading = false;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: widget.petData['name'] ?? '');
    speciesController =
        TextEditingController(text: widget.petData['species'] ?? '');
    ageController = TextEditingController(text: widget.petData['age'] ?? '');
    breedController =
        TextEditingController(text: widget.petData['breed'] ?? '');
    sexController = TextEditingController(text: widget.petData['sex'] ?? '');
    descriptionController =
        TextEditingController(text: widget.petData['description'] ?? '');
    selectedImagePath =
        widget.petData['imageAssetsPath'] ?? 'assets/default.jpg';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    speciesController.dispose();
    ageController.dispose();
    breedController.dispose();
    sexController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updatePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('Pets')
            .doc(widget.petId)
            .update({
          'name': nameController.text.trim(),
          'species': speciesController.text.trim(),
          'age': ageController.text.trim(),
          'breed': breedController.text.trim(),
          'sex': sexController.text.trim(),
          'description': descriptionController.text,
          'imageAssetsPath': selectedImagePath ?? 'assets/default.jpg',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet listing updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update pet listing'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deletePet() async {
    bool confirmation = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text(
                    'Are you sure you want to delete this pet listing?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              );
            }) ??
        false;
    if (!confirmation) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Delete the pet
      await FirebaseFirestore.instance
          .collection('Pets')
          .doc(widget.petId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet listing deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting listing: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error deleting pet: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        appBar: AppBar(
          title: Text('Edit Pet Listing'),
          actions: [
            IconButton(
                onPressed: () {
                  deletePet();
                },
                icon: Icon(Icons.delete, color: Colors.red,))
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                    key: _formKey,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Edit Pet Information',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Pet Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pets),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the pet name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: speciesController,
                          decoration: InputDecoration(
                            labelText: 'Species',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the species';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: breedController,
                          decoration: InputDecoration(
                            labelText: 'Breed',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.smart_button),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the breed';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: ageController,
                          decoration: InputDecoration(
                            labelText: 'Age (years)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the age';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: sexController,
                          decoration: InputDecoration(
                            labelText: 'Sex',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.transgender),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the sex';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 300,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: selectedImagePath != null
                              ? Image.asset(selectedImagePath!, fit: BoxFit.cover,)
                              : IconButton(icon: Icon(Icons.add_photo_alternate, size: 50, ), onPressed: showImagePicker
                          ),
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(onPressed: showImagePicker, child: Text(selectedImagePath != null ? 'Change Image' : 'Select Image')),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              updatePet();
                            },
                            child: Text('Update'),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    )),
              ));
  }
}
