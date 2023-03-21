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
  bool _isLoading = false;
  List<Object> objectList = [];
  late String selectedFruit;

  Future<String> loadFromAssets() async {
    return await rootBundle.loadString('lib/json/organizations.json');
  }

  @override
  void initState() {
    super.initState();
    loadYourData();
  }

  loadYourData() async {
    setState(() {
      _isLoading = true;
    });

    String jsonString = await loadFromAssets();
    final orgResponse = fruitResponseFromJson(jsonString);
    objectList = orgResponse.objects;
    setState(() {
      _isLoading = true;
    });
  }


  @override
  Widget build(BuildContext context) {    
    String selectedFruit = "";

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
      //     )
      //   )
      )
      );
  
  }

}

FruitResponse fruitResponseFromJson(String str) => FruitResponse.fromJson(json.decode(str));

String fruitResponseToJson(FruitResponse data) => json.encode(data.toJson());

class FruitResponse {
    List<Object> objects;
    int from;
    int to;
    int total;

    FruitResponse({
        required this.objects,
        required this.from,
        required this.to,
        required this.total,
    });

    factory FruitResponse.fromJson(Map<String, dynamic> json) => FruitResponse(
        objects: List<Object>.from(json["objects"].map((x) => Object.fromJson(x))),
        from: json["from"],
        to: json["to"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "objects": List<dynamic>.from(objects.map((x) => x.toJson())),
        "from": from,
        "to": to,
        "total": total,
    };
}

class Object {
    String id;
    String name;
    String city;

    Object({
        required this.id,
        required this.name,
        required this.city,
    });

    factory Object.fromJson(Map<String, dynamic> json) => Object(
        id: json["id"],
        name: json["autocompleteTerm"],
        city: json["city"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "city": city,
    };
}