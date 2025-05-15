import 'package:cloud_firestore/cloud_firestore.dart';

class PetRequest {
  String? petId;
  String? ownerId;
  String? requesterId;
  String? requesterName;
  String? requesterEmail;
  String? requesterPhone;
  String? status; // 'pending', 'accepted', 'declined'
  Timestamp? timestamp;

  PetRequest({
    this.petId,
    this.ownerId,
    this.requesterId,
    this.requesterName,
    this.requesterEmail,
    this.requesterPhone,
    this.status,
    this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'requesterPhone': requesterPhone,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory PetRequest.fromFirestore(Map<String, dynamic> data) {
    return PetRequest(
      petId: data['petId'],
      ownerId: data['ownerId'],
      requesterId: data['requesterId'],
      requesterName: data['requesterName'],
      requesterEmail: data['requesterEmail'],
      requesterPhone: data['requesterPhone'],
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }
}