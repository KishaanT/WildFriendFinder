import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class User {
  String? fName;
  String? lName;
  String? username;
  String? password;
  String? email;
  String? phone;
  String? address;
  String? DOB;


  User({this.fName, this.lName, this.username, this.password, this.email,
      this.phone, this.address, this.DOB});

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      fName: data['fName'] as String?,
      lName: data['lName'] as String?,
      username: data['username'] as String?,
      password: data['password'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      DOB: data['DOB'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // if(userId != null) 'userId' : userId,
      if(fName != null) 'fName' : fName,
      if(lName != null) 'lName' : lName,
      if(username != null) 'username' : username,
      if(password != null) 'password' : password,
      if(email != null) 'email' : email,
      if(phone != null) 'phone' : phone,
      if(address != null) 'address' : address,
      if(DOB != null) 'DOB' : DOB,
    };
  }
}
