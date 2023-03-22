//select_map.dart

import 'dart:convert';

import 'package:avandra/assets/org_parser.dart';
import 'package:avandra/screens/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/fonts.dart';
import '../utils/colors.dart';
import '../utils/global.dart';

class SelectMapScreen extends StatefulWidget {
  const SelectMapScreen({Key? key}) : super(key: key);

  @override
  State<SelectMapScreen> createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {

  // final List<String> items = [
  //   'One',
  //   'Two',
  //   'Three',
  // ];

  // String? selectedValue;
  // bool showDropdown = true;

  @override
  Widget build(BuildContext context) {    

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("SELECT MAP SCREEN", style:TextStyle(color: regularTextSizeColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton( //makeshift functional back button
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/Menu'); //hardcode return to menu
          },
        ),
      ),
      body: Center (

        
      //   child: DropdownButtonHideUnderline(
      //     child: ButtonTheme(
      //       alignedDropdown: true,
      //       child: DropdownButton(
      //         isExpanded: true,
      //         hint: Row(
      //           children: const [
      //             SizedBox(
      //               width: 4,
      //             ),
      //             Expanded(
      //               child: Text(
      //               'Select Your Status',
      //               style: TextStyle(
      //                 fontSize: 15,
      //                 fontWeight: FontWeight.bold,
      //                 color: smallerTextColor,
      //               ),
      //               textAlign: TextAlign.left,
      //               overflow: TextOverflow.ellipsis,
      //               ),
      //               ),
      //           ],
      //         ),
      //         items: items.map((item) => DropdownMenuItem<String>(
      //           value: item,
      //           child: Text(
      //             item,
      //             style: const TextStyle(
      //             fontSize: 15,
      //             fontWeight: FontWeight.bold,
      //             color: regularTextSizeColor,
      //             ),
      //             overflow: TextOverflow.ellipsis,
      //           ),
      //     ))
      //       .toList(),
      //       value: selectedValue,
      //       onChanged: (value) {
      //       setState(() {
      //         selectedValue = value as String;
      //       });
      //     },
      // )
          
        )
      );
  
  }

}
