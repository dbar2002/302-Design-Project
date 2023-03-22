import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'roles.dart';

//WILL ADD ROLES LATER

class User {
  final String? uid;
  final String? email;
  final String? password;
  final String? fullname;
  Map<String, String>? organizationsAndRoles;
  final String? CBUAccess;
  User({
    this.uid,
    this.email,
    this.password,
    this.fullname,
    this.organizationsAndRoles,
    this.CBUAccess,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;
    // If refresh is set to true, a refresh of the id token is forced.

    return User(
      uid: snapshot['id'] as String,
      email: snap['email'] as String,
      password: snapshot['password'] as String,
      fullname: snapshot['fullname'] as String,
      organizationsAndRoles: snapshot['organizations'],
      CBUAccess: 'Test'
    );
  }

  Map<String, dynamic> toJson() => {
        "username": fullname,
        "uid": uid,
        "email": email,
        "organizations": organizationsAndRoles,
        "CBUAccess": CBUAccess
      };

  @override
  String toString() {
    return 'Users{name: $fullname, email: $email}';
  }
}
