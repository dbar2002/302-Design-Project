import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class getOrganizations {
  static Future<List<String>> getOrgs() async {
    List<String> dataList = [];
    QuerySnapshot feed =
        await FirebaseFirestore.instance.collection("organizations").get();
    for (var element in feed.docs) {
      dataList.add(element['name']);
    }
    Text("Hello");
    return dataList;
  }
}
