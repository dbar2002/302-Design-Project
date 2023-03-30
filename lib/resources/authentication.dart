import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avandra/model/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required Map<String, String> organization,
  }) async {
    String res = "Some error Occurred";
    String role = setUserRole(email);

    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          organization.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        model.User _user = model.User(
          fullname: username,
          uid: cred.user!.uid,
          email: email,
          organizationsAndRoles: organization,
          CBUAccess: role,
        );

        //
        await waitForCustomClaims();
        // adding user in our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> getUserRole(String userId) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("users").doc(userId);
    String access = "Admin";
    await documentReference.get().then((snapshot) {
      access = snapshot.get("CBUAccess").toString();
    });
    return access.toString();
  }

  Future waitForCustomClaims() async {
    User currentUser = _auth.currentUser!;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    Stream<DocumentSnapshot> docs =
        userDocRef.snapshots(includeMetadataChanges: false);

    DocumentSnapshot data = await docs
        .firstWhere((DocumentSnapshot snapshot) => snapshot?.data != null);
    print('data ${data.toString()}');

    IdTokenResult idTokenResult = (await (currentUser.getIdTokenResult(true)));
    print('claims : ${idTokenResult.claims}');
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String setUserRole(String email) {
    String domain = email.split('@')[1]; // saves what comes after the @
    String first = email.split('@')[0]; // saves what comes before the @
    String role = "Visitor";
    if (domain.toLowerCase().contains('calbaptist.edu') &&
        first.contains(".")) {
      role = "Student";
    } else if (domain.toLowerCase().contains('calbaptist.edu') &&
        !first.contains(".")) {
      role = "Employee";
    } else if (first.toLowerCase().contains('avandra')) {
      role = 'Admin';
    }
    return role;
  }
}
