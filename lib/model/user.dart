import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'roles.dart';

//WILL ADD ROLES LATER

class User {
  final String? uid;
  final String? email;
  final String? password;
  final String? fullname;
  Map<String, String>? organizationsAndRoles;

  User({
    this.uid,
    this.email,
    this.password,
    this.fullname,
    this.organizationsAndRoles,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot['id'] as String,
      email: snap['email'] as String,
      password: snapshot['password'] as String,
      fullname: snapshot['fullname'] as String,
      organizationsAndRoles: snapshot['organizations'],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": fullname,
        "uid": uid,
        "email": email,
        "organizations": organizationsAndRoles
      };

  @override
  String toString() {
    return 'Users{name: $fullname, email: $email}';
  }
}
