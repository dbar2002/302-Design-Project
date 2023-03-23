import 'dart:convert';

import 'package:avandra/assets/org_parser.dart';
import 'package:avandra/screens/edit_profile.dart';
import 'package:avandra/widgets/basic_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/fonts.dart';
// import 'package:avandra/utils/fonts.dart';
import '../utils/colors.dart'; //system cannot find the path?
// import 'package:avandra/utils/colors.dart';
import '../utils/global.dart';
// import 'package:avandra/utils/global.dart';
import '../widgets//logo.dart';

class SelectMapScreen extends StatefulWidget {
  const SelectMapScreen({Key? key}) : super(key: key);

  @override
  State<SelectMapScreen> createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {
  var selectedOrg;
  final TextEditingController _organizationController = TextEditingController();
  late String orgAndRole = _organizationController.text;

  @override
  void dispose() {
    super.dispose();
    _organizationController.dispose();
  }

  String? selectedValue;
  bool showDropdown = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          //title: const Text("SELECT MAP SCREEN", style:TextStyle(color: regularTextSizeColor)),
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            //makeshift functional back button
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/Menu'); //hardcode return to menu
            },
          ),
        ),
        body: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LogoWidget(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 150, bottom: 25),
                      child: Text("Select Your Organization",
                          style: TextStyle(
                              color: Colors.black, fontSize: headingSize)),
                    ),
                    //child: <Widget> [logoWidget()],
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('organizations')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            const Text("Loading...");
                          } else {
                            List<DropdownMenuItem> organizations = [];
                            for (int i = 0;
                                i < (snapshot.data! as dynamic).docs.length;
                                i++) {
                              DocumentSnapshot snap = snapshot.data!.docs[i];
                              organizations.add(
                                DropdownMenuItem(
                                  // ignore: sort_child_properties_last
                                  child: Text(
                                    snap['name'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: regularTextSize,
                                      color: regularTextSizeColor,
                                    ),
                                  ),
                                  value: "${snap['name']}",
                                ),
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 50.0),
                                DropdownButton(
                                  iconDisabledColor: smallerTextColor,
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.black54),
                                  dropdownColor: Colors.white,
                                  items: organizations,
                                  onChanged: (orgValue) {
                                    _organizationController.text = orgValue;
                                    setState(() {
                                      selectedOrg = orgValue;
                                    });
                                  },
                                  value: selectedOrg,
                                  isExpanded: false,
                                  hint: Text(
                                    "Choose Organization",
                                    style: GoogleFonts.montserrat(
                                      fontSize: regularTextSize,
                                      color: regularTextSizeColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Container();
                        }),
                        Padding(padding: const EdgeInsets.only(top: 20),
                child: BasicButton(
                  text: "Add New Organization", 
                  
                  onPressed: () async {Navigator.of(context).pushNamedAndRemoveUntil('/addNewOrg', (route) => false);} 
                )),
                    Padding(
                        padding: const EdgeInsets.only(top: 100, bottom: 25),
                        child: BasicButton(
                            text: "Continue",
                            onPressed: () async {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/nav', (route) => false);
                            })

                        ),
                  ],
                ))));
  }
}
