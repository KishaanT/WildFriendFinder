import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final String? userId;
  final int? index;
  const NotificationsPage({super.key, required this.userId, required this.index});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('PetRequests')
          .doc(requestId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${newStatus}')),
      );
    } catch (e) {
      print('Error updating request status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request')),
      );
    }
  }

  Future<void> deleteNotification(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('PetRequests')
          .doc(requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> index = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = index['index'] ;
    print(_selectIndex);
    List<String> _widgetOption = ['homePage', 'listingPage', 'notifications', 'accountPage'];

    void pageChange(int index) {
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(context, _widgetOption[index],
            arguments: {'index': _selectIndex, 'userId': widget.userId});
      });
    }
    print('Notifications Page - Current UserId: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('PetRequests')
            .where('ownerId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          print('Number of notifications found: ${snapshot.data?.docs.length ?? 0}');

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Requests for your pets will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              print('Notification $index: $data');

              final timestamp = data['timestamp'] as Timestamp?;
              final dateString = timestamp != null
                  ? DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate())
                  : 'Date not available';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Pets')
                    .doc(data['petId'])
                    .get(),
                builder: (context, petSnapshot) {
                  if (petSnapshot.hasError) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Error loading pet information'),
                      ),
                    );
                  }

                  if (!petSnapshot.hasData) {
                    return Container();
                  }

                  final petData = petSnapshot.data!.data() as Map<String, dynamic>?;
                  final petName = petData?['name'] ?? 'Unknown Pet';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Request for $petName',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStatusChip(data['status'] ?? 'unknown'),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteNotification(doc.id),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'From: ${data['requesterName'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Email: ${data['requesterEmail'] ?? 'No email'}',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone: ${data['requesterPhone'] ?? 'No phone'}',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          SizedBox(height: 8),
                          Text(
                            dateString,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (data['status'] == 'pending') ...[
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => updateRequestStatus(doc.id, 'accepted'),
                                    child: Text('Accept'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => updateRequestStatus(doc.id, 'declined'),
                                    child: Text('Decline'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'accepted':
        backgroundColor = Colors.green;
        break;
      case 'declined':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}