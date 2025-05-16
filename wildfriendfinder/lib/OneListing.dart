import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditPetPage.dart';
import 'Maps.dart';

class OneListing extends StatefulWidget {
  final String? petId;
  final String? userId;

  const OneListing({super.key, required this.petId, required this.userId});

  @override
  State<OneListing> createState() => _OneListingState();
}

class _OneListingState extends State<OneListing> {
  bool _isRequestPending = false;
  bool _checkingRequest = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkRequestStatus();
  }

  Future<void> checkRequestStatus() async {
    try {
      final petRequestSnapshot = await FirebaseFirestore.instance
          .collection('PetRequests')
          .where('petId', isEqualTo: widget.petId)
          .where('requesterId', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'pending')
          .get();
      setState(() {
        _isRequestPending = petRequestSnapshot.docs.isNotEmpty;
        _checkingRequest = false;
      });
    } catch (e) {
      print('Error checking request status: $e');
      setState(() {
        _checkingRequest = false;
      });
    }
  }

  Future<void> sendRequest(String ownerId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();
      if(!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found')),
        );
        return;
      }
      final userData = userDoc.data() as Map<String, dynamic>;
      await FirebaseFirestore.instance.collection('PetRequests')
      .add({
        'petId': widget.petId,
        'ownerId': ownerId,
        'requesterId': widget.userId,
        'requesterName': '${userData['fName']} ${userData['lName']}',
        'requesterEmail': userData['email'],
        'requesterPhone': userData['phone'],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isRequestPending = true;
      });
    } catch (e) {
      print('Error sending request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('Pets').doc(widget.petId).get(),
      builder: (context, petSnapshot) {
        if (petSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!petSnapshot.hasData || !petSnapshot.data!.exists) {
          return Scaffold(body: Center(child: Text('Pet not found.')));
        }

        final petData = petSnapshot.data!.data() as Map<String, dynamic>;
        final ownerId = petData['ownerId'];
        final imageAssetsPath =
            petData['imageAssetsPath'] ?? 'assets/default.jpg';

        final isOwner = widget.userId == ownerId;

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('Users').doc(ownerId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
            print('OwnerId$ownerId');

            return Scaffold(
              appBar: AppBar(
                title: Text(petData['name'] ?? 'Pet Details', style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.deepPurple,
                actions: [
                  if (isOwner)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white,),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditPetPage(
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
                  children: [
                    userData != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Listed by: ${userData['fName'] + " " + userData['lName']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              // Text('Email: ${userData['email']}'),
                            ],
                          )
                        : Text('User info not found'),
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(imageAssetsPath, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/default.jpg',
                            fit: BoxFit.cover,
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('${petData['name']}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('${petData['species']} • ${petData['breed']}'),
                    SizedBox(height: 10),
                    Text('Age: ${petData['age']} years'),
                    Text('Sex: ${petData['sex']}'),
                    SizedBox(height: 20),
                    Text('Description:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(petData['description'] ?? 'No description'),
                    Divider(height: 40),
                    if (!isOwner)
                      Center(
                        child: _checkingRequest ? CircularProgressIndicator() :
                        ElevatedButton(onPressed:_isRequestPending
                            ? null
                            : () => sendRequest(ownerId),
                          child: Text(_isRequestPending ? 'Request Pending' : 'Request This Pet'),
                        style:  ElevatedButton.styleFrom(
                          backgroundColor: _isRequestPending
                              ? Colors.grey
                              : Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        ),
                      ),
                    SizedBox(height: 10,),
                    if (userData != null && userData['address'] != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLocationPage(
                                          userAddress: userData['address'],
                                          username:
                                              '${userData['fName']} ${userData['lName']}',
                                        )));
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                          label: Text('View Owner Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
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
