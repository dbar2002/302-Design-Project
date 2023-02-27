import 'package:cloud_firestore/cloud_firestore.dart';

import 'roles.dart';

//WILL ADD ROLES LATER

class User {
  final int? uid;
  final String? email;
  final String? password;
  final String? fullname;
  //final Roles? roles;

  User({
    this.uid,
    this.email,
    this.password,
    this.fullname,
    /*this.roles*/
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot['id'] as int,
      email: snap['email'] as String,
      password: snapshot['password'] as String,
      fullname: snapshot['fullname'] as String,
      //roles: Roles.fromJson(snapshot['Role']));
    );
  }

  Map<String, dynamic> toJson() => {
        "username": fullname,
        "uid": uid,
        "email": email,
      };

  @override
  String toString() {
    return 'Users{name: $fullname, email: $email}';
  }
}
