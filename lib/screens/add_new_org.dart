import 'package:avandra/widgets/input_box.dart';
import 'package:avandra/utils/colors.dart';
import 'package:avandra/utils/fonts.dart';
import 'package:avandra/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../resources/validator.dart';
import '../widgets/basic_button.dart';

class AddNewOrgScreen extends StatefulWidget {
  const AddNewOrgScreen({super.key});

  @override
  State<AddNewOrgScreen> createState() => _AddNewOrgScreenState();
}

class _AddNewOrgScreenState extends State<AddNewOrgScreen> {
  final TextEditingController _schoolOrg = TextEditingController();
  bool? student = false;
  bool? visitor = false;
  bool? employee = false;

  final email = FirebaseAuth.instance.currentUser?.email;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late final organization;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  void dispose() {
    super.dispose();
    _emailController.dispose();
    _organizationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: backgroundColor,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/userProf', (route) => false);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 25,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          Text(
            'School/Organization',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: regularTextSize,
              color: regularTextSizeColor,
            ),
          ),
          const SizedBox(height: 15),
          InputBox(
            textEditingController: _schoolOrg,
            hintText: 'Enter School/Org Here',
            title: TextInputType.text,
            validator: (value) => Validator.validateOrg(
              org: value,
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: this.student,
                onChanged: (bool? value) {
                  setState(() {
                    this.student = value;
                  });
                },
                overlayColor: MaterialStatePropertyAll(Colors.black),
                checkColor: Colors.black,
                activeColor: Colors.white,
              ),
              Text(
                'Student',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: regularTextSize,
                  color: regularTextSizeColor,
                ),
              ),
              Checkbox(
                value: this.visitor,
                onChanged: (bool? value) {
                  setState(() {
                    this.visitor = value;
                  });
                },
                overlayColor: MaterialStatePropertyAll(Colors.black),
                checkColor: Colors.black,
                activeColor: Colors.white,
              ),
              Text(
                'Visitor',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: regularTextSize,
                  color: regularTextSizeColor,
                ),
              ),
              Checkbox(
                value: this.employee,
                onChanged: (bool? value) {
                  setState(() {
                    this.employee = value;
                  });
                },
                overlayColor: MaterialStatePropertyAll(Colors.black),
                checkColor: Colors.black,
                activeColor: Colors.white,
              ),
              Text(
                'Employee',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: regularTextSize,
                  color: regularTextSizeColor,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              FirebaseFunctions.instance
                  .httpsCallable('assignUserRole')
                  .call({"data": _emailController.toString()});
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('organizations')
                  .add(
                    organization,
                  );

              if (student!) {
                showSnackBar(
                    context, 'Organization added with student access!');
              }
              if (visitor!) {
                showSnackBar(
                    context, 'Organization added with visitor access!');
              }
              if (employee!) {
                showSnackBar(
                    context, 'Organization added with employee access!');
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: Text('Add organization',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: regularTextSize,
                  color: Colors.white,
                )),
          )
        ],
      ),
      backgroundColor: backgroundColor,
    );
  }
}
