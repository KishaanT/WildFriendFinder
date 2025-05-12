import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditPetPage.dart';

class OneListing extends StatefulWidget {
  final String? petId;
  final String? userId;

  const OneListing({super.key, required this.petId, required this.userId});

  @override
  State<OneListing> createState() => _OneListingState();
}

class _OneListingState extends State<OneListing> {


  @override
  Widget build(BuildContext context) {


    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Pets').doc(widget.petId).get(),
      builder: (context, petSnapshot) {
        if (petSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!petSnapshot.hasData || !petSnapshot.data!.exists) {
          return Scaffold(body: Center(child: Text('Pet not found.')));
        }

        final petData = petSnapshot.data!.data() as Map<String, dynamic>;
        final ownerId = petData['ownerId'];

        final isOwner = widget.userId == ownerId;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(ownerId)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
            print('OwnerId$ownerId');
            return Scaffold(
              appBar: AppBar(
                title: Text(petData['name'] ?? 'Pet Details'),
                backgroundColor: Colors.deepPurple,
                actions: [
                  if (isOwner)
                    IconButton(
                      icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPetPage(
                          petId: widget.petId,
                          petData: petData,
                        )));
                    },
                    ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [Text('Listed by:', style: TextStyle(fontWeight: FontWeight.bold)),
                    userData != null
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userData['fName'] + " " + userData['lName']}'),
                        Text('Email: ${userData['email']}'),
                      ],
                    )
                        : Text('User info not found'),

                    SizedBox(width: 200, child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black,),
                      ),
                    )
                    ),
                    SizedBox(height: 10,),
                    Text('${petData['name']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('${petData['species']} • ${petData['breed']}'),
                    SizedBox(height: 10),
                    Text('Age: ${petData['age']} years'),
                    Text('Sex: ${petData['sex']}'),
                    SizedBox(height: 20),
                    Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(petData['description'] ?? 'No description'),
                    Divider(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

