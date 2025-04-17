import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OneListing extends StatefulWidget {
  final String? petId;
  const OneListing({super.key, required this.petId});

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

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .where('userId', isEqualTo: ownerId)
              .limit(1)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final userDocs = userSnapshot.data?.docs ?? [];
            final userData = userDocs.isNotEmpty
                ? userDocs.first.data() as Map<String, dynamic>
                : null;

            return Scaffold(
              appBar: AppBar(
                title: Text(petData['name'] ?? 'Pet Details'),
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

